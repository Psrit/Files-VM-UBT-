from ImagePreprocessing cimport gaussian_blur, decimation, DTYPE_t, SIGMA
# from ImagePreprocessing import DTYPE

cdef class GaussianOctave:
    cdef:
        DTYPE_t[:, :, ::1] scales
        readonly DTYPE_t[:, :, ::1] diff_scales
        int nsca, nrows, ncols
        DTYPE_t sigma

    cdef tuple _find_exact_extremum(self, int s, int r, int c, int niter=*)
    cdef bint _is_low_contrast_or_unstable(self, int s, int r, int c,
                DTYPE_t v, DTYPE_t contrast_threshold=*, DTYPE_t stability_threshold=*)
    cpdef list find_keypoints_in_octave(self)

cdef class GaussianPyramid:
    cdef:
        readonly list octaves
        int noct
    cpdef list find_keypoints(self)