cd FFT2-PROJECT/
echo "CONFIG_gpio-demo" >> project-spec/meta-user/conf/user-rootfsconfig
echo "CONFIG_peekpoke" >> project-spec/meta-user/conf/user-rootfsconfig
echo "CONFIG_kernel-devsrc" >> project-spec/meta-user/conf/user-rootfsconfig
# source /tools/PetaLinux/2019.2/settings.sh
petalinux-config -c rootfs
