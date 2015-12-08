setwd("~/Desktop/kaggle_R/whats_cooking/")

# 0.79344 with removeSparseTerms(myDtm, 0.9999) + xgboost(..., max.depth = 25, eta = 0.3, nround = 200, objective = "multi:softmax")

library(jsonlite)
library(Matrix)
# For classification
library(xgboost)
# To show the most important feature
library(ggplot2)
library(Ckmeans.1d.dp)

source("common.R")

train <- fromJSON("./data/train.json", flatten=TRUE)
test <- fromJSON("./data/test.json", , flatten=TRUE)

# Get the document term matrix (fusion of train and test)
myDtm <- getDtmAsDf(train, test, 0.9999)

# Split the data into train and test
dtm_train  <- myDtm[1:nrow(train), ]
dtm_test <- myDtm[-(1:nrow(train)), ]

# To transform the type of cuisine into a factor
factor_cuisine <- as.factor(c(train$cuisine))

# Transform the dtm into xgb.DMatrix
# SoftmaxMultiClassObj: label must be in [0, num_class)
xgbmat_train <- xgb.DMatrix(Matrix(data.matrix(dtm_train)), label=as.numeric(factor_cuisine) - 1)
xgbmat_test <- xgb.DMatrix(Matrix(data.matrix(dtm_test)))

# Number of different cuisines
nb_class <- length(unique(train$cuisine))

# train our multiclass classification model using softmax
# For more information on parameters : https://github.com/dmlc/xgboost/blob/master/doc/parameter.md
my_xgboost <- xgboost(xgbmat_train,
                      max.depth = 25,
                      eta = 0.3,
                      nround = 200,
                      objective = "multi:softmax",
                      verbose = 1,
                      num_class = nb_class)

# predict on my_xgboost set
my_prediction <- predict(my_xgboost, newdata = xgbmat_test)
# Change cuisine number back to string
# my_prediction <- sapply(my_prediction, FUN = function(x) as.character(factor_cuisine[x + 1]))
my_prediction <- levels(factor_cuisine)[my_prediction+1]

my_solution <- data.frame(id = test$id, cuisine = my_prediction)
write.csv(my_solution, file="./data/solution_xgboost.csv" , row.names = FALSE, quote = FALSE)

# plot the most important features
#names <- colnames(dtm_train)
#importance_matrix <- xgb.importance(names, model = my_xgboost)
#png("./image/importance_xgboost.png")
#xgb.plot.importance(importance_matrix[1:25,])
#dev.off()
