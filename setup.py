from distutils.core import setup, Extension
import numpy

std_module = Extension('convolution_cpp_lib', sources=['py_wrapper_module.cpp'], 
                              include_dirs=[numpy.get_include()])

setup(name='convolution_cpp_lib',
      version='1.0',
      description='Module for calculating matrix convolution using FFT.',
      install_dirs = ["cycler==0.10.0",
                          "kiwisolver==1.0.1"
                          "matplotlib==3.0.2",
                          "numpy==1.16.1",
                          "pandas==0.24.1",
                          "pyparsing==2.3.1",
                          "python-dateutil==2.8.0",
                          "pytz==2018.9",
                          "six==1.12.0"],
      ext_modules=[std_module])
