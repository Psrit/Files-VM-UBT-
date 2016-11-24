from ImPreprocessing import gaussian_blur

import os
from PIL import Image
from scipy import *
from scipy.ndimage import filters
from pylab import *
import time


def main():
    # blank = [[255 for i in range(10)] for j in range(10)]
    # Image.fromarray(uint8(array(blank))).save("./fig/white.jpg")


    testfile = "./fig/Mercedes.jpg"
    test_out_path = "./test_out/"
    if os.path.exists(test_out_path) == False:
        os.makedirs(test_out_path)

    im = array(Image.open(testfile).convert("L"), "f")
    Image.fromarray(uint8(im)).save(
        test_out_path + os.path.splitext(os.path.split(testfile)[1])[0] + "_grayscale.jpg")

    t_start = time.time()
    im_blurred = gaussian_blur(im, 10)
    # im_blurred = filters.gaussian_filter(im, 10)
    t_finish = time.time()

    print "Gaussian blurring has cost ", t_finish - t_start, " seconds"
    imshow(Image.fromarray(uint8(im_blurred)))
    show()
    Image.fromarray(uint8(im_blurred)).save(
        test_out_path + os.path.splitext(os.path.split(testfile)[1])[0] + "_out10.jpg")


if __name__ == "__main__":
    import cProfile

    cProfile.run("main()", sort="time")
