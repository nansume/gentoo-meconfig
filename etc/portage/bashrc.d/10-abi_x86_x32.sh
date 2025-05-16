#!/lib/shell/env bash5
# Copyright (C) 2019 Artem Slepnev, Shellgen
# License GPLv3+: GNU GPL version 3 or later
# gnu.org/licenses/gpl.html



if [[ ${EBUILD_PHASE-} == setup && ${OLD_EBUILD_PHASE-} != ${EBUILD_PHASE-} ]]; then
   if [[ $MULTILIB_ABIS == amd64*x32 ]]; then
      abi_x86_x32() {
         unset -f $FUNCNAME

         declare -grx ABI_X86=$DEFAULT_ABI
         declare -grx MULTILIB_ABIS=$DEFAULT_ABI
         declare -grx CFLAGS_default=${CFLAGS_x32}
         declare -grx CFLAGS+=\ ${CFLAGS_default}
         declare -grx CXXFLAGS+=\ ${CFLAGS_default}
         declare -grx LDFLAGS_default=${LDFLAGS_x32}
         declare -grx LDFLAGS+=\ ${CFLAGS_default}
         declare -grx CHOST_default=${CHOST_x32}
         declare -grx CTARGET_default=$CBUILD
         declare -grx LIBDIR_default=${LIBDIR_x32}
         declare -grx LD_LIBRARY_PATH=/usr/${LIBDIR_default}
      }


      _AbisList() {
         unset -f $FUNCNAME

         ENV_NAME=${1:-$ENV_NAME}
         declare -r FILE=/$OVERLAY_DIR/profiles/lst.d/$ENV_NAME

         if [[ -r $FILE ]]; then
            IFS=$'\n' mapfile -tn 50 -d $'\n' ABIS_LIST < $FILE
         fi
      }



      ENV_NAME=${BASH_SOURCE##*/}
      ENV_NAME=${ENV_NAME%.*}

      _AbisList
      for PACKAGE in ${ABIS_LIST[*]}; {
         case $PACKAGE in
            $CATEGORY/$PN:$SLOT)
               $ENV_NAME
               # color: green
               printf " \e[1;3m+\e[m $BASH_SOURCE\n"
            ;;
         esac
      }
      unset -v ENV_NAME ABIS_LIST PACKAGE
   fi
fi