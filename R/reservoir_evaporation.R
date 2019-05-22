#' Evaporation from reservoir surface
#'
#' Calculate evaporation from reservoir surface to include in ```reservoir_model```
#' @importFrom lubridate year month day
#' @import sf
#' @importFrom gstat gstat
#' @export

reservoir_evaporation <- function(){

# Calculate reservoir surface area with old approach (Molle 1994) ####
res_mod$area_1 <- (res_mod$vol_1/1500)^1/(2.7/(2.7-1))*2.7*1500

# Get potential evaporation from postos
print(paste(Sys.time(), "starting to interpolate evaporation for", dates[d]))

postos$evaporation <- NA
for(i in 1:nrow(postos)){
  data <- time_series[[paste0(postos$Codigo[i])]]
  postos$evaporation[i] <- subset(data, Ano == year(dates[d]) & Mes == month(dates[d]) & Dia == day(dates[d]))$Evap..mm.
  }

# Interpolate potential evaporation with IDW, get mean for each subbasin
gs <- gstat(formula=evaporation~1, locations=~x+y, data= data.frame(x = postos$x, y = postos$y, evaporation = postos$evaporation))
idw <- predict(gs,centroids,debug.level=0)
catch$evaporation <- idw$var1.pred

res_mod$ETP <- NA
for(s in 1:nrow(res_mod)){
  if(length(catch$evaporation[catch$HYBAS_ID == reservoirs$HYBAS_ID[s]])>0){
    res_mod$ETP[s] <- catch$evaporation[catch$HYBAS_ID == reservoirs$HYBAS_ID[s]]
  }
}

res_mod$ETact <- res_mod$area_1*res_mod$ETP*0.001

return(res_mod)
}
