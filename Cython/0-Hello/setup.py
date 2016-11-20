# coding=utf-8

# to build, run 'python setup.py build_ext --inplace' in command line

# since the module doesn’t require any extra C libraries or a special build setup,
# in the easy way, we can use: 'import pyximport; pyximport.install()'
# and then import hello directly in Test0.py

# to figure out where the code is taking time,
# use the -a switch to the cython command line program:
# 'cython -a hello.pyx'

from distutils.core import setup
from Cython.Build import cythonize

setup(
    name="Hello World app",
    ext_modules=cythonize("hello.pyx"),
)
