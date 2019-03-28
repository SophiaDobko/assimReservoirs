#' Plot contributing basins
#'
#' This function plots the identified contributing basins of identBasinsGauges
#' @param list_output output of identBasinsGauges
#' @export

plotBasins <- function(list_output){
  plot(list_output$catch$geometry, main = "Reservoir with contributing basins")
  plot(list_output$res$geometry, border = "darkred", add = T)
}


#' Plot contributing rain gauges
#'
#' This function plots the identified rain gauges of identBasinsGauges
#' @param list_output output of identBasinsGauges
#' @param distGauges distance in km around the contributing basins to look for rain gauges, defaults to 30
#' @export

plotGauges <- function(list_output, distGauges = 30){
plot(list_output$catch_buffer, border = "green", main = paste("Basins with rain gauges within", distGauges, "km"))
plot(list_output$catch$geometry, add = T, border = "red", col = "white")
plot(list_output$gauges_catch$geometry, add = T)
}


#' Plot idw interpolation
#'
#' This function plots the identified rain gauges of identBasinsGauges
#' @param list_output output of identBasinsGauges
#' @param list_idw output of idwRain
#' @export
plotIDW <- function(list_output, list_idw){

  library(manipulate)

  dailyRain <- list_idw$dailyRain_table
  idwRaster <- list_idw$idwRaster

   manipulate(
    plot(idwRaster[[n]], main = names(idwRaster)[[n]]),
    n = slider(1,5))
}

