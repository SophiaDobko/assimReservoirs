# routing

resRouting <- function(list_output){

  if(list_output$routing == F){
  print("no routing ")
    }else{
      print("routing in process...")
catch <- list_output$catch
      riv_catch <- st_intersection(riv, list_output$catch)

      res_riv_catch <- st_join(res_max, riv_catch, join = st_intersects)
      res_riv_catch <- subset(res_riv_catch, !is.na(ARCID))


plot(catch$geometry, col = "white")
plot(riv_catch$geometry, add = T, col = "red")
plot(res_riv_catch$geometry, col = "cadetblue4", add = T)

}
}
