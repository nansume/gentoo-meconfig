#!/bin/bash
# Copyright (C) 2021 Artem Slepnev, Shellgen
# License GPLv3+: GNU GPL version 3 or later
# http://gnu.org/licenses/gpl.html


XABI='all' XUSER='livecd'

((UID)) || {
  cd "${INSTALL_DIR}/"
  mkdir --mode=0750 --parents home/${XUSER}/{.config/mc,download}/ root/.config/{,mc/}
  chown ${XUSER}:${XUSER}     home/${XUSER}/{.config/mc,download}/
  # create package
  [[ -d '../../pkg/' ]] || mkdir '../../pkg/'
  shopt -s 'globstar' 'dotglob'
  printf '%s\n' ** \
   | cpio -H newc -o \
   | xz --best --extreme --check=crc32 --lzma2=dict=1024KiB \
   > ../../pkg/${PN}_${PV}_${XABI}.cxz
  #printf %s\n' ** | cpio -H newc -o | zstd -f -o ../../pkg/${PN}_${PV}_${XABI}.czst
}