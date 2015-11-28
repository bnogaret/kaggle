library(stringr) # for str_extract
library(plyr) # for join
library(rpart)

predict_Age_Fare <- function(full, data) {
    # Decision tree for missing data
    age_rpart <- rpart(Age ~ Pclass + Sex + Embarked + Title + Sex + FamilySize + SibSp + Parch + Fare,
                       data = full[!is.na(full$Age),],
                       method='anova')
    # Predict the missing data
    data$Age[is.na(data$Age)] <- predict(age_rpart, data)[is.na(data$Age)]
    # Replace NA fare value by the median one
    data$Fare[is.na(data$Fare)] <- median(data$Fare, na.rm = TRUE)
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

add_feature_Mother <- function(data) {
    data$Mother <- 0
    data$Mother[data$Sex=='female' & data$Parch>0 & data$Age>18 & data$Title!='Miss'] <- 1
    return(data)
}

clean <- function(train, test) {
    # Exclude the column Survived
    full <- join(train[,-2], test, type="full")

    # Make sure it has an Embarked
    full$Embarked[full$Embarked == ""] <- "S"

    # Add the feature "FamilySize"
    full <- add_feature_FamilySize(full)

    # Add the feature "Title"
    full <- add_feature_Title(full)

    # Predict the variable Age and Fare (there are some missing data for this value)
    # See exploratory.R
    full <- predict_Age_Fare(full, full)

    # Add the feature "Child"
    full <- add_feature_Child(full)

    # Add the feature "Mother"
    full <- add_feature_Mother(full)

    # Make sure some columns are categorical variable
    full$Title <- as.factor(full$Title)
    full$Embarked <- as.factor(full$Embarked)

    # Split the data to train and test
    train_temp <- full[1:nrow(train),]
    train_temp$Survived <- train$Survived
    test_temp <- full[-(1:nrow(train)),]

    return(list(train=train_temp, test=test_temp))
}
