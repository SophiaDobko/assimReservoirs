# reservoir model
setwd("D:/reservoir_model")

library(assimReservoirs)
list_BG <- identBasinsGauges(ID = 49301)

catch <- list_BG$catch
plotGauges(list_BG)
buffer <- list_BG$catch_buffer

library(gstat)
library(sp)
library(sf)
library(raster)
library(lubridate)

postos <- read.csv("postos.csv", dec = ".", sep = "\t", header = T)
postos$lat <- - as.numeric(char2dms(from = as.character(postos$Latitude..S.), chd = "°", chm = "'", chs = "\""))
postos$lon <- - as.numeric(char2dms(from = as.character(postos$Longitude..W.), chd = "°", chm = "'", chs = "\""))

coordinates(postos) <- ~lon+lat
proj4string(postos) <- "+proj=longlat +datum=WGS84 +no_defs"
postos <- st_as_sf(postos)
postos_utm <- st_transform(postos, crs = "+proj=utm +zone=24 +datum=WGS84 +units=m +no_defs")

plot(buffer)
plot(catch$geometry, add = T)
plot(postos_utm$geometry, add = T)

# start loop over days ####
start <- as.Date("2000-01-01")
end <- as.Date("2000-01-15")
dates <- seq.Date(from = start, to = end, by = "day")

collect_timesteps <- NULL
# get runoff for stations in the buffer, certain day
for(d in 1:length(dates)){
  postos <- st_intersection(postos_utm, buffer)
  files <- dir("Time_series")
  postos$runoff <- NA
  for(i in 1:nrow(postos)){
    if(length(grep(postos$Codigo[i], files))>0){
      data <- read.table(paste0("Time_series/", grep(postos$Codigo[i], files, value = T)), header = T)
      postos$runoff[i] <- subset(data, Ano == year(dates[d]) & Mes == month(dates[d]) & Dia == day(dates[d]))$Esc..mm.
    }
  }

# interpolate runoff, get mean for each subbasin
# IDW = inverse distance weighted interpolation

# Create an empty grid where n is the total number of cells
g <- as(postos, "Spatial")
b <- as(list_BG$catch_buffer, "Spatial")
c <- as(list_BG$catch$geometry, "Spatial")
g@bbox <- b@bbox

grd              <- as.data.frame(spsample(g, "regular", n=50000))
names(grd)       <- c("X", "Y")
coordinates(grd) <- c("X", "Y")
gridded(grd)     <- TRUE  # Create SpatialPixel object
fullgrid(grd)    <- TRUE  # Create SpatialGrid object

# Add P's projection information to the empty grid
proj4string(grd) <- proj4string(g)

# Interpolate the grid cells using a power value of 2 (idp=2.0)
idw <- gstat::idw(runoff ~ 1, g, newdata=grd, idp=2.0)
r <- raster(idw)
r <- mask(r, c)
r <- crop(r,c)

# Output: mean runoff for each subcatchment
for(s in 1:nrow(catch)){
  catch$runoff_mean[s] <- mean(unlist(extract(r,catch[s,])))
}

# Routing
if(list_BG$routing){
#  resRouting(list_BG)
  print("strategic reservoirs -> routing necessary")

  }else{
    sub <- subset(catch, UP_AREA == min(catch$UP_AREA))
    res_sub <- st_intersection(res_max, sub[,c(15)])
# length(unique(res_sub$id_jrc))

plot(sub$geometry)
plot(res_sub$geometry, add = T, col = "cadetblue2")
plot(riv$geometry, add = T, col = "cadetblue")

# res_sub_riv <- st_intersection(res_sub, riv)
# plot(res_sub_riv$geometry, col = "red", add = T)

res_sub$cont_area <- (as.numeric(st_area(sub)))/nrow(res_sub)
# first timestep
res_sub$t <- d
if(d == 1){ res_sub$vol_0 <- 0 }else{
  res_sub$vol_0 <- res_sub0$vol_1 }
res_sub$Qin_m3 <- res_sub$runoff_mean * res_sub$cont_area *0.001
res_sub$Qout_m3[res_sub$Qin_m3 > res_sub$vol_max] <- res_sub$vol_0[res_sub$Qin_m3 > res_sub$vol_max] + res_sub$Qin_m3[res_sub$Qin_m3 > res_sub$vol_max] - res_sub$vol_max[res_sub$Qin_m3 > res_sub$vol_max]
res_sub$Qout_m3[res_sub$Qin_m3 <= res_sub$vol_max] <- 0
res_sub$vol_1 <- res_sub$vol_0 + res_sub$Qin_m3 - res_sub$Qout_m3

collect_timesteps <- rbind(collect_timesteps, res_sub)
res_sub0 <- res_sub

  }
}


