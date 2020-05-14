import numpy as np

f = open("vector.in", "r")

a = []
n = f.readline()[0]
line = f.readline()
l = line.replace(" ", "")
# for i in range(int(n)):
#     a.append(float(l[i]))
l = line.split(" ")
for i in range(int (n)):
    a.append(float(l[i]))
print(a)
np.set_printoptions(precision=6)
print(np.fft.fft(a))
f.close()
