#' Reservoir routing of strategic reservoirs ####
#'
#' This function identifies which strategic reservoir drains into which stategic downstream reservoir
#' @return the column ```res_down``` in the geospatial dataframe ```res_max```
#' @import sf
#' @import igraph
#' @import dplyr
#' @export

# library(assimReservoirs)

Routing <- function(){
  res_max$res_down <- NA
  strategic <- res_max[res_max$`distance to river`==0,]
  g <- river_graph

# get leaves ####
  leaves = which(degree(g, v = V(g), mode = "in")==0)

# for-loop through leaves ####
  for(l in 1:length(leaves)){

    if(l %in% c(500,1000,1500)){print(paste(Sys.time(),l, "leaves done"))}

    riv_downstr <- all_simple_paths(g,from=leaves[l],mode='out') %>%
    unlist %>% unique

    riv_l <- riv[riv_downstr,]
    strat_downstr <- subset(strategic, `nearest river` %in% riv_l$ARCID)

    if(nrow(strat_downstr) > 1){


    # if(max(first$UP_CELLS)==max(last$UP_CELLS)){

      if(length(unique(strat_downstr$`nearest river`))==1){

      riv_s <- riv_l[riv_l$ARCID==strat_downstr$`nearest river`[1],]
      points <- st_line_sample(riv_s, n = 200)
      points <- st_cast(points, "POINT")
      points <- st_sf(points)
      points$sample <- 1:200
      points <- st_buffer(points, dist = 100)

      inter <- st_intersection(strat_downstr, points)
      r <- data.frame(id_jrc = unique(inter$id_jrc))
      for(i in 1:nrow(r)){
        r$sample_max[i] <- max(inter$sample[inter$id_jrc== r$id_jrc[i]])
      }
      for(i in 1:(nrow(r))){
        res_max$res_down[res_max$id_jrc==r$id_jrc[i]] <- r$id_jrc[i+1]
        }

    }else{
      strat_downstr$UP_CELLS <- NA
      for(u in 1:nrow(strat_downstr)){
        strat_downstr$UP_CELLS[u] <- riv_l$UP_CELLS[riv_l$ARCID==strat_downstr$`nearest river`[u]]

      }
      first <- strat_downstr[1,]
      last <- strat_downstr[nrow(strat_downstr),]

    if(max(first$UP_CELLS) > max(last$UP_CELLS)){
      strat_downstr <- strat_downstr[nrow(strat_downstr):1,]
    }

    for(s in 1:nrow(strat_downstr)){
        res_max$res_down[res_max$id_jrc == strat_downstr$id_jrc[s]] <- strat_downstr$id_jrc[s+1]
    }}
    }
  }
  res_max$res_down[is.na(res_max$res_down)] <- -1
  strategic <- res_max[res_max$`distance to river`==0,]
  strategic <- strategic[!is.na(strategic$id_jrc),]
  st_write(strategic, dsn = "D:/shapefiles/strategic_res.shp")

  return(res_max)
}
