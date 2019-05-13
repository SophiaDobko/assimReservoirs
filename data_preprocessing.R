# Data preprocessing ####

library(sf)
otto <- st_read("D:/shapefiles/hybas_sa_lev12")
riv <- st_read("D:/shapefiles/hybas_sa_riv")
res_max <- st_read("D:/shapefiles/res_max")

res_max <- res_max[,c(1,3,8)]
res_max$vol_max <- res_max$volume
res_max$volume <- NULL

ce <- st_read("D:/shapefiles/Brazil_states")
ce <- subset(ce, NM_ESTADO == "CEARÁ")
ce$ID <- NULL
ce$CD_GEOCODU <- NULL
ce$NM_ESTADO <- NULL
ce$NM_REGIAO <- NULL
ce <- st_transform(ce, "+proj=utm +zone=24 +south +datum=WGS84 +no_defs")

otto <- st_transform(otto, "+proj=utm +zone=24 +south +datum=WGS84 +no_defs")
riv <- st_transform(riv, "+proj=utm +zone=24 +south +datum=WGS84 +no_defs")
res_max <- st_transform(res_max, "+proj=utm +zone=24 +south +datum=WGS84 +no_defs")

otto <- st_intersection(otto, ce)
riv <- st_intersection(riv, ce)
rm(ce)
dup <- riv[which(duplicated(riv$ARCID)),]
riv <- subset(riv, !(ARCID %in% dup$ARCID))
rownames(riv) <- 1:nrow(riv)

save(otto, file = "D:/assimReservoirs/data/otto.RData")
save(riv, file = "D:/assimReservoirs/data/riv.RData")
save(res_max, file = "D:/assimReservoirs/data/res_max.RData")

# postos -> reservoir model ####
library(sp)
postos <- read.csv("D:/reservoir_model/postos.csv", dec = ".", sep = "\t", header = T)
postos$lat <- - as.numeric(char2dms(from = as.character(postos$Latitude..S.), chd = "°", chm = "'", chs = "\""))
postos$lon <- - as.numeric(char2dms(from = as.character(postos$Longitude..W.), chd = "°", chm = "'", chs = "\""))
coordinates(postos) <- ~lon+lat
proj4string(postos) <- "+proj=longlat +datum=WGS84 +no_defs"
postos <- st_as_sf(postos)
postos <- st_transform(postos, crs = "+proj=utm +zone=24 +south +datum=WGS84 +units=m +no_defs")

save(postos, file = "D:/assimReservoirs/data/postos.RData")


