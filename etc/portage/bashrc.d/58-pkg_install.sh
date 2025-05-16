#!/bin/bash
# Copyright (C) 2021 Artem Slepnev, Shellgen
# License GPLv3+: GNU GPL version 3 or later
# http://gnu.org/licenses/gpl.html


((UID)) || {
   [[ -d ${INSTALL_DIR}/ ]] || exit
   cd "${INSTALL_DIR}/"
   chown -R root:root ${INSTALL_DIR}/ ${SRC_DIR}/${PN}-${PV}/

   # create package
   [[ -d '../../pkg/' ]] || mkdir '../../pkg/'
   #find . | cpio -H newc -o | zstd -f -o ../${PN}_${PV}_${ABI}.czst
   shopt -s 'globstar'
   printf '%s\n' ** \
    | cpio -H newc -o \
    | xz --best --extreme --check=crc32 --lzma2=dict=1024KiB \
    > ../../pkg/${PN}_${PV}_${ABI}.cxz

   # Install rootfs
   #[[ ${ROOTFS_NOWR-} ]] || MOUNT_OPT='rw'
   #mount -vio "remount,${MOUNT_OPT}" /mnt/root/
   #rsync -avHx --update --exclude-from='excludes.lst' ${PWD}/ ${OS_ROOT_DIR}/${PWD#/}/
   #shopt -uo 'noglob'
   #cp -vfulr ${OS_ROOT_DIR}/${INSTALL_DIR#/}/* ${OS_ROOT_DIR}/
   #mount -io 'remount,ro' /mnt/root/
}