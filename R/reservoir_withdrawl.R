#' Water withdrawl from reservoirs
#'
#' Calculate water withdrawl from the reservoirs, 1% of maximum volume per day, to include in ```reservoir_model```
#' @export

reservoir_withdrawl <- function(){
  res_mod$withdrawl <- NA
  for(w in 1:nrow(res_mod)){
    if(res_mod$vol_1[w] > (0.01*res_mod$vol_max[w])){
      res_mod$withdrawl[w] <- 0.01*res_mod$vol_max[w]
    }else{
      res_mod$withdrawl[w] <- res_mod$vol_1[w]
    }
  }
   # res_mod$withdrawl[res_mod$vol_1 > (0.01*res_mod$vol_max)] <- 0.01*res_mod$vol_max[res_mod$vol_1>(0.01*res_mod$vol_max)]
   # res_mod$withdrawl[res_mod$vol_1 <= (0.01*res_mod$vol_max)] <- res_mod$vol_1[res_mod$vol_1<=(0.01*res_mod$vol_max)]
  return(res_mod)
}
