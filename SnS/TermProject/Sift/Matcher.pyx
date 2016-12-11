from FeatureDescription cimport PointFeature
from Defaults import MATCH_DIST_RATIO
from numpy cimport int_t, double_t
import numpy as np


cdef dict match(list features1, list features2):
    """
    For each point in features1, find the point in feature2 that matches it.

    :param features1: list
        # The list of the features in one image #
    :param features2: list
        # The list of the features in another image #

    :return: dict
        # The dictionary of the matched points #
        The key of each item is the feature from features1; the corresponding
        value is the matched feature in features2.

    """
    cdef:
        dict match_scores = {}
        int l1 = len(features1), l2 = len(features2)
        int i1, i2
        PointFeature f1, f2
        double_t[::1] dotprods = np.zeros(l2, dtype=np.double)
        double_t[::1] desc1, desc2
        double_t[::1] angular_dist
        int_t[::1] sorted_indexes

    for i1 in range(0, l1):
        f1 = features1[i1]
        desc1 = np.array(f1.descriptor, dtype=np.double)
        desc1 /= np.linalg.norm(desc1)
        for i2 in range(0, l2):
            desc2 = np.array(features2[i2].descriptor, dtype=np.double)
            desc2 /= np.linalg.norm(desc2)
            dotprods[i2] = np.dot(desc1, desc2)

        angular_dist = np.arccos(dotprods)
        sorted_indexes = np.argsort(angular_dist)
        # print("angular_dist: ", np.array(angular_dist))
        # print("sorted_indexes (small to large): ", np.array(sorted_indexes))

        if angular_dist[sorted_indexes[0]] < \
            MATCH_DIST_RATIO * angular_dist[sorted_indexes[1]]:
            f2 = features2[sorted_indexes[0]]
            match_scores[f1.coord] = f2.coord

    return match_scores



cpdef dict match_twosides(list features1, list features2):
    """
    Bi-directional matching function.

    :param features1: list
        # The list of the features in one image #
    :param features2: list
        # The list of the features in another image #

    :return: dict
        # The dictionary of the matched points #
        The key of each item is the feature from features1; the corresponding
        value is the matched feature in features2.

    """
    cdef:
        int i
        # Since the dictionary's size is not supposed to be changed during the
        # iteration, we have to use a new dict to store the updated matching
        # result.
        dict matches12, matches21, matches = {}
        tuple coord1, coord2

    matches12 = match(features1, features2)
    matches21 = match(features2, features1)

    for coord1 in matches12.keys():
        coord2 = matches21.get(matches12[coord1], None)
        if coord2 == coord1:
            matches[coord1] = matches12[coord1]

    return matches

