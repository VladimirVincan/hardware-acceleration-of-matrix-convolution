# source /tools/PetaLinux/2019.2/settings.sh
petalinux-create --type project --template zynq --name FFT2-PROJECT
cd FFT2-PROJECT/
petalinux-config --get-hw-description=$(pwd)/../release
