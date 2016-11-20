# to build, run 'python setup.py build_ext --inplace'

from distutils.core import setup
from Cython.Build import cythonize

setup(
    name = "Hello World app",
    ext_modules = cythonize("hello.pyx"),
)