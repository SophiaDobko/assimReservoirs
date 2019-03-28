# test

setwd("D:/assimReservoirs")
library(roxygen2)
library(devtools)
document()

setwd("D:/DownloadReservoirData")

# functions ####
# identBasinGauges
list_output <- identBasinsGauges(ID = 2707)
save(list_output, file = "data/list_output.RData")

# requestGauges
api <- requestGauges(requestDate = today(), Ndays = 5, list_output = list_output)
save(api, file = "data/api.Rdata")

# idwRain
load("data/list_output.RData")
load("data/api.Rdata")
idwRain <- idwRain(list_output, api)

# plots ####
#identBasinGauges
plot(catch$geometry, col = "white")
plot(res$geometry, col = "red", border = "red", add = T)

#requestGauges
plot(catch_buffer, border = "green")
plot(catch$geometry, add = T, border = "red", col = "white")
plot(gauges_catch$geometry, add = T)

#idwRain
dailyRain_table <- idwRain$dailyRain_table
idwRaster <- idwRain$idwRaster
# plot idw in context of considered gauges
plot(list_output$gauges_catch$geometry)
plot(idwRaster[[1]], add=T)
# plot only idw for catchment and reservoir
plot(idwRaster[[1]])
plot(list_output$res$geometry, add = T)
plot(list_output$catch$geometry, add = T)

