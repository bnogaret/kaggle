#Set the working directory to save the result in a ccsv file
setwd("/home/nogaret/Desktop/kaggle/titanic/")

# Import the training set: train
train_url <- "http://s3.amazonaws.com/assets.datacamp.com/course/Kaggle/train.csv"
train <- read.csv(train_url)

# Import the testing set: test
test_url <- "http://s3.amazonaws.com/assets.datacamp.com/course/Kaggle/test.csv"
test <- read.csv(test_url)

# Load in the R package rpat that includes decision trees 
library(rpart)

# Build the decision tree
# Use ?rpart in the console for more information
# Formula explanation :
# Predict survived based on the variables Passenger Class, Sex, Age, Number of Siblings/Spouses Aboard, Number of Parents/Children Aboard, Passenger Fare and Port of Embarkation.
my_tree <- rpart(formula = Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked, data = train, method = "class")
# Based on the decision tree, the variables that play the most important role to to determine whether or not a passenger will survive are :
# Sex, Age, Passenger Class, Number of Siblings/Spouses Aboard, Fare

# Visualize the decision tree using plot() and text()
plot(my_tree)
text(my_tree)

# Load in the packages to create a fancified version of my tree (plot and text are too basic)
library(rattle)
library(rpart.plot)
library(RColorBrewer)

# Plot my fancy tree
fancyRpartPlot(my_tree)

# Make my prediction using the test set
# see https://stat.ethz.ch/R-manual/R-devel/library/rpart/html/predict.rpart.html for more information
my_prediction <- predict(my_tree, test, type="class")

# Create a data frame with two columns: PassengerId & Survived. Survived contains my predictions
my_solution <- data.frame(PassengerId = test$PassengerId, Survived = my_prediction)

# Check that my data frame has 418 entries
nrow(my_solution)

# Write my solution to a csv file with the name my_solution.csv
# Don't add the row names
write.csv(my_solution, file="./my_solution_test_two.csv" , row.names = FALSE)