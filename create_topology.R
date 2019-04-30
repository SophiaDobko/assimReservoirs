library(sf)
library(assimReservoirs)
library(dplyr)

riv_all=split_river_network(riv)

## chose a reach ID to select the relevant river network
reach_id=130960 # eg outlet of Jaguaribe

riverid=filter(riv_all,ARCID==reach_id) %>% pull(membership)
riv_i = filter(riv_all,membership==riverid)
nodes_i = riv2nodes(riv_i)

g = riv2graph(nodes_i,riv_i)

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


neighbors(g,5,mode='out')

incident(g,5,mode='out')

degree_distribution(g,cumulative=TRUE)

# get vertices
V(g)

# get edges
E(g)


all_simple_paths(g,from=8)


A = g[,] %>% as.matrix # adjacency matrix
A[1:10,1:10]

L = laplacian_matrix(g) %>% as.matrix
L[1:10,1:10]
