# cython: profile=True
# import math
import numpy

def gaussian_blur(input, double sigma=1.6, int size=-1):
    """
    Gaussian blurring using 2-dimensional square Gaussian kernel.

    :param input: Image or ndarray
        Input image.
    :param sigma: scalar (sequence of scalars are not supported yet)
        Standard deviation for Gaussian kernel. According to Lowe in his
        famous SIFT paper, sigma is set to be 1.6 (default here).
    :param size: scalar (sequence of scalars are not supported yet)
        Size of the Gaussian kernel. If being negative or zero, size will
        be 'around' (6*sigma+1).
        size should be odd. If not, it will be increased by 1.
    :return: ndarray
        Returned array of same shape as 'input'.

    """

    cdef:
        int row, col, index, imrows, imcols

    input = numpy.asanyarray(input)

    if size <= 0:
        size = <int>numpy.ceil(6 * sigma + 1)
    if size % 2 == 0:
        size += 1
    gaussian_array1d = numpy.arange(-(size - 1) / 2, (size - 1) / 2 + 1)
    gaussian_array1d = numpy.exp(-(gaussian_array1d ** 2) / (2 * (sigma ** 2))) / \
                       (numpy.sqrt(2 * numpy.pi) * sigma)
    gaussian_array1d /= sum(gaussian_array1d)

    im_conv = numpy.zeros(input.shape)
    im_blurred = numpy.zeros(input.shape)
    imrows, imcols = input.shape
    print "image size: ", input.shape

    for row in range(0, imrows):
        for col in range(0, imcols):
            for index in range(max(-(size - 1) / 2 + col, 0),
                               min((size - 1) / 2 + col + 1, imcols)):
                im_conv[row, col] \
                    += input[row, index] * gaussian_array1d[index - col + (size - 1) / 2]
    for row in range(0, imrows):
        for col in range(0, imcols):
            for index in range(max(-(size - 1) / 2 + row, 0),
                               min((size - 1) / 2 + row + 1, imrows)):
                im_blurred[row, col] \
                    += im_conv[index, col] * gaussian_array1d[index - row + (size - 1) / 2]

    return im_blurred
