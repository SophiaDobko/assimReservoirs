require(rmarkdown)
#require(bookdown)

setwd('/home/delgado/proj/assimReservoirs')

render("./vignettes/topology_reservoir_network.Rmd","slidy")
