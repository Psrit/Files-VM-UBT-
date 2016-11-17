import os
from PIL import Image
from pylab import *


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
