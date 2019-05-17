#' Identify contributing basins - sf
#'
#' This function identifies contributing basins of an sf geospatial dataframe
#' @param shape shapefile (WGS84, UTM zone=24 south) to identify its contributing basins, e.g. a reservoir from ```data(res_max)```
#' @return a geospatial dataframe of all contributin subbasins
#' @import sf
#' @import igraph
#' @export

contributing_basins_shape <- function(shape = res_max[res_max$id_jrc == 25283,]){
  otto_res <- st_intersection(shape, otto)
  catch_v <- which(otto$HYBAS_ID %in% otto_res$HYBAS_ID) %>%
    all_simple_paths(otto_graph, from = ., mode = "in") %>%
    unlist %>% unique
  catch <- otto[catch_v,]
  return(catch)
}

# catch <- contributing_basins_shape()


#' Identify contributing basins - reservoir
#'
#' This function identifies contributing basins of a reservoir from ```res_max```
#' @param ID id of a reservoir from ```res_max```
#' @return a geospatial dataframe of all contributing subbasins
#' @import sf
#' @import igraph
#' @export

contributing_basins_res <- function(ID = 25283){
  res <- res_max[res_max$id_jrc == ID,]
  otto_res <- otto[otto$HYBAS_ID == res$HYBAS_ID,]
  catch_v <- which(otto$HYBAS_ID==otto_res$HYBAS_ID) %>%
    all_simple_paths(otto_graph, from = ., mode = "in") %>%
    unlist %>% unique
  catch <- otto[catch_v,]
  return(catch)
}

# catch <- contributing_basins_res()


#' Identify Rain gauges of the catchment
#'
#' This function identifies rain gauges within a certain distance around the catchment
#' @param catch output of ```contributing_basins_res``` or ```contributing_basins_shape```
#' @param distGauges distance in km around the contributing basins to look for rain gauges
#' @return a point shapefile with the rain gauges within the chosen distance (distGauges)
#' @import sf
#' @export

rain_gauges_catch <- function(catch, distGauges = 30){
  gauges <- st_transform(p_gauges_saved, "+proj=utm +zone=24 +south +datum=WGS84 +no_defs")
  buffer <- st_buffer(st_union(catch, by_feature = F), dist = distGauges *1000)
  gauges_catch <- st_intersection(gauges, buffer)

  return(gauges_catch)
}

# gauges_catch <- rain_gauges_catch(catch)

