# routing

resRouting <- function(list_output){

  if(list_output$routing == F){
  print("no routing ")
    }else{
      print("routing in process...")

      riv_catch <- st_intersection(riv, catch)
      res_riv_catch <- st_intersection(res_max, riv_catch)


plot(catch$geometry, col = "white")
plot(riv_catch$geometry, add = T, col = "red")


}
}
