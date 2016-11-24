from cpython.object cimport Py_LT, Py_LE, Py_EQ, Py_NE, Py_GT, Py_GE

cdef class E:
    """Extension type that supports addition and rich comparisons. """
    cdef int data
    def __init__(self, d):
        self.data = d
    def __add__(x, y):
        # Regular __add__ behavior
        if isinstance(x, E):
            if isinstance(y, int):
                return (<E> x).data + y
        # Extension types do not support __radd__; they simply but effectively
        # overload __add__ to do the job of both the regular __add__ and
        # __radd__ in one special method.
        # Here is the __radd__ behavior implemented by us manually:
        elif isinstance(y, E):
            if isinstance(x, int):
                return (<E> y).data + x
        else:
            return NotImplemented

    # Cython provides a single method __richcmp__(x, y, op) instead of individual
    # comparison special methods like __eq__, __lt__, and __le__.
    # If a type supports rich comparisons, then chained comparisons like 0 <= e
    # <= 200 are automatically supported as well.
    def __richcmp__(x, y, int op):
        cdef:
            E e
            double data

        # make e always refer to the E instance.
        e, y = (x, y) if isinstance(x, E) else (y, x)
        data = e.data

        if op == Py_LT:
            return data < y
        elif op == Py_LE:
            return data <= y
        elif op == Py_EQ:
            return data == y
        elif op == Py_NE:
            return data != y
        elif op == Py_GT:
            return data > y
        elif op == Py_GE:
            return data >= y
        else:
            assert False

cdef class I:
    """Extension type that supports iterator. """
    cdef:
        list data
        int i
    def __init__(self):
        self.data = range(100)
        self.i = 0

    # With __iter__, instances of I can be used in for loops.
    def __iter__(self):
        return self

    # With __next__, instances of I can be used where an iterator is required:
    # it = iter(I())
    # it.next() returns 0
    # next(it) returns 1
    def __next__(self):
        if self.i >= len(self.data):
            raise StopIteration()
        ret = self.data[self.i]
        self.i += 1
        return ret
