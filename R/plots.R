#' Plot contributing basins
#'
#' This function plots the identified contributing basins of contributing_basins_shape and contributing_basins
#' @param catch output from ```contributing_basins_shape``` or ```contributing_basins```
#' @export

plot_contributing_basins <- function(catch, shape){
  plot(catch$geometry, border = "red", main = "Contributing subbasins")
  plot(shape$geometry, col = "cadetblue4", add = T)
}

# plot_contributing_basins(catch, shape = res_max[res_max$id_jrc == 25283,])


#' Plot rain gauges
#'
#' This function plots the identified rain gauges of identBasinsGauges
#' @param catch output of ```contributing_basins_res``` or ```contributing_basins_shape```
#' @param gauges_catch output of ```rain_gauges_catch```
#' @param distGauges distance in km around the contributing basins to look for rain gauges as it was used in identBasinsGauges, defaults to 30
#' @export

plot_gauges_catch <- function(catch, gauges_catch, distGauges = 30){
  buffer <- st_buffer(st_union(catch, by_feature = F), dist = distGauges *1000)
  plot(buffer, border = "green", main = paste("Basins with rain gauges within", distGauges, "km"))
  plot(catch$geometry, add = T, border = "red", col = "white")
  plot(gauges_catch$geometry, add = T)

}

# plot_gauges_catch(catch, gauges_catch)


#' Plot idw interpolation
#'
#' This function plots the interpolated precipitation in the contributing basins
#' @param list_api_rain output of api_rain_raster
#' @import manipulate
#' @import raster
#' @export

plot_api_rain <- function(list_api_rain){

  dailyRain <- list_api_rain$dailyRain_table
  idwRaster <- list_api_rain$idwRaster

  par(mar = c(2,2,2,2), oma = c(1,1,1,1))
  manipulate(
    plot(idwRaster[[day]], main = names(idwRaster)[[day]]),
    day = slider(1,5))
}


#' Plot trmm of subbasins
#'
#' This function plots the averaged precipitation in all subbasins of the contributing basins
#' @param trmm_means output of trmmRain, geospatial dataframe with mean TRMM precipitation of each field of a given sf geometric object
#' @import sf
#' @export

plotTRMM <- function(trmm_means){

  par(oma = c(0,0,1,1))
  plot(trmm_means["trmm_mean"], border = "black", main = "Mean TRMM precipitation")
}

