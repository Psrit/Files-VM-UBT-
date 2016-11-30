# cython: profile=False
cimport cython
import numpy as np
# cimport numpy as np  # moved to .pxd

DTYPE = np.float32
# ctypedef np.float32_t DTYPE_t  # moved to .pxd
# cdef double SIGMA = 1.6  # moved to .pxd

@cython.boundscheck(False)
@cython.wraparound(False)
cpdef DTYPE_t[:, ::1] gaussian_blur(DTYPE_t[:, ::1] input, DTYPE_t sigma=SIGMA, int size=-1):
    """
    Gaussian blurring using 2-dimensional square Gaussian kernel.

    :param input: ndarray or other 2-dimensional object having the buffer interface
        Input image array.
        Data type of input should be DTYPE (=np.float32,?). `~PIL.Image.Image`
        objects are supposed to be converted to array before sent to this
        function.
    :param sigma: double (sequence of scalars are not supported yet; default=SIGMA)
        Standard deviation for Gaussian kernel.
        According to Lowe in his famous SIFT paper, sigma is set to be SIGMA=1.6
        (default here).
    :param size: integer (sequence of scalars are not supported yet; default=-1)
        Size of the Gaussian kernel.
        If being negative or zero, size will be 'around' (6*sigma+1).
        `size` should be odd. If not, it will be increased by 1.
    :return: memoryview of a 2-D array
        Returned memoryview of the 2-D `DTYPE` array.
        It has the same shape and the same data type (DTYPE) as `input`.
        By type casting (e.g. numpy.array(gaussian_blur(im, sigma))), we can
        get the array form of the output data.

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
        # print(sigma, (2 * (sigma ** 2)), np.sqrt(2 * np.pi) * sigma)
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


@cython.boundscheck(False)
@cython.wraparound(False)
cpdef DTYPE_t[:, ::1] decimation(DTYPE_t[:, ::1] input, int interval=2):
    """
    Downsampling the image by only keeping one pixel per (`interval`)**2 points.

    :param input: ndarray or other 2-dimensional object having the buffer interface
        Input image array.
        Data type of input should be DTYPE (=np.float32,?). `~PIL.Image.Image`
        objects are supposed to be converted to array before sent to this
        function.
    :param interval: integer (>=1; default=2)
        For example, we keep input[0, 0], input[0, 2], input[0, 4],...
        input[2, 0],... when interval == 1.
    :return: memoryview of a 2-D array
        Returned memoryview of the 2-D `DTYPE` array.
        It has the same shape and the same data type (DTYPE) as `input`.

    """
    assert interval >= 1

    cdef:
        int row = 0, col = 0, out_row = 0, out_col = 0
        int in_nrows = input.shape[0]
        int in_ncols = input.shape[1]
        int out_nrows = (in_nrows + interval - 1) // interval
        int out_ncols = (in_ncols + interval - 1) // interval
        DTYPE_t[:, ::1] output = np.zeros([out_nrows, out_ncols], dtype=DTYPE)

    while row < in_nrows:
        while col < in_ncols:
            output[out_row, out_col] = input[row, col]
            col += interval
            out_col += 1
        col = 0
        out_col = 0
        row += interval
        out_row += 1

    return output
