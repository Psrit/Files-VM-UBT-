# With integrate.pxd, other modules written in Cython can
# define fast custom functions to integrate.
cdef class Function:
    cpdef double evaluate(self, double x)  except * # except * cannot be left out.

cdef class SampleFunction(Function):
    cpdef double evaluate(self, double x)  except *

cpdef integrate(Function f, double a, double b, int N)
