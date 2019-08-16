#include <Python.h>
#include "numpy/arrayobject.h"
#include <vector>
#include <numeric>
#include <iterator>
#include "FFT_iterative.cpp"

void free_Carrayptrs(double **v) {
    free((char*) v);
}

double **ptrvector(long n){
    double **v;
    v = (double **)malloc((size_t) (n*sizeof(double)));
    if (!v) {
        printf("In **ptrvector. Allocation of memory for double array failed.");
        exit(0);
    }
    return v;
}

double **pymatrix_to_Carrayptrs(PyArrayObject *arrayin){
    double **c, *a;
    int i, n, m;

    n = arrayin->dimensions[0];
    m = arrayin->dimensions[1];
    c = ptrvector(n);
    a = (double *) arrayin->data;
    for (i=0;i<n;++i) {
        c[i] = a+i*m;
    }
    return c;
}

int not_doublematrix(PyArrayObject *mat) {
    if (mat->descr->type_num != NPY_DOUBLE || mat->nd != 2) {
        PyErr_SetString(PyExc_ValueError,
            "In not_doublematrix: array must be of type Float and 2 dimensional.");
        return 1;
    }
    return 0;
}

// e.g. 1 001 001 010 -> 1 111 111 111 -> 10 000 000 000
int setBitNumber(int n)
{
    n |= n >> 1;
    n |= n >> 2;
    n |= n >> 4;
    n |= n >> 8;
    n |= n >> 16;
    n = n + 1;
    return n;
}

int highestBit(int n)
{
  int ret = 0;
  while (n>0) n>>=1,++ret;
  return ret;
}

static PyObject *Py_FFT_convolution(PyObject *self, PyObject *args)
{
    double **cinmat1, **cinmat2, **coutmat;
    PyArrayObject *matin1, *matin2, *matout;
    int dims[2],n1,m1,n2,m2,n,m, log2n, log2m;

    if (!PyArg_ParseTuple(args, "O!O!", &PyArray_Type, &matin1, &PyArray_Type, &matin2)) 
        return NULL;
    if (NULL == matin1 || NULL == matin2) return NULL;

    if (not_doublematrix(matin1) || not_doublematrix(matin2)) return NULL;

    n1=matin1->dimensions[0];
    m1=matin1->dimensions[1];
    n2=matin2->dimensions[0];
    m2=matin2->dimensions[1];
    n = dims[0]= setBitNumber(n1+n2-1);
    m = dims[1]= setBitNumber(m1+m2-1);
    log2n = highestBit(n);
    log2m = highestBit(m);
    matout = (PyArrayObject*) PyArray_FromDims(2,dims,NPY_DOUBLE);

    cinmat1=pymatrix_to_Carrayptrs(matin1);
    cinmat2=pymatrix_to_Carrayptrs(matin2);
    coutmat=pymatrix_to_Carrayptrs(matout);

    double **mat1, **mat2;
    alloc_matrix(n,m, &mat1);
    alloc_matrix(n,m, &mat2);

    for (int i=0;i<n;++i)
        for (int j=0;j<m;++j)
             if (i<n1 && j<m1)
                 mat1[i][j]=cinmat1[i][j];
             else
                 mat1[i][j]=0;

    for (int i=0;i<n;++i)
        for (int j=0;j<m;++j)
             if (i<n2 && j<m2)
                 mat2[i][j]=cinmat2[i][j];
             else
                 mat2[i][j]=0;

    matrix_convolution(n,m,log2n, log2m, mat1,mat2,coutmat);
    free_Carrayptrs(cinmat1);
    free_Carrayptrs(cinmat2);
    free_Carrayptrs(coutmat);

    return PyArray_Return(matout);
}

static PyMethodDef convolution_methods[] = {
	{"matrix_convolution", Py_FFT_convolution,	METH_VARARGS,	 "Return the convolution of matrices using FFT."},
	{NULL,		NULL}		/* sentinel */
};

static struct PyModuleDef convolution_module = {
    PyModuleDef_HEAD_INIT,
    "convolution_cpp_lib",   /* name of module */
    NULL, /* module documentation, may be NULL */
    -1,
    convolution_methods
};

PyMODINIT_FUNC PyInit_convolution_cpp_lib(void)
{
    import_array();
    return PyModule_Create(&convolution_module);
}

int main(int argc, char **argv)
{
    wchar_t *program = Py_DecodeLocale(argv[0], NULL);
    if (program == NULL) {
        fprintf(stderr, "Fatal error: cannot decode argv[0]\n");
        exit(1);
    }
    /* Add a built-in module, before Py_Initialize */
    PyImport_AppendInittab("convolution_cpp_lib", PyInit_convolution_cpp_lib);

    /* Pass argv[0] to the Python interpreter */
    Py_SetProgramName(program);

    /* Initialize the Python interpreter.  Required. */
    Py_Initialize();

    PyMem_RawFree(program);
    return 0;
}
