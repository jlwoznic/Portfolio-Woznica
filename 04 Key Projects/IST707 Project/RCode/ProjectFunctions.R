# 
# Course: IST707
# Name: Joyce Woznica
# Project Code: Package Functions
# Due Date: 12/10/2019
#

# function section
# ------------------------------------------------------------------
# helpful functions for removing spaces
# need to clean out extra spaces from ends of lines
trim.leading<-function(x) {sub("^\\s+","",x)}
trim.trailing<-function(x) {sub("\\s+$","",x)}
trim<-function(x) {sub("^\\s+|\\s+$","",x)}
trimCity<-function(x) {sub("\\,.*$","",x)}
trimSlash<-function(x) {sub("/.*$","",x)}

# Need to find "buckets" for the information
# maybe pick under 25%, 25% to 50%, 50% to 75%, 75% and up?
buildCutOffs<- function(mini, maxi, numcuts)
{
  index<-numcuts
  cutoffs<-c(0)
  while(index>=1)
  {
    cutoffs<- c(cutoffs, round(maxi/index))
    index<-index-1
  }
  return(cutoffs)
}

# convert exponential to decimal
toDecimal<-function(x) {format(x,scientific = FALSE)}

# State Name to Abbreviation
name2abbr <- function (st)
{
  statesDF <- data.frame(state.abb, state.name)
  colnames(statesDF)<-c("abbr","name")
  res<-statesDF$abb[match(st, statesDF$name, nomatch="NA")]
  substr(res,1,3)
}

# create a function to replace each column NA with mean for that column
replaceNAwMeans<-function(vec)
{
  numcols<-length(colnames(vec))
  index<-1
  while(index<=numcols)
  {
    theColV <- vec[,index]
    if (is.numeric(theColV))
    {
    theColV[is.na(theColV)]<-mean(theColV,na.rm=TRUE)
    vec[,index]<-theColV
    }
    index<-index+1
  }
  return(vec)
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

# convert lesion1 to 4 variables, unless 5 digits - then do by hand
convertLesion1 <- function(lesion1)
{
  numcols<-length(lesion1)
  new_vec<-NULL
#  if (numcols == 4)
#  {
    index<-1
    while (index <= numcols)
    {
      lesionVal <- lesion1[index]
      # first lesion Value
      if (index==1) { new_vec[index]<- firstL[lesionVal]}
      # second lesion value
      if (index==2) 
      {
        if (lesionVal != 0) { new_vec[index]<- secondL[lesionVal]} else {new_vec[index] <- secondL.0}
    }
      # third, if zero
      if (index == 3)
      { 
        if (lesionVal != 0) {new_vec[index]<- thirdL[lesionVal]} else  {new_vec[index] <- thirdL.0}
        }
      # fourth, if zero
      if (index==4)
      { 
        if (lesionVal != 0) {new_vec[index]<- fourthL[lesionVal]} else  {new_vec[index] <- fourthL.0}
        }
      index<-index+1
     }
#  }
  new_vec
}

# Create new DF of lesion1
generateLesion1<-function(col)
{
  num.rows <- length(col)
  colDF <- NULL
  colI <-1
  while(colI<=num.rows)
  {
    theVal <- col[colI]
    # check length first - don't do for 1 or 5
    vec <- as.integer(unlist(str_split(theVal,"")))  
    numNums <- length(vec)
    if (numNums == 4) {colDF <- rbind(colDF, convertLesion1(vec))}
    if (numNums == 1) {colDF <- rbind(colDF, c("none", "none", "none", "none"))}
    if (numNums == 5) {colDF <- rbind(colDF, c("fix", theVal, "none", "none"))}
    if (numNums == 3) {colDF <- rbind(colDF, c("omit", theVal, "none", "none"))}
    colI<-colI+1 
    }
  colDF
  }

# function to convert lived=1, died=0, euthanized=0.5 for RSME
convertOutcome <- function(col)
{
  num.rows <- length(col)
  colDF <- NULL
  colI <- 1
  while (colI <= num.rows)
  {
    theVal <- col[colI]
    if (theVal == "lived") {colDF <- rbind(colDF, 1)}
    if (theVal == "died") {colDF <- rbind(colDF, 0)}
    if (theVal == "euthanized") {colDF <- rbind(colDF, 0.5)}
    colI <- colI + 1
  }
  colDF
  }


