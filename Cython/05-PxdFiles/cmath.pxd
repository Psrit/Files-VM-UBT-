cdef extern from "<math.h>":
    # Actually these two declarations are copied from math.pxd:
    double sin(double x)
    double pi "M_PI"  # as in Python's math module

