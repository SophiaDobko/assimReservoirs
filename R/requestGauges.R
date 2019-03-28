#' Request rain data from FUNCEME api
#'
#' This function requests api rain data for selected rain gauges
#' @param requestDate latest date of interest, e.g. as.Date("2018-03-15") or today()
#' @param Ndays number of days to go back in time from requestDate
#' @param list_output output of identBasinsGauges
#' @export

requestGauges <- function(requestDate, Ndays, list_output) {

  library(lubridate)
  library(dplyr)
  library(sf)
  library(jsonlite)

  gauges_catch <- list_output[["gauges_catch"]]
  api <- data.frame()
  for(c in 1:nrow(gauges_catch)){
    codigo = gauges_catch$codigo[c]

    rain_list <- list()
    for(i in seq(0, Ndays-1)){
      request=paste0('http://api.funceme.br/rest/pluvio/pluviometria-funceme-normalizada?codigo=',
                     codigo,
                     '&data.date=',
                     format(requestDate-i, tz="America/Fortaleza", format="%Y-%m-%d"))
      resp=fromJSON(request)
      value=resp$list$valor

      if(is.null(value)) {
        warning(paste0("No values for codigo ",codigo," recorded after requested date ",requestDate))
        value=NA
      }
      dt=strptime(resp$list$data$date,format="%Y-%m-%d %H:%M:%S",tz="America/Fortaleza")
      if(length(dt)==0) {
        dt=NA
      }
      rainOut=data.frame(returnedDate=as.Date(dt),requestDate=requestDate,value=value,codigo=codigo)

      rain_list[[i+1]] <- rainOut
    }
    rain <- bind_rows(rain_list)
    api <- rbind(api, rain)
  }
return(api)
}

