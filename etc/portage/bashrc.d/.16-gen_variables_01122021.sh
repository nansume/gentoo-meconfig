#!/bin/bash
# Copyright (C) 2021 Artem Slepnev, Shellgen
# License GPLv3+: GNU GPL version 3 or later
# http://gnu.org/licenses/gpl.html


((UID)) && {
   for F in \
    '/lib/shell/profile.d/'*'-ldpath_apply.sh' \
    '/lib/shell/profile.d/'*'-path_apply.sh' \
    '/lib/shell/profile.d/'*'-bash_profile_tools.sh'; {
      source ${F}; F="${F##*-}"; _${F%.sh}
   }
   shopt -uo 'noglob'

   CBUILD=${CHOST}
   CTARGET=${CHOST}

   case ${HOSTTYPE} in
      'x86_64')
         GCC_INCDIR="/usr/lib/gcc/${CHOST}/${GCC_VER}/include"
      ;;
   esac

   declare -x CBUILD CTARGET
}