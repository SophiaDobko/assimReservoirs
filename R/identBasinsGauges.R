#' Contributing basins and rain gauges
#'
#' This function identifies contributing basins and surrounding rain gauges
#' @param ID id (due to JRC) of the reservoir of interest
#' @param distGauges distance in km around the contributing basins to look for rain gauges, defaults to 30
#' @export

identBasinsGauges <- function(ID, distGauges = 30){

library(maptools)
library(sf)
library(gtools)
library(raster)

# Identify contributing basins ####

res <- subset(res_max, id_jrc == ID)
if(nrow(res) == 0){print(paste("ID", ID, "doesn't exist!"))}
otto_int <- st_intersection(otto, res)

otto_res <- NULL
for(i in 1:nrow(otto_int)){
  c <- subset(otto, HYBAS_ID == otto_int$HYBAS_ID[i])
  otto_res <- rbind(otto_res, c)
}

# does res lie on the river network?
riv_res <- st_join(riv, res, join = st_intersects)
riv_res <- riv_res[!is.na(riv_res$id_jrc),]

if(nrow(riv_res)==0){
# identify all reservoirs in otto_res, calculate area-share
  catch <- otto_res

  all_res <- st_intersection(res_max, catch)
  all_res$geometry <- NULL
  all_res <- unique(all_res[,c(1,2)])
  catch_km2 <- (sum(catch$SUB_AREA)-sum(all_res$area_max*1e-06))/nrow(all_res)
  routing <- F
}else{
# reservoir is on river
# calculate up_cells of riv
centr <- st_centroid(res)
centr <- st_transform(centr, "+proj=latlong  +datum=WGS84 +no_defs")
lat <- as.numeric(ymin(extent(centr)))
up_cells <- max(riv_res$UP_CELLS)
up_cells_km2 <- up_cells * (30.87 * cos(lat*2*pi/360)*15)^2/(10^6)

# Check if the lowest subbasin is really contributing to the reservoirs ####
# if up-cells >= up-area - lowest subbasin -> lowest subbasin contributes
# if up-cells < up-area - lowest subbasin -> lowest subbasin is not part of otto_res
otto1 <- otto_res[otto_res$UP_AREA == max(otto_res$UP_AREA),]
  if(up_cells_km2 < otto1$UP_AREA - otto1$SUB_AREA){
    otto_res <- subset(otto_res, HYBAS_ID != otto1$HYBAS_ID)
  }

  if(up_cells_km2 <= sum(otto_res$SUB_AREA)){
# catch_km2 =  up_cells_km2, catch = otto_res
    catch_km2 <- up_cells_km2
    catch <- otto_res
    routing <- F

  }else{
    # up_cells_km2 > sum(otto_res$SUB_AREA)
    catch_km2 <- max(otto_res$UP_AREA)

    catch <- otto_res[otto_res$UP_AREA == max(otto_res$UP_AREA),]
    c <- subset(otto, NEXT_DOWN == catch$HYBAS_ID)
    catch <- rbind(catch, c)
    while(nrow(c) > 0){
      c <- subset(otto, NEXT_DOWN %in% c$HYBAS_ID)
      catch <- rbind(catch, c)
      routing <- T
    }
  }
}


# Rain gauges ####
gauges <- st_transform(p_gauges_saved, "+proj=utm +zone=24 +datum=WGS84 +no_defs")
catch_buffer <- st_buffer(st_union(catch, by_feature = F), dist = distGauges *1000)
gauges_catch <- st_intersection(gauges, catch_buffer)

return(list_output <- list("res" = res, "catch" = catch, "catch_km2" =  catch_km2, "catch_buffer" = catch_buffer, "gauges_catch" = gauges_catch, "routing" = routing))
}


