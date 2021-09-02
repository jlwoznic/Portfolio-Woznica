# 
# Course: IST707
# Name: Joyce Woznica
# Project Code: Vizualizations and Modeling
# Due Date: 12/10/2019
#
# ------------------------------------------------------------------
# Set working directory
setwd("C:/Users/Joyce/Desktop/Syracuse/IST707/Project/RCode")
# Run ProjectPackages2
source("ProjectPackages2.R", local=TRUE) # sometimes have to run twice - not sure why
# Run ProjectFunctions
source("ProjectFunctions.R", local=TRUE)
# Run ColicDataLoadCleanup
source("ColicDataLoadCleanup.R", local=TRUE)

# ------------------------------------------------------------------
# force no scientific notation
options(scipen=999)
# General Statistics and Analysis
summary(colicData)
genStat <- stat.desc(colicData, basic=F)
View(genStat)

# combine in a plot
table(colicData$outcome)
barplot(table(colicData$outcome), col=rainbow(20))

# overall description (lengthy)
describe(colicData)

test<-as.matrix(colicData)
summary(test)

# descriptive statistics from using stargazer package
stargazer(colicData, type="text")


# ------------------------------------------------------------------
# Initial Visualizations
# boxplot of mucous_membrane
# boxplot of pain level
# abdomen
# histograms of Rectal_temp, pulse, respiratory rate, temp of extremeties, pulse, reflux
hist(colicData$rectal_temp, col=topo.colors(5), main="Histogram of Rectal Temperatures")
hist(colicData$pulse, col=terrain.colors(5), main="Histogram of Pulse")
hist(colicData$respiratory_rate, col=rainbow(5), main="Histogram of Respiratory Rate")
hist(colicData$total_protein, col=topo.colors(5), main="Histogram of Total Protein")
hist(colicData$packed_cell_volume, col=cm.colors(5), main="Histogram of Packed Cell Volume")

# count these and group by how many of each
# do a which on the values to get totals
# separate data be outcome for plotting reflux
gastroTbl <- table(colicData$outcome, colicData$nasogastric_reflux)
gastroDF <- data.frame(gastroTbl)
colnames(gastroDF)<-c("outcome", "reflux", "horse_count")

barplot(gastroTbl,beside=TRUE, legend=TRUE, col=c("red", "orange", "green"),
        main="Horses showing Naso Gastric Reflux by Outcome",
        axisnames=TRUE)

# Abdomen Presentation
barplot(table(colicData$outcome, colicData$abdomen), beside=TRUE, legend=TRUE,
        col=c("red", "blue", "green"), main="Abdomen Presentation and Outcome",
        axisnames=TRUE)

# lesion1A - redo with ggplot later!
barplot (table(colicData$outcome, colicData$lesion1A), beside=TRUE, legend=TRUE,
         col=c("red", "blue", "green"), main="Lesion 1A Location and Outcome",
         axisnames=TRUE)

# Lesion 1A (Site)
g <- ggplot(colicData, aes(x=lesion1A, fill=factor(outcome)))
g <- g + ggtitle("Lesion 1A (Site) Location by Outcome")
g <- g + geom_bar(position="dodge")
g <- g + xlab("Lesion Site") + ylab("Number of Horses")
g <- g + theme(axis.text.x = element_text(angle = 45, hjust = 1))
g <- g + theme(plot.title = element_text(hjust=0.5))
g

# Lesion 1B (Type)
g <- ggplot(colicData, aes(x=lesion1B, fill=factor(outcome)))
g <- g + ggtitle("Lesion 1B (Type) Location by Outcome")
g <- g + geom_bar(position="dodge")
g <- g + xlab("Lesion Type") + ylab("Number of Horses")
g <- g + theme(axis.text.x = element_text(angle = 45, hjust = 1))
g <- g + theme(plot.title = element_text(hjust=0.5))
g

# Lesion 1C (SubType)
g <- ggplot(colicData, aes(x=lesion1C, fill=factor(outcome)))
g <- g + ggtitle("Lesion 1C (SubType) Location by Outcome")
g <- g + geom_bar(position="dodge")
g <- g + xlab("Lesion SubType") + ylab("Number of Horses")
g <- g + theme(axis.text.x = element_text(angle = 45, hjust = 1))
g <- g + theme(plot.title = element_text(hjust=0.5))
g

# Lesion 1D (Code)
g <- ggplot(colicData, aes(x=lesion1D, fill=factor(outcome)))
g <- g + ggtitle("Lesion 1D (Code) Location by Outcome")
g <- g + geom_bar(position="dodge")
g <- g + xlab("Lesion Code") + ylab("Number of Horses")
g <- g + theme(axis.text.x = element_text(angle = 45, hjust = 1))
g <- g + theme(plot.title = element_text(hjust=0.5))
g

# count these and group by how many of each
# do a which on the values to get totals
# separate data be outcome for rectal exam feces
fecesTbl <- table(colicData$outcome, colicData$rectal_exam_feces)
fecesDF <- data.frame(fecesTbl)
colnames(fecesDF)<-c("outcome", "feces", "horse_count")

barplot(fecesTbl,beside=TRUE, legend=TRUE, col=c("red", "orange", "green"),
        main="Number of Horses Feces Status by Colic Outcome",
        axisnames=TRUE)

surgTbl <- table(colicData$outcome, colicData$surgery)
barplot(surgTbl,beside=TRUE, legend=TRUE, col=c("red", "orange", "green"),
        main="Number of Horses who had Surgery by Colic Outcome",
        axisnames=TRUE)

# boxplot of mucous membrane by outcome
# this doesn't make sense - fix it!
# with boxplot
g <- ggplot(colicData, aes(group=mucous_membrane,x=mucous_membrane,y=outcome)) 
g <- g + geom_boxplot(aes(fill=factor(mucous_membrane)))
g <- g+ theme(axis.text.x = element_text(angle = 45, hjust = 1))
g <- g + ggtitle("Outcome by Mucous Membrane") + theme(plot.title=element_text(hjust=0.5))
g

# Some initial plotting of the data to see what we have
plot(colicData$outcome,colicData$pulse)
# boxplot pulse rate by Outcome
# with boxplot
g <- ggplot(colicData, aes(group=outcome,x=outcome,y=pulse)) 
g <- g + geom_boxplot(aes(fill=factor(outcome)))
g <- g+ theme(axis.text.x = element_text(angle = 45, hjust = 1))
g <- g + xlab("Outcome") + ylab("Pulse")
g <- g + ggtitle("Pulse Rate by Outcome") + theme(plot.title=element_text(hjust=0.5))
g

# Some initial plotting of the data to see what we have
plot(colicData$outcome,colicData$pulse)
# boxplot of total protein by outcome
# with boxplot
g <- ggplot(colicData, aes(group=outcome,x=outcome,y=total_protein)) 
g <- g + geom_boxplot(aes(fill=factor(outcome)))
g <- g+ theme(axis.text.x = element_text(angle = 45, hjust = 1))
g <- g + xlab("Outcome") + ylab("Total Protein")
g <- g + ggtitle("Total Protein by Outcome") + theme(plot.title=element_text(hjust=0.5))
g

# Plot pulse rate by outcome
g <- ggplot(colicData, aes(x=outcome, y=pulse)) + geom_point()
g <- g + stat_smooth(method= "lm", col=rainbow(20))
g <- g + ggtitle("Pulse Rates by Outcome")
g <- g + xlab("Outcome") + ylab("Pulse")
g

g<- ggplot(colicData, aes(x=age, fill=factor(outcome)))
g<- g+ ggtitle("Outcome by Age")
g<- g+ xlab("Age") + ylab("Outcome")
g<- g + geom_bar(position="dodge")
g

# Look at some of the data via a scatter plot
g <- ggplot(colicData, aes(x=temp_of_extremities, y=respiratory_rate))
g <- g + geom_point(aes(color=outcome, size=age))
g <- g + ggtitle("Outcome using Age, Respiratory Rate and Extremity Temperature")
g <- g + theme(plot.title=element_text(hjust=0.5))
g <- g + xlab("Extremity Temperature") + ylab("Respiratory Rate")
g

#Data Visualization
#Visual 1
ggplot(colicData, aes(packed_cell_volume, colour = outcome)) +
  geom_freqpoly(binwidth = 1) + labs(title="Packed Cell Volume Distribution by Outcome")

#visual 2
c <- ggplot(colicData, aes(x=nasogastric_reflux_ph, fill=outcome, color=outcome)) +
  geom_histogram(binwidth = 1) + labs(title="Nasogastric Reflux PH Distribution by Outcome")
c + theme_bw()

#visual 3
P <- ggplot(colicData, aes(x=total_protein, fill=outcome, color=outcome)) +
  geom_histogram(binwidth = 1) + labs(title="Total Protein Distribution by Outcome")
P + theme_bw()

# -----------------------------------------------------------------------------
# Clustering that Means Nothing to me
## k means visualization results!
X <- colicData
distance1 <- get_dist(X,method = "manhattan")
fviz_dist(distance1, gradient = list(low = "#00AFBB", mid = "white", high = "#FC4E07"))
distance2 <- get_dist(X,method = "euclidean")
fviz_dist(distance2, gradient = list(low = "#00AFBB", mid = "white", high = "#FC4E07"))

# ------------------------------------------------------------------
# Decision Tree
##Make Train and Test sets
trainRatio <- .70
set.seed(11) # Set Seed so that same sample can be reproduced in future also
sample <- sample.int(n = nrow(colicData), size = floor(trainRatio*nrow(colicData)), replace = FALSE)
train <- colicData[sample, ]
test <- colicData[-sample, ]
train_orig <- train
test_orig <- test
# train / test ratio
length(sample)/nrow(colicData)

##--------------------------------------------------------------------------------------------------------
#Decision Tree Models 
# build accuracy vector
treeAccuracyV <- list()

#Train Tree Model 1
# start with first Training Tree 1
train_tree1 <- rpart(outcome ~ ., data = train, method="class", control=rpart.control(cp=0))
summary(train_tree1)
#predict the test dataset using the model for train tree No. 1
predicted1 <- predict(train_tree1, test, type="class")
#plot number of splits
rsq.rpart(train_tree1)
#predict the test dataset using the model for train tree No. 1
predicted1 <- predict(train_tree1, test, type="class")
plotcp(train_tree1)
#plot the decision tree
fancyRpartPlot(train_tree1, cex=0.6, caption="Training Tree 1")
fancyRpartPlot(train_tree1, cex=0.6, caption="Training Tree 1", palettes=c("Greys", "Blues", "Oranges"))
#confusion matrix to find correct and incorrect predictions
tree1_table <- table(Outcome=predicted1, true=test$outcome)
treeAccuracyV <- c(treeAccuracyV, sum(diag(tree1_table)) / sum(tree1_table))

#Train Tree Model 2 
train_tree2 <- rpart(outcome ~ ., data = train, method="class", control=rpart.control(cp=0, minsplit = 2, maxdepth = 5))
summary(train_tree2)
#predict the test dataset using the model for train tree No. 2
predicted2<- predict(train_tree2, test, type="class")
plotcp(train_tree2)
#plot number of splits
rsq.rpart(train_tree2)
#plot the decision tree
fancyRpartPlot(train_tree2, cex=0.6, caption="Training Tree 2")
#confusion matrix to find correct and incorrect predictions
tree2_table <- table(Outcome=predicted2, true=test$outcome)
treeAccuracyV <- c(treeAccuracyV, sum(diag(tree2_table)) / sum(tree2_table))

#Train Tree Model 3
train_tree3 <- rpart(outcome ~ ., data = train, method="class", control=rpart.control(cp=0, minsplit = 5, maxdepth = 5))
summary(train_tree3)
#predict the test dataset using the model for train tree No. 3
predicted3 <- predict(train_tree3, test, type="class")
plotcp(train_tree3)
#plot number of splits
rsq.rpart(train_tree3)
#plot the decision tree
fancyRpartPlot(train_tree3, cex=0.6, caption="Training Tree 3")
#confusion matrix to find correct and incorrect predictions
tree3_table <- table(Outcome=predicted3, true=test$outcome)
treeAccuracyV <- c(treeAccuracyV, sum(diag(tree3_table)) / sum(tree3_table))

#Train Tree Model 4 
train_tree4 <- rpart(outcome ~ ., data = train, method="class", control=rpart.control(cp=0, minsplit = 3, maxdepth = 5))
summary(train_tree4)
#predict the test dataset using the model for train tree No. 4
predicted4 <- predict(train_tree4, test, type="class")
plotcp(train_tree4)
#plot number of splits
rsq.rpart(train_tree4)
#plot the decision tree
fancyRpartPlot(train_tree4, cex=0.6, caption="Training Tree 4")
#confusion matrix to find correct and incorrect predictions
tree4_table <- table(Outcome=predicted4, true=test$outcome)
treeAccuracyV <- c(treeAccuracyV, sum(diag(tree4_table)) / sum(tree4_table))

#Train Tree Model 5 ** BEST MODEL **
train_tree5 <- rpart(outcome ~ ., data = train, method="class", control=rpart.control(cp=0, minsplit = 3, maxdepth = 4))
summary(train_tree5)
#predict the test dataset using the model for train tree No. 5
predicted5 <- predict(train_tree5, test, type="class")
plotcp(train_tree5)
#plot number of splits
rsq.rpart(train_tree5)
#plot the decision tree
fancyRpartPlot(train_tree5, cex=0.6, caption="Training Tree 5")
#confusion matrix to find correct and incorrect predictions
tree5_table <- table(Outcome=predicted5, true=test$outcome)
treeAccuracyV <- c(treeAccuracyV, sum(diag(tree5_table)) / sum(tree5_table))

#Train Tree Model 6 
train_tree6 <- rpart(outcome ~ ., data = train, method="class", control=rpart.control(cp=0, minsplit = 3, maxdepth = 3))
summary(train_tree6)
#predict the test dataset using the model for train tree No. 6
predicted6 <- predict(train_tree6, test, type="class")
plotcp(train_tree6)
#plot number of splits
rsq.rpart(train_tree6)
#plot the decision tree
fancyRpartPlot(train_tree6, cex=0.6, caption="Training Tree 6")
#confusion matrix to find correct and incorrect predictions
tree6_table <- table(Outcome=predicted6, true=test$outcome)
treeAccuracyV <- c(treeAccuracyV, sum(diag(tree6_table)) / sum(tree6_table))

# show other confusion  matrices to determine which is best
treeAccuracyV <- data.frame(treeAccuracyV)
colnames(treeAccuracyV) <- c("tree1", "tree2", "tree3", "tree4", "tree5", "tree6")
treeAccuracyV

# Play around with tuning
# rpart.control(minsplit = 20, minbucket = round(minsplit/3), maxdepth = 30)
# Arguments:
#  -minsplit: Set the minimum number of observations in the node before the algorithm perform a split
#  -minbucket:  Set the minimum number of observations in the final note i.e. the leaf
#  -maxdepth: Set the maximum depth of any node of the final tree. The root node is treated a depth 0

accuracy_tune <- function(fit) {
  predict_unseen <- predict(fit, test_orig, type = 'class')
  table_mat <- table(test_orig$outcome, predict_unseen)
  accuracy_Test <- sum(diag(table_mat)) / sum(table_mat)
  accuracy_Test
}

control <- rpart.control(minsplit = 4,
                         minbucket = round(5 / 3),
                         maxdepth = 3,
                         cp = 0)
tune_fit <- rpart(outcome~., data = train_orig, method = 'class', control = control)
accuracy_tune(tune_fit)

minsplit = 4
minbucket= round(5/3)
maxdepth = 3
cp=0	

ind <- 1
while ( ind <= ncol(treeAccuracyV)) 
{ 
  print(paste('Accuracy for test', ind, treeAccuracyV[,ind]))
  ind <- 1 + ind
  }
##--------------------------------------------------------------------------------------------------------
# Pruning the tree - find the best model (5)
printcp(train_tree5)
plotcp(train_tree5)
ptrain_tree5 <- prune(train_tree5, cp = train_tree5$cptable[which.min(train_tree5$cptable[,"xerror"]), "CP"])
fancyRpartPlot(ptrain_tree5, uniform=TRUE, cex=0.5, main="Pruned Classification Tree 5")
rpart.plot(ptrain_tree5, extra=104, box.palette="GnBu", branch.lty=3, shadow.col="gray", nn=TRUE)

predictedpt5 <- predict(ptrain_tree5, test, type="class")

ptree5_table <- table(Outcome=predictedpt5, true=test$outcome)
pruned_accuracy <- sum(diag(ptree5_table)) / sum(ptree5_table)
pruned_accuracy

#---------------------------------------------------------------------------------------------------------
# Decision Trees with cross validation
# Create k-folds for k-fold cross validation 
# code used from code provided by Jeremy Bolton, Professor at Syracuse University
## Number of observations
N <- nrow(colicData)
## Number of desired splits
kfolds <- 4
## Generate indices of holdout observations
## Note if N is not a multiple of folds you will get a warning, but is OK.
# these are sets of observations to use as samples - there are 10 sets
holdout <- split(sample(1:N), 1:kfolds)
head(holdout)

dtree <- function (traindf, testdf, c_p, min_split, max_depth, graph_pall)
{
  # build the model
  Dtree <- rpart(outcome ~., data = traindf, method="class", control=rpart.control(cp=c_p, minsplit=min_split, maxdepth=max_depth))
  # reflect the error
  rsq.rpart(Dtree)
  # plot the tree
  rpart.plot(Dtree, extra=104, box.palette="GnBu", branch.lty=3, shadow.col="gray", nn=TRUE)
  return(Dtree)
}

Para_DTreeDF <- NULL

#Run training and Testing for each of the k-folds
# decision trees for kfolds
AllResultsCD <-list()
AllLabelsCD <-list()

# repeat from here
startTime <- proc.time()
for (k in 1:kfolds)
{
  # grab a set to be Test set
  colicData_Test <- colicData[holdout[[k]], ]
  colicData_Train <- colicData[-holdout[[k]], ]
  ## View the created Test and Train sets
  (head(colicData_Train))
  (table(colicData_Test$outcome))
  ## Make sure you take the labels out of the testing data
  (head(colicData_Test))
  # this needs to remove outcome, 
  colicData_Test_noOutcome <- subset(colicData_Test, select = -outcome)
  colicData_Test_justOutcome <- colicData_Test$outcome
  (head(colicData_Test_noOutcome))
  
  # decision tree modeling with Train
  dt_Train <- rpart(outcome ~., data = colicData_Train, method="class", control=rpart.control(cp=0, minsplit=2, maxdepth=6))
  rpart.plot(dt_Train, extra=104, box.palette="GnBu", cex=NULL, branch.lty=3, shadow.col="gray", nn=TRUE)
  dt_Pred <- predict(dt_Train, colicData_Test_noOutcome, type="class")
  
  #Testing accurancy of decision tree with Kaggle train data sub set
  (confusionMatrix(dt_Pred, colicData_Test$outcome))
  
  # Accumulate results from each fold, if you like
  AllResultsCD <- c(AllResultsCD,dt_Pred)
  AllLabelsCD <- c(AllLabelsCD, colicData_Test_justOutcome)
}
proc.time() - startTime

### end crossvalidation -- present results for all folds   
dt_table <- table(unlist(AllResultsCD),unlist(AllLabelsCD))
# test accuracy
print(paste('Accuracy for CV Decision Trees', sum(diag(dt_table)) / sum(dt_table)))
# build a matrix with the parameters and accuracy so we can use this to determine the best tree
# Run each of the above changing the minsplit and maxdepth
Para_DTreeDF <- rbind(Para_DTreeDF, c(2, 4, sum(diag(dt_table)) / sum(dt_table)))
Para_DTreeDF <- rbind(Para_DTreeDF, c(3, 5, sum(diag(dt_table)) / sum(dt_table)))
Para_DTreeDF <- rbind(Para_DTreeDF, c(4, 4, sum(diag(dt_table)) / sum(dt_table)))
Para_DTreeDF <- rbind(Para_DTreeDF, c(4, 6, sum(diag(dt_table)) / sum(dt_table)))
Para_DTreeDF <- rbind(Para_DTreeDF, c(4, 8, sum(diag(dt_table)) / sum(dt_table)))
Para_DTreeDF <- rbind(Para_DTreeDF, c(2, 10, sum(diag(dt_table)) / sum(dt_table)))
Para_DTreeDF <- rbind(Para_DTreeDF, c(4, 25, sum(diag(dt_table)) / sum(dt_table)))
Para_DTreeDF <- rbind(Para_DTreeDF, c(3, 4, sum(diag(dt_table)) / sum(dt_table)))

rownames(Para_DTreeDF) <- c()
colnames(Para_DTreeDF) <- c("minsplit", "maxdepth", "accuracy")
Para_DTreeDF <- data.frame(Para_DTreeDF)

##--------------------------------------------------------------------------------------------------------
# Random Forest
# use these same sets for samples for Random Forest
# already used previously
##Make Train and Test sets
# remove the outcome from the training set
rf_cdtest <- test_orig
rf_cdtrain <- train_orig
rf_cdtrain_noOutcome <- subset(rf_cdtrain, select = - outcome)
rf_cdtrain_justOutcome <- rf_cdtrain$outcome
rf_cdtest_noOutcome <- subset(rf_cdtest, select = -outcome)
rf_cdtest_justOutcome <- rf_cdtest$outcome

rf_wtrees <- function (numTrees)
{
  randF <- randomForest(rf_cdtrain_noOutcome, rf_cdtrain_justOutcome, xtest=rf_cdtest_noOutcome, 
                      ntree=numTrees, importance=TRUE, keep.forest=TRUE)
  randF # to look at the confusion matrix
  randFCM <- randF$confusion
  c(numTrees, sum(diag(randFCM)) / sum(randFCM))
}

# run the function with various trees
rfAccuracyM <- NULL
rfAccuracyM <- rbind(rfAccuracyM, rf_wtrees(100))
rfAccuracyM <- rbind(rfAccuracyM, rf_wtrees(75))
rfAccuracyM <- rbind(rfAccuracyM, rf_wtrees(50))
rfAccuracyM <- rbind(rfAccuracyM, rf_wtrees(49))
rfAccuracyM <- rbind(rfAccuracyM, rf_wtrees(48))
rfAccuracyM <- rbind(rfAccuracyM, rf_wtrees(47))
rfAccuracyM <- rbind(rfAccuracyM, rf_wtrees(46))
rfAccuracyM <- rbind(rfAccuracyM, rf_wtrees(45))
rfAccuracyM <- rbind(rfAccuracyM, rf_wtrees(44))
rfAccuracyM <- rbind(rfAccuracyM, rf_wtrees(43))
rfAccuracyM <- rbind(rfAccuracyM,rf_wtrees(42))
rfAccuracyM <- rbind(rfAccuracyM,rf_wtrees(40))
rfAccuracyM <- rbind(rfAccuracyM, rf_wtrees(35))
rfAccuracyM <- rbind(rfAccuracyM, rf_wtrees(25))
rfAccuracyM <- rbind(rfAccuracyM, rf_wtrees(15))
colnames(rfAccuracyM) <- c("NumTrees", "Accuracy")
rfAccuracyM

predictions <- data.frame(ImageID=1:nrow(rf_cdtest_noOutcome), 
                          label=levels(rf_cdtrain_justOutcome)[randF$test$predicted])
head(predictions)
str(predictions)
randF$ntree
tree1<-getTree(randF, 1, labelVar=TRUE)

##--------------------------------------------------------------------------------------------------------
# Associative Rule Mining
# must do some data cleanup first
colicDataARM <- colicData
# Create bins for the nasogastric_reflux_ph
summary(colicDataARM$nasogastric_reflux_ph)
colicDataARM$nasogastric_reflux_ph <- cut(colicDataARM$nasogastric_reflux_ph, breaks = c(0, 1.5, 3, 4.5, 6, 7.5),
                labels=c("< 1.5", "1.5-3", "3-4.5", "4.5-6", "6-7.5"))
# repeat for abdomo_protein
summary(colicDataARM$abdomo_protein)
colicDataARM$abdomo_protein <- cut(colicDataARM$abdomo_protein, breaks = c(0, 1.5, 3, 4.5, 6, 7.5, 9, 10.5),
                                          labels=c("< 1.5", "1.5-3", "3-4.5", "4.5-6", "6-7.5", "7.5-9", "9-10.5"))
# need to fix columns 3, 4, 5, 18 and 19 to be logical or factor
# 3-rectal_temp
summary(colicDataARM$rectal_temp)
colicDataARM$rectal_temp <- cut(colicDataARM$rectal_temp, breaks = c(34, 35, 36, 37, 38, 39, 40, 41),
                                          labels=c("34-35", "35-36", "36-37", "37-38", "38-39", "39-40", "40-41"))
# 4-pulse
summary(colicDataARM$pulse)
colicDataARM$pulse <- cut(colicDataARM$pulse, breaks = c(30, 45, 60, 75, 90, 105, 120, 135, 150, 165, 180, 195),
                                labels=c("30-45", "45-60", "60-75", "75-90", "90-105", "105-120", "120-135", "135-150", "150-165",
                                         "165-180", "180-195"))
# 5-respiratory_rate
summary(colicDataARM$respiratory_rate)
colicDataARM$respiratory_rate <- cut(colicDataARM$respiratory_rate, breaks = c(5, 15, 25, 35, 45, 55, 65, 75, 85, 95, 105),
                                labels=c("5-15", "15-25", "25-35", "35-45", "45-55", "55-65", " 65-75", 
                                "75-85", "85-95", "95-105"))

# 18-packed_cell_volume
summary(colicDataARM$packed_cell_volume)
colicDataARM$packed_cell_volume <- cut(colicDataARM$packed_cell_volume, breaks = c(20, 30, 40, 50, 60, 70, 80),
                                     labels=c("20 -30", "30-40", "40-50", "50-60", "60-70", "70-80"))

# 19-total_protein
summary(colicDataARM$total_protein)
colicDataARM$total_protein <- cut(colicDataARM$total_protein, breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90),
                                       labels=c("0-10", "10-20", "20 -30", "30-40", "40-50", "50-60", "60-70", "70-80", "80-90"))

# function to run associative rule mining
# df - dataframe
# conf_int - confidence interval
# supp_num = supp
# max_length - maximum length
myARMlived <- function (df, conf_int, supp_num, min_length, max_length)
{
        apriori(df, parameter=list(supp=supp_num, conf=conf_int, minlen=min_length, maxlen=max_length),
                appearance = list(default="lhs", rhs="outcome=lived"),
                control = list(verbose=F))
}

myARMdied <- function (df, conf_int, supp_num, min_length, max_length)
{
  apriori(df, parameter=list(supp=supp_num, conf=conf_int, minlen=min_length, maxlen=max_length),
          appearance = list(default="lhs", rhs=c("outcome=died", "outcome=euthanized")),
          control = list(verbose=F))
}

# inspection error
detach(package:tm, unload=TRUE)
myRules1 <- myARMlived(colicDataARM, 0.9, 0.001, 2, 4)
myRules2 <- myARMlived(colicDataARM, 0.9, 0.07, 2, 4)
myRules3 <- myARMlived(colicDataARM, 0.95, 0.05, 2, 4)
# inspect the rules
inspect(myRules1[1:25])
inspect(myRules2[1:25])
inspect(myRules3[1:25])

# Best set of rules
myRules4 <- myARMlived(colicDataARM, 0.9, 0.20, 2, 5)
inspect(myRules4[1:25])

# died rules
myRules5 <- myARMdied(colicDataARM, 0.9, 0.001, 2, 4)
myRules6 <- myARMdied(colicDataARM, 0.9, 0.07, 2, 4)
myRules7 <- myARMdied(colicDataARM, 0.95, 0.05, 2, 4)
# inspect the rules
inspect(myRules5[1:25])
inspect(myRules6[1:25])
inspect(myRules7[1:25])

# Best set of rules
myRules8 <- myARMdied(colicDataARM, 0.9, 0.05, 2, 5)
inspect(myRules8[1:25])

myRules <- myRules4
myRules <- myRules8

## sorted
SortedmyRules_conf <- sort(myRules, by="confidence", decreasing=TRUE)
inspect(SortedmyRules_conf[1:20])

SortedmyRules_sup <- sort(myRules, by="support", decreasing=TRUE)
inspect(SortedmyRules_sup[1:20])

SortedmyRules_lift <- sort(myRules, by="lift", decreasing=TRUE)
inspect(SortedmyRules_lift[1:20])

# ----------------------------------------------------------------------------------------------------------------------
# Visualize the Rules
plot (SortedmyRules_sup[1:8],method="graph",interactive=TRUE,shading="support") 
plot (SortedmyRules_lift[1:5], method="graph", interactive=TRUE, shading="lift")
plot (SortedmyRules_conf[1:5],method="graph",interactive=TRUE,shading="confidence") 
arulesViz::plotly_arules(SortedmyRules_conf[1:20])
arulesViz::plotly_arules(SortedmyRules_sup[1:10])
arulesViz::plotly_arules(SortedmyRules_lift[1:10])

# ----------------------------------------------------------------------------------------------------------------------
# Naive Bayes
#split data into training and test data sets - these can be used for each test (nb, svm, lm)
indxTrain <- createDataPartition(y = colicData$outcome,p = 0.75,list = FALSE)
training <- colicData[indxTrain,]
testing <- colicData[-indxTrain,]

#Check dimensions of the split
prop.table(table(colicData$outcome)) * 100
prop.table(table(training$outcome)) * 100
prop.table(table(testing$outcome)) * 100

#create objects x which holds the predictor variables and y which holds the response variables
y = training$outcome
x = training[,-22] #remove outcome

# best Accuracy is with 5
model <- train(x,y,"nb",trControl=trainControl(method="cv",number=5))
model

nb<-naiveBayes(outcome~., data = training, laplace = 0, na.action = na.pass)

#Model Evaluation
#Predict testing set
nbPredict <- predict(nb, newdata = testing)
nbPredict <- predict(nb, newdata = testing , type=c("class", "raw"), lplace = 1, threshold=0.0001, eps=0)

#Get the confusion matrix to see accuracy value and other parameter values

nbCM <- confusionMatrix(nbPredict, testing$outcome )
nbCM$table
sum(diag(nbCM$table)) / sum(nbCM$table)
# shows an accuracy of 66.67% (about the same as the decision tree)

#-------------------------------------------------------------------------------------------------------------
# Naive Bayes
# Create k-folds for k-fold cross validation 
# code used from code provided by Jeremy Bolton, Professor at Syracuse University
## Number of observations
N <- nrow(colicData)
## Number of desired splits
kfolds <- 4
## Generate indices of holdout observations
## Note if N is not a multiple of folds you will get a warning, but is OK.
# these are sets of observations to use as samples - there are 10 sets
holdout <- split(sample(1:N), 1:kfolds)
head(holdout)

#Run training and Testing for each of the k-folds
# naive bayes for kfolds
AllResultsNB<-list()
AllLabelsNB<-list()

for (k in 1:kfolds)
  {
    # grab a set to be Test set
  colicData_Test <- colicData[holdout[[k]], ]
  colicData_Train <- colicData[-holdout[[k]], ]
  ## View the created Test and Train sets
  (head(colicData_Train))
  (table(colicData_Test$outcome))
  ## Make sure you take the labels out of the testing data
  (head(colicData_Test))
  # this needs to remove outcome, 
  colicData_Test_noOutcome <- subset(colicData_Test, select = -outcome)
  colicData_Test_justOutcome <- colicData_Test$outcome
  (head(colicData_Test_noOutcome))
  
  #### Naive Bayes prediction ussing e1071 package
  #Naive Bayes Train model
  train_naibayes<-naiveBayes(outcome~., data=colicData_Train, na.action = na.pass)
  train_naibayes
  #summary(train_naibayes)
  
  #Naive Bayes model Prediction 
  nb_Pred <- predict(train_naibayes, colicData_Test_noOutcome)
  nb_Pred
  
  #Testing accurancy of naive bayes model 
  (confusionMatrix(nb_Pred, colicData_Test$outcome))
  
  # Accumulate results from each fold, if you like
  AllResultsNB<- c(AllResultsNB,nb_Pred)
  AllLabelsNB<- c(AllLabelsNB, colicData_Test_justOutcome)
  
}

### end crossvalidation -- present results for all folds   
nb_table <- table(unlist(AllResultsNB),unlist(AllLabelsNB))
# test accuracy
print(paste('Accuracy for CV Naive Bayes', sum(diag(nb_table)) / sum(nb_table)))

# code used from code provided by Jeremy Bolton, Professor at Syracuse University
## using naivebayes package
## https://cran.r-project.org/web/packages/naivebayes/naivebayes.pdf
NB_object<- naive_bayes(outcome~., data=colicData, laplace=1)
NB_prediction<-predict(NB_object, colicData_Test_noOutcome, type = c("class"))
head(predict(NB_object, colicData_Test_noOutcome, type = "prob"))
NB_Table <- table(NB_prediction,colicData_Test_justOutcome)
sum(diag(NB_Table)) / sum(NB_Table)
print(paste('Accuracy for CV Naive Bayes', sum(diag(NB_Table)) / sum(NB_Table)))

# try NaiveBayes with mlr
#Getting started with Naive Bayes in mlr
#Create a classification task for learning on entire DigitDF dataset (not 10-fold)
task <- makeClassifTask(data = colicData, target = "outcome")
#Initialize the Naive Bayes classifier
selected_model <- makeLearner("classif.naiveBayes")
#Train the model
NB_mlr <- train(selected_model, task)

#Read the model learned  
NB_mlr$learner.model

#Predict on the dataset without passing the target feature
predictions_mlr = as.data.frame(predict(NB_mlr, newdata = colicData_Test_noOutcome))

##Confusion matrix to check accuracy
NB_mlr_table <- table(predictions_mlr[,1],colicData_Test$outcome)
print(paste('Accuracy for MLR Naive Bayes', sum(diag(NB_mlr_table)) / sum(NB_mlr_table)))

# ----------------------------------------------------------------------------------------------------------------------
# SVM
#split data into training and test data sets - these can be used for each test (nb, svm, lm)
indxTrain <- createDataPartition(y = colicData$outcome,p = 0.75,list = FALSE)
training <- colicData[indxTrain,]
testing <- colicData[-indxTrain,]
svm.train <- training
svm.test <- testing

#Check dimensions of the split
prop.table(table(colicData$outcome)) * 100
prop.table(table(training$outcome)) * 100
prop.table(table(testing$outcome)) * 100
KAccMatrix <- NULL

# radial kernel
svm.modelR <- svm(outcome~.,data=svm.train, kernel="radial")
summary(svm.modelR)
svm.test$PredS<-predict(svm.modelR,svm.test, type="votes")
# Compare Observed and Predicted
table.svm <- table(pred = svm.test$PredS,
                   true = svm.test$outcome)/length(svm.test$outcome)
sum(diag(table.svm)) / sum(table.svm)
KAccMatrix <- rbind(KAccMatrix, c("radial", sum(diag(table.svm)) / sum(table.svm)))

# linear kernel
svm.modelL <- svm(outcome~.,data=svm.train, kernel="linear")
summary(svm.modelL)
svm.test$PredS<-predict(svm.modelL,svm.test, type="votes")
# Compare Observed and Predicted
table.svm <- table(pred = svm.test$PredS,
                   true = svm.test$outcome)/length(svm.test$outcome)
sum(diag(table.svm)) / sum(table.svm)
KAccMatrix <- rbind(KAccMatrix, c("linear", sum(diag(table.svm)) / sum(table.svm)))

# sigmoid kernel
svm.modelS <- svm(outcome~.,data=svm.train, kernel="sigmoid")
summary(svm.modelS)
svm.test$PredS<-predict(svm.modelS,svm.test, type="votes")
# Compare Observed and Predicted
table.svm <- table(pred = svm.test$PredS,
                   true = svm.test$outcome)/length(svm.test$outcome)
sum(diag(table.svm)) / sum(table.svm)
KAccMatrix <- rbind(KAccMatrix, c("sigmoid", sum(diag(table.svm)) / sum(table.svm)))

# polynomial kernel
svm.modelP <- svm(outcome~.,data=svm.train, kernel="polynomial")
summary(svm.modelP)
svm.test$PredS<-predict(svm.modelP,svm.test, type="votes")
# Compare Observed and Predicted
table.svm <- table(pred = svm.test$PredS,
                   true = svm.test$outcome)/length(svm.test$outcome)
sum(diag(table.svm)) / sum(table.svm)
KAccMatrix <- rbind(KAccMatrix, c("polynomial", sum(diag(table.svm)) / sum(table.svm)))
colnames(KAccMatrix) <- c("Kernel", "Accuracy")

# linear kernel - using limited variables
svm.modelL <- svm(outcome~lesion1A+lesion1B+lesion1D+pain+rectal_exam_feces+rectal_temp+temp_of_extremities+total_protein,
                  data=svm.train, kernel="linear")
summary(svm.modelL)
svm.test$PredS<-predict(svm.modelL,svm.test, type="votes")
# Compare Observed and Predicted
table.svm <- table(pred = svm.test$PredS,
                   true = svm.test$outcome)/length(svm.test$outcome)
sum(diag(table.svm)) / sum(table.svm)
KAccMatrix <- rbind(KAccMatrix, c("linear", sum(diag(table.svm)) / sum(table.svm)))

# played around with trying to do RSME
compTable <- data.frame(svm.test$outcome,svm.test$PredS)
colnames(compTable) <- c("truth", "estimate")
compTable$truth <- convertOutcome(compTable$truth)
compTable$estimate <- convertOutcome(compTable$estimate)
# this is the RMSE (how low)
RSMEsvm<-sqrt(mean((compTable$truth-compTable$estimate)^2))
RSMEsvm

# ----------------------------------------------------------------------------------------------------------------------
# REGRESSION ANALYSIS 
# first convert the "y" to numeric with convertOutcome function
colicDataLM <- colicData
colicDataLM$outcome <- convertOutcome(colicDataLM$outcome)
allTopReg <- lm(outcome ~., data = colicDataLM)
top.model <- summary(allTopReg)
top.model$adj.r.squared
# see which have p-value less than 0.07
good_vars <- which(top.model$coefficients[,4] <= 0.07)
coeff_df <- NULL
iVar <- 1
trows <- length(good_vars)
coeffs <- top.model$coefficients
while (iVar <= trows)
{
  grow <- good_vars[iVar]
  coeff_df <- rbind(coeff_df, c(rownames(coeffs)[grow], top.model$coefficients[grow,4]))
  iVar <- iVar + 1
}
coeeff_df <- data.frame(coeff_df)
colnames(coeff_df) <- c("variable", "p-value")

# step through to find best model
TopAICModel <- step(allTopReg, data=colicDataLM, direction="backward")
# AIC Results
#Step:  AIC=-672.79
#outcome ~ age + respiratory_rate + temp_of_extremities + mucous_membrane + 
#  capillary_refill_time + pain + packed_cell_volume + total_protein + 
#  abdomo_protein + cp_data + lesion1A + lesion1B + lesion1C + 
#  lesion1D

BestTopModel <- lm(outcome ~ age + respiratory_rate + temp_of_extremities + mucous_membrane + 
                     capillary_refill_time + pain + packed_cell_volume + total_protein + 
                     abdomo_protein + cp_data + lesion1A + lesion1B + lesion1C + 
                     lesion1D, data=colicDataLM)
summary(BestTopModel)

# output the data in a more readable format
#stargazer(BestlmModel, allReg, type="text", title="Linear Regression Output", align=TRUE)
SG <- stargazer(BestTopModel, type="text", title="Linear Regression Output", align=TRUE)

# try with glm instead of lm
GLM.Model <- glm(outcome ~ age + respiratory_rate + temp_of_extremities + mucous_membrane + 
                    capillary_refill_time + pain + packed_cell_volume + total_protein + 
                    abdomo_protein + cp_data + lesion1A + lesion1B + lesion1C + 
                    lesion1D, data=colicDataLM)
summary(GLM.Model)
# AIC of 157.87
summary.GLM.Model <- summary(GLM.Model)
stargazer(GLM.Model, type="text", title="Linear Regression Output", align=TRUE)

# Linear Regression Prediction
# create a test set
RSMEsvm_matrix <- NULL
indxTrain <- createDataPartition(y = colicDataLM$outcome,p = 0.75,list = FALSE)
training <- colicDataLM[indxTrain,]
testing <- colicDataLM[-indxTrain,]
lm.train <- training
lm.test <- testing

# Predict and RSME for Best Linear Model
lmPred <- predict(BestTopModel, lm.test, type="response")
lmPred <- data.frame(lmPred)
# compute absolute error for each case
# create new dataframe for plotting
compTable <- data.frame(lm.test$outcome,lmPred[,1])
colnames(compTable) <- c("test", "predicted")
compTable$error <- abs(compTable$test - compTable$predicted)
colnames(compTable) <- c("test", "predicted", "error")
RSMEsvm<-sqrt(mean((compTable$test-compTable$predicted)^2))
RSMEsvm_matrix <- rbind(RSMEsvm_matrix, c("Linear Regression Model", RSMEsvm))

# Predict and RSME for Best GLM Model
lmPred <- predict(GLM.Model, lm.test, type="response")
lmPred <- data.frame(lmPred)
# compute absolute error for each case
# create new dataframe for plotting
compTable <- data.frame(lm.test$outcome,lmPred[,1])
colnames(compTable) <- c("test", "predicted")
compTable$error <- abs(compTable$test - compTable$predicted)
colnames(compTable) <- c("test", "predicted", "error")
RSMEsvm<-sqrt(mean((compTable$test-compTable$predicted)^2))
RSMEsvm_matrix <- rbind(RSMEsvm_matrix, c("Best GLM Model", RSMEsvm))

lmPlot <- data.frame(compTable$error, compTable$test, compTable$predicted)
colnames(lmPlot) <- c("Error", "Outcome", "Predicted")
plotlm1 <- ggplot(lmPlot, aes(x=Outcome, y=Predicted)) +
  geom_point(aes(size=Error, color=Error)) +
  ggtitle("Linear Regression with Outcome and Predicted") +
  xlab("Outcome") + ylab("Predicted")
plotlm1

# plot with Total Protein and Packed Cell Volume
# change the scale
lmPlot <- data.frame(compTable$error, lm.test$pain, lm.test$packed_cell_volume, lm.test$total_protein)
colnames(lmPlot) <- c("error", "pain", "packed_cell_volume", "total_protein")
plotlm2 <- ggplot(lmPlot, aes(x=packed_cell_volume, y=total_protein)) +
  geom_point(aes(size=error, color=pain)) +
  ggtitle("Linear Regression with Total Protein, Packed Cell Volume and Pain") +
  xlab("Packed Cell Volume") + ylab("Total Protein")
plotlm2

# plot with Total Protein and Packed Cell Volume
# change the scale
lmPlot <- data.frame(compTable$error, lm.test$total_protein, lm.test$packed_cell_volume, lm.test$respiratory_rate)
colnames(lmPlot) <- c("error", "total_protein", "packed_cell_volume", "respiratory_rate")
plotlm3 <- ggplot(lmPlot, aes(x=total_protein, y=respiratory_rate)) +
  geom_point(aes(size=error, color=packed_cell_volume)) +
  ggtitle("Linear Regression with Total Protein, Packed Cell Volume and Respiratory Rate") +
  xlab("Total Protein") + ylab("Respiratory Rate")
plotlm3

lmPlot <- data.frame(compTable$error, lm.test$total_protein, lm.test$rectal_exam_feces, lm.test$abdomen)
colnames(lmPlot) <- c("error", "total_protein", "rectal_exam_feces", "abdomen")
plotlm4 <- ggplot(lmPlot, aes(x=abdomen, y=total_protein)) +
  geom_point(aes(size=error, color=rectal_exam_feces)) +
  ggtitle("Linear Regression with Total Protein, Feces and Abdomen") +
  xlab("Abdomen") + ylab("Total Protein")
plotlm4

coefficients(BestTopModel) # model coefficients
confint(BestTopModel, level=0.95) # CIs for model parameters

# ---------------------------------------------------------------------------------------------
# 1. Perform a logit analysis 
# outcome is a factor variable showing if a horse died, lived or was euthanized
# using this variable, we will use the logit model to determine the logistics regression model
# using 'glm' to predict if a loan will be issued or not
# step through
mylogit <- glm(outcome ~ ., data=colicData, family=binomial(logit))
TopAICm <- step(mylogit, data=colicData, direction="backward")
# AIC Results
#Step:  AIC=180.71
#outcome ~ surgery + age + rectal_temp + respiratory_rate + temp_of_extremities + 
#  capillary_refill_time + pain + peristalsis + abdominal_distention + 
#  nasogastric_tube + nasogastric_reflux + nasogastric_reflux_ph + 
#  rectal_exam_feces + abdomen + packed_cell_volume + total_protein + 
#  abdomo_protein + surgical_lesion + cp_data + lesion1A + lesion1D

BestglmModel <- glm(outcome ~ surgery + age + rectal_temp + respiratory_rate + temp_of_extremities + 
                      capillary_refill_time + pain + peristalsis + abdominal_distention + 
                      nasogastric_tube + nasogastric_reflux + nasogastric_reflux_ph + 
                      rectal_exam_feces + abdomen + packed_cell_volume + total_protein + 
                      abdomo_protein + surgical_lesion + cp_data + lesion1A + lesion1D, 
                    data=colicData, family = binomial(logit))
summary(BestglmModel)

# do some Prediction
indxTrain <- createDataPartition(y = colicData$outcome,p = 0.75,list = FALSE)
training <- colicData[indxTrain,]
testing <- colicData[-indxTrain,]
lm.train <- training
lm.test <- testing

lmPred <- predict(BestglmModel, lm.test, type="response")
lmPred <- data.frame(lmPred)
# compute absolute error for each case
# create new dataframe for plotting
compTable <- data.frame(lm.test$outcome,lmPred[,1])
colnames(compTable) <- c("test", "predicted")
# update test with numeric outcome
compTable$test <- convertOutcome(compTable$test)
compTable$error <- abs(compTable$test - compTable$predicted)
colnames(compTable) <- c("test", "predicted", "error")
RSMEsvm<-sqrt(mean((compTable$test-compTable$predicted)^2))
RSMEsvm_matrix <- rbind(RSMEsvm_matrix, c("Logit Model", RSMEsvm))

# reviewing the p-values, drop surgery, rectal_temp, respiratory_rate and see what happens
BestglmModel2 <- glm(outcome ~ age + temp_of_extremities + 
                      capillary_refill_time + pain + peristalsis + abdominal_distention + 
                      nasogastric_tube + nasogastric_reflux + nasogastric_reflux_ph + 
                      rectal_exam_feces + abdomen + packed_cell_volume + total_protein + 
                      abdomo_protein + surgical_lesion + cp_data + lesion1A + lesion1D, 
                    data=colicData, family = binomial(logit))
summary(BestglmModel2)

lmPred <- predict(BestglmModel2, lm.test, type="response")
lmPred <- data.frame(lmPred)
# compute absolute error for each case
# create new dataframe for plotting
compTable <- data.frame(lm.test$outcome,lmPred[,1])
colnames(compTable) <- c("test", "predicted")
# update test with numeric outcome
compTable$test <- convertOutcome(compTable$test)
compTable$error <- abs(compTable$test - compTable$predicted)
colnames(compTable) <- c("test", "predicted", "error")
RSMEsvm<-sqrt(mean((compTable$test-compTable$predicted)^2))
RSMEsvm_matrix <- rbind(RSMEsvm_matrix, c("Refined Logit Model", RSMEsvm))

# probit model
# AIC Best Model
myprobit <- glm(outcome~., data=colicData, family=binomial(probit))
TopAICp <- step(myprobit, data=colicDataLM, direction="backward")

# Best Probit
# Step:  AIC=183.49
#outcome ~ age + pulse + respiratory_rate + temp_of_extremities + 
#  peripheral_pulse + mucous_membrane + capillary_refill_time + 
#  pain + peristalsis + abdominal_distention + nasogastric_reflux + 
#  nasogastric_reflux_ph + rectal_exam_feces + abdomen + packed_cell_volume + 
#  total_protein + abdomo_protein + surgical_lesion + cp_data + 
#  lesion1A + lesion1C + lesion1D

Best.probit <- glm(outcome ~ age + pulse + respiratory_rate + temp_of_extremities + 
                     peripheral_pulse + mucous_membrane + capillary_refill_time + 
                     pain + peristalsis + abdominal_distention + nasogastric_reflux + 
                     nasogastric_reflux_ph + rectal_exam_feces + abdomen + packed_cell_volume + 
                     total_protein + abdomo_protein + surgical_lesion + cp_data + 
                     lesion1A + lesion1C + lesion1D, family=binomial(probit), data=colicDataLM)

summary(Best.probit)

lmPred <- predict(Best.probit, lm.test, type="response")
lmPred <- data.frame(lmPred)
# compute absolute error for each case
# create new dataframe for plotting
compTable <- data.frame(lm.test$outcome,lmPred[,1])
colnames(compTable) <- c("test", "predicted")
# update test with numeric outcome
compTable$test <- convertOutcome(compTable$test)
compTable$error <- abs(compTable$test - compTable$predicted)
colnames(compTable) <- c("test", "predicted", "error")
RSMEsvm<-sqrt(mean((compTable$test-compTable$predicted)^2))
RSMEsvm_matrix <- rbind(RSMEsvm_matrix, c("Best Probit Model", RSMEsvm))
colnames(RSMEsvm_matrix) <- c("Model Type", "RSME")

# test for linearity
Ramsey <- resettest(outcome ~ age + pulse + respiratory_rate + temp_of_extremities + 
  peripheral_pulse + mucous_membrane + capillary_refill_time + 
  pain + peristalsis + abdominal_distention + nasogastric_reflux + 
  nasogastric_reflux_ph + rectal_exam_feces + abdomen + packed_cell_volume + 
  total_protein + abdomo_protein + surgical_lesion + cp_data + 
  lesion1A + lesion1C + lesion1D, power = 2:3, type = "regressor", data=colicDataLM)
Ramsey
# results show p-value < 0.05 so no linearity issues

# Variance Inflation Factor (car package)
vif(Best.probit)
# Results from vif
# lesion1C significantly larger than 10 at 299 so probably would be dropped - shows multicollinearity

# Breusch-Pagan test of heteroscedasticity
# get error on "atomic vectors"
outlierTest(BestglmModel)
# Results for outlierTest is to eliminate horse 246 from the data as it is an outlier
# rstudent unadjusted p-value Bonferonni p


#--------------------------------------------------------------------------------------------
# neural network
# using entire set
colicNNet <- neuralnet(outcome ~ age + pulse + respiratory_rate + temp_of_extremities + 
                         peripheral_pulse + mucous_membrane + capillary_refill_time + 
                         pain + peristalsis + abdominal_distention + nasogastric_reflux + 
                         nasogastric_reflux_ph + rectal_exam_feces + abdomen + packed_cell_volume + 
                         total_protein + abdomo_protein + surgical_lesion + cp_data + 
                         lesion1A + lesion1C + lesion1D, colicDataLM, hidden=2, lifesign="minimal",
                       linear.output=FALSE, threshold=0.1)


# neural Network without factor variables
colicNNetA <- neuralnet(outcome ~ rectal_temp + pulse + packed_cell_volume + total_protein
                       + abdomo_protein + nasogastric_reflux_ph, colicDataLM, hidden=2, lifesign="minimal",
                       linear.output=FALSE, threshold=0.1)

plot(colicNNetA)

abc <- data.frame(colicNNetA$result.matrix)
abc
# shows error
abc[1,1]



