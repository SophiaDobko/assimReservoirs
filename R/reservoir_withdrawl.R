#' Water withdrawl from reservoirs
#'
#' Calculate water withdrawl from the reservoirs, 1% of maximum volume per day, to include in ```reservoir_model```
#' @export

reservoir_withdrawl <- function(){
  print(paste(Sys.time(), "Estimate withdrawl for", dates[d]))

  res_mod$withdrawl <- NA
  for(w in 1:nrow(res_mod)){
    if(!is.na(res_mod$vol_1[w])){
      if(res_mod$vol_1[w] > (0.01*res_mod$vol_max[w])){
        res_mod$withdrawl[w] <- 0.01*res_mod$vol_max[w]
      }else{
        res_mod$withdrawl[w] <- res_mod$vol_1[w]
      }
    }
  }

  return(res_mod)
}
