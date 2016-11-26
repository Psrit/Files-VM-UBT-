from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

ext_modules = [
    Extension("ImagePreprocessing",
              sources=["ImagePreprocessing.pyx"],
              libraries=["m"]  # Unix-like specific for libc math library
              )
]

setup(
    name="Sift",
    ext_modules=cythonize(ext_modules),
)
