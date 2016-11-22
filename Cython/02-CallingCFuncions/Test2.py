import calling_c_demo
import math

print calling_c_demo.parse_charptr_to_py_int("3.14159")
print calling_c_demo.Sa(3.14)

# Segmentation fault (core dumped)???
# print calling_c_demo.my_strstr(needle="akd", haystack="hfvcakdfagbcffvschvxcdfgccbcfhvgcsnfxjh")
# print calling_c_demo.my_strstr("akd", "hfvcakdfagbcffvschvxcdfgccbcfhvgcsnfxjh")

print calling_c_demo.Sa(0)