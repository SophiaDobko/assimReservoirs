# reservoir routing with river graph ####
# library(dplyr)
# riv %>% group_by(ARCID) %>% summarize(N=n()) %>% filter(N>1)
library(sf)

# get leaves ####
g <- river_graph

# leaves=which(degree(g, v = V(g), mode = "in")==0)
# i=leaves[50]
# for(i in leaves){
# riv_down <- riv[neighbors(g,i,mode='out'),]
# }

leaves = which(degree(g, v = V(g), mode = "in")==0)
riv_down <- data.frame(leaves = leaves, riv_down = NA)
for(i in 1:length(leaves)){
  rd <- as.numeric(neighbors(g,leaves[i],mode='out'))
  if(length(rd) == 0){
    riv_down$riv_down[i] <- NA
  }else{
    riv_down$riv_down[i] <- rd
  }
}


# for-loop through leaves
res_max$next_res <- NA
# strategic <- res_max[res_max$`distance to river`==0,]
# river_reaches <- unique(strategic$`nearest river`)

for(l in 1:nrow(riv_down)){
  points <- st_line_sample(riv[riv_down$leaves[l],], n = 50)
  points <- st_cast(points, "POINT")
  points <- st_sf(points)
  points$sample <- 1:50

  res_l <- subset(res_max, `nearest river` == riv$ARCID[l])
  if(nrow(res_l) > 0){
    strat_l <- subset(res_l, `distance to river`==0)

    if(nrow(strat_l) > 1){
      inter <- st_intersection(strat_l, points)
      r <- data.frame(id_jrc = unique(inter$id_jrc))
      for(i in 1:nrow(r)){
        r$sample_max[i] <- max(inter$sample[inter$id_jrc== r$id_jrc[i]])
      }

    }

  }

}

# plot(points)
#
plot(points$points)
# plot(strategic$geometry[strategic$`nearest river`==river_reaches[1]], add = T, col = "cadetblue")

plot(strat_l$geometry, add = T)

