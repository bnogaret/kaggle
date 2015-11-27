library(Amelia) # for missmap
library(plyr) # for join

source("common.R")

setwd("~/Desktop/kaggle/my_project/titanic/")

train <- read.csv("./data/train.csv") # 891 observations
test <- read.csv("./data/test.csv") # 418 observations

str(train)
str(test)

# Passengers that survived vs passengers that passed away (as proportions)
# 1 = died, 0 = survived
prop.table(table(train$Survived))

# Males & females that survived vs males & females that passed away (as proportions)
# margin : to specify whether you want row-wise (1) or column-wise proportions (2)
prop.table(table(train$Sex, train$Survived), margin=1)

# Show the missing data
sapply(train, function(x) sum(is.na(x)))
missmap(train)
sapply(test, function(x) sum(is.na(x)))
missmap(test)
# Train : 177 data are missing for age
# Test : 86 missing data for age and 1 flor Fare

l <- clean(train, test)
train <- as.data.frame(l$train)
test <- as.data.frame(l$test)

# Show proportions of child who survived / passed away
prop.table(table(train$Child, train$Survived), margin=1)

# PCA
# Get the list of columns that are of type numeric (prcomp only on numeric columns)
nums <- sapply(train, is.numeric)
pca <-prcomp(train[, nums], center = TRUE, scale. = TRUE)
print(pca)
summary(pca)
biplot(pca)
plot(pca$x[,1], pca$x[,2], cex=(train$Survived + 1), col=(train$Survived + 2), main = "First two PCA", xlab = "PC1", ylab = "PC2")

missmap(train)
missmap(test)
