#!/lib/shell/env bash5
# Copyright (C) 2020 Artem Slepnev, Shellgen
# License GPLv3: GNU GPL version 3



source /lib/shell/so 'profile' 'evar' || exit

# phase:
#
#   'die_hooks' - ?
#
#  EBUILD_PHASE:      'clean'
#
#  EBUILD_PHASE:      'depend'
#
#  EBUILD_PHASE:      'pretend'     [eapi=5]
#  EBUILD_PHASE_FUNC: 'pkg_pretend' [eapi=5]
#
#  EBUILD_PHASE:      'nofetch'
#
#   '${PORTAGE_CONFIGROOT%/}/$OVERLAY_DIR/profiles/profile.bashrc'


# phase: 'pretend' - variables [eapi=5]
#  declare -x ECLASSDIR="/usr/portage/gentoo/eclass"
#  declare -x PORTDIR="/usr/portage/gentoo"

# phase: 'pretend' 'setup' - variables '[eapi=5] - [eapi=7]'
#  declare -x A="portage-2.3.67.tar.bz2"
#  declare -x BASH_ENV="/etc/spork/is/not/valid/profile.env"
#  declare -x D="/var/tmp/portage/sys-apps/portage-2.3.67/image/"
#  declare -x DISTDIR="/var/tmp/portage/sys-apps/portage-2.3.67/distdir"
#  declare -x EBUILD_PHASE_FUNC="pkg_pretend"
#  declare -x ED="/var/tmp/portage/sys-apps/portage-2.3.67/image/"
#  declare -x EMERGE_FROM="ebuild"
#  declare -x FILESDIR="/var/tmp/portage/sys-apps/portage-2.3.67/files"
#  declare -x MERGE_TYPE="buildonly"
#  declare -x PKGUSE=""
#  declare -x PM_EBUILD_HOOK_DIR="/etc/portage/env"
#  declare -x PORTAGE_ACTUAL_DISTDIR="/usr/local/distfiles"
#  declare -x PORTAGE_BASHRC="/etc/portage/bashrc"
#  declare -x PORTAGE_BASHRC_FILES="/$OVERLAY_DIR/profiles/profile.bashrc"
#  declare -x PORTAGE_BUILDDIR="/var/tmp/portage/sys-apps/portage-2.3.67"
#  declare -x PORTAGE_BUILD_GROUP="portage"
#  declare -x PORTAGE_BUILD_USER="portage"
#  declare -x PORTAGE_ECLASS_LOCATIONS="/usr/portage/gentoo"
#  declare -x PORTAGE_TMPDIR="/var/tmp"
#  declare -x PORTAGE_XATTR_EXCLUDE="btrfs.* security.evm"
#  declare -x PR="r0"
#  declare -x PV="2.3.67"
#  declare -x PVR="2.3.67"
#  declare -x RPMDIR="/usr/portage/rpm"
#  declare -x T="/var/tmp/portage/sys-apps/portage-2.3.67/temp"
#  declare -x WORKDIR="/var/tmp/portage/sys-apps/portage-2.3.67/work"



# $PRE_EBUILD_PHASE
if [[ -s "${PORTAGE_CONFIGROOT%/}/etc/vars.d/portage_pre_phase" ]]; then
   source ${PORTAGE_CONFIGROOT%/}/etc/vars.d/portage_pre_phase
   > ${PORTAGE_CONFIGROOT%/}/etc/vars.d/portage_pre_phase
fi

if ! declare -F _BashRcLoad &> /dev/null; then
   ###############################################################################
   # load bashrc file env
   ###############################################################################
   _BashRcLoad() {
      local _FILE

      [[ $SHELLOPTS == *'noglob'* ]] && set +o noglob

      if [[ -d "${PORTAGE_CONFIGROOT%/}/$OVERLAY_DIR/profiles/bashrc.d/" ]]; then
         for _FILE in ${PORTAGE_CONFIGROOT%/}/$OVERLAY_DIR/profiles/bashrc.d/*; {
            [[ $SHELLOPTS == *'noglob'* ]] || set -o noglob
            if [[ -r $_FILE ]]; then
               source $_FILE || return
            fi
         }
      fi
      [[ $SHELLOPTS == *'noglob'* ]] || set -o noglob
   }
   ###############################################################################

   # phase: pre_setup
   #if [[ ${EBUILD_PHASE-} == setup && ${OLD_EBUILD_PHASE-} != ${EBUILD_PHASE-} ]]; then
   if [[ ${EBUILD_PHASE-} == 'setup' ]]; then
      if (( UID == '0' )) && [[ -O /tmp/emerge.log ]]; then
         chown -v $PORTAGE_BUILD_USER:$PORTAGE_BUILD_GROUP /tmp/emerge.log
      fi
   fi

   case ${EBUILD_PHASE-} in
      'depend')
         printf " \e[1;32m+\e[m depend: $CATEGORY/\e[1;33m$PN\e[m\n"
      ;;
      'setup'|'preinst')
         _MountShm() {
            unset -f $FUNCNAME
            declare MOUNTLIST
            mapfile -ts '0' -n '60' -d $'\n' MOUNTLIST < /proc/mounts || return
            if [[ ${MOUNTLIST[*]} == *'/dev/zram0 / '* ]]; then
               if [[ ${MOUNTLIST[*]} == *'shm /dev/shm '* ]]; then
                  umount /dev/shm/
               else
                  [[ -d /dev/shm/ ]] || mkdir --mode=1777 /dev/shm/
                  if [[ ${MOUNTLIST[@]} == *'tmpfs / '* ]]; then
                     mount -nit tmpfs -o noatime,noexec,nosuid,nodev,mode=1777,size=10% shm /dev/shm/
                  else
                     mount -nit tmpfs -o noatime,noexec,nosuid,nodev,mode=1777 shm /dev/shm/
                  fi
               fi
            fi
         }


         if (( UID == '0' )); then
            if [[ -G /etc/ld.so.conf ]]; then
               chown -v :$PORTAGE_BUILD_GROUP /etc/ld.so.conf
               chmod -v 0640 /etc/ld.so.conf
            fi
         fi
      ;;
   esac
fi


# EAPI=6: EBUILD_PHASE=pretend remove
#  replace: pretend => setup
case ${EBUILD_PHASE-} in
   'pretend')
      if declare -F pre_pkg_$EBUILD_PHASE &> /dev/null; then
         # error - color: red
         printf " \e[;31m++\e[m pre_pkg_$EBUILD_PHASE... \e[1;31merror\e[m\n"
         return 1
      else
         pre_pkg_pretend() {
            unset -f $FUNCNAME
            # check_devpts - disable
            check_devpts() {
               # ok - color: green
               printf " \e[1;32m+\e[m check_devpts... \e[1;33mdisable\e[m\n"
            }

            if ! [[ ${PORTAGE_COLORMAP-} ]]; then
               if [[ -s ${PORTAGE_CONFIGROOT%/}/$OVERLAY_DIR/'profiles/color.map' ]]; then
                  #PORTAGE_COLORMAP=$'GOOD=$\'\E[32;01m\'\nWARN=$\'\E[33;01m\'\nBAD=$\'\E[31;01m\''
                  mapfile -ts '0' -n '20' -d $'\n' PORTAGE_COLORMAP < ${PORTAGE_CONFIGROOT%/}/$OVERLAY_DIR/'profiles/color.map'
                  declare -grx PORTAGE_COLORMAP
                  # ok - color: green
                  printf " \e[1;32m+\e[m color.map \e[;33muser\e[m... \e[1;33mok\e[m\n"
               fi
            fi
            # ok - color: green
            printf " \e[1;32m+\e[m pre_pkg_$EBUILD_PHASE... \e[1;33mok\e[m\n"
         }
      fi
   ;;
   'pretend'|'depend'|'setup')
      if ! [[ ${OVERLAY_DIR-} ]]; then
         declare -grx OVERLAY_DIR
      fi

      if [[ ${SLOT-} ]]; then
         # fix: variables $SLOT save
         #  phase 'setup' after remove $SLOT
         #printf SLOT=$SLOT > /etc/vars.d/portage || return
         _VarWrite "_SLOT=$SLOT" portage || return

         # ok - color: green
         printf " \e[1;32m+\e[m \e[1;36m$BASH_SOURCE\e[m\n"
      else
         #printf SLOT=0 > /etc/vars.d/portage || return
         _VarWrite '_SLOT=0' portage || return
         # error - color: red
         printf " \e[;31m++\e[m variables \$SLOT \e[1;33msave\e[m... \e[1;31merror\e[m\n"
      fi
   ;;
esac


# ok - color: green
printf " \e[1;32m+\e[m EBUILD_PHASE: \e[1;33m${EBUILD_PHASE:-empty}\e[m\n"
if _BashRcLoad; then

   trap '
      #if [[ ${BASH_ARGV-} == die_hooks ]]; then
      #${S%/work/*}/.exit_status
      if [[ -e "${T%/temp}/.die_hooks" ]]; then
         if declare -F _GccVerSwitch &> /dev/null; then
            _GccVerSwitch '9'
            unset -f _GccVerSwitch
         fi
         if declare -F _RouteDefault &> /dev/null; then
            _RouteDefault
         fi
         if declare -F _UnbindClean &> /dev/null; then
            PYTHON_SLOT='3.7'
            for MOUNTPOINT in \
             /usr/include/{openssl,unicode}/ \
             /usr/lib/python${PYTHON_SLOT}/ \
             /usr/bin/python${PYTHON_SLOT}m-config \
             /usr/bin/python${PYTHON_SLOT}m
            {
               _UnbindClean $MOUNTPOINT
            }
            unset -f _UnbindClean
         fi
         if declare -F _CpuSetDefault &> /dev/null; then
            _CpuSetDefault
         fi
         if [[ -e "${T%/temp}/.die_hooks" || -e "${T%/temp}/.exit_status" ]]; then
            if [[ ${PORTAGE_LOG_FILE-} && -s $PORTAGE_LOG_FILE ]]; then
               cp -p "$PORTAGE_LOG_FILE" "/tmp/${PN}_build_$RANDOM.log"
            fi
         fi
         > "${PORTAGE_CONFIGROOT%/}/etc/vars.d/portage_pre_phase"

         #mapfile -s 0 -n 110 MOUNTLIST < /proc/mounts
         #if [[ ${MOUNTLIST[*]} == *" /usr/share $FSTYPE rw,"* ]]; then
         #   if mount -o remount,ro /usr/share/; then
         #      printf " \e[1;32m+\e[m \e[1;37mmount\e[m -o remount,\e[1;35mro\e[m \e[1;34mlocal filesystem\e[m... \e[1;33mok\e[m\n"
         #   fi
         #fi
         if declare -F _PostRemount &> /dev/null; then
            _PostRemount
         fi
      fi
   ' EXIT

   printf " \e[1;32m+\e[m _BashRcLoad... \e[1;33mok\e[m\n"
else
   # error - color: red
   printf " \e[;31m++\e[m _BashRcLoad... \e[1;31merror\e[m\n"
   return 1
fi


case ${EBUILD_PHASE:-empty} in
   'pretend'|'depend'|'setup')
      declare -p > /tmp/ebuild_$EBUILD_PHASE.log
   ;;
   'install'|'preinst'|'empty')
      if [[ ${INSTALL_MASK-} ]]; then
         INSTALL_MASK=${INSTALL_MASK// /}
      fi
      if [[ ${PKG_INSTALL_MASK-} ]]; then
         PKG_INSTALL_MASK=${PKG_INSTALL_MASK// /}
      fi
   ;;
esac

case ${EBUILD_PHASE:-empty} in
   'clean'|'empty')
   ;;
   *)
      PRE_EBUILD_PHASE=$EBUILD_PHASE
      printf PRE_EBUILD_PHASE=$PRE_EBUILD_PHASE \
       > ${PORTAGE_CONFIGROOT%/}/etc/vars.d/portage_pre_phase
      chown -v $PORTAGE_BUILD_USER:$PORTAGE_BUILD_GROUP \
       ${PORTAGE_CONFIGROOT%/}/etc/vars.d/portage_pre_phase
   ;;
esac
case ${EBUILD_PHASE-} in
   'package'|'postinst')
      #${S%/work/*}/.compile
      #if [[ -e ${T%/temp}/.instprepped ]]; then
      if [[ -e "${T%/temp}/.installed" ]]; then
         if [[ ${PORTAGE_LOG_FILE-} && -s $PORTAGE_LOG_FILE ]]; then
            cp -p "$PORTAGE_LOG_FILE" "/tmp/${PN}_build_$RANDOM.log"
         fi
      fi
   ;;
esac


[[ $SHELLOPTS == *'nounset'* ]] && set +o nounset
[[ $SHELLOPTS == *'noglob'* ]] && set +o noglob
[[ $SHELLOPTS == *'errexit'* ]] && set +o errexit
[[ $BASHOPTS == *'inherit_errexit'* ]] && shopt -u inherit_errexit
# fix: unpack zip - fail
[[ $SHELLOPTS == *'pipefail'* ]] && set +o pipefail
# meson.build:21:0: ERROR:
#  Options "radeonsi$'\n'swrast" are not in allowed choices: , auto, kmsro,
[[ $BASHOPTS == *'extquote'* ]] || shopt -s extquote