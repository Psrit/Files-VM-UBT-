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

# print(integrate(SampleFunction(), 0, pi, 10000))

# Some notes on our new implementation of evaluate:
#
# **The fast method dispatch here only works because evaluate was declared
#   in Function. Had evaluate been introduced in SampleFunction, the
#   code would still work, but Cython would have used the slower Python
#   method dispatch mechanism instead.
#
# **In the same way, had the argument f not been typed, but only been passed
#   as a Python object, the slower Python dispatch would be used.
#
# **Since the argument is typed, we need to check whether it is None. In Python,
#   this would have resulted in an AttributeError when the evaluate method
#   was looked up, but Cython would instead try to access the (incompatible)
#   internal structure of None as if it were a Function, leading to a crash
#   or data corruption.
