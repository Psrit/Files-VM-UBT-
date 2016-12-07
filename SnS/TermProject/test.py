# import pyximport; pyximport.install()

import os
from PIL import Image
from scipy import *
from pylab import *
from Sift.DOGSpaceGenerator import GaussianPyramid
from Sift.Math import *


def main():
    # blank = [[255 for i in range(10)] for j in range(10)]
    # Image.fromarray(uint8(array(blank))).save("./fig/white.jpg")

    # GET TEST IMAGE
    # -----------------------------------------------------
    # -----------------------------------------------------
    testfile = "./Sift/fig/Mercedes.jpg"
    test_out_path = "./Sift/test_out/"
    if os.path.exists(test_out_path) == False:
        os.makedirs(test_out_path)

    im = array(Image.open(testfile).convert("L"), "f")
    im = im / 255
    # Image.fromarray(uint8(im)).save(
    #     test_out_path + os.path.splitext(os.path.split(testfile)[1])[0] + "_grayscale.jpg")


    # # GAUSSIAN BLURRING TEST
    # # -----------------------------------------------------
    # # -----------------------------------------------------
    # t_start = time.time()
    # im_blurred = array(gaussian_blur(im, 10))
    # # im_blurred = filters.gaussian_filter(im, 1)
    # t_finish = time.time()
    #
    # print("Gaussian blurring has cost " + str(t_finish - t_start) + " seconds")
    # imshow(Image.fromarray(uint8(im_blurred)))
    # Image.fromarray(uint8(im_blurred)).save(
    #     test_out_path + os.path.splitext(os.path.split(testfile)[1])[0] + "_out10.jpg")
    # # imsave(test_out_path + os.path.splitext(os.path.split(testfile)[1])[0] + "_out10.jpg", uint8(im_blurred))

    # # DECIMATION TEST
    # # -----------------------------------------------------
    # # -----------------------------------------------------
    # im_dsam = array(decimation(im, interval=10))
    # imshow(Image.fromarray(uint8(im_dsam)))
    # Image.fromarray(uint8(im_dsam)).save(
    #     test_out_path + os.path.splitext(os.path.split(testfile)[1])[0] + "_dsam.jpg")
    # # imsave(test_out_path + os.path.splitext(os.path.split(testfile)[1])[0] + "_out10.jpg", uint8(im_blurred))
    # # show()

    # GAUSSIAN Pyramid TEST
    p = GaussianPyramid(im, 4, 4)  # , predesample=True, predesample_intvl=2)
    print p.find_features()
    # o = 0
    # s = 0
    # for octave in p.octaves:
    #     for scale in octave.diff_scales:
    #         # print np.array(scale).max(), np.array(scale).min()
    #         Image.fromarray(uint8(np.array(scale) * 255)).save(
    #             test_out_path + "pyramid_test" + os.sep +
    #             os.path.splitext(os.path.split(testfile)[1])[0] +
    #             "_o" + str(o) + "_s" + str(s) + ".jpg"
    #         )
    #         s += 1
    #     o += 1
    #     s = 0
    # print("test result: ", p.find_keypoints())

    # print det3(np.array([[1.0,0.0,0.0],[0.0,1.0,0.0],[0.0,0.0,1.0]]))



if __name__ == "__main__":
    import cProfile

    cProfile.run("main()", sort="time")
