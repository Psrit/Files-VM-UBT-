from PIL import Image
from pylab import *

testfile = "../fig/pycharm.png"

# # TEST 1
# # ---------------------------------------------------------
#
# # read image into array
# im = array(Image.open(testfile))
#
# # show the image
# imshow(im)
#
# # plot
# x = [100, 100, 400, 400]
# y = [200, 500, 200, 500]
#
# plot(x, y, "r*")  # mark the four points with red stars
# plot(x[:2], y[:2])  # link first two points with a line (default: blue)
#
# title("Plotting: 'pycharm.png'")
# axis("off")
# # show()



# # TEST 2
# # ---------------------------------------------------------
#
# im_greyscale = array(Image.open(testfile).convert("L"))
#
# figure()  # create a new figure
#
# gray()
# contour(im_greyscale, origin="image")
# axis("equal")
# axis("off")
#
# figure()
#
# hist(im_greyscale.flatten(), 128)
# show()


# TEST 3
# ---------------------------------------------------------

im_interact = array(Image.open(testfile))
imshow(im_interact)

print("Please click 3 points")
x = ginput(3)
print "you clicked: ", x

show()
