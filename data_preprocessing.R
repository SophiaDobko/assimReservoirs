# Data preprocessing ####

library(sf)
otto <- st_read("D:/shapefiles/hybas_sa_lev12")
riv <- st_read("D:/shapefiles/hybas_sa_riv")

ce <- st_read("D:/shapefiles/Ceara_muni")
ce <- st_transform(ce, "+proj=longlat +datum=WGS84 +no_defs")

otto <- st_intersection(otto, ce)
riv <- st_intersection(riv, ce)

plot(ce$geometry)
plot(otto$geometry)
plot(riv$geometry)

save(otto, file = "data/otto_CE.RData")
save(riv, file = "data/riv_CE.RData")

res_max <- st_read("D:/shapefiles/res_max")
save(res_max, file = "data/res_max.RData")
