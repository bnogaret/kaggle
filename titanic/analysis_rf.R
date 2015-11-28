# For randomForest
library(randomForest)
library(plyr) # for revalue

source("common.R")

#Set the working directory to save the result in a ccsv file
setwd("~/Desktop/kaggle/my_project/titanic/")

train <- read.csv("./data/train.csv") # 891 observations
test <- read.csv("./data/test.csv") # 418 observations

l <- clean(train, test)
train <- as.data.frame(l$train)
test <- as.data.frame(l$test)


# Set seed for reproducibility
set.seed(1)

# 0.79904 : ntree = 2500

# Apply the Random Forest Algorithm
my_forest <- randomForest(as.factor(Survived) ~ Pclass + Sex + Age + SibSp + Parch + Embarked + Fare + Title + Child + FamilySize,
                          data = train,
                          importance = TRUE,
                          ntree = 2500)
# To see the importance of each variable
varImpPlot(my_forest)

# Make your prediction using the test set
my_prediction <- predict(my_forest, test)

# Create a data frame with two columns: PassengerId & Survived. Survived contains your predictions
my_solution <- data.frame(PassengerId = test$PassengerId, Survived = my_prediction)

# Write my solution to a csv file with the name my_solution.csv
# Don't add the row names
write.csv(my_solution, file="./data/solution_rf.csv" , row.names = FALSE)
