# 
# IST 664 - Natural 
# Final Project: Classification of Death, Euthansia or Injury on NYS Racetracks
# Author: Joyce Woznica
# Date: 9/15/2020
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

# for colors
from colour import Color
import random
import matplotlib.colors as mcolors

# packages for wordclouds
# note - must install wordcloud
# conda install -c conda-forge wordcloud
import collections
from wordcloud import WordCloud, STOPWORDS, ImageColorGenerator
from PIL import Image

# for manipulating strings
import string

# Import packages
import nltk, re, collections
from nltk.corpus import PlaintextCorpusReader
from nltk.corpus import stopwords
from nltk.stem import PorterStemmer
from nltk.tokenize import WordPunctTokenizer
from nltk.collocations import *
from nltk.metrics import BigramAssocMeasures
from nltk import FreqDist
from nltk import bigrams 
from nltk.util import ngrams
from nltk.probability import DictionaryProbDist

# for stemming
from nltk import punkt
from nltk.stem import PorterStemmer
from nltk.stem import LancasterStemmer

# for classification and prediction
from sklearn import preprocessing
from sklearn.svm import LinearSVC
from sklearn.naive_bayes import MultinomialNB
from sklearn.model_selection import cross_val_predict
from sklearn.naive_bayes import GaussianNB
from sklearn.metrics import classification_report
from sklearn.metrics import confusion_matrix
from sklearn.linear_model import LogisticRegression

###-------------------------------------- Read in Data ------------------------------------------------------
# In this section, the dataset (CSV files) will be read into a pandas dataframe
# Death and Breakdown File
incidentFile = "/Users/joycewoznica/Syracuse/IST664/FinalProject/data/Equine_Death_and_Breakdown.csv"
incidentDF = pd.read_csv(incidentFile)

# make a copy of the frame if I want to go back to it
incidentDForig = incidentDF.copy()

###-------------------------- Review Data Structure, Data Clean-up -----------------------------------------
# In this section, the overall structure of the data is reviewed. Some clean-up is done as per the comments
# Review structure of the Incident dataset
str(incidentDF)
incidentDF.shape
# 4220 rows, 13 observations

# any NAs?
incidentDF.isna().sum()

###------------------------------------- Initial Analysis before Data Manipulation -------------------------
## What are the types of incidents?
incidentDFbyIncType = incidentDF['Incident Type'].value_counts()
# convert to dataframe
incidentDFbyIncType = incidentDFbyIncType.to_frame()
# index by Incident Type
incidentTypes = incidentDFbyIncType.index.values
# rename column to "Incidents"
incidentDFbyIncType.columns = ['Incidents']
# create a column for Incident Types
incidentDFbyIncType['Incident Type'] = incidentTypes

# plot with seaborn - Vertical
fg = sns.catplot(x = "Incident Type", y = "Incidents", hue = "Incident Type", dodge=False,
                    height = 5, aspect = 2, palette="Spectral", kind="bar", data=incidentDFbyIncType)
fg.set_xticklabels(rotation=45, horizontalalignment = 'right', 
                         fontweight = 'light', fontsize = 'medium')
fg.set(xlabel = "Incident Type", ylabel = "Number of Incidents", 
       title = "Number of Incidents by Incident Type from 2009 - present")

# plot with seaborn - Horizontal
fg = sns.catplot(x = "Incidents", y = "Incident Type", hue = "Incident Type", dodge=False,
                    height = 5, aspect = 2, palette="Spectral", kind="bar", data=incidentDFbyIncType)
fg.set_xticklabels(rotation=45, horizontalalignment = 'right', 
                         fontweight = 'light', fontsize = 'medium')
fg.set(xlabel = "Number of Incidents", ylabel = "Incident Type", 
       title = "Number of Incidents by Incident Type from 2009 - present")          

# Now look at Death or Injury the same way
## What is in Death and Injury?
incidentDFbyDI = incidentDF['Death or Injury'].value_counts()
# convert to dataframe
incidentDFbyDI = incidentDFbyDI.to_frame()
# index by Death or Injury
DITypes = incidentDFbyDI.index.values
# Need to deal with blank value
DITypes[0] = "Unknown"
# rename column to "Frequency"
incidentDFbyDI.columns = ['Frequency']
# create a column for the Death or Injury
incidentDFbyDI['Outcome'] = DITypes

# plot with seaborn - Horizontal
fg = sns.catplot(x = "Frequency", y = "Outcome", hue = "Outcome", dodge=False,
                    height = 6, aspect = 3, palette="Spectral", kind="bar", data=incidentDFbyDI)
fg.set_xticklabels(rotation=45, horizontalalignment = 'right', 
                         fontweight = 'light', fontsize = 'medium')
fg.set(xlabel = "Number of Incidents", ylabel = "Death or Injury Type", 
       title = "Frequency of by Death or Injury from 2009 - present")

# Need to do some investigation on the following
# - Unknown
# - Equine Death, Equine Injury/Equine Death, Death, death - are they all horse death?
# - Maybe remove steward list?
# - Maybe combine Injury, Equine Injury and Lameness?

# good color maps: coolwarm, twilight, twilight_shifted, seismic, Spectral, Dark2, ocean, 
#                  terrain, Set1, gist_stern, cubehelix, gist_earth, nipy_spectral,
#                  viridis, inferno, magma, plasma, cividis
# prism, gnuplot, , hsv, gist_rainbow, gist_ncar

# Now need to look at way to pair Incident Type and Death or Injury to see what they are
# Create a DF of just the Incident Type, Death or Injury and the Incident Description
collapsedDF = incidentDF[['Incident Type', 'Death or Injury', 'Incident Description']].copy()

# Maybe create a column of the combinations and then determine what to predict...
# need to create an "outcome" column that is created from reviewing the incident type and the death 
# or injury columns
outcomeDF = []
outcomeDF = pd.DataFrame(columns=['Outcome'])

# parse dataframe and set up outcome column
for index,row in collapsedDF.iterrows():
    outcome = ""
    itemIT = row['Incident Type']
    itemDI = row['Death or Injury']
    itemDesc = row['Incident Description']
    # was Equine Death
    if itemIT == "EQUINE DEATH":
        if itemDI == "Equine Death" or itemDI == "Death" or itemDI == "death"  or itemDI == " ":
            outcome = "Death"
        # Euthanisia
        if itemDI == "Euthanasia" or itemDI == "Injury":
            outcome = "Euthanasia"
    # Horse Injury
    if itemIT == "RACING INCIDENT":
        if itemDI == "Injury":
            outcome = "Injury"
    if itemIT == "RACING INJURY":
        if itemDI == "Injury":
            outcome = "Injury"
        if itemDI == "Accident":
            outcome = "Accident"
    if itemIT == "BREAKDOWN":
        if itemDI == "Injury":
            outcome = "Injury"
    if itemIT == "FALL OF HORSE":
        if itemDI == "Injury":
            outcome = "Injury"
        if itemDI == "Equine Death":
            outcome = "Death"
        if itemDI == "Euthanasia":
            outcome = "Eunthansia"
    # Accident
    if itemIT == "ACCIDENT - TAGGED SULKY":
        outcome = "Accident"
        
    # Lame or Injury
    if itemIT == "STEWARDS/VETS LIST":
        if itemDI == "Lameness" or itemDI == "Lame no Death":
            outcome = "Lameness"
        if itemDI == "Injury":
            outcome = "Injury"
    
    # fix incorrectly tagged information
    if itemDesc.find("vann",0,len(itemDesc)) != -1:
        outcome = "Injury"
    if itemDesc.find("euthan",0,len(itemDesc)) != -1:
        outcome = "Euthanasia"
    
    # dump poorly tagged information in the "Other" category
    if outcome == "":
        outcome = "Other"
    # update dataframe 
    outcomeDF = outcomeDF.append(pd.DataFrame({'Outcome': [outcome]}))
            
# reset the index properly
outcomeDF = outcomeDF.reset_index()
# remove bad index
outcomeDF = outcomeDF.drop(['index'], axis=1)
# need to add the columns from the other  to the original dataframe
incidentDF['Outcome'] = outcomeDF['Outcome']

# ready for plotting
incidentDFbyOutcome = incidentDF['Outcome'].value_counts()
# convert to dataframe
incidentDFbyOutcome = incidentDFbyOutcome.to_frame()
# index by Incident Type
outcomes = incidentDFbyOutcome.index.values
# rename column to "Incidents"
incidentDFbyOutcome.columns = ['Frequency']
# create a column for Incident Types
incidentDFbyOutcome['Outcome'] = outcomes

# plot with seaborn - Horizontal
fg = sns.catplot(x = "Frequency", y = "Outcome", hue = "Outcome", dodge=False,
                    height = 5, aspect = 2, palette="Spectral", kind="bar", data=incidentDFbyOutcome)
fg.set_xticklabels(rotation=45, horizontalalignment = 'right', 
                         fontweight = 'light', fontsize = 'medium')
fg.set(xlabel = "Frequency of Outcomes", ylabel = "Outcome", 
       title = "Frequency of Outcomes on NYS Race Tracks from 2009 - present")          

# new dataframe for analysis
incidentSubDF = incidentDF[['Incident Type', 'Death or Injury', 'Outcome', 'Incident Description']].copy()

# Keep this version for further classification with more outcomes provided
incidentBigDF = incidentSubDF.copy()
incidentFullDF = incidentSubDF.copy()
# now need to combine "Inury, Lameness and Accident into "Injury" and drop "Other" outcomes
# This still has Lameness
incidentSubDF.loc[incidentSubDF['Outcome'] == 'Lameness'] = "Injury"
incidentDF.loc[incidentDF['Outcome'] == 'Lameness'] = "Injury"
incidentSubDF.loc[incidentSubDF['Outcome'] == 'Accident'] = "Injury"
incidentDF.loc[incidentDF['Outcome'] == 'Accident'] = "Injury"
# drop Outcome
indexNames = incidentSubDF[(incidentSubDF['Outcome'] == "Other")].index
incidentSubDF.drop(indexNames, inplace=True)
incidentDF.drop(indexNames, inplace=True)
# reduced dataset to 2179 rows

# Just remove the Other column and keep rest for classification
# these will be used later in the classification section
incidentFullDF = incidentBigDF.copy()
incidentBigDF.drop(indexNames, inplace=True)

# Plot new smaller dataset and information by Outcome
incidentDFbyOutcome = incidentDF['Outcome'].value_counts()
# convert to dataframe
incidentDFbyOutcome = incidentDFbyOutcome.to_frame()
# index by Incident Type
outcomes = incidentDFbyOutcome.index.values
# rename column to "Incidents"
incidentDFbyOutcome.columns = ['Frequency']
# create a column for Incident Types
incidentDFbyOutcome['Outcome'] = outcomes

# plot with seaborn - Horizontal
fg = sns.catplot(x = "Frequency", y = "Outcome", hue = "Outcome", dodge=False,
                    height = 5, aspect = 2, palette="Spectral", kind="bar", data=incidentDFbyOutcome)
fg.set_xticklabels(rotation=45, horizontalalignment = 'right', 
                         fontweight = 'light', fontsize = 'medium')
fg.set(xlabel = "Frequency of Outcomes", ylabel = "Outcome", 
       title = "Frequency of Outcomes on NYS Race Tracks from 2009 - present")          

###------------------------------------- Word Cloud Analysis ---------------------------------------------
## Are there any common words in the incident descriptions
# Checking for null values in `description`
incidentDF['Incident Description'].isnull().sum()
# none, so we can continue
# subset out just the text about the incident
textDF = incidentDF['Incident Description']
textDF = textDF.to_frame()
# convert all to lower case
textDF['Incident Description'] = textDF['Incident Description'].str.lower()
# grab all text together
all_text = textDF['Incident Description'].str.split(' ')
all_text.head()
# create blank dataframe for individual words
all_text_nopunc = []

# remove punctuation
for text in all_text:
    text = [x.strip(string.punctuation) for x in text]
    all_text_nopunc.append(text)
all_text_nopunc[0]
text_desc = [" ".join(text) for text in all_text_nopunc]

# this is the step that makes this a single set of words not separated
# by incident type which can be used for bigrams and more
final_text_desc = " ".join(text_desc)
# see what is in the final text
final_text_desc[:500]

# need to replace "/" with space
final_text_desc = final_text_desc.replace("/"," ")
# need to replace the "-" with a space
final_text_desc = final_text_desc.replace("-", " ")

# remove extra spaces?
final_text_desc = final_text_desc.replace("  ", " ")
final_text_desc = final_text_desc.replace("  ", " ")
len(final_text_desc)

# Attempt 1
# remove only standard 179 stop words
stopwords = set(STOPWORDS)
# need to remove all numbers
wordcloud_text = WordCloud(stopwords=stopwords, collocations=False, background_color="white", 
                           colormap = 'Dark2',
                           prefer_horizontal = 0.85,
                           max_font_size= 30, max_words=200).generate(final_text_desc)
# show the plot
plt.figure(figsize = (15,15))
plt.axis("off")
plt.imshow(wordcloud_text, interpolation='bilinear')
plt.title("Top 200 Most Common Words in Incident Descriptions", fontsize = 16)
plt.show()
    
# Attempt 2: Note - this is the FIRST wordcloud in the report
# add additional information to try to rule out certain words to find more details
# remove tr, trn (for trainer) and jr (for name Junior)
stopwords.update(["tr", "trn", "jr"])
# other words that look like they should be removed are actually diagonosis information:
# rf - right front
# fx - fracture
# dnf - did not finish
# lf - left front
wordcloud_text = WordCloud(stopwords=stopwords, collocations=False, background_color="white", 
                           colormap = 'Dark2',
                           prefer_horizontal = 0.85,
                           max_font_size= 30, max_words=200).generate(final_text_desc)
# show the plot
plt.figure(figsize = (15,15))
plt.axis("off")
plt.imshow(wordcloud_text, interpolation='bilinear')
plt.title("Top 200 Most Common Words in Incident Descriptions", fontsize = 16)
plt.show()

# Attempt 3 - Remove personal names
stopwords.update(["michael", "john", "robert", "todd", "rodriguez", "englehart", "mark", "rudy",
                  "david", "bruce", "gary", "james", "will", "william", "linda", "richard", "joseph",
                  "chris", "ferraro", "paul", "thomas", "jose", "pletcher", "levine", "christopher",
                  "jacobson", "mike", "contessa", "krubera", "gullo", "morales", "edward", "belmont", 
                  "jeremiah", "chad", "ray", "patrick"])

wordcloud_text = WordCloud(stopwords=stopwords, collocations=False, background_color="white", 
                           colormap = 'Set1',
                           prefer_horizontal = 0.85,
                           max_font_size= 30, max_words=200).generate(final_text_desc)
# show the plot
plt.figure(figsize = (15,15))
plt.axis("off")
plt.imshow(wordcloud_text, interpolation='bilinear')
plt.title("Top 200 Most Common Words in Incident Descriptions", fontsize = 16)
plt.show()

# Different representation of top words in pie graph (remove numbers)
filtered_text_desc = [word for word in final_text_desc.split() if word not in stopwords]
counted_word_desc = collections.Counter(filtered_text_desc)

word_count_desc = {}

for letter, count in counted_word_desc.most_common(12):
    if not (letter.isnumeric()):
        word_count_desc[letter] = count
    
topwordDF = pd.DataFrame.from_dict(word_count_desc, orient='index', columns = ['wordcount'])
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
plt.title("Top 12 Most Used Words in Incident Descriptions", fontsize = 16)
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
       title = "Top Words in Incident Descriptions by Count")

###------------------------------Unstructured Data Analysis -------------------------------------------------
# Unigrams, Bigrams and Trigrams
# list of existing variables
# text_desc - list of each observation with text withput punctuation in sentences
# filtered_text_desc - text as an array (tokenized text)
# final_text_desc - all text in a single corpus
# tokenize using nlkt.word_tokenize to create a list of each individual token

incTokens = nltk.word_tokenize(final_text_desc) # contains stop words
# use this as the starting point or use filtered_text_desc which is without stop words

# Now we need to convert the tokens to all lowercase
# this has already been done, but we will do again for good measure
incWords = [w.lower() for w in incTokens]

# create a dictionary for each book to gather data about how tokens
# are decreased with each step 'Initial', 'Tokens', 'NoPunct', 'NoStop', 'NoSmall'
incDict = dict()
incDict['Initial'] = len(final_text_desc)
# check the length of the list of words
incDict['Tokens'] = len(incWords)

# Bigrams
incBigram = ngrams(incTokens,2)
freq_dist = nltk.FreqDist(incBigram)
prob_dist = nltk.MLEProbDist(freq_dist)
numBigrams = freq_dist.N()

# Trigrams
incTrigram = ngrams(incTokens,3)
Tfreq_dist = nltk.FreqDist(incTrigram)
Tprob_dist = nltk.MLEProbDist(Tfreq_dist)
numTrigrams = Tfreq_dist.N()

# Bigrams - Incident Description
incBigramList = list(nltk.bigrams(incWords))
print(incBigramList[:30])
# maybe remove gary, gullo, tr, trn, samuel, morales and other names?

# Trigrams - Incident Description
incTrigramList = list(nltk.trigrams(incWords))
print(incTrigramList[:30])

# remove punctuation
# Function to remove punctuation and non-alphabetic characters
def remove_punc_filter(word):
    # pattern to match word of non-alphabetical characters
    mPattern = re.compile('^[^a-z]+$')
    if (mPattern.match(word)):
        return True
    else:
        return False
    
# remove punctuation from both inc and kw words
aincWords = [w for w in incWords if not remove_punc_filter(w)]
incDict['NoPunc'] = len(aincWords)
aincWords[:25]

# remove stop words
stopWords = nltk.corpus.stopwords.words('english')
len(stopWords)
# for Incident Description
# ** Check if necessary - look at previous stop words (names, tr, jr, etc.)
# add some additional stop words after review of the words
incmoreStopWords = ["michael", "john", "robert", "todd", "rodriguez", "englehart", "mark", "rudy",
                  "david", "bruce", "gary", "james", "will", "william", "linda", "richard", "joseph",
                  "chris", "ferraro", "paul", "thomas", "jose", "pletcher", "levine", "christopher",
                  "jacobson", "mike", "contessa", "krubera", "gullo", "morales", "edward", "belmont", 
                  "jeremiah", "chad", "ray", "patrick", "tr", "trn", "jr", "'s", "r", "j", "l"]

incstopWords = stopWords + incmoreStopWords
len(incstopWords)

# this is the type of list that we will need for feature sets later, but it is not properly shuffled
# will need to do collapse the words (put all together) after shuffling the dataframe
sincWords = [w for w in aincWords if not w in incstopWords]

incDict['NoStop'] = len(sincWords)

# need to stem, but realy only want to stem "horse" and "horses"
# definitely want to look at stemming (check labs)
# create instances of stemmers
porter = PorterStemmer()
lancaster = LancasterStemmer()

# check to see how these work
word_list = ["euthanisia", "euthanized", "died", "dead","death","lame","lameness","unseated","unseating",
             "injured", "injury", "injuries", "ambulanced", "collapse", "collapsed"]
print("{0:20}{1:20}{2:20}".format("Word","Porter Stemmer","Lancaster Stemmer"))
for word in word_list:
    print("{0:20}{1:20}{2:20}".format(word,porter.stem(word),lancaster.stem(word)))
# not happy with how the stemmers worked, so determined would not stem

# First list the top 50 words by frequency (normalized by the length of the document)
incDist = FreqDist(sincWords)
incDist2 = DictionaryProbDist(incDist, normalize=True)
incDist2.prob('injury')
incDist2.prob('euthanized')
incDist.plot(50)
# need to make second number number / len(sincWords)
incItems = incDist.most_common(50)
# Show the normalized probability
for item in incItems:
  print(item)

# try this
inctotal = incDict['NoStop']

# Probability in Dictionary.ProbDist is actually No Stop Words for Denominator
for item in incItems:
    print(item[0], item[1], item[1]/inctotal)
    
# Visualize the normalized frequency - Incident Description
incTop50DF = pd.DataFrame(incItems)
incTop50DF.columns = ['word', 'frequency']
# set a column for normalized frequency
incTotalLen = incDict['NoStop']
incnFreqDF = []
incnFreqDF = pd.DataFrame(columns=['norm_freq'])

# Loop through to create normalized value
for value in incTop50DF['frequency']:
    # get the normalized frequency
    normfreq = value/incTotalLen
    incnFreqDF = incnFreqDF.append(pd.DataFrame({'norm_freq': [normfreq]}))
    
# reset the index properly
incnFreqDF = incnFreqDF.reset_index()
# remove bad index
incnFreqDF = incnFreqDF.drop(['index'], axis=1)
# need to add the columns from the other 
incTop50DF['norm_freq'] = incnFreqDF['norm_freq']

# plot with seaborn - Unigrams
fg = sns.catplot(x = "norm_freq", y = "word", hue = "word", dodge=False, 
                    height = 8, aspect = 1, palette="Spectral", kind="bar", data=incTop50DF)
fg.set_xticklabels(rotation=25, horizontalalignment = 'center', 
                         fontweight = 'light', fontsize = 'medium')
fg._legend.remove()
fg.set(xlabel = "Normalized Frequency", ylabel = "Word", 
       title = "Top 50 Words in Incident Description (normalized)")

# Let's start to review what we have working one text at a time
# first create the bigram association measure
bMeasures = nltk.collocations.BigramAssocMeasures()
# create the bigram finder followed by scores
incFinder = BigramCollocationFinder.from_words(sincWords)
# remove less frequent words
incFinder.apply_freq_filter(3)
incScores = incFinder.score_ngrams(bMeasures.raw_freq)
# check the top 50 scores
for score in incScores[:50]:
    print(score)

# Make a nice format for graphing as well as for printing
for score in incScores[:50]:
    print("Words: ", score[0], "\tScore: ", score[1])

# Visualize the normalized frequency of the bigrams - Incident Description
incBig50DF = pd.DataFrame(incScores[:50])
incBig50DF.columns = ['words', 'norm_freq']
newincBig50DF = []
newincBig50DF = pd.DataFrame(columns=['words_string'])
for item in incBig50DF['words']:
    (word1, word2) = item
    newword = word1 + ", " + word2
    newincBig50DF = newincBig50DF.append(pd.DataFrame({'words_string': [newword]}))

# reset the index properly
newincBig50DF = newincBig50DF.reset_index()
# remove bad index
newincBig50DF = newincBig50DF.drop(['index'], axis=1)
# need to add the columns from the other 
incBig50DF['words_string'] = newincBig50DF['words_string']

# plot with seaborn
fg = sns.catplot(x = "norm_freq", y = "words_string", hue = "words_string", dodge=False, 
                    height = 8, aspect = 1, palette="viridis", kind="bar", 
                    data=incBig50DF)
fg.set_xticklabels(rotation=25, horizontalalignment = 'center', 
                         fontweight = 'light', fontsize = 'medium')
fg._legend.remove()
fg.set(xlabel = "Bigram Score", ylabel = "Bigrams", 
       title = "Top 50 Bigrams from Incident Description")

## Trigrams
tMeasures = nltk.collocations.TrigramAssocMeasures()
# create the trigram finder followed by scores
incTFinder = TrigramCollocationFinder.from_words(sincWords)
# remove less frequent words
incTFinder.apply_freq_filter(3)
incTScores = incTFinder.score_ngrams(tMeasures.raw_freq)
# check the top 50 scores
# Make a nice format for graphing as well as for printing
for score in incTScores[:50]:
    print("Words: ", score[0], "\tScore: ", score[1])

# Visualize the normalized frequency of the trigrams - Incident Description
incTri50DF = pd.DataFrame(incTScores[:50])
incTri50DF.columns = ['words', 'norm_freq']
newincTri50DF = []
newincTri50DF = pd.DataFrame(columns=['words_string'])
for item in incTri50DF['words']:
    (word1, word2, word3) = item
    newword = word1 + ", " + word2 + ", " + word3
    newincTri50DF = newincTri50DF.append(pd.DataFrame({'words_string': [newword]}))

# reset the index properly
newincTri50DF = newincTri50DF.reset_index()
# remove bad index
newincTri50DF = newincTri50DF.drop(['index'], axis=1)
# need to add the columns from the other 
incTri50DF['words_string'] = newincTri50DF['words_string']

# plot with seaborn
fg = sns.catplot(x = "norm_freq", y = "words_string", hue = "words_string", dodge=False, 
                    height = 8, aspect = 1, palette="viridis", kind="bar", 
                    data=incTri50DF)
fg.set_xticklabels(rotation=25, horizontalalignment = 'center', 
                         fontweight = 'light', fontsize = 'medium')
fg._legend.remove()
fg.set(xlabel = "Trigram Score", ylabel = "Trigrams", 
       title = "Top 50 Trigrams from Incident Description")

# VERY POOR RESULTS - maybe need more stopwords?
# Do not include in final report - skip PMI
# mutual information PMI (Pointwise Mutual Information)
# scores high things that only go together
# PMI Incident Description (Bigrams)
incPFinder = BigramCollocationFinder.from_words(sincWords,window_size = 5)
# play around with Frequency filter
incPFinder.apply_freq_filter(3)
incPScores = incPFinder.score_ngrams(bMeasures.pmi)
incPMI = incPFinder.nbest(bMeasures.pmi,50)

# to print out the answers in order using PMI
for item in incPScores[:50]:
    print(item)
# pretty much all horse names or trainer/proper names

# Trigrams using PMI
incTPFinder = TrigramCollocationFinder.from_words(sincWords, window_size = 5)
# finder.nbest(bigram_measures.pmi, 10)
# to print out the answers in order using PMI
incTPFinder.apply_freq_filter(3)
incTPMI2 = incTPFinder.score_ngrams(tMeasures.pmi)
incTPMI = incTPFinder.nbest(tMeasures.pmi,50)
for item in incTPMI2[:50]:
    print(item)
# A little better with Trigram PMI - if you look at injuries and locations, etc.
# still not using

###------------------------------- Function for doing Cross Validation ---------------------------
# Author: These programs were provided to us in class
# first define the function to run the cross validation given the docs, gold standard labels and the 
# the featureset for testing
# function passing number of folds, feature set and labels
## cross-validation ##
# this function takes the number of folds, the feature sets and the labels
# it iterates over the folds, using different sections for training and testing in turn
#   it prints the performance for each fold and the average performance at the end
def cross_validation_PRF(num_folds, featuresets, labels):
    subset_size = int(len(featuresets)/num_folds)
    print('Each fold size:', subset_size)
    # for the number of labels - start the totals lists with zeroes
    num_labels = len(labels)
    print ('Number of labels: ', labels)
    total_precision_list = [0] * num_labels
    total_recall_list = [0] * num_labels
    total_F1_list = [0] * num_labels

    # iterate over the folds
    for i in range(num_folds):
        test_this_round = featuresets[(i*subset_size):][:subset_size]
        train_this_round = featuresets[:(i*subset_size)] + featuresets[((i+1)*subset_size):]
        # train using train_this_round
        classifier = nltk.NaiveBayesClassifier.train(train_this_round)
        # evaluate against test_this_round to produce the gold and predicted labels
        goldlist = []
        predictedlist = []
        for (features, label) in test_this_round:
            goldlist.append(label)
            predictedlist.append(classifier.classify(features))

        # computes evaluation measures for this fold and
        #   returns list of measures for each label
        print('Fold', i)
        (precision_list, recall_list, F1_list) \
                  = eval_measures3(goldlist, predictedlist, labels)
        # take off triple string to print precision, recall and F1 for each fold
        '''
        print('\tPrecision\tRecall\t\tF1')
        # print measures for each label
        for i, lab in enumerate(labels):
            print(lab, '\t', "{:10.3f}".format(precision_list[i]), \
              "{:10.3f}".format(recall_list[i]), "{:10.3f}".format(F1_list[i]))
        '''
        # for each label add to the sums in the total lists
        for i in range(num_labels):
            # for each label, add the 3 measures to the 3 lists of totals
            total_precision_list[i] += precision_list[i]
            total_recall_list[i] += recall_list[i]
            total_F1_list[i] += F1_list[i]

    # find precision, recall and F measure averaged over all rounds for all labels
    # compute averages from the totals lists
    precision_list = [tot/num_folds for tot in total_precision_list]
    recall_list = [tot/num_folds for tot in total_recall_list]
    F1_list = [tot/num_folds for tot in total_F1_list]
    # the evaluation measures in a table with one row per label
    print('\nAverage Precision\tRecall\t\tF1 \tPer Label')
    # print measures for each label
    for i, lab in enumerate(labels):
        print(lab, '\t', "{:10.3f}".format(precision_list[i]), \
          "{:10.3f}".format(recall_list[i]), "{:10.3f}".format(F1_list[i]))
    
    # print macro average over all labels - treats each label equally
    print('\nMacro Average Precision\tRecall\t\tF1 \tOver All Labels')
    print('\t\t', "{:10.3f}".format(sum(precision_list)/num_labels), \
          "{:10.3f}".format(sum(recall_list)/num_labels), \
          "{:10.3f}".format(sum(F1_list)/num_labels))

    # for micro averaging, weight the scores for each label by the number of items
    #    this is better for labels with imbalance
    # first intialize a dictionary for label counts and then count them
    label_counts = {}
    for lab in labels:
      label_counts[lab] = 0 
    # count the labels
    for (doc, lab) in featuresets:
      label_counts[lab] += 1
    # make weights compared to the number of documents in featuresets
    num_docs = len(featuresets)
    label_weights = [(label_counts[lab] / num_docs) for lab in labels]
    print('\nLabel Counts', label_counts)
    #print('Label weights', label_weights)
    # print macro average over all labels
    print('Micro Average Precision\tRecall\t\tF1 \tOver All Labels')
    precision = sum([a * b for a,b in zip(precision_list, label_weights)])
    recall = sum([a * b for a,b in zip(recall_list, label_weights)])
    F1 = sum([a * b for a,b in zip(F1_list, label_weights)])
    print( '\t\t', "{:10.3f}".format(precision), \
      "{:10.3f}".format(recall), "{:10.3f}".format(F1))
    
# Function to compute precision, recall and F1 for each label
#  and for any number of labels
# Input: list of gold labels, list of predicted labels (in same order)
# Output:  prints precision, recall and F1 for each label

# Function to compute precision, recall and F1 for each label
#  and for any number of labels
# Input: list of gold labels, list of predicted labels (in same order)
# Output: returns lists of precision, recall and F1 for each label
#      (for computing averages across folds and labels)
def eval_measures3(gold, predicted, labels):
    
    # these lists have values for each label 
    recall_list = []
    precision_list = []
    F1_list = []

    for lab in labels:
        # for each label, compare gold and predicted lists and compute values
        TP = FP = FN = TN = 0
        for i, val in enumerate(gold):
            if val == lab and predicted[i] == lab:  TP += 1
            if val == lab and predicted[i] != lab:  FN += 1
            if val != lab and predicted[i] == lab:  FP += 1
            if val != lab and predicted[i] != lab:  TN += 1
        # use these to compute recall, precision, F1
        # for small numbers, guard against dividing by zero in computing measures
        if (TP == 0) or (FP == 0) or (FN == 0):
          recall_list.append (0)
          precision_list.append (0)
          F1_list.append(0)
        else:
          recall = TP / (TP + FP)
          precision = TP / (TP + FN)
          recall_list.append(recall)
          precision_list.append(precision)
          F1_list.append( 2 * (recall * precision) / (recall + precision))

    # the evaluation measures in a table with one row per label
    return (precision_list, recall_list, F1_list)
        
# Function to compute precision, recall and F1 for each label
#  and for any number of labels
# Input: list of gold labels, list of predicted labels (in same order)
# Output: returns lists of precision, recall and F1 for each label
#      (for computing averages across folds and labels)
def eval_measures(gold, predicted):
    # get a list of labels
    labels = list(set(gold))
    # these lists have values for each label 
    recall_list = []
    precision_list = []
    F1_list = []
    for lab in labels:
        # for each label, compare gold and predicted lists and compute values
        TP = FP = FN = TN = 0
        for i, val in enumerate(gold):
            if val == lab and predicted[i] == lab:  TP += 1
            if val == lab and predicted[i] != lab:  FN += 1
            if val != lab and predicted[i] == lab:  FP += 1
            if val != lab and predicted[i] != lab:  TN += 1
        # use these to compute recall, precision, F1
        recall = TP / (TP + FP)
        precision = TP / (TP + FN)
        recall_list.append(recall)
        precision_list.append(precision)
        F1_list.append( 2 * (recall * precision) / (recall + precision))

    # the evaluation measures in a table with one row per label
    print('\tPrecision\tRecall\t\tF1')
    # print measures for each label
    for i, lab in enumerate(labels):
        print(lab, '\t', "{:10.3f}".format(precision_list[i]), \
          "{:10.3f}".format(recall_list[i]), "{:10.3f}".format(F1_list[i]))

def cross_validation_accuracy(num_folds, featuresets):
    subset_size = int(len(featuresets)/num_folds)
    print('Each fold size:', subset_size)
    accuracy_list = []
    # iterate over the folds
    for i in range(num_folds):
        test_this_round = featuresets[(i*subset_size):][:subset_size]
        train_this_round = featuresets[:(i*subset_size)] + featuresets[((i+1)*subset_size):]
        # train using train_this_round
        classifier = nltk.NaiveBayesClassifier.train(train_this_round)
        # evaluate against test_this_round and save accuracy
        accuracy_this_round = nltk.classify.accuracy(classifier, test_this_round)
        print (i, accuracy_this_round)
        accuracy_list.append(accuracy_this_round)
    # find mean accuracy over all rounds
    print ('mean accuracy', sum(accuracy_list) / num_folds)
    
# Confusion Matrix
def confusion_matrix(featuresets):
    set_length = len(featuresets)
    train_length = int((2*set_length)/3)
    test_length = int(set_length/3)
    train_set, test_set = featuresets[train_length:], featuresets[:test_length]
    cm_classifier = nltk.NaiveBayesClassifier.train(train_set)
    cm_accuracy = nltk.classify.accuracy(cm_classifier, test_set)
    print("Accuracy: ", cm_accuracy)
    goldlist = []
    predictedlist = []
    for (featuresets, label) in test_set:
    	goldlist.append(label)
    	predictedlist.append(cm_classifier.classify(featuresets))
    # print out the confusion matrix
    cm = nltk.ConfusionMatrix(goldlist, predictedlist)
    print(cm.pretty_format(sort_by_count=True, truncate=9))

    # or show the results as percentages
    print(cm.pretty_format(sort_by_count=True, show_percents=True, truncate=9))

# now combine lists together
def merge(list1, list2): 
    merged_list = [(list1[i], list2[i]) for i in range(0, len(list1))] 
    return merged_list 

# before running this function - create a blank data frame: fixedDF and blank list for the return
# pass in dataframe to be converted to list for return
# function to prepare dataframe as classification list for processing
    # then tokenize the description
# remove the stopwords
# this becomes the proper approach for classification experiments
def prepareDataframe (initialDF, fixedDF):
    # lowercase each description
    initialDF['Incident Description'] = initialDF['Incident Description'].str.lower()

    # grab all text together
    initial_desc = initialDF['Incident Description'].str.split(' ')
    initial_desc.head()
    # create blank dataframe for tokenized words
    initial_desc_nopunc = []

    # remove punctuation
    for desc in initial_desc:
        desc = [x.strip(string.punctuation) for x in desc]
        initial_desc_nopunc.append(desc)
        initial_desc_nopunc[0]
        # this is a list with the text rejoined, not tokenized
        initial_desc_final = [" ".join(text) for text in initial_desc_nopunc]

    # need to replace "/" with space
    # need to replace the "-" with a space
    # remove extra spaces
    noslash = []
    for desc in initial_desc_final:
        desc = desc.replace("/", " ")
        desc = desc.replace("-", " ")
        desc = desc.replace("  ", " ")
        desc = desc.replace("  ", " ")
        noslash.append(desc)
        noslash[0]

    initialDescDF = []
    initialDescDF = pd.DataFrame(noslash, columns=['Incident Description'])

    # now need to do stopwords
    # remove stop words
    stopWords = nltk.corpus.stopwords.words('english')
    len(stopWords)
    # for Incident Description
    # add some additional stop words after review of the words
    incmoreStopWords = ["michael", "john", "robert", "todd", "rodriguez", "englehart", "mark", "rudy",
                        "david", "bruce", "gary", "james", "will", "william", "linda", "richard", "joseph",
                        "chris", "ferraro", "paul", "thomas", "jose", "pletcher", "levine", "christopher",
                        "jacobson", "mike", "contessa", "krubera", "gullo", "morales", "edward", "belmont", 
                        "jeremiah", "chad", "ray", "patrick", "tr", "trn", "jr", "'s", "r", "j", "l"]

    incstopWords = stopWords + incmoreStopWords
    len(incstopWords)

    initialDescDF['Desc NoStops'] = initialDescDF['Incident Description'].apply(lambda x: ' '.join([word for word in x.split() if word not in incstopWords]))

    # now create final frame with merged information and fixed descriptions
    initialDF['Fixed Incident Description'] = initialDescDF['Desc NoStops']
    fixedDF = initialDF[['Fixed Incident Description', 'Outcome']]
    fixedDF.columns = ['Incident Description', 'Outcome']

    # need to create the proper frame now with each Incident Description tokeninized as in the fClassDF
    # which as all the stop words and punctuation, etc. removed
    # create list of phrase documents as (list of words, label)
    # first tokenize all the Incident Descriptions
    fixedDF['Tokenized'] = fixedDF.apply(lambda row: nltk.word_tokenize(row['Incident Description']), axis=1)

    #documents = [(desc, outcome) for outcome in outcomeList]
    # for desc in 
    fixed_tokens_list = fixedDF['Tokenized'].tolist()
    fixed_outcome_list = fixedDF['Outcome'].tolist()

    # merge the lists togeter
    fixedList = merge(fixed_tokens_list, fixed_outcome_list)
    return(fixedList)

#------------------------------------- Prepare Dataframe and Data for Cross Validation ------------
# create a frame that is just the Incident Description and then the Outcome
# This data frame must go through the proper preprocessing similar to that done before
# to create wordclouds. This is repeated to show understanding and processing steps
    
# list with balanced 3 possible outcomes
classificationDF = incidentDF[['Incident Description', 'Outcome']].copy()
# need to reindex
classificationDF.reset_index(drop=True, inplace=True)
# now process the frame to get the list for experiements
fClassDF = []
fClassList = []
fClassList = prepareDataframe(classificationDF, fClassDF)
# shuffle the list
random.shuffle(fClassList)

# list with 5 possible outcomes
classificationBigDF = incidentBigDF[['Incident Description', 'Outcome']].copy()
classificationBigDF.reset_index(drop=True, inplace=True)
fClassBigDF = []
fClassBigList = []
fClassBigList = prepareDataframe(classificationBigDF, fClassBigDF)
# shuffle the list
random.shuffle(fClassBigList)

# list with 6 possible outcome including Other
classificationFullDF = incidentFullDF[['Incident Description', 'Outcome']].copy()
classificationFullDF.reset_index(drop=True, inplace=True)
fClassFullDF = []
fClassFullList = []
fClassFullList = prepareDataframe(classificationFullDF, fClassFullDF)
# shuffle the list
random.shuffle(fClassFullList)
# ClassList(s) - now ready for some FeatureSets and some Classification Experiments

#------------------------------------- Feature Set Definition ------------------------------------
# Feature sets to create
# Unigrams
# Bigrams
# Trigrams
# POS Feature Set?
# Use cross validation
# Use precision, recall
# Create confusion matrix

##---------------------- Unigrams ----------------------------
# get all words from all movie_reviews and put into a frequency distribution
# in our case - all stopwords, punctuation, etc already done
all_words_list = [word for (desc,outcome) in fClassList for word in desc]
all_words = nltk.FreqDist(all_words_list)
print(len(all_words))

# get the 2000 most frequently appearing keywords in the corpus
word_items = all_words.most_common(2000)
word_features = [word for (word,count) in word_items]

# define features (keywords) of a document for a BOW/unigram baseline
# each feature is 'contains(keyword)' and is true or false depending
# on whether that keyword is in the document
def unigram_document_features(document, word_features):
    document_words = set(document)
    features = {}
    for word in word_features:
        features['V_{}'.format(word)] = (word in document_words)
    return features

# feature sets from a feature definition function
# this is unigrams
random.shuffle(fClassList)
unigram_featuresets = [(unigram_document_features(d, word_features), c) for (d, c) in fClassList]

# create labels (correct classification gold standard)
# must do this after EVERY shuffle
label_list = [c for (d,c) in fClassList]
labels = list(set(label_list)) 

# at this point, we can call the cross_validation_PRF function
# no additional shuffling here so labels will remain in order for accuracy and other measures
num_folds = 10
print("\nCross Validation for Unigrams for", num_folds, "folds: ")
cross_validation_accuracy(num_folds, unigram_featuresets)
print("\nCross Validation Precision and Recall for Unigrams for", num_folds, "folds: ")
cross_validation_PRF(num_folds, unigram_featuresets, labels)

# Confusion Matrix
confusion_matrix(unigram_featuresets)

##---------------------- Bigrams ----------------------------
####   Bigram features   ####
# set up for using bigrams
bigram_measures = nltk.collocations.BigramAssocMeasures()

# create the bigram finder on all the words in sequence
print(all_words_list[:10])
finder = BigramCollocationFinder.from_words(all_words_list)

# define the top 500 bigrams using the chi squared measure
bigram_features = finder.nbest(bigram_measures.chi_sq, 500)
print(bigram_features[:10])
# these look to be mostly horses names

# define features that include words as before 
# add the most frequent significant bigrams
# this function takes the list of words in a document as an argument and returns a feature dictionary
# it depends on the variables word_features and bigram_features
def bigram_document_features(document, word_features, bigram_features):
    document_words = set(document)
    document_bigrams = nltk.bigrams(document)
    features = {}
    for word in word_features:
        features['V_{}'.format(word)] = (word in document_words)
    for bigram in bigram_features:
        features['B_{}_{}'.format(bigram[0], bigram[1])] = (bigram in document_bigrams)    
    return features

# use this function to create feature sets for all sentences, reshuffle first
random.shuffle(fClassList)
bigram_featuresets = [(bigram_document_features(d, word_features, bigram_features), c) for (d, c) in fClassList]

# number of features for document 0
print(len(bigram_featuresets[0][0].keys()))

# features in document 0
print(bigram_featuresets[0][0])

# create labels (correct classification gold standard)
# must do this after EVERY shuffle
label_list = [c for (d,c) in fClassList]
labels = list(set(label_list)) 

# no shuffling so labels remain in order
print("\nCross Validation for Bigrams for", num_folds, "folds: ")
cross_validation_accuracy(num_folds, bigram_featuresets)
print("\nCross Validation Precision and Recall for Bigrams for", num_folds, "folds: ")
cross_validation_PRF(num_folds, bigram_featuresets, labels)

# Confusion Matrix
confusion_matrix(bigram_featuresets)

##--------------------- Trigrams ----------------------------
####   Trigram features   ####
# set up for using bigrams
trigram_measures = nltk.collocations.TrigramAssocMeasures()

# create the bigram finder on all the words in sequence
print(all_words_list[:10])
finder = TrigramCollocationFinder.from_words(all_words_list)

# define the top 500 bigrams using the chi squared measure
trigram_features = finder.nbest(trigram_measures.chi_sq, 500)
print(trigram_features[:10])
# still lots of horse names, but some additional things

# define features that include words as before 
# add the most frequent significant trigram
# this function takes the list of words in a document as an argument and returns a feature dictionary
# it depends on the variables word_features and bigram_features
def trigram_document_features(document, word_features, trigram_features):
    document_words = set(document)
    document_trigrams = nltk.trigrams(document)
    features = {}
    for word in word_features:
        features['V_{}'.format(word)] = (word in document_words)
    for trigram in trigram_features:
        features['B_{}_{}'.format(trigram[0], trigram[1])] = (trigram in document_trigrams)    
    return features

# use this function to create feature sets for all sentences
random.shuffle(fClassList)
trigram_featuresets = [(trigram_document_features(d, word_features, trigram_features), c) for (d, c) in fClassList]

# number of features for document 0
print(len(trigram_featuresets[0][0].keys()))

# features in document 0
print(trigram_featuresets[0][0])

# create labels (correct classification gold standard)
# must do this after EVERY shuffle
label_list = [c for (d,c) in fClassList]
labels = list(set(label_list)) 

# no additional reshuffling so labels are in correct order
print("\nCross Validation for Trigrams for", num_folds, "folds: ")
cross_validation_accuracy(num_folds, trigram_featuresets)
print("\nCross Validation Precision and Recall for Trigrams for", num_folds, "folds: ")
cross_validation_PRF(num_folds, trigram_featuresets, labels)

# Confusion Matrix
confusion_matrix(trigram_featuresets)

#--------------------- POS Tags ------------------------------
###  POS tag counts
# this function takes a document list of words and returns a feature dictionary
# it runs the default pos tagger (the Stanford tagger) on the document
#   and counts 4 types of pos tags to use as features
def POS_document_features(document, word_features):
    document_words = set(document)
    tagged_words = nltk.pos_tag(document)
    features = {}
    for word in word_features:
        features['contains({})'.format(word)] = (word in document_words)
    numNoun = 0
    numVerb = 0
    numAdj = 0
    numAdverb = 0
    for (word, tag) in tagged_words:
        if tag.startswith('N'): numNoun += 1
        if tag.startswith('V'): numVerb += 1
        if tag.startswith('J'): numAdj += 1
        if tag.startswith('R'): numAdverb += 1
    features['nouns'] = numNoun
    features['verbs'] = numVerb
    features['adjectives'] = numAdj
    features['adverbs'] = numAdverb
    return features

# define feature sets using this function
random.shuffle(fClassList)
POS_featuresets = [(POS_document_features(d, word_features), c) for (d, c) in fClassList]
# number of features for document 0
print(len(POS_featuresets[0][0].keys()))

# the first sentence
print(fClassList[0])
# the pos tag features for this sentence
print('num nouns', POS_featuresets[0][0]['nouns'])
print('num verbs', POS_featuresets[0][0]['verbs'])
print('num adjectives', POS_featuresets[0][0]['adjectives'])
print('num adverbs', POS_featuresets[0][0]['adverbs'])

# create labels (correct classification gold standard)
# must do this after EVERY shuffle
label_list = [c for (d,c) in fClassList]
labels = list(set(label_list)) 

# no more shuffling so labels sttay in order
print("\nCross Validation for Part of Speech Tags for", num_folds, "folds: ")
cross_validation_accuracy(num_folds, POS_featuresets)
print("\nCross Validation Precision and Recall for Part of Speech Tags for", num_folds, "folds: ")
cross_validation_PRF(num_folds, POS_featuresets, labels)

# Confusion Matrix
confusion_matrix(POS_featuresets)

#------------------------- Best Feature Sets on unbalanced Data Sets -----------------
# using the cross_validation_PRF function and confusion matrix on the other datasets to see what happens
# Just use best featuresets

# Five Outcome Dataset
# unigrams

all_words_list = [word for (desc,outcome) in fClassBigList for word in desc]
all_words = nltk.FreqDist(all_words_list)
print(len(all_words))

# get the 2000 most frequently appearing keywords in the corpus
word_items = all_words.most_common(2000)
word_features = [word for (word,count) in word_items]

# feature sets from a feature definition function
# this is unigrams
random.shuffle(fClassBigList)
unigram_featuresets = [(unigram_document_features(d, word_features), c) for (d, c) in fClassBigList]

# create labels (correct classification gold standard)
# must do this after EVERY shuffle
label_list = [c for (d,c) in fClassBigList]
labels = list(set(label_list)) 

# at this point, we can call the cross_validation_PRF function
# no additional shuffling here so labels will remain in order for accuracy and other measures
num_folds = 10
print("\nCross Validation for Unigrams for Five Outcomes", num_folds, "folds: ")
cross_validation_accuracy(num_folds, unigram_featuresets)
print("\nCross Validation Precision and Recall for Unigrams for Five Outcomes", num_folds, "folds: ")
cross_validation_PRF(num_folds, unigram_featuresets, labels)

# Confusion Matrix
confusion_matrix(unigram_featuresets)

# bigrams
bigram_measures = nltk.collocations.BigramAssocMeasures()

# create the bigram finder on all the words in sequence
finder = BigramCollocationFinder.from_words(all_words_list)

# define the top 500 bigrams using the chi squared measure
bigram_features = finder.nbest(bigram_measures.chi_sq, 500)

# use this function to create feature sets for all sentences, reshuffle first
random.shuffle(fClassBigList)
bigram_featuresets = [(bigram_document_features(d, word_features, bigram_features), c) for (d, c) in fClassBigList]

# create labels (correct classification gold standard)
# must do this after EVERY shuffle
label_list = [c for (d,c) in fClassBigList]
labels = list(set(label_list)) 

# no shuffling so labels remain in order
print("\nCross Validation for Bigrams for Five Outcomes for", num_folds, "folds: ")
cross_validation_accuracy(num_folds, bigram_featuresets)
print("\nCross Validation Precision and Recall for Bigrams for Five Outcomes for", num_folds, "folds: ")
cross_validation_PRF(num_folds, bigram_featuresets, labels)

# Confusion Matrix
confusion_matrix(bigram_featuresets)

# Six  Outcome Dataset
# unigrams

all_words_list = [word for (desc,outcome) in fClassFullList for word in desc]
all_words = nltk.FreqDist(all_words_list)
print(len(all_words))

# get the 2000 most frequently appearing keywords in the corpus
word_items = all_words.most_common(2000)
word_features = [word for (word,count) in word_items]

# feature sets from a feature definition function
# this is unigrams
random.shuffle(fClassFullList)
unigram_featuresets = [(unigram_document_features(d, word_features), c) for (d, c) in fClassFullList]

# create labels (correct classification gold standard)
# must do this after EVERY shuffle
label_list = [c for (d,c) in fClassFullList]
labels = list(set(label_list)) 

# at this point, we can call the cross_validation_PRF function
# no additional shuffling here so labels will remain in order for accuracy and other measures
num_folds = 10
print("\nCross Validation for Unigrams for Six Outcomes", num_folds, "folds: ")
cross_validation_accuracy(num_folds, unigram_featuresets)
print("\nCross Validation Precision and Recall for Unigrams for Six Outcomes", num_folds, "folds: ")
cross_validation_PRF(num_folds, unigram_featuresets, labels)

# Confusion Matrix
confusion_matrix(unigram_featuresets)

# bigrams
bigram_measures = nltk.collocations.BigramAssocMeasures()

# create the bigram finder on all the words in sequence
finder = BigramCollocationFinder.from_words(all_words_list)

# define the top 500 bigrams using the chi squared measure
bigram_features = finder.nbest(bigram_measures.chi_sq, 500)

# use this function to create feature sets for all sentences, reshuffle first
random.shuffle(fClassFullList)
bigram_featuresets = [(bigram_document_features(d, word_features, bigram_features), c) for (d, c) in fClassFullList]

# create labels (correct classification gold standard)
# must do this after EVERY shuffle
label_list = [c for (d,c) in fClassFullList]
labels = list(set(label_list)) 

# no shuffling so labels remain in order
print("\nCross Validation for Bigrams for Six Outcomes for", num_folds, "folds: ")
cross_validation_accuracy(num_folds, bigram_featuresets)
print("\nCross Validation Precision and Recall for Bigrams for Six Outcomes for", num_folds, "folds: ")
cross_validation_PRF(num_folds, bigram_featuresets, labels)

# Confusion Matrix
confusion_matrix(bigram_featuresets)
#----------------------------------------------------------------------------------
