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

  for(fname in files3A[2]) {
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
  nc=ncdf4::nc_open(files3A[2])

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
# inputfilenames <- ncvar_get(nc, "InputFileNames")
nprecip <- dim(precip)

c <- st_transform(list_BG$catch, "+proj=latlong  +datum=WGS84 +no_defs")
# change calculation, now its doing the opposite of what it should do... ####
latmin <- floor((as.numeric(ymin(extent(c)))+90)/0.25+1)
latmax <- ceiling((as.numeric(ymax(extent(c)))+90)/0.25+1)
longmin <- floor((as.numeric(xmin(extent(c)))+180)/0.25+1)
longmax <- ceiling((as.numeric(xmax(extent(c)))+180)/0.25+1)

precip <- data.frame(precip)
precip_catch <- precip[latmin:latmax, longmin:longmax]
lat <- seq((((latmin-1)*0.25)-90),(((latmax-1)*0.25)-90), by = 0.25)
lon <- seq((((longmin-1)*0.25)-180),(((longmax-1)*0.25)-180), by = 0.25)


r <- raster(t(precip), xmn = min(lon), xmx = max(lon), ymn = min(lat), ymx = max(lat), crs = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))
plot(r)

# do zonal statistics similary to idwRain
# dailyRain <- data.frame()
# for(i in 1:length(dates)){

res <- as(list_BG$res$geometry, "Spatial")
# daily <- data.frame("date" = dates[i], "catch_mean" = mean(unlist(extract(r, c))), "reservoir_mean" = mean(unlist(extract(r, res))))
daily <- data.frame("catch_mean" = mean(unlist(extract(r, c))), "reservoir_mean" = mean(unlist(extract(r, res))))
# dailyRain <- rbind(dailyRain, daily)
}
return(list_idw <- list("idwRaster" = idwRaster, "dailyRain_table" = dailyRain))

