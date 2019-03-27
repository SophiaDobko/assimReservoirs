#' Interpolate rain data
#'
#' This function interpolates rain data using idw (inverse distance weighted) interpolation
#' @export
date <- as.Date("2019-03-24")

idwRain <- function(date, list_output, api){

library(gstat)
library(sp)
library(sf)
library(raster)

apisub <- subset(api, returnedDate == date)
gauges_catch <- merge.data.frame(list_output$gauges_catch, apisub, by = "codigo")

# IDW due to https://mgimond.github.io/Spatial/interpolation-in-r.html ####
# = inverse distance weighted interpolation

# Create an empty grid where n is the total number of cells
g <- st_as_sf(gauges_catch[,c(1,18,21)])
g <- as(g, "Spatial")
b <- as(list_output$catch_buffer, "Spatial")
c <- as(list_output$catch, "Spatial")
g@bbox <- b@bbox

grd              <- as.data.frame(spsample(g, "regular", n=50000))
names(grd)       <- c("X", "Y")
coordinates(grd) <- c("X", "Y")
gridded(grd)     <- TRUE  # Create SpatialPixel object
fullgrid(grd)    <- TRUE  # Create SpatialGrid object

# Add P's projection information to the empty grid
proj4string(grd) <- proj4string(g)

# Interpolate the grid cells using a power value of 2 (idp=2.0)
idw <- gstat::idw(value ~ 1, g, newdata=grd, idp=2.0)

# Convert to raster object then clip to catchment
r <- raster(idw)
r <- mask(r, c)

# Output: daily mean rain for the whole catchment and the reservoir
res <- as(list_output$res, "Spatial")
#problem?????####
rRes <- mask(r, res)

dailyRain <- data.frame("date" = date, "catch_mean" = mean(values(r), na.rm =T), "reservoir_mean" = mean(values(rRes), na.rm = T))

return(list_idw <- list("idw" = r, "dailyRain_table" = dailyRain))
}




