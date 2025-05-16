#!/bin/bash
# Copyright (C) 2019-2023 Artjom Slepnjov, Shellgen

# ccache noclean
#MAKEOPTS=-j1
BUILD_TMPDIR='/var/tmp/build'
CCACHE_DIR="${BUILD_TMPDIR}/ccache"
CCACHE_SIZE="3.0G"
#CCACHE_SIZE=1.0G
#CCACHE_SIZE"0.4G
BUILD_TMPDIR='/var/tmp/tmp-noram'