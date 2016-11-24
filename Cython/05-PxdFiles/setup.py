from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

ext_modules = [
    Extension("integrate",
              sources=["integrate.pyx"],
              libraries=["m"]  # Unix-like specific for libc math library
              )
]

setup(
    name="extension_types",
    ext_modules=cythonize(ext_modules),
)
