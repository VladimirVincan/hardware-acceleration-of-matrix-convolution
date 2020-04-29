import numpy as np

f = open("vector.in", "r")

a = []
n = f.readline()[0]
line = f.readline()
l = line.replace(" ", "")
for i in range(int(n)):
    a.append(float(l[i]))
print(a)
print(np.fft.fft(a))
f.close()
