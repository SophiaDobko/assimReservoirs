#' List and download trmm data in ftp
#'
#' @param YEAR year
#' @param MONTH month
#' @param DAY and day to be downloaded
#' @return files_world, contains the names of the available trmm files
#' @export

get_trmm_world <- function(YEAR, MONTH, DAY){

  list_files <- curl::new_handle()
  ftp_prefix='ftp://'
  myurl = paste0('arthurhou.pps.eosdis.nasa.gov/gpmdata/', sprintf("%04d", YEAR), "/", sprintf("%02d",  MONTH), "/", sprintf("%02d", DAY), '/gprof/')
  up = "martinsd@uni-potsdam.de:martinsd@uni-potsdam.de"
  curl::handle_setopt(list_files, userpwd = up,ftp_use_epsv = TRUE, dirlistonly = TRUE)

  con <- curl::curl(url = paste0(ftp_prefix,myurl), "r", handle = list_files)
  files <- readLines(con)
  close(con)

  files_world <- files[grep(pattern = "3A-DAY.", files)]

  for(fname in files_world[1:length(files_world)]) {
    curl::curl_download(
      paste0(ftp_prefix,myurl,fname),
      destfile = paste0(getwd(),'/',fname),
      handle = curl::new_handle(userpwd = up)
    )

  }
  return(files_world)
}


#' Get rain from trmm data
#'
#' obtain precipitation on the reservoir and the mean of its catchment and each subbasin
#' @param shape sf geometric object in WGS 84, longlat
#' @param files_world output of get_trmm_world
#' @return ```trmm_means``` is a geospatial dataframe with the mean TRMM precipitation for each field of the input shape
#' @export

trmmRain <- function(shape, files_world){

  library(ncdf4)
  library(raster)
  library(sf)

  nc_rasters <- list()
  for(f in 1:length(files_world)){

    nc = ncdf4::nc_open(files_world[f])
    precip <- ncvar_get(nc, "Grid/surfacePrecipitation")

    latmin <- floor((as.numeric(ymin(extent(shape)))+90)/0.25+1)
    latmax <- ceiling((as.numeric(ymax(extent(shape)))+90)/0.25+1)
    longmin <- floor((as.numeric(xmin(extent(shape)))+180)/0.25+1)
    longmax <- ceiling((as.numeric(xmax(extent(shape)))+180)/0.25+1)

    precip <- data.frame(precip)
    precip_shape <- precip[latmin:latmax, longmin:longmax]
    lat <- seq((((latmin-1)*0.25)-90),(((latmax-1)*0.25)-90), by = 0.25)
    lon <- seq((((longmin-1)*0.25)-180),(((longmax-1)*0.25)-180), by = 0.25)

    r <- raster(t(precip_shape), xmn = min(lon), xmx = max(lon), ymn = min(lat), ymx = max(lat), crs = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))
    nc_rasters[[f]] <- r
  }

# calculate mean of all rasters
  nc_mean <- do.call("mean", nc_rasters)

# calculate mean of each subbasin
  for(s in 1:nrow(shape)){
    shape$trmm_mean[s] <- mean(unlist(extract(r,shape[s,])))
  }

  return(trmm_means = shape)
}
