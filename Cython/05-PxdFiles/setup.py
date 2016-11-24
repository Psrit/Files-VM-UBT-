from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

setup(
    name="integrate_demo",
    ext_modules=cythonize("*.pyx"),
)

## OR:
# ext_modules = [
#     Extension("integrate",
#               sources=["integrate.pyx"],
#               libraries=["m"]  # Unix-like specific for libc math library
#               )
# ]
#
# setup(
#     name="integrate_demo",
#     ext_modules=cythonize(ext_modules),
# )
