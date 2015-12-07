import time
import numpy as np
import pandas as pd
from sklearn import svm
from sklearn.decomposition import PCA

# 0.97914 pca.pca.explained_variance_ratio_ > 0.9 (num = 87)
# 0.96800 pca.pca.explained_variance_ratio_ > 0.8 (num = 43)
# 0.98243 with num = 35
# 0.98529 with num = 0.8 and C=10
# 0.98429 with num = 0.8 and C=2

start_time_read = time.time()
dataset_train = pd.read_csv("./data/train.csv", encoding="utf-8")
dataset_test = pd.read_csv("./data/test.csv", encoding="utf-8")
end_time_read = time.time()

# Get an numpy ndarray of the pixels
labels = dataset_train[[0]].values.ravel()
train = dataset_train.iloc[:, 1:].values
test = dataset_test.values

# Get PCA
start_time_pca = time.time()
# Want PCA to have explained_variance_ratio_ > 0.9 (as 0 < num < 1)
pca = PCA(n_components=0.8, whiten=True)
train_pca = pca.fit_transform(train)
end_time_pca = time.time()

# Create and train the SVM
start_time_svm = time.time()
svm = svm.SVC(C=10.0, verbose=True)
svm.fit(train_pca, labels)
end_time_svm = time.time()

# Make the prediction on test but first has to use PCA
test_pca = pca.transform(test)
pred = svm.predict(test_pca)

# Save as a dataSet
np.savetxt('./data/solution_svm.csv',
           np.c_[range(1, len(test)+1), pred],
           delimiter=',',
           header='ImageId,Label',
           comments='',
           fmt='%d')

print("Time to read the data : %s || Time for PCA : %s || Time to train : %s" %
      (end_time_read - start_time_read, end_time_pca - start_time_pca, end_time_svm - start_time_svm))
