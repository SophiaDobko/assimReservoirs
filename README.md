# assimReservoirs

The aim of this package is the assimilation of reservoir extents in Ceará, northeast Brazil. 
With the use of meteorological observations, the reservoir extent shall be modeled in order to complement the reservoir extent estimations based on remote sensing [jmigueldelgado/buhayra](https://github.com/jmigueldelgado/buhayra). 

<br>

#### Available funcions:

- ```identBasinsGauges(ID, distGauges)``` identifies the contributing basins of a certain reservoir and the precipitation gauges within a certain buffer around this basin

- ```plotBasins(list_BG)``` plots the identified contributing basins

- ```plotGauges(list_BG, distGauges)``` plots the identified rain gauges within the given distance, which allows to check if an adequate number of rain gauges is included for the interpolation 

- ```requestGauges(requestDate, Ndays, list_BG)``` requests api rain data for the above selected rain gauges

- ```idwRain(list_BG, api)``` interpolates rain data using idw (inverse distance weighted) interpolation

- ```plotIDW(list_BG, list_idw)``` plots the result of ```idwRain```: the interpolated precipitation in the contributing basins

- ```resRouting(list_BG)``` creates a routing scheme for the strategic reservoirs (= reservoirs on the main river course) - for each reservoir the next reservoir downstream is identified

- ```plotStratRes(list_BG, list_routing)``` plots the strategic reservoirs identified by resRouting

<br>

#### Included data:
- ```data(res_max)``` a geospatial dataframe of all 22960 reservoirs identified in Ceará with their ID, maximum extent and geometry, adapted from  Jean-Francois Pekel, Andrew Cottam, Noel Gorelick, Alan S. Belward, High-resolution mapping of global surface water and its long-term changes. Nature 540, 418-422 (2016). (doi:10.1038/nature20584).

- ```data(otto)``` a geospatial dataframe of the level 12 subbasins in  Ceará, classified following the method of Otto Pfafstetter as published by Lehner, B., Verdin, K., Jarvis, A. (2008): New global hydrography derived from spaceborne elevation data. Eos, Transactions, AGU, 89(10): 93-94. Among other variables, HYBAS_ID gives the ID of a subbasin, NEXT_DOWN the ID of the next downstream subbasin, SUB_AREA the area of the specific subbasin and UP_AREA the contributing area in km².

- ```data(riv)``` a geospatial dataframe of the river reaches in Ceará from Lehner, B., Verdin, K., Jarvis, A. (2008): New global hydrography derived from spaceborne elevation data. Eos, Transactions, AGU, 89(10): 93-94. ARCID gives for each river reach an ID and UP_CELLS the number of upstrem catchment cells, with a cell size of 15 arcseconds x 15 arcseconds. 


<br>

#### Outputs:

- ```list_BG``` (from ```identBasinsGauges```) is a list with 6 elements: "res" is the treated reservoir, "catch" is the catchment contributing to this reservoir, "catch_km2" gives the area of the catchment in square kilometers, "catch_buffer" is a shapefile of a buffer zone of the chosen size around the catchment, "gauges_catch" is a point shapefile with the rain gauges within "catch_buffer" and "routing" is logical, indicating if routing can be done (TRUE when the reservoir receives water from upstream subbasins)

- ```api``` (from ```requestGauges```) is a dataframe with the precipitation available for the requested dates and gauges

- ```list_idw``` (from ```idwRain```) is a list with 2 elements: "idwRaster" contains a raster of the interpolated precipitation for each requested day, "dailyRain_table" is a dataframe with the mean precipitation on the catchment and the reservoir of each requested day.

- ```list_routing``` (from ```resRouting```) if no routing is possible "No routing" is printed, otherwise the output is a list with 3 elements: "res_main" is a dataframe of all the reservoirs in the catchment where the area of UP_CELLS > 0.5 * the area of its subbasin, res_down shows the ID of the next downstream reservoir, "reservoirs" is a geospatial dataframe of all the reservoirs in the catchment which are on a river reach of "riv", and "riv_catch" is a geospatial dataframe of all the river reaches in the catchment.

<br>

#### Future functions:

- complement the interpolation of precipitation data from rain gauges with radar data

- water balance to calculate the reservoir extent and compare it to the extent estimated from remote sensing

<br>

#### Example:

```
library(assimReservoirs)

list_BG <- identBasinsGauges(ID = 25283, distGauges = 20)
plotBasins(list_BG)
plotGauges(list_BG, distGauges = 20)

api <- requestGauges(requestDate = today(), Ndays = 5, list_BG)
list_idw <- idwRain(list_BG, api)
plotIDW(list_BG, list_idw)

list_routing <- resRouting(list_BG)
plotStratRes(list_BG, list_routing)
```
<br>
