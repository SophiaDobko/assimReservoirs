# Example

ID = 24140
distGauges = 30

list_output <- identBasinsGauges(ID = 24140, distGauges = 30)
plotBasins(list_output)
plotGauges(list_output)

api <- requestGauges(requestDate = today(), Ndays = 5, list_output)
list_idw <- idwRain(list_output, api)
plotIDW(list_output, list_idw)

list_routing <- resRouting(list_output)
plotStratRes(list_output, list_routing)
