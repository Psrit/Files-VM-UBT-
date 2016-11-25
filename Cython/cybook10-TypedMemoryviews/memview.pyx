from cython cimport boundscheck, wraparound

def summer_typed_mv(double[:] mv):
    """ Sums its argument's contents. """
    cdef double d, ss = 0.0
    for d in mv:
        ss += d
    return ss

def summer_typed_mv_c(double[:] mv):
    """ Sums its argument's contents. """
    cdef:
        double ss = 0.0
        int i, N

    N = mv.shape[0]
    with boundscheck(False), wraparound(False):
        for i in range(N):
            ss += mv[i]
    return ss
