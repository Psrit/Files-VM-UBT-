# cython: profile=True
# cython: boundscheck=False
# cython: wraparound=False

cimport cython
cimport numpy as np
import numpy as np
from ImagePreprocessing import DTYPE

cdef class MathError(Exception):
    pass

cdef class NonSquareError(MathError):
    pass

cdef class NonInvertibleError(MathError):
    pass

cpdef DTYPE_t det(DTYPE_t[:, ::1] m) except *:
    """ Only 2x2 and 3x3 square matrices are supported. """
    cdef int dim = m.shape[0]

    if m.shape[0] != m.shape[1]:
        raise NonSquareError("Only square matrices allowed.")

    if dim == 3:
        return -m[0, 2] * m[1, 1] * m[2, 0] + \
               m[0, 1] * m[1, 2] * m[2, 0] + \
               m[0, 2] * m[1, 0] * m[2, 1] - \
               m[0, 0] * m[1, 2] * m[2, 1] - \
               m[0, 1] * m[1, 0] * m[2, 2] + \
               m[0, 0] * m[1, 1] * m[2, 2]
    elif dim == 2:
        return -m[0, 1] * m[1, 0] + m[0, 0] * m[1, 1]

cpdef DTYPE_t[:, ::1] inv(DTYPE_t[:, ::1] m) except *:
    """ Only 2x2 and 3x3 square matrices are supported. """
    cdef:
        int dim = m.shape[0]
        DTYPE_t[:, ::1] inv_of_m
        DTYPE_t det_of_m = det(m)

    if m.shape[0] != m.shape[1]:
        raise NonSquareError("Only square matrices allowed.")
    if det_of_m == 0:
        raise NonInvertibleError("Only invertible matrices allowed.")

    if dim == 3:
        inv_of_m = np.array(
            [[-m[1, 2] * m[2, 1] + m[1, 1] * m[2, 2],
              m[0, 2]*m[2, 1] - m[0, 1]*m[2, 2],
              -m[0, 2] * m[1, 1] + m[0, 1] * m[1, 2]],
            [m[1, 2] * m[2, 0] - m[1, 0] * m[2, 2],
             -m[0, 2] * m[2, 0] + m[0, 0] * m[2, 2],
             m[0, 2] * m[1, 0] - m[0, 0] * m[1, 2]],
            [-m[1, 1] * m[2, 0] + m[1, 0] * m[2, 1],
             m[0, 1] * m[2, 0] - m[0, 0]*m[2, 1],
             -m[0, 1] * m[1, 0] + m[0, 0] * m[1, 1]]],
            dtype=DTYPE
        ) / det_of_m

    elif dim == 2:
        inv_of_m = np.array(
            [[m[1, 1], -m[0, 1]],
             [-m[1, 0], m[0, 0]]]) / det_of_m

    return inv_of_m


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


cdef double simple_parabola_interp(double l, double c, double r):
    """
    Simply calculate the location where the max/min value lies using
    three values of the quadratic function f(x) at x=-1, 0, 1.

    If l+r=2c, f(x) mustn't be a quadratic function. So simply raise
    a ZeroDivisionError.

    :param l: f(-1)
    :param c: f(0)
    :param r: f(1)
    :return: xm which makes f(xm) become the max/min.

    """

    return 0.5 * (-l + r)/(2 * c - (l + r))