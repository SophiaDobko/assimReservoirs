# Data preprocessing ####

library(sf)
otto <- st_read("D:/shapefiles/hybas_sa_lev12")
riv <- st_read("D:/shapefiles/hybas_sa_riv")

ce <- st_read("D:/shapefiles/Brazil_states")
ce <- subset(ce, NM_ESTADO == "CEARÁ")
ce$ID <- NULL
ce$CD_GEOCODU <- NULL
ce$NM_ESTADO <- NULL
ce$NM_REGIAO <- NULL
ce <- st_transform(ce, "+proj=longlat +datum=WGS84 +no_defs")

otto <- st_intersection(otto, ce)
riv <- st_intersection(riv, ce)
res_max <- st_read("D:/shapefiles/res_max")
rm(ce)

# otto <- st_transform(otto, "+proj=utm +zone=24 +datum=WGS84 +no_defs")
# riv <- st_transform(riv, "+proj=utm +zone=24 +datum=WGS84 +no_defs")
# res_max <- st_transform(res_max, "+proj=utm +zone=24 +datum=WGS84 +no_defs")

save(otto, file = "data/otto_CE.RData")
save(riv, file = "data/riv_CE.RData")
save(res_max, file = "data/res_max.RData")
