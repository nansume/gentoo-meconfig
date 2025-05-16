#!/lib/shell/env bash5
# Copyright (C) 2020 Artem Slepnev, Shellgen
# License GPLv3: GNU GPL version 3



declare EMERGE_ENV_DIR=${BASH_SOURCE##*/}
        EMERGE_ENV_DIR=${EMERGE_ENV_DIR%.*}
        EMERGE_ENV_DIR="${EMERGE_ENV_DIR#??-}.env"

if [[ -d "${PORTAGE_CONFIGROOT%/}/$OVERLAY_DIR/profiles/$EMERGE_ENV_DIR/" ]]; then
   _PackageList() {
      local -r ENV_NAME=${1%.*}
      local -r FILE="/$OVERLAY_DIR/profiles/lst.d/$ENV_NAME"

      if [[ ${PACKAGES_LIST[0]-} ]]; then
         unset -v PACKAGES_LIST
      fi

      if [[ -r $FILE ]]; then
         IFS=$'\n' mapfile -ts '0' -n '100' -d $'\n' PACKAGES_LIST < $FILE || return
      else
         PACKAGES_LIST=$CATEGORY/$PN
      fi
   }


   _PackageEnv() {
      local PACKAGE

      # fix: variables package name - force load
      if [[ ! ${SLOT-} && -f /etc/vars.d/portage ]]; then
         local SLOT _SLOT
         mapfile -tn '1' -d $'\n' _SLOT < /etc/vars.d/portage || return
         #source /etc/vars.d/portage || return
         if [[ ${_SLOT-} ]]; then
            SLOT=${_SLOT#*=}
            unset -v _SLOT
         else
            SLOT='0'
         fi
      fi

      [[ $BASHOPTS == *'nullglob'* ]] || shopt -s nullglob
      #[[ $SHELLOPTS == *noglob* ]] && set +o noglob
      [[ $SHELLOPTS == *'noglob'* ]] || set -o noglob
      for PACKAGE in ${PACKAGES_LIST[*]}; {
         [[ $SHELLOPTS == *'noglob'* ]] || set -o noglob
         [[ $BASHOPTS == *'nullglob'* ]] && shopt -u nullglob
         #if [[ $PACKAGE != #'* && $ENV_NAME == *30-cpumax ]]; then
         #   declare -p PACKAGE
         #fi
         case $PACKAGE in
            #*/*'|\
            $CATEGORY/$PN|\
            $CATEGORY/$PN:${SLOT%/*}|\
            $CATEGORY/${PN}-${PV}|\
            $CATEGORY/${PN}-${PVR})
               source $ENV_NAME || return
               #if [[ ${EBUILD_PHASE-} == setup ]]; then
               #   # ok - color: green
               #   printf " \e[1;32m+\e[m package.env: ${PACKAGE#*/}... ${ENV_NAME##*/}\n"
               #fi
               break
            ;;
         esac
      }
      # fix: ebuild phase [post] - failed
      [[ $BASHOPTS == *'nullglob'* ]] || shopt -s nullglob

      [[ $SHELLOPTS == *'noglob'* ]] || set -o noglob
      # fix - comment str: ebuild phase [post] - failed
      #[[ $BASHOPTS == *nullglob* ]] && shopt -u nullglob
   }


   _PackagesEnvLoad() {
      unset -f $FUNCNAME

      local PACKAGES_LIST ENV_NAME

      [[ $BASHOPTS == *'nullglob'* ]] || shopt -s nullglob
      [[ $SHELLOPTS == *'noglob'* ]] && set +o noglob

      for ENV_NAME in ${PORTAGE_CONFIGROOT%/}/$OVERLAY_DIR/profiles/$EMERGE_ENV_DIR/*; {
         [[ $SHELLOPTS == *'noglob'* ]] || set -o noglob
         [[ $BASHOPTS == *'nullglob'* ]] && shopt -u nullglob
         if [[ -f $ENV_NAME ]]; then
            _PackageList ${ENV_NAME##*/} || return
            _PackageEnv || return
         fi
         # fix: ebuild phase [post] - failed
         [[ $BASHOPTS == *'nullglob'* ]] || shopt -s nullglob
      }
      [[ $SHELLOPTS == *'noglob'* ]] || set -o noglob
      [[ $BASHOPTS == *'nullglob'* ]] && shopt -u nullglob
   }



   _PackagesEnvLoad || return

   unset -f _PackagesList _PackageEnv
   unset -v EMERGE_ENV_DIR
fi