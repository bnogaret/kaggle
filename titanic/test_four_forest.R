# For randomForest
library(randomForest)
library(plyr) # for revalue

source("common.R")

#Set the working directory to save the result in a ccsv file
setwd("~/Desktop/kaggle/my_project/titanic/")

cleanUp <- function(data) {
  # Replace NA Fare value by the median fare value.
  data$Fare[is.na(data$Fare)] <- median(data$Fare, na.rm = TRUE)

  # Add a new variable
  data$family_size <- data$SibSp + data$Parch + 1

  # How to fill in missing Age values?
  # We make a prediction of a passengers Age using the other variables and a decision tree model.
  # This time you give method = "anova" since you are predicting a continuous variable.
  predicted_age <- rpart(Age ~ Pclass + Sex + SibSp + Parch + Fare + Embarked + family_size,
                         data = data[!is.na(data$Age),], method = "anova")
  data$Age[is.na(data$Age)] <- predict(predicted_age, data[is.na(data$Age),])

  return(data)
}

train <- read.csv("./data/train.csv") # 891 observations
test <- read.csv("./data/test.csv") # 418 observations

l <- clean(train, test)
train <- as.data.frame(l$train)
test <- as.data.frame(l$test)

# Passenger on row 62 and 830 do not have a value for embarkment.
# Since many passengers embarked at Southampton, we give them the value S.
# train$Embarked[c(62, 830)] <- "S"


# Set seed for reproducibility
set.seed(1)

train$Title <- as.factor(train$Title)
test$Title <- as.factor(test$Title)

# Problem avec Embarked column

# Apply the Random Forest Algorithm
my_forest <- randomForest(as.factor(Survived) ~ Pclass + Sex + Age + SibSp + Parch + Fare + Title + Child + FamilySize,
                          data=train,
                          importance=TRUE,
                          ntree=5000)
# To see the importance of each variable
varImpPlot(my_forest)

# Make your prediction using the test set
my_prediction <- predict(my_forest, test)

# Create a data frame with two columns: PassengerId & Survived. Survived contains your predictions
my_solution <- data.frame(PassengerId = test$PassengerId, Survived = my_prediction)

# Write my solution to a csv file with the name my_solution.csv
# Don't add the row names
write.csv(my_solution, file="./data/solution_rf.csv" , row.names = FALSE)

levels(train$Embarked)
levels(test$Embarked)
