import sys
# from scipy import signal
# from scipy import linalg
import scipy.signal
import scipy.fftpack
import numpy as np

import convolution_cpp_lib

a = [[1,0,1,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]]
# a = [[1,2,3,4],[0,0,0,0],[0,0,0,0],[0,0,0,0]]
# a = [[1,2,3,4],[5,6,7,8],[9,10,11,12],[13,14,15,16]]
# a = [[1+17j,2+18j,3+19j,4+20j],[5+21j,6+22j,7+23j,8+24j],[9+25j,10+26j,11+27j,12+28j],[13+29j,14+30j,15+31j,16+32j]]
# a = [[1+21j,2+22j,3+23j,4+24j],[5+25j,6+26j,7+27j,8+28j],[9+29j,10+30j,11+31j,12+32j],[13+33j,14+34j,15+35j,16+36j]]
# a = [[1.5,2.3,3.4,0],[1,5,0,0],[0,1,1,2],[2.1,1.3,4.5,1]]
# a = [[1,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0]]
# a = [1,0,1,0]
print(np.fft.fft2(np.array(a)))
# print(np.fft.fft(np.array(a)))

# a = [[1,2,3,0,0,0,0,0],[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0]]
# print(np.fft.fft2(np.array(a)))
# print("\n")

# b = [[1,0,0,0,0,0,0,0],[0,2,3,0,0,0,0,0],[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0]]
# print(np.fft.fft2(np.array(b)))
# print("\n")

# print(scipy.signal.convolve2d(a,b))

# c = [1,2,3,0,0,0,0,0]
# print(np.fft.fft(c))
# print("\n")

# c = [1,2,3,0,0,0,0,0]
# print(scipy.fftpack.fft(c))
# print("\n")

# c = [1,2,3,0]
# print(np.fft.fft(c))
# print("\n")

# c = [1,2,3,4]
# print(np.fft.fft(c))
# print("\n")
