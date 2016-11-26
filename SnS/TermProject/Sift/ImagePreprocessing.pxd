cimport numpy as np
ctypedef np.float32_t DTYPE_t

cpdef gaussian_blur(DTYPE_t[:, ::1] input, double sigma=*, int size=*)