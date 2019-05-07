#' Create reservoir routing scheme
#'
#' This function creates a routing scheme for the strategic reservoirs, those on the main river course. For each reservoir the next reservoir downstream is identified.
#' @param list_BG the output list of identBasinsGauges
#' @return if no routing is possible "No routing" is printed, otherwise the output is a list with 3 elements: "res_main" is a dataframe of all the reservoirs in the catchment where the area of UP_CELLS > 0.5 * the area of its subbasin, res_down shows the ID of the next downstream reservoir, "reservoirs" is a geospatial dataframe of all the reservoirs in the catchment which are on a river reach of "riv", and "riv_catch" is a geospatial dataframe of all the river reaches in the catchment.
#' @import sf
#' @import raster
#' @export

resRouting <- function(list_BG){

  if(list_BG$routing == F){

    print("No routing ")

    }else{

      print(paste("Routing started at", Sys.time()))

      catch <- list_BG$catch
      res <- list_BG$res
      riv_catch <- st_intersection(riv, st_union(catch))

      res_riv_catch <- st_join(res_max, riv_catch, join = st_intersects)
      res_riv_catch <- subset(res_riv_catch, !is.na(ARCID))
      res_riv_catch <- st_join(res_riv_catch, catch, join = st_intersects)

      reservoirs <- unique(res_riv_catch[,c(1,2)])

      res_order <- NULL
      IDs <- reservoirs$id_jrc

      for(i in 1:length(IDs)){

        res_i <- subset(reservoirs, id_jrc == IDs[i])
        riv_i <- st_join(riv_catch, res_i, join = st_intersects)
        riv_i <- subset(riv_i, !is.na(id_jrc))
        riv_i <- data.frame(ARCID = riv_i$ARCID, UP_CELLS = riv_i$UP_CELLS)
        otto <- st_intersection(catch, res_i)
        otto <- data.frame(HYBAS_ID = otto$HYBAS_ID, SUB_AREA = otto$SUB_AREA)

# calculate up_cells area of riv
        centr <- st_centroid(res_i)
        centr <- st_transform(centr, "+proj=latlong  +datum=WGS84 +no_defs")
        lat <- as.numeric(ymin(extent(centr)))
        up_cells <- max(riv_i$UP_CELLS)
        up_cells_km2 <- up_cells * (30.87 * cos(lat*2*pi/360)*15)^2/(10^6)
        sub_area_km2 <- sum(otto$SUB_AREA)

        o <- data.frame(id_jrc = IDs[i], up_cells_km2 = up_cells_km2, sub_area_km2 = sub_area_km2)
        res_order <- rbind(res_order, o)
      }

      res_main <- subset(res_order, up_cells_km2 > 0.5 * sub_area_km2)
      res_main$res_down <- NA
      # res_not_main <- subset(res_order, up_cells_km2 <= 0.5 * sub_area_km2)

# find the next reservoir downstream

      for(r in 1:nrow(res_main)){

        print(paste(r, "- started reservoir", res_main$id_jrc[r],  "at", Sys.time()))

        res_down <- NULL
        res_r <- subset(res_riv_catch, id_jrc == res_main$id_jrc[r])
        res_r <- subset(res_r, UP_AREA == max(UP_AREA) & UP_CELLS == max(UP_CELLS))

        otto_start <- subset(catch, HYBAS_ID == res_r$HYBAS_ID)


        res_otto_start <- subset(res_riv_catch, id_jrc %in% res_main$id_jrc & HYBAS_ID == otto_start$HYBAS_ID & id_jrc != res_main$id_jrc[r])

# downstream reservoirs have at least the same up_cells and if the same, they should be more near to the next downstream subbasin
        res_down <- subset(res_otto_start, UP_CELLS >= res_r$UP_CELLS)

        if(catch$HYBAS_ID == otto_start$NEXT_DOWN){
          otto_down <- catch[catch$HYBAS_ID == otto_start$NEXT_DOWN,]
          res_down <- res_down[as.numeric(st_distance(res_down, otto_down)) < as.numeric(st_distance(res_r, otto_down))[1],]
        }else{
          otto_down <- NULL
        }
        res_down <- res_down[order(res_down$UP_CELLS, decreasing = T),]
        res_down <- res_down[!duplicated(res_down$id_jrc),]

# choose the reservoir with the smallest distance to res
        if(nrow(res_down) > 1){
          res_down <- res_down[st_distance(res_down,res) == min(st_distance(res_down, res)),]
          res_main$res_down[r] <- res_down$id_jrc[1]
        }

        if(nrow(res_down) == 1){
          res_main$res_down[r] <- res_down$id_jrc[1]
        }

# go to the next downstream subbasin until finding a reservoir
        if(nrow(res_down) == 0){
          if(res_main$id_jrc[r] == res$id_jrc){
        next

          }else{
            if(is.null(otto_down)){
              next
            }

          while(nrow(res_down) == 0){
            otto_start <- otto_down
            otto_down <- catch[catch$HYBAS_ID == otto_start$NEXT_DOWN,]
            res_otto_start <- subset(res_riv_catch, id_jrc %in% res_main$id_jrc & HYBAS_ID == otto_start$HYBAS_ID & id_jrc != res_main$id_jrc[r])

# downstream reservoirs have at least the same up_cells and if the same, they should be more near to the next downstream subbasin
            res_down <- subset(res_otto_start, UP_CELLS >= res_r$UP_CELLS)
            res_down <- res_down[as.numeric(st_distance(res_down, otto_down)) < as.numeric(st_distance(res_r, otto_down))[1],]
            res_down <- res_down[order(res_down$UP_CELLS, decreasing = T),]
            res_down <- res_down[!duplicated(res_down$id_jrc),]


# choose the reservoir with the smallest distance to res
            if(nrow(res_down) > 1){
              res_down <- res_down[st_distance(res_down, res_r) == min(st_distance(res_down, res_r)),]
              res_main$res_down[r] <- res_down$id_jrc[1]
            }

            if(nrow(res_down) == 1){
              res_main$res_down[r] <- res_down$id_jrc[1]
            }
          }
        }
      }
    }

    list_routing <- list("res_main" = res_main, "reservoirs" = reservoirs,"riv_catch" =  riv_catch)
    return(list_routing)
    print(paste("Routing finished at", Sys.time()))
  }

}


