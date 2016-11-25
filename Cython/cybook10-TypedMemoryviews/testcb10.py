import memview
import numpy_cleanup
import numpy as np

l = np.arange(100.0)
print(memview.summer_typed_mv(l))
print(memview.summer_typed_mv_c(l))

arr = numpy_cleanup.make_matrix(100, 100)
print("arr: ", arr)
arr2 = arr
arr[0, 0] = 100
print("arr2: ", arr2)
print(arr.base)
