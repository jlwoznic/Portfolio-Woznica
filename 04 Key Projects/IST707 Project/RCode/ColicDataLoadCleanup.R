# 
# Course: IST707
# Name: Joyce Woznica
# Project Code: Colic Data Load and Cleanup
# Due Date: 12/10/2019
#
# ------------------------------------------------------------------

# Data loading
colicData <- read.csv("C:/Users/Joyce/Desktop/Syracuse/IST707/Project/Data/horseRaw.csv", header = TRUE, na.strings = "NA")
str(colicData)
summary(colicData)

# review missing data
tMissing <-sum(is.na(colicData))
cat("The number of missing values in Horse Colic Data is ", tMissing)

# visualize the missing data
missmap(colicData)
# debating using mice package to predict missing data
#Use mice package to predict missing values
# fill in with missing columns that have missing data
#mice_mod <- mice(colicData[, c("Glucose","BloodPressure","SkinThickness","Insulin","BMI")], method='rf')
#mice_complete <- complete(mice_mod)

# What to do with missing data??
# replace missing data with means - which will not work on rows that are not numeric
colicDataM <- replaceNAwMeans(colicData)

# now replace with most common factor
colicDataM <- replaceNAwMode(colicDataM)
Hold.colicData <- colicData
colicData<-colicDataM
# review missing data
tMissing <-sum(is.na(colicData))
cat("The number of missing values in Horse Colic Data is ", tMissing)

missmap(colicData)

# do by hand
# nasogastric tube (NA is mode) - must be 'slight'
# abdomo_appearance - must be 'cloudy'
# abdomen - must be 'distend_large"
# rectal_exam_feces - must be 'absent'
colicData$nasogastric_tube[is.na(colicData$nasogastric_tube)] <- "slight" 
colicData$abdomo_appearance[is.na(colicData$abdomo_appearance)] <- "cloudy" 
colicData$abdomen[is.na(colicData$abdomen)] <- "distend_large" 
colicData$rectal_exam_feces[is.na(colicData$rectal_exam_feces)] <- "absent"
# look at above 4 lines to make changes faster for manuals!

# review missing data
tMissing <-sum(is.na(colicData))
cat("The number of missing values in Horse Colic Data is ", tMissing)
missmap(colicData)

# fix the rows that have extensive combinations
# do we just remove these data points since we only have 8 combined for all 300 horses?
length(which(colicData$lesion_3 != 0))
length(which(colicData$lesion_2 != 0))
# drop these columns and eliminate Hospital Number
colicData <- subset(colicData, select=-c(lesion_2, lesion_3, hospital_number))

# separate out the lesion_1 with variables
length(which(colicData$lesion_1 != 0))
# make 3 variables out of lesion_1
# set up the variables
firstL <- c("gastric", "small_intestine", "large_colon", "large_colon_cecum", "cecum", "traverse_colon", 
            "rectum-descending_colon", "uterus", "bladder", "none", "all_intestinal_sites")
secondL <- c("simple", "strangulation", "inflammation", "other")
secondL.0 <- "none"
thirdL <- c("mechanical", "paralytic", "none")
thirdL.0 <- "none"
fourthL <- c("obturation", "intrinsic", "extrinsic", "adynamic", "volvulous-torsion", "intussuption", 
             "thromboembolic", "hernia", "lipoma-selenic_incarceration", "displacement")
fourthL.0 <- "none"

# took about 5 hours to figure this out!
new_lesion1Cols <- generateLesion1(colicData$lesion_1)
colnames(new_lesion1Cols) <- c("lesion1A", "lesion1B", "lesion1C", "lesion1D")
new_lesion1Cols <- data.frame(new_lesion1Cols)

# replace colicData$lesion_1 with new 4 rows
colicData <- cbind(colicData, new_lesion1Cols)
colicData <- subset(colicData, select=-c(lesion_1))

# the rows to do manually
# probably a better way, but was in a hurry
fix_manually <- subset(colicData, colicData$lesion1A == "fix")

# fix each manually
fix_seven <- subset(fix_manually, fix_manually$lesion1B == 31110)
fix_seven$lesion1A <- "large_colon"
fix_seven$lesion1B <- "simple"
fix_seven$lesion1C <- "mechanical"
fix_seven$lesion1D <- "displacement"

fix_two <- subset(fix_manually, fix_manually$lesion1B == 11124)
fix_two$lesion1A <- "all_intestinal_sites"
fix_two$lesion1B <- "simple"
fix_two$lesion1C <- "paralytic"
fix_two$lesion1D <- "adynamic"

fix_onea <- subset(fix_manually, fix_manually$lesion1B == 11300)
fix_onea$lesion1A <- "all_intestinal_sites"
fix_onea$lesion1B <- "inflammation"
fix_onea$lesion1C <- "none"
fix_onea$lesion1D <- "none"

fix_oneb <- subset(fix_manually, fix_manually$lesion1B == 11400)
fix_oneb$lesion1A <- "all_intestinal_sites"
fix_oneb$lesion1B <- "other"
fix_oneb$lesion1C <- "none"
fix_oneb$lesion1D <- "none"

# need to omit 12208 - not valid value
fix_onec <- subset(fix_manually, fix_manually$lesion1B == 21110)
fix_onec$lesion1A <- "small_intestine"
fix_onec$lesion1B <- "simple"
fix_onec$lesion1C <- "mechanical"
fix_onec$lesion1D <- "displacement"

fix_oned <- subset(fix_manually, fix_manually$lesion1B == 41110)
fix_oned$lesion1A <- "large_colon_cecum"
fix_oned$lesion1B <- "simple"
fix_oned$lesion1C <- "mechanical"
fix_oned$lesion1D <- "displacement"

to_replace <- rbind(fix_seven, fix_two, fix_onea, fix_oneb, fix_onec, fix_oned)
# delete all rows with "fix"
colicData <- subset(colicData, colicData$lesion1A != "fix")

# append fixed rows to colicData
colicData <- rbind(colicData, to_replace)

# maybe use the mode for each column on the incorrect "omit"'s
# maybe just delete all "omits" and bad 3133 number :)
# remove all rows with omit
wrong_rows <- subset(colicData, colicData$lesion1A == "omit")
# I think I wil remove these items
colicData <- subset(colicData, colicData$lesion1A != "omit")
# instead of losing these 6 data points, replace with what I THINK the data is
# for 300
#fix_300 <- subset(wrong_rows, wrong_rows$lesion1B == 300)
#fix_300$lesion1A <- "large_colon"
#fix_300$lesion1B <- "none"
#fix_300$lesion1C <- "none"
#fix_300$lesion1D <- "none"

#fix_400 <- subset(wrong_rows, wrong_rows$lesion1B == 400)
#fix_400$lesion1A <- "large_colon_cecum"
#fix_400$lesion1B <- "none"
#fix_400$lesion1C <- "none"
#fix_400$lesion1D <- "none"

#to_replace <- rbind(fix_300, fix_400)
#colicData <- subset(colicData, colicData$lesion1A != "omit")
#colicData <- rbind(colicData, to_replace)

# where capillary_refill_time = 3, change to less_3_sec
fix_caps <- subset(colicData, colicData$capillary_refill_time == 3)
fix_caps$capillary_refill_time <- "less_3_sec"
colicData <- subset(colicData, colicData$capillary_refill_time != 3)
colicData <- rbind(colicData, fix_caps)

# now mix the data up
new_order <- sample(nrow(colicData))
colicData <- colicData[new_order,]

