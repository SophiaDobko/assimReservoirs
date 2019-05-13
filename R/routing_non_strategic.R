#' Reservoir routing of non-strategic reservoirs ####
#'
#' This function identifies which non-strategic reservoir drains into which stategic downstream reservoir
#' @return completes the column ```res_down``` in the geospatial dataframe ```res_max```
#' @import sf
#' @import igraph
#' @import dplyr
#' @export

# library(assimReservoirs)

Routing_non_strat <- function(){
  strategic <- res_max[res_max$`distance to river`==0,]
  non_strat <- res_max[res_max$`distance to river`>0,]
  g <- river_graph

  for(n in 1:nrow(non_strat)){
    strat_downstr <- strategic[strategic$`nearest river` %in% non_strat$`nearest river`[n],]

    if(nrow(strat_downstr)==0){

      riv_downstr <- all_simple_paths(g,from=rownames(riv[riv$ARCID==strategic$`nearest river`[n],]),mode='out') %>%
        unlist %>% unique
        riv_l <- riv[riv_downstr,]
        strat_downstr <- subset(strategic, `nearest river` %in% riv_l$ARCID)
        # take only strategic reservoirs from the nearest river reach!?!

    }

    strat <- subset(strat_downstr, st_distance(strat_downstr, non_strat) == min(st_distance(strat_downstr, non_strat)))

    m <- ceiling((1+nrow(strat_downstr))/2)
    res_max$res_down[res_max$id_jrc==non_strat$id_jrc[n]] <- strat_downstr$id_jrc[m]

  }
  return(res_max)
}


res_max <- Routing_non_strat()
save(res_max, file = "D:/assimReservoirs/data/res_max.RData")


