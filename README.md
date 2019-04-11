# assimReservoirs

The aim of this package is the assimilation of reservoir extents in Ceará, northeast Brazil. 
With a simple model, including meteorological observations and the routing scheme of the reservoirs, errors in the reservoir extent estimations based on remote sensing [jmigueldelgado/buhayra](https://github.com/jmigueldelgado/buhayra) shall be corrected. 

So far, the following functions are implemented:

- ```identBasinsGauges(ID, distGauges)``` identifies the contributing basins of a certain reservoir and the precipitation gauges within a certain buffer around this basin

- ```requestGauges(requestDate, Ndays, list_output)``` requests api rain data for the above selected rain gauges
- ```idwRain(list_output, api)``` interpolates rain data using idw (inverse distance weighted) interpolation

Have a look at the results using the following plot functions:

- ```plotBasins(list_output)``` - plot the identified contributing basins
- ```plotGauges(list_output)``` - plot the identified rain gauges
- ```plotIDW(list_output, list_idw)``` - plot the interpolated precipitation in the contributing basins

Future functions:
- water balance to calculate the reservoir extent and compare it to the extent estimated from remote sensing
- maybe include radar data in the precipitation interpolation
