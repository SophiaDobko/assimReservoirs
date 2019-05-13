# reservoir routing with river graph ####
# library(dplyr)
# riv %>% group_by(ARCID) %>% summarize(N=n()) %>% filter(N>1)
library(assimReservoirs)
library(sf)
library(igraph)

Routing <- function(){
  res_max$res_down <- 0
  strategic <- res_max[res_max$`distance to river`==0,]
  g <- river_graph

# get leaves ####
leaves = which(degree(g, v = V(g), mode = "in")==0)

while(length(leaves)>0){

riv_down <- data.frame(leaves = leaves, riv_down = NA)
for(i in 1:length(leaves)){
  rd <- as.numeric(neighbors(g,leaves[i],mode='out'))
  if(length(rd) == 0){
    riv_down$riv_down[i] <- NA
  }else{
    riv_down$riv_down[i] <- rd
  }
}

# for-loop through leaves ####
for(l in 1:nrow(riv_down)){
# for(l in 1:1000){
  # l = 1250

  # identify reservoirs on leave river reach and their order
  # res_l <- subset(res_max, `nearest river` == riv$ARCID[l])
  strat_l <- subset(strategic, `nearest river` == riv$ARCID[l])

  if(nrow(strat_l)>0){

    if(nrow(strat_l)==1){
      r <- data.frame(id_jrc = strat_l$id_jrc, sample_max = NA)
    }

    if(nrow(strat_l) > 1){

      points <- st_line_sample(riv[l,], n = 200)
      points <- st_cast(points, "POINT")
      points <- st_sf(points)
      points$sample <- 1:200
      points <- st_buffer(points, dist = 100)

      inter <- st_intersection(strat_l, points)

      r <- data.frame(id_jrc = unique(inter$id_jrc))
      for(i in 1:nrow(r)){
        r$sample_max[i] <- max(inter$sample[inter$id_jrc== r$id_jrc[i]])
      }
      for(i in 1:(nrow(r)-1)){
        res_max$res_down[res_max$id_jrc==r$id_jrc[i]] <- r$id_jrc[i+1]
      }

    }
  r_old <- r

# go to next river reach to find one next reservoir

  strat_l <- subset(strategic, `nearest river` == riv$ARCID[l])

  if(nrow(strat_l) == 0){
    if(is.na(riv_down$riv[l])){
      res_max$res_down[res_max$id_jrc == r_old$id_jrc[nrow(r_old)]] <- (-1)
    }else{
    next_riv <- riv_down$riv_down[l]

    while(nrow(strat_l) == 0 && length(next_riv)>0){
      # next_riv <- as.numeric(neighbors(g,next_riv,mode='out'))
      # strat_l <- subset(strategic, `nearest river` == riv$ARCID[rownames(riv) == next_riv])
      next_riv <- neighbors(g,next_riv,mode='out')
      strat_l <- subset(strategic, `nearest river` == riv$ARCID[next_riv])
  }

  if(nrow(strat_l) == 0){
    res_max$res_down[res_max$id_jrc == r_old$id_jrc[nrow(r_old)]] <- (-1)
  }

  if(nrow(strat_l)==1){
    res_max$res_down[res_max$id_jrc == r_old$id_jrc[nrow(r_old)]] <- strat_l$id_jrc
  }

  if(nrow(strat_l) > 1){
      points <- st_line_sample(riv[rownames(riv) == next_riv,], n = 200)
      points <- st_cast(points, "POINT")
      points <- st_sf(points)
      points$sample <- 1:200
      points <- st_buffer(points, dist = 100)

      inter <- st_intersection(strat_l, points)
      r <- data.frame(id_jrc = unique(inter$id_jrc))
      for(i in 1:nrow(r)){
        r$sample_max[i] <- max(inter$sample[inter$id_jrc== r$id_jrc[i]])
      }

  res_max$res_down[res_max$id_jrc == r_old$id_jrc[nrow(r_old)]] <- r$id_jrc[1]
        }
      }
    }
  }
}

  # strategic <- res_max[res_max$`distance to river`==0,]

  g=delete_vertices(g, leaves)
  leaves = which(degree(g, v = V(g), mode = "in")==0)
}

return(res_max)
}

res_max <- Routing()

strategic <- subset(res_max,`distance to river`==0)
summary(strategic$res_down)
length(which(strategic$res_down==0))
length(which(strategic$res_down==-1))

# st_write(strategic, dsn = "D:/shapefiles/strategic_res.shp")
# st_write(riv, dsn = "D:/shapefiles/riv_CE.shp")

leaves
plot(g)

plot(points$points)
# plot(strategic$geometry[strategic$`nearest river`==river_reaches[1]], add = T, col = "cadetblue")
# plot(res_l$geometry, add = T)
plot(strat_l$geometry[1], add = T, col = "red")
plot(strat_l$geometry[2], add = T, col = "green")
plot(strat_l$geometry[3], add = T, col = "blue")


plot(strat_l$geometry, col = "red")
# plot(strat_l$geometry, add = T, col = "red")
plot(points$points, add = T)

