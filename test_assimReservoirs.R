# test

# very important packages
library(roxygen2)
library(devtools)

# automatic documentation
setwd("D:/assimReservoirs")
document()

# install and load this package
setwd("D:/")
install("assimReservoirs")
library(assimReservoirs)

setwd("D:/DownloadReservoirData")

# functions ####
# identBasinGauges
list_output <- identBasinsGauges(ID = 2707, distGauges = 30000)
save(list_output, file = "data/list_output.RData")

# requestGauges
api <- requestGauges(requestDate = today(), Ndays = 5, list_output = list_output)
save(api, file = "data/api.Rdata")

# idwRain
load("data/list_output.RData")
load("data/api.Rdata")
list_idw <- idwRain(list_output, api)

# plots ####
plotBasins(list_output)
plotGauges(list_output)
plotIDW(list_output, list_idw)
