# reservoir model
# library(assimReservoirs)
# list_BG <- identBasinsGauges(ID = 49301)
# list_BG_shape <- identBasinsGauges(shape = subset(res_max, id_jrc==49301))

#' Create reservoir routing scheme
#'
#' This function creates a routing scheme for the strategic reservoirs, those on the main river course. For each reservoir the next reservoir downstream is identified.
#' @param list_BG the output list of identBasinsGauges
#' @param start date at which model run shall start, default: as.Date("2000-01-10")
#' @param end date at which model run shall end, default: as.Date("2000-01-15")
#' @return table with vol_0 (volume at the beginning of the timestep t), q_in_m3 (inflow in m3), q_out_m3 (outflow in m3) and vol_1 (volume at the end of the timestep) for each reservoir
#' @importFrom lubridate year month day
#' @import sf
#' @import raster
#' @export

res_model <- function(list_BG, start = as.Date("2000-01-14"), end = as.Date("2000-01-18")){

  catch <- list_BG$catch
  buffer <- list_BG$catch_buffer
  postos_utm <- postos

# start loop over days
  dates <- seq.Date(from = start, to = end, by = "day")

  collect_timesteps <- NULL
# get runoff for stations in the buffer, certain day
  for(d in 1:length(dates)){
    postos <- st_intersection(postos_utm, buffer)
    files <- dir("D:/reservoir_model/Time_series")
    postos$runoff <- NA

    for(i in 1:nrow(postos)){
      if(length(grep(postos$Codigo[i], files))>0){
        data <- read.table(paste0("D:/reservoir_model/Time_series/", grep(postos$Codigo[i], files, value = T)), header = T)
        postos$runoff[i] <- subset(data, Ano == year(dates[d]) & Mes == month(dates[d]) & Dia == day(dates[d]))$Esc..mm.
      }
    }

# interpolate runoff, get mean for each subbasin
# IDW = inverse distance weighted interpolation

# Create an empty grid, n is the total number of cells
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
# start with first upstream subbasin
    sub <- subset(catch, UP_AREA == min(catch$UP_AREA))
    res_sub <- st_intersection(res_max, sub[,c(15)])
# length(unique(res_sub$id_jrc))

# plot ####
# plot(sub$geometry)
# plot(res_sub$geometry, add = T, col = "cadetblue2")
# plot(riv$geometry, add = T, col = "cadetblue")

# identify lowest reservoir on river
res_sub_riv <- st_intersection(res_sub, riv)
res_low <- subset(res_sub_riv, UP_CELLS == max(res_sub_riv$UP_CELLS))

res_sub$cont_area <- (as.numeric(st_area(sub)))/nrow(res_sub)

res_sub$t <- d
if(d == 1){ res_sub$vol_0 <- 0 }else{
  res_sub$vol_0 <- res_sub0$vol_1 }
res_sub$Qin_m3 <- res_sub$runoff_mean * res_sub$cont_area *0.001
res_sub$Qout_m3[res_sub$Qin_m3 > res_sub$vol_max] <- res_sub$vol_0[res_sub$Qin_m3 > res_sub$vol_max] + res_sub$Qin_m3[res_sub$Qin_m3 > res_sub$vol_max] - res_sub$vol_max[res_sub$Qin_m3 > res_sub$vol_max]
res_sub$Qout_m3[res_sub$Qin_m3 <= res_sub$vol_max] <- 0
res_sub$vol_1 <- res_sub$vol_0 + res_sub$Qin_m3 - res_sub$Qout_m3

# extra calculation for res_low
res_sub$Qin_m3[res_sub$id_jrc == res_low$id_jrc] <- res_sub$Qin_m3[res_sub$id_jrc == res_low$id_jrc] + sum(res_sub$Qout_m3[res_sub$id_jrc != res_low$id_jrc])
if(res_sub$Qin_m3[res_sub$id_jrc == res_low$id_jrc]> res_low$vol_max){
  res_sub$Qout_m3[res_sub$id_jrc == res_low$id_jrc] <- res_sub$vol_0[res_sub$id_jrc == res_low$id_jrc] + res_sub$Qin_m3[res_sub$id_jrc == res_low$id_jrc] - res_sub$vol_max[res_sub$id_jrc == res_low$id_jrc]
}else{
  res_sub$Qout_m3[res_sub$id_jrc == res_low$id_jrc] <- 0 }
res_sub$vol_1[res_sub$id_jrc == res_low$id_jrc] <- res_sub$vol_0[res_sub$id_jrc == res_low$id_jrc] + res_sub$Qin_m3[res_sub$id_jrc == res_low$id_jrc] - res_sub$Qout_m3[res_sub$id_jrc == res_low$id_jrc]

collect_timesteps <- rbind(collect_timesteps, res_sub)
res_sub0 <- res_sub

    }
  }
return(collect_timesteps)
}
