cd FFT2-PROJECT/
echo "#ifdef CONFIG_BOOTCOMMAND" >> project-spec/meta-user/recipes-bsp/u-boot/files/platform-top.h
echo "#undef CONFIG_BOOTCOMMAND" >> project-spec/meta-user/recipes-bsp/u-boot/files/platform-top.h
echo "#define CONFIG_BOOTCOMMAND \"run uenvboot; run cp_kernel2ram && run cp_dtb2ram && bootm \${netstart} - \${dtbnetstart}\"" >> project-spec/meta-user/recipes-bsp/u-boot/files/platform-top.h
echo "#endif" >> project-spec/meta-user/recipes-bsp/u-boot/files/platform-top.h
# source /tools/PetaLinux/2019.2/settings.sh
cp ../system-user.dtsi project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi
petalinux-build -c device-tree
petalinux-build
petalinux-package --boot --format BIN --fsbl images/linux/zynq_fsbl.elf --fpga
images/linux/system.bit --u-boot images/linux/u-boot.elf
cp -f -t /media/bici/BOOT/ images/linux/BOOT.BIN images/linux/system.dtb images/linux/image.ub
umount /media/bici/BOOT
mkdir images/linux/rootfs
tar xzf images/linux/rootfs.tar.gz -C images/linux/rootfs
sudo tar xf ~/Downloads/linaro-jessie-developer-20161117-32.tar.gz --strip-components=1 -C /media/bici/ROOT_FS/
sudo cp -rf images/linux/rootfs/lib/modules/* /media/bici/ROOT_FS/lib/modules/
sudo cp -P images/linux/rootfs/usr/src/kernel /media/bici/ROOT_FS/usr/src/kernel
umount /media/bici/ROOT_FS
