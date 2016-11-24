from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

ext_modules = [
    Extension("ImPreprocessing",
              sources=["ImPreprocessing.pyx"],
              libraries=["m"]  # Unix-like specific for libc math library
              )
]

setup(
    name="ImPreprocessing",
    ext_modules=cythonize(ext_modules),
)
