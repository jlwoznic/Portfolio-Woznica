# 
# Course: IST707
# Name: Joyce Woznica
# Project Code: Package Loading
# Due Date: 12/10/2019
#
# Package Section
# ------------------------------------------------------------------
#specify the packages of interest
packages <- c("pastecs", "stargazer", "psych", "ggplot2", "e1071", "arules", "gmodels", "arulesViz", "slam", "quanteda", 
              "tm", "SnowballC", "proxy", "cluster", "stringi", "Matrix", "tidytext", "factoextra", "mclust", "reshape2", "psych",
              "purrr", "tibble", "tidyr", "stringr", "readr", "forcats", "tidyverse", "stats", "flexclust", "LICORS", "modelr",
              "factoextra", "stringi", "stats", "GGally", "randomForest", "caret", "caretEnsemble", "e1071", "Amelia", "rpart",
              "mice", "rattle", "rpart.plot", "naivebayes", "mlr","yardstick", "gmodels", "lmtest", "car", "neuralnet", "caTools")

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

# I find this does not always work, so added to install when required here
require(dplyr)

install.packages("plyr",dependencies=TRUE)
library(plyr)

