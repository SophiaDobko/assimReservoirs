
#' Obtain graph nodes from HydroSheds river network
#'
#' Extract the nodes of the HydroSheds river network.
#' @param riv a sf dataframe with a topologicaly valid river network. Each linestrings is ordered from upstream (first point of the linestring) to downstream (last point of the linestring), just like in the HydroSheds dataset
#' @return nodes a sf dataframe of points marking the nodes of the river network defined as the inlet of each river reach.
#' @importFrom sf st_geometry_type st_line_sample st_linestring st_cast
#' @importFrom dplyr filter
#' @importFrom magrittr %>% %<>%
#' @export
riv2nodes <- function(riv){

  nodes=riv
  for(i in seq(1,nrow(nodes)))
  {
    if(st_geometry_type(riv[i,])=='LINESTRING')
    {
      nodes$geometry[i]=st_line_sample(riv[i,],sample=0)
    }
    else
    {
      nodes$geometry[i]=st_linestring()
    }
  }

  valid=st_geometry_type(nodes)=='MULTIPOINT'

  nodes %<>%
    filter(valid) %>%
    st_cast(., "POINT", group_or_split = FALSE)

  return(nodes)
}


#' Split river network into disjoint graphs
#' @param riv a sf dataframe with a topologicaly valid river network. Use for example the HydroSheds dataset.
#' @return riv_i a sf dataframe with a topologicaly valid river network with a membership label for each disjoint graph.
#' @importFrom sf st_touches
#' @importFrom igraph graph.adjlist components
#' @importFrom dplyr mutate
#' @importFrom magrittr %>%
#' @export
split_river_network <- function(riv){
  touching_list=st_touches(riv)

  g = graph.adjlist(touching_list)
  c = components(g)

  riv_i=mutate(riv,membership=as.factor(c$membership)) %>%
    arrange()
  return(riv_i)
}

#' Calculate graph object based on river network
#' @param nodes_i a sf dataframe of points marking the nodes of the river network defined as the inlet of each river reach. This must be only one tree. It won't work with a forest.
#' @param riv_i a sf dataframe with a topologicaly valid river network. This must be only one tree. It won't work with a forest.
#' @return g a igraph object
#' @importFrom sf st_touches
#' @importFrom igraph graph.adjlist components
#' @export
riv2graph <- function(nodes_i,riv_i){
  touch=st_touches(nodes_i,riv_i)
  for(i in seq(1,length(touch))){
    touch[[i]]=setdiff(touch[[i]],i)
  }
  g=graph.adjlist(touch, mode='in')
  return(g)
}
