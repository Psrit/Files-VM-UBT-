#include <malloc.h>
float* make_empty_matrix_c(int nrows, int ncols) {
    float* mat = (float*)malloc(nrows * ncols * sizeof(float));
    return mat;
}