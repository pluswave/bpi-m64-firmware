#!/bin/bash

function pt_error()
{
    echo -e "\033[1;31mERROR: $*\033[0m"
}

function pt_warn()
{
    echo -e "\033[1;31mWARN: $*\033[0m"
}

function pt_info()
{
    echo -e "\033[1;32mINFO: $*\033[0m"
}

function pt_ok()
{
    echo -e "\033[1;33mOK: $*\033[0m"
}



SDCARD="$1"

if [ -z "$SDCARD" ]; then
    pt_error "Usage: $0 <SD card> (SD CARD: /dev/sdX  or /dev/mmcblkX where X is your sd card number)"
    exit 1
fi

pt_info "Umounting $out, please wait..."
umount ${SDCARD}* >/dev/null 2>&1
sleep 1
sync

set -e

pt_warn "Flashing $SDCARD...."
dd if=./boot0.bin conv=notrunc bs=1k seek=8 of=${SDCARD}
dd if=./ub-m64-sdcard.bin conv=notrunc bs=1k seek=19096 of=${SDCARD}

mkdir -p erootfs
mount $SDCARD"2" erootfs
tar -xvpzf rootfs_m64_rc3.tar.gz -C ./erootfs --numeric-ow
sync
umount erootfs
rm -fR erootfs

set +e
mkdir eboot
mount $SDCARD"1" eboot
tar -xvpzf boot_m64_rc3.tar.gz -C ./eboot --numeric-ow
sync
umount eboot
rm -fR eboot

pt_ok "Finished flashing $SDCARD!"
