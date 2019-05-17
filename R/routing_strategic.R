#' Reservoir routing of strategic reservoirs ####
#'
#' This function identifies which strategic reservoir drains into which stategic downstream reservoir
#' @return the column ```res_down``` in the geospatial dataframe ```res_max```
#' @importFrom sf st_line_sample st_cast st_sf st_buffer st_intersection st_write
#' @importFrom igraph all_simple_paths degree
#' @importFrom dplyr %>%
#' @export

# library(assimReservoirs)

Routing <- function(){
  res_max$res_down <- NA
  strategic <- res_max[res_max$`distance to river`==0,]


# for-loop through leaves ####
  g <- river_graph
  leaves = which(degree(g, v = V(g), mode = "in")==0)

  for(l in 1:length(leaves)){

    if(l %in% c(500,1000,1500)){print(paste(Sys.time(),l, "leaves done"))}

    riv_downstr <- all_simple_paths(g,from=leaves[l],mode='out') %>%
    unlist %>% unique
    riv_l <- riv[riv_downstr,]
    strat_downstr <- subset(strategic, `nearest river` %in% riv_l$ARCID)

    if(nrow(strat_downstr) > 1){
      first <- strat_downstr[1,]
      last <- strat_downstr[nrow(strat_downstr),]

      if(max(first$UP_CELLS) > max(last$UP_CELLS)){
        strat_downstr <- strat_downstr[nrow(strat_downstr):1,]
        }

      for(s in 1:nrow(strat_downstr)){
          res_max$res_down[res_max$id_jrc == strat_downstr$id_jrc[s]] <- strat_downstr$id_jrc[s+1]
      }
    }
  }

# for-loop through river reaches with multiple reservoirs ####
  print(paste(Sys.time(), "start correcting order where multiple reservoirs on one river reach"))
  dup <- strategic[which(duplicated(strategic$`nearest river`)),]
  multiple_res <- strategic[strategic$`nearest river` %in% dup$`nearest river`,]

  for(d in 1:length(unique(dup$`nearest river`))){
    riv_l <- riv[riv$ARCID==dup$`nearest river`[d],]
    strat_downstr <- subset(strategic, `nearest river` == riv_l$ARCID)

    points <- st_line_sample(riv_l, n = 200)
    points <- st_cast(points, "POINT")
    points <- st_sf(points)
    points$sample <- 1:200
    points <- st_buffer(points, dist = 100)

    inter <- st_intersection(strat_downstr, points)
    r <- data.frame(id_jrc = unique(inter$id_jrc))

    for(i in 1:nrow(r)){
      r$sample_max[i] <- max(inter$sample[inter$id_jrc== r$id_jrc[i]])
    }
# correct res_down in res_max for this river reach
    res_max$res_down[res_max$id_jrc==r$id_jrc[nrow(r)]] <- strat_downstr$res_down[!(strat_downstr$res_down %in% strat_downstr$id_jrc)]
    res_max$res_down[res_max$res_down %in% strat_downstr$id_jrc] <- r$id_jrc[1]

    for(i in 1:(nrow(r)-1)){
      res_max$res_down[res_max$id_jrc==r$id_jrc[i]] <- r$id_jrc[i+1]
    }
  }

  res_max$res_down[is.na(res_max$res_down)] <- -1
  strategic <- res_max[res_max$`distance to river`==0,]
  strategic <- strategic[!is.na(strategic$id_jrc),]
  st_write(strategic, dsn = "D:/shapefiles/strategic_res.shp")

  return(res_max)
  print(paste(Sys.time(), "finished!"))
}

# res_max <- Routing()
# save(res_max, file = "D:/assimReservoirs/data/res_max.RData")


