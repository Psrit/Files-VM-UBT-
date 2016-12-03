cimport numpy as np
ctypedef np.float32_t DTYPE_t

cpdef DTYPE_t[:, ::1] gaussian_blur(DTYPE_t[:, ::1] input, DTYPE_t sigma=*, int size=*)
cpdef DTYPE_t[:, ::1] decimation(DTYPE_t[:, ::1] input, int interval=*)