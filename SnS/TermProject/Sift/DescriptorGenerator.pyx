from ImagePreprocessing cimport gaussian_blur, DTYPE_t
from ImagePreprocessing import DTYPE
import numpy as np
cimport cython

@cython.boundscheck(False)
@cython.wraparound(False)
cdef decimation(DTYPE_t[:, ::1] input, int interval=2):
    """
    Downsampling the image by only keeping one pixel per (`interval`)**2 points.

    :param input: ndarray or other 2-dimensional object having the buffer interface
        Input image array.
        Data type of input should be DTYPE (=np.float32,?). `~PIL.Image.Image`
        objects are supposed to be converted to array before sent to this
        function.
    :param interval: integer (>=0; default=2)
        For example, we keep input[0, 0], input[0, 2], input[0, 4],...
        input[2, 0],... when interval == 1.
    :return: memoryview of a 2-D array
        Returned memoryview of the 2-D `DTYPE` array.
        It has the same shape and the same data type (DTYPE) as `input`.

    """

    cdef:
        int row, col, out_row = 0, out_col = 0
        int in_nrows = input.shape[0]
        int in_ncols = input.shape[1]
        int out_nrows = (in_nrows + interval - 1) // interval
        int out_ncols = (in_ncols + interval - 1) // interval
        DTYPE_t[:, ::1] output = np.zeros([out_nrows, out_ncols], dtype=DTYPE)

    for row in range(0, in_nrows):
        for col in range(0, in_ncols):
            output[out_row, out_col] = input[row, col]
            row += interval
            out_row += 1
        col += interval
        out_col += 1

    return output

cdef pyramid_generator():
    pass
