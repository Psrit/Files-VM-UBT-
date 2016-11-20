cmake_minimum_required(VERSION 3.6)
project(ImagePreprocessing)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

set(SOURCE_FILES ImPreprocessing.cpp CApiTest.cpp)
add_executable(ImagePreprocessing ${SOURCE_FILES})