# cython: profile=True
cimport numpy as np
cimport cython
import numpy as np
from ImagePreprocessing import DTYPE


cdef DTYPE_t det(DTYPE_t[:, ::1] m, int dim):
    """ Only 2x2 and 3x3 square matrices are supported. """
    if dim == 3:
        return -m[0, 2] * m[1, 1] * m[2, 0] + \
               m[0, 1] * m[1, 2] * m[2, 0] + \
               m[0, 2] * m[1, 0] * m[2, 1] - \
               m[0, 0] * m[1, 2] * m[2, 1] - \
               m[0, 1] * m[1, 0] * m[2, 2] + \
               m[0, 0] * m[1, 1] * m[2, 2]
    elif dim == 2:
        return -m[0, 1] * m[1, 0] + m[0, 0] * m[1, 1]


cdef DTYPE_t[:, :] transpose(DTYPE_t[:, ::1] m):
    """
    Calculate the transposed result.

    It seems that this function is not much faster than numpy's transpose(),
    so don't use this one. :(

    """
    cdef:
        int nrows = m.shape[0]
        int ncols = m.shape[1]
        DTYPE_t[:, :] t = np.zeros([ncols, nrows], dtype=DTYPE)
        int r, c
    for r in range(0, nrows):
        for c in range(0, ncols):
            t[c, r] = m[r, c]
    return t
