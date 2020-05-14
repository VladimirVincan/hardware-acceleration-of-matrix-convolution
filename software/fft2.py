import numpy as np
from pandas import *

f = open("matrix.in", "r")

aa = []
n = f.readline()[0]
for i in range(int (n)):
    a = []
    line = f.readline()
    l = line.replace(" ", "")
    # for i in range(int(n)):
    #     a.append(float(l[i]))
    l = line.split(" ")
    for j in range(int (n)):
        a.append(float(l[j]))
    aa.append(a)
    print(np.fft.fft(a))
# print(aa)
print("\n")
aa = np.fft.fft2(aa)
# aa = round(aa.real,2) + round(aa.imag,2) * 1j
# aa = DataFrame(aa)
# aa = aa.round(3)
# print('\n'.join([' '.join(['{:2f}'.format(item) for item in row]) for row in aa]))
# print(aa)
print(aa, sep = " ")
f.close()
