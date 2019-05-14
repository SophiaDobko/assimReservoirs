#' Estimate runoff contributing areas of each reservoir ####
#'
#' This function estimates the area of directly contributing runoff for all reservoirs, based on the mean yearly runoff of 1960-1990
#' @param start default: as.Date("1960-01-01")
#' @param end default: as.Date("1990-01-01")
#' @return columns runoff_est and runoff_adapt in dataframe res_max
#' @importFrom lubridate year month day
#' @import sf
#' @import raster
#' @export

runoff_contributing <- function(start = as.Date("1960-01-01"), end = as.Date("1989-12-31")){

  # catch <- list_BG$catch
  # buffer <- list_BG$catch_buffer
  # postos_utm <- postos

  # start loop over days
  dates <- seq.Date(from = start, to = end, by = "day")
  files <- dir("D:/reservoir_model/Time_series")
  postos$runoff_mean <- NA

  for(i in 1:nrow(postos)){
    if(length(grep(postos$Codigo[i], files))>0){
      data <- read.table(paste0("D:/reservoir_model/Time_series/", grep(postos$Codigo[i], files, value = T)), header = T)
      data$date <- as.Date(paste0(data$Ano, "-", data$Mes, "-", data$Dia))
      data <- subset(data, date >= start & date <= end)
      data1 <- aggregate(data$Esc..mm., FUN = sum, by = list(data$Ano))
      postos$runoff_mean[i] <- mean(data1$x)
    }
  }

  # interpolate runoff, get mean for each subbasin
  # IDW = inverse distance weighted interpolation

  # Create an empty grid, n is the total number of cells
  postos <- postos[!is.na(postos$runoff_mean),]
  g <- as(postos, "Spatial")
  b <- as(otto, "Spatial")
  c <- as(otto$geometry, "Spatial")
  g@bbox <- b@bbox

  grd              <- as.data.frame(spsample(g, "regular", n=50000))
  names(grd)       <- c("X", "Y")
  coordinates(grd) <- c("X", "Y")
  gridded(grd)     <- TRUE  # Create SpatialPixel object
  fullgrid(grd)    <- TRUE  # Create SpatialGrid object

  # Add P's projection information to the empty grid
  proj4string(grd) <- proj4string(g)

  # Interpolate the grid cells using a power value of 2 (idp=2.0)
  idw <- gstat::idw(runoff_mean ~ 1, g, newdata=grd, idp=2.0)
  r <- raster(idw)
  r <- mask(r, c)
  r <- crop(r,c)

  # Output: mean runoff for each subcatchment
  for(s in 1:nrow(otto)){
    otto$runoff_mean[s] <- mean(unlist(extract(r,otto[s,])), na.rm = T)
  }

#  res_max <- merge(res_max, otto$runoff_mean, by = )



}




