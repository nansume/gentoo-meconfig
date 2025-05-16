#!/lib/shell/env bash5
# Copyright (C) 2019 Artem Slepnev, Shellgen
# License GPLv3+: GNU GPL version 3 or later
# gnu.org/licenses/gpl.html



if [[ ${EBUILD_PHASE-} == setup || ${EBUILD_PHASE-} == _install ]]; then
   if [[ $MULTILIB_ABIS == *x86*x32 ]]; then
      abi_x86_32() {
         declare -grx DEFAULT_ABI=x86
         declare -grx ABI=$DEFAULT_ABI
         declare -grx ABI_X86=32
         declare -grx BITS=$ABI_X86
         declare -grx MULTILIB_ABIS=$DEFAULT_ABI
         declare -grx CFLAGS_default=${CFLAGS_x86}
         declare -grx CFLAGS+=\ ${CFLAGS_default}
         declare -grx CXXFLAGS+=\ ${CFLAGS_default}
         declare -grx LDFLAGS_default=${LDFLAGS_x86}
         declare -grx LDFLAGS+=\ ${CFLAGS_default}
         declare -grx CHOST_default=${CHOST_x86}
         declare -grx CHOST=$CHOST_default
         declare -grx CBUILD=$CHOST
         declare -grx CTARGET_default=$CBUILD
         declare -grx CTARGET=${CTARGET_default}
         declare -grx LIBDIR_default=${LIBDIR_x86}

         # dev-java/javatoolkit-0.3.0-r9: libx32 => lib
         #declare -grx LIBDIR_x32=${LIBDIR_x86}

         declare -gx LD_LIBRARY_PATH=/usr/${LIBDIR_default}
      }


      if declare -F before_pkg_$EBUILD_PHASE &> /dev/null; then
         # error - color: red
         printf " \e[;31m++\e[m \e[1;37mbefore_pkg_$EBUILD_PHASE\e[m... \e[1;31merror\e[m\n"
         return 1
      else
         before_pkg_setup() {
            unset -f $FUNCNAME
            abi_x86_32 || return
            # color: green
            printf " \e[1;3m+\e[m ${BASH_SOURCE##*/}\n"
            unset -f abi_x86_32
            unset -v ENV_NAME ABIS_LIST PACKAGE
         }

         #INHERITED+=' multilib-minimal'

         # java-service-wrapper-3.5.25-r1
         # USE=amd64 - replace force
         # bug: BITS=32 => BITS=64
         # fix: remove - USE flag
         USE=${USE/amd64 /}
      fi
      if declare -F _after_src_$EBUILD_PHASE &> /dev/null; then
         # error - color: red
         printf " \e[;31m++\e[m \e[1;37mafter_src_$EBUILD_PHASE\e[m... \e[1;31merror\e[m\n"
         return 1
      else
         _after_src_install() {
            unset -f $FUNCNAME
            if [[ -d ${ED}/usr/libx32/ && -d ${ED}/usr/lib/ ]]; then
               declare PWD=$PWD OLDPWD=$OLDPWD
               set +o noglob
               cd ${ED}/usr/lib/
               #mv -v --no-clobber ${ED}/usr/libx32/* ${ED}/usr/lib/
               #rm --dir ${ED}/usr/libx32/
               #ln -vP ${ED}/usr/libx32/* ${ED}/usr/lib/
               ln -vs ../libx32/* ${ED}/usr/lib/
               cd $OLDPWD/
               printf " \e[;31m++\e[m \e[1;37mabi=32 libx32\e[m... \e[1;31merror\e[m\n"
               set -o noglob
            fi
            # color: green
            printf " \e[1;3m+\e[m ${BASH_SOURCE##*/}\n"
         }
      fi
   fi
fi