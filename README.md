# assimReservoirs

The aim of this package is the assimilation of reservoir extents in Ceará, northeast Brazil. 
With the use of meteorological observations, the reservoir extent shall be modeled in order to complement the reservoir extent estimations based on remote sensing [jmigueldelgado/buhayra](https://github.com/jmigueldelgado/buhayra). 


## Examples

```
library(assimReservoirs)

# Data preprocessing ####

# Routing of strategic and non-strategic reservoirs
res_max <- Routing()
res_max <- Routing_non_strat()

# Estimate runoff contributing areas for all reservoirs
res_max <- runoff_contributing_area()

# Download and interpolate rain data for a specific catchment ####

catch <- contributing_basins_res()
catch <- contributing_basins_shape()
plot_contributing_basins(catch, shape = res_max[res_max$id_jrc == 25283,])

gauges_catch <- ident_rain_gauges(catch)
plot_gauges_catch(catch, gauges_catch)

api <- request_api_gauges(requestDate = as.Date("2018-03-15") , Ndays = 5, gauges_catch)
list_idw <- idwRain(catch, gauges_catch, api, distGauges = 30, ID)
plotIDW(list_idw)

files_world <- get_trmm_world(YEAR = 2019, MONTH = 04, DAY = 12)
trmm_means <- trmmRain(shape = st_transform(list_BG$catch, "+proj=latlong  +datum=WGS84 +no_defs"), files_world)
plotTRMM(trmm_means)

# Simple model
res_model <- res_model2(ID = 31440, start = as.Date("2004-01-24"), end = as.Date("2004-01-30"))
```

## Available funcions

### Data preprocessing

- ```res_max <- Routing()``` identifies which strategic reservoir drains into which stategic downstream reservoir

- ```res_max <- Routing_non_strat()``` identifies which non-strategic reservoir drains into which stategic downstream reservoir

- ```res_max <- runoff_contributing_area()``` estimates the area of directly contributing runoff for all reservoirs, based on the mean yearly runoff of 1960-1990. The columns ```runoff_contr_est``` and ```runoff_contr_adapt``` are added to the geospatial dataframe ```res_max```, ```runoff_contr_adapt``` adapts the estimated (theoretic) runoff contributing area to the actual subbasin area.

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

### Run a simple model of water volume of the reservoirs and flow through the reservoir network
- ```reservoir_model(ID = 31440, start = as.Date("2004-01-24"), end = as.Date("2004-01-30"))```



## Included data
- ```data(res_max)``` a geospatial dataframe of all 22960 reservoirs identified in Ceará with their ID, maximum extent and geometry, adapted from  Jean-Francois Pekel, Andrew Cottam, Noel Gorelick, Alan S. Belward, High-resolution mapping of global surface water and its long-term changes. Nature 540, 418-422 (2016). (doi:10.1038/nature20584).

- ```data(otto)``` a geospatial dataframe of the level 12 subbasins in  Ceará, classified following the method of Otto Pfafstetter as published by Lehner, B., Verdin, K., Jarvis, A. (2008): New global hydrography derived from spaceborne elevation data. Eos, Transactions, AGU, 89(10): 93-94. Among other variables, HYBAS_ID gives the ID of a subbasin, NEXT_DOWN the ID of the next downstream subbasin, SUB_AREA the area of the specific subbasin and UP_AREA the contributing area in km².

- ```data(riv)``` a geospatial dataframe of the river reaches in Ceará from Lehner, B., Verdin, K., Jarvis, A. (2008): New global hydrography derived from spaceborne elevation data. Eos, Transactions, AGU, 89(10): 93-94. ARCID gives for each river reach an ID and UP_CELLS the number of upstrem catchment cells, with a cell size of 15 arcseconds x 15 arcseconds. 


## Outputs

- ```catch``` output of contributing_basins_shape or contributing_basins_res, the catchment contributing to a reservoir or sf object 

- ```gauges_catch``` output of ```rain_gauges_catch```, a geospatial dataframe with the rain gauges within ```catch_buffer``` 

```api``` output of ```request_api_gauges```, a dataframe with the precipitation available for the requested dates and gauges

```list_idw``` <br>
output of ```idwRain```, a list with 2 elements:

- ```idwRaster``` contains a raster of the interpolated precipitation for each requested day, 
- ```dailyRain_table``` is a dataframe with the mean precipitation on the catchment and the reservoir of each requested day.

- ```files_world``` output of ```get_trmm_world```, contains the names of the available trmm files

```trmm_means``` output of ```trmmRain```, a geospatial dataframe with the mean TRMM precipitation for each subbasin

```reservoir_model``` a dataframe showing for each timestep reservoir volumes at the beginning (vol_0) and end (vol_1),  inflow (Qin_m3) and outflow (Qout_m3)


## Future functions:

- water balance to calculate the reservoir extent and compare it to the extent estimated from remote sensing

