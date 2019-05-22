# Plot distribution of reservoir size along downstream path
library(assimReservoirs)
res_distr <- res_max
res_distr$res_down[res_distr$res_down == -1] <- NA
for(i in 1:nrow(res_distr)){
  res_distr$area_max_res_down[i] <- res_distr$area_max[res_distr$id_jrc == res_distr$res_down[i]][1]
}
res_distr <- res_distr[!is.na(res_distr$res_down),]

# hist(res_distr$area_max)
mydata <- res_distr[c("id_jrc", "area_max", "area_max_res_down")]
#mydata <- res_distr[c("area_max")]
mydata$geometry <- NULL
# mydata <- scale(mydata) # standardize variables
mydata$log10area_max <- log10(mydata$area_max)
mydata$log10area_max_res_down <- log10(mydata$area_max_res_down)

plot(log10(mydata$area_max_res_down) ~ log10(mydata$area_max))
hist(mydata$log10area_max)
hist(mydata$log10area_max_res_down)

# Determine number of clusters
wss <- (nrow(mydata)-1)*sum(apply(mydata,2,var))
for (i in 2:15) wss[i] <- sum(kmeans(mydata,
                                     centers=i)$withinss)
plot(1:15, wss, type="b", xlab="Number of Clusters",
     ylab="Within groups sum of squares")

# K-Means Cluster Analysis
fit <- kmeans(mydata$log10area_max, 6) # 5 cluster solution
# get cluster means
groupmeans <- aggregate(mydata,by=list(fit$cluster),FUN=mean)
groupmeans <- groupmeans[order(groupmeans$area_max),]
groupmins <- aggregate(mydata,by=list(fit$cluster),FUN=min)
groupmaxs <- aggregate(mydata,by=list(fit$cluster),FUN=max)

# append cluster assignment
mydata <- data.frame(mydata, fit$cluster)
m <- table(mydata$fit.cluster)
m
library(sm)
# plot all groups in 1 plot
# cols <- c("green","darkgreen", "darkblue", "blue","purple","red","orange","yellow")
# sm.density.compare(mydata$log10area_max_res_down, mydata$fit.cluster, col = cols)
# legend(locator(1), legend = c("a", "b", "c", "d", "e","f","g","h"), levels(mydata$fit.cluster), fill = cols)

# 1 plot for each group
png("D:/assimReservoirs/figures/reservoir_distribution.png", width = 5, height = 8, res = 500, units = "i")
par(mfrow = c(6,1), mar = c(4,4,1,2), oma = c(1,0,0,0))
for(i in groupmeans$Group.1[1:6]){
  plot(density(mydata$log10area_max_res_down[mydata$fit.cluster==i]), xlim = c(3,9.2), ylim = c(0,0.5), main = "")
  legend("topright", inset = -0.01, paste("reservoir surface \n", round(groupmins$area_max[groupmins$Group.1==i]), "-", round(groupmaxs$area_max[groupmins$Group.1==i])), bty = "n")
   }
dev.off()

# plot hist 1
png("D:/assimReservoirs/figures/reservoir_distribution_hist1.png", width = 5, height = 8, res = 500, units = "i")
par(mfrow = c(6,1), mar = c(4,4,1,2), oma = c(1,0,0,0))
for(i in groupmeans$Group.1[1:6]){
  hist(mydata$log10area_max_res_down[mydata$fit.cluster==i], ylim = c(0,1200), xlab = "log10(area_res_down)", main = "", xlim = c(3,10))
  legend("topright", inset = -0.04, paste("reservoir surface \n", round(groupmins$area_max[groupmins$Group.1==i]), "-", round(groupmaxs$area_max[groupmins$Group.1==i]), "\n N=", length(mydata$log10area_max_res_down[mydata$fit.cluster==i])),
         bty = "n", xpd = T)
}
dev.off()

# plot hist 2
mydata$fit2 <- mydata$fit.cluster
fit2 <- mydata[mydata$fit.cluster==4,]
fit2 <- fit2[order(fit2$log10area_max),]
fit2$fit2[197:393] <- 7
fit2 <- fit2[fit2$fit2==7,]
mydata$fit2[mydata$area_max %in% fit2$area_max] <- 7

png("D:/assimReservoirs/figures/reservoir_distribution_hist2.png", width = 5, height = 8, res = 500, units = "i")
par(mfrow = c(8,1), mar = c(4,4,1,8), oma = c(1,0,0,0))
for(i in c(groupmeans$Group.1[1:6],7)){
  hist(mydata$log10area_max_res_down[mydata$fit2==i], xlab = "log10(area_res_down)", main = "", xlim = c(3,8.8))
  legend("right", inset = -0.3, paste("A=", round(min(mydata$area_max[mydata$fit2==i])), "- \n", round(max(mydata$area_max[mydata$fit2==i])), "m² \n N=", length(mydata$log10area_max_res_down[mydata$fit2==i])),
         bty = "n", xpd = T)
}
hist(mydata$log10area_max_res_down, main = "", xlim = c(3,8.8), col = "darkred")
legend("right", inset = -0.3, "all reservoirs",
       bty = "n", xpd = T)

dev.off()

# evaluate by HU
library(sf)
res_geometry <- st_read("D:/shapefiles/res_max")
res_geometry <- st_transform(res_geometry, "+proj=utm +zone=24 +south +datum=WGS84 +no_defs")
res_hu <- data.frame(id_jrc = res_geometry$id_jrc, hu = res_geometry$hu)
mydata <- base::merge(mydata, res_hu, by = "id_jrc")

baixo_jaguaribe <- mydata[mydata$hu==3,]
litoral <- mydata[mydata$hu==6,]
medio_jaguaribe <- mydata[mydata$hu==7,]
salgado <- mydata[mydata$hu==9,]
crateus <- mydata[mydata$hu==12,]

png("D:/assimReservoirs/figures/reservoir_distribution_litoral.png", width = 5, height = 8, res = 500, units = "i")
par(mfrow = c(7,1), mar = c(4,4,1,8), oma = c(1,0,0,0))
for(i in groupmeans$Group.1[1:6]){
  hist(litoral$log10area_max_res_down[litoral$fit.cluster==i], xlab = "log10(area_res_down)", main = "", xlim = c(3,8))
  legend("right", inset = -0.3, paste("A=", round(groupmins$area_max[groupmins$Group.1==i]), "- \n", round(groupmaxs$area_max[groupmins$Group.1==i]), "m² \n N=", length(litoral$log10area_max_res_down[litoral$fit.cluster==i])),
         bty = "n", xpd = T)
}
hist(litoral$log10area_max_res_down, main = "", xlim = c(3,8), col = "darkred", xlab = "Litoral - log10(area_res_down)")
legend("right", inset = -0.3, "all reservoirs",
       bty = "n", xpd = T)
dev.off()

png("D:/assimReservoirs/figures/reservoir_distribution_salgado.png", width = 5, height = 8, res = 500, units = "i")
par(mfrow = c(7,1), mar = c(4,4,1,8), oma = c(1,0,0,0))
for(i in groupmeans$Group.1[1:6]){
  hist(salgado$log10area_max_res_down[salgado$fit.cluster==i], xlab = "log10(area_res_down)", main = "", xlim = c(3,9))
  legend("right", inset = -0.3, paste("A=", round(groupmins$area_max[groupmins$Group.1==i]), "- \n", round(groupmaxs$area_max[groupmins$Group.1==i]), "m² \n N=", length(salgado$log10area_max_res_down[salgado$fit.cluster==i])),
         bty = "n", xpd = T)
}
hist(salgado$log10area_max_res_down, main = "", col = "darkred", xlab = "Salgado - log10(area_res_down)", xlim = c(3,9))
legend("right", inset = -0.3, "all reservoirs",
       bty = "n", xpd = T)
dev.off()

png("D:/assimReservoirs/figures/reservoir_distribution_crateus.png", width = 5, height = 8, res = 500, units = "i")
par(mfrow = c(7,1), mar = c(4,4,1,8), oma = c(1,0,0,0))
for(i in groupmeans$Group.1[1:6]){
  hist(crateus$log10area_max_res_down[crateus$fit.cluster==i], xlab = "log10(area_res_down)", main = "", xlim = c(3,8))
  legend("right", inset = -0.3, paste("A=", round(groupmins$area_max[groupmins$Group.1==i]), "- \n", round(groupmaxs$area_max[groupmins$Group.1==i]), "m² \n N=", length(crateus$log10area_max_res_down[crateus$fit.cluster==i])),
         bty = "n", xpd = T)
}
hist(crateus$log10area_max_res_down, main = "", xlim = c(3,8), col = "darkred", xlab = "Crateus - log10(area_res_down)")
legend("right", inset = -0.3, "all reservoirs",
       bty = "n", xpd = T)
dev.off()

png("D:/assimReservoirs/figures/reservoir_distribution_baixo_jaguaribe.png", width = 5, height = 8, res = 500, units = "i")
par(mfrow = c(7,1), mar = c(4,4,1,8), oma = c(1,0,0,0))
for(i in groupmeans$Group.1[1:6]){
  hist(baixo_jaguaribe$log10area_max_res_down[baixo_jaguaribe$fit.cluster==i], xlab = "log10(area_res_down)", main = "", xlim = c(3,8))
  legend("right", inset = -0.3, paste("A=", round(groupmins$area_max[groupmins$Group.1==i]), "- \n", round(groupmaxs$area_max[groupmins$Group.1==i]), "m² \n N=", length(baixo_jaguaribe$log10area_max_res_down[baixo_jaguaribe$fit.cluster==i])),
         bty = "n", xpd = T)
}
hist(baixo_jaguaribe$log10area_max_res_down, main = "", xlim = c(3,8), col = "darkred", xlab = "baixo_jaguaribe - log10(area_res_down)")
legend("right", inset = -0.3, "all reservoirs",
       bty = "n", xpd = T)
dev.off()

png("D:/assimReservoirs/figures/reservoir_distribution_medio_jaguaribe.png", width = 5, height = 8, res = 500, units = "i")
par(mfrow = c(7,1), mar = c(4,4,1,8), oma = c(1,0,0,0))
for(i in groupmeans$Group.1[1:6]){
  hist(medio_jaguaribe$log10area_max_res_down[medio_jaguaribe$fit.cluster==i], xlab = "log10(area_res_down)", main = "", xlim = c(3,9))
  legend("right", inset = -0.3, paste("A=", round(groupmins$area_max[groupmins$Group.1==i]), "- \n", round(groupmaxs$area_max[groupmins$Group.1==i]), "m² \n N=", length(medio_jaguaribe$log10area_max_res_down[medio_jaguaribe$fit.cluster==i])),
         bty = "n", xpd = T)
}
hist(medio_jaguaribe$log10area_max_res_down, main = "", xlim = c(3,9), col = "darkred", xlab = "medio_jaguaribe - log10(area_res_down)")
legend("right", inset = -0.3, "all reservoirs",
       bty = "n", xpd = T)
dev.off()
