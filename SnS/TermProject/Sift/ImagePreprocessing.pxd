cimport numpy as np
ctypedef np.float32_t DTYPE_t
cdef double SIGMA = 1.6

cpdef DTYPE_t[:, ::1] gaussian_blur(DTYPE_t[:, ::1] input, double sigma=*, int size=*)
cpdef DTYPE_t[:, ::1] decimation(DTYPE_t[:, ::1] input, int interval=*)