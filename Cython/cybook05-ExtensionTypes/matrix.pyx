from libc.stdlib cimport malloc, free

cdef class Matrix:
    cdef:
        unsigned int nrows, ncols
        double*_matrix
    def __cinit__(self, nr, nc):
        self.nrows = nr
        self.ncols = nc
        self._matrix = <double*> malloc(nr * nc * sizeof(double))
        if self._matrix == NULL:
            raise MemoryError()
    # the __del__ special method is not supported by extension types;
    # __dealloc__ takes the role (C-level finalization).
    def __dealloc__(self):
        if self._matrix != NULL:
            free(self._matrix)
