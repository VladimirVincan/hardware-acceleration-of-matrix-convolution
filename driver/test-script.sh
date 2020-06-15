rmmod fft2-driver.ko
insmod fft2-driver.ko

echo "0, 1" > /dev/xlnx,bram_re
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

echo "1, 3, 1, 3" > /dev/xlnx,fft2
cat /dev/xlnx,fft2
cat /dev/xlnx,bram_re
cat /dev/xlnx,bram_im
