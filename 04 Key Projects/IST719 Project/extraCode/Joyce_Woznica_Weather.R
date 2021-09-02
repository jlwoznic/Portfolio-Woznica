# 
# Course: IST719
# Name: Joyce Woznica
# Project Code: Equine Death and Breakdown Final Project
# Due Date: 
#
# ----------------  Package Section --------------------------------------------------
#specify the packages of interest
packages=c("reshape2", "ggplot2", "dplyr", "RColorBrewer", "lubridate", "stringr", "tm",
           "wordcloud", "alluvial", "treemap", "ggmap", "tidyverse", "jsonlite", "viridis")

#use this function to check if each package is on the local machine
#if a package is installed, it will be loaded
#if any are not, the missing package(s) will be installed and loaded
package.check <- lapply(packages, FUN = function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x, dependencies = TRUE)
    library(x, character.only = TRUE)
  }
})

#verify they are loaded
search()
require(dplyr)

install.packages("plyr",dependencies=TRUE)
library(plyr)

calculate_mode <- function(x)
{
  uniqx <- unique(x)
  uniqx[which.max(tabulate(match(x,uniqx)))]
}

# used and replaces ENTIRE column with mode
replaceNAwMode<-function(vec)
{
  numcols<-length(colnames(vec))
  index<-1
  while(index<=numcols)
  {
    theColV <- vec[,index]
    if (is.factor(theColV))
    {
      theColV[is.na(theColV)]<-calculate_mode(theColV)
      vec[,index]<-theColV
    }
    index<-index+1
  }
  return(vec)
}

# ----------------- Data Loading -------------------------------------------------
rData <- read.csv("/Users/joycewoznica/IST719/Project/Equine_Death_and_Breakdown.csv", 
                  header = TRUE, na.strings = "NA", 
                  stringsAsFactors = FALSE)

# review missing data
tMissing <-sum(is.na(rData))
cat("The number of missing values in Equine Death and Breakdown Data is ", tMissing)
rData$Weather.Conditions[is.na(rData$Weather.Conditions)] <- "Clear" 

# since 2020 is not complete, remove all rows with Year = 2020
index <- which(rData$Year != "2020")
rData <- rData[index,]

#------------------- Add id to rData -------------------
# add id to rData
# need to do an apply or tapply here
track.id <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11)
track.names <- c("Aqueduct Racetrack (NYRA)", "Batavia Downs", "Belmont Park (NYRA)",
                 "Buffalo Raceway", "Finger Lakes Gaming & Racetrack", 
                 "Monticello Raceway & Mighty M Gaming", "Saratoga Racecourse (NYRA)",
                 "Saratoga Gaming & Raceway", "Tioga Downs", "Vernon Downs", "Yonkers Raceway")
rData$id <- track.id[match(rData$Track, track.names)]


#--------- TO FINISH - Weather Conditions ---------------
# easy weather
inc.by.weather <- as.data.frame(cbind(rData$Track, rData$Incident.Type, rData$Weather.Conditions))
colnames(inc.by.weather) <- c("Track", "Incident.Type", "Weather.Conditions")
#inc.by.weather$id <- as.numeric(inc.by.weather$id)
inc.by.weather <- inc.by.weather[which(inc.by.weather$Weather.Conditions != " "),]
inc.by.weather$Weather.Conditions <- tolower(inc.by.weather$Weather.Conditions)
tot.rows <- length(inc.by.weather$Track)
big.weather.df <- inc.by.weather
big.weather.df$WC.Temp <- ""
big.weather.df$WC.Sky <- ""
big.weather.df$WC.Prec <- ""
big.weather.df$WC.Other <- ""

# weather
# first build a smaller df of just weather information about the incident (that matches up to the incident type)
i <- 1
while (i <= tot.rows)
{
  ext.weather.df <- NULL
  # NULL out variables
  WC.Prec <- ""
  WC.Other <- ""
  WC.Sky <- ""
  WC.Temp <- ""
  # get date from the race tack data
  weather.test <- inc.by.weather$Weather.Conditions[i]
  # now see what matches
  # WC.Prec
  if (grepl("rain",weather.test)) WC.Prec <- "Rain"
  if (grepl("shower", weather.test)) WC.Prec <- "Showers"
  if (grepl("fog", weather.test)) WC.Prec <- "Foggy"
  if (grepl("thunder", weather.test)) WC.Prec <- "Thunder"
  if (grepl("humid", weather.test)) WC.Prec <- "Humid"
  if (grepl("muggy", weather.test)) WC.Prec <- "Humid"
  if (grepl("dry", weather.test)) WC.Prec <- "Dry"
  
  # WC.Sky
  if (grepl("sun", weather.test)) WC.Sky <- "Sunny"
  if (grepl("cloud", weather.test)) WC.Sky <- "Cloudy"
  if (grepl("clear", weather.test)) WC.Sky <- "Clear"
  if (grepl("hazy", weather.test)) WC.Sky <- "Hazy"
  if (grepl("overcast", weather.test)) WC.Sky <- "Overcast"
   
  # WC.Other
  if (grepl("sloppy",weather.test)) WC.Other <- "Sloppy"
  if (grepl("breez", weather.test)) WC.Other <- "Windy"
  if (grepl("wind", weather.test)) WC.Other <- "Windy"
  
  # WC.Temp
  if (grepl("cold", weather.test)) WC.Temp <- "Cold"
  if (grepl("freez", weather.test)) WC.Temp <- "Cold"
  if (grepl("cool", weather.test)) WC.Temp <- "Cool"
  if (grepl("mild", weather.test)) WC.Temp <- "Warm"
  if (grepl("warm", weather.test)) WC.Temp <- "Warm"
  if (grepl("hot", weather.test)) WC.Temp <- "Hot"
    
  # now check temps
  temp <- as.numeric(str_extract(weather.test, "\\-*\\d+\\.*\\d*"))
  if (!is.na(temp))
      {
        if (temp < 45) WC.Temp <- "Cold"
        if (temp >= 45 && temp < 60) WC.Temp <- "Cool"
        if (temp >= 60 && temp < 75) WC.Temp <- "Warm"
        if (temp >= 75) WC.Temp <- "Hot"
      }
  # Now need to build a dataframe from all the WC variables
  ext.weather.df <- data.frame(cbind(WC.Temp, WC.Sky, WC.Prec, WC.Other))
  colnames(ext.weather.df) <- c("WC.Temp", "WC.Sky", "WC.Prec", "WC.Other")
  # this creates the new row
  big.weather.df$WC.Temp[i] <- WC.Temp
  big.weather.df$WC.Sky[i] <- WC.Sky
  big.weather.df$WC.Prec[i] <- WC.Prec
  big.weather.df$WC.Other[i] <- WC.Other
  
  # increment i
  i <- i + 1
}

big.weather.df[big.weather.df==""] <- "Unreported"
#big.weather.df <- subset(big.weather.df, select = -Incident.Type)
df.Sky <- as.data.frame(table(big.weather.df$Incident.Type, big.weather.df$Track, big.weather.df$WC.Sky))
colnames(df.Sky) <- c("Incident.Type", "Track", "Sky", "Frequency")
df.Prec <- as.data.frame(table(big.weather.df$Incident.Type, big.weather.df$Track, big.weather.df$WC.Prec))
colnames(df.Prec) <- c("Incident.Type", "Track", "Prec", "Frequency")
df.Temp <- as.data.frame(table(big.weather.df$Incident.Type, big.weather.df$Track, big.weather.df$WC.Temp))
colnames(df.Temp) <- c("Incident.Type", "Track", "Temperature", "Frequency")
df.Other <- as.data.frame(table(big.weather.df$Incident.Type, big.weather.df$Track, big.weather.df$WC.Other))
colnames(df.Other) <- c("Incident.Type", "Track", "Other", "Frequency")

# eliminate 0 frequencies
df.Sky <- df.Sky[which(df.Sky$Frequency >= 1),]
df.Prec <- df.Prec[which(df.Prec$Frequency >= 1),]
df.Temp <- df.Temp[which(df.Temp$Frequency >= 1),]
df.Other <- df.Other[which(df.Sky$Other >= 1),]
# elimintate Unreported 

# try setting manual shapes and manual colors - make equine death RED
par(mar=c(5,8,4,2))
g <- ggplot(df.Sky, aes(x = Sky, y = Frequency)) 
g <- g + geom_point(aes(shape = Track, color = Incident.Type))
g <- g + labs(title = "Incident Frequency by Sky Conditions",
              subtitle = "by Track and Incident Type")
g <- g + theme(axis.text.x = element_text(angle= 45, hjust = 1))
g <- g + theme(plot.title = element_text(hjust = 0.5, face = "bold"), 
               plot.subtitle = element_text(hjust = 0.5))
g

# Just frequency by Sky Conditions
df.Sky2 <- as.data.frame(table(df.Sky$Sky))
colnames(df.Sky2) <- c("Sky", "Frequency")
g <- ggplot(df.Sky2, aes(x = Sky, y=Frequency))
g <- g + geom_boxplot()
g

# Frequency by Sky Conditions
# set color using scale_fill_manual and set 6 values Or haw many
# Just try without
num.colors <- length(df.Sky$Sky)
getPalette = colorRampPalette(brewer.pal(11, "RdYlBu"))
my.cols <- getPalette(num.colors)
# remove unreported
par(mar=c(5,12,4,2))
g <- ggplot(df.Sky, aes(x = Incident.Type, y=Frequency, color=Sky, fill=Sky))
g <- g + geom_boxplot(outlier.colour = "red")
g <- g + labs(title = "Incident Frequency by Sky Conditions",
              subtitle = "by Incident Type")
g <- g + theme(axis.text.x = element_text(angle= 45, hjust = 1))
g <- g + theme(plot.title = element_text(hjust = 0.5, face = "bold"), 
               plot.subtitle = element_text(hjust = 0.5))
#g <- g + scale_fill_manual(values = my.cols) + scale_color_manual(values = my.cols)
#g <- g + geom_boxplot(outlier.colour = "red", outlier.shape = 8, outlier.size = 4, notch=TRUE)
g

# Frequency by Temp Conditions
g <- ggplot(df.Temp, aes(x = Temp, y=Frequency))
g <- g + geom_boxplot()
g

attempt.df <- as.data.frame(table(big.weather.df$WC.Temp, big.weather.df$WC.Prec, 
                                  big.weather.df$WC.Sky,  big.weather.df$WC.Other))
colnames(attempt.df) <- c("WC.Temp", "WC.Prec", "WC.Sky", "WC.Other", "Frequency")
plot.attempt.df <- aggregate(attempt.df$Frequency, 
                              list(Temperature = attempt.df$WC.Temp, 
                                   Sky = attempt.df$WC.Sky,
                                   Precipitation = attempt.df$WC.Prec), sum)
colnames(plot.attempt.df) <- c("Temperature", "Sky", "Precipitation", "Frequency")

#------------------ Plot Weather Conditions -----------------------------
# Just try without
num.colors <- length(big.weather.df$Weather.Conditions)
getPalette = colorRampPalette(brewer.pal(11, "RdYlBu"))
my.cols <- getPalette(num.colors)

g <- ggplot(plot.attempt.df, aes(x = Temperature, y = Frequency))
g <- geom_boxplot()
g

#------------------- SAVING -----------------
# Need to update with mode values for plotting

attempt.df <- as.data.frame(table(big.weather.df$Incident.Type, 
                                  big.weather.df$WC.Temp, big.weather.df$WC.Prec, 
                                  big.weather.df$WC.Sky,  big.weather.df$WC.Other))
colnames(attempt.df) <- c("Incident.Type", "WC.Temp", "WC.Prec", "WC.Sky", "WC.Other", "Frequency")

plot.attempt.df <- aggregate(attempt.df$Frequency, 
                             list(Temperature = attempt.df$WC.Temp, 
                                  Sky = attempt.df$WC.Sky,
                                  Precipitation = attempt.df$WC.Prec), sum)
colnames(plot.attempt.df) <- c("Temperature", "Sky", "Precipitation", "Frequency")


summary(plot.attempt.df$Temperature)
plot.attempt.df$Temperature[is.na(plot.attempt.df$Temperature)] <- "Warm"
summary(plot.attempt.df$Temperature)

summary(plot.attempt.df$Sky)
plot.attempt.df$Sky[is.na(plot.attempt.df$Sky)] <- "Clear"
summary(plot.attempt.df$Sky)

summary(plot.attempt.df$Precipitation)
plot.attempt.df$Precipitation[is.na(plot.attempt.df$Precipitation)] <- "Dry"
summary(plot.attempt.df$Precipitation)

