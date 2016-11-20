#include <python2.7/Python.h>
#include <numpy/arrayobject.h>
#include <stdio.h>
#include <math.h>

/* Gaussian blurring using 2-dimensional square Gaussian kernel. */
double **GaussianBlur(int **input, int rowsOfInput, int colsOfInput,
                      double sigma = 1.6, int size = -1) {
    if (size <= 0)
        size = (int) ceil(6 * sigma + 1);
    if (size % 2 == 0)
        size++;
    double *gaussian_array1d = new double[size];
    int halfSideLength = (size - 1) / 2;
    double sum = 0;
    for (int i = 0; i < size; i++) {
        // the central point of gaussian array lies at i = (size - 1) / 2
        gaussian_array1d[i] = exp(-pow((i - halfSideLength), 2) / (2 * pow(sigma, 2)))
                              / (sqrt(2 * M_PI) * sigma);
        sum += gaussian_array1d[i];
    }
    printf("image size: (%d, %d)\n", rowsOfInput, colsOfInput);

    double **im_conv = new double *[rowsOfInput];
    for (int row = 0; row < rowsOfInput; row++) {
        im_conv[row] = new double[colsOfInput];
        for (int col = 0; col < colsOfInput; col++)
            for (int index = (int) fmax(-(size - 1) / 2 + col, 0);
                 index < fmin((size - 1) / 2 + col + 1, colsOfInput); index++)
                im_conv[row][col]
                        += input[row][index] * gaussian_array1d[index - col + (size - 1) / 2];
    }

    double **im_blurred = new double *[rowsOfInput];
    for (int row = 0; row < rowsOfInput; row++) {
        im_blurred[row] = new double[colsOfInput];
        for (int col = 0; col < colsOfInput; col++)
            for (int index = (int) fmax(-(size - 1) / 2 + row, 0);
                 index < fmin((size - 1) / 2 + row + 1, rowsOfInput); index++)
                im_blurred[row][col]
                        += im_conv[index][col] * gaussian_array1d[index - row + (size - 1) / 2];
    }

    for (int row = 0; row < rowsOfInput; row++)
        delete im_conv[row];
    delete im_conv;
    delete gaussian_array1d;

    return im_blurred;
}


static PyObject *_gaussian_blur(PyObject *self, PyObject *args) {
    int **_input;
    int _rowsOfInput, _colsOfInput;
    int _sigma, _size;
    double **im_blurred;

    if (!PyArg_Parse(args, "O!(ii)di", &PyArray_Type, &_input, &_rowsOfInput,
                     &_colsOfInput, &_sigma, &_size))
        return NULL;

    im_blurred = GaussianBlur(_input, _rowsOfInput, _colsOfInput, _sigma, _size);

    npy_intp dims[_rowsOfInput];
    for (int i = 0; i < _rowsOfInput; i++)
        dims[i] = _colsOfInput;

    PyObject *out = PyArray_SimpleNewFromData(_rowsOfInput, dims,
                                              NPY_DOUBLE, im_blurred);
}

static PyMethodDef ImPreprocModuleMethods[] = {
        {
                "gaussian_blur",
                _gaussian_blur,
                METH_VARARGS,
                ""
        },
        {NULL, NULL, 0, NULL}
};

PyMODINIT_FUNC initImPreprocessing(void) {
    (void) Py_InitModule("ImPreprocessing", ImPreprocModuleMethods);
}