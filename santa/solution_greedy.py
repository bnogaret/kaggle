import pandas as pd
import numpy as np
import common_python.haversineDistance as hd

# 17927556718.34740 (greedy_random)
# 16886488245.97060 (greedy_shortest_north_pole)

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
def get_greedy_shortest_path(df, current_gift_id, id_visited, current_trip_id):
    df.loc[df['GiftId'] == current_gift_id, 'TripId'] = current_trip_id
    total_weight = df.loc[df['GiftId'] == current_gift_id, 'Weight'].values[0]
    position = df.loc[df['GiftId'] == current_gift_id, ['Latitude', 'Longitude']].values[0]
    # Get all the rows that haven't been visited yet
    dist = df[~df['GiftId'].isin(id_visited)]
    dist = dist[['Latitude', 'Longitude', 'GiftId']].values
    dist = get_sorted_haversine_distance(dist, position)

    j = 0
    while j < dist.shape[0]:
        gift_id = int(dist[j, 1])
        temp_weight = df.loc[df['GiftId'] == gift_id, 'Weight'].values[0]
        if total_weight + temp_weight >= MAXIMUM_WEIGHT_CAPACITY:
            break
        else:
            id_visited[gift_id] = True
            total_weight += temp_weight
            df.loc[df['GiftId'] == gift_id, 'TripId'] = current_trip_id
        j += 1
    print(current_trip_id, total_weight, j, dist.shape, df.shape)


#@profile
def greedy_shortest_north_pole(df):

    id_visited = {}
    current_trip_id = 0
    l = df[['Latitude', 'Longitude', 'GiftId']].values
    l = get_sorted_haversine_distance(l, NORTH_POLE)
    l = l[:, 1].tolist()

    for i in l:
        if i not in id_visited:
            current_trip_id += 1
            id_visited[i] = True

            get_greedy_shortest_path(df, i, id_visited, current_trip_id)


#@profile
def greedy_random(df, seed=None):
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

    for i in l:
        if i not in id_visited:
            current_trip_id += 1
            id_visited[i] = True

            get_greedy_shortest_path(df, i, id_visited, current_trip_id)


dataset_gift = pd.read_csv("./data/gifts.csv")
# Add the column TripId and initialise it at 0
dataset_gift.loc[:, 'TripId'] = 0

greedy_shortest_north_pole(dataset_gift)
#greedy_random(dataset_gift)

# Put the heaviest gift first (considered as the first to be delivered)
dataset_gift = dataset_gift.sort_values(['TripId', 'Weight'], ascending=[True, False])

np.savetxt('./data/solution_greedy.csv',
           np.c_[dataset_gift['GiftId'], dataset_gift['TripId']],
           delimiter=',',
           header='GiftId,TripId',
           comments='',
           fmt='%d')
