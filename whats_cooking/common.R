# Text Mining
library(tm)
library(RWeka)
library(SnowballC)

# Normalize the ingredients :
# lower case, no repetition, replace - by _, replace non regular characters, trim the string
normalize <- function(data) {
  data$ingredients <- lapply(data$ingredients, FUN=tolower)
  data$ingredients <- lapply(data$ingredients, FUN=function(x) gsub("-", "_", x))
  data$ingredients <- lapply(data$ingredients, FUN=function(x) gsub("[^a-z0-9_ ]", "", x))
  return(data)
}

# Get the document term matrix from the different ingredients include in train and test
# Add the number of ingredients after having removed sparse terms
# Stopwords are removed + stem the words + trim
getDtmAsDf <- function(train, test, keepTerm = 0.99) {
    train <- normalize(train)
    test <- normalize(test)
    
    # Build a corpus that is a collection of text documents (train and test)
    myCorpus <- c(Corpus(VectorSource(train$ingredients)), Corpus(VectorSource(test$ingredients)))
    myCorpus <- tm_map(myCorpus, stripWhitespace)
    # Apply remowords(stopwords) for myCorpus
    myCorpus <- tm_map(myCorpus, removeWords, stopwords('english'))
    # Stem the words of the document (need library RWeka and SnowballC)
    myCorpus <- tm_map(myCorpus, stemDocument)
  
    # Create a Document-Term matrix
    # myDtm <- DocumentTermMatrix(myCorpus, control = list(minWordLength = 1, weighting = function(x) weightTfIdf(x, normalize = FALSE)))
    myDtm <- DocumentTermMatrix(myCorpus)
    # The DTM is very sparse (sparsity = 99% !)
    # Reducing the number of features, by removing ingredients that don’t occur often, may help with the model
    # (although sometimes unique ingredients may be key to predict certain cuisines).
    # The sparsity threshold works as follows :
    # If we say 0.98, this means to only keep terms that appear in 2% or more of the recipes.
    # If we say 0.99, that means to only keep terms that appear in 1% or more of the recipes.
    myDtm <- removeSparseTerms(myDtm, keepTerm)
    myDtm <- as.data.frame(as.matrix(myDtm))
    
    myDtm$nbIngredients <- rowSums(myDtm)
    return(myDtm)
}
