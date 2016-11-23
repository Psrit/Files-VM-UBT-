from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

ext_modules = [
    Extension("calling_c_demo",
              sources=["calling_c_demo.pyx"],
              libraries=["m"]  # Unix-like specific for libc math library
              ),
    Extension("fact_demo",
              sources=["fact_demo.pyx"])
]

setup(
    name="Demos",
    ext_modules=cythonize(ext_modules),
)
