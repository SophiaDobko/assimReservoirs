# assimReservoirs

The aim of this package is the assimilation of reservoir extents in Ceará, northeast Brazil. 
With the use of meteorological observations, the reservoir extent shall be modeled in order to complement the reservoir extent estimations based on remote sensing [jmigueldelgado/buhayra](https://github.com/jmigueldelgado/buhayra). 


## Examples

```
library(assimReservoirs)

# Data preprocessing ####

# Create river graph


# Routing of strategic and non-strategic reservoirs
res_max <- Routing()
res_max <- Routing_non_strat()

# Estimate runoff contributing areas for all reservoirs
res_max <- runoff_contributing()

# Download and interpolate rain data for a specific catchment ####

list_BG <- identBasinsGauges(ID = 25283, distGauges = 20)
list_BG <- identBasinsGauges_shape(shape = subset(res_max, id_jrc==49301), distGauges = 20)
plotBasins(list_BG)
plotGauges(list_BG, distGauges = 20)

api <- requestGauges(requestDate = today(), Ndays = 5, list_BG)
list_idw <- idwRain(list_BG, api)
plotIDW(list_BG, list_idw)

files_world <- get_trmm_world(YEAR = 2019, MONTH = 04, DAY = 12)
trmm_means <- trmmRain(shape = st_transform(list_BG$catch, "+proj=latlong  +datum=WGS84 +no_defs"), files_world)
plotTRMM(trmm_means)

# Simple model
res_model <- res_model2(ID = 31440, start = as.Date("2004-01-24"), end = as.Date("2004-01-30"))
```

## Available funcions

### Data preprocessing

- ```res_max <- Routing()```
- ```res_max <- Routing_non_strat()```

- ```res_max <- runoff_contributing()```

### Download and interpolate rain data for a specific catchment

- ```identBasinsGauges(ID, distGauges)``` identifies the contributing basins of a certain reservoir and the rain gauges within a certain buffer around this basin

- ```identBasinsGauges_shape(shape, distGauges)``` allows to identify contributing basins and rain gauges for any shapefile

- ```plotBasins(list_BG)``` plots the identified contributing basins

- ```plotGauges(list_BG, distGauges)``` plots the identified rain gauges within the given distance, which allows to check if an adequate number of rain gauges is included for the interpolation 

- ```requestGauges(requestDate, Ndays, list_BG)``` requests api rain data for the above selected rain gauges

- ```idwRain(list_BG, api)``` interpolates rain data using idw (inverse distance weighted) interpolation

- ```get_trmm_world``` lists and downloads TRMM data in ftp from the Tropical Rainfall Measuring Mission (https://trmm.gsfc.nasa.gov/)

- ```trmmRain``` extracts rain from TRMM data

- ```plotTRMM``` plots the mean TRMM precipitation of the contributing subbasins

- ```plotIDW(list_BG, list_idw)``` plots the result of ```idwRain```: the interpolated precipitation in the contributing basins

## Run a simple model of water volume of the reservoirs and flow through the reservoir network
- ```res_model2(ID = 31440, start = as.Date("2004-01-24"), end = as.Date("2004-01-30"))```



## Included data
- ```data(res_max)``` a geospatial dataframe of all 22960 reservoirs identified in Ceará with their ID, maximum extent and geometry, adapted from  Jean-Francois Pekel, Andrew Cottam, Noel Gorelick, Alan S. Belward, High-resolution mapping of global surface water and its long-term changes. Nature 540, 418-422 (2016). (doi:10.1038/nature20584).

- ```data(otto)``` a geospatial dataframe of the level 12 subbasins in  Ceará, classified following the method of Otto Pfafstetter as published by Lehner, B., Verdin, K., Jarvis, A. (2008): New global hydrography derived from spaceborne elevation data. Eos, Transactions, AGU, 89(10): 93-94. Among other variables, HYBAS_ID gives the ID of a subbasin, NEXT_DOWN the ID of the next downstream subbasin, SUB_AREA the area of the specific subbasin and UP_AREA the contributing area in km².

- ```data(riv)``` a geospatial dataframe of the river reaches in Ceará from Lehner, B., Verdin, K., Jarvis, A. (2008): New global hydrography derived from spaceborne elevation data. Eos, Transactions, AGU, 89(10): 93-94. ARCID gives for each river reach an ID and UP_CELLS the number of upstrem catchment cells, with a cell size of 15 arcseconds x 15 arcseconds. 


## Outputs

```list_BG``` <br>
output of ```identBasinsGauges```, a list with 6 elements:

- ```res``` is the treated reservoir (or shapefile), 
- ```catch``` is the catchment contributing to this reservoir (or shapefile), 
- ```catch_km2``` gives the area of the catchment in square kilometers,
- ```catch_buffer``` is a shapefile of a buffer zone of the chosen size around the catchment, 
- ```gauges_catch``` is a point shapefile with the rain gauges within ```catch_buffer``` and 
- ```routing``` is logical, indicating if routing can be done (TRUE when the reservoir receives water from upstream subbasins)

```api``` <br>
output of ```requestGauges```, a dataframe with the precipitation available for the requested dates and gauges

```list_idw``` <br>
output of ```idwRain```, a list with 2 elements:

- ```idwRaster``` contains a raster of the interpolated precipitation for each requested day, 
- ```dailyRain_table``` is a dataframe with the mean precipitation on the catchment and the reservoir of each requested day.

```files_world```<br>
output of ```get_trmm_world```, contains the names of the available trmm files

```trmm_means``` <br>
output of ```trmmRain```, a geospatial dataframe with the mean TRMM precipitation for each subbasin

```res_model```<br>


## Future functions:

- water balance to calculate the reservoir extent and compare it to the extent estimated from remote sensing

