from numpy import *
from pylab import *
from PIL import Image

testfile = "../fig/pycharm.png"

im = array(Image.open(testfile))
print im.shape, im.dtype  # features of array

im = array(Image.open(testfile).convert("L"), "f")
print im.shape, im.dtype

vsize = im.shape[0]  # number of rows
hsize = im.shape[1]  # number of columns
im1 = im[:vsize / 2, :hsize / 2]
imshow(Image.fromarray(im1))
show()

im2 = 255 - im
imshow(Image.fromarray(im2))
show()

im3 = (100.0 / 255) * im + 100
imshow(Image.fromarray(im3))
show()

im4 = 255.0 * (im/255.0)**2
imshow(Image.fromarray(im4))

show()
