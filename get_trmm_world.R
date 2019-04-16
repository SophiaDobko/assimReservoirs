#' List and download trmm data in ftp
#'
#' @param
#' @return
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

  for(fname in filesworld[1:length(filesworld)]) {
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
#' @param list_BG output of identBasinsGauges
#' @param files_world output of get_trmm_world
#' @return a list with 3 elements:
#' - ```sub_means``` is a geospatial dataframe with the mean TRMM precipitation for each subbasin
#' - ```catch_mean``` is the mean precipitation for the whole catchment
#' - ```reservoir_mean``` is the precipitation on the reservoir
#' @export

trmmRain <- function(list_BG, files_world){

  library(ncdf4)
  library(raster)
  library(sf)

  nc_rasters <- list()
  for(f in 1:length(files_world)){

    nc=ncdf4::nc_open(files_world[f])
    precip <- ncvar_get(nc, "Grid/surfacePrecipitation")

    c <- st_transform(list_BG$catch, "+proj=latlong  +datum=WGS84 +no_defs")
    latmin <- floor((as.numeric(ymin(extent(c)))+90)/0.25+1)
    latmax <- ceiling((as.numeric(ymax(extent(c)))+90)/0.25+1)
    longmin <- floor((as.numeric(xmin(extent(c)))+180)/0.25+1)
    longmax <- ceiling((as.numeric(xmax(extent(c)))+180)/0.25+1)

    precip <- data.frame(precip)
    precip_catch <- precip[latmin:latmax, longmin:longmax]
    lat <- seq((((latmin-1)*0.25)-90),(((latmax-1)*0.25)-90), by = 0.25)
    lon <- seq((((longmin-1)*0.25)-180),(((longmax-1)*0.25)-180), by = 0.25)

    r <- raster(t(precip_catch), xmn = min(lon), xmx = max(lon), ymn = min(lat), ymx = max(lat), crs = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))
    nc_rasters[[f]] <- r
  }

# calculate mean of all rasters
  nc_mean <- do.call("mean", nc_rasters)

# calculate mean of each subbasin
  for(s in 1:nrow(c)){
    c$trmm_mean[s] <- mean(unlist(extract(r,c[s,])))
  }

  res <- st_transform(list_BG$res, "+proj=latlong  +datum=WGS84 +no_defs")

  return(list_trmm <- list("sub_means" = c[,c(1,15)], "catch_mean" = mean(unlist(extract(nc_mean, c))), "reservoir_mean" = mean(unlist(extract(nc_mean, res)))))
}
