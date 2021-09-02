# ------------------------------------------------------------------
# Clustering
# Trying some Clustering
# check again - no longer working
library(stats)
colicData.Matrix <- as.matrix(colicData)
m <- colicData.Matrix
distMatrix_E <- dist(m, method="euclidean")
#print(distMatrix_E)
distMatrix_M <- dist(m, method="manhattan")
#print(distMatrix_M)

##Clustering
###Clustering Methods:
## HAC: Hierarchical Algorithm Clustering Method
## Euclidean
groups_E <- hclust(distMatrix_E,method="ward.D")
plot(groups_E, cex=0.5, font=22, hang=-1, main = "HAC Cluster Dendrogram with Euclidean Similarity")
rect.hclust(groups_E, k=2)

# Clustering with Manhattan
groups_M <- hclust(distMatrix_M,method="ward.D")
plot(groups_M, cex=0.5, font=22, hang=-1, main = "HAC Cluster Dendrogram with Manhattan Similarity")
rect.hclust(groups_M, k=2)

X <- colicData
# K-Means Cluster Analysis
fitcd <- kmeans(X, 5) # 5 cluster solution
# get cluster means
aggregate(X,by=list(fitcd$cluster),FUN=mean)
# append cluster assignment
mydata <- data.frame(X, fitcd$cluster) 

## Create a normalized version of Papers_DTM
colicDataM_N1 <- apply(colicDataM, 1, function(i) round(i/sum(i),3))
Papers_Matrix_Norm <- t(Papers_M_N1)
## Have a look at the original and the norm to make sure
(Papers_M[c(1:11),c(1000:1010)])
(Papers_Matrix_Norm[c(1:11),c(1000:1010)])
# upon is 4627
(Papers_Matrix_Norm[c(1:11),c(4620:4630)])

## k means clustering Methods
X <- m_norm
k2 <- kmeans(X, centers = 2, nstart = 100, iter.max = 50)
str(k2)

k3 <- kmeans(X, centers = 8, nstart = 50, iter.max= 50)
str(k3)

# print the centroids
k3$centers
cluster_assignment <- data.frame(X, k3$cluster)
View(cluster_assignment)
cluster_assignment

## k means visualization results!
distance1 <- get_dist(X,method = "manhattan")
fviz_dist(distance1, gradient = list(low = "#00AFBB", mid = "white", high = "#FC4E07"))
distance2 <- get_dist(X,method = "euclidean")
fviz_dist(distance2, gradient = list(low = "#00AFBB", mid = "white", high = "#FC4E07"))
distance3 <- get_dist(X,method = "spearman")
fviz_dist(distance3, gradient = list(low = "#00AFBB", mid = "white", high = "#FC4E07", title= "Distance Matrix Visualization, Spearman Method"))
str(X)

## k means
kmeansFIT_1 <- kmeans(X, centers = 4)
#(kmeansFIT1)
summary(kmeansFIT_1)

#(kmeansFIT_1$cluster)
#fviz_cluster(kmeansFIT_1, data = X)
kmeansFIT_2 <- kmeans(X, centers = 3)
#(kmeansFIT2)
summary(kmeansFIT_2)

(kmeansFIT_2$cluster)
#fviz_cluster(kmeansFIT_2, data = X)
