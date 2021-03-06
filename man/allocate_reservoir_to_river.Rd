% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/topology.r
\name{allocate_reservoir_to_river}
\alias{allocate_reservoir_to_river}
\title{Allocate each reservoir to nearest river reach within a given subbasin}
\usage{
allocate_reservoir_to_river(riv_i)
}
\arguments{
\item{riv_i}{a subset of river reaches from \code{data(riv)}}
}
\value{
res_max_subset subset of the reservoir data frame with the respective attributed river reach and distance to river reach
}
\description{
Allocate each reservoir to nearest river reach within a given subbasin
}
