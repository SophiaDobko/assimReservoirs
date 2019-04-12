#' list and download trmm data in ftp
#'
#' @export

get_trmm <- function(){

  list_files <- curl::new_handle()
  ftp_prefix='ftp://'
  myurl = "arthurhou.pps.eosdis.nasa.gov/gpmuser/martinsd@uni-potsdam.de/pgs/"
  up = "martinsd@uni-potsdam.de:martinsd@uni-potsdam.de"
  curl::handle_setopt(list_files, userpwd = up,ftp_use_epsv = TRUE, dirlistonly = TRUE)

  con <- curl::curl(url = paste0(ftp_prefix,myurl), "r", handle = list_files)
  files <- readLines(con)
  close(con)


  for(fname in files) {
    curl::curl_download(
      paste0(ftp_prefix,myurl,fname),
      destfile = paste0(getwd(),'/',fname),
      handle = curl::new_handle(userpwd = up)
    )

  }
  return(files)
}

# trmm ####
setwd("D:/DownloadReservoirData/trmm")
get_trmm()


#' get rain from trmm data
#'
#' obtain precipitation for the past few days
#' @export
trmmRain <- function(){
  library(ncdf4)
  nc=ncdf4::nc_open('2B-SP-47W0S33W10S.GPM.DPRGMI.CORRA2018.20190408-S022304-E022610.029020.V06A.HDF5')

  nc
}

library(raster)

trmmRain()

# print(nc)
# attributes(nc)$names
# attributes(nc$var)$names
# ncatt_get(nc, attributes(nc$var)$names[4])
# nlon <- dim(lon)
# nlat <- dim(lat)
# nprecip <- dim(precip)

lon <- ncvar_get(nc, "NS/Longitude")
lat <- ncvar_get(nc, "NS/Latitude")
precip <- ncvar_get(nc, "NS/surfPrecipTotRate")

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
