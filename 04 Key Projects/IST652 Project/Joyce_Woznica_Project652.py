# 
# IST 652 - Scripting for Data Analysis
# Final Project: Racetrack Infractions and Incidents
# Author: Joyce Woznica
# Date: 6/7/2020
#
###------------------------------------ Import Packages --------------------------------------------------
# In this section, the packages required for the code are loaded
# These are the packages required for the entire program and no
# other imports are used later in the code
import pandas as pd
import numpy as np

# for plotting
import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib import cm
from matplotlib.colors import ListedColormap, LinearSegmentedColormap

# for date and time manipulation
import datetime as dt
import time

# packages for wordclouds
# note - must install wordcloud
# conda install -c conda-forge wordcloud
import collections
from wordcloud import WordCloud, STOPWORDS, ImageColorGenerator
from PIL import Image

# for manipulating strings
import string

# for colors
from colour import Color
import random
import matplotlib.colors as mcolors

# Import packages for tweets 
# (be sure to start Mongo DB)
import tweepy as tw
import json
import sys
import os
import pymongo

###-------------------------------------- Read in Data ------------------------------------------------------
# In this section, the two datasets (CSV files) used are read into a pandas dataframe
# Rulings file
rulingsFile = "/Users/joycewoznica/Syracuse/IST652/Project/data/horse-racing-rulings-beginning-1985.csv"
rulingsDF = pd.read_csv(rulingsFile)

# Death and Breakdown File
incidentFile = "/Users/joycewoznica/Syracuse/IST652/Project/data/Equine_Death_and_Breakdown.csv"
incidentDF = pd.read_csv(incidentFile)

###-------------------------- Review Data Structure, Data Clean-up -----------------------------------------
# In this section, the overall structures are reviewed. Some clean-up is done as per the comments
# review structure of the Rulings dataset
str(rulingsDF)
rulingsDF.shape
# 36790 rows and 14 columns

# get listing of all rows with a Fine Year <= 2008 (only interested in the last decade)
# this returns all the rows to remove (where the year is less than or equal to 2008)
indexNames = rulingsDF[rulingsDF['Fine Year'] <= 2008].index
# drop those rows
rulingsDF.drop(indexNames, inplace=True)
# review new shape of dataframe
rulingsDF.shape
# drops down to only 11,516 rows and 14 columns

# Review structure of the Incident dataset
str(incidentDF)
incidentDF.shape
# 4148 rows, 13 observations
# remove 2020 (since not yet over) from incidentDF using same method
indexNames = incidentDF[incidentDF['Year'] >= 2020].index
# drop those rows from the dataset
incidentDF.drop(indexNames, inplace=True)
# review new shape of dataframe
incidentDF.shape
# now down to 4152 rows and 13 columns

# Do we need to drop NaN or blanks
rulingsDF.isna().sum()
# drop the NaN notice date - will be required later
rulingsDF = rulingsDF[rulingsDF['Notice Date'].notna()]
# review new shape
rulingsDF.shape
# 11515 rows, 14 observations

# for presentation
print(rulingsDF.loc[1])
print(incidentDF.iloc[1])

###------------------------------------- Analysis -----------------------------------------------------------
## Which tracks have the most infractions?
# count infractions by Race Track
rulingsDFbyTrack = rulingsDF['Race Track'].value_counts()
# convert to dataframe
rulingsDFbyTrack = rulingsDFbyTrack.to_frame()
# index by Track Name
trackNames = rulingsDFbyTrack.index.values
# rename column to "Infractions"
rulingsDFbyTrack.columns = ['Infractions']

# Need to drop Main Office, none and New York Racing Association as these are not actual Track Names
rulingsDFbyTrack = rulingsDFbyTrack.drop(['Main Office', 'none', 'New York Racing Association'])
trackNames = rulingsDFbyTrack.index.values
# add column of track names
rulingsDFbyTrack['TrackName'] = trackNames

# plot with seaborn
fg = sns.catplot(x = "TrackName", y = "Infractions", hue = "TrackName", dodge=False,
                    height = 5, aspect = 2, palette="Spectral", kind="bar", data=rulingsDFbyTrack)
fg.set_xticklabels(rotation=45, horizontalalignment = 'right', 
                         fontweight = 'light', fontsize = 'medium')
fg.set(xlabel = "Race Track", ylabel = "Number of Infractions", 
       title = "Infractions by Race Track from 2009 - 2019")
            
###------------------------------------- Analysis -----------------------------------------------------------
## Are there more infractions in Harness or TB Racing?
# count infractions by Race Type: Harness or Thoroughbred
rulingsDFbyType = rulingsDF['Race Type'].value_counts()
# convert to dataframe
rulingsDFbyType = rulingsDFbyType.to_frame()
# rename columns
rulingsDFbyType.columns = ['Infractions']
# Need to remove blanks
rulingsDFbyType.isna()
# drop where Race Type is ? or unknown
rulingsDFbyType = rulingsDFbyType.drop(['?'])
# add column of race types for plotting
RaceTypes = rulingsDFbyType.index.values
rulingsDFbyType['RaceType'] = RaceTypes

# plot with seaborn
fg = sns.catplot(x = "RaceType", y = "Infractions", hue = "RaceType", dodge=False,
                    height = 3, aspect = 2, palette="Set1", kind="bar", data=rulingsDFbyType)
fg.set_xticklabels(horizontalalignment = 'center', 
                         fontweight = 'light', fontsize = 'medium')
fg.set(xlabel = "Race Type", ylabel = "Number of Infractions", 
       title = "Infractions by Race Type from 2009 - 2019")

###------------------------------------- Analysis -----------------------------------------------------------
## Are certain individuals receiving higher numbers of infractions that others?
# grab top 20 or 15 of the individuals (Full Name) and number of infractions sorted by highest to lowest
# count infractions by Full Name
rulingsDFbyName = rulingsDF['Full Name'].value_counts()
# convert to dataframe
rulingsDFbyName = rulingsDFbyName.to_frame()
# reindex by Full Name
FullNames = rulingsDFbyName.index.values
# Change column name
rulingsDFbyName.columns = ['Infractions']
# Need to remove blanks
rulingsDFbyName.isna()
# add column of race types for plotting
FullNames = rulingsDFbyName.index.values
rulingsDFbyName['FullName'] = FullNames
shortrulingsDFbyName = rulingsDFbyName.head(25)

# plot with seaborn
fg = sns.catplot(x = "FullName", y = "Infractions", hue = "FullName", dodge=False,
                    height = 6, aspect = 2, palette="Spectral", kind="bar", data=shortrulingsDFbyName)
fg.set_xticklabels(rotation = 45, horizontalalignment = 'right', 
                         fontweight = 'light', fontsize = 'medium')
fg.set(xlabel = "Full Name", ylabel = "Number of Infractions", 
       title = "Infractions by Individual (top 25) from 2009 - 2019")

###------------------------------------- Analysis -----------------------------------------------------------
## What occupation has the most infractions?
# count by Occupation
rulingsDFbyOccupation = rulingsDF['Occupation'].value_counts() 
# convert to dataframe
rulingsDFbyOccupation = rulingsDFbyOccupation.to_frame()
Occupations = rulingsDFbyOccupation.index.values
rulingsDFbyOccupation.columns = ['Infractions']
# Need to remove blanks
rulingsDFbyOccupation.isna().sum()
# reindex by Occupation
Occupations = rulingsDFbyOccupation.index.values
# Add column for Occupation
rulingsDFbyOccupation['Occupation'] = Occupations
# Grab just top 25 Occupations
shortrulingsDFbyOccupation = rulingsDFbyOccupation.head(25)

# plot with seaborn
fg = sns.catplot(x = "Occupation", y = "Infractions", hue = "Occupation", dodge=False,
                    height = 6, aspect = 2, palette="RdBu", kind="bar", data=shortrulingsDFbyOccupation)
fg.set_xticklabels(rotation = 45, horizontalalignment = 'right', 
                         fontweight = 'light', fontsize = 'medium')
fg.set(xlabel = "Occupation", ylabel = "Number of Infractions", 
       title = "Infractions by Top 25 Reported Occupations from 2009 - 2019")

###------------------------------------- Analysis -----------------------------------------------------------
## Track infractions over the years
# gather data by track and by year and then do something to calculate the values of both
str(rulingsDFbyTrack)
print(rulingsDFbyTrack.columns)
# create a cross table by Track and Fine Year
byTrackbyYear = pd.crosstab(rulingsDF['Race Track'], rulingsDF['Fine Year'])
# Drop those infractions that did not occur on an actual track
byTrackbyYear = byTrackbyYear.drop(['Main Office', 'none', 'New York Racing Association'])

# column names
print(byTrackbyYear.columns)
print(list(byTrackbyYear.columns))
# row names
print(byTrackbyYear.index.values)
# Change the index to the year by transposing the frame
byTrackbyYear = byTrackbyYear.transpose()
# reindex
byTrackbyYear['FineYear'] = byTrackbyYear.index.values
# melt the frame to get frame in required grouping format
melted_byTrackbyYear = pd.melt(byTrackbyYear, id_vars = "FineYear", 
                               var_name = "TrackName", value_name = "Infractions")

# need to do this a line plot by column (track) and then different color for each track
# set the plot size for better plotting
plt.rcParams['figure.figsize']=11,8
ax = plt.gca()
g = sns.lineplot(x = 'FineYear', y = 'Infractions', hue="TrackName", style = "TrackName", dashes = False, 
             legend = "full", marker = 'o', palette = "Dark2", data = melted_byTrackbyYear)
plt.title("Infractions by Fine Year by Race Track from 2009 - 2019", fontsize = 12)
plt.xlabel("Fine Year", fontsize = 10)
plt.ylabel("Infractions", fontsize = 10)
g.legend(loc="right", bbox_to_anchor = (1.42, 0.5), ncol = 1 )
l = np.arange(2009, 2020, 1)
ax.set(xticks=l, xticklabels = l)

###------------------------------------- Analysis -----------------------------------------------------------
## What is the Total Fine by Individual/Occupation?
# propertly group the fine data
rulingsDFbyFNO = rulingsDF.groupby(['Full Name', 'Occupation'])
# sum the fines
tFinesbyFNO = rulingsDFbyFNO.sum()

# reset index
tFinesbyFNO = tFinesbyFNO.reset_index()
# drop the Fine Year column
tFinesbyFNODF = tFinesbyFNO.drop(['Fine Year'], axis=1)
# rename the columns
tFinesbyFNODF.columns = ['FullName', 'Occupation', 'TotalFines']

# need to sort by descending Fine
tFinesbyFNODF = tFinesbyFNODF.sort_values(["FullName", "Occupation", "TotalFines"], 
                                          ascending =(True, True, False))
# remove all Fines smaller fines to get a more manageable grouping
min(tFinesbyFNODF.TotalFines)
max(tFinesbyFNODF.TotalFines)
# only look at fines that are greater than or equal to $4,000
tFinesbyFNODF = tFinesbyFNODF[tFinesbyFNODF.TotalFines >= 4000]
# sort by total fine
tFinedbyFNODF = tFinesbyFNODF.sort_values(["TotalFines"], ascending=(False))
# Do bar graph by person and a different color bar for each occupation w/i person
# plot with seaborn
fg = sns.catplot(x = "FullName", y = "TotalFines", hue = "Occupation", dodge=False,
                    height = 6, aspect = 2, palette="Dark2", kind="bar", data=tFinesbyFNODF)
fg.set_xticklabels(rotation = 75, horizontalalignment = 'right', 
                         fontweight = 'light', fontsize = 'small')
fg.set(xlabel = "Occupation", ylabel = "Total Fines", 
       title = "Total Fines by Individual/Occupation for totals over $4,000 from 2009 - 2019")

# drop out Luis Pena
tFinesbyFNODF = tFinesbyFNODF[tFinesbyFNODF.FullName != "LUIS PENA"]
# replot without Outlier
# plot with seaborn
fg = sns.catplot(x = "FullName", y = "TotalFines", hue = "Occupation", dodge=False,
                    height = 6, aspect = 2, palette="Dark2", kind="bar", data=tFinesbyFNODF)
fg.set_xticklabels(rotation = 75, horizontalalignment = 'right', 
                         fontweight = 'light', fontsize = 'small')
fg.set(xlabel = "Occupation", ylabel = "Total Fines", 
       title = "Total Fines by Individual/Occupation for totals over $4,000 from 2009 - 2019")

###------------------------------------- Analysis -----------------------------------------------------------
## Average Fine by Occupation
# Group appropriately
rulingsDFbyOcc = rulingsDF.groupby(['Occupation', 'Full Name'])
# obtain average (mean) fine 
aFinebyFNOcc = rulingsDFbyOcc.mean()
# reset index
aFinebyFNOcc = aFinebyFNOcc.reset_index()
# drop the Fine Year column
aFinebyFNOccDF = aFinebyFNOcc.drop(['Fine Year'], axis=1)
# rename the columns
#aFinebyFNOccDF.columns = ['FullName', 'Occupation', 'AvgFine']
avgFinebyOcc = aFinebyFNOccDF.groupby(["Occupation"])
# obtain the mean fine by occuptation
avgFinebyOccDF = avgFinebyOcc.mean()
# set a column for occupation
avgFinebyOccDF['Occupation'] = avgFinebyOccDF.index.values

# round to 2 decimal places
avgFinebyOccDF = avgFinebyOccDF.round({"Fine Amount":2})
avgFinebyOccDF.columns = ['AvgFine', 'Occupation']
# need to sort by descending Fine
avgFinebyOccDF = avgFinebyOccDF.sort_values(["AvgFine"], ascending=(False))
# determine what is the smallest average for plotting
min(avgFinebyOccDF.AvgFine)
max(avgFinebyOccDF.AvgFine)
# remove all fines under $50
avgFinebyOccDF = avgFinebyOccDF[avgFinebyOccDF.AvgFine > 50]

# Do bar graph by person and a different color bar for each occupation w/i person
# plot with seaborn
fg = sns.catplot(x = "Occupation", y = "AvgFine", hue = "Occupation", dodge=False,
                    height = 6, aspect = 3, palette="Spectral", kind="bar", data=avgFinebyOccDF)
fg.set_xticklabels(rotation = 80, horizontalalignment = 'right', 
                         fontweight = 'light', fontsize = 'small')
fg.set(xlabel = "Occupation", ylabel = "Average Fine in USD", 
       title = "Average Fine by Occupation over $50 from 2009-2019")

# drop out jocket-agent to get a better handle on the lower fines
avgFinebyOccDF = avgFinebyOccDF[avgFinebyOccDF.Occupation != "JOCKEY AGENT"]

# plot with seaborn
fg = sns.catplot(x = "Occupation", y = "AvgFine", hue = "Occupation", dodge=False,
                    height = 6, aspect = 3, palette="Spectral", kind="bar", data=avgFinebyOccDF)
fg.set_xticklabels(rotation = 80, horizontalalignment = 'right', 
                         fontweight = 'light', fontsize = 'small')
fg.set(xlabel = "Occupation", ylabel = "Average Fine in USD", 
       title = "Average Fine by Occupation over $50 without Jockey-Agent from 2009-2019")

###------------------------------------- Analysis -----------------------------------------------------------
## Tracks with highest number of infractions in Year/Month
# duplicate the origin dataframe
# must do some work on the dates for this to happen 
# this is also required or merging frames later in code
wDaterulingsDF = rulingsDF.copy()

# remove rulings related to main office, etc. as traditionally just licensing issues
wDaterulingsDF = wDaterulingsDF[wDaterulingsDF['Race Track'] != "Main Office"]
wDaterulingsDF = wDaterulingsDF[wDaterulingsDF['Race Track'] != "New York Racing Association"]
wDaterulingsDF = wDaterulingsDF[wDaterulingsDF['Race Track'] != "none"]
wDaterulingsDF.shape

notice_date = wDaterulingsDF['Notice Date']
# now convert to a data frame - hoping for matching indices
ndateDF = pd.DataFrame(notice_date)

mdyDF = []
mdyDF = pd.DataFrame(columns=['Infraction Date', 'Year', 'Month', 'Day'])

# warning - this takes a while 
# convert date to different format and create Year, Month and Day columns
for value in ndateDF['Notice Date']:
    # split out date
    yy = int(value[0:4])
    mm = int(value[5:7])
    dd = int(value[8:10])
    # convert date for new Infraction Date
    infdate = dt.datetime(yy, mm, dd).strftime('%m/%d/%Y')
    # convert month
    month = dt.date(yy, mm, dd).strftime('%B')
    mdyDF = mdyDF.append(pd.DataFrame({'Infraction Date': [infdate],
                           'Year': [yy],
                           'Month': [month],
                           'Day': [dd]}))

# reset the index properly
mdyDF = mdyDF.reset_index()
# remove bad index
mdyDF = mdyDF.drop(['index'], axis=1)

# need to add the columns from the other 
wDaterulingsDF['Month'] = mdyDF['Month']
wDaterulingsDF['Day'] = mdyDF['Day']
wDaterulingsDF['Infraction Date'] = mdyDF['Infraction Date']

# Now see which month in each year has the most infractions by racetrack
# after that - we check twitter to see if there is any tweets that month (+/- 5 days)
rulingsbyMYT_DF = wDaterulingsDF.groupby(['Fine Year', 'Month', 'Race Track'])
rulingsbyMYT_DF.groups
# now need to sum each by count racetrack for each year/month
# need something around value_counts()
arulingsbyMYT_DF = rulingsbyMYT_DF.size()
# This is what we need to graph by track, but need to do that stacking and reindexing
# reset index
arulingsbyMYT_DF = arulingsbyMYT_DF.reset_index()
# drop the Fine Year column
# rename the columns
arulingsbyMYT_DF.columns = ['Year', 'Month', 'Race Track', 'Infractions']
arulingsbyMYT_DF['Race Track'].unique()

# sort by descending infractions
arulingsbyMYT_DF = arulingsbyMYT_DF.sort_values(['Infractions', 'Race Track', 'Year', 'Month'],
                                                ascending=(False, True, True, True))
len(arulingsbyMYT_DF.Infractions)
# get max and minimum infractions - determine where to cut off data frame for tweet lookup
min(arulingsbyMYT_DF.Infractions)
max(arulingsbyMYT_DF.Infractions)
# remove all but the highest number of infractions by track by year/month
arulingsbyMYT_DF = arulingsbyMYT_DF[arulingsbyMYT_DF.Infractions > 28]
top_list = len(arulingsbyMYT_DF.Infractions)
# reindex the top by track
arulingsbyMYT_DF = arulingsbyMYT_DF.set_index('Race Track')

###------------------------------------- Analysis -----------------------------------------------------------
## What are the most common suspension timeframes by track?
## Average Suspension Days by Occupation
rulingsDF_dayS = rulingsDF.copy()
indexNames = rulingsDF_dayS[rulingsDF['Days Suspended'] == " "].index
# drop those rows from the dataset
rulingsDF_dayS.drop(indexNames, inplace=True)

# get rid of unnecessary columngs
rulingsDF_dayS = rulingsDF_dayS.drop(['Fine Year', 'Fine Amount', 'Notice Date', 
                                      'Rules', 'Notice'], axis=1)
rulingsDF_dayS['Days Suspended'].unique()
# replace the bad 'space 3' with '3'
rulingsDF_dayS = rulingsDF_dayS.replace(" 3", "3")
rulingsDF_dayS['Days Suspended'].unique()
# Need to remove row with date formatted field that should not be there
rulingsDF_dayS = rulingsDF_dayS[rulingsDF_dayS['Days Suspended'] != "8/21/2014"]
rulingsDF_dayS['Days Suspended'].unique()

# these are strings
days_SuspDF = rulingsDF_dayS['Days Suspended'].value_counts() 
# convert to dataframe
days_SuspDF = days_SuspDF.to_frame()
NumDays = days_SuspDF.index.values
days_SuspDF.columns = ['Value Count']
# add a column for Days Suspended
days_SuspDF['Days Suspended'] = NumDays
# cut out some of the numbers to make plot better
min(days_SuspDF['Value Count'])
max(days_SuspDF['Value Count'])
days_SuspDF = days_SuspDF[days_SuspDF['Value Count'] > 2]
# need to sort by highest value count
days_SuspDF = days_SuspDF.sort_values(['Value Count'], ascending=False)
result = days_SuspDF.groupby(["Days Suspended"])['Value Count'].aggregate(np.median).reset_index().sort_values('Value Count', ascending=False)
# plot with seaborn
fg = sns.catplot(x = "Days Suspended", y = "Value Count", hue = "Days Suspended", dodge=False,
                    height = 8, aspect = 2, palette="deep", kind="bar", data=days_SuspDF, order=result['Days Suspended'])
fg.set_xticklabels(horizontalalignment = 'center', 
                         fontweight = 'light', fontsize = 'medium')
fg.set(xlabel = "Days Suspended", ylabel = "Count of Suspension Period", 
       title = "Counts of Number of Days Suspended from 2009 - 2019")
###------------------------------------- Analysis -----------------------------------------------------------
## What is more common: Fine, Suspension, etc?
rulingsDFbyType = rulingsDF['Type'].value_counts()
# convert to dataframe
rulingsDFbyType = rulingsDFbyType.to_frame()
# index by Ruling Type
ruling_type = rulingsDFbyType.index.values
# rename column to "Infractions"
rulingsDFbyType.columns = ['Count']

# add column of track names
rulingsDFbyType['Ruling Type'] = ruling_type
# plot with seaborn
fg = sns.catplot(x = "Ruling Type", y = "Count", hue = "Ruling Type", dodge=False,
                    height = 6, aspect = 1.5, palette="deep", kind="bar", data=rulingsDFbyType)
fg.set_xticklabels(rotation=45, horizontalalignment = 'right', 
                         fontweight = 'light', fontsize = 'medium')
fg.set(xlabel = "Ruling Type", ylabel = "Number of Type", 
       title = "Ruling Types from 2009 - 2019")

###------------------------------------- Analysis -----------------------------------------------------------
## Are there any common words in the infraction descriptions
# Checking for null values in `description`
rulingsDF['Ruling Text'].isnull().sum()
# none, so we can continue
# subset out just the text about the ruling
textDF = rulingsDF['Ruling Text']
textDF = textDF.to_frame()
# convert all to lower case
textDF['Ruling Text'] = textDF['Ruling Text'].str.lower()
# grab all text together
all_text = textDF['Ruling Text'].str.split(' ')
all_text.head()
# create blank dataframe for individual words
all_text_nopunc = []
for text in all_text:
    text = [x.strip(string.punctuation) for x in text]
    all_text_nopunc.append(text)
all_text_nopunc[0]
text_ruling = [" ".join(text) for text in all_text_nopunc]

final_text_ruling = " ".join(text_ruling)
# see what is in the final text
final_text_ruling[:500]

# must remove "nbsp" which is non-breaking space from wordcloud_text
# Attempt 1
stopwords = set(STOPWORDS)
stopwords.update(["is", "of", "nbsp", "for", "the", "a", "he", "you", "to", 
                  "in", "with", "are", "new", "york", "state", "will", "hereby",
                  "quot", "may"])
# need to remove all numbers
wordcloud_text = WordCloud(stopwords=stopwords, collocations=False, background_color="white", 
                           colormap = 'nipy_spectral',
                           prefer_horizontal = 0.85,
                           max_font_size= 30, max_words=175).generate(final_text_ruling)
# show the plot
plt.figure(figsize = (15,15))
plt.axis("off")
plt.imshow(wordcloud_text, interpolation='bilinear')
plt.title("Top 175 Most Common Words in Infraction Descriptions", fontsize = 16)
plt.show()
    
# Attempt 2
# add additional information to try to rule out certain words to find more details
stopwords.update(["is", "of", "nbsp", "for", "the", "a", "he", "you", "to", 
                  "in", "with", "are", "new", "york", "state", "will", "hereby",
                  "quot", "may", "race", "racing", "pari-mutuel",
                  "driving", "license", "participate", "fined", "hereby", "suspension",
                  "licensing", "failed", "horse", "requirements", "notified", "commission",
                  "racetrack", "receipt", "board", "comply", "day", "consideration",
                  "gaming", "wagering", "purse", "quot", "1st", "2nd", "3rd", "4th", "5th",
                  "6th", "7th", "8th", "invoice", "january", "february", "march", "april",
                  "may", "june", "july", "august", "september", "october", "november", "december",
                  "suspended", "days", "violation", "pari", "mutuel"])
# need to remove all numbers
wordcloud_text = WordCloud(stopwords=stopwords, collocations=False, background_color="white", 
                           colormap = 'nipy_spectral',
                           prefer_horizontal = 0.85,
                           max_font_size= 30, max_words=175).generate(final_text_ruling)
# show the plot
plt.figure(figsize = (15,15))
plt.axis("off")
plt.imshow(wordcloud_text, interpolation='bilinear')
plt.title("Top 175 Most Common Words in Infraction Descriptions", fontsize = 16)
plt.show()

# Attempt 3
# add additional information to try to rule out certain words to find more details
stopwords.update(["is", "of", "nbsp", "for", "the", "a", "he", "you", "to", 
                  "in", "with", "are", "new", "york", "state", "will", "hereby",
                  "quot", "may", "race", "racing", "pari-mutuel",
                  "driving", "license", "participate", "fined", "hereby", "suspension",
                  "licensing", "failed", "horse", "requirements", "notified", "commission",
                  "racetrack", "receipt", "board", "comply", "day", "consideration",
                  "gaming", "wagering", "purse", "quot", "1st", "2nd", "3rd", "4th", "5th",
                  "6th", "7th", "8th", "9th", "invoice", "january", "february", "march", "april",
                  "may", "june", "july", "august", "september", "october", "november", "december",
                  "suspended", "days", "violation", "pari", "mutuel", "reason", "respondent", 
                  "nycrr", "hearing", "appeal", "rule", "employee", "fine", "rules", "general", 
                  "right", "employ", "sunday", "monday", "tuesday", "wednesday", "thursday",
                  "friday", "saturday", "sunday", "generally", "mr", "person", 
                  "downs", "statement", "calendar"])
# need to remove all numbers
wordcloud_text = WordCloud(stopwords=stopwords, collocations=False, background_color="white", 
                           colormap = 'Dark2',
                           prefer_horizontal = 0.85,
                           max_font_size= 30, max_words=175).generate(final_text_ruling)
# show the plot
plt.figure(figsize = (15,15))
plt.axis("off")
plt.imshow(wordcloud_text, interpolation='bilinear')
plt.title("Top 175 Most Common Words in Infraction Descriptions", fontsize = 16)
plt.show()

# Different representation of top words in pie graph (remove numbers)
filtered_text_ruling = [word for word in final_text_ruling.split() if word not in stopwords]
counted_word_ruling = collections.Counter(filtered_text_ruling)

word_count_ruling = {}

for letter, count in counted_word_ruling.most_common(20):
    if not (letter.isnumeric()):
        word_count_ruling[letter] = count
    
topwordDF = pd.DataFrame.from_dict(word_count_ruling, orient='index', columns = ['wordcount'])
len(topwordDF)
# pull out certain slices
explode_slices = (0.1, 0, 0, 0, 0.1, 0, 0, 0.1, 0, 0, 0, 0.1)
len(explode_slices)

colors = random.choices(list(mcolors.CSS4_COLORS.values()),k = len(topwordDF))
plot = topwordDF.plot.pie(y='wordcount', figsize=(12, 12),
                          explode=explode_slices, 
                          shadow = True, colors = colors,
                          labels = topwordDF.index)
# Fix for this plot
plt.title("Top 12 Most Used Words in Infraction Descriptions", fontsize = 16)
plot.legend(loc="right", bbox_to_anchor = (1.2, 0.5), ncol = 1 )

# plot this as some other plot type (bar)
# plot with seaborn
# add in the column for word
topwordDF['Word'] = topwordDF.index.values

fg = sns.catplot(x = "wordcount", y = "Word", hue = "Word", dodge=False,
                    height = 6, aspect = 3, palette="RdYlBu", kind="bar", data=topwordDF)
fg.set_xticklabels(rotation = 80, horizontalalignment = 'left', 
                         fontweight = 'light', fontsize = 'small')
fg.set(xlabel = "Word", ylabel = "Word Count", 
       title = "Top Words in Infraction Descriptions by Count")

###------------------------------Unstructured Data Analysis -------------------------------------------------
## Tweets concerning NYS Horse Racing 
# Twitter Keys for API
# ** NOTE: Sometimes this "hung" and I had to run the twitter code separately from
#          the other code in order for it to work.
CONSUMER_KEY = 'NeMSryEx2Uc6YFi8t74fHsFNe'
CONSUMER_SECRET = 'XlzCSmkKQM2OhrfO9r10p9fWNRNB1W2Qd8fLOHo0VcCET0ELqM'
OAUTH_TOKEN = '1259973954166456320-b5xXXSu7WUfTVLEjhXagRvYF6wzmiL'
OAUTH_SECRET = 'G3AbUXGLUEcobVTeJYlAzz29uiTQIKchSUfb1rVUFgoHI'

auth = tw.OAuthHandler(CONSUMER_KEY, CONSUMER_SECRET)
auth.set_access_token(OAUTH_TOKEN, OAUTH_SECRET)

# db_fns - courtesy of Dr. D. Landowski
# This function either starts or adds to an existing database and collection in Mongo
# Parameters:  
#   data - this should be a list of json objects, where each will be a collection element
#      in the DB stored under a unique ID key created by Mongo
#   DBname - the name of the database, either new or existing
#   DBcollection - the name of the collection, either new or existing
def save_to_DB (DBname, DBcollection, data):
    # connect to database server and just let connection errors fail the program
    client = pymongo.MongoClient('localhost', 27017)
    # save the results in a database collection
    #   change names to lowercase because they are not case sensitive
    #   and remove special characters like hashtags and spaces (other special characters may also be forbidden)
    DBname = DBname.lower()
    DBname = DBname.replace('#', '')
    DBname = DBname.replace(' ', '')
    DBcollection = DBcollection.lower()
    DBcollection = DBcollection.replace('#', '')
    DBcollection = DBcollection.replace(' ', '')

    # use the DBname and collection, which will create if not existing
    db = client[DBname]
    collection = db[DBcollection]   
        
    # add the data to the database
    collection.insert_many(data)
    print("Saved", len(data), "documents to DB collection", DBname, DBcollection)

# This function gets data from an existing DB and collection
# Parameters:  
#   DBname and DBcollection- the name of the database and collection, either new or existing
# Result:
#   data - returns all the data in the collection as a list of JSON objects
def load_from_DB (DBname, DBcollection):
    # connect to database server and just let connection errors fail the program
    client = pymongo.MongoClient('localhost', 27017)
    # use the DBname and collection, which will create if not existing
    db = client[DBname]
    collection = db[DBcollection]    
        
    # get all the data from the collection as a cursor
    docs = collection.find()
    #  convert the cursor to a list
    docs_bson = list(docs)
    docs_json_str = [dumps(doc) for doc in docs_bson]
    docs_json = [json.loads(doc) for doc in docs_json_str]
    return docs_json

# Simple search using tweepy
# result_tweets = simple_search(api, query, max_results=num_tweets)
def simple_search(api, query, since, until, max_results=500):
  # the first search initializes a cursor, stored in the metadata results,
  #   that allows next searches to return additional tweets
  #search_results = [status for status in tw.Cursor(api.search, q=query).items(max_results)]
  search_results = tw.Cursor(api.search,
                             q=search_words,
                             lang="en",
                             since=date_since,
                             until=date_until).items(max_results)
  
  # for each tweet, get the json representation
  tweets = [tweet._json for tweet in search_results]
  return tweets

# tie all these together for a single call to all functions
def run_simple_tweet_search(query, num_tweets, since, until, DBname, DBcollection):
    # api = oauth_login()
    ''' if needed switch to using the appauth login to avoid rate limiting '''
    #api = appauth_login()
    api = tw.API(auth, wait_on_rate_limit=True)

    print ("Twitter Authorization: ", api)
    
    # access Twitter search
    result_tweets = simple_search(api, query, since, until, max_results=num_tweets)
    tot_results = len(result_tweets)
    print ('Number of result tweets: ', len(result_tweets))

    # save the results in a database collection
    #   change names to lowercase because they are not case sensitive
    #   and remove special characters like hashtags and spaces (other special characters may also be forbidden)
    DBname = DBname.lower()
    DBname = DBname.replace('#', '')
    DBname = DBname.replace(' ', '')
    DBcollection = DBcollection.lower()
    DBcollection = DBcollection.replace('#', '')
    DBcollection = DBcollection.replace(' ', '')
    
    # use the save and load functions in this program
    # in this, we do not want any retweeted tweets - only originals
    if tot_results > 0:
        save_to_DB(DBname, DBcollection, result_tweets)
    # Done!

# check Twitter
# Set common variables for runs
tweets_to_return = 375
dbname = "racedb"
collname = "racecoll"

# so - just ran tweets on all racetracks and the common hashtags and users
date_since = "2019-01-01"
# get today's date
date_until = time.strftime("%Y-%m-%d")
search_wordsList = ["#aqueductracetrack", "@BDRacetrack", "#belmontpark", "@BelmontStakes", 
                    "@BufffaloRaceway", "#buffaloraceway", "@FLGaming", "#fingerlakesracetrack", 
                    "#monticelloraceway", "@gotiogadowns", "#tiogadowns", "@governondowns", 
                    "#vernondowns", "@YonkersRaceway", "#yonkersraceway", "@racingwrongs", 
                    "@HR_Nation", "@TheNYRA", "@NYSGamingComm", "@NYRBets", 
                    "@trotinsider", "#harnessracing", "@Equibase"]

for search_words in search_wordsList:
    print(search_words)
    run_simple_tweet_search(search_words, tweets_to_return, date_since, date_until, dbname, collname)

# build a database of just the last 1000 tweets from racingwrongs
tweets_to_return = 1000
search_wordsList = ["@racingwrongs"]

# put them in their own database and collection
dbname = "racewrongdb"
collname = "racewrongcoll"

for search_words in search_wordsList:
    print(search_words)
    run_simple_tweet_search(search_words, tweets_to_return, date_since, date_until, dbname, collname)

# Get Tweet_List for building pandas dataframe - build one for each tweet_list
# for racedb
client = pymongo.MongoClient('localhost', 27017)
db = client.racedb
coll = db.racecoll
# Get tweets
tweets = coll.find()
# Create list of tweets - tweet_list
tweet_list = [tweet for tweet in tweets]

# same for racing wrongs
# Get Tweet_List for building pandas dataframe
db = client.racewrongdb
coll = db.racewrongcoll
# Get tweets
tweets = coll.find()
# Create list of tweets - rwtweet_list
rwtweet_list = [tweet for tweet in tweets]

# Convert previously selected fields into a pandas dataframe for analysis
def tweets_to_pd(tweets):
    df = pd.DataFrame()
    for tweet in tweets:
        if not tweet['entities'].get('media') is None:
            for m in tweet['entities'].get('media'):
                content_type =  m.get('type')
        else:
            content_type = "None"
        data = {'id':str(tweet['id'])
               ,'user':tweet['user']['name']
               ,'text':tweet['text']
               ,'Timestamp': tweet['created_at']
               ,'location':tweet['user']['location']
               ,'content type':content_type
               ,'favorites':tweet['favorite_count']
               ,'retweets':tweet['retweet_count']
              }
        # remove retweets
        if not(tweet['text'].startswith('RT')):
            df = df.append(data,ignore_index=True)
    return df

tweets_DF = tweets_to_pd(tweet_list)
rwrong_DF = tweets_to_pd(rwtweet_list)

# Run Wordcloud: racing accounts and hashtags
tweets_DF['text'].isnull().sum()
# none, so we can continue

# subset out just the text about the ruling
tweetDF = tweets_DF['text']
tweetDF = tweetDF.to_frame()

# convert all to lower case
tweetDF['text'] = tweetDF['text'].str.lower()

# grab all text together
all_tweets = tweetDF['text'].str.split(' ')
all_tweets.head()

# create blank dataframe for individual words
all_tweets_nopunc = []

for tweet in all_tweets:
    tweet = [x.strip(string.punctuation) for x in tweet]
    all_tweets_nopunc.append(tweet)

all_tweets_nopunc[0]
tweet_ruling = [" ".join(tweet) for tweet in all_tweets_nopunc]

final_tweet_ruling = " ".join(tweet_ruling)
# see what is in the final text
final_tweet_ruling[:500]

# set stopwords
stopwords = set(STOPWORDS)
stopwords.update(["rt"])

# plot wordcloud
wordcloud_text = WordCloud(stopwords=stopwords, collocations=False, background_color="white", 
                           colormap = 'Set1',
                           prefer_horizontal = 0.95,
                           max_font_size= 30, max_words=175).generate(final_tweet_ruling)
# show the plot
plt.figure(figsize = (15,15))
plt.axis("off")
plt.imshow(wordcloud_text, interpolation='bilinear')
plt.title("Most Recent Top 175 Most Common Words in Tweets about Racing", fontsize = 16)
plt.show()

# clean up by removing some account names           
# Massage the stopwords
stopwords.update(["rt", "https", "ejxd2", "hf6y7ysgeg", "co"])
# plot wordcloud
wordcloud_text = WordCloud(stopwords=stopwords, collocations=False, background_color="white", 
                           colormap = 'Set1',
                           prefer_horizontal = 0.95,
                           max_font_size= 30, max_words=175).generate(final_tweet_ruling)
# show the plot
plt.figure(figsize = (15,15))
plt.axis("off")
plt.imshow(wordcloud_text, interpolation='bilinear')
plt.title("Most Recent Top 175 Most Common Words in Tweets about Racing", fontsize = 16)
plt.show()                 
         
# clean up again by removing all the different tracks            
stopwords.update(["rt", "https", "ejxd2", "hf6y7ysgeg", "co", "thenyra", "nysgamingcomm",
                  "equibase", "hr_nation", "nyrabets", "racingwrongs", "amp", "thenyra"])

# plot wordcloud
wordcloud_text = WordCloud(stopwords=stopwords, collocations=False, background_color="white", 
                           colormap = 'ocean',
                           prefer_horizontal = 0.95,
                           max_font_size= 30, max_words=175).generate(final_tweet_ruling)
# show the plot
plt.figure(figsize = (15,15))
plt.axis("off")
plt.imshow(wordcloud_text, interpolation='bilinear')
plt.title("Most Recent Twitter: Top 175 Most Common Words in Tweets about Racing", fontsize = 14)
        
# Run Wordcloud: racingwrongs
# repeat (as mentioned - need to make a function) for racingwrongs
rwrong_DF['text'].isnull().sum()
# none, so we can continue

# subset out just the text about the ruling
rwrongDF = rwrong_DF['text']
rwrongDF = rwrongDF.to_frame()

# convert all to lower case
rwrongDF['text'] = rwrongDF['text'].str.lower()

# grab all text together
all_tweets = rwrongDF['text'].str.split(' ')
all_tweets.head()

# create blank dataframe for individual words
all_tweets_nopunc = []

for tweet in all_tweets:
    tweet = [x.strip(string.punctuation) for x in tweet]
    all_tweets_nopunc.append(tweet)

all_tweets_nopunc[0]
tweet_ruling = [" ".join(tweet) for tweet in all_tweets_nopunc]

final_tweet_ruling = " ".join(tweet_ruling)
# see what is in the final text
final_tweet_ruling[:500]

# set stopwords
stopwords = set(STOPWORDS)
stopwords.update(["rt", "https", "co", "oyq9jtw09s", "raypowe94432684", "racingwrongs","via",
                  "hejtkjhpvh", "lisakayemundy", "k7ig8vveut", "britneyeurton", "amp", 
                  "mkn8gn9ank", "f5clpn9jka", "ndbig7ajnb", "mknBgn9ank", "xzayamkox2",
                  "robbiesaunders0", "yvsavh7aje", "lvzz1asvvo", "angelagirl7777",
                  "x00rwydr17", "alameda140", "xdevtgq4s3", "cc88mksaee", "6zsgbfb17w",
                  "fvjhhqpjfp", "uuyzyamb1y", "vi40kbw5zs", "ae8sz18udm", "xdevtfq4s3",
                  "cr2dup8uqt", "kyyxa1nbrk", "eacnoqukukd", "tddifi8ryb", "y1q0hkb1kh"])

# plot wordcloud
wordcloud_text = WordCloud(stopwords=stopwords, collocations=False, background_color="black", 
                           colormap = 'Accent',
                           prefer_horizontal = 0.95,
                           max_font_size= 30, max_words=175).generate(final_tweet_ruling)
# show the plot
plt.figure(figsize = (15,15))
plt.axis("off")
plt.imshow(wordcloud_text, interpolation='bilinear')
plt.title("Most Recent Twitter: Top 175 Most Common Words from @racingwrongs", fontsize = 16)
plt.show()                

###--------------------------------- Merged Data Set Analysis ---------------------------------------------
## Merge Datasets on both Dates and Tracks 
# first make dates match - accomplished this in tweet section
# Notice Date is in format: 2019-02-09T00:00:00.000
# Incident Date is format: 02/17/2020
# Track is in rulingsDF now in wDaterulingsDF which has dates that match Incident Date
# Race Track is in incidentDF
# make new frames so can drop columns
rulings_formergeDF = wDaterulingsDF.copy()
incident_formergeDF = incidentDF.copy()

# drop unneeded columns from each data frame
rulings_formergeDF = rulings_formergeDF.drop(columns=['Notice', 'Notice Date', 'Rules', 'Fine Amount',
                                                      'Suspension Start', 'Suspension End', 
                                                      'Days Suspended', 'Month', 'Day'])
incident_formergeDF = incident_formergeDF.drop(columns=['Inv Location', 'Racing Type Description',
                                                        'Weather Conditions', 'Death or Injury'])

# Now dates are in proper format - must match the naming convention for merging
# - Infraction Date (wDaterulingsDF) to Incident Date (incidentDF)
# - Race Track (wDaterulingsDF) and Track (incidentD)
# Change columns to "Date" and "Track" in both frames in preparation for join
rulings_formergeDF.rename(columns={'Race Track':'Track', 
                                   'Infraction Date':'Date',
                                   'Fine Year':'Year',
                                   'Race Type':'Division'}, inplace=True)
incident_formergeDF.rename(columns={'Incident Date':'Date'}, inplace=True)

# merge the dataframes
mergedDF = rulings_formergeDF.merge(incident_formergeDF, how = 'inner', on = ['Year', 'Date', 'Track', 'Division'])

# rearrange the order of the dataframe columns
print(list(mergedDF.columns))
len(list(mergedDF.columns))
mergedDF = mergedDF[['Year', 'Date', 'Track', 'Division', 'Occupation', 
                     'Full Name', 'Trainer', 'Jockey Driver', 'Horse', 
                     'Incident Type', 'Type', 'Ruling Text', 'Incident Description']]

# see if any of the 'Full Name' matches any names from the Incident data set
# iterate through each row and select  
# 'Name' and 'Percentage' column respectively. 
for index,row in mergedDF.iterrows(): 
    if row["Full Name"] == row["Jockey Driver"]:
        print("Matching Full Name and Jockey Driver")
        print(row)
    if row["Full Name"] == row["Trainer"]:
        print("Matching Full Name and Trainer")
        print(row)

mergedDF_grouped = mergedDF.groupby(['Incident Type', 'Track', 'Date'])
mergedDF_grouped.groups
# now need to sum each by count racetrack for each year/month
# need something around value_counts()
mergedDF_grouped = mergedDF_grouped.size()
# This is what we need to graph by track, but need to do that stacking and reindexing
# reset index
mergedDF_grouped = mergedDF_grouped.reset_index()
# rename the columns
mergedDF_grouped.columns = ['Incident Type', 'Track', 'Date', 'Incident Count']
# sort the data
mergedDF_grouped = mergedDF_grouped.sort_values(by=['Date'], ascending=True)
# plot with seaborn

# scatterplot by date showing track and incident type
# date is X, count is Y
# color = track
# shape is incident type
plt.rcParams['figure.figsize']=15,8
g = sns.scatterplot(data = mergedDF_grouped, x = 'Date', y = 'Incident Count', hue = 'Track', 
               palette = 'Dark2', style = 'Incident Type', s=55)
plt.xticks(rotation=90, horizontalalignment = 'center', 
           fontweight = 'light', fontsize = 'small')
plt.title("Racing Incidents by Date, Track and Type", fontsize = 12)
plt.xlabel("Date", fontsize = 10)
plt.ylabel("Incident Count", fontsize = 10)

# plot incidents numbers in merged dataset
# despite no matching incidents - does any incident on the track
# correlate to equine death on the track
mergedDF_Incident = mergedDF['Incident Type'].value_counts()
# convert to dataframe
mergedDF_Incident = mergedDF_Incident.to_frame()
# index by Track Name
incidents = mergedDF_Incident.index.values
# rename column to "Infractions"
mergedDF_Incident.columns = ['Incident Counts']
mergedDF_Incident['Incident Type']=incidents
len(incidents)
# pull out certain slices
explode_slices = (0.1, 0, 0, 0, 0)
len(explode_slices)

colors = random.choices(list(mcolors.CSS4_COLORS.values()),k = len(incidents))
plot = mergedDF_Incident.plot.pie(y='Incident Counts', figsize=(6,6),
                          explode=explode_slices, 
                          shadow = True, colors = colors,
                          labels = mergedDF_Incident.index)
# Fix for this plot
plt.title("Incident Type Counts matching Racing Day Infractions", fontsize = 16)
plot.legend(loc="right", bbox_to_anchor = (1.75, 0.5), ncol = 1 )

# plot this as some other plot type (bar)
# plot with seaborn
fg = sns.catplot(x = "Incident Counts", y = "Incident Type", hue = "Incident Type", dodge=False,
                    height = 2, aspect = 4, palette="deep", kind="bar", data=mergedDF_Incident)
fg.set_xticklabels(horizontalalignment = 'center', 
                         fontweight = 'light', fontsize = 'small')
fg.set(xlabel = "Incident Type", ylabel = "Incident Counts", 
       title = "Incident Type Counts matching Racing Day Infractions from 2009 - 2019")


