#' Contributing basins and rain gauges
#'
#' This function identifies contributing basins and surrounding rain gauges
#' @export

identBasinsGauges <- function(ID){

library(maptools)
library(sf)
library(gtools)
library(raster)

# Identify contributing basins ####
otto <- st_read("data/ottobacias/NIVEL6_B")
otto <- st_transform(otto, "+proj=longlat +datum=WGS84 +no_defs")
#otto <- as(otto, "Spatial")

ce <- st_read("D:/shapefiles/Ceara_muni/Ceara.shp")
ce <- st_transform(ce, "+proj=longlat +datum=WGS84 +no_defs")

otto <- st_intersection(otto, ce)
otto$nunivotto6 <- as.numeric(as.character(otto$nunivotto6))

res <- st_read("D:/shapefiles/res_max")
res <- subset(res, id_jrc == ID)

otto_res <- st_intersection(otto, res)

if(even(otto_res$nunivotto6)){
  catch <- otto[otto$nunivotto6 == otto_res$nunivotto6,]
}else{
  if(even(as.numeric((substr(otto_res$nunivotto6, 5,5))))){
    context <- otto[substr(otto$nunivotto6, 1,5)==substr(otto_res$nunivotto6, 1,5),]
    catch <- context[substr(context$nunivotto6, 1,6)>=substr(otto_res$nunivotto6, 1,6),]
  }else{
    context <- otto[substr(otto$nunivotto6, 1,4)==substr(otto_res$nunivotto6, 1,4),]
    c <- context[nchar(context$nunivotto6)==5,]
    c <- c[substr(c$nunivotto6, 1,5)>=substr(otto_res$nunivotto6, 1,5),]
    context <- context[nchar(context$nunivotto6)==6,]
    context <- context[substr(context$nunivotto6, 1,6)>=substr(otto_res$nunivotto6, 1,6),]
    catch <- rbind(c,context)
  }}

# Rain gauges ####
load("data/p_gauges_saved.RData")
res <- st_transform(res, "+proj=utm +zone=24 +datum=WGS84 +no_defs")
gauges <- st_transform(p_gauges_saved, "+proj=utm +zone=24 +datum=WGS84 +no_defs")
catch <- st_transform(catch, "+proj=utm +zone=24 +datum=WGS84 +no_defs")
catch_buffer <- st_buffer(st_union(catch, by_feature = F), dist = 30000)

gauges_catch <- st_intersection(gauges, catch_buffer)

return(list_output <- list("res" = res, "catch" = catch, "catch_buffer" = catch_buffer, "gauges_catch" = gauges_catch))
}


