//
// Created by xiaojx on 11/20/16.
//

#include <python2.7/Python.h>
#include <numpy/arrayobject.h>
#include <stdio.h>
#include <math.h>

int c_api_test(int a) {
    return -a;
}

static PyObject *_c_api_test(PyObject *self, PyObject *args) {
    int _input;

    if (!PyArg_Parse(args, "i", &_input))
        return NULL;

    int _out = c_api_test(_input);

    return PyLong_FromLong(_out);
//    PyObject *out = PyArray_SimpleNewFromData(_rowsOfInput, dims,
//                                              NPY_DOUBLE, im_blurred);
}

static PyMethodDef CApiTestModuleMethods[] = {
        {
                "c_api_test",
                _c_api_test,
                METH_VARARGS,
                ""
        },
        {NULL, NULL, 0, NULL}
};

PyMODINIT_FUNC initCApiTest(void) {
    (void) Py_InitModule("CApiTest", CApiTestModuleMethods);
}