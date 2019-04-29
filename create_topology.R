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

valid=st_geometry_type(nodes)=='MULTIPOINT'

nodes %<>%
  filter(valid) %>%
  st_cast(., "POINT", group_or_split = FALSE)

riv = filter(riv,valid)





###### Spectral clustering for
A=matrix(0,nrow(nodes),nrow(nodes))
D=matrix(0,nrow(nodes),nrow(nodes))

touching_list=st_touches(riv)
library(igraph)

g = graph.adjlist(touching_list)
c = components(g)

riv=mutate(riv,membership=as.factor(c$membership))

# ggplot(riv) + geom_sf(aes(color=membership))
#
# for(i in seq(min(as.numeric(riv$membership)),max(as.numeric(riv$membership))))
# {
#   plt=ggplot(filter(riv,membership==i)) + geom_sf()
#   ggsave(paste0("member",i,".png"),plt,width=5,height=5)
# }




while
touch=st_touches(filter(nodes,ARCID==outlet_tmp),riv)
riv_upstr = riv[touch[[1]],] %>% filter(ARCID!=outlet)

nodes_upstr = filter(nodes,ARCID %in% pull(riv_upstr,ARCID))

nodes_upstr
