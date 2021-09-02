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

#------------------ Functions ----------------------------------------------------

nominatim_osm <- function(address = NULL)
{
  if(suppressWarnings(is.null(address)))
    return(data.frame())
  tryCatch(
    d <- jsonlite::fromJSON( 
      gsub('\\@addr\\@', gsub('\\s+', '\\%20', address), 
           'http://nominatim.openstreetmap.org/search/@addr@?format=json&addressdetails=0&limit=1')
    ), error = function(c) return(data.frame())
  )
  if(length(d) == 0) return(data.frame())
  return(data.frame(lon = as.numeric(d$lon), lat = as.numeric(d$lat)))
}

#dplyr will be used to stack lists together into a data.frame and to get the pipe operator '%>%'
suppressPackageStartupMessages(library(dplyr))

NewLatLon<-function(addresses){
  d <- suppressWarnings(lapply(addresses, function(address) {
    #set the elapsed time counter to 0
    t <- Sys.time()
    #calling the nominatim OSM API
    api_output <- nominatim_osm(address)
    #get the elapsed time
    t <- difftime(Sys.time(), t, 'secs')
    #return data.frame with the input address, output of the nominatim_osm function and elapsed time
    return(data.frame(address = address, api_output, elapsed_time = t))
  }) %>%
    #stack the list output into data.frame
    bind_rows() %>% data.frame())
  #output the data.frame content into console
  return(d)
}

# helpful functions for removing spaces
# need to clean out extra spaces from ends of lines
trim.leading<-function(x) {sub("^\\s+","",x)}
trim.trailing<-function(x) {sub("\\s+$","",x)}
trim<-function(x) {sub("^\\s+|\\s+$","",x)}
trimCity<-function(x) {sub("\\,.*$","",x)}

# maybe add weather station?
# should have just put this in a excel file!!!
trackAddress <- function(track.df)
{
  track.address <- NULL
  if (track == "Aqueduct Racetrack (NYRA)") track.address <- c("110-00 rockaway blvd", "south ozone park", "ny", "11420")
  if (track == "Batavia Downs") track.address <- c("8315 park road", "batavia", "ny", "14020")
  if (track == "Belmont Park (NYRA)") track.address <- c("2150 hempstead turnpike", "elmont", "ny", "11003")
  if (track == "Buffalo Raceway") track.address <- c("5600 mckinley parkway", "hamburg", "ny", "14075")
  if (track == "Finger Lakes Gaming & Racetrack") track.address <- c("5857 ny-96", "farmington", "ny", "14425")
  if (track == "Monticello Raceway & Mighty M Gaming") track.address <- c("204 ny-17b", "monticello", "ny", "12701")
  if (track == "Saratoga Racecourse (NYRA)") track.address <- c("267 union ave", "saratoga springs", "ny", "12866")
  if (track == "Saratoga Gaming & Raceway") track.address <- c("342 jefferson street", "saratoga springs", "ny", "12866")
  if (track == "Tioga Downs") track.address <- c("2384 w river road", "nichols", "ny", "13812")
  if (track == "Vernon Downs") track.address <- c("4229 stuhlman road", "vernon", "ny", "13476")
  if (track == "Yonkers Raceway") track.address <- c("810 mclean ave", "yonkers", "ny", "10704")
  track.address
}

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

# --------------- Interrogte Data ---------------------------------------------------
# force no scientific notation
options(scipen=999)
# General Statistics and Analysis
summary(rData)
str(rData)

# A little more summary information
test<-as.matrix(rData)
summary(test)

unique(rData$Inv.Location)

# for Stats in Title
# what is percent of total incidents that are equine death
for.perc <- table(rData$Incident.Type)
for.perc <- as.data.frame(for.perc)
colnames(for.perc) <- c("Incident.Type", "Frequency")
total.incidents <- sum(for.perc$Frequency)
perc.death <- 100*(for.perc[which(for.perc$Incident.Type == "EQUINE DEATH"),2]/total.incidents)

# find percent that happen on track
str(rData)
unique(rData$Racing.Type.Description)
for.perc <- table(rData$Racing.Type.Description)
for.perc <- as.data.frame(for.perc)
colnames(for.perc) <- c("Racing.Type.Description", "Frequency")
total.incidents <- sum(for.perc$Frequency)
perc.racing <- 100*(for.perc[which(for.perc$Racing.Type.Description == "Racing"),2]/total.incidents)

# find the percentage change of equine death in 2009 versus 2019 (to show improvement)
# aggregate? or table?
# really would like to get EQUINE DEATH deduction
for.perc  <-as.data.frame(table(rData$Year, rData$Incident.Type))
colnames(for.perc) <- c("Year", "Incident.Type", "Frequency")
for.perc <- for.perc[which(for.perc$Incident.Type == "EQUINE DEATH"),]
total.incidents <- sum(for.perc$Frequency)
for.perc$Year <- c(2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019)
for.perc$Year <- as.numeric(for.perc$Year)
perc.2009 <- 100*(for.perc[which(for.perc$Year == 2009),3]/total.incidents)
perc.2019 <- 100*(for.perc[which(for.perc$Year == 2019),3]/total.incidents)
perc.improvement <- perc.2009 - perc.2019

# -------------- Bar Chart - Frequency of Incidents by Type -------------------
# ?? What is the most common incident happening on racetracks ??
inc.type <- table(rData$Incident.Type)
inc.type <- as.data.frame(inc.type)
colnames(inc.type) <- c("Incident.Type", "Frequency")
num.colors <- length(inc.type$Incident.Type)
getPalette = colorRampPalette(brewer.pal(9, "YlOrRd"))
my.cols <- getPalette(num.colors)
# determine tick marks
tlen <- 1500
nticks <- 10
tick.dist <- tlen/nticks
ticks <- seq(0, tlen, by = tick.dist)

par(mar=c(5,12,4,2))
my.bar <- barplot(sort(table(rData$Incident.Type)), col=my.cols,
                  xlab = "Incident Frequency",
                  main = "Number of Incidents by Type",
                  las = 1, cex.names = 0.65,
                  horiz = TRUE, xaxt = "n",
                  xlim = c(0, tlen), 
                  args.legend = list(x = "topleft", bty = "n", cex=0.75))
# enter correct axis tick marks
axis(1, at = ticks)
# just change white bar to RED in Adobe

# --------------  Pie Chart - Frequency of Incidents by Track (NOT USED)-------------------
# ?? Are certain tracks having more issues than others?
# aggregate to get just track, death, total incidents in new dataframe
for.pie<-as.data.frame(table(rData$Track))
colnames(for.pie) <- c("Track", "Frequency")
# need more colors, but for now - okay
my.cols <- brewer.pal(num.colors, "Set3")

# maybe do for death of total percent of incidents?
# not used
pie(for.pie$Frequency, labels = for.pie$Track, 
    main = "Single Dimensional: Frequency of Incidents by Track",
    angle = 45, cex = .75,
    col = my.cols)

# --------------  Incidents per year - time series by division --------------------
# 
# ?? Are Racing Incidents decreasing ?? 
# ?? Are the declining on both types of tracks ??
# how to get a sum of all incidents by division by year
tsp.df <- as.data.frame(table(rData$Year, rData$Division, rData$Incident.Type))
# can I do something by type (color) freq (y), year (x)
colnames(tsp.df) <- c("Year", "Division", "Incident.Type", "Frequency")
test.df <- aggregate(tsp.df$Frequency, 
                     list(Year=tsp.df$Year, Division=tsp.df$Division), sum)
colnames(test.df) <- c("Year", "Division", "Frequency")

par(mar=c(4,4,4,4))
# this gets the points - now need to connect the dots
# label the axes and move title to bold, center
g <- ggplot(test.df) + aes(x = Year, y = Frequency, group = Division)
g <- g + geom_line(aes(color = Division))
g <- g + geom_point(aes(color = Division)) + ylim(c(0,400))
g <- g + labs(title = "Incident Frequency by Division by Year",
              subtitle="Frequency of Incidents for each Racing Division in New York State over Time")
g <- g + xlab("Year") + ylab("Number of Incidents")
g <- g + theme(axis.text.x = element_text(angle = 45, hjust = 1))
g <- g + theme(plot.title = element_text(hjust=0.5), plot.subtitle = element_text(hjust=0.5))
g

# --------------  Incidents per year - time series by track --------------------
# 
# ?? Are Racing Incidents decreasing ??
# how to get a sum of all incidents by track by year
itsbyTrack.df <- as.data.frame(table(rData$Year, rData$Track, rData$Incident.Type))
# can I do something by type (color) freq (y), year (x)
colnames(itsbyTrack.df) <- c("Year", "Track", "Incident.Type", "Frequency")
test.df <- aggregate(itsbyTrack.df$Frequency, 
                     list(Year=itsbyTrack.df$Year, Track=itsbyTrack.df$Track), sum)
colnames(test.df) <- c("Year", "Track", "Frequency")

par(mar=c(4,4,4,4))
g <- ggplot(test.df) + aes(x = Year, y = Frequency, group = Track)
g <- g + geom_line(aes(color = Track))
g <- g + geom_point(aes(color = Track)) 
g <- g + labs(title = "Incident Frequency by Track by Year",
              subtitle="Frequency of Incidents at each Race Track in New York State over Time")
g <- g + xlab("Year") 
g <- g + scale_y_continuous (name = "Number of Incidents", limits = c(0, 140), breaks=c(0, 20, 40, 60, 80, 100, 120, 140))
g <- g + theme(axis.text.x = element_text(hjust = 1))
g <- g + theme(plot.title = element_text(hjust=0.5, face = "bold"), plot.subtitle = element_text(hjust=0.5))
g

# --------------  Incidents by Type by Division --------------------
# not used - changed to plot by 
num.colors <- length(unique(rData$Incident.Type))
xtz <- colorRampPalette(c("navy", "darkblue", "darkred", "orange", "tan", "darkgreen"))
my.cols <- xtz(num.colors)
barplot(table(rData$Incident.Type, rData$Division), beside=TRUE, legend=TRUE,
        main="Incident Type by Racetrack Division", 
        sub="Frequency of Each Incident Type by Racetrack Division - Harness or Thoroughbred",
        col = my.cols,
        axisnames=TRUE, las = 1, cex.names = 1,
        args.legend = list(x = "topleft", bty = "n", cex=0.85))

# Need to make this type on X and Division on Y, beside
par(mar=c(12, 5, 4, 2))
barplot(table(rData$Division, rData$Incident.Type), beside=TRUE, legend=TRUE,
        main="Frequency of Each Incident Type by Racetrack Division - Harness or Thoroughbred", 
        col = c("tan", "darkred"),
        axisnames=TRUE, 
        las = 2, 
        cex.names = .65,
        args.legend = list(x = "topleft", bty = "n", cex=0.85))

# --------------  Incidents by Type by Track -------------------------
subset.df <- as.data.frame(rData[which(rData$Incident.Type != "STEWARDS/VETS LIST"),])
num.colors <- length(unique(subset.df$Incident.Type))
xtz <- colorRampPalette(c("tan", "chocolate", "red", "darkred", "darkgreen", "cadetblue", "navy"))
my.cols <- xtz(num.colors)

par(mar=c(12, 10, 5, 4))
# maybe remove stewards/vet list
g <- ggplot(subset.df, aes(x=Track, fill=factor(Incident.Type)))
g <- g + labs(title = "Incident Type by Track",
              subtitle="Frequence of  Incident Type at each Track in New York State without Stewards/Vets List")
g <- g + geom_bar(position = "fill")
g <- g + scale_fill_manual(name="Incident Types", values= my.cols)
g <- g + xlab("Track") + ylab("Number of Incidents")
g <- g + theme(axis.text.x = element_text(angle = 45, hjust = 1))
g <- g + theme(plot.title = element_text(hjust=0.5), plot.subtitle = element_text(hjust=0.5))
g

# not used
# find a better plot for this - not a bar plot
g <- ggplot(subset.df, aes(x=Track, fill=factor(Incident.Type)))
g <- g + labs(title = "Incident Type by Track",
              subtitle="Number of each Incident Type that occured at each Track in New York State")
g <- g + geom_bar(position="stack")
g <- g + scale_fill_manual(name="Incident Types", values= my.cols)
g <- g + xlab("Track") + ylab("Number of Incidents")
g <- g + theme(axis.text.x = element_text(angle = 45, hjust = 1))
g <- g + theme(plot.title = element_text(hjust=0.5), plot.subtitle = element_text(hjust=0.5))
g

#------------------ Word Cloud --------------------------------
# need to grab only those rows that fit the accident profile
# Need to maybe only use rows where incident is NOT "equine death - infectious disease" or "stewards/vets list"
index <- which(rData$Incident.Type != "STEWARDS/VETS LIST" |
                 rData$Incident.Type != "EQUINE DEATH - INFECTIOUS DISEASE")
descripts.df <- as.data.frame(rData$Incident.Description[index])
colnames(descripts.df) <- c("description")
# to lower case
descripts.df <- as.data.frame(gsub("\\.", " ", as.character(descripts.df$description)))
colnames(descripts.df) <- c("description")
descripts.df <- as.data.frame(gsub("-", " ", as.character(descripts.df$description)))
colnames(descripts.df) <- c("description")
descripts.df <- as.data.frame(gsub(":", " ", as.character(descripts.df$description)))
colnames(descripts.df) <- c("description")
descripts.df <- tolower(strsplit(as.character(descripts.df$description), " ", 2))
# remove punctuation
descripts.df <- sapply(descripts.df, removePunctuation)
docs <- Corpus(VectorSource(descripts.df))
docs <- tm_map(docs, removeWords, stopwords("english"))
dtm <- TermDocumentMatrix(docs) 
matrix <- as.matrix(dtm) 
words <- sort(rowSums(matrix),decreasing=TRUE) 
df <- data.frame(word = names(words),freq=words)
set.seed(1234) # for reproducibility 
# euthanized word is too large - need to fix
df[1,1] <- "death"

par(mar=c(4,4,4,4))
wordcloud(words = df$word, freq = df$freq, min.freq = 1,
          max.words=200, random.order=FALSE, rot.per=0.35,
          colors=brewer.pal(8, "Dark2"))

# try with wordcloud2 for special shapes
# find a horse shape
require(devtools)
install_github("lchiffon/wordcloud2")
library(wordcloud2)
fig.Path <- "/Users/joycewoznica/IST719/Project/Images/HR01.png"
par(mar=c(0,0,0,0))
# for some reason - euthanized comes up with size = 0.65

wordcloud2(df, 
           color = "random-light",
#           backgroundColor = "#003A23",
           figPath = fig.Path,
           size = 1.05, minSize = 0,
           fontFamily = "Segoe UI", fontWeight = "bold",
           rotateRatio = 1, minRotation = -pi/6, maxRotation = pi/6, 
           shuffle = FALSE
           )

wordcloud2(df, 
           color = "Set2",
           figPath = fig.Path,
           size = 1.05, minSize = 0,
           fontFamily = "Segoe UI", fontWeight = "bold",
           rotateRatio = 1, minRotation = -pi/6, maxRotation = pi/6, 
           shuffle = FALSE
)

#------------------ Deaths by Trainer -----------------------
# confirm that we are doing death only here - not just incidents???
# Use this to develop list oi trainers with most deaths
trainer.df <- as.data.frame(table(rData$Trainer, rData$Incident.Type))
# can I do something by type (color) freq (y), year (x)
colnames(trainer.df) <- c("Trainer", "Incident.Type", "Frequency")
test.df <- aggregate(trainer.df$Frequency, 
                     list(trainer.df$Trainer), sum)
colnames(test.df) <- c("Trainer", "Frequency")
# get only those wehere there is more than 5 frequency
test.df <- as.data.frame(test.df[which(test.df$Frequency >= 35),])
# remove blank trainer
test.df <- test.df[which(test.df$Trainer != " "),]
test.df <- test.df[order(-test.df$Frequency),]
rownames(test.df) <- test.df$Trainer
trainer.list <- rownames(test.df)

# now get by these trainers only and by track
# ?? Do some trainers have more deaths than others ??
# Not by track, but overall
new.trainer.df <- as.data.frame(table(rData$Trainer, rData$Track, rData$Incident.Type))
# can I do something by type (color) freq (y), year (x)
colnames(new.trainer.df) <- c("Trainer", "Track", "Incident.Type", "Frequency")
new.trainer.df <- new.trainer.df[which(new.trainer.df$Frequency >= 1),]
# remove blanks
new.trainer.df <- new.trainer.df[which(new.trainer.df$Trainer != " "),]

# build a new data frame only matching highest incident trainers
new.temp <- new.trainer.df
return.temp <- NULL
for (tname in trainer.list)
{
  return.temp <- rbind(return.temp, subset(new.temp, new.temp$Trainer == tname))
}
high.inc.trainer.df <- return.temp

# color = Track and size = Frequency
# other than shape?
# fix colors

par(mar=c(5,12,4,2))
g <- ggplot(high.inc.trainer.df, aes(x = Trainer, y = Frequency)) 
g <- g + geom_point(aes(shape = Track, color = Incident.Type))
g <- g + labs(title = "Trainers with Highest Number of Incidents",
              subtitle = "by Track and Incident Type")
g <- g + theme(axis.text.x = element_text(angle= 45, hjust = 1))
g <- g + theme(plot.title = element_text(hjust = 0.5, face = "bold"), 
               plot.subtitle = element_text(hjust = 0.5))
g

num.colors <- length(unique(high.inc.trainer.df$Incident.Type))
xtz <- colorRampPalette(c("yellow", "tan", "darkred", "brown", "chocolate3", "darkolivegreen", "darkgreen", "cyan4", "cadetblue", "navy"))
my.cols <- xtz(num.colors)

# Try a better plot
# find a better plot for this - not a bar plot
# need to sort this by most number of incidents - just reorder manually LOL
#g <- ggplot(high.inc.trainer.df, aes(x=Trainer, fill=factor(Incident.Type)))
g <- ggplot(high.inc.trainer.df, aes(x=Trainer, fill=factor(Incident.Type)))
g <- g + labs(title = "Incident Type by Top Trainers",
              subtitle="Number of each Incident Type that occured at each Track in New York State by Trainer")
g <- g + geom_bar(position="stack")
g <- g + scale_fill_manual(name="Incident Types", values= my.cols)
g <- g + xlab("Trainer") + ylab("Number of Incidents")
g <- g + theme(axis.text.x = element_text(angle = 45, hjust = 1))
g <- g + theme(plot.title = element_text(hjust=0.5), plot.subtitle = element_text(hjust=0.5))
g

# not used
for.pie<-test.df
num.colors <- length(test.df$Trainer)
getPalette = colorRampPalette(brewer.pal(11, "Spectral"))
my.cols <- getPalette(num.colors)

# maybe do for death of total percent of incidents?
# not used
# find a way to put percentages?
pie(for.pie$Frequency, labels = for.pie$Trainer, 
    main = "Single Dimensional: Frequency of Incidents by Track",
    angle = 45, cex = .75,
    col = my.cols)

#---------- Map of Tracks ---------------------
# Does location make a difference?
# ?? Where in New York are the highest incidents of Equine Death on the track ??
index <- which(rData$Incident.Type == "EQUINE DEATH")
map.df <- as.data.frame(rData$Track[index])
colnames(map.df) <- c("Track")
# now just get the counts 
counts.by.track <- as.data.frame(table(map.df))
colnames(counts.by.track) <- c("Track", "Deaths")
# call function to add ciy/state to each track
# need to match up address with each track
# function to get address
i <- 1
city.state.df <- NULL
while (i <= length(counts.by.track$Track))
{
  track <- counts.by.track$Track[i]
  city.state.df <- rbind(city.state.df, trackAddress(track))
  i <- i+1
}
colnames(city.state.df) <- c("StreetAdd", "City", "State", "Zip")
city.state.df <- as.data.frame(city.state.df)
city.state.df$Addr <- sprintf("%s, %s %s %s",
                              city.state.df$StreetAdd, 
                              city.state.df$City, 
                              city.state.df$State, 
                              city.state.df$Zip)
city.state.df <- as.data.frame(city.state.df)
geocode.df <- NewLatLon(city.state.df$Addr)
# then combine using
total.map.df <- cbind(counts.by.track, city.state.df, geocode.df)
# remove unnecessary columns
total.map.df[,c("address", "elapsed_time")] <- list(NULL)

# map it
# maybe try to angle words?
# maybe add shape for Division of Track?
ny.map <- map_data("state", region = "new york")
oplot <- ggplot(total.map.df,aes(lon,lat))
oplot <- oplot + geom_polygon(data = ny.map, aes(x = long, y = lat, group = group),
                              color="darkgreen", 
                              fill = "white")
oplot <- oplot + geom_point(aes(color = Deaths),size=5) + 
  scale_color_viridis(option = "inferno", direction = -1)
oplot <- oplot + geom_text(data=total.map.df, aes(label = Track, x = lon, y = lat),
                           position = position_nudge(x = 0, y = .12),
                           size = 3, color = "saddlebrown")
oplot <- oplot +  xlim(-80,-72.3)+ylim(40.5,45.05)
oplot <- oplot + xlab("Longitude") + ylab("Latitude") 
oplot <- oplot + ggtitle("Incidents by Track Location in New York State")
oplot

LonH <- -72
LonL <- -80.15
LonM <- (LonH + LonL)/2
LatH <- 45.15
LatL <- 40.05
LatM <- (LatH + LatL)/2

# gets a terrain map
e <- get_map(location=c(LonL, LatL, LonH, LatH), zoom=7, maptype="terrain")
Tmap <- ggmap(e)
Tmap <- Tmap + geom_point(data=total.map.df, aes(color = Deaths),size=5) + 
  scale_color_viridis(option = "inferno", direction = -1)
Tmap <- Tmap + geom_text(data=total.map.df, aes(label = Track, x = lon, y = lat),
                           position = position_nudge(x = .05, y = .15),
                           size = 3, color = "black")
Tmap <- Tmap + xlab("Longitude") + ylab("Latitude") 
Tmap <- Tmap + ggtitle("Incidents by Track Location in New York State")
Tmap

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
g <- ggplot(df.Temp, aes(x = Temperature, y=Frequency))
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

# ------------ NOT USED OR COMPLETED - Look up weather in file --------------
# ?? Does weather play a factor in equine deaths ??
# weather
# first build a smaller df of just weather information about the incident (that matches up to the incident type)
wtrack.df <- cbind(rData$id, rData$Incident.Date, rData$Track, rData$Incident.Type)
wtrack.df <- as.data.frame(wtrack.df)
colnames(wtrack.df) <- c("id", "Incident.Date", "Track", "Incident.Type")
wtrack.df$id <- as.numeric(wtrack.df$id)

# get historical weather using rnoaa 
install.packages("devtools")
library(devtools)
sessionInfo()
devtools::install_github("ropensci/rnoaa")
install.packages("rnoaa")
library(rnoaa)

# for NOAA
# Email: 	jlwoznic@syr.edu
# Token: 	MmIlMbbJvDnYOMxgeImRlJTbLperrfgK
options(noaakey = "MmIlMbbJvDnYOMxgeImRlJTbLperrfgK")

stations <- ghcnd_stations()
# remove all by NY
new.stations <- stations[which(stations$state == "NY"), ]
# now need only those stations that have start date <= 2009 and end date >= 2019
#index <- which((tweets$date > start.date) & (tweets$date < end.date))
index <- which((new.stations$first_year < 2010) & (new.stations$last_year > 2018))
new.stations <- new.stations[index, ]

# build a lat/lon matrix
weather.geocode.df <- cbind.data.frame(geocode.df$lat, geocode.df$lon)
weather.geocode.df$id <- rownames(weather.geocode.df) 
colnames(weather.geocode.df) <- c("lat", "lon", "id")
abc <- meteo_nearby_stations(weather.geocode.df, lat_colname = "lat", lon_colname = "lon",
                             station_data = new.stations, var = "all", year_min = 2009, year_max = 2019,
                             radius = 35, limit=NULL)
# gave up on the loop - LOL
# grab first station which is closest to the lat/lon of the track
# need to use the 3rd index for Monticello because there was no data for the first two stations
wstation.track <- c(abc$`1`$id[1], abc$`2`$id[1], abc$`3`$id[1], abc$`4`$id[1],
                    abc$`5`$id[1], abc$`6`$id[3], abc$`7`$id[1], abc$`8`$id[1],
                    abc$`9`$id[1], abc$`10`$id[1], abc$`11`$id[1])

##now we have a list of the closest weather station for each track, we can use the associated CSV
# file that I downloaded from Climate.gov for each station by reading the mapping stations2csv.csv
stations2csv.df <- read.csv("/Users/joycewoznica/IST719/Project/noaa/stations2csv.csv", header = TRUE, stringsAsFactors = FALSE)
# loop through here
weather.dir <- "/Users/joycewoznica/IST719/Project/noaa/"

# PSUN = Daily percent of possible sunshine (percent)
# PRCP = Precipitation (tenths of mm)
# TMAX = Maximum temperature (tenths of degrees C)
# TMIN = Minimum temperature (tenths of degrees C)
# ACSC = Average cloudiness sunrise to sunset from 30-second 
#       ceilometer data (percent)
# AWND = Average daily wind speed (tenths of meters per second)
# 
# WT** = Weather Type where ** has one of the following values:
#  
# 01 = Fog, ice fog, or freezing fog (may include heavy fog)
# 02 = Heavy fog or heaving freezing fog (not always 
#                                        distinquished from fog)
# 03 = Thunder
# 05 = Hail (may include small hail)
# 07 = Dust, volcanic ash, blowing dust, blowing sand, or 
#      blowing obstruction
# 08 = Smoke or haze 
# 11 = High or damaging winds
# 12 = Blowing spray
# 13 = Mist
# 14 = Drizzle
# 15 = Freezing drizzle 
# 16 = Rain (may include freezing rain, drizzle, and
#           freezing drizzle) 
# 17 = Freezing rain 
# 21 = Ground fog 
# 22 = Ice fog or freezing fog
# for all WT - there is a 1 or blank - if 1, then this condition happened


# PSUN doesn't seem to exist in all files
# ACSC doesn't seem to exist in all files
# WT12 doesn't seem to exist in all files
weather.interest <- c("PRCP", "TMAX", "TMIN", "AWND", 
                      "WT01", "WT02", "WT03", "WT05", 
                      "WT07", "WT08", "WT11", "WT13", 
                      "WT14", "WT15", "WT16", "WT17", 
                      "WT21", "WT22")
numconditions <- length(weather.interest)

i <- 1
for (i in 11)
{
  csv.file <- paste0(weather.dir, stations2csv.df$CSV[i], ".csv")
  weatherFile.df <- read.csv(csv.file, header = TRUE, stringsAsFactors = FALSE)
  # obtain just the weather section relevant to this station
  wtrack.subset.df <- wtrack.df[which(wtrack.df$id == i),]
  # get weather data for the date
  # now need to apply to each row adding columns for weather based on value in wtrack.subset.df$Incident.Date
  #first need to get the dat for each row in the subset and then match that date in the weatherFile.df
  numdates <- length(wtrack.subset.df$Incident.Date)
  j <- 1
  for (j in numdates)
  {
    # get date from the race tack data
    weather.date <- wtrack.subset.df$Incident.Date[j]
    # now return columns of interest from weatherFile.df for this date
    test.date <- as.Date(weather.date, format = "%m/%d/%Y")
    # need to map date from MM/DD/YYYY to YYYY-MM-DD and then match in the weatherFile.df
    match.row <- weatherFile.df[which(weatherFile.df$DATE == test.date),]
    w.df <- as.data.frame(cbind(match.row$PRCP, match.row$TMAX, match.row$TMIN, match.row$AWND,
                                match.row$WT01, match.row$WT02, match.row$WT03, match.row$WT05,
                                match.row$WT07, match.row$WT08, match.row$WT11, match.row$WT13, 
                                match.row$WT14, match.row$WT15, match.row$WT16, match.row$WT17, 
                                match.row$WT21, match.row$WT22))
    colnames(w.df) <- weather.interest
    # create a new frame with the proper wtrack.subset.df data merged
    
  }
  # now we need to add these extra columns to the original wtrack.subset.id
}

# date is 'YYYY-MM-DD' (character)

# this means that for getting weather by date, you will need to open the corresponding stations2csv.df$CSV 
# which maps to each track and then find the important information from that data.
# Thinking of storing weather data separately from the incident data, but not sure



