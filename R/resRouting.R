# routing

resRouting <- function(list_output){

  library(sf)

  if(list_output$routing == F){
  print("no routing ")
    }else{
      print("routing in process...")
catch <- list_output$catch

      riv_catch <- st_intersection(riv, catch)

      res_riv_catch <- st_join(res_max, riv_catch, join = st_intersects)
      res_riv_catch <- subset(res_riv_catch, !is.na(ARCID))

      res_order <- NULL
      IDs <- unique(res_riv_catch$id_jrc)
      for(i in 1:length(IDs)){
        res <- subset(res_riv_catch, id_jrc == IDs[i])
        riv <- unique(data.frame(ARCID = res$ARCID, UP_CELLS = res$UP_CELLS))
        otto <- unique(data.frame(HYBAS_ID = res$HYBAS_ID, SUB_AREA = res$SUB_AREA))

        # calculate up_cells of riv
        centr <- st_centroid(res)
        centr <- st_transform(centr, "+proj=latlong  +datum=WGS84 +no_defs")
        lat <- as.numeric(ymin(extent(centr)))
        up_cells <- max(riv$UP_CELLS)
        up_cells_km2 <- up_cells * (30.87 * cos(lat*2*pi/360)*15)^2/10^6
        sub_area_km2 <- sum(otto$SUB_AREA)

        o <- data.frame(id_jrc = IDs[i], up_cells_km2 = up_cells_km2, sub_area_km2 = sub_area_km2)
        res_order <- rbind(res_order, o)
      }

      res_main <- subset(res_order, up_cells_km2 > 0.5 * sub_area_km2)
      res_main$res_down <- NA
      res_not_main <- subset(res_order, up_cells_km2 <= 0.5 * sub_area_km2)


plot(catch$geometry, col = "white")
plot(riv_catch$geometry, add = T, col = "red")
plot(res_riv_catch$geometry, col = "gray", border = "gray", add = T)
plot(res_riv_catch$geometry[res_riv_catch$id_jrc %in% res_main$id_jrc], add = T)

# find the next reservoir downstream

for(r in 1:length(res_main)){
res_down <- NULL
res <- subset(res_riv_catch, id_jrc == res_main$id_jrc[r])
otto_start <- res[res$UP_AREA == max(res$UP_AREA),]$HYBAS_ID
otto_start <- subset(catch, HYBAS_ID ==otto_start)
otto_down <- catch[catch$HYBAS_ID == otto_start$NEXT_DOWN,]
res_otto_start <- subset(res_riv_catch, id_jrc %in% res_main$id_jrc & HYBAS_ID == otto_start$HYBAS_ID & id_jrc != res_main$id_jrc[r])
# downstream reservoirs have at least the same up_cells and if the same, they should be more near to the next downstream subbasin
res_down <- subset(res_otto_start, UP_CELLS >= max(res$UP_CELLS))
res_down <- res_down[as.numeric(st_distance(res_down, otto_down)) < as.numeric(st_distance(res, otto_down)),]

  if(nrow(res_down) > 1){
    # choose the reservoir with the smallest distance to res
    res_main$res_down[r] <- res_down[st_distance(res_down,res) == min(st_distance(res_down, res)),]$id_jrc
    }

  if(nrow(res_down) == 1){
    res_main$res_down[r] <- res_down$id_jrc
  }
  # go to the next downstream subbasin until finding a reservoir
  if(nrow(res_down) == 0){
    while(is.null(res_down)){

    }
    res_main$res_down[r] <- ...
  }


plot(catch[catch$HYBAS_ID == otto_start,]$geometry)
plot(res_otto_start$geometry, col = "blue", add = T)
plot(res$geometry, col = "darkred", add = T)
plot(res_next_down$geometry, col = "green", add = T)
# plot(catch[catch$HYBAS_ID == 6120357770,]$geometry, col = "green", add = T)
# plot(res$geometry, col = "green", add = T)

otto_down <- otto[otto$HYBAS_ID == otto_start$NEXT_DOWN,]
res_down <- merge(res_main, res_riv_catch[res_riv_catch$HYBAS_ID == otto_down$NEXT_DOWN,], by = "id_jrc")
if(length(unique(res_down$id_jrc)) > 1){ }
if(length(unique(res_down$id_jrc)) == 1){ }
if(length(unique(res_down$id_jrc)) == 0){ }

# a) überprüfe ob mehrere res in subbasin
#    -> mithilfe von arc_ID und up_cells ordnen
# b) while-Schleife um folgende subbasins auf res zu überprüfen
# -> a und b für jedes res durchgehen

while(is.null(res_down)){

  res_main$res_down[r] <- c

  plot(catch$geometry, col = "transparent")
  plot(res_down$geometry, add = T)
  plot(res$geometry, add = T, border = "blue")
    }

   }
  }
}


