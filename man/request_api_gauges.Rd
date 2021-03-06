% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/request_api_gauges.R
\name{request_api_gauges}
\alias{request_api_gauges}
\title{Request rain data from FUNCEME api}
\usage{
request_api_gauges(requestDate = as.Date("2018-03-15"), Ndays = 5,
  gauges_catch)
}
\arguments{
\item{requestDate}{latest date of interest, e.g. today(), default is as.Date("2018-03-15")}

\item{Ndays}{number of days to go back in time from requestDate, default = 5}

\item{gauges_catch}{output of \code{rain_gauges_catch}}
}
\value{
a dataframe with the precipitation available for the requested dates and gauges
}
\description{
This function requests api rain data for selected rain gauges
}
