from PIL import Image
from numpy import *
from pylab import *
from scipy.ndimage import filters

import scipy
from scipy.misc import imsave

testfile = "../fig/pycharm.png"

# image blurring
# ---------------------------------------------------------
# I_{blurred} = I * G_{\sigma}, G is 2-D Gaussian convolution kernel

im = array(Image.open(testfile).convert("L"), "f")  # "f" is needed!
im2 = filters.gaussian_filter(im, 3)

imshow(Image.fromarray(im2))  # don't use uint8(im2) (?)
show()

# image derivative
# ---------------------------------------------------------
# take I_{x/y} to be the derivative of image I in x/y direction
# I_{x/y} = I * D_{x/y}, D is Prewitt filter:
# D_x = [[-1,0,1],[-1,0,1],[-1,0,1]], D_y = [[-1,-1,-1],[0,0,0],[1,1,1]]
# or Sobel filter:
# D_x = [[-1,0,1],[-2,0,2],[-1,0,1]], D_y = [[-1,-2,-1],[0,0,0],[1,2,1]]

imx = zeros(im.shape)
filters.sobel(im, 1, imx)

imy = zeros(im.shape)
filters.sobel(im, 0, imy)

magnitude = sqrt(imx ** 2 + imy ** 2)
imshow(Image.fromarray(magnitude))
show()

# or Gaussian derivative filter:
# I_{x/y} = I * G_{\sigma, x/y}, G_{\sigma, x/y} = dG_{\sigma}/d(x or y)
sigma = 5
imx = zeros(im.shape)
filters.gaussian_filter(im, (sigma, sigma), (0, 1), imx)
imy = zeros(im.shape)
filters.gaussian_filter(im, (sigma, sigma), (1, 0), imy)

# other SciPy modules
# ---------------------------------------------------------

# 1. reading/writing .mat
# import scipy.io
# data_i = scipy.io.loadmat("test.mat")
# data_o = {}
# data_o["x"] = x
# scipy.io.savemat("test.mat", data_o)

# 2. saving array as images

im = scipy.misc.face()
imsave("./test_out/test_lena.jpg", im)
