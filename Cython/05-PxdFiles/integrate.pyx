from cmath cimport sin, pi

cdef class Function:
    # a "virtual" function
    # Note: unlike a cdef method, a cpdef method is fully overrideable
    # by methods and instance attributes in Python subclasses
    cpdef double evaluate(self, double x) except *:
        return 0

cdef class SampleFunction(Function):
    cpdef double evaluate(self, double x) except *:
        return sin(x) / x if x != 0 else 1

cpdef integrate(Function f, double a, double b, int N):
    cdef int i
    cdef double s, dx
    if f is None:
        raise ValueError("f cannot be None")

    s = 0
    dx = (b - a) / N
    for i in range(N):
        s += f.evaluate(a + i * dx)

    return s * dx

