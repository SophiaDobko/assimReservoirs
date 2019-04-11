# Example

ID = 24140
distGauges = 30

list_output <- identBasinsGauges(ID = 24140, distGauges = 30)
# save(list_output, file = "data/list_output.RData")

# requestGauges
api <- requestGauges(requestDate = today(), Ndays = 5, list_output)
# save(api, file = "data/api.Rdata")

# idwRain
# load("data/list_output.RData")
# load("data/api.Rdata")
list_idw <- idwRain(list_output, api)

# resRouting
list_routing <- resRouting(list_output)
# save(list_routing, file = "D:/assimReservoirs/data/list_routing.RData")

# plots ####
plotBasins(list_output)
plotGauges(list_output)
plotIDW(list_output, list_idw)
plotStratRes(list_output, list_routing)
