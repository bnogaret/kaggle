"""
Gather functions to use when the dataset is explored.
"""


def basic_info_series(c):
    """
    :param c:
    :return:
    """
    print(c.describe())
    print("Number of null values %d (%d %%)" % (c.isnull().sum(), proportion_null_df(c)))


def proportion_null_df(df):
    """
    Return the proportion of null value for a column / several columns
    :param df:
    :return:
    """
    return (df.isnull().sum() / df.shape[0]) * 100


def basic_info_df(df, verbose=False):
    print("************************************")
    print("* Basic info on a pandas.dataframe *")
    print("************************************")
    print("Size: ({0} lignes, {1} columns)".format(*df.shape))
    print(df.columns)
    print(proportion_null_df(df))
    print(df.info(verbose=verbose))
    print(df.describe())
    print("Example for the first row:")
    print(df.head(n=1))