#!/lib/shell/env bash5
# Copyright (C) 2019 Artem Slepnev, Shellgen
# License GPLv3+: GNU GPL version 3 or later
# gnu.org/licenses/gpl.html



# bug:
#################################
# dev-perl/Locale-gettext-1.70.0
#################################
# Looks good
# Generating a Unix-style Makefile
# Writing Makefile for Locale::gettext
# Writing MYMETA.yml and MYMETA.json
# ==> Your Makefile has been rebuilt. <==
# ==> Please rerun the make command.  <==
# make: *** [Makefile:966: Makefile] Error 1
#  * ERROR: dev-perl/Locale-gettext-1.70.0::gentoo failed (compile phase):
#  *   emake failed

# set: unpack,prepare
if [[ ${EBUILD_PHASE-} == compile ]]; then
   case $PN in
      *)
         if declare -F pre_src_$EBUILD_PHASE &> /dev/null; then
            # error - color: red
            printf " \e[;31m++\e[m \e[1;37mpre_src_$EBUILD_PHASE\e[m... \e[1;31merror\e[m\n"
            return 1
         else
            pre_src_compile() {
               set -o errexit -o pipefail -o nounset
               unset -f $FUNCNAME

               # before pre_src_$EBUILD_PHASE
               if declare -F before_src_$EBUILD_PHASE &> /dev/null; then
                  before_src_$EBUILD_PHASE || return
               fi

               if ! declare -F _ChangeTime &> /dev/null; then
                  if [[ -s /lib/shell/rc ]]; then
                     source /lib/shell/so rc shell
                     #source /lib/shell/variable shell
                  fi
               fi

               if declare -F _ChangeTime &> /dev/null; then
                  # ok - color: green
                  printf " \e[1;32m+\e[m ebuild/$CATEGORY/\e[1;36m$PN\e[m \e[1;35mChangeTime\e[m... \e[1;33m$FUNCNAME\e[m\n"
                  #_ChangeTime ${PORTAGE_BUILDDIR} || return
                  if [[ ${S} == */work ]]; then
                     _ChangeTime ${S} || return
                  else
                     _ChangeTime ${S%/*} || return
                  fi
               else
                  # error - color: red
                  printf " \e[;31m++\e[m ${BASH_SOURCE##*/} \e[1;33m_ChangeTime\e[m... \e[1;31merror\e[m\n"
                  return 1
               fi
               set +o nounset +o pipefail +o errexit
            }
         fi
      ;;
   esac
fi