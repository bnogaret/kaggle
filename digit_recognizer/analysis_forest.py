import time
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier

# 0.96814 with 500 trees
# 0.96800 with 1000 trees

start_time_read = time.time()
dataset_train = pd.read_csv("./data/train.csv", encoding="utf-8")
dataset_test = pd.read_csv("./data/test.csv", encoding="utf-8")
end_time_read = time.time()

# Get an numpy ndarray of the pixels
labels = dataset_train[[0]].values.ravel()
train = dataset_train.iloc[:, 1:].values
test = dataset_test.values

# Create and train the Random Forest
start_time_rf = time.time()
rf= RandomForestClassifier(n_estimators=1000, n_jobs=4)
rf.fit(train, labels)
end_time_rf = time.time()

# Make the prediction on test
pred = rf.predict(test)

# Save as a dataSet
np.savetxt('./data/solution_random_forest.csv',
           np.c_[range(1,len(test)+1), pred],
           delimiter=',',
           header = 'ImageId,Label',
           comments = '',
           fmt='%d')

print("Time to read the data : %s || Time to train : %s" %
      (end_time_read - start_time_read, end_time_rf - start_time_rf))