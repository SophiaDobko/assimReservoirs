# reservoir routing with river graph ####
# library(dplyr)
# riv %>% group_by(ARCID) %>% summarize(N=n()) %>% filter(N>1)
# library(assimReservoirs)
library(sf)
library(igraph)

Routing <- function(){
  res_max$res_down <- -1
  strategic <- res_max[res_max$`distance to river`==0,]
  g <- river_graph

# get leaves ####
  leaves = which(degree(g, v = V(g), mode = "in")==0)

# for-loop through leaves ####
  for(l in 1:length(leaves)){

    riv_downstr <- all_simple_paths(g,from=leaves[l],mode='out') %>%
    unlist %>% unique

    riv_l <- riv[riv_downstr,]
    strat_downstr <- subset(strategic, `nearest river` %in% riv_l$ARCID)

    points <- st_line_sample(riv_l, n = 2000)
    points <- st_cast(points, "POINT")
    points <- st_sf(points)
    points$sample <- 1:2000
    points <- st_buffer(points, dist = 100)

    inter <- st_intersection(strat_downstr, points)
    r <- data.frame(id_jrc = unique(inter$id_jrc))
    for(i in 1:nrow(r)){
      r$sample_max[i] <- max(inter$sample[inter$id_jrc== r$id_jrc[i]])
    }
    for(i in 1:(nrow(r)-1)){
      res_max$res_down[res_max$id_jrc==r$id_jrc[i]] <- r$id_jrc[i+1]
    }



    # if(nrow(strat_downstr) > 1){
    #   strat_downstr <- st_join(strat_downstr, riv_l, join = st_intersects)
    #
    # first <- st_join(strat_downstr[1,], riv_l, join = st_intersects)
    # last <- st_join(strat_downstr[nrow(strat_downstr),], riv_l, join = st_intersects)
    #
    # if(max(first$UP_CELLS) > max(last$UP_CELLS)){
    #   strat_downstr <- strat_downstr[nrow(strat_downstr):1,]
    # }
    # if(max(first$UP_CELLS) == max(last$UP_CELLS)){
    #
    # }
    #   #
    #
    #   for(s in 1:nrow(strat_downstr)){
    #     res_max$res_down[res_max$id_jrc == strat_downstr$id_jrc[s]] <- strat_downstr$id_jrc[s+1]
    #   }
    # }
    # }
  }
  res_max$res_down[is.na(res_max$res_down)] <- -100
  strategic <- res_max[res_max$`distance to river`==0,]
  strategic <- strategic[!is.na(strategic$id_jrc),]
  st_write(strategic, dsn = "D:/shapefiles/strategic_res.shp")

  return(res_max)
}

res_max <- Routing()


