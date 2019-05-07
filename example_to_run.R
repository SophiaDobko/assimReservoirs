# Example
library(assimReservoirs)
list_output <- identBasinsGauges(ID = 25283, distGauges = 20)
plotBasins(list_output)
plotGauges(list_output, distGauges = 20)

api <- requestGauges(requestDate = today(), Ndays = 5, list_output)
list_idw <- idwRain(list_output, api)
plotIDW(list_output, list_idw)

list_routing <- resRouting(list_output)
plotStratRes(list_output, list_routing)
