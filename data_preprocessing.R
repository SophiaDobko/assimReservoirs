# Data preprocessing ####

library(sf)
library(sp)
library(igraph)

# Prepare otto, riv and res_max ####
otto <- st_read("D:/shapefiles/hybas_sa_lev12")
riv <- st_read("D:/shapefiles/hybas_sa_riv")
res_max <- st_read("D:/shapefiles/res_max")
res_geometry <- st_read("D:/shapefiles/res_max")

res_max <- res_max[,c(1,3,8)]
res_max$vol_max <- res_max$volume
res_max$volume <- NULL
upcells <- riv
upcells$geometry <- NULL
res_max <- merge(res_max, upcells, by.x = "nearest river", by.y = "ARCID")

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
res_geometry <- st_transform(res_geometry, "+proj=utm +zone=24 +south +datum=WGS84 +no_defs")

otto <- st_intersection(otto, ce)
riv <- st_intersection(riv, ce)
rm(ce)
dup <- riv[which(duplicated(riv$ARCID)),]
riv <- subset(riv, !(ARCID %in% dup$ARCID))
rownames(riv) <- 1:nrow(riv)

res_catch <- st_intersection(res_max, otto)
res_max$HYBAS_ID <- NA
for(r in 1:nrow(res_max)){
  res <- res_catch[res_catch$id_jrc == res_max$id_jrc[r],]
  if(nrow(res)>1){
    res <- res[res$UP_CELLS== max(res$UP_CELLS),]
  }
  res_max$HYBAS_ID[r] <- res$HYBAS_ID
}
res_max <- res_max[c(2:5,1,6,8,7)]

save(otto, file = "D:/assimReservoirs/data/otto.RData")
save(riv, file = "D:/assimReservoirs/data/riv.RData")
save(res_max, file = "D:/assimReservoirs/data/res_max.RData")
save(res_geometry, file = "D:/assimReservoirs/data/res_geometry.RData")

# create otto_graph ####
create_graph <- otto
# create_graph <- create_graph[create_graph$NEXT_DOWN>0,]
create_graph$NEXT_DOWN[create_graph == 0] <- NA
create_graph <- data.frame(from = create_graph$HYBAS_ID, to = create_graph$NEXT_DOWN)
otto_graph <- graph_from_data_frame(create_graph, directed = T)
save(otto_graph, file = "D:/assimReservoirs/data/otto_graph.RData")

# create reservoir-graph after routing ####
create_graph <- res_max
create_graph$res_down[(res_max$res_down)==-1] <- NA
# create_graph <- create_graph[!is.na(create_graph$res_down),]
create_graph <- data.frame(from = create_graph$id_jrc, to = create_graph$res_down)
reservoir_graph <- graph_from_data_frame(create_graph, directed = T)
save(reservoir_graph, file = "D:/assimReservoirs/data/reservoir_graph.RData")

# postos ####
postos <- read.csv("D:/reservoir_model/postos.csv", dec = ".", sep = "\t", header = T)
postos$lat <- - as.numeric(char2dms(from = as.character(postos$Latitude..S.), chd = "°", chm = "'", chs = "\""))
postos$lon <- - as.numeric(char2dms(from = as.character(postos$Longitude..W.), chd = "°", chm = "'", chs = "\""))
coordinates(postos) <- ~lon+lat
proj4string(postos) <- "+proj=longlat +datum=WGS84 +no_defs"
postos <- st_as_sf(postos)
postos <- st_transform(postos, crs = "+proj=utm +zone=24 +south +datum=WGS84 +units=m +no_defs")
save(postos, file = "D:/assimReservoirs/data/postos.RData")


