setwd("~/Desktop/kaggle_R/whats_cooking/")

# 0.63023 : 100 trees, removeSparseTerms 0.99, nodesize = 40
# 0.71943 : 200 trees, removeSparseTerms 0.99

library(jsonlite)
# Classification
library(randomForest)

source("common.R")

train <- fromJSON("./data/train.json", flatten=TRUE)
test <- fromJSON("./data/test.json", flatten=TRUE)

# Get the document term matrix (fusion of train and test)
myDtm <- getDtmAsDf(train, test, 0.99)

# Split the data into train and test
df_train <- myDtm[1:nrow(train), ]
df_test <- myDtm[-(1:nrow(train)), ]

df_train$cuisine <- train$cuisine

set.seed(1)

# Apply the Random Forest Algorithm
my_forest <- randomForest(as.factor(cuisine) ~ ., 
                          data=df_train, 
                          importance=TRUE, 
                          ntree=200,
                          do.trace = TRUE)

# To see the importance of each variable
varImpPlot(my_forest)

my_prediction <- predict(my_forest, df_test)

my_solution <- data.frame(id = test$id, cuisine = my_prediction)

write.csv(my_solution, file="./data/solution_forest.csv" , row.names = FALSE)
