# reservoir routing with river graph ####

# identify leaves

# for-loop through leaves

res_max$next_res <- NA
strategic <- res_max[res_max$`distance to river`==0,]
river_reaches <- unique(strategic$`nearest river`)

points <- st_line_sample(riv[riv$ARCID==river_reaches[1],], n = 50)
points <- st_cast(points, "POINT")
points <- st_sf(points)
points$sample <- 1:50

plot(points)

plot(points$points)
plot(strategic$geometry[strategic$`nearest river`==river_reaches[1]], add = T, col = "cadetblue")

inter <- st_intersection(strategic, points)
r <- data.frame(id_jrc = unique(inter$id_jrc))
for(i in 1:nrow(r)){
  r$sample_max[i] <- max(inter$sample[inter$id_jrc== r$id_jrc[i]])
}

