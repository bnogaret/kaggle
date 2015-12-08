setwd("~/Desktop/kaggle_R/whats_cooking/")

# https://www.youtube.com/watch?v=WZvPUGNJg18

# 0.64300 : getDtmAsDf(..., 0.99) + gbm(as.factor(cuisine) ~ ., ..., n.trees = 200, shrinkage = 0.05)

library(jsonlite)
# Classification
library(gbm)

source("common.R")

train <- fromJSON("./data/train.json", flatten=TRUE)
test <- fromJSON("./data/test.json", , flatten=TRUE)

# Get the document term matrix (fusion of train and test)
myDtm <- getDtmAsDf(train, test, 0.99)

# Split the data into train and test
df_train <- myDtm[1:nrow(train), ]
df_test <- myDtm[-(1:nrow(train)), ]

df_train$cuisine <- train$cuisine

set.seed(1)

my_gbm <- gbm(as.factor(cuisine) ~ .,
              data=df_train,
              n.trees = 200, 
              keep.data = FALSE,
              shrinkage = 0.05,
              verbose= TRUE)

# Estimates the optimal number of boosting iterations
nbTree <- gbm.perf(my_gbm)
print(nbTree)
print(summary(my_gbm))

predict_gbm <- predict(my_gbm, df_test, type="response", n.trees = nbTree)
print(predict_gbm)

# Get the name corresponding for the maximum value for each row (the 1)
my_prediction <- apply(predict_gbm, 1, function(x) colnames(predict_gbm)[which.max(x)])

my_solution <- data.frame(id = test$id, cuisine = my_prediction)

write.csv(my_solution, file="./data/solution_gbm.csv" , row.names = FALSE, quote = FALSE)
