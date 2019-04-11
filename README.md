# assimReservoirs

The aim of this package is the assimilation of reservoir extents in Ceará, northeast Brazil. 
With the use of meteorological observations, the reservoir extent shall be modeled in order to complement the reservoir extent estimations based on remote sensing [jmigueldelgado/buhayra](https://github.com/jmigueldelgado/buhayra). 

<br>

#### Available funcions:

- ```identBasinsGauges(ID, distGauges)``` identifies the contributing basins of a certain reservoir and the precipitation gauges within a certain buffer around this basin

- ```plotBasins(list_output)``` plots the identified contributing basins

- ```plotGauges(list_output, distGauges)``` plots the identified rain gauges within the given distance, which allows to check if an adequate number of rain gauges is included for the interpolation 

- ```requestGauges(requestDate, Ndays, list_output)``` requests api rain data for the above selected rain gauges

- ```idwRain(list_output, api)``` interpolates rain data using idw (inverse distance weighted) interpolation

- ```plotIDW(list_output, list_idw)``` plots the result of ```idwRain```: the interpolated precipitation in the contributing basins

- ```resRouting(list_output)``` creates a routing scheme for the strategic reservoirs (= reservoirs on the main river course) - for each reservoir the next reservoir downstream is identified

- ```plotStratRes(list_output, list_routing)``` plots the strategic reservoirs identified by resRouting


<br>

#### Future functions:

- include radar data and combine it with the data from the rain gauges for more reliable precipitation data

- water balance to calculate the reservoir extent and compare it to the extent estimated from remote sensing

<br>

#### Example:

```
library(assimReservoirs)

list_output <- identBasinsGauges(ID = 25283, distGauges = 20)
plotBasins(list_output)
plotGauges(list_output, distGauges = 20)

api <- requestGauges(requestDate = today(), Ndays = 5, list_output)
list_idw <- idwRain(list_output, api)
plotIDW(list_output, list_idw)

list_routing <- resRouting(list_output)
plotStratRes(list_output, list_routing)
```
<br>
