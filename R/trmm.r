#' get trmm data
#'
#' obtain precipitation for the past few days
#' @export
trmmRain <- function(){
  nc=ncdf4::nc_open('2B-SP-47W0S33W10S.GPM.DPRGMI.CORRA2018.20190408-S022304-E022610.029020.V06A.HDF5')

  nc
}

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
