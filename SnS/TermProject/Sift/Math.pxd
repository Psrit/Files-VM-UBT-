from ImagePreprocessing cimport DTYPE_t

cdef DTYPE_t det(DTYPE_t[:, ::1] m, int dim)

# Not much faster than np.
# cdef DTYPE_t[:, :] transpose(DTYPE_t[:, ::1] m)