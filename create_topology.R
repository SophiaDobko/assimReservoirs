library(sf,warn.conflicts=FALSE)
library(assimReservoirs,warn.conflicts=FALSE)
library(dplyr,warn.conflicts=FALSE)
library(igraph,warn.conflicts=FALSE)



inter=st_intersects(riv,filter(res_max,id_jrc==24870),sparse=FALSE)

which(inter)

neighbor=neighbors(river_graph, which(inter), mode = c("out")) %>% as.numeric

river_graph[[which(inter)]]

neighbor



riv[572,]
riv[which(inter),]
nodes[588,]
nodes[which(inter),]

count=riv %>% group_by(ARCID) %>% summarise(N=n())

count %>% filter(N>1)

nodes = riv2nodes(riv)
river_graph = riv2graph(nodes,riv)

save(river_graph,file='data/river_graph.RData')
save(nodes,file='data/nodes.RData')
# st_write(riv,dsn='riv.geojson')
# st_write(res_max,dsn='res_max.geojson')



## create new reservoir dataset with attribution of river reach
res_max_riv=allocate_reservoir_to_river(riv)

riv_all=split_river_network(riv)


## choose a reach ID to select the relevant river network
reach_id=140877 # eg somewhere in the jaguaribe river catchment will select the whole jaguaribe catchment.

riv_i=select_disjoint_river(reach_id,riv_all)



nodes_i = riv2nodes(riv_i)
g = riv2graph(nodes_i,riv_i)
riv_upstr=river_upstream(reach_id,riv_i,g)

## attribute a river reach to each reservoir. compute distance of reservoir to river reach.

# res_id=31440
# res_id=31441
# i=which(res_max$id_jrc==res_id)


# st_write(res_max,"data/res_max_dist_riv.geojson")
#
# save(res_max,file="data/res_max.RData")


is.directed(river_graph)

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
