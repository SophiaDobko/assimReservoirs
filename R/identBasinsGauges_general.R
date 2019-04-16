#' Contributing basins and rain gauges
#'
#' This function identifies contributing basins and surrounding rain gauges
#' @param shape shapefile (WGS84, UTM zone=24) of the geometry for which the catchment shall be identified, e.g. a reservoir from ```data(res_max)```
#' @param distGauges distance in km around the contributing basins to look for rain gauges, defaults to 30
#' @return a list with 6 elements:
#' - ```res``` is the treated shape/reservoir,
#' - ```catch``` is the catchment contributing to this shape/reservoir,
#' - ```catch_km2``` gives the area of the catchment in square kilometers,
#' - ```catch_buffer``` is a shapefile of a buffer zone of the chosen size around the catchment,
#' - ```gauges_catch``` is a point shapefile with the rain gauges within "catch_buffer" and
#' - ```routing``` is logical, indicating if routing can be done (TRUE when the shape/reservoir receives water from upstream subbasins)
#' @export

identBasinsGauges_gen <- function(shape, distGauges = 30){

library(maptools)
library(sf)
library(gtools)
library(raster)

# Identify contributing basins ####

otto_int <- st_intersection(otto, shape)

otto_shape <- NULL
for(i in 1:nrow(otto_int)){
  c <- subset(otto, HYBAS_ID == otto_int$HYBAS_ID[i])
  otto_shape <- rbind(otto_shape, c)
}

# does shape lie on the river network?
riv_shape <- st_join(riv, shape, join = st_intersects)
riv_shape <- riv_shape[!is.na(riv_shape$id_jrc),]

if(nrow(riv_shape)==0){
# identify all reservoirs in otto_shape, calculate area-share
  catch <- otto_shape

  all_res <- st_intersection(res_max, catch)
  all_res$geometry <- NULL
  all_res <- unique(all_res[,c(1,2)])
  catch_km2 <- (sum(catch$SUB_AREA)-sum(all_res$area_max*1e-06))/nrow(all_res)
  routing <- F
}else{
# reservoir is on river
# calculate up_cells of riv
centr <- st_centroid(shape)
centr <- st_transform(centr, "+proj=latlong  +datum=WGS84 +no_defs")
lat <- as.numeric(ymin(extent(centr)))
up_cells <- max(riv_shape$UP_CELLS)
up_cells_km2 <- up_cells * (30.87 * cos(lat*2*pi/360)*15)^2/(10^6)

# Check if the lowest subbasin is really contributing to the reservoir/shape ####
# if up-cells >= up-area - lowest subbasin -> lowest subbasin contributes
# if up-cells < up-area - lowest subbasin -> lowest subbasin is not part of otto_res
otto1 <- otto_shape[otto_shape$UP_AREA == max(otto_shape$UP_AREA),]
  if(up_cells_km2 < otto1$UP_AREA - otto1$SUB_AREA){
    otto_shape <- subset(otto_shape, HYBAS_ID != otto1$HYBAS_ID)
  }

  if(up_cells_km2 <= sum(otto_shape$SUB_AREA)){
# catch_km2 =  up_cells_km2, catch = otto_shape
    catch_km2 <- up_cells_km2
    catch <- otto_shape
    routing <- F

  }else{
    # up_cells_km2 > sum(otto_shape$SUB_AREA)
    catch_km2 <- max(otto_shape$UP_AREA)

    catch <- otto_shape[otto_shape$UP_AREA == max(otto_shape$UP_AREA),]
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

return(list_BG <- list("res" = shape, "catch" = catch, "catch_km2" =  catch_km2, "catch_buffer" = catch_buffer, "gauges_catch" = gauges_catch, "routing" = routing))
}


