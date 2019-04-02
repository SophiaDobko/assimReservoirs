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

load("D:/assimReservoirs/data/otto_CE.RData")
load("D:/assimReservoirs/data/res_max.RData")
load("D:/assimReservoirs/data/riv_CE.RData")
ID <- 37380
ID <- 44755

res <- subset(res_max, id_jrc == ID)
otto_res <- st_intersection(otto, res)

# does res lie on the river network? ####
#res <- st_transform(res, "+proj=utm +zone=24 +datum=WGS84 +no_defs")
#riv <- st_transform(riv, "+proj=utm +zone=24 +datum=WGS84 +no_defs")

riv_res <- st_join(riv, res, join = st_intersects)
riv_res <- riv_res[!is.na(riv_res$id_jrc),]


centr <- st_centroid(res)
lat <- ymin(extent(centr))
cells <- max(riv_res$UP_CELLS)
area_cont <- cells * 30.87 * cos(lat*2*pi/360)
cos(49*2*pi/360)

# plot ####
plot(res$geometry, col = "cadetblue4")
plot(riv_res$geometry, add = T)
plot(centr, col = "red", add = T)


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
catch_buffer <- st_buffer(st_union(catch, by_feature = F), dist = distGauges *1000)

gauges_catch <- st_intersection(gauges, catch_buffer)

return(list_output <- list("res" = res, "catch" = catch, "catch_buffer" = catch_buffer, "gauges_catch" = gauges_catch))
}


