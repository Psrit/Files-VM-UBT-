from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

ext_modules = [
    Extension("convolve1",
              sources=["convolve1.pyx"],
              libraries=["m"]  # Unix-like specific for libc math library
              ),

    Extension("convolve2",
              sources=["convolve2.pyx"],
              libraries=["m"]  # Unix-like specific for libc math library
              )
]

setup(
    name="Convolve",
    ext_modules=cythonize(ext_modules),
)
