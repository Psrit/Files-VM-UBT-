import os
from PIL import Image
from pylab import *
from numpy import *


def get_imlist(path):
    """
    :param path:
    :return: the list of names of all JPG files in path

    """
    return [os.path.join(path, filename) for filename in os.listdir(path) if filename.endswith(".jpg")]
    # [expression for item in iterable if condition]


def imresize(im, sz):
    """
    :param im: PIL image array
    :param sz: new size
    :return: array of the resized image

    """
    pil_im = Image.fromarray(uint8(im))  # 8-bit unsigned int
    return array(pil_im.resize(sz))


def histeq(im, nbr_bins=256):
    """
    equalize the greyscale histogram

    :param im: input array of a PIL image
    :param nbr_bins: number of bins of the histogram
    :return: the array of histogram-equalized image, and normalized cdf of the histogram

    >>> testfile = "./fig/pycharm.png"
    >>> im = array(Image.open(testfile).convert("L"))
    >>> im2, cdf = histeq(im)
    >>> imshow(Image.fromarray(im2))
    >>> show()

    """
    imhist, bins = histogram(im.flatten(), nbr_bins, density=True)
    cdf = imhist.cumsum()  # cumulative distribution function
    cdf = 255 * cdf / cdf[-1]  # normalize cdf: cdf[-1] == 255

    im_transformed = interp(im.flatten(), bins[:-1], cdf)
    # y = interp(x, xp, fp, left=None, right=None, period=None)
    # bins[:-1] doesn't include b[-1]

    return im_transformed.reshape(im.shape), cdf
    # since im2 is a 1-D array, it must be reshaped by using im's shape (tuple(rows, cols))


def compute_average(imlist):
    """
    calculate the average image of imlist

    :param imlist: list of filenames of input images
    :return: array of the average image of imlist

    """
    averageim = array(Image.open(imlist[0]), "f")
    for imname in imlist[1:]:
        try:
            averageim += array(Image.open(imname))
        except:
            print imname + "...skipped"
    averageim /= len(imlist)

    return array(averageim, "uint8")


if __name__ == "__main__":
    import doctest

    doctest.testmod(verbose=True)
