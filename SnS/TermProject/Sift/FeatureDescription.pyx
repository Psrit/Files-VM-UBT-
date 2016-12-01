# cython: profile=True

cimport cython
from cpython.object cimport Py_LT, Py_LE, Py_EQ, Py_NE, Py_GT, Py_GE
from ImagePreprocessing cimport DTYPE_t
from ImagePreprocessing import DTYPE

cdef class Location:
    """
    The class storing the location of the keypoint.

    (octave, scale, row, col) info are included; all elements are int.
    row and col are values relative to the blurred image.

    """
    # moved to .pxd
    # cdef:
    #     int octave, scale, row, col

    def __init__(self, o, s, r, c):
        self.octave = o
        self.scale = s
        self.row = r
        self.col = c
        # print "Location initialized: ", self.octave, self.scale, self.row, self.col

    def __str__(self):
        return "(oct={0.octave}, sca={0.scale}, row={0.row}, " \
               "col={0.col})".format(self)

    def __richcmp__(self, other, int op):
        if op == Py_EQ:
            return self.octave == other.octave and \
                   self.scale == other.scale and \
                   self.row == other.row and \
                   self.col == other.col

    def __hash__(self):
        return hash(id(self))

cdef class PointFeature:
    """
    The class describing the feature of the keypoint.

    Main features are:

    ** location: Location
        (octave, scale, row, col) info; all elements are int.
        `row` and `col` are values relative to the blurred image.
        See class `Location`.
    ** coord: tuple
        Row-col coordinate of the exact keypoint in the ORIGINAL image.
        This means:
            coord[0] = (row + row_offset) * 2 ** octave
            coord[1] = (col + col_offset) * 2 ** octave
    ** exact_scale: double
        The precise scale of the point, which is the scale number of it
        in the octave (int) plus the scale offset.
    ** ori: double
        Orientation of keypoint

    """
    # moved to .pxd
    # cdef:
    #     Location location
    #     tuple coord
    #     double exact_scale
    #     double ori
    #     double[::1] descriptor

    def __init__(self, Location loc, tuple coord, double exact_scale):
        self.location = loc
        self.coord = coord
        self.exact_scale = exact_scale

    def __str__(self):
        return "Location: " + str(self.location) + " " + \
               "Coordinate: " + str(self.coord) + \
               "Scale: " + str(self.exact_scale)  # + \
               # "Orientation: " + str(self.ori) + \
               # "Descriptor: " + str(self.descriptor)

    def __richcmp__(self, other, int op):
        if op == Py_EQ:
            return self.location == other.location and \
                   self.coord == other.coord and \
                   self.exact_scale == other.exact_scale

    def __hash__(self):
        return hash(id(self))
