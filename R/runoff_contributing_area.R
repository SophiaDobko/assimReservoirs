#' Estimate runoff contributing areas of each reservoir ####
#'
#' This function estimates the area of directly contributing runoff for all reservoirs, based on the mean yearly runoff of 1960-1990
#' @param start default: as.Date("1960-01-01")
#' @param end default: as.Date("1989-12-31")
#' @return columns runoff_contr_est and runoff_contr_adapt in dataframe res_max, runoff_contr_adapt adapts the estimated (theoretic) runoff contributing area to the actual subbasin area
#' @importFrom lubridate year month day
#' @import raster
#' @export

runoff_contributing_area <- function(start = as.Date("1960-01-01"), end = as.Date("1989-12-31")){

# Interpolate runoff with IDW
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
  postos <- postos[!is.na(postos$runoff_mean),]

  # Interpolate runoff with IDW, get mean for each subbasin
  dat <- as(postos, "Spatial")
  postos$x <- dat@coords[,1]
  postos$y <- dat@coords[,2]
  gs <- gstat(formula=runoff~1, locations=~x+y, data= data.frame(x = postos$x, y = postos$y, runoff = postos$runoff_mean))
  centroids <- st_centroid(otto)
  dat <- as(centroids, "Spatial")
  centroids$x <- dat@coords[,1]
  centroids$y <- dat@coords[,2]
  st_geometry(centroids)=NULL
  idw <- predict(gs,centroids,debug.level=0)
  otto$runoff_mean <- idw$var1.pred


  runoff <- otto[,c(1,7,15)]
  runoff$geometry <- NULL
  res_max <- merge(res_max, runoff, by ="HYBAS_ID")
  res_max <- res_max[c(2:7,1,8,9)]
  res_max$runoff_contr_est <- res_max$vol_max/res_max$runoff_mean/1000

  res_max <- res_max[order(res_max$id_jrc),]
  res_max_routing <- res_max_routing[order(res_max_routing$id_jrc),]
  res_max$res_down <- res_max_routing$res_down

  # Limit runoff_contr_adapt to actual subbasin size
  res_max$runoff_contr_adapt <- res_max$runoff_contr_est
  for(i in 1:length(unique(res_max$HYBAS_ID))){
    basin <- res_max[res_max$HYBAS_ID==unique(res_max$HYBAS_ID)[i],]
    if(sum(basin$runoff_contr_est)>basin$SUB_AREA[1]){
      # big <- basin[!(basin$res_down %in% basin$id_jrc),]
      big <- basin[basin$runoff_contr_est == max(basin$runoff_contr_est),]
      res_max$runoff_contr_adapt[res_max$id_jrc==big$id_jrc] <- big$SUB_AREA-sum(basin$runoff_contr_est[basin$id_jrc != big$id_jrc])
    }
  }
  negative <- res_max[res_max$runoff_contr_adapt<0,]
  if(nrow(negative)>0){
    for(i in 1:length(negative$HYBAS_ID)){
      basin <- res_max[res_max$HYBAS_ID == negative$HYBAS_ID[i],]
      big <- basin[basin$runoff_contr_est == max(basin$runoff_contr_est) | basin$runoff_contr_adapt == max(basin$runoff_contr_adapt),]
      res_max$runoff_contr_adapt[res_max$id_jrc %in% big$id_jrc] <- (big$SUB_AREA[1]-sum(basin$runoff_contr_est[!(basin$id_jrc %in% big$id_jrc)]))/2
    }
  }
  return(res_max)
}

