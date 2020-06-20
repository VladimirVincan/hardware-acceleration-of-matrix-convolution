rmmod fft2-driver.ko
insmod fft2-driver.ko

echo "0, 2" > /dev/xlnx,bram_re
echo "1, 0" > /dev/xlnx,bram_re
echo "2, 0" > /dev/xlnx,bram_re
echo "3, 0" > /dev/xlnx,bram_re

echo "4, 0" > /dev/xlnx,bram_re
echo "5, 0" > /dev/xlnx,bram_re
echo "6, 0" > /dev/xlnx,bram_re
echo "7, 0" > /dev/xlnx,bram_re

echo "8, 0" > /dev/xlnx,bram_re
echo "9, 0" > /dev/xlnx,bram_re
echo "10, 0" > /dev/xlnx,bram_re
echo "11, 0" > /dev/xlnx,bram_re

echo "12, 0" > /dev/xlnx,bram_re
echo "13, 0" > /dev/xlnx,bram_re
echo "14, 0" > /dev/xlnx,bram_re
echo "15, 0" > /dev/xlnx,bram_re

echo "0, 0" > /dev/xlnx,bram_im
echo "1, 0" > /dev/xlnx,bram_im
echo "2, 0" > /dev/xlnx,bram_im
echo "3, 0" > /dev/xlnx,bram_im

echo "4, 0" > /dev/xlnx,bram_im
echo "5, 0" > /dev/xlnx,bram_im
echo "6, 0" > /dev/xlnx,bram_im
echo "7, 0" > /dev/xlnx,bram_im

echo "8, 0" > /dev/xlnx,bram_im
echo "9, 0" > /dev/xlnx,bram_im
echo "10, 0" > /dev/xlnx,bram_im
echo "11, 0" > /dev/xlnx,bram_im

echo "12, 0" > /dev/xlnx,bram_im
echo "13, 0" > /dev/xlnx,bram_im
echo "14, 0" > /dev/xlnx,bram_im
echo "15, 0" > /dev/xlnx,bram_im


echo "1024, 5" > /dev/xlnx,bram_re
echo "1025, 0" > /dev/xlnx,bram_re
echo "1026, 0" > /dev/xlnx,bram_re
echo "1027, 0" > /dev/xlnx,bram_re

echo "1028, 0" > /dev/xlnx,bram_re
echo "1029, 0" > /dev/xlnx,bram_re
echo "1030, 0" > /dev/xlnx,bram_re
echo "1031, 0" > /dev/xlnx,bram_re

echo "1032, 0" > /dev/xlnx,bram_re
echo "1033, 0" > /dev/xlnx,bram_re
echo "1034, 0" > /dev/xlnx,bram_re
echo "1035, 0" > /dev/xlnx,bram_re

echo "1036, 0" > /dev/xlnx,bram_re
echo "1037, 0" > /dev/xlnx,bram_re
echo "1038, 0" > /dev/xlnx,bram_re
echo "1039, 0" > /dev/xlnx,bram_re

echo "1024, 0" > /dev/xlnx,bram_im
echo "1025, 0" > /dev/xlnx,bram_im
echo "1026, 0" > /dev/xlnx,bram_im
echo "1027, 0" > /dev/xlnx,bram_im

echo "1028, 0" > /dev/xlnx,bram_im
echo "1029, 0" > /dev/xlnx,bram_im
echo "1030, 0" > /dev/xlnx,bram_im
echo "1031, 0" > /dev/xlnx,bram_im

echo "1032, 0" > /dev/xlnx,bram_im
echo "1033, 0" > /dev/xlnx,bram_im
echo "1034, 0" > /dev/xlnx,bram_im
echo "1035, 0" > /dev/xlnx,bram_im

echo "1036, 0" > /dev/xlnx,bram_im
echo "1037, 0" > /dev/xlnx,bram_im
echo "1038, 0" > /dev/xlnx,bram_im
echo "1039, 0" > /dev/xlnx,bram_im

echo "4, 4, 4, 4" > /dev/xlnx,fft2
cat /dev/xlnx,fft2
cat /dev/xlnx,bram_re
cat /dev/xlnx,bram_im
