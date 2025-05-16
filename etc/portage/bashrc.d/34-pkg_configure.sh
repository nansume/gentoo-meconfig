#!/bin/bash
# Copyright (C) 2021 Artem Slepnev, Shellgen
# License GPLv3+: GNU GPL version 3 or later
# http://gnu.org/licenses/gpl.html


((UID)) && {
cd ${WORKDIR}/

./configure \
  --prefix= \
  --libdir="/${LIB_DIR}" \
  --includedir="${DPREFIX}/include" \
  --libexecdir="${DPREFIX}/libexec" \
  --datarootdir="${DPREFIX}/share" \
  --disable-rpath \
  --disable-nls \
  --disable-extensions \
  --disable-mpfr \
  --without-readline
}