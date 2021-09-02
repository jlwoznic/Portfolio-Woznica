# ----------------------------------------------------------------------------------------------------------------------
# Naive Bayes

#split data into training and test data sets
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
model <- train(x,y,'nb',trControl=trainControl(method='cv',number=5))
model

nb<-naiveBayes(outcome~., data = training, laplace = 0, na.action = na.pass)

#Model Evaluation
#Predict testing set
#Predict <- predict(model,newdata = testing , type=c("class", "raw"), threshold=0.01, eps=0)
nbPredict <- predict(nb, newdata = testing)
nbPredict <- predict(nb, newdata = testing , type=c("class", "raw"), lplace = 1, threshold=0.0001, eps=0)

#Get the confusion matrix to see accuracy value and other parameter values

nbCM <- confusionMatrix(nbPredict, testing$outcome )
nbCM$table
sum(diag(nbCM$table)) / sum(nbCM$table)
# shows an accuracy of 79% (better than decision tree)

#Plot Variable performance
# plot difference or probabilities?

# ----------------------------------------------------------------------------------------------------------------------
# SVM
# SVM, KSVM, NB
# a new method for sampling the data for SVM and NB
# ** Due to the time it takes to run this output - I elected to take a random sample of 15,000 of the TrainData
# ** and 5,000 of the test data to test this model
svm.train <- satSurvey[sample(nrow(satSurvey), size=15000, replace=FALSE),]
table(svm.train$Satisfaction)/length(svm.train$Satisfaction)

svm.test <- satSurvey[sample(nrow(satSurvey), size=5000, replace=FALSE),]
nb.test <- satSurvey[sample(nrow(satSurvey), size=5000, replace=FALSE),]
ksvm.test <- satSurvey[sample(nrow(satSurvey), size=5000, replace=FALSE),]
lm.test <- satSurvey[sample(nrow(satSurvey), size=5000, replace=FALSE),]

table(svm.test$Satisfaction)/length(svm.test$Satisfaction)

# Linear Regression Prediction
lmPred <- predict(Final.Model, lm.test, type="response")
lmPred <- data.frame(lmPred)
compTable <- data.frame(lm.test[,1],lmPred[,1])
colnames(compTable) <- c("test", "Pred")
# this is the RMSE (how low)
RSMElm<-sqrt(mean((compTable$test-compTable$Pred)^2))
RSMElm

# plot some LM results
# compute absolute error for each case
compTable$error <- abs(compTable$test - compTable$Pred)
# create new dataframe for plotting
lmPlot <- data.frame(compTable$error, lm.test$PriceSens, lm.test$Status)
colnames(lmPlot) <- c("error", "PriceSens", "Status")
plotlm1 <- ggplot(lmPlot, aes(x=PriceSens, y=Status)) +
  geom_point(aes(size=error, color=error)) +
  ggtitle("Linear Regression with Price Sensitivity and Loyalty Status") +
  xlab("Price Sensitivity") + ylab("Loyalty Card Status")
plotlm1

lmPlot <- data.frame(compTable$error, lm.test$TravelType, lm.test$Status, lm.test$PriceSens)
colnames(lmPlot) <- c("error", "TravelType", "Status", "PriceSens")
plotlm2 <- ggplot(lmPlot, aes(x=PriceSens, y=Status)) +
  geom_point(aes(size=error, color=TravelType)) +
  ggtitle("Linear Regression with Price Sensitivity, Travel Type and Loyalty Status") +
  xlab("Price Sensitivity") + ylab("Loyalty Card Status")
plotlm2

lmPlot <- data.frame(compTable$error, lm.test$DeptDelayMins, lm.test$ArrDelayMins, lm.test$SchDeptHour)
colnames(lmPlot) <- c("error", "DeptDelay", "ArrivalDelay", "ScheduledDept")
plotlm3 <- ggplot(lmPlot, aes(x=DeptDelay, y=ArrivalDelay)) +
  geom_point(aes(size=error, color=ScheduledDept)) +
  ggtitle("Linear Regression with Departure and Arrival Delays and Scheduled Departure Hour") +
  xlab("Departure Delay in Minutes") + ylab("Arrival Delay in Minutes")
plotlm3

# change the scale
plotlm3 <- ggplot(lmPlot, aes(x=DeptDelay, y=ArrivalDelay)) +
  geom_point(aes(size=error, color=ScheduledDept)) +
  ggtitle("Linear Regression with Departure and Arrival Delays and Scheduled Departure Hour") +
  scale_x_continuous(limits=c(0,450)) + scale_y_continuous(limits=c(0,500)) +
  xlab("Departure Delay in Minutes") + ylab("Arrival Delay in Minutes")
plotlm3

# change the scale again
plotlm3 <- ggplot(lmPlot, aes(x=DeptDelay, y=ArrivalDelay)) +
  geom_point(aes(size=error, color=ScheduledDept)) +
  ggtitle("Linear Regression with Departure and Arrival Delays and Scheduled Departure Hour") +
  scale_x_continuous(limits=c(0,200)) + scale_y_continuous(limits=c(0,200)) + 
  xlab("Departure Delay in Minutes") + ylab("Arrival Delay in Minutes")
plotlm3

# SUpport Vector Machine (SVM)
svm.model<- svm(Satisfaction~Status+Age+PriceSens+PercOther+TravelType+Class+DeptDelayMins+ArrDelayMins,data=svm.train)
summary(svm.model)

svm.test$PredS<-predict(svm.model,svm.test, type="votes")
# Compare Observed and Predicted
table.svm <- table(pred = svm.validate$PredS,
                   true = svm.validate$Satisfaction)/length(svm.validate$Satisfaction)

# SVM 
# create prediction
svmPred <- predict(svm.model, svm.test, type="votes")
svmPred <- (data.frame(svmPred))
compTable <- data.frame(svm.test[,1],svmPred[,1])
colnames(compTable) <- c("test", "Pred")
# this is the RMSE (how low)
RSMEsvm<-sqrt(mean((compTable$test-compTable$Pred)^2))
RSMEsvm

# plot some SVM results
# compute absolute error for each case
compTable$error <- abs(compTable$test - compTable$Pred)
# create new dataframe for plotting
# Reflected in Figure 33
svmPlot <- data.frame(compTable$error, svm.test$PriceSens, svm.test$Status)
colnames(svmPlot) <- c("error", "PriceSens", "Status")
plotsvm1 <- ggplot(svmPlot, aes(x=PriceSens, y=Status)) +
  geom_point(aes(size=error, color=error)) +
  ggtitle("Support Vector Machine with Price Sensitivity and Loyalty Status") +
  xlab("Price Sensitivity") + ylab("Loyalty Card Status")
plotsvm1

svmPlot <- data.frame(compTable$error, svm.test$TravelType, svm.test$Status, svm.test$PriceSens)
colnames(svmPlot) <- c("error", "TravelType", "Status", "PriceSens")
plotsvm2 <- ggplot(svmPlot, aes(x=PriceSens, y=Status)) +
  geom_point(aes(size=error, color=TravelType)) +
  ggtitle("Support Vector Machine with Price Sensitivity, Travel Type and Loyalty Status") +
  xlab("Price Sensitivity") + ylab("Loyalty Card Status")
plotsvm2

svmPlot <- data.frame(compTable$error, svm.test$DeptDelayMins, svm.test$ArrDelayMins, svm.test$SchDeptHour)
colnames(svmPlot) <- c("error", "DeptDelay", "ArrivalDelay", "ScheduledDept")
plotsvm3 <- ggplot(svmPlot, aes(x=DeptDelay, y=ArrivalDelay)) +
  geom_point(aes(size=error, color=ScheduledDept)) +
  ggtitle("Support Vector Machine with Departure and Arrival Delays and Scheduled Departure Hour") +
  scale_x_continuous(limits=c(0,200)) + scale_y_continuous(limits=c(0,200)) + 
  xlab("Departure Delay in Minutes") + ylab("Arrival Delay in Minutes")
plotsvm3

# Naive Bayes
nb.train <- satSurvey[sample(nrow(satSurvey), size=3000, replace=FALSE),]
nb.test <- satSurvey[sample(nrow(satSurvey), size=1000, replace=FALSE),]

nbOutput <- naiveBayes(Satisfaction~Age+PriceSens+PercOther,
                       data=nb.train)
str(nbOutput)
# create prediction
nbPred <- predict(nbOutput, nb.test)
nbPred <- as.data.frame(nbPred)
str(nbPred)
compTable <- data.frame(nb.test[,1],nbPred[,1])
colnames(compTable) <- c("test", "Pred")
# this is the RSME
RSMEnb <- sqrt(mean(compTable$test-compTable$Pred)^2)
RSMEnb

RSME.frame<-NULL
RSME.frame <- c(RSMEsvm, RSMElm, RSMEksvm)
RSME.frame<-melt(RSME.frame)
RSME.frame$model <- c("RSMEsvm", "RSMElm", "RSMEksvm")
g <- ggplot(data=RSME.frame, aes(x=model, y=value))
g <- g + geom_bar(stat="identity", position="dodge")
g <- g + ggtitle("RSME Values by Model Type")
g <- g + xlab("RSME Model") + ylab("RSME Value")
g

# ----------------------------------------------------------------------------------------------------------------------
# REGRESSION ANALYSIS
# Just some test regressions on certain variables to see how they are correlated, if at all
# Reflected in Figure 23
testReg1 <- lm(satSurvey$Satisfaction ~ satSurvey$FlightMins)
summary(testReg1)

# Reflected in Figure 24
testReg2 <- lm(satSurvey$Satisfaction ~ satSurvey$Status)
s.model <- summary(testReg2)
# Reflected in Figure 24
testReg3 <- lm(satSurvey$Satisfaction ~ satSurvey$NumFlights)
s.model <- summary(testReg3)
# Reflected in Figure 24
testReg4 <- lm(satSurvey$Satisfaction ~ satSurvey$PriceSens)
s.model <- summary(testReg4)


coefficients(testReg1) # model coefficients
confint(testReg1, level=0.95) # CIs for model parameters

# create a smaller dataframe of the top 3 airlines based on mean satisfaction
topAsatSurvey1 <- as.data.frame(subset(satSurvey, AirlineCode == "VX"))
topAsatSurvey2 <- as.data.frame(subset(satSurvey, AirlineCode == "HA"))
topAsatSurvey3 <- as.data.frame(subset(satSurvey, AirlineCode =="AS"))
topAsatSurvey <- rbind(topAsatSurvey1, topAsatSurvey2, topAsatSurvey3)

allTopReg <- lm(topAsatSurvey$Satisfaction ~., data = as.data.frame(topAsatSurvey))
top.model <- summary(allTopReg)
top.model$adj.r.squared
TopAICModel <- step(allTopReg, data=topAsatSurvey, direction="backward")
# AIC Results
#Step:  AIC=-4362.92
#topAsatSurvey$Satisfaction ~ Status + Age + Gender + PriceSens + 
#  FFYear + PercOther + TravelType + AirlineCode + SchDeptHour + 
#  Cancelled + ArrDelayGT5
# Reflected Figure 25
BestTopModel <- lm(formula=topAsatSurvey$Satisfaction ~ Status + Age + Gender + PriceSens + 
                     FFYear + PercOther + TravelType + AirlineCode + SchDeptHour + 
                     Cancelled + ArrDelayGT5, data = as.data.frame(topAsatSurvey))
summary(BestTopModel)

# output the data in a more readable format
#stargazer(BestlmModel, allReg, type="text", title="Linear Regression Output", align=TRUE)
SG <- stargazer(BestTopModel, type="text", title="Linear Regression Output", align=TRUE)

# look at linear regression on all variables
# this is useless - want a Multiple R-squared and p-value for those that matter!
# multiple linear regression to see if the multiple R-squared show correlation
# and review the p-values
allReg <- lm(satSurvey$Satisfaction ~., data=as.data.frame(satSurvey))
s.model <- summary(allReg)
s.model$coef[,4]
s.model$adj.r.squared

# step through to get the best model
AICModels<-step(allReg,data=satSurvey, direction="backward")
#AIC Results were as follows:
# Call:
#  lm(formula = satSurvey$Satisfaction ~ Status + Age + Gender + 
#       PriceSens + FFYear + PercOther + TravelType + ShopAmount + 
#       EatDrink + Class + SchDeptHour + Cancelled + ArrDelayGT5, 
#     data = as.data.frame(satSurvey))
# AIC = -85696.57
BestlmModel <- lm(formula = satSurvey$Satisfaction ~ Status + Age + Gender + 
                    PriceSens + FFYear + PercOther + TravelType + ShopAmount + 
                    EatDrink + Class + SchDeptHour + Cancelled + ArrDelayGT5, 
                  data = as.data.frame(satSurvey))
summary(BestlmModel)

Final.Model <- lm(formula = satSurvey$Satisfaction ~ Status + Age + Gender + 
                    PriceSens + FFYear + PercOther + TravelType + ShopAmount + 
                    Class + SchDeptHour + Cancelled + ArrDelayGT5, 
                  data = as.data.frame(satSurvey))
summary(Final.Model)

# output the data in a more readable format
#stargazer(BestlmModel, allReg, type="text", title="Linear Regression Output", align=TRUE)
stargazer(Final.Model, type="text", title="Linear Regression Output", align=TRUE)
summary.Model<- summary(Final.Model)
