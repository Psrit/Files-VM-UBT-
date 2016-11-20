from libc.stdlib cimport atoi

def parse_charptr_to_py_int(char *s):
    assert s is not NULL, "byte string value is NULL"
    return atoi(s)


# OR use: from libc.math cimport sin
cdef extern from "math.h":
    cpdef double sin(double x)

cdef double sample_fun_x_not_zero(double x):
    assert x != 0, "x is 0"
    return sin(x) / x

def Sa(double x):
    return sample_fun_x_not_zero(x) if x != 0 else 1


cdef extern from "string.h":
    char*strstr(const char*haystack, const char*needle)

def my_strstr(const char*haystack, const char*needle):
    print strstr(haystack, needle)
