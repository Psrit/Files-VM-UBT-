import os
from PIL import Image
from scipy import *
from pylab import *
from Sift.ImagePreprocessing import decimation
from Sift.DOGSpaceGenerator import GaussianPyramid
from Sift.Math import *


# TODO: TO BE COMPLETED

def appendimages(im1, im2):
    rows1 = im1.shape[0]
    rows2 = im2.shape[0]
    if rows1 < rows2:
        im1 = concatenate((im1, zeros((rows2 - rows1, im1.shape[1]))), axis=0)
    elif rows1 > rows2:
        im2 = concatenate((im2, zeros((rows1 - rows2, im2.shape[1]))), axis=0)
    return concatenate((im1, im2), axis=1)


def plot_matches(im1, im2, locs1, locs2, matchscores, show_below=True):
    im3 = appendimages(im1, im2)
    if show_below:
        im3 = vstack((im3, im3))
    imshow(im3)
    cols1 = im1.shape[1]
    for i, m in enumerate(matchscores):
        if m > 0:
            plot([locs1[i][1], locs2[m][1] + cols1], [locs1[i][0], locs2[m][0]], 'c')
    axis('off')
