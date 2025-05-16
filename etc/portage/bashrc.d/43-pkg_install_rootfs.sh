#!/bin/bash
# Copyright (C) 2021-2022 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html


[[ -d ${INSTALL_DIR} ]] || exit
cd "${INSTALL_DIR}/"

PV+="-$(date '+%Y%m%d-p%H')"
# create dirs,files (system)
((UID)) || return 0

mkdir -pm '0755' {bin,dev}/ var/{log,lib/misc}/

umask u=rwx,g=rwx,o=rwx
mkdir -pm '1777' {dev/shm,tmp}/
mkdir -pm '0777' 'run/'
> var/log/profile.log
umask u=rwx,g=rx,o=rx

ln -sf /proc/self/fd/0   'dev/stdin'
ln -sf /proc/self/fd/1   'dev/stdout'
ln -sf /proc/self/fd/2   'dev/stderr'
ln -sf /proc/self/mounts 'etc/mtab'
ln -sf bash              'bin/sh'

ln -sf /proc/self/fd     'dev/fd'
ln -sf /run              'var/run'