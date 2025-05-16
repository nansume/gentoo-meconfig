#!/lib/shell/env bash5
# Copyright (C) 2019 Artem Slepnev, Shellgen
# License GPLv3: GNU GPL version 3



_OsDirVariables() {
   return 1
   if [[ -f ${PORTAGE_CONFIGROOT%/}/etc/vars.d/emerge ]]; then
      source /lib/shell/variable emerge
   fi

   declare -r IFS=$'\n'
   #declare FSTYPE='nilfs2'
   #if ! [[ ${MOUNTPOINT-} ]]; then
      declare MOUNTPOINT
      [[ $BASHOPTS == *nullglob* ]] || shopt -s nullglob
      [[ $SHELLOPTS == *noglob* ]] && set +o noglob

      for MOUNTPOINT in /mnt/*; {
         continue
      }
      MOUNTPOINT=${MOUNTPOINT#/mnt/}
      [[ ${MOUNTPOINT-} ]] || return

      if [[ -d /mnt/${MOUNTPOINT}/ ]]; then
         read -esn 7 -p 'mount point - name? enter(sda|mmcblk0) MOUNTPOINT=' -i /mnt/${MOUNTPOINT} MOUNTPOINT
         if [[ ${MOUNTPOINT-} ]]; then
            MOUNTPOINT=${MOUNTPOINT%/}
            MOUNTPOINT=${MOUNTPOINT##*/}
            [[ ${MOUNTPOINT-} ]] || return
         fi
      fi
      _VarWrite MOUNTPOINT=$MOUNTPOINT emerge
   #fi
   [[ ${MOUNTPOINT-} ]] || return

   if [[ -d /mnt/${MOUNTPOINT}/ ]]; then
      declare OSDIR
      for OSDIR in /mnt/${MOUNTPOINT}/osdir/*; {
         break
      }
      read -esn 150 -p "os dir - path? enter($OSDIR|/mnt/$MOUNTPOINT/osdir/gentoo_x86) OSDIR=" -i ${OSDIR} OSDIR
      [[ ${OSDIR-} ]] || return
      _VarWrite OSDIR=$OSDIR emerge
   else
      return
   fi
   [[ $SHELLOPTS == *noglob* ]] || set -o noglob
   [[ $BASHOPTS == *nullglob* ]] && shopt -u nullglob
}


_PkgDbSync() {
   unset -f $FUNCNAME
   if [[ -e ${T%/temp}/.instprepped && ${PRE_EBUILD_PHASE-} == after_postinst ]]; then
      [[ ${MOUNTPOINT-} ]] || return
      [[ ${OSDIR-} ]] || return
      mount -io remount,rw /mnt/$MOUNTPOINT/
      rsync -avHx --delete-after /var/db/pkg/ $OSDIR/var/db/pkg/
      sync
      printf " \e[1;32m+\e[1;37m rsync\e[m -avHx\e[1;35m --delete-after \e[1;34m/var/db/pkg/ \e[1;31m$OSDIR\e[m/var/db/pkg/\e[m... \e[1;33mok\e[m\n"
      mount -io remount,ro /mnt/$MOUNTPOINT/
   fi
}


_PostRemount() {
   unset -f $FUNCNAME
   declare -r IFS=$'\n'

   if [[ -e ${T%/temp}/.instprepped && ${PRE_EBUILD_PHASE-} == postinst ]]; then
      printf 'PRE_EBUILD_PHASE=after_postinst' > ${PORTAGE_CONFIGROOT%/}/etc/vars.d/portage_pre_phase
   fi
   if ! [[ ${MOUNTPOINT-} ]]; then
      #_OsDirVariables
      if [[ -f ${PORTAGE_CONFIGROOT%/}/etc/vars.d/portage ]]; then
         source /lib/shell/variable portage
      else
         return
      fi
   fi
   [[ ${MOUNTPOINT-} ]] || return
   [[ ${OSDIR-} ]] || return
   #elif [[ -e ${T%/temp}/.instprepped && ${PRE_EBUILD_PHASE-} == after_postinst ]]; then
   if [[ ${PRE_EBUILD_PHASE-} == after_postinst || -e ${T%/temp}/.die_hooks || ${EBUILD_PHASE-} == cleanrm ]]; then
      declare MOUNTLIST STRING
      mapfile -ts 2 -n 110 MOUNTLIST < /proc/mounts
      for STRING in ${MOUNTLIST[*]}; {
         #umount /var/db/pkg/
         if [[ $STRING == *' /usr/share '* && $STRING != *'noexec,'* ]]; then
            if mount -io remount,noexec /usr/share/; then
               printf " \e[1;32m+ \e[1;37mmount\e[m -o remount,\e[1;35mnoexec \e[1;34m/usr/share/\e[m... \e[1;33mok\e[m\n"
            fi
         fi
         #if [[ ${MOUNTLIST[*]} == *" /usr/share $FSTYPE rw,"* ]]; then
         if [[ $STRING == *' /usr/share '*'rw,'* ]]; then
            #sleep 6.0s
            sync
            #sleep 0.6s
            if mount -io remount,ro /usr/share/ || true; then
               printf " \e[1;32m+ \e[1;37mmount\e[m -o remount,\e[1;35mro \e[1;34mlocal filesystem\e[m... \e[1;33mok\e[m\n"
               _PkgDbSync
            else
               return
            fi
         fi
      }
   fi
}


_InstallRemount() {
   unset -f $FUNCNAME
   declare -r IFS=$'\n'
   declare MOUNTPOINT OSDIR MOUNTLIST STRING
   #MOUNTPOINT='sdb'
   #OSDIR='/mnt/'$MOUNTPOINT'/osdir/gentoo_x32_multilib'
   #mount -o bind,ro,noexec,nosuid,nodev $OSDIR/var/db/pkg/ /var/db/pkg/
   mapfile -ts 2 -n 110 MOUNTLIST < /proc/mounts

   for STRING in ${MOUNTLIST[*]}; {
      if [[ $STRING == *' /usr/share '*'ro,'* ]]; then
         if mount -io remount,rw /usr/share/; then
            printf " \e[1;32m+ \e[1;37mmount\e[m -o remount,\e[1;35mrw \e[1;34mlocal filesystem\e[m... \e[1;33mok\e[m\n"
         fi
      fi
      #if [[ $STRING == *' /usr/share '* && $STRING != *'noexec,'* ]]; then
      #   if mount -io remount,noexec /usr/share/; then
      #      printf " \e[1;32m+ \e[1;37mmount\e[m -o remount,\e[1;35mnoexec \e[1;34m/usr/share/\e[m... \e[1;33mok\e[m\n"
      #   fi
      #fi
   }
}


#_OsDirVariables
if [[ -f ${PORTAGE_CONFIGROOT%/}/etc/vars.d/portage ]]; then
   source /lib/shell/variable portage
else
   return
fi
[[ ${MOUNTPOINT-} ]] || return
[[ ${OSDIR-} ]] || return

case ${EBUILD_PHASE:-empty} in
   clean)
      #declare -p > /tmp/${PN}_${EBUILD_PHASE}_$RANDOM.log
      #printf "$PORTAGE_ACTUAL_DISTDIR/${A%% *}\n"
      if ! [[ ${A-} ]]; then
         printf " \e[;31m+ \e[1;35mvariables [empty]: \${A}\e[m... \e[1;31merror\e[m\n"
      elif [[ ! -e ${T%/temp}/.setuped && ! -f $PORTAGE_ACTUAL_DISTDIR/${A%% *} ]]; then
         _DistDirRemount() {
            unset -f $FUNCNAME
            declare -r IFS=$'\n'
            declare MOUNTLIST STRING
            #printf " \e[1;32m+ \e[1;37m$PORTAGE_ACTUAL_DISTDIR/${A%% *}\e[m... \e[1;33mok\e[m\n"
            mapfile -ts 2 -n 110 MOUNTLIST < /proc/mounts
            for STRING in ${MOUNTLIST[*]}; {
               #declare -p STRING
               if [[ $STRING == *' /usr/local/distfiles '*'ro,'* ]]; then
               #if [[ ${MOUNTLIST[*]} == *" /usr/local/distfiles $FSTYPE ro,"* ]]; then
                  if mount -io remount,rw /usr/local/distfiles/ || true; then
                     printf " \e[1;32m+ \e[1;37mmount\e[m -o remount,\e[1;35mrw \e[1;34mlocal filesystem\e[m... \e[1;33mok\e[m\n"
                     printf " \e[1;32m+ \e[1;37mmount\e[m -o remount,\e[1;35mrw \e[1;34m/usr/local/distfiles/\e[m... \e[1;33mok\e[m\n"
                     #declare -p > /tmp/${PN}_${EBUILD_PHASE}_$RANDOM.log
                  else
                     return
                  fi
                  break
               fi
            }
         }
         _DistDirRemount
      #elif [[ -e ${T%/temp}/.instprepped && ! -e ${T%/temp}/.exit_status ]]; then
      elif [[ -e ${T%/temp}/.instprepped && ${PRE_EBUILD_PHASE-} == postinst ]]; then
         #rsync -avHx --delete-after /var/db/pkg/ $OSDIR/var/db/pkg/
         #printf " \e[1;32m+\e[1;37m rsync\e[m -avHx\e[1;35m --delete-after \e[1;34m/var/db/pkg/ \e[1;31m$OSDIR\e[m/var/db/pkg/\e[m... \e[1;33mok\e[m\n"
         _PkgDbSync
      #else
      #   declare -p > /tmp/ebuild_$EBUILD_PHASE.log
      #   return 1
      fi
   ;;
   setup)
      _SetupRemount() {
         unset -f $FUNCNAME
         declare -r IFS=$'\n'
         declare MOUNTLIST STRING
         mapfile -ts 2 -n 110 MOUNTLIST < /proc/mounts

         for STRING in ${MOUNTLIST[*]}; {
            if [[ $STRING == *' /usr/local/distfiles '*'rw,'* ]]; then
               # bug: sleep =< 5.0s - mount point is busy
               #sleep 6.0s
               sync
               #sleep 0.6s
               if mount -io remount,ro /usr/local/distfiles/ || mount -io remount,ro /usr/share/; then
                  printf " \e[1;32m+ \e[1;37mmount\e[m -o remount,\e[1;35mro \e[1;34m/usr/local/distfiles/\e[m... \e[1;33mok\e[m\n"
                  printf " \e[1;32m+ \e[1;37mmount\e[m -o remount,\e[1;35mro \e[1;34mlocal filesystem\e[m... \e[1;33mok\e[m\n"
               #elif mount -o remount,ro /usr/share/; then
               else
                  return
               fi
            elif [[ $STRING == *' /usr/share '*'noexec,'* ]]; then
               sync
               if mount -io remount,exec /usr/share/; then
                  printf " \e[1;32m+ \e[1;37mmount\e[m -o remount,\e[1;35mexec \e[1;34m/usr/share/\e[m... \e[1;33mok\e[m\n"
               fi
            fi
         }
      }
      _SetupRemount
   ;;
   install|prerm)
      _InstallRemount
   ;;
   postinst)
   ;;
   empty)
      #[[ ${PRE_EBUILD_PHASE-} == instprep ]]; then
      if [[ -e ${T%/temp}/.instprepped && ! -e ${T%/temp}/.compiled ]]; then
      #if [[ -d /var/tmp/portage/$CATEGORY/${P}/image/ ]]; then
         # install binary
         _PostRemount
         _InstallRemount
      else
         _PostRemount
      fi
   ;;
   cleanrm)
      # declare -x T="/var/tmp/portage/app-text/mupdf-1.15.0/temp"
      # declare -x T="/var/tmp/portage/._unmerge_/x11-base/xorg-server-1.20.5/temp"
      # ls -l ${T/\._unmerge_\//}/../.compiled
      # ls -l ${T/\._unmerge_\//}
      if [[ -d ${T/\._unmerge_\//} && ! -e ${T/\._unmerge_\//}/../.compiled ]]; then
      # bug:
      #  ldconfig: Can't create temporary cache file /etc/ld.so.cache~: Read-only file system
      #  File "/usr/lib/python3.7/site-packages/portage/dbapi/_MergeProcess.py", line 234, in _spawn
      #  OSError: [Errno 30] Read-only file system: b'/etc/profile.env.4176'
      #(
      # declare -p > /tmp/ebuild_${EBUILD_PHASE}_$RANDOM.log
      # declare -i N=0
      # while true; do
      #   if (( N >= 400 )); then
      #      break
      #   elif [[ ! -d ${T%/temp}/ ]]; then
      #      sync
      #      _PostRemount
      #      break
      #   else
      #      sleep 2s
      #   fi
      #   N+=1
      # done
      #) &
         _PostRemount
      # declare -x S="/var/tmp/portage/gnome-base/gnome-desktop-3.32.2/work/gnome-desktop-3.32.2"
      # + EBUILD_PHASE: postrm
      # + _BashRcLoad... ok
      # + EBUILD_PHASE: cleanrm
      #ls: cannot access '/var/tmp/portage/gnome-base/gnome-desktop-3.30.2.3/temp/../.compiled': No such file or directory
      #ls: cannot access '/var/tmp/portage/gnome-base/gnome-desktop-3.30.2.3/temp': No such file or directory
      # + _BashRcLoad... ok
      #>>> Regenerating /etc/ld.so.cache...
      #>>> Original instance of package unmerged safely.
      # + EBUILD_PHASE: postinst
      # + _BashRcLoad... ok
      # + EBUILD_PHASE: empty
      elif [[ -d /var/tmp/portage/$CATEGORY/${P}/ && ! -e /var/tmp/portage/$CATEGORY/${P}/.compiled ]]; then
         declare -p > /tmp/ebuild_${EBUILD_PHASE}_${RANDOM}_bug.log
         _PostRemount
      elif [[ ! -d /var/tmp/portage/$CATEGORY/${P}/ && ${PRE_EBUILD_PHASE-} == postrm ]]; then
         {
          # bug: no fix ( child proc block ppid )
          #sleep 15s
          #_PostRemount
          printf " \e[;31m+ \e[1;35mPostRemount\e[m... \e[1;31merror\e[m\n"
         } &
      fi
   ;;
esac

unset -v FSTYPE MOUNTLIST MOUNTPOINT OSDIR


####### sample #######
# mapfile -s 0 -n 110 MOUNTLIST < /proc/mounts
# if [[ ${FSLIST[*]} == *$'\t'${FSTYPE}$'\n'* ]]; then
# if [[ ${MOUNTLIST[*]} == *$'/dev/'*' /usr/local/distfiles '*' rw,'*$'\n'* ]]; then