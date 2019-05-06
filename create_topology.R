library(sf,warn.conflicts=FALSE)
library(assimReservoirs,warn.conflicts=FALSE)
library(dplyr,warn.conflicts=FALSE)
library(igraph,warn.conflicts=FALSE)

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

res_max = mutate(res_max,`nearest river`=NA,`distance to river`=NA)
for(i in seq(1,nrow(res_max)))
{
  cat(i,'\n')
  riv_inters <- st_intersects(res_max[i,],riv_i,sparse=FALSE) %>%
    filter(riv_i,.) %>%
    filter(UP_CELLS==max(UP_CELLS))

  if(nrow(riv_inters)==0)
  {
    otto_k=st_intersects(otto,res_max[i,],sparse=FALSE) %>% filter(otto,.)
    riv_k = st_buffer(otto_k,-1000) %>%
    st_union %>%
    st_intersects(riv_i,.,sparse=FALSE) %>%
    filter(riv_i,.)

    if(nrow(riv_k)>0){
      res_max$`nearest river`[i] = st_nearest_feature(res_max[i,],riv_k) %>%
      riv_k$ARCID[.]

      res_max$`distance to river`[i] = st_distance(res_max[i,],filter(riv_k,ARCID==res_max$`nearest river`[i]))
    }
  } else {
    res_max$`nearest river`[i] = riv_inters$ARCID
    res_max$`distance to river`[i] = 0
  }
}



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
