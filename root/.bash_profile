#!/usr/bin/env bash4
# Copyright (C) 2018 Artem Slepnev, Shellgen
# License GPLv3+: GNU GPL version 3 or later
# gnu.org/licenses/gpl.html



source /var/lib/evar/shell.env

# non-interactive shell
if ! [[ ${PS1:-} ]]; then
   # init 1 - non close
   if (( $PPID == 0 )); then
      trap 'printf error...\\n
       exec bash --login' EXIT
   fi

   set -o errexit
else  # interactive login shell
   PS1=

   if (( $PPID == 0 )); then
      alias exit='exec init'
      PS1='init_1 '
   elif (( $TTY == 2 )); then
      source /tmp/evar/net.env
   elif (( $TTY == 5 )) && [[ -f /etc/profile.env ]]; then
      # Gentoo tools (portage)
      OLDPATH=$PATH
      source /etc/profile.env

      if [[ ${ROOTPATH:-} ]]; then
         if (( ${#OLDPATH} == 29 )); then
            PATH+=:$OLDPATH
         else
            PATH=$OLDPATH
         fi
         PS1='(gentoo) '
         unset OLDPATH ROOTPATH
      fi
   fi

   PS1+=${ps1/5/1}
   unset ps1
fi


declare -r PATH