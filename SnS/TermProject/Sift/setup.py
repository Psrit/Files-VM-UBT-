from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

ext_modules = [
    Extension("ImagePreprocessing",
              sources=["ImagePreprocessing.pyx"],
              include_dirs=['.'],
              libraries=["m"]  # Unix-like specific for libc math library
              ),
    Extension("DOGSpaceGenerator",
              sources=["DOGSpaceGenerator.pyx"],
              include_dirs=['.'],
              libraries=["m"]  # Unix-like specific for libc math library
              ),
    Extension("DescriptorGenerator",
              sources=["DescriptorGenerator.pyx"],
              include_dirs=['.'],
              libraries=["m"]  # Unix-like specific for libc math library
              ),
    Extension("Math",
              sources=["Math.pyx"],
              include_dirs=['.'],
              libraries=["m"]  # Unix-like specific for libc math library
              )
]

setup(
    name="Sift",
    ext_modules=cythonize(ext_modules),
)
