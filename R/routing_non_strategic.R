#' Reservoir routing of non-strategic reservoirs ####
#'
#' This function identifies which non-strategic reservoir drains into which stategic downstream reservoir
#' @return completes the column ```res_down``` in the geospatial dataframe ```res_max```
#' @importFrom sf st_distance
#' @importFrom igraph all_simple_paths
#' @importFrom dplyr %>%
#' @export

# library(assimReservoirs)

Routing_non_strat <- function(){
  strategic <- res_max[res_max$`distance to river`==0,]
  non_strat <- res_max[res_max$`distance to river`>0,]
  g <- river_graph

  for(n in 15088:nrow(non_strat)){

    if(n %in% c(2500,5000,7500,10000,12500,15000,16000,17500,20000)){
      print(paste(Sys.time(),n, "reservoirs done"))}

    strat_downstr <- strategic[strategic$`nearest river` %in% non_strat$`nearest river`[n],]

    if(nrow(strat_downstr)==0){

      riv_downstr <- all_simple_paths(g,from=rownames(riv[riv$ARCID==non_strat$`nearest river`[n],]),mode='out') %>%
        unlist %>% unique
      riv_l <- riv[riv_downstr,]
      strat_downstr <- subset(strategic, `nearest river` %in% riv_l$ARCID)
    }

    if(nrow(strat_downstr)>1){
      strat_downstr <- strat_downstr[st_distance(strat_downstr, non_strat[n,]) == min(st_distance(strat_downstr, non_strat[n,])),]
    }

    if(nrow(strat_downstr)==1){
      res_max$res_down[res_max$id_jrc==non_strat$id_jrc[n]] <- strat_downstr$id_jrc
    }else{
      res_max$res_down[res_max$id_jrc==non_strat$id_jrc[n]] <- NA
    }
  }

  return(res_max)
}


# res_max$res_down[is.na(res_max$res_down)] <- -1
# res_max <- Routing_non_strat()
# save(res_max_routing, file = "D:/assimReservoirs/data/res_max_routing.RData")
# non_strat <- res_max_non_strat[res_max$`distance to river`>0,]




