# test

# very important packages
# problem mit "Rtools" -> warum nicht möglich zu installieren, aber immer wieder danach gefragt?
library(roxygen2)
library(devtools)

# automatic documentation
setwd("D:/assimReservoirs")
document()

# install and load this package
setwd("D:/")
install("assimReservoirs")
library(assimReservoirs)

setwd("D:/assimReservoirs")


# functions ####
# identBasinGauges
res_max <- st_read("data/res_max") # choose ID from res_max$id_jrc
ID <- res_max$id_jrc[168] # e.g. 168, ID = 5348
list_output <- identBasinsGauges(ID = ID, distGauges = 30)
# save(list_output, file = "data/list_output.RData")

# requestGauges
api <- requestGauges(requestDate = today(), Ndays = 5, list_output)
# save(api, file = "data/api.Rdata")

# idwRain
# load("data/list_output.RData")
# load("data/api.Rdata")
list_idw <- idwRain(list_output, api)

# plots ####
plotBasins(list_output)
plotGauges(list_output)
plotIDW(list_output, list_idw)

# still in work ####
# new plots/versions ####
plot(res$geometry, col = "cadetblue4")
plot(riv_res$geometry, add = T)
plot(centr, col = "red", add = T)

plot(catch$geometry, col = "white")
plot(otto_res$geometry, border = "red", add = T)
plot(res$geometry, col = "cadetblue4", add = T)

