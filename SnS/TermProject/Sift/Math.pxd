from ImagePreprocessing cimport DTYPE_t

cdef DTYPE_t det(DTYPE_t[:, ::1] m) except *

cdef DTYPE_t[:, ::1] inv(DTYPE_t[:, ::1] m) except *

cdef double simple_parabola_interp(double l, double c, double r)
# Not much faster than np.
# cdef DTYPE_t[:, :] transpose(DTYPE_t[:, ::1] m)