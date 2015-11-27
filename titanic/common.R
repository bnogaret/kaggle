library(stringr) # for str_extract
library(plyr) # for join

predict_Age_Fare <- function(full, data) {
    # Create linear models for predicting missing values in AGE and FARE on all the data
    age.mod <- lm(Age ~ Pclass + Sex + SibSp + Parch + Fare, data = full[!is.na(full$Age),])
    fare.mod<- lm(Fare ~ Pclass + Sex + SibSp + Parch + Age, data = full[!is.na(full$Fare),])
    # Predict the missing data
    data$Age[is.na(data$Age)] <- predict(age.mod, data)[is.na(data$Age)]
    data$Fare[is.na(data$Fare)] <- predict(fare.mod, data)[is.na(data$Fare)]
    return(data)
}

add_feature_Child <- function(data) {
    data$Child[data$Age < 18] <- 1
    data$Child[data$Age >= 18] <- 0
    return(data)
}

add_feature_FamilySize <- function(data) {
    data$FamilySize <- data$SibSp + data$Parch + 1
    return(data)
}

add_feature_Title <- function(data) {
    data$Title <- NA
    data$Title[!is.na(str_extract(data$Name, "Mr"))] <- "Mr"
    data$Title[!is.na(str_extract(data$Name, "Mrs"))] <- "Mrs"
    data$Title[!is.na(str_extract(data$Name, "Mme"))] <- "Mrs"
    data$Title[!is.na(str_extract(data$Name, "Miss"))] <- "Miss"
    data$Title[!is.na(str_extract(data$Name, "Ms"))] <- "Miss"
    data$Title[!is.na(str_extract(data$Name, "Mlle"))] <- "Miss"
    data$Title[!is.na(str_extract(data$Name, "Capt"))] <- "Mr"
    data$Title[!is.na(str_extract(data$Name, "Major"))] <- "Mr"
    data$Title[!is.na(str_extract(data$Name, "Col"))] <- "Mr"
    data$Title[!is.na(str_extract(data$Name, "Master"))] <- "Mr"
    data$Title[!is.na(str_extract(data$Name, "Rev"))] <- "Mr"
    data$Title[!is.na(str_extract(data$Name, "Dr"))] <- "Mr"
    data$Title[!is.na(str_extract(data$Name, "Don"))] <- "Mr"
    data$Title[!is.na(str_extract(data$Name, "Countess"))] <- "Mrs"
    data$Title[!is.na(str_extract(data$Name, "Jonkheer"))] <- "Mr"
    return(data)
}

clean <- function(train, test) {
    full <- join(test, train, type="full")
    train <- predict_Age_Fare(full, train)
    test <- predict_Age_Fare(full, test)

    # Add Child
    train <- add_feature_Child(train)
    test <- add_feature_Child(test)

    # Add familySize
    train <- add_feature_FamilySize(train)
    test <- add_feature_FamilySize(test)

    # Add a title
    train <- add_feature_Title(train)
    test <- add_feature_Title(test)

    train$Embarked[train$Embarked == ""] <- "S"
    test$Embarked[test$Embarked == ""] <- "S"

    return(list(train=train, test=test))
}
