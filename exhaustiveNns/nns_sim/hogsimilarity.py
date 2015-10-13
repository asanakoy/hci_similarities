import numpy as np
from pprint import pprint
import scipy.signal
import cv2

__author__ = 'asanakoy'


def get_hog_similarity(h1, h2, padsize, h1_reversed=None, h1_flipped_reversed=None):
    if h1_reversed is None:
        h1_reversed = h1[::-1, ::-1, ::-1]

    if h1_flipped_reversed is None:
        h1_flipped_reversed = h1[::-1, :, ::-1]

    overlap_area = 1.0 * min(h1.shape[1], h2.shape[1]) * min(h1.shape[2], h2.shape[2])

    new_h2 = np.zeros((h1.shape[0], h1.shape[1] + 2 * padsize, h1.shape[2] + 2 * padsize),
                        dtype=np.float32)

    M = min(new_h2.shape[1], h2.shape[1])
    N = min(new_h2.shape[2], h2.shape[2])
    new_start = ((new_h2.shape[1] - M) / 2, (new_h2.shape[2] - N) / 2)
    start = ((h2.shape[1] - M) / 2, (h2.shape[2] - N) / 2)

    new_h2[:, new_start[0]:(new_start[0] + M), new_start[1]:(new_start[1] + N)] =\
        h2[:, start[0]:(start[0] + M),         start[1]:(start[1] + N)]

    # val1 = np.amax(scipy.signal.convolve(new_h2, h1_reversed, 'valid')) / overlap_area
    # val2 = np.amax(scipy.signal.convolve(new_h2, h1_flipped_reversed, 'valid')) / overlap_area

    val1 = None
    for i in range(h1.shape[0]):
        if val1 is None:
            val1 = scipy.signal.correlate2d(new_h2[i], h1[i], 'valid')
        else:
            val1 += scipy.signal.correlate2d(new_h2[i], h1[i], 'valid')
    val1 = np.amax(val1) / overlap_area

    val2 = 0

    similarity = val1
    isFlipped = 0

    if val1 < val2:
        similarity = val2
        isFlipped = 1

    return (similarity, isFlipped)
