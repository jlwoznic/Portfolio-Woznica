# 
# Course: SCM 651
# Name: Team 73
# Homework #4
# Code: Loan Analysis - Main Code
# Due Date: 06/02/2019
#

# ----------------------------------------------------------------------------------------------------------------------
# DESCRIPTIVE STATISTICS
# from pastecs package
# only works on numeric variables in the set
# I did not find this useful
# Reflected in Figure 3 
# show general descriptive statistics of the data
summary(bankDF)
# show standard deviations of each variable
sapply (bankDF, sd)


# ---------------------------------------------------------------------------------------------------------------
# DESCRIPTIVE STATISTICS
# from pastecs package
# only works on numeric variables in the set
# NOT USEFUL
genStat <- stat.desc(bankDF, basic=F)
View(genStat)

# overall description (lengthy)
describe(bankDF)

test<-as.matrix(bankDF)
# Reflected in Figure 2 
summary(test)

# descriptive statistics from using stargazer package
stargazer(bankDF, type="text")

# ---------------------------------------------------------------------------------------------
# 1. Perform a logit analysis 
# PersonalLoan is a binary variable showing if a loan was issued (1) or not (0)
# using this variable, we will use the logit model to determine the logistics regression model
# using 'glm' to predict if a loan will be issued or not
mylogit <- glm(PersonalLoan ~ Age + Experience + Income + ZIP.Code + Family + CCAvg + 
                 Education + Mortgage + SecuritiesAccount + CDAccount + Online + CreditCard, 
               data = bankDF, family = "binomial")

# force no scientific notation
options(scipen=999)

# show the summary of this information
summary(mylogit)

confint(mylogit, level=0.95) # CIs for model parameters

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








# find the mean satisfaction by airline
airlineSatmeans<- ddply(satSurvey, .(Airline), summarize, SatValue = mean(Satisfaction))
# Reflected in Figure 7
newASM <-airlineSatmeans[order(-airlineSatmeans$SatValue),]
newASM
# Reflected in Figure 6
summary(airlineSatmeans)
range(airlineSatmeans$SatValue)

# from gmodels package - not right for this, but just playing around with statiistics
chisq.test(satSurvey$Gender,satSurvey$Satisfaction)

# ----------------------------------------------------------------------------------------------------------------------
# INITIAL VISUALIZATION
# Plot the Mean Satisfaction Rate by Airline
# Reflected in Figure 8
g <- ggplot(newASM) 
g <- g + geom_bar( aes(x = reorder(Airline, -SatValue), y=SatValue), stat="identity", fill="blue", alpha=0.7) 
g <- g + theme(axis.text.x = element_text(angle = 45, hjust = 1))
g <- g + scale_y_continuous(name="Satisfaction Rating", limits=c(0, 3.75), breaks=seq(0,4,.15))
g <- g + ggtitle("Average Satisfaction Rating by Airline")
g <- g + xlab("Airline")
g

# satisfaction mean by location (state) - Origination
OrigState.means<- ddply(satSurvey, .(OrigState), summarize, SatValue = mean(Satisfaction))
colnames(OrigState.means)<- c("State", "OrigStateSat")
Ordered.OS.SatMeans <- OrigState.means[order(-OrigState.means$OrigStateSat),]

# satisfaction mean by location (state) - Destination
DestState.means<- ddply(satSurvey, .(DestState), summarize, SatValue = mean(Satisfaction))
colnames(DestState.means)<- c("State", "DestStateSat")
Ordered.DS.SatMeans <- DestState.means[order(-DestState.means$DestStateSat),]
StateSatdf <- merge(OrigState.means, DestState.means, by = "State")

# Melt for plotting
# Refected in Figure 14
meltedStatedf <- melt(StateSatdf, id.vars = "State")
g <- ggplot(meltedStatedf, aes(x=State, y=value, fill=variable))
g <- g + geom_bar(stat='identity', position='dodge')
g <- g + theme(axis.text.x = element_text(angle = 90, hjust = 1))
g <- g + ggtitle("Average Satisfaction Rating by State")
g <- g + xlab("State") + ylab("Satisfaction Rating")
g

# Some initial plotting of the data to see what we have
# maybe try sampling data from our set (maybe 1000 values) and using that
testS<-sample(satSurvey$Satisfaction,1000,replace=FALSE)
testDD<-sample(satSurvey$DeptDelayMins,1000, replace=FALSE)
testdf<-data.frame(testS,testDD)
plot(testS,testDD)

# Plotting a sample of 1000 items of Satisfaction and Departure Delays
# Reflected in Figure 15
g <- ggplot(testdf, aes(x=testDD, y=testS)) + geom_point()
g <- g + stat_smooth(method= "lm", col="red")
g <- g + ggtitle("Satisfaction Rating by Departure Delay in Minutes")
g <- g + xlab("Departure Delay in Minutes") + ylab("Satisfaction Rating")
g

# Are men or women more satisfied?
# Reflected in Figure 9
g<- ggplot(satSurvey, aes(x=Gender, fill=factor(Satisfaction)))
g<- g+ ggtitle("Satisfaction by Gender")
g<- g+ xlab("Gender") + ylab("Satisfaction Rating")
g<- g + geom_bar(position="dodge")
g

# boxplot male/female by satistfaction
# with boxplot
# do this again with buckets or something!
g<- ggplot(satSurvey, aes(group=Gender,x=Gender,y=Satisfaction)) 
g<- g + geom_boxplot(aes(fill=factor(Gender)))
g<- g + ggtitle("Satisfaction by Gender") + theme(plot.title=element_text(hjust=0.5))
g

# also did against month - just for my own benefit
g<- ggplot(satSurvey, aes(group=AirlineCode,x=AirlineCode,y=Satisfaction)) 
g<- g + geom_boxplot(aes(fill=factor(AirlineCode)))
g<- g + ggtitle("Satisfaction by Airline Code") + theme(plot.title=element_text(hjust=0.5))
g

hist(satSurvey$Satisfaction)
table(satSurvey$Gender)

# which airline has the best satisfaction
# Reflected in Figure 11
g<- ggplot(satSurvey, aes(x=AirlineCode, fill=factor(Satisfaction)))
g<- g + geom_bar(position="dodge")
g<- g+ ggtitle("Satisfaction Rating Frequency by Airline")
g<- g + xlab("Airline Code") + ylab("Frequency of Satisfaction Rating")
g

# Does Travel Type affect Satisfaction?
# Reflected in Figure 19
g<- ggplot(satSurvey, aes(x=TravelType, fill=factor(Satisfaction)))
g<- g + geom_bar(position="dodge")
g<- g+ ggtitle("Airline Satisfaction Rating Frequency by Travel Type")
g<- g+ xlab("Travel Type") + ylab("Satisfaction Rating Frequency")
g

# Does Status affect Satisfaction?
# Reflected in Figure 20
g<- ggplot(satSurvey, aes(x=Status, fill=factor(Satisfaction)))
g<- g + geom_bar(position="dodge")
g<- g+ ggtitle("Airline Satisfaction Rating Frequency by Loyalty Card Status")
g<- g+ xlab("Card Status") + ylab("Satisfaction Rating Frequency")
g

# Does Shopping and Eating in the Airport affect Satisfaction?
# Add scale for y axis
g <- ggplot(satSurvey, aes(x=EatDrink, y = Satisfaction, 
                           fill = ShopAmount))
g <- g + geom_bar(stat = "identity")
g

# maybe plot by age buckets?
# create bins/buckets for box plot
# really want to check by Satisfaction though
# Reflected in Figure 10
plotBuckets<-buildCutOffs(min(satSurvey$Age),max(satSurvey$Age),5)
SatSurvWB <- satSurvey
SatSurvWB$Bucket<-cut(satSurvey$Age,plotBuckets)
g<- ggplot(SatSurvWB)  
g<- g + geom_boxplot(aes(Bucket, Age, fill=factor(Bucket)))
g<- g + ggtitle("Age of Flyers Surveyed") + theme(plot.title=element_text(hjust=0.5))
g<- g + xlab("Age Groupings") + ylab("Satisfaction Value")
g

# now do a line plot against Date for satisfaction
# Does time of year matter?
g <- ggplot(satSurvey, aes(x=FlightDate, y=Satisfaction))
g <- g + geom_line(size=1, color="navy")
g <- g + ylab("Satisfaction")
g <- g + ggtitle("Satisfaction by Date")+theme(plot.title=element_text(hjust=0.5))
g

# Does time of year matter?
g <- ggplot(satSurvey, aes(x=FlightDate, y=Satisfaction))
g <- g + geom_point(size=1, color="orange")
g <- g + ylab("Satisfaction")
g <- g + ggtitle("Satisfaction by Date")+theme(plot.title=element_text(hjust=0.5))
g <- g + xlab("Date of Flight")
g


# data needs to be cleaned for missing values
# Add scale for y axis
g <- ggplot(satSurvey, aes(x=Age, y=Satisfaction, group=Gender ))
g <- g + geom_bar(stat="identity", position="dodge", color="steelblue", 
                  aes(fill=factor(Gender)))
g

# Look at all the data via a scatter plot
#         Create a scatter chart (geom_point), 
#         x-axis is AirlineCode
#         y-axis is Satisfaction
#         dot size represents Status
#         color represents DeptDelayMins
# Reflected in Figure 13
g <- ggplot(satSurvey, aes(x=AirlineCode, y=Satisfaction))
g <- g + geom_point(aes(color=Status, size=DeptDelayMins))
g <- g + ggtitle("Satisfaction versus Airline Code, Status and Delay Minutes")
g <- g + theme(plot.title=element_text(hjust=0.5))
g <- g + xlab("Airline Code") + ylab("Satisfaction Rating")
g

#         Create a scatter chart (geom_point), 
#         x-axis is AirlineCode
#         y-axis is Satisfaction
#         dot size represents ArrDelayMins
#         color represents DeptDelayMins
g <- ggplot(satSurvey, aes(x=AirlineCode, y=Satisfaction))
g <- g + geom_point(aes(color=ArrDelayMins, size=DeptDelayMins))
g <- g + ggtitle("Satisfaction versus Airline Code, Arrival and Delay Minutes")
g <- g + theme(plot.title=element_text(hjust=0.5))
g <- g+ xlab("Airline Code") + ylab("Satisfaction Rating")
g

# Histogram of satisfaction rating vs number of flights
# Reflected in Figure 22
g <- ggplot(satSurvey, aes(x=Satisfaction,y=NumFlights, fill=AirlineCode))
g <- g + geom_bar(stat="identity")
g <- g + ggtitle("Number of Flight Frequency by Airline Satisfaction Rating and Code")
g <- g + xlab("Satisfaction Rating") + ylab("Number of Flight Frequency")
g

# Look at all the data via a scatter plot
#         Create a scatter chart (geom_point), 
#         x-axis is First Flight Year
#         y-axis is Satisfaction
#         dot size represents Number of Flights
#         color represents Flights on other airlines
# Reflected in Figure 21
g <- ggplot(satSurvey, aes(x=FFYear, y=Satisfaction))
g <- g + geom_point(aes(color=PercOther, size=NumFlights))
g <- g + ggtitle("Satisfaction versus First Flight Year, Percentage on Other Airlines, Number of Flights")
g <- g + theme(plot.title=element_text(hjust=1))
g <- g + scale_x_continuous(name="Year of First Flight", limits=c(min(satSurvey$FFYear), max(satSurvey$FFYear)))
g 

# play around with bar graphs
# Reflected in Figure 12
g <- ggplot(satSurvey, aes(x=Satisfaction, y = Age, 
                           fill = AirlineCode))
g <- g + geom_bar(stat = "identity")
g <- g + ggtitle("Satisfaction Rating Frequency by Airline Code and Age")
g

# ----------------------------------------------------------------------------------------------------------------------
# MAP VISUALIZATIONS

us <- map_data("state")

# need to create a new frame - elected to create two frames (one for Orignation Airport, other for Destination Airport)
# Satisfaction
# Origination - which is OrigCity, OrgState (but the state needs to be an abbrevation)
# Destation - which is DestCity, DestState (but the state needs to be an abbreviation)
# first remove all columns except the 3 we need
orig.mapDF <- data.frame(satSurvey$Satisfaction, satSurvey$OrigCity, satSurvey$OrigState)
dest.mapDF <- data.frame(satSurvey$Satisfaction, satSurvey$DestCity, satSurvey$DestState)
colnames(orig.mapDF) <- c("Satisfaction", "OrigCity", "OrigState")
colnames(dest.mapDF) <- c("Satisfaction", "DestCity", "DestState")
# trim the City to remove everything after the "/"
orig.mapDF$OrigCity <- trimSlash(orig.mapDF$OrigCity)
dest.mapDF$DestCity <- trimSlash(dest.mapDF$DestCity)
# get state abbreviations
orig.mapDF$OrigStateAbbr <- name2abbr(orig.mapDF$OrigState)
dest.mapDF$DestStateAbbr <- name2abbr(dest.mapDF$DestState)

# get rid of pacific territories and other non-states
orig.mapDF<-na.omit(orig.mapDF)
dest.mapDF<-na.omit(dest.mapDF)

# remove Hawaii and Alaska (for easier plotting)
orig.mapDF <- subset(orig.mapDF, orig.mapDF$OrigStateAbbr !="HI")
dest.mapDF <- subset(dest.mapDF, dest.mapDF$DestStateAbbr !="HI")
orig.mapDF <- subset(orig.mapDF, orig.mapDF$OrigStateAbbr !="AK")
dest.mapDF <- subset(dest.mapDF, dest.mapDF$DestStateAbbr !="AK")

# create combination Origination and Destination with city, ST in lower case
orig.mapDF$Origination <- paste(orig.mapDF$OrigCity,orig.mapDF$OrigStateAbbr, sep=', ')
dest.mapDF$Destination <- paste(dest.mapDF$DestCity,dest.mapDF$DestStateAbbr, sep=', ')
# convert to all lower case
orig.mapDF$Origination<-tolower(orig.mapDF$Origination)
dest.mapDF$Destination<-tolower(dest.mapDF$Destination)

# remove the unnecessary columns now
orig.mapDF <- data.frame(orig.mapDF$Origination, orig.mapDF$Satisfaction, orig.mapDF$OrigState)
colnames(orig.mapDF)<-c("Origination", "Satisfaction", "State")
dest.mapDF <- data.frame(dest.mapDF$Destination,dest.mapDF$Satisfaction, dest.mapDF$DestState)
colnames(dest.mapDF)<-c("Destination", "Satisfaction", "State")

# need to summarize by mean satisfaction
# satisfaction mean by location (state) - Destination
Dest.means <- ddply(dest.mapDF, .(Destination), summarize, SatValue = mean(Satisfaction))
Orig.means <- ddply(orig.mapDF, .(Origination), summarize, Satvalue = mean(Satisfaction))

# add Latitudes and longitudes
#first.omeans <-head(Orig.means)
#first.omeans$geoCode <- NewLatLon(first.omeans$Origination)
Orig.means$geoCode<-NewLatLon(Orig.means$Origination)
Dest.means$geoCode<-NewLatLon(Dest.means$Destination)

# plot by Origination Airport Location
# Reflected in Figure 16 and 18
oplot <- ggplot(Orig.means,aes(geoCode$lon,geoCode$lat))
oplot <- oplot + geom_polygon(data=us,aes(x=long,y=lat,group=group),color='gray',fill='white')
oplot <- oplot + geom_point(aes(color = Satvalue),size=5)
oplot <- oplot +  xlim(-125,-65)+ylim(20,50)
oplot <- oplot + ylab("Latitude") + xlab("Longitude")
oplot <- oplot + ggtitle("Average Satisfaction by Origination Airport Location")
oplot

# plot by Destination Airport Location
# Reflected in Figure 17 and 18
dplot <- ggplot(Orig.means,aes(geoCode$lon,geoCode$lat))
dplot <- dplot + geom_polygon(data=us,aes(x=long,y=lat,group=group),color='gray',fill='white')
dplot <- dplot + geom_point(aes(color = Satvalue),size=5)
dplot <- dplot +  xlim(-125,-65)+ylim(20,50)
dplot <- dplot + ylab("Latitude") + xlab("Longitude")
dplot <- dplot + ggtitle("Average Satisfaction by Destimation Airport Location")
dplot

# random plotting
plot(satSurvey$FlightDate, satSurvey$Satisfaction)

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
# Reflected Figure 25
summary(BestlmModel)

# Reflected in Figure 26
Final.Model <- lm(formula = satSurvey$Satisfaction ~ Status + Age + Gender + 
                    PriceSens + FFYear + PercOther + TravelType + ShopAmount + 
                    Class + SchDeptHour + Cancelled + ArrDelayGT5, 
                  data = as.data.frame(satSurvey))
summary(Final.Model)

# output the data in a more readable format
#stargazer(BestlmModel, allReg, type="text", title="Linear Regression Output", align=TRUE)
stargazer(Final.Model, type="text", title="Linear Regression Output", align=TRUE)
summary.Model<- summary(Final.Model)

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
# Reflected in Figure 28
lmPlot <- data.frame(compTable$error, lm.test$PriceSens, lm.test$Status)
colnames(lmPlot) <- c("error", "PriceSens", "Status")
plotlm1 <- ggplot(lmPlot, aes(x=PriceSens, y=Status)) +
  geom_point(aes(size=error, color=error)) +
  ggtitle("Linear Regression with Price Sensitivity and Loyalty Status") +
  xlab("Price Sensitivity") + ylab("Loyalty Card Status")
plotlm1

# Reflected in Figure 29
lmPlot <- data.frame(compTable$error, lm.test$TravelType, lm.test$Status, lm.test$PriceSens)
colnames(lmPlot) <- c("error", "TravelType", "Status", "PriceSens")
plotlm2 <- ggplot(lmPlot, aes(x=PriceSens, y=Status)) +
  geom_point(aes(size=error, color=TravelType)) +
  ggtitle("Linear Regression with Price Sensitivity, Travel Type and Loyalty Status") +
  xlab("Price Sensitivity") + ylab("Loyalty Card Status")
plotlm2

# Reflected in Figure 30
lmPlot <- data.frame(compTable$error, lm.test$DeptDelayMins, lm.test$ArrDelayMins, lm.test$SchDeptHour)
colnames(lmPlot) <- c("error", "DeptDelay", "ArrivalDelay", "ScheduledDept")
plotlm3 <- ggplot(lmPlot, aes(x=DeptDelay, y=ArrivalDelay)) +
  geom_point(aes(size=error, color=ScheduledDept)) +
  ggtitle("Linear Regression with Departure and Arrival Delays and Scheduled Departure Hour") +
  xlab("Departure Delay in Minutes") + ylab("Arrival Delay in Minutes")
plotlm3

# change the scale
# Reflected in Figure 31
plotlm3 <- ggplot(lmPlot, aes(x=DeptDelay, y=ArrivalDelay)) +
  geom_point(aes(size=error, color=ScheduledDept)) +
  ggtitle("Linear Regression with Departure and Arrival Delays and Scheduled Departure Hour") +
  scale_x_continuous(limits=c(0,450)) + scale_y_continuous(limits=c(0,500)) +
  xlab("Departure Delay in Minutes") + ylab("Arrival Delay in Minutes")
plotlm3

# change the scale again
# Reflected in Figure 32
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

# Reflected in Figure 34
svmPlot <- data.frame(compTable$error, svm.test$TravelType, svm.test$Status, svm.test$PriceSens)
colnames(svmPlot) <- c("error", "TravelType", "Status", "PriceSens")
plotsvm2 <- ggplot(svmPlot, aes(x=PriceSens, y=Status)) +
  geom_point(aes(size=error, color=TravelType)) +
  ggtitle("Support Vector Machine with Price Sensitivity, Travel Type and Loyalty Status") +
  xlab("Price Sensitivity") + ylab("Loyalty Card Status")
plotsvm2

# Reflected in Figure 35
svmPlot <- data.frame(compTable$error, svm.test$DeptDelayMins, svm.test$ArrDelayMins, svm.test$SchDeptHour)
colnames(svmPlot) <- c("error", "DeptDelay", "ArrivalDelay", "ScheduledDept")
plotsvm3 <- ggplot(svmPlot, aes(x=DeptDelay, y=ArrivalDelay)) +
  geom_point(aes(size=error, color=ScheduledDept)) +
  ggtitle("Support Vector Machine with Departure and Arrival Delays and Scheduled Departure Hour") +
  scale_x_continuous(limits=c(0,200)) + scale_y_continuous(limits=c(0,200)) + 
  xlab("Departure Delay in Minutes") + ylab("Arrival Delay in Minutes")
plotsvm3

# KSVM
ksvmOutput <- ksvm(Satisfaction~Status+Age+PriceSens+PercOther+TravelType+Class+DeptDelayMins+ArrDelayMins,
                   data=svm.train,kernel="rbfdot",kpar="automatic",C=10,cross=3,prob.model=TRUE)

# test the model
ksvmPred <- predict(ksvmOutput, ksvm.test, type="votes")
ksvmPred <- data.frame(ksvmPred)
str(ksvmPred)
compTable <- data.frame(ksvm.test[,1],ksvmPred[,1])
colnames(compTable) <- c("test", "Pred")
# this is the RMSE (how low)
RSMEksvm<-sqrt(mean((compTable$test-compTable$Pred)^2))
RSMEksvm

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

# Reflected in Figure 36
RSME.frame<-NULL
RSME.frame <- c(RSMEsvm, RSMElm, RSMEksvm)
RSME.frame<-melt(RSME.frame)
RSME.frame$model <- c("RSMEsvm", "RSMElm", "RSMEksvm")
g <- ggplot(data=RSME.frame, aes(x=model, y=value))
g <- g + geom_bar(stat="identity", position="dodge")
g <- g + ggtitle("RSME Values by Model Type")
g <- g + xlab("RSME Model") + ylab("RSME Value")
g