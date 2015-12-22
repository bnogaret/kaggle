import pandas as pd
import numpy as np
import common_python.haversineDistance as hd

# Result : 24149827928.55160

# Position of the north pole (in degree)
NORTH_POLE = (90, 0)
MAXIMUM_WEIGHT_CAPACITY = 1000


#@profile
def get_sorted_haversine_distance(array, point):
    # Get the array of distance
    t = hd.haversine_distance_array_point(array, point, angle='degree')
    # Create the array(distance, GiftId)
    t = np.column_stack((t, array[:, 2]))
    # Sort the array by distance (move the whole line!)
    return t[t[:, 0].argsort()]


#@profile
def greedy(df, seed=None):
    """
    :param df:
    :param seed:
    :return:
    """
    # Shuffle the GiftId
    np.random.seed(seed)
    id_visited = {}
    current_trip_id = 0
    # Number from 1 to number of rows of df (including)
    l = np.arange(1, df.shape[0] + 1)
    np.random.shuffle(l)

    for i in l[0:2]:
        if i not in id_visited:
            current_trip_id += 1
            id_visited[i] = True

            df.loc[df['GiftId'] == i, 'TripId'] = current_trip_id
            total_weight = df.loc[df['GiftId'] == i, 'Weight'].values[0]
            position = df.loc[df['GiftId'] == i, ['Latitude', 'Longitude']].values[0]
            # Get all the rows that haven't been visited yet
            dist = df[~df['GiftId'].isin(id_visited)]
            # If all the row have already been visited, we leave
            if dist.shape[0] == 0:
                break
            dist = dist[['Latitude', 'Longitude', 'GiftId']].values
            dist = get_sorted_haversine_distance(dist, position)

            j = 0
            while j < dist.shape[0]:
                gift_id = int(dist[j, 1])
                temp_weight = df.loc[df['GiftId'] == gift_id, 'Weight'].values[0]
                if total_weight + temp_weight > MAXIMUM_WEIGHT_CAPACITY:
                    break
                else:
                    id_visited[gift_id] = True
                    total_weight += temp_weight
                    df.loc[df['GiftId'] == gift_id, 'TripId'] = current_trip_id
                j += 1
            print(current_trip_id, total_weight, j, dist.shape, df.shape)


dataset_gift = pd.read_csv("./data/gifts.csv")
# Transform the Latitude / Longitude in radian
dataset_gift.loc[:, 'TripId'] = 0
greedy(dataset_gift, seed=0)

np.savetxt('./data/solution_greedy.csv',
           np.c_[dataset_gift['GiftId'], dataset_gift['TripId']],
           delimiter=',',
           header='GiftId,TripId',
           comments='',
           fmt='%d')
