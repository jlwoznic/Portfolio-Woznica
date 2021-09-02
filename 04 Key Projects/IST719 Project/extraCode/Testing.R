tes<-c("1.abc","2.di","3.lik")
dat<-c(5,3,2)
h<-data.frame(tes,dat)
h$num<-substr(h$tes,1,1)

sapply(strsplit(as.character(h$tes), "\\."), "[[", 2)

temp <- tolower(strsplit(as.character(descripts.df$description), " ", 2))
#temp <- tolower(temp$)


shopping_list <- c("apples x4", "bag of flour", "bag of sugar", "milk x2")
str_extract_all(shopping_list, "[a-z]+")
str_extract_all(shopping_list, "\\b[a-z]+\\b")
str_extract_all(shopping_list, "\\d")
