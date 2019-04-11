#' Plot contributing basins
#'
#' This function plots the identified contributing basins of identBasinsGauges
#' @param list_output output of identBasinsGauges
#' @export

plotBasins <- function(list_output){
  plot(list_output$catch$geometry, col = "white", main = "Reservoir with contributing basins")
  plot(list_output$res$geometry, col = "cadetblue4", add = T)
}


#' Plot rain gauges
#'
#' This function plots the identified rain gauges of identBasinsGauges
#' @param list_output output of identBasinsGauges
#' @param distGauges distance in km around the contributing basins to look for rain gauges as it was used in identBasinsGauges, defaults to 30
#' @export

plotGauges <- function(list_output, distGauges = 30){
  plot(list_output$catch_buffer, border = "green", main = paste("Basins with rain gauges within", distGauges, "km"))
  plot(list_output$catch$geometry, add = T, border = "red", col = "white")
  plot(list_output$gauges_catch$geometry, add = T)
}


#' Plot idw interpolation
#'
#' This function plots the interpolated precipitation in the contributing basins
#' @param list_output output of identBasinsGauges
#' @param list_idw output of idwRain
#' @export

plotIDW <- function(list_output, list_idw){

  library(manipulate)
  function(raster)

  dailyRain <- list_idw$dailyRain_table
  idwRaster <- list_idw$idwRaster

  par(mar = c(2,2,2,2), oma = c(1,1,1,1))
   manipulate(
    plot(idwRaster[[day]], main = names(idwRaster)[[day]]),
    day = slider(1,5))
}


#' Plot strategic reservoirs
#'
#' This function plots the strategic reservoirs identified by resRouting
#' @param list_output output of identBasinsGauges
#' @export

plotStratRes <- function(list_output, list_routing){

  catch <- list_output$catch
  res_main <- list_routing$res_main
  riv_catch <- list_routing$riv_catch
  res_riv_catch <- list_routing$res_riv_catch


  plot(catch$geometry, col = "white")
  plot(riv_catch$geometry, col = "cadetblue", add = T)
  plot(reservoirs$geometry, col = "gray50", border = "gray50", add = T)
  plot(reservoirs$geometry[reservoirs$id_jrc %in% res_main$id_jrc], col = "cadetblue4", border = "cadetblue4", add = T)
  legend("bottomright", fill = c("cadetblue4", "gray50"), legend = c("strategic reservoirs", "non-strategic reservoirs"), cex = 0.7)
}

