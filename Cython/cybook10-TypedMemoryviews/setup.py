from distutils.core import setup, Extension
from Cython.Build import cythonize
from numpy import get_include

ext = [
    Extension("numpy_cleanup",
              sources=["numpy_cleanup.pyx"],
              include_dirs=['.', get_include()]
              ),
    Extension("memview",
              sources=["memview.pyx"],
              )
]

setup(
    name="TypedMemoryviews",
    ext_modules=cythonize(ext)
)
