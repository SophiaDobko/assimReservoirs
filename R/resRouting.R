#' Create reservoir routing scheme
#'
#' This function creates a routing scheme for the strategic reservoirs, those on the main river course. For each reservoir the next reservoir downstream is identified.
#' @param list_output the output list of identBasinsGauges
#' @export

resRouting <- function(list_output){

  library(sf)

  if(list_output$routing == F){

    print("no routing ")

    }else{

      print("routing in process...")

      catch <- list_output$catch
      riv_catch <- st_intersection(riv, st_union(catch))

      res_riv_catch <- st_join(res_max, riv_catch, join = st_intersects)
      res_riv_catch <- subset(res_riv_catch, !is.na(ARCID))
      res_riv_catch <- st_join(res_riv_catch, catch, join = st_intersects)

      reservoirs <- unique(res_riv_catch[,c(1,2)])

      res_order <- NULL
      IDs <- reservoirs$id_jrc

      for(i in 1:length(IDs)){

        res <- subset(reservoirs, id_jrc == IDs[i])
        riv <- st_join(riv_catch, res, join = st_intersects)
        riv <- subset(riv, !is.na(id_jrc))
        riv <- data.frame(ARCID = riv$ARCID, UP_CELLS = riv$UP_CELLS)
        otto <- st_intersection(catch, res)
        otto <- data.frame(HYBAS_ID = otto$HYBAS_ID, SUB_AREA = otto$SUB_AREA)

# calculate up_cells area of riv
        centr <- st_centroid(res)
        centr <- st_transform(centr, "+proj=latlong  +datum=WGS84 +no_defs")
        lat <- as.numeric(ymin(extent(centr)))
        up_cells <- max(riv$UP_CELLS)
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

        res_down <- NULL
        res <- subset(res_riv_catch, id_jrc == res_main$id_jrc[r])
        res <- subset(res, UP_AREA == max(UP_AREA) & UP_CELLS == max(UP_CELLS))

        otto_start <- subset(catch, HYBAS_ID == res$HYBAS_ID)
        otto_down <- catch[catch$HYBAS_ID == otto_start$NEXT_DOWN,]
        res_otto_start <- subset(res_riv_catch, id_jrc %in% res_main$id_jrc & HYBAS_ID == otto_start$HYBAS_ID & id_jrc != res_main$id_jrc[r])

# downstream reservoirs have at least the same up_cells and if the same, they should be more near to the next downstream subbasin
        res_down <- subset(res_otto_start, UP_CELLS >= res$UP_CELLS)
        res_down <- res_down[as.numeric(st_distance(res_down, otto_down)) < as.numeric(st_distance(res, otto_down))[1],]
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

          while(nrow(res_down) == 0){
            otto_start <- otto_down
            otto_down <- catch[catch$HYBAS_ID == otto_start$NEXT_DOWN,]
            res_otto_start <- subset(res_riv_catch, id_jrc %in% res_main$id_jrc & HYBAS_ID == otto_start$HYBAS_ID & id_jrc != res_main$id_jrc[r])

# downstream reservoirs have at least the same up_cells and if the same, they should be more near to the next downstream subbasin
            res_down <- subset(res_otto_start, UP_CELLS >= res$UP_CELLS)
            res_down <- res_down[as.numeric(st_distance(res_down, otto_down)) < as.numeric(st_distance(res, otto_down))[1],]
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
          }
        }
      }
    }

  return(res_main)
}


