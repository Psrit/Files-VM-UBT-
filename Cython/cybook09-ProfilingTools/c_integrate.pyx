cimport cython

@cython.cdivision(True)
cdef double integrate(double (*f) (double), double a, double b, int N=2000):
    cdef:
        int i
        double s=0.0
        double dx = (b - a) / N

    # if f == NULL:
    #     raise ValueError("f cannot be None")

    for i in range(N):
        s += f(a + i * dx)

    return s * dx