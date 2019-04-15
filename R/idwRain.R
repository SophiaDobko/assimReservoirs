#' Interpolate rain data
#'
#' This function interpolates rain data using idw (inverse distance weighted) interpolation
#' @param list_BG output of identBasinsGauges
#' @param api output of requestGauges
#' @return a list with 2 elements:
#' - ```idwRaster``` contains a raster with the interpolated precipitation for each requested day,
#' - ```dailyRain_table``` is a dataframe with the mean precipitation of the catchment and the reservoir of each requested day.
#' @export

idwRain <- function(list_BG, api){

library(gstat)
library(sp)
library(sf)
library(raster)

  api <- subset(api, !is.na(value))
  dates <- sort(unique(api$returnedDate))

  dailyRain <- data.frame()
  idwRaster <- list()
  for(i in 1:length(dates)){
    apisub <- subset(api, returnedDate == dates[i])
    gauges_catch <- merge.data.frame(list_BG$gauges_catch, apisub, by = "codigo")

# IDW due to https://mgimond.github.io/Spatial/interpolation-in-r.html ####
# = inverse distance weighted interpolation

# Create an empty grid where n is the total number of cells
g <- st_as_sf(gauges_catch[,c(1,18,21)])
g <- as(g, "Spatial")
b <- as(list_BG$catch_buffer, "Spatial")
c <- as(list_BG$catch$geometry, "Spatial")
g@bbox <- b@bbox

grd              <- as.data.frame(spsample(g, "regular", n=500000))
names(grd)       <- c("X", "Y")
coordinates(grd) <- c("X", "Y")
gridded(grd)     <- TRUE  # Create SpatialPixel object
fullgrid(grd)    <- TRUE  # Create SpatialGrid object

# Add P's projection information to the empty grid
proj4string(grd) <- proj4string(g)

# Interpolate the grid cells using a power value of 2 (idp=2.0)
idw <- gstat::idw(value ~ 1, g, newdata=grd, idp=2.0)
r <- raster(idw)
r <- mask(r, c)
r <- crop(r,c)
idwRaster[[i]] <- r # Output: interpolation raster for each day

# Output: daily mean rain for the whole catchment and the reservoir
res <- as(list_BG$res$geometry, "Spatial")
daily <- data.frame("date" = dates[i], "catch_mean" = mean(unlist(extract(r, c))), "reservoir_mean" = mean(unlist(extract(r, res))))

dailyRain <- rbind(dailyRain, daily)
}
names(idwRaster) <- c(dailyRain$date)
return(list_idw <- list("idwRaster" = idwRaster, "dailyRain_table" = dailyRain))
}




