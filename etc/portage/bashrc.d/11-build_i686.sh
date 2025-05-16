#!/lib/shell/env bash5
# Copyright (C) 2019 Artem Slepnev, Shellgen
# License GPLv3+: GNU GPL version 3 or later
# gnu.org/licenses/gpl.html



if [[ ${EBUILD_PHASE-} == setup ]]; then
   if [[ $MULTILIB_ABIS == *x86*x32 ]]; then
      build_i686() {
         declare -grx ABI=x86
         declare -grx CHOST=${CHOST_x86}
         declare -grx CBUILD=$CHOST
         declare -grx CTARGET=${CTARGET_default}
      }


      if declare -F before_pkg_$EBUILD_PHASE &> /dev/null; then
         # error - color: red
         printf " \e[;31m++\e[m \e[1;37mbefore_pkg_$EBUILD_PHASE\e[m... \e[1;31merror\e[m\n"
         return 1
      else
         before_pkg_setup() {
            unset -f $FUNCNAME
            build_i686 || return
            # color: green
            printf " \e[1;3m+\e[m ${BASH_SOURCE##*/}\n"
            unset -f build_i686
         }
      fi
   fi
fi