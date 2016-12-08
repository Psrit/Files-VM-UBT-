# import pyximport; pyximport.install()

import os
from PIL import Image
from scipy import *
from pylab import *
from Sift.ImagePreprocessing import decimation
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
    filename = os.path.splitext(os.path.split(testfile)[1])[0]
    if os.path.exists(test_out_path) == False:
        os.makedirs(test_out_path)

    im = array(Image.open(testfile).convert("L"), "f")
    im_normalized = im / 255
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


    # # GAUSSIAN PYRAMID TEST
    # # -----------------------------------------------------
    # # -----------------------------------------------------
    # p = GaussianPyramid(im, 4, 4, predesample=False)  # , predesample=True, predesample_intvl=2)
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


    # SIFT TEST
    p = GaussianPyramid(im_normalized)  # , predesample=True, predesample_intvl=2)
    # for feature in p.features:
    #     print str(feature)
    # p.save_feature_txt(filename=os.path.splitext(os.path.split(testfile)[1])[0])

    locs = np.array([(feature.coord[0], feature.coord[1], feature.sigma_abs, feature.ori)
                     for feature in p.features])

    def plot_features(im, locs, circle=False, predesampled=False, predesample_intvl=2):
        def draw_circle(row, col, radius):
            t = arange(0, 1.01, .01) * 2 * pi

            x = radius * cos(t) + col
            y = radius * sin(t) + row
            plot(x, y, 'b', linewidth=2)

        if predesampled:
            im = decimation(im, predesample_intvl)
        # FIXME: ???
        # im = uint8(im)
        imshow(im)

        if circle:
            for loc in locs:
                if loc[0] >= im.shape[0] or loc[1] >= im.shape[1]:
                    print "OUT!"
                else:
                    draw_circle(*loc[0:3])
        else:
            plot(locs[:, 1], locs[:, 0], 'ob')
        axis('off')

    plot_features(im, locs)

    show()

    # TODO: TO BE COMPLETED
    # def save_features_fig(testfile, locs, circle=False, predesampled=False, predesample_intvl=2):
    #     imfig = array(Image.open(testfile))
    #
    #     def draw_circle(row, col, radius):
    #         t = arange(0, 1.01, .01) * 2 * pi
    #
    #         x = radius * cos(t) + col
    #         y = radius * sin(t) + row
    #         plot(x, y, 'b', linewidth=2)
    #
    #     if circle:
    #         for loc in locs:
    #             if loc[0] >= im.shape[0] or loc[1] >= im.shape[1]:
    #                 print "OUT!"
    #             else:
    #                 draw_circle(*loc[0:3])
    #     else:
    #         plot(locs[:, 1], locs[:, 0], 'ob')
    #
    #     figure(figsize=(8, 6))
    #     xlim(0, imfig.shape[1])
    #     ylim(0, imfig.shape[0])
    #     axis('off')
    #
    #     savefig("temp_features.jpg")
    #
    #     imfeatures = array(Image.open("temp_features.jpg"))
    #     im_out = imfeatures + imfig
    #
    #     Image.fromarray(uint8(im)).save(test_out_path + filename + "_features.jpg")
    #
    # save_features_fig(testfile, locs)


if __name__ == "__main__":
    import cProfile

    cProfile.run("main()", sort="time")
