from ImagePreprocessing cimport DTYPE_t
from DOGSpaceGenerator cimport GaussianPyramid
from numpy cimport int_t

cdef list calc_keypoints_ori(GaussianPyramid pyramid, list feature_list)

cdef int_t[::1] calc_descriptor(
        DTYPE_t[:, ::1] img, int r, int c, double main_ori, double sigma_oct,
        int nareas=*, int nbins=*)

cdef class Location:
    cdef:
        # Public to other Cython files and Python.
        # Without the 'public' specifier, other Cython files cannot
        # access to these data fields, either.
        public int octave, scale, row, col

cdef class PointFeature:
    cdef:
        public Location location
        public tuple coord
        public double exact_scale
        public double sigma_oct
        public double ori
        public int_t[::1] descriptor