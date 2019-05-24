# Plot distribution of reservoir size along downstream path
library(assimReservoirs)
res_distr <- res_max
res_distr$res_down[res_distr$res_down == -1] <- NA
for(i in 1:nrow(res_distr)){
  res_distr$area_max_res_down[i] <- res_distr$area_max[res_distr$id_jrc == res_distr$res_down[i]][1]
}
res_distr <- res_distr[!is.na(res_distr$res_down),]

# hist(res_distr$area_max)
mydata <- res_distr[c("area_max", "area_max_res_down")]
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
cols <- c("green","darkgreen", "darkblue", "blue","purple","red","orange","yellow")
sm.density.compare(mydata$log10area_max_res_down, mydata$fit.cluster, col = cols)
legend(locator(1), legend = c("a", "b", "c", "d", "e","f","g","h"), levels(mydata$fit.cluster), fill = cols)

# 1 plot for each group
png("D:/assimReservoirs/figures/reservoir_distribution.png", width = 5, height = 6.5, res = 500, units = "i")
par(mfrow = c(6,1), mar = c(2,4,2,2), oma = c(1,0,0,0))
for(i in groupmeans$Group.1[1:6]){
  plot(density(mydata$log10area_max_res_down[mydata$fit.cluster==i]), xlim = c(3,9.2), ylim = c(0,0.5), main = "")
  legend("topright", inset = -0.01, paste("reservoir surface \n", round(groupmins$area_max[groupmins$Group.1==i]), "-", round(groupmaxs$area_max[groupmins$Group.1==i])), bty = "n")
   }
dev.off()
