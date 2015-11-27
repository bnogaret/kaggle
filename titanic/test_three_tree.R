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

# Add some option on rpart
# minsplit : the minimum number of observations that must exist in a node in order for a split to be attempted.
# cp : the complexity parameter
control = rpart.control(minsplit = 50, cp = 0)

# Add a new feature at the train set : family size = (SibSp + Parch + 1)
# Why ? Hypothesis : the bigger the family is, the more time it needs to get together on a sinking ship, and hence have less chance of surviving.
train$family_size <- train$SibSp + train$Parch + 1

# Build the decision tree
# Use ?rpart in the console for more information
# Formula explanation :
# Predict survived based on the variables Passenger Class, Sex, Age, Number of Siblings/Spouses Aboard, Number of Parents/Children Aboard, Passenger Fare and Port of Embarkation.
my_tree <- rpart(formula = Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked + family_size, data = train, method = "class", control = control)

# Load in the packages to create a fancified version of my tree (plot and text are too basic)
library(rattle)
library(rpart.plot)
library(RColorBrewer)

# Plot my fancy tree
fancyRpartPlot(my_tree)
# We can see that $family_size is not included in the plot
# Apparently other variables played a more important role.

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