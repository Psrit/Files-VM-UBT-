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
        public double ori
        public double[::1] descriptor