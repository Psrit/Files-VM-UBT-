from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

ext_modules = [
    Extension("particle",
              sources=["particle.pyx"],
              libraries=["m"]  # Unix-like specific for libc math library
              ),
    Extension("matrix",
              sources=["matrix.pyx"],
              libraries=["m"])
]

setup(
    name="extension_types",
    ext_modules=cythonize(ext_modules),
)
