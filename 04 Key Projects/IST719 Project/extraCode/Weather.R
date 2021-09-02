install.packages("devtools")
library(devtools)
sessionInfo()

#devtools::install_github("Ram-N/weatherData")
#install.packages("rwunderground")
#library(rwunderground)
devtools::install_github("ropensci/rnoaa")
install.packages("rnoaa")
library(rnoaa)
#update_packages()

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
wstation.track <- c(abc$`1`$id[1], abc$`2`$id[1], abc$`3`$id[1], abc$`4`$id[1],
                    abc$`5`$id[1], abc$`6`$id[3], abc$`7`$id[1], abc$`8`$id[1],
                    abc$`9`$id[1], abc$`10`$id[1], abc$`11`$id[1])
# now I hae a list of each station id
# START HERE
library(httr)
library(jsonlite)
library(lubridate)
options(stringsAsFactors = FALSE)
url <- "https://samples.openweathermap.org/data/2.5/history"
path <- "city?id=2885679&type=hour&appid=6a90ebf383b54a3368b396db6ea3f806"
raw.result <- GET(url = url, path = path)

# UGH
ncdc_datasets()
# this is what I want - but does not work
out <- ncdc(datasetid = "GHCND", stationid = paste0("GHCND:", wstation.track[5]),
            startdate = '2009-05-01', enddate = '2009-06-01')

out <- ncdc(datasetid = 'GHCND', stationid = 'GHCND:USW00014895', startdate = '2013-10-01',
     enddate = '2013-12-01')

# try HOMR
out <- homr(qid = paste0("GHCND:", wstation.track[1]),
            begindate = '2009-05-01', enddate = '2009-05-01')


out <- ncdc(datasetid='GHCND', stationid='GHCND:USW00014895', datatypeid='PRCP', 
            startdate = '2010-05-01', enddate = '2010-05-01', limit=500)

homr(qid = 'COOP:046742')
homr(qid = ':046742')
homr(qidMod='starts', qid='COOP:0467')
homr(headersOnly=TRUE, state='DE')
homr(headersOnly=TRUE, country='GHANA')
homr(headersOnly=TRUE, state='NC', county='BUNCOMBE')
homr(name='CLAYTON')
res <- homr(state='NC', county='BUNCOMBE', combine=TRUE)
res$id
res$head
res$updates
homr(nameMod='starts', name='CLAY')
homr(headersOnly=TRUE, platform='ASOS')
homr(qid='COOP:046742', date='2011-01-01')
test <- homr(qid='COOP:046742', begindate='2005-01-01', enddate='2005-01-01')
homr(state='DE', headersOnly=TRUE)
homr(station=20002078)
homr(station=20002078, date='all', phrData=FALSE)

ncdc(datasetid = 'GHCND', stationid = 'GHCND:USW00014895', 
     startdate = '2013-10-01', enddate = '2013-12-01')


# wunderground
loc <- rwunderground::set_location(territory="New York", city="Vernon")
history(loc, "20150101")
history(location, date = "20150101", use_metric = FALSE,
        key = get_api_key(), raw = FALSE, message = TRUE)

history(set_location(territory = "Hawaii", city = "Honolulu"), "20130101")
history(set_location(airport_code = "SEA"), "20130101")
history(set_location(zip_code = "90210"), "20130131")
history(set_location(territory = "IR", city = "Tehran"), "20140131")


# NOAA NWS REST API Example
# 3-hourly forecast for Lower Mannhattan (Zip Code: 10001)
library(httr)
library(XML)
url <- "http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdXMLclient.php"
response <- GET(url,query=list(zipCodeList="10001",
                               product="time-series",
                               begin=format(Sys.Date(),"%Y-%m-%d"),
                               Unit="e",
                               temp="temp",rh="rh",wspd="wspd"))
doc   <- content(response,type="text/xml")   # XML document with the data
# extract the date-times
dates <- doc["//time-layout/start-valid-time"]
dates <- as.POSIXct(xmlSApply(dates,xmlValue),format="%Y-%m-%dT%H:%M:%S")
# extract the actual data
data   <- doc["//parameters/*"]
data   <- sapply(data,function(d)removeChildren(d,kids=list("name")))
result <- do.call(data.frame,lapply(data,function(d)xmlSApply(d,xmlValue)))
colnames(result) <- sapply(data,xmlName)
# combine into a data frame
result <- data.frame(dates,result)
head(result)