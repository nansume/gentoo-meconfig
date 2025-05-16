#!/bin/bash
# Copyright (C) 2021-2022 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html


((UID)) && return
cd "${INSTALL_DIR}/"

[[ -c dev/console ]] || mknod -m 0600 'dev/console' c 5 1
[[ -c dev/null    ]] || mknod -m 0666 'dev/null'    c 1 3
[[ -c dev/urandom ]] || mknod -m 0444 'dev/urandom' c 1 9