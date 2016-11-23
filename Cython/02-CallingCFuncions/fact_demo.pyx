# cython: embedsignature=True

#  a little bit faster than pure python
def py_fact(n):
    """Computes n!"""
    if n <= 1:
        return 1
    return n * py_fact(n - 1)

# in this case statically typing typed_fact's argument dose not improve
# performance over py_fact
def typed_fact(long n):
    """Computes n!"""
    if n <= 1:
        return 1
    return n * typed_fact(n - 1)

# much faster than typed_fact and py_fact.
# a wrapper function is needed if we want to use c_fact from Python code outside
# this extension module.
#
# to partially address the limitation of C int while maintaining Cython's performance,
# we can use doubles rather than integral types
cdef long c_fact(long n):
    """Computes n!"""
    if n <= 1:
        return 1
    return n * c_fact(n - 1)

def wrap_c_fact(n):
    """Computes n!"""
    return c_fact(n)

# same as c_fact, but wrapper is generated automatically.
# note that not all C types can be used as the argument types or return type of cpdef functions.
cpdef long cp_fact(long n):
    """Computes n!"""
    if n <= 1:
        return 1
    return n * cp_fact(n - 1)
