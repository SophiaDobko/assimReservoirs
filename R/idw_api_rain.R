#' Get rain from api data
#'
#' This function interpolates rain data using idw (inverse distance weighted) interpolation
#' @param catch catch output of ```contributing_basins_res``` or ```contributing_basins_shape```
#' @param api output of ```request_api_gauges```
#' @param date one of the dates requested in```request_api_gauges```, defaults to as.Date("2018-03-15")
#' @return ```api_means``` is a geospatial dataframe with the mean api precipitation for each subbasin of the input ```catch```
#' @importFrom gstat gstat
#' @importFrom sf st_transform st_as_sf st_centroid st_geometry
#' @importFrom raster predict
#' @export

apiRain <- function(catch, api, date = as.Date("2018-03-15")){

  p_gauges_saved <- st_transform(p_gauges_saved, "+proj=utm +zone=24 +south +datum=WGS84 +no_defs")
  api_postos <- merge(api, p_gauges_saved[,1], by = "codigo")
  api_postos <- api_postos[!is.na(api_postos$returnedDate),]
  api_postos <- subset(api_postos, returnedDate == "2018-03-15")

  # Interpolate rainfall with IDW, get mean for each subbasin
  dat <- sf::st_as_sf(api_postos)
  dat <- as(dat, "Spatial")
  api_postos$x <- dat@coords[,1]
  api_postos$y <- dat@coords[,2]
  gs <- gstat::gstat(formula=rain~1, locations=~x+y, data= data.frame(x = api_postos$x, y = api_postos$y, rain = api_postos$value))
  centroids <- sf::st_centroid(catch)
  dat <- as(centroids, "Spatial")
  centroids$x <- dat@coords[,1]
  centroids$y <- dat@coords[,2]
  sf::st_geometry(centroids)=NULL
  idw <- predict(gs,centroids,debug.level=0)
  catch$rain <- idw$var1.pred

  return(api_means = catch)
}
