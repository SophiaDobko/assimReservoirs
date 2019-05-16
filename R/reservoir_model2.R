#' Model reservoirs
#'
#' This function models runoff concentration for the contributing basins of a shapefile
#' @param ID ID of the reservoir for which the contributing basins shall be modelled
#' @param start date at which model run shall start, default: as.Date("2000-01-10")
#' @param end date at which model run shall end, default: as.Date("2000-01-15")
#' @return table with vol_0 (volume at the beginning of the timestep t), q_in_m3 (inflow in m3), q_out_m3 (outflow in m3) and vol_1 (volume at the end of the timestep) for each reservoir and for each subbasin
#' @importFrom lubridate year month day
#' @import sf
#' @import raster
#' @import igraph
#' @export

res_model2 <- function(ID = 33443, start = as.Date("2002-04-01"), end = as.Date("2002-04-15")){

# identify contributing catchment
  res <- res_max[res_max$id_jrc == ID,]
  otto_res <- otto[otto$HYBAS_ID == res$HYBAS_ID,]

  catch_v <- which(otto$HYBAS_ID==otto_res$HYBAS_ID) %>%
    all_simple_paths(otto_graph, from = ., mode = "in") %>%
    unlist %>% unique
  catch <- otto[catch_v,]
  buffer <- st_buffer(st_union(catch, by_feature = F), dist = 20 *1000)

# identify leaves of otto_graph
  otto_leaves = which(degree(otto_graph, v = catch_v, mode = "in") == 0)

# identify contributing reservoirs and leaves of reservoir_graph
  res_v <- which(res_max$id_jrc == ID) %>%
  all_simple_paths(reservoir_graph, from = ., mode = "in") %>%
    unlist %>% unique
  reservoirs <- res_max[res_v,]
  res_leaves = which(degree(reservoir_graph, v = res_v, mode = "in") == 0)

# start loop over days
  dates <- seq.Date(from = start, to = end, by = "day")

  collect_res_timesteps <- NULL
# get runoff for stations in the buffer, certain day
  for(d in 1:length(dates)){
    postos <- st_intersection(postos, buffer)
    files <- dir("D:/reservoir_model/Time_series")
    postos$runoff <- NA

    for(i in 1:nrow(postos)){
      if(length(grep(postos$Codigo[i], files))>0){
        data <- read.table(paste0("D:/reservoir_model/Time_series/", grep(postos$Codigo[i], files, value = T)), header = T)
        postos$runoff[i] <- subset(data, Ano == year(dates[d]) & Mes == month(dates[d]) & Dia == day(dates[d]))$Esc..mm.
      }
    }

# interpolate runoff  with IDW, get mean for each subbasin
# Create an empty grid, n is the total number of cells
    g <- as(postos, "Spatial")
    b <- as(buffer, "Spatial")
    c <- as(catch$geometry, "Spatial")
    g@bbox <- b@bbox

    grd              <- as.data.frame(spsample(g, "regular", n=5000))
    names(grd)       <- c("X", "Y")
    coordinates(grd) <- c("X", "Y")
    gridded(grd)     <- TRUE  # Create SpatialPixel object
    fullgrid(grd)    <- TRUE  # Create SpatialGrid object

    # Add projection information to the empty grid
    proj4string(grd) <- proj4string(g)

    # Interpolate the grid cells using a power value of 2 (idp=2.0)
    idw <- gstat::idw(runoff ~ 1, g, newdata=grd, idp=2.0)
    r <- raster(idw)
    r <- mask(r, c)
    r <- crop(r,c)

    # Output: mean runoff for each subcatchment
        for(s in 1:nrow(catch)){
      catch$runoff[s] <- mean(unlist(extract(r,catch[s,])))
    }

# loop through all reservoirs to distribute runoff
    res_mod <- data.frame(t = d, date = dates[d], id_jrc = reservoirs$id_jrc, vol_max = reservoirs$vol_max, runoff_contr_adapt = reservoirs$runoff_contr_adapt)
    for(s in 1:nrow(res_mod)){
      if(length(catch$runoff[catch$HYBAS_ID == reservoirs$HYBAS_ID[s]])>0){
      res_mod$runoff[s] <- catch$runoff[catch$HYBAS_ID == reservoirs$HYBAS_ID[s]]
      }
    }
    if(d == 1){
      res_mod$vol_0 <- 0 }else{
      res_mod$vol_0 <- res_mod0$vol_1 }
    res_mod$Qin_m3 = res_mod$runoff_contr_adapt*res_mod$runoff*1000
    res_mod$Qout_m3[res_mod$Qin_m3  + res_mod$vol_0 > res_mod$vol_max] <- res_mod$vol_0[res_mod$Qin_m3 + res_mod$vol_0 > res_mod$vol_max] + res_mod$Qin_m3[res_mod$Qin_m3 + res_mod$vol_0 > res_mod$vol_max] - res_mod$vol_max[res_mod$Qin_m3 + res_mod$vol_0 > res_mod$vol_max]
    res_mod$Qout_m3[res_mod$Qin_m3 + res_mod$vol_0 <= res_mod$vol_max] <- 0
    res_mod$vol_1 <- res_mod$vol_0 + res_mod$Qin_m3 - res_mod$Qout_m3

# loop through all reservoirs (/subbasins) to distribute qout? ####
    for(l in 1:length(res_leaves)){
      res_downstr <- all_simple_paths(reservoir_graph, from=which(res_max$id_jrc==as.numeric(names(res_leaves)[l])), to = which(res_max$id_jrc==ID), mode='out') %>%
        unlist %>% unique
      res_l <- res_max[res_downstr,]
      # res_l <- res_l[!is.na(res_l$id_jrc),]
      # res_l <- res_l[res_l$id_jrc %in% reservoirs$id_jrc,]

      if(nrow(res_l)>1){
        for(r in 2:nrow(res_l)){
          res_mod$Qin_m3[r] <- res_mod$Qin_m3[r] + res_mod$Qout_m3[r-1]
          if(res_mod$Qin_m3[r]+res_mod$vol_0[r] > res_mod$vol_max[r]){
            res_mod$Qout_m3[r] <- res_mod$vol_0[r] + res_mod$Qin_m3[r] - res_mod$vol_max[r]
          }else{
            res_mod$Qout_m3[r] <- 0 }
          res_mod$vol_1[r] <- res_mod$vol_0[r] + res_mod$Qin_m3[r] - res_mod$Qout_m3[r]
        }
      }
    }

# Collect all timesteps
    collect_res_timesteps <- rbind(collect_res_timesteps, res_mod)
    res_mod0 <- res_mod
  }
  return(collect_res_timesteps)
}

# collect <- res_model2()

