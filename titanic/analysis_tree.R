library(rpart) # For decision trees
# Load in the packages to create a fancified version of my tree (plot and text are too basic)
library(rattle)
library(rpart.plot)
library(RColorBrewer)

source("common.R")

# 0.75120 : minsplit = 40

setwd("~/Desktop/kaggle/my_project/titanic/")

train <- read.csv("./data/train.csv") # 891 observations
test <- read.csv("./data/test.csv") # 418 observations

l <- clean(train, test)
train <- as.data.frame(l$train)
test <- as.data.frame(l$test)

# Add some controls on rpart
# minsplit : the minimum number of observations that must exist in a node in order for a split to be attempted.
# cp : the complexity parameter
control <- rpart.control(minsplit = 40, cp = 0)

# Build the decision tree
my_tree <- rpart(Survived ~ Pclass + Sex + Age + SibSp + Parch + Embarked + Fare + Title + Child + FamilySize,
                 data = train,
                 method = "class",
                 control = control)

# Plot my fancy tree
fancyRpartPlot(my_tree)
my_prediction <- predict(my_tree, test, type="class")

# Create a data frame with two columns: PassengerId & Survived. Survived contains my predictions
my_solution <- data.frame(PassengerId = test$PassengerId, Survived = my_prediction)

# Write my solution to a csv file with the name my_solution.csv
# Don't add the row names
write.csv(my_solution, file="./data/solution_tree.csv" , row.names = FALSE)
