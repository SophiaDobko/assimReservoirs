# Example

list_output <- identBasinsGauges(ID = 25283, distGauges = 20)
plotBasins(list_output)
plotGauges(list_output, distGauges = 20)

api <- requestGauges(requestDate = today(), Ndays = 5, list_output)
list_idw <- idwRain(list_output, api)
plotIDW(list_output, list_idw)

list_routing <- resRouting(list_output)
plotStratRes(list_output, list_routing)

head(riv)
outlet=130960

nodes=riv

for(i in seq(1,nrow(nodes)))
{
  if(st_geometry_type(riv[i,])=='LINESTRING')
  {
    nodes$geometry[i]=st_line_sample(riv[i,],sample=0)
  }
  else
  {
    nodes$geometry[i]=st_linestring()
  }
}


touch=st_touches(filter(nodes,ARCID==outlet),riv)
riv[touch[[1]],] %>% filter(ARCID!=outlet)
