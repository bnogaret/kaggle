# Set the working directory
setwd("~/Desktop/kaggle/whats_cooking/")

library(Amelia)
library(jsonlite)
library(data.table)

# Get the most common ingredients for a particular cuisine
topIngredients <- function(data, cuisine, topNum = 5) {
  list_ingredient <- unlist(data$ingredients[data$cuisine == cuisine])
  table <- data.table(table(list_ingredient))
  colnames(table) <- c("ingredients", "Freq")
  table <- table[order(table$Freq, decreasing = TRUE),]
  return(table$ingredients[1:topNum])
}

# Get the most common ingredients for each kind of cuisines
# Return a list (either list[1] or list$greek to get the ingredients for greek)
topIngredientsAll <- function(data, topNum = 5) {
  list_cuisine <- unique(train$cuisine)
  list_top <- sapply(list_cuisine, FUN=function(x) {
    topIngredients(data, x, topNum)
  }, simplify = FALSE)
  return(list_top)
}

train <- fromJSON("./data/train.json", flatten=TRUE)
test <- fromJSON("./data/test.json", , flatten=TRUE)

str(train)
sapply(train, class)
head(train, n = 2L)
tail(train, n = 2L)

# Add a variable to count the number of ingredients for each recipe
train$nbIngredients <- sapply(train$ingredients, FUN=length)
test$nbIngredients <- sapply(test$ingredients, FUN=length)

# Missing data per column
sapply(train, function(x) sum(is.na(x)))
sapply(test, function(x) sum(is.na(x)))
# To see the missing data (need amelia)
missmap(train)

# Top ingredients for each cuisine
t <- topIngredientsAll(train)

# Show the number of recipes per type of cuisine
ftable <- table(train$cuisine)
barplot(ftable, las=2)

# Mean number of ingredient per type of cuisine
ftable <- aggregate(nbIngredients ~ cuisine, data=train, FUN=mean)
barplot(ftable$nbIngredients, names.arg=ftable[,1], las = 2)
