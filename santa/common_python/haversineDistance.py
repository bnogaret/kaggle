from math import radians, cos, sin, asin, sqrt
import numpy as np


AVG_EARTH_RADIUS = 6371  # in km


def haversine_distance_points(point1, point2, angle='rad'):
    """
    Calculate the Haversine distance between two points, i.e. the great-circle
    distance between two points on a sphere from their longitudes and latitudes.
    For more information, :see https://en.wikipedia.org/wiki/Haversine_formula
    :param point1: point2: two 2-tuples, containing the latitude and longitude of each point
    (first value the latitude, second value longitude).
    :param angle: the unit for the latitudes and longitudes (point and array). It's either 'rad' or 'degree'.
    :return Returns the distance between the two points in km.
    """
    # unpack latitude/longitude
    lat1, lng1 = point1
    lat2, lng2 = point2

    if angle=='degree':
        # convert all latitudes/longitudes from decimal degrees to radians
        lat1, lng1, lat2, lng2 = map(radians, (lat1, lng1, lat2, lng2))

    # calculate haversine
    lat = lat2 - lat1
    lng = lng2 - lng1
    d = sin(lat / 2) ** 2 + cos(lat1) * cos(lat2) * sin(lng / 2) ** 2
    h = 2 * AVG_EARTH_RADIUS * asin(sqrt(d))

    return h


def haversine_distance_arrays(array1, array2, angle='rad'):
    """
    Calculate the Haversine distance between each point of the numpy array.
    The first column of the 2 arrays is the latitude, the second is the longitude.
    :param array1: a numpy array of two columns
    :param array2: a numpy array of two columns
    :param angle: the unit for the latitudes and longitudes (point and array). It's either 'rad' or 'degree'.
    :return: a numpy array of one column
    """
    if angle == 'degree':
        # Convert the arrays
        lat1 = np.radians(array1[:, 0])
        long1 = np.radians(array1[:, 1])
        lat2 = np.radians(array2[:, 0])
        long2 = np.radians(array2[:, 1])
    else:
        lat1 = array1[:, 0]
        long1 = array1[:, 1]
        lat2 = array2[:, 0]
        long2 = array2[:, 1]
    dlat = lat1 - lat2
    dlong = long1 - long2
    t = np.square(np.sin(dlat/2.0)) + np.cos(lat1) * \
        np.cos(lat2) * np.square(np.sin(dlong/2.0))
    t = AVG_EARTH_RADIUS * 2 * np.arcsin(np.sqrt(t))
    return t


def haversine_distance_array_point(array, point, angle='rad'):
    """
    Calculate the Haversine distance between each point of the numpy 'array' and the point 'point'.
    :param array: the numpy array. First column contains the latitudes and
    the second column, the longitudes.
    :param point: the coordinate of the point (latitude, longitude)
    :param angle: the unit for the latitudes and longitudes (point and array). It's either 'rad' or 'degree'.
    :return: a numpy array of one column
    """
    # Create an array by repeating the point p
    p = np.array([[point[0], point[1]], ] * array.shape[0])
    print(p)
    return haversine_distance_arrays(array, p, angle)
