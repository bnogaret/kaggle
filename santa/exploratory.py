import matplotlib
matplotlib.use('Qt5Agg')

import matplotlib.pyplot as plt
import pandas as pd


def basic_info_df(df):
    print(df.columns)
    print(df.info(verbose=True))
    print(df.describe())
    print(df.head(n=1))


dataset_gift = pd.read_csv("./data/gifts.csv")
basic_info_df(dataset_gift)

# s for the size of the points / alpha for the transparency
dataset_gift.plot.scatter('Longitude', 'Latitude', s=1, color="yellow", alpha=0.5)
plt.title("Gift location (%d gifts)" % len(dataset_gift))
plt.show()
plt.savefig("./image/gift_location.png")
