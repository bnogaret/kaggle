# Set the working directory
setwd("~/Desktop/kaggle/whats_cooking/")

# http://www.rdatamining.com/examples/text-mining
# http://homes.cs.washington.edu/~tqchen/pdf/BoostedTree.pdf

# 0.59523 with rpart and removeSparseTerms(myDtm, 0.99) and control (40)

library(jsonlite)
# Classification
library(rpart)

source("common.R")

train <- fromJSON("./data/train.json", flatten=TRUE)
test <- fromJSON("./data/test.json", , flatten=TRUE)

# Get the document term matrix (fusion of train and test)
myDtm <- getDtmAsDf(train, test, 0.99)

# Split the data into train and test
df_train <- myDtm[1:nrow(train), ]
df_test <- myDtm[-(1:nrow(train)), ]

df_train$cuisine <- train$cuisine

# Get the tree
# Add some option on rpart (try not to overfit)
# minsplit : the minimum number of observations that must exist in a node in order for a split to be attempted.
# cp : the complexity parameter
control <- rpart.control(minsplit = 40, cp = 0)
# In the formula : . means all the variables not already mentionned
# Type : class for classification, anova for regression
tree <- rpart(as.factor(cuisine) ~ ., 
              data=df_train, 
              control = control)

my_prediction <- predict(tree, df_test, type="class")

my_solution <- data.frame(id = test$id, cuisine = my_prediction)

write.csv(my_solution, file="./data/solution_tree.csv" , row.names = FALSE)
