import matplotlib
import pandas as pd
import numpy as np

matplotlib.use('Qt5Agg')

import matplotlib.pyplot as plt
import matplotlib.cm as cm
from sklearn.decomposition import PCA
from sklearn.manifold import TSNE

from exploratoryUtils import *

NB_ROWS_TSNE = 2000

dataset_train = pd.read_csv("./data/train.csv", encoding="utf-8")
dataset_test = pd.read_csv("./data/test.csv", encoding="utf-8")

basic_info_df(dataset_train)

# Get an numpy ndarray of the label (first column of the dataset_train)
labels = dataset_train[[0]].values

# Get the number of images for each digit
list_label, count_per_label = np.unique(labels, return_counts=True)
print(list_label, count_per_label)
plt.bar(list_label, count_per_label)
plt.xlabel("Digit")
plt.ylabel("Number of images")
plt.title("Number of images per digit character")
plt.savefig("./image/images_per_digit.png")
plt.show()

# Get an numpy ndarray of the pixels
train = dataset_train.iloc[:, 1:].values
test = dataset_test.values

colors = [int(i) for i in labels]


# Principal component analysis (just print the first two)
pca = PCA(n_components=2, whiten=True)
train_pca = pca.fit(train).transform(train)
# Very low level of variance ration. As expected, two is not enough.
print('Explained variance ratio (first two components): %s' % str(pca.explained_variance_ratio_))
plt.scatter(train_pca[:, 0], train_pca[:, 1], c=colors)
plt.title("First two components for PCA")
plt.savefig("./image/pca.png")
plt.show()


# t-distributed Stochastic Neighbor Embedding
# only the first NB_ROWS_TSNE rows, otherwise : MemoryError
# See : https://github.com/scikit-learn/scikit-learn/issues/4619
tsne = TSNE(n_components=2, random_state=0, verbose=2)
train_tsne = tsne.fit_transform(train[0:NB_ROWS_TSNE, :])
plt.scatter(train_tsne[:, 0], train_tsne[:, 1], c=colors[0:NB_ROWS_TSNE])
plt.title("TSNE map (first %s rows)" % NB_ROWS_TSNE)
plt.savefig("./image/tsne_%s.png" % NB_ROWS_TSNE)
plt.show()


# Return a 1D array of the different label values (Basically array([1, 0, 1, ..., 7, 6, 9]))
target = labels.ravel().astype(np.uint8)
print(target)

# Convert the 1D array of size 784 in a 2D array of size 28*28 (real size of the image)
train = np.array(train).reshape((-1, 1, 28, 28)).astype(np.uint8)
test = np.array(test).reshape((-1, 1, 28, 28)).astype(np.uint8)

plt.imshow(train[69][0], cmap=cm.binary)
plt.show()

plt.imshow(test[69][0], cmap=cm.binary)
plt.show()
