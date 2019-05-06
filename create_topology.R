library(sf)
library(assimReservoirs)
library(dplyr)
library(igraph)

riv_all=split_river_network(riv)

## choose a reach ID to select the relevant river network
reach_id=140877 # eg somewhere in the jaguaribe river catchment will select the whole jaguaribe catchment.

riv_i=select_disjoint_river(reach_id,riv_all)
nodes_i = riv2nodes(riv_i)
g = riv2graph(nodes_i,riv_i)
riv_upstr=river_upstream(reach_id,riv_i,g)

##
hybas_id=6121099550
allocate_reservoir_to_river(hybas_id,riv_i,res_max)

otto_k = filter(otto,HYBAS_ID==hybas_id)
res_i=res_max
res_k = st_within(res_i,otto_k,sparse=FALSE) %>%
  filter(res_i,.)

riv_k = st_buffer(otto_k,-1000) %>%
  st_intersects(riv_i,.,sparse=FALSE) %>%
  filter(riv_i,.)

reservoirs_near_river=mutate(res_k,nearest_river=st_nearest_feature(res_k,riv_k)  %>% riv_k$ARCID[.])

plot(reservoirs_near_river)

is.directed(g)


## get leaves
leaves=which(degree(g, v = V(g), mode = "in")==0)
i=leaves[1]
for(i in leaves){
  dwn=neighbors(g,i,mode='out')
}

g=delete_vertices(g, leaves)
leaves=which(degree(g, v = V(g), mode = "in")==0)
leaves
plot(g)



nodes_i$ARCID[p[[i]]]
nodes_i[c(8,6,5,2),]


A = g[,] %>% as.matrix # adjacency matrix
A[1:10,1:10]

L = laplacian_matrix(g) %>% as.matrix
L[1:10,1:10]
