# 
# Course: IST687
# Name: Joyce Woznica
# Project Code: Load and Manipulate Data
# Due Date: MM/DD/2019
# Date Submitted:
#
# read in a dataset so that it can be useful.
# use this package to read in a XLS file

#
airlineSatSurvey <- read_excel("C:/ProjectIST687/SatisfactionSurvey2.xlsx")

# this is excellent! from Hsmic
satSurvey <- as.data.frame(airlineSatSurvey)

# rename the columns to make easier:
# Satisfaction = Satisfaction
# Airline Status = Status
# Age = Age
# Gender = Gender
# Price Sensitivity = PriceSens
# Year of First Flight = FFYear
# % of Flight with other Airlines = PercOther
# No of Flight p.a. = NumFlights
# Type of Travel = TravelType
# No. of other Loyalty Cards = NumCards
# Shopping Amount at Airport = ShopAmount
# Eating and Drinking at Airport = EatDrink
# Class = Class
# Day of Month = MonthDay
# Flight date = FlightDate
# Airline Code = AirlineCode
# Airline Name = Airline
# Origin City = OrigCity
# Origin State = OrigState
# Destination City = DestCity
# Destination State = DestState
# Scheduled Departure Hour = SchDeptHour
# Departure Delay in Minutes = DeptDelayMins
# Arrival Delay in Minutes = ArrDelayMins
# Flight cancelled = Cancelled
# Flight time in minutes = FlightMins
# Flight Distance = Distance
# Arrival Delay greater than 5 Mins = ArrDelayGT5

newColNames <- c("Satisfaction","Status", "Age", "Gender", "PriceSens", 
                 "FFYear", "PercOther", "NumFlights", "TravelType", "NumCards", 
                 "ShopAmount", "EatDrink", "Class", "MonthDay", "FlightDate", 
                 "AirlineCode", "Airline", "OrigCity", "OrigState", 
                 "DestCity", "DestState", "SchDeptHour", 
                 "DeptDelayMins", "ArrDelayMins", "Cancelled",
                 "FlightMins", "Distance", "ArrDelayGT5")

colnames(satSurvey)<-newColNames
View(satSurvey)

# Remove spaces (for beginning and end of lines)
satSurvey$Gender<-trim(satSurvey$Gender)
# remove ", STATE_ABBR" from Cities
satSurvey$OrigCity<-trimCity(satSurvey$OrigCity)
satSurvey$DestCity<-trimCity(satSurvey$DestCity)

# NA appears when plane doesn't take off
# if Cancelled = "Yes" - set all delay and arrival minutes to 0
satSurvey$DeptDelayMins[satSurvey$Cancelled=="Yes"]<-0
satSurvey$ArrDelayMins[satSurvey$Cancelled=="Yes"]<-0
satSurvey$FlightMins[satSurvey$Cancelled=="Yes"]<-0
satSurvey$FlightMins[is.na(satSurvey$FlightMins)]<-0
satSurvey$ArrDelayMins[is.na(satSurvey$ArrDelayMins)]<-0

# anymore NAs?
na_count<-sapply(satSurvey, function(x) sum(length(which(is.na(x)))))
na_count
# remove the lines that have no satistfaction value
satSurvey<-na.omit(satSurvey)
