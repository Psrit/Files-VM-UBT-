# cython: profile=True
# cython: boundscheck=False
# cython: wraparound=False

cimport cython
import numpy as np
from cpython.object cimport Py_LT, Py_LE, Py_EQ, Py_NE, Py_GT, Py_GE
from ImagePreprocessing cimport DTYPE_t
from ImagePreprocessing import DTYPE
from DOGSpaceGenerator cimport GaussianPyramid, GaussianOctave
from Math cimport simple_parabola_interp
# from Defaults import *  # error???
from Defaults import ORI_HIST_BINS, ORI_HIST_SEARCH_RADIUS, \
    ORI_HIST_SEARCH_SIGMA_FCTR, DESCR_MAG_THR, ORI_PEAK_RATIO, \
    DESCR_HIST_AREAS, DESCR_HIST_BINS, DESCR_TO_INT_FCTR, \
    ORI_HIST_SMOOTH_STEPS



cdef list calc_keypoints_ori(GaussianPyramid pyramid, list feature_list):
    """
    Calculate the main orientation of the keypoint.

    :param pyramid" GaussianPyramid
        It is the GaussianPyramid where the keypoints come from.
    :param feature_list: list
        It is the input list of keypoint features whose orientations are not
        calculated.

    :return: new_list: list
        A new list of the keypoint features whose orientations are calculated.
        A single keypoint may have several copies in the list with different
        main orientations because those directions in which the value of the
        histogram reaches ORI_PEAK_RATIO times the maximum value are all
        counted in.

    """
    cdef:
        int i, li, ri, smooth_i
        int o, s, r, c, n, nbins = ORI_HIST_BINS
        double mag_max, mag_thr, max_bin

        PointFeature feature, temp_feature
        Location loc
        tuple coord
        double exact_scale
        double sigma_oct, sigma_abs

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
        exact_scale = feature.exact_scale
        sigma_oct = feature.sigma_oct
        sigma_abs = feature.sigma_abs

        hist = calc_keypoint_ori_hist(pyramid.octaves[o].scales[s],
                    r, c, round(ORI_HIST_SEARCH_RADIUS * sigma_oct),
                    ORI_HIST_SEARCH_SIGMA_FCTR * sigma_oct)
        for smooth_i in range(0, ORI_HIST_SMOOTH_STEPS):
            smooth_hist(hist, ORI_HIST_BINS)

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
                # now 0 <= max_bin < nbins

                temp_feature = PointFeature(loc, coord,
                                            exact_scale, sigma_oct, sigma_abs)
                temp_feature.ori = max_bin * pi2 / nbins  # - np.pi ?

                new_list.append(temp_feature)

    return new_list



cdef DTYPE_t[::1] calc_keypoint_ori_hist(DTYPE_t[:, ::1] img, int r, int c,
                            int radius, DTYPE_t sigma, int bins=ORI_HIST_BINS):
    """
    Calculate the orientation histogram of a certain keypoint.

    :param img: DTYPE_t[::1]
        # the image where the keypoint lies #
        The image is in the Gaussian pyramid (`scales` of the GaussianOctave),
        instead of the DoG pyramid (`diff_scales`), although `loc` is got from
        the DoG pyramid.
    :param r: int
        # the row number of the keypoint #
    :param c: int
        # the column number of the keypoint #
        Here we simply use `r`, `c` as the location of the keypoint in the
        Gaussian pyramid.
    :param radius: int
        # radius of the searching area #
    :param sigma: DTYPE_t
        # the weight of Gaussian function used in summing up all nearby
        points' gradient #
    :param bins: int
        # number of bins in the histogram (default: ORI_HIST_BINS=36) #

    :return: DTYPE_t[::1]
        # the orientation histogram of a certain keypoint #
        The n-th bin in the histogram represents the sum of maginitudes of the
        gradients whose directions lie in range [(n/bins)*2*pi-hbw, (n/bins)
        *2*pi+hbw), where `hbw` means the half width of the angular range area
        represented by the bin, equalling to pi/bin.

    """
    cdef:
        int dr, dc, n
        double weight, mag, ori
        # the denominator in the exp of the gaussian function
        DTYPE_t exp_denom = 2.0 * sigma * sigma
        DTYPE_t[::1] hist = np.zeros(bins, dtype=DTYPE)

    for dr in range(-radius, radius + 1):
        for dc in range(-radius, radius + 1):
            calc_gradient(img, r + dr, c + dc, &mag, &ori)
            weight = np.exp(-(dr * dr + dc * dc) / exp_denom)
            n = round(bins * ori / (2 * np.pi))
            if n == bins:
                n = 0
            hist[n] += weight * mag

    return hist



cdef smooth_hist(DTYPE_t[::1] hist, int nbins):
    cdef:
        int i
        double prev = hist[nbins - 1], temp, h0 = hist[0]

    for i in range(0, nbins):
        temp = hist[i]
        hist[i] = 0.25 * prev + 0.5 * hist[i] + \
            0.25 * (hist[i + 1] if i + 1 != nbins else h0)
        prev = temp



cdef bint calc_gradient(DTYPE_t[:, ::1] img, int r, int c,
                        double* mag, double* ori):
    """
    Calculate the gradient at a certain point.

    :param img: DTYPE_t[:, ::1]
        # the image where the keypoint lies #
        Same as the `img` in `calc_keypoint_ori_hist`, here `img` is also in
        the Gaussian pyramid.
    :param r: int
        # row number of the keypoint #
    :param c: int
        # column number of the keypoint #
    :param mag: double*
        # the pointer of the double which stores the magnitude value #
    :param ori: double*
  {built-in method mainloop}       # the pointer of th {built-in method mainloop}e double which stores the orientation value #
 {built-in method mainloop}
    :return: bint
        # True of False #
        If the given `r`, `c` are invalid, return False; otherwise return True.

    """
    cdef:
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
        int c, DTYPE_t main_ori, DTYPE_t sigma_oct,
        int nareas=DESCR_HIST_AREAS, int nbins=DESCR_HIST_BINS):
    """
    Calculate the gradient histogram at a keypoint.

    The meaning of the parameters are same as those in calc_descriptor.

    """
    cdef:
        int dr, dc
        double r_area, c_area, n_bin
        DTYPE_t[:, :, ::1] hist = np.zeros([nareas, nareas, nbins], dtype=DTYPE)
        double cos_t = np.cos(main_ori), sin_t = np.sin(main_ori)
        double area_width = sigma_oct * 3  # according to the paper
        int radius = int(area_width * (2 ** 0.5) * (nbins + 1.0) * 0.5 + 0.5)
        double mag, ori, weight
        double pi2 = 2 * np.pi
        double bins_per_rad = nbins / pi2
        double exp_denom = (nareas ** 2) * 0.5

    for dr in range(-radius, radius + 1):
        for dc in range(-radius, radius + 1):
            c_rot = cos_t * dc - sin_t * dr
            r_rot = sin_t * dc + cos_t * dr
            c_area = c_rot / area_width + nareas / 2 - 0.5
            r_area = r_rot / area_width + nareas / 2 - 0.5

            # If the rotated point is still in the 'oblique' inscribed square
            # of the circle whose radius is `radius`:
            if -1.0 < r_area < nareas and -1.0 < c_area < nareas:
                if calc_gradient(img, r + dr, c + dc, &mag, &ori):
                    ori -= main_ori
                    while ori < 0.0:
                        ori += pi2
                    while ori >= pi2:
                        ori -= pi2
                    n_bin = ori * bins_per_rad
                    weight = np.exp(-(c_rot ** 2 + r_rot ** 2) / exp_denom)
                    interp_hist(hist, r_area, c_area, n_bin,
                                nareas, nbins, mag * weight)
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
                        n = (n0 + n_i) % nbins
                        v *= (1.0 - dn if n_i == 0 else dn)
                        hist[r, c, n] += v



cdef int_t[::1] calc_descriptor(
        DTYPE_t[:, ::1] img, int r, int c, double main_ori, double sigma_oct,
        int nareas=DESCR_HIST_AREAS, int nbins=DESCR_HIST_BINS):
    """
    Pass parameters to calc_keypoint_decr_hist to get the descriptor histogram,
    and transform it into the descriptor vector.

    :param img: DTYPE_t[:, ::1]
        # the image where the keypoint lies
        Same as the `img` in `calc_keypoint_ori_hist`, here `img` is also in
        the Gaussian pyramid.
    :param r: int
        # row number of the keypoint #
    :param c: int
        # column number of the keypoint #
    :param main_ori: double
        # the orientation of the keypoint #
    :param sigma_oct: double
        # the sigma of the keypoint #
        The sigma is relative to the octave the point lies in.
    :param nareas: int
        # the number of the sampling areas #
    :param nbins: int
        # the number of the bins in each histogram #

    :return: int_t[::1]
        # the gradient histogram #
        It is a (nareas * nareas * nbins)-dimensional array.

    """
    cdef:
        DTYPE_t[:, :, ::1] hist = \
            calc_keypoint_decr_hist(img, r, c, main_ori, sigma_oct, nareas, nbins)
        int ri, ci, ni, i, length, int_value
        double norm2 = 0, value
        # list desc = []
        # here `descriptor` is still of double[::1] type:
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
        # print "descriptor[" + str(i) + "](before) " + str(descriptor[i])
        int_value = int(DESCR_TO_INT_FCTR * descriptor[i])
        # print "int_value" + str(int_value)
        descriptor[i] = min(255, int_value)
        # print "descriptor[" + str(i) + "](after) " + str(descriptor[i])

    # print "print in calc_descriptor: ", np.array(descriptor)
    # Copy the array, and cast it to a specified type (int):
    return np.array(descriptor).astype(int)



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
        # (octave, scale, row, col) info #
        All elements of `Location` are int. `row` and `col` are values
        relative to the blurred image. See class `Location`.
    ** coord: tuple
        # Row-col coordinate of the exact keypoint in the ORIGINAL image #
        This means:
            coord[0] = (row + row_offset) * 2 ** octave
            coord[1] = (col + col_offset) * 2 ** octave
    ** exact_scale: double
        # The precise scale of the point #
        It equals to the scale number of it in the octave (int) plus the scale
        offset.
    ** sigma_oct: double
        # The 'relative' sigma of the point in the octave it lies in #
        Generally, for a keypoint whose location is (o, s, r, c) with `sigma0`
        as the basic scale of the pyramid,
            sigma_oct = sigma0 * (2.0 ** (s / nscas)),
        where nscas is the number of the scales in the octave. The value is
        given by the __init__ caller.
    ** sigma_abs: double
        # The absolute sigma of the point in the DoG pyramid #
        It is calculated from:
    		sigma_abs = sigma0 * (2.0 ** (o + s / nscas))
    ** ori: double
        # Orientation of keypoint #
    ** descriptor: int_t[::1]
        # The descriptor vector of the keypoint #

    """
    # moved to .pxd
    # cdef:
    #     Location location
    #     tuple coord
    #     double exact_scale
    #     double sigma_oct
    #     double ori
    #     int_t[::1] descriptor

    def __init__(self, Location loc, tuple coord, double exact_scale,
                 double sigma_oct, double sigma_abs):
        self.location = loc
        self.coord = coord
        self.exact_scale = exact_scale
        self.sigma_oct = sigma_oct
        self.sigma_abs = sigma_abs
        # it seems that Memoryview must be initialized if...
        self.descriptor = np.array([], dtype=int)

    def __str__(self):
        return "Location: " + str(self.location) + "\t" + \
               "Coordinate: " + str(self.coord) + "\t" + \
               "Scale: " + str(self.sigma_abs) + "\n" + \
               "Orientation (rad; [0, 2pi)): " + str(self.ori) + "\n" + \
               "Descriptor: " + "\n" + str(np.array(self.descriptor))

    def __richcmp__(self, other, int op):
        if op == Py_EQ:
            return self.location == other.location and \
                   self.coord == other.coord and \
                   self.exact_scale == other.exact_scale

    def __hash__(self):
        return hash(id(self))
