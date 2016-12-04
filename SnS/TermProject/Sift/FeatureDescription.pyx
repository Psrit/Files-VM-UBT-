# cython: profile=True

cimport cython
import numpy as np
from cpython.object cimport Py_LT, Py_LE, Py_EQ, Py_NE, Py_GT, Py_GE
from ImagePreprocessing cimport DTYPE_t
from ImagePreprocessing import DTYPE
from Defaults import ORI_HIST_BINS

# TODO: TO BE COMPLETED
cdef calc_keypoint_ori(PointFeature feature):
    """
    Calculate the main orientation of the keypoint.

    :param feature:
    :return:

    """
    pass

cdef DTYPE_t[::1] calc_keypoint_ori_hist(DTYPE_t[:, ::1] img, int r, int c,
                            int radius, DTYPE_t sigma, int bins=ORI_HIST_BINS):
    """
    Calculate the orientation histogram of a certain keypoint.

    :param img: the image where the keypoint lies
        The image is in the Gaussian pyramid (`scales` of the GaussianOctave),
        instead of the DoG pyramid (`diff_scales`), although `loc` is got from
        the DoG pyramid.
    :param r: the row number of the keypoint
    :param c: the column number of the keypoint
        Here we simply use `r`, `c` as the location of the keypoint in the
        Gaussian pyramid.
    :param radius: radius of the searching area
    :param sigma: the weight of Gaussian function used in summing up all nearby
        points' gradient
    :param bins: number of bins in the histogram (default: ORI_HIST_BINS=36)

    :return: the orientation histogram of a certain keypoint
        The n-th bin in the histogram represents the sum of maginitudes of the
        gradients whose directions lies in range [(n/bins)*2*pi-hbw, (n/bins)
        *2*pi+hbw), where `hbw` means the half width of the angular range area
        represented by the bin, equalling to pi/bin.

    """
    cdef:
        int dr, dc, n
        DTYPE_t weight, mag, ori
        # the denominator in the exp of the gaussian function
        DTYPE_t exp_denom = 2.0 * sigma * sigma
        DTYPE_t[::1] hist = np.zeros([1, bins], dtype=DTYPE)

    for dr in range(-radius, radius + 1):
        for dc in range(-radius, radius + 1):
            [mag, ori] = calc_gradient(img, r, c)
            weight = np.exp(-(dr * dr + dc * dc) / exp_denom)
            n = round(bins * ori / (2 * np.pi))
            if n == bins:
                n = 0
            hist[n] += weight * mag

    return hist

cdef list calc_gradient(DTYPE_t[:, ::1] img, int r, int c):
    """
    Calculate the gradient at a certain point.

    :param img: the image where the keypoint lies
        Same as the `img` in `calc_keypoint_ori_hist`, here `img` is also in
        the Gaussian pyramid.
    :param r: row number of the keypoint
    :param c: column number of the keypoint

    :return: [magnitude, orientation] of the gradient
        The orientation is given in radian, and in range [0, 2*pi).

    """
    cdef:
        DTYPE_t mag, ori
        list grad
        DTYPE_t grad_x = img[r, c + 1] - img[r, c - 1]
        DTYPE_t grad_y = img[r + 1, c] - img[r - 1, c]

    mag = (grad_x ** 2 + grad_y ** 2) ** 0.5
    ori = np.arctan2(grad_y, grad_x)
    if ori < 0:
        ori += 2 * np.pi

    grad = [mag, ori]
    return grad


cdef DTYPE_t[:, :, ::1] calc_keypoint_decr_hist(DTYPE_t[:, ::1] img, int r,
            int c, DTYPE_t ori, DTYPE_t sigma_oct, int nareas=4, int nbins):
    """
    Calculate the gradient histogram at a keypoint.

    :param img: the image where the keypoint lies
        Same as the `img` in `calc_keypoint_ori_hist`, here `img` is also in
        the Gaussian pyramid.
    :param r: row number of the keypoint
    :param c: column number of the keypoint
    :param ori: the orientation of the keypoint
    :param sigma_oct: the sigma of the keypoint
        The sigma is relative to the octave the point lies in.
    :param nareas: the number of the sampling areas
    :param nbins: the number of the bins in each histogram

    :return: the gradient histogram
        It is a (nareas * nareas * nbins)-dimensional array.

    """
    cdef:
        int dr, dc, rbin, cbin
        double r_area, c_area
        DTYPE[:, :, ::1] hist = np.zeros([nareas, nareas, nbins], dtype=DTYPE)
        double cos_t = np.cos(ori), sin_t = np.sin(ori)
        double area_width = sigma_oct * 3  # according to the paper
        double radius = area_width * (2 ** 0.5) * (nbins + 1.0) * 0.5 + 0.5

    for dr in range(-radius, radius + 1):
        for dc in range(-radius, radius + 1):
            c_rot = cos_t * c - sin_t * r
            r_rot = sin_t * c + cos_t * r
            c_area = c_rot / area_width + nareas / 2 - 0.5
            r_area = r_rot / area_width + nareas / 2 - 0.5

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

    Main fields are:

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
    ** sigma_oct: double
        The sigma of the point in the octave it lies in. Generally, for a
        keypoint whose location is (o, s, r, c) with `sigma` as the basic
        scale of the pyramid, sigma_oct=sigma*(2**(s/nscas)), where nscas
        is the number of the scales in the octave. The value is given by
        the __init__ caller.
    ** ori: double
        Orientation of keypoint.
    ** descriptor: double[::1]
        The descriptor vector of the keypoint.

    """
    # moved to .pxd
    # cdef:
    #     Location location
    #     tuple coord
    #     double exact_scale
    #     double sigma_oct
    #     double ori
    #     double[::1] descriptor

    def __init__(self, Location loc, tuple coord, double exact_scale,
                 double sigma_oct):
        self.location = loc
        self.coord = coord
        self.exact_scale = exact_scale
        self.sigma_oct = sigma_oct

    def __str__(self):
        return "Location: " + str(self.location) + "\t" + \
               "Coordinate: " + str(self.coord) + "\t" + \
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
