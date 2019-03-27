# test

setwd("D:/assimReservoirs")
document()

setwd("D:/DownloadReservoirData")

# functions ####
# identBasinGauges
list_output <- identBasinsGauges(ID = 2707)
save(list_output, file = "data/list_output.RData")
# requestGauges
api <- requestGauges(requestDate = today(), Ndays = 5, list_output = list_output)
save(api, file = "data/api.Rdata")

load("data/list_output.RData")
load("data/api.Rdata")


# plots ####
#identBasinGauges
plot(catch$geometry, col = "white")
plot(res$geometry, col = "red", border = "red", add = T)

#requestGauges
plot(catch_buffer, border = "green")
plot(catch$geometry, add = T, border = "red", col = "white")
plot(gauges_catch$geometry, add = T)

#idwRain
plot(g, col = "red")
plot(r, add = T)
plot(c, add = T)
