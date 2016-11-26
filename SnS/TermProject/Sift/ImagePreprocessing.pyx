# cython: profile=False
cimport cython
import numpy as np
cimport numpy as np

DTYPE = np.float32
ctypedef np.float32_t DTYPE_t

@cython.boundscheck(False)
@cython.wraparound(False)
cpdef gaussian_blur(DTYPE_t[:, ::1] input, double sigma=1.6, int size=-1):
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
        int row, col, index
        # NOTE: imrows, imcols = input.shape is WRONG
        int imrows = input.shape[0]
        int imcols = input.shape[1]
        DTYPE_t[::1] gaussian_array1d
        # NOTE: ... = np.zeros(input.shape) is WRONG
        DTYPE_t[:, ::1] im_conv = np.zeros([imrows, imcols], dtype=DTYPE)
        DTYPE_t[:, ::1] im_blurred = np.zeros([imrows, imcols], dtype=DTYPE)

    if size <= 0:
        size = <int>np.ceil(6 * sigma + 1)
    if size % 2 == 0:
        size += 1
    gaussian_array1d = np.arange(-(size - 1) / 2.0, (size - 1) / 2.0 + 1, dtype=DTYPE)
    cdef:
        DTYPE_t sum = 0
    for index in range(0, size):
        gaussian_array1d[index] \
            = np.exp(-gaussian_array1d[index] ** 2 /
                     (2 * (sigma ** 2))) / (np.sqrt(2 * np.pi) * sigma)
        sum += gaussian_array1d[index]
    for index in range(0, size):
        gaussian_array1d[index] /= sum



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
