# cython: profile=True
from libc.math cimport sin, pi

cpdef double sin2(double x):
    return sin(x) ** 2

def integrate(f, double a, double b, int N=2000):
    cdef:
        int i
        double s=0.0
        double dx = (b - a) / N

    if f is None:
        raise ValueError("f cannot be None")

    for i in range(N):
        s += f(a + i * dx)

    return s * dx