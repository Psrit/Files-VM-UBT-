# cython: profile=True

cimport cython
import numpy as np
from cpython.object cimport Py_LT, Py_LE, Py_EQ, Py_NE, Py_GT, Py_GE
from ImagePreprocessing cimport DTYPE_t
from ImagePreprocessing import DTYPE
from DOGSpaceGenerator cimport GaussianPyramid
from Math cimport simple_parabola_interp
# from Defaults import *  # error???
from Defaults import ORI_HIST_BINS, ORI_HIST_SEARCH_RADIUS, \
    ORI_HIST_SEARCH_SIGMA_FCTR, DESCR_MAG_THR, ORI_PEAK_RATIO


# TODO: TO BE COMPLETED


cdef list calc_keypoints_ori(GaussianPyramid pyramid, list feature_list):
    """
    Calculate the main orientation of the keypoint.

    :param feature_list
    :return: new_list

    """
    cdef:
        int i, li, ri
        int o, s, r, c, n, nbins = ORI_HIST_BINS
        double mag_max, mag_thr, max_bin

        PointFeature feature, temp_feature
        Location loc
        tuple coord
        double exact_scale
        double sigma_oct

        double pi2 = 2 * np.pi
        DTYPE_t[::1] hist
        list new_list = []

    for i in range(0, len(feature_list)):
        feature = feature_list[i]

        o = feature.location.octave
        s = feature.location.scale
        r = feature.location.row
        c = feature.location.col
        loc = feature.location
        coord = feature.coord
        exact_scale = feature.exact_sca
        sigma_oct = feature.sigma_oct

        hist = calc_keypoint_ori_hist(GaussianPyramid.octaves[o].scales[s],
                    r, c, round(ORI_HIST_SEARCH_RADIUS * sigma_oct),
                    ORI_HIST_SEARCH_SIGMA_FCTR * sigma_oct)
        mag_max = max(hist)
        mag_thr = mag_max * ORI_PEAK_RATIO

        for n in range(0, ORI_HIST_BINS):
            li = n - 1 if n != 0 else nbins - 1
            ri = (n + 1) % nbins
            if hist[n] > hist[li] and hist[n] > hist[ri] and hist[n] > mag_thr:
                max_bin = n + simple_parabola_interp(hist[li], hist[n], hist[ri])
                if max_bin < 0:
                    max_bin += nbins
                elif max_bin >= nbins:
                    max_bin -= nbins

                temp_feature = PointFeature(loc, coord, exact_scale, sigma_oct)
                temp_feature.ori = max_bin * pi2 / nbins  # - np.pi ?

                new_list.append(temp_feature)

    return new_list


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
        double weight, mag, ori
        # the denominator in the exp of the gaussian function
        DTYPE_t exp_denom = 2.0 * sigma * sigma
        DTYPE_t[::1] hist = np.zeros([1, bins], dtype=DTYPE)

    for dr in range(-radius, radius + 1):
        for dc in range(-radius, radius + 1):
            calc_gradient(img, r, c, &mag, &ori)
            weight = np.exp(-(dr * dr + dc * dc) / exp_denom)
            n = round(bins * ori / (2 * np.pi))
            if n == bins:
                n = 0
            hist[n] += weight * mag

    return hist



cdef bint calc_gradient(DTYPE_t[:, ::1] img, int r, int c,
                        double* mag, double* ori):
    """
    Calculate the gradient at a certain point.

    :param img: the image where the keypoint lies
        Same as the `img` in `calc_keypoint_ori_hist`, here `img` is also in
        the Gaussian pyramid.
    :param r: row number of the keypoint
    :param c: column number of the keypoint
    :param mag: the pointer of the double which stores the magnitude value
    :param ori: the pointer of the double which stores the orientation value

    :return: True of False
        If the given `r`, `c` are invalid, return False; otherwise return True.

    """
    cdef:
        list grad
        DTYPE_t grad_x
        DTYPE_t grad_y
    if 0 < r < img.shape[0] - 1 and 0 < c < img.shape[1] - 1:
        grad_x = img[r, c + 1] - img[r, c - 1]
        grad_y = img[r + 1, c] - img[r - 1, c]

        mag[0] = (grad_x ** 2 + grad_y ** 2) ** 0.5
        ori[0] = np.arctan2(grad_y, grad_x)
        if ori[0] < 0:
            ori[0] += 2 * np.pi

        return True
    # If the given `r`, `c` are invalid, return False:
    else:
        return False



cdef DTYPE_t[:, :, ::1] calc_keypoint_decr_hist(DTYPE_t[:, ::1] img, int r,
        int c, DTYPE_t main_ori, DTYPE_t sigma_oct, int nareas=4, int nbins=8):
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
        int dr, dc
        double r_area, c_area, n_bin
        DTYPE_t[:, :, ::1] hist = np.zeros([nareas, nareas, nbins], dtype=DTYPE)
        double cos_t = np.cos(main_ori), sin_t = np.sin(main_ori)
        double area_width = sigma_oct * 3  # according to the paper
        int radius = int(area_width * (2 ** 0.5) * (nbins + 1.0) * 0.5 + 0.5)
        double mag, ori, grad_ori, weight
        double pi2 = 2 * np.pi
        double bins_per_rad = nbins / pi2
        double exp_denom = (nareas ** 2) * 0.5

    for dr in range(-radius, radius + 1):
        for dc in range(-radius, radius + 1):
            c_rot = cos_t * c - sin_t * r
            r_rot = sin_t * c + cos_t * r
            c_area = c_rot / area_width + nareas / 2 - 0.5
            r_area = r_rot / area_width + nareas / 2 - 0.5

            # If the rotated point is still in the 'oblique' inscribed square
            # of the circle whose radius is `radius`:
            if -1.0 < r_area < nareas and -1.0 < c_area < nareas:
                if calc_gradient(img, r + dr, c + dc, &mag, &ori):
                    grad_ori -= ori
                    while grad_ori < 0.0:
                        grad_ori += pi2
                    while grad_ori >= pi2:
                        grad_ori -= pi2
                    n_bin = grad_ori * bins_per_rad
                    weight = np.exp(-(c_rot ** 2 + r_rot ** 2) / exp_denom)
                    interp_hist(hist, r_area, c_area, n_bin, nareas, nbins, mag)
    return hist



cdef interp_hist(DTYPE_t[:, :, ::1] hist, double r_area, double c_area,
                 double n_bin, int nareas, int nbins, double mag):
    cdef:
        int r_i, c_i, n_i
        int r0 = int(r_area), c0 = int(c_area), n0 = int(n_bin)
        double dr = r_area - r0, dc = c_area - c0, dn = n_bin - n0
        double v = mag
        int r, c, n

    for r_i in range(0, 2):
        r = r0 + r_i
        # if `r` is valid:
        if 0 <= r < nareas:
            v *= (1.0 - dr if r_i == 0 else dr)
            for c_i in range(0, 2):
                c = c0 + c_i
                # if `c` is valid:
                if 0 <= c < nareas:
                    v *= (1.0 - dc if c_i == 0 else dc)
                    for n_i in range(0, 2):
                        # `n` is always valid since the bin is 'cyclic' for n:
                        n = (n0 + n_i) % n
                        v *= (1.0 - dn if n_i == 0 else dn)
                        hist[r, c, n] += v



cdef double[::1] calc_descriptor(
        DTYPE_t[:, ::1] img, int r, int c, int main_ori, int sigma_oct,
        int nareas=4, int nbins=8):
    """
    Pass parameters to calc_keypoint_decr_hist to get the descriptor histogram,
    and transform it into the descriptor vector.

    """
    cdef:
        DTYPE_t[:, :, ::1] hist = \
            calc_keypoint_decr_hist(img, r, c, main_ori, sigma_oct, nareas, nbins)
        int ri, ci, ni, i, length, int_value
        double norm2 = 0, value
        # list desc = []
        double[::1] descriptor = np.array([])

    for ri in range(0, nareas):
        for ci in range(0, nareas):
            for ni in range(0, nbins):
                value = hist[ri, ci, ni]
                descriptor = np.append(descriptor, value)
                norm2 += value ** 2
    length = len(descriptor)

    normalize(&descriptor[0], length, norm2)

    for i in range(0, length):
        if descriptor[i] > DESCR_MAG_THR:
            descriptor[i] = DESCR_MAG_THR

    normalize(&descriptor[0], length)

    for i in range(0, length):
        int_value = int(DESCR_MAG_THR * descriptor[i])
        descriptor[i] = min(255, int_value)

    return descriptor



cdef normalize(double* vector, int length, double norm2=-1):
    cdef:
        int i = 0

    if norm2 <= 0:
        norm2 = 0
        for i in range(0, length):
            norm2 += vector[i] ** 2

    for i in range(0, length):
        vector[i] /= (norm2 ** 0.5)



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
