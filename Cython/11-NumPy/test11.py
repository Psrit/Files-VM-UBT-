from __future__ import print_function
import timeit

test_setup = """\
import numpy as np
N = 100
f = np.arange(N*N, dtype=np.int).reshape((N,N))
g = np.arange(81, dtype=np.int).reshape((9,9))
"""

purepy_setup = """\
import convolve_py
"""
print("TESTING: pure python")
t = timeit.Timer("convolve_py.naive_convolve(f, g)", purepy_setup + test_setup)
# print(t.timeit())
print("time spent on each repeat (unit: seconds): ", t.repeat(repeat=3, number=1))

purepyx_setup = """\
import convolve1
"""
print("TESTING: pure cython with python-type object")
t = timeit.Timer("convolve1.naive_convolve(f, g)", purepyx_setup + test_setup)
# print(t.timeit())
print("time spent on each repeat (unit: seconds): ", t.repeat(repeat=3, number=1))

pyx_ctype_setup = """\
import convolve2
"""
print("TESTING: pure cython with C-type object")
t = timeit.Timer("convolve2.naive_convolve(f, g)", pyx_ctype_setup + test_setup)
# print(t.timeit())
print("time spent on each repeat (unit: seconds): ", t.repeat(repeat=3, number=1))