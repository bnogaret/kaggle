import matplotlib
matplotlib.use('Qt5Agg')

import numpy as np
import matplotlib.pyplot as plt
import pandas as pd


def proportion_null_column(df):
    return (df.isnull().sum() / df.shape[0]) * 100


def basic_info_df(df):
    print(df.columns)
    print(df.info(verbose=True))
    print(df.describe())
    print(df.head(n=1))
    print(proportion_null_column(df))


dataset_store = pd.read_csv("./data/store.csv", encoding="utf-8")
dataset_train = pd.read_csv("./data/train.csv", encoding="utf-8")
dataset_test = pd.read_csv("./data/test.csv", encoding="utf-8")

basic_info_df(dataset_store)
basic_info_df(dataset_train)
basic_info_df(dataset_test)

# Convert the column Date from object into datetime
dataset_train['Date'] = pd.to_datetime(dataset_train['Date'], format='%Y-%m-%d')

plt.plot_date(dataset_train.loc[dataset_train.Store == 1, 'Date'],
              dataset_train.loc[dataset_train.Store == 1, 'Sales'])
plt.title("Sales for Store 1 per date")
plt.savefig("./image/sales_store_1.png")
plt.show()

temp = dataset_train.groupby('Date')['Sales']
dates = np.unique(dataset_train.loc[:, 'Date'].values)

plt.plot_date(dates,
              temp.apply(lambda x: x.mean()),
              'ro',
              label="Mean")
plt.plot_date(dates,
              temp.apply(lambda x: x.max()),
              'bs',
              label="Max")
plt.plot_date(dates,
              temp.apply(lambda x: x.min()),
              'g^',
              label="Min")
plt.ylabel("Sales")
plt.xlabel("Date")
plt.title("Some summaries of sales per date")
plt.legend(loc=2)
plt.savefig("./image/sales_summary.png")
plt.show()

# Histograms of sale : distribution and mean
temp = dataset_train.groupby('Store')['Sales'].apply(lambda x: x.mean()).values

plt.figure(1)
# nrows/ncols/plot_numbers
plt.subplot(221)
plt.hist(dataset_train['Sales'], bins=25)
plt.title("Distribution of sales")
plt.subplot(222)
plt.hist(np.log(dataset_train['Sales'] + 1), bins=25)
plt.title("Distribution of log(sales)")

plt.subplot(223)
plt.hist(temp, bins=25)
plt.title("Average sales per store")
plt.subplot(224)
plt.hist(np.log(temp + 1), bins=25)
plt.title("Average log(sales) per store")
plt.savefig("./image/hist_sales.png")
plt.show()

from scipy.stats import norm
import matplotlib.mlab as mlab

# Learn the mean and standard deviation (the square root of the variance)
mu, std = norm.fit(np.log(temp + 1))
# Draw the
n, bins, patches = plt.hist(np.log(temp + 1), 25, normed=1, facecolor='green', alpha=0.5, label="Average log(sales)")
# add a 'best fit' line
y = mlab.normpdf(bins, mu, std)
plt.plot(bins, y, 'r--', label="Estimated normal distribution")
plt.legend()
plt.savefig("./image/hist_average_sales_with_normal.png")
plt.show()

train = pd.merge(dataset_train, dataset_store, on="Store")
test = pd.merge(dataset_train, dataset_store, on="Store")
