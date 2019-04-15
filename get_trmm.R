#' list and download trmm data in ftp
#'
#' @export

YEAR = 2019
MONTH = 04
DAY = 12
setwd("D:/DownloadReservoirData/trmm")

get_trmm <- function(){

  list_files <- curl::new_handle()
  ftp_prefix='ftp://'
#  paste('ftp://arthurhou.pps.eosdis.nasa.gov/gpmdata', sprintf("%04d", YEAR), sprintf("%02d",  MONTH), sprintf("%02d", DAY), 'gprof/', hdf_filename,sep='/')
  myurl = paste0('arthurhou.pps.eosdis.nasa.gov/gpmdata/', sprintf("%04d", YEAR), "/", sprintf("%02d",  MONTH), "/", sprintf("%02d", DAY), '/gprof/')
  up = "martinsd@uni-potsdam.de:martinsd@uni-potsdam.de"
  curl::handle_setopt(list_files, userpwd = up,ftp_use_epsv = TRUE, dirlistonly = TRUE)

  con <- curl::curl(url = paste0(ftp_prefix,myurl), "r", handle = list_files)
  files <- readLines(con)
  close(con)

  files3A <- files[grep(pattern = "3A-DAY.", files)]

  for(fname in files3A[1]) {
    curl::curl_download(
      paste0(ftp_prefix,myurl,fname),
      destfile = paste0(getwd(),'/',fname),
      handle = curl::new_handle(userpwd = up)
    )

  }
  return(files3A)
}


# trmm ####
setwd("D:/DownloadReservoirData/trmm")
get_trmm()
save(files3A, file = "files3A.RData")


#' get rain from trmm data
#'
#' obtain precipitation for the past few days
#' @export

trmmRain <- function(){
  library(ncdf4)
  nc=ncdf4::nc_open(files3A[1])

  nc
}

library(raster)
library(sf)

trmmRain()

# print(nc)
attributes(nc)$names
attributes(nc$var)$names
# ncatt_get(nc, attributes(nc$var)$names[4])
# nlon <- dim(lon)
# nlat <- dim(lat)
precip <- ncvar_get(nc, "Grid/surfacePrecipitation")
inputfilenames <- ncvar_get(nc, "InputFileNames")
nprecip <- dim(precip)

c <- st_transform(list_BG$catch, "+proj=latlong  +datum=WGS84 +no_defs")
# change calculation, now its doing the opposite of what it should do... ####
latmin <- floor(as.numeric(ymin(extent(c)))*0.25-90)
latmax <- ceiling(as.numeric(ymax(extent(c)))*0.25-90)
longmin <- floor(as.numeric(xmin(extent(c)))*0.25-180)
longmax <- ceiling(as.numeric(xmax(extent(c)))*0.25-180)

precip <- data.frame(precip)
precip_catch <- precip[latmin:latmax, longmin:longmax]
# precip_catch <-

ceiling(1.5)
floor(1.5)

day_month <- ncvar_get(nc,"ScanTime/DayOfMonth",start=1)
second <- ncvar_get(nc, "ScanTime/Second")
minute <- ncvar_get(nc, "ScanTime/Minute")
hour <- ncvar_get(nc, "ScanTime/Hour")
day_year <- ncvar_get(nc,"ScanTime/DayOfYear")
day_year1 <- ncvar_get(nc, attributes(nc$var)$names[12])
day_year2 <- ncvar_get(nc, attributes(nc$var)$names[23])

ncvar_get(nc,"ScanTime/Hour")
fillvalue <- ncatt_get(nc, "NS/surfPrecipTotRate", "_FillValue")
precip[precip == fillvalue$value] <- NA

r <- raster(t(precip), xmn = min(lon), xmx = max(lon), ymn = min(lat), crs = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
plot(r)

# do zonal statistics similary to idwRain
dailyRain <- data.frame()
for(i in 1:length(dates)){

res <- as(list_output$res$geometry, "Spatial")
daily <- data.frame("date" = dates[i], "catch_mean" = mean(unlist(extract(r, c))), "reservoir_mean" = mean(unlist(extract(r, res))))
dailyRain <- rbind(dailyRain, daily)
}
return(list_idw <- list("idwRaster" = idwRaster, "dailyRain_table" = dailyRain))

