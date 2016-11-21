#encoding=utf-8

from __future__ import division
import numpy as np
# "cimport" is used to import special compile-time information
# about the numpy module (this is stored in a file numpy.pxd which is
# currently part of the Cython distribution).
cimport numpy as np

# We now need to fix a datatype for our arrays. I've used the variable
# DTYPE for this, which is assigned to the usual NumPy runtime
# type int object.
DTYPE = np.int
# "ctypedef" assigns a corresponding compile-time type to DTYPE_t. For
# every type in the numpy module there's a corresponding compile-time
# type with a _t-suffix.
ctypedef np.int_t DTYPE_t
# "def" can type its arguments but not have a return type. The type of the
# arguments for a "def" function is checked at run-time when entering the
# function.
#
# The arrays f, g and h is typed as "np.ndarray" instances. The only effect
# this has is to a) insert checks that the function arguments really are
# NumPy arrays, and b) make some attribute access like f.shape[0] much
# more efficient. (In this example this doesn't matter though.)
#
# To speed up indexing, we can use "Buffer" syntax, which must be told
# the datatype (first argument) and number of dimensions (“ndim” keyword-only
# argument, if not provided then one-dimensional is assumed).
def naive_convolve(np.ndarray[DTYPE_t, ndim=2] input, np.ndarray[DTYPE_t, ndim=2] kernel):
    """
    2D discrete convolution of an image with a filter kernel
    :param input: an image indexed by (in_row, in_col)
    :param kernel: a filter kernel.
        It needs odd dimensions.
    :return: the output image indexed by (out_row, out_col)

    """
    if kernel.shape[0] % 2 != 1 or kernel.shape[1] % 2 != 1:
        raise ValueError("Only odd dimensions on filter supported")
    assert input.dtype == DTYPE and kernel.dtype == DTYPE

    # The "cdef" keyword is also used within functions to type variables. It
    # can only be used at the top indentation level (there are non-trivial
    # problems with allowing them in other places, though we'd love to see
    # good and thought out proposals for it).
    #
    # For the indices, the "int" type is used. This corresponds to a C int,
    # other C types (like "unsigned int") could have been used instead.
    # Purists could use "Py_ssize_t" which is the proper Python type for
    # array indices.
    cdef int in_row_max = input.shape[0]
    cdef int in_col_max = input.shape[1]
    cdef int ker_row_max = kernel.shape[0]
    cdef int ker_col_max = kernel.shape[1]
    cdef int ker_row_mid = ker_row_max // 2
    cdef int ker_col_mid = ker_col_max // 2
    cdef int out_row_max = in_row_max + 2 * ker_row_mid
    cdef int out_col_max = in_col_max + 2 * ker_col_mid

    cdef np.ndarray output = np.zeros([out_row_max, out_col_max], dtype=input.dtype)

    cdef int out_row, out_col, s, t, in_row, in_col

    # It is very important to type ALL your variables. You do not get any
    # warnings if not, only much slower code (they are implicitly typed as
    # Python objects).
    cdef int s_from, s_to, t_from, t_to

    # For the value variable, we want to use the same data type as is
    # stored in the array, so we use "DTYPE_t" as defined above.
    # NB! An important side-effect of this is that if "value" overflows its
    # datatype size, it will simply wrap around like in C, rather than raise
    # an error like in Python.
    cdef DTYPE_t value

    for out_row in range(out_row_max):
        for out_col in range(out_col_max):
            value = 0
            s_from = max(-ker_row_mid, ker_row_mid - out_row)
            s_to = min(ker_row_mid, (out_row_max - 1) - out_row - ker_row_mid) + 1
            t_from = max(-ker_col_mid, ker_col_mid - out_col)
            t_to = min(ker_col_mid, (out_col_max - 1) - out_col - ker_col_mid) + 1
            # (s, t) is the coordinate of point on the kernel,
            # where the s-axis points in the direction that index of rows increases
            # and the t-axis points in the direction that index of columns increases
            # the origin is at the center of the (reflected) kernel
            for s in range(s_from, s_to):
                for t in range(t_from, t_to):
                    in_row = out_row - ker_row_mid + s
                    in_col = out_col - ker_col_mid + t
                    value += input[in_row, in_col] \
                             * kernel[ker_row_mid - s, ker_col_mid - t]
            output[out_row, out_col] = value

    return output
