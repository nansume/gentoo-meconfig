#!/lib/shell/env bash
# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2


if [[ ${EBUILD_PHASE-} == setup ]]; then
   if declare -F before_pkg_$EBUILD_PHASE &> /dev/null; then
      # error - color: red
      printf " \e[;31m++\e[m \e[1;37mbefore_pkg_$EBUILD_PHASE\e[m... \e[1;31merror\e[m\n"
      return 1
   else
      before_pkg_setup() {
         unset -f $FUNCNAME
# ABI=$DEFAULT_ABI
# CHOST=${CHOST_amd64}
# CHOST_default=${CHOST_amd64}
# CBUILD=${CHOST_default}
CFLAGS=$CFLAGS\ ${CFLAGS_amd64}
# CTARGET_default=${CHOST_default}
# PKG_CONFIG_PATH='/usr'/${LIBDIR_amd64}/'pkgconfig'

#BITS=$ABI_X86
#CFLAGS_default=${CFLAGS_amd64}
CXXFLAGS=$CXXFLAGS\ ${CFLAGS_amd64}
#LDFLAGS_default=${LDFLAGS_amd64}
LDFLAGS=$LDFLAGS\ ${CFLAGS_amd64}

# declare -x ABI_DEFAULT="x32"
# declare -x DEFAULT_ABI="amd64"
#
# declare -x CHOST="x86_64-pc-linux-gnux32"
# declare -x CHOST_amd64="x86_64-pc-linux-gnu"
# declare -x CHOST_default="x86_64-pc-linux-gnux32"
#
# declare -x CBUILD="x86_64-pc-linux-gnux32"
#
# declare -x CFLAGS="-O2 -msse -ftree-vectorize -g0 -msse2 -msse3"
# declare -x CFLAGS_amd64="-m64"
# declare -x CFLAGS_default
#
# declare -x CTARGET_default="x86_64-pc-linux-gnux32"
#
# declare -x KERNEL_ABI="amd64"
#
# declare -x LDFLAGS_amd64="-m elf_x86_64"
# declare -x LDFLAGS_default

         # color: green
         printf " \e[1;3m+\e[m ${BASH_SOURCE##*/}\n"
      }
   fi
fi