#!/lib/shell/env bash5
# Copyright (C) 2019 Artem Slepnev, Shellgen
# License GPLv3: GNU GPL version 3



if [[ ${EBUILD_PHASE-} == prepare ]]; then
   _UserPatchDefault() {
      unset -f $FUNCNAME
      if declare -F post_src_$EBUILD_PHASE &> /dev/null; then
         # error - color: red
         printf " \e[;31m++\e[m post_src_$EBUILD_PHASE... \e[1;31merror\e[m\n"
         return 1
      else
         post_src_prepare() {
            set -o errexit -o pipefail -o nounset
            unset -f $FUNCNAME
            if declare -F _UserPatch &> /dev/null; then
               _UserPatch
               # ok - color: green
               printf " \e[1;32m+\e[m $FUNCNAME... \e[1;32mok\e[m\n"
            fi

            # after post_src_$EBUILD_PHASE
            if declare -F after_src_$EBUILD_PHASE &> /dev/null; then
               after_src_$EBUILD_PHASE || return
            fi
            set +o nounset +o pipefail +o errexit +o noglob
         }
      fi
   }


   _LoadEpatchUser() {
      if (( ${EAPI:-0} <= 5 )); then
         if declare -F epatch_user &> /dev/null; then
            unset -f $FUNCNAME
            # epatch_user - legacy
            epatch_user() {
               set -o errexit -o pipefail -o nounset
               unset -f $FUNCNAME
               _UserPatch
               # after post_src_$EBUILD_PHASE
               if declare -F after_src_$EBUILD_PHASE &> /dev/null; then
                  after_src_$EBUILD_PHASE || return
               fi
               # ok - color: green
               printf " \e[1;32m+\e[m $FUNCNAME... \e[1;32mok\e[m\n"
               set +o nounset +o pipefail +o errexit +o noglob
            }
         else
            _UserPatchDefault
            # The ebuild phase 'prepare' has exited unexpectedly
            #  failed
            #if [[ ! -f ${T}/epatch_user.log ]]; then
            #   printf ''> ${T}/epatch_user.log
            #fi
         fi
      elif (( EAPI >= 6 )); then
         if declare -F eapply_user &> /dev/null; then
            unset -f $FUNCNAME
            # eapply_*
            # eapply_user
            # EAPI = 6,7
            eapply_user() {
               set -o errexit -o pipefail -o nounset
               _UserPatch
               #if [[ ! -f ${T}/.portage_user_patches_applied ]]; then
               #   printf ''> ${T}/.portage_user_patches_applied
               #fi
               # bug: fix
               unset -f $FUNCNAME
               # after post_src_$EBUILD_PHASE
               if declare -F after_src_$EBUILD_PHASE &> /dev/null; then
                  after_src_$EBUILD_PHASE || return
               fi
               # ok - color: green
               printf " \e[1;32m+\e[m $FUNCNAME... \e[1;32mok\e[m\n"
               set +o nounset +o pipefail +o errexit +o noglob
            }
         else
            _UserPatchDefault
         fi
      fi
   }


   if declare -F pre_src_$EBUILD_PHASE &> /dev/null; then
      # error - color: red
      printf " \e[;31m++\e[m pre_src_$EBUILD_PHASE... \e[1;31merror\e[m\n"
      return 1
   else
      pre_src_prepare() {
         set -o errexit -o pipefail -o nounset
         unset -f $FUNCNAME

         _PatchUserApply() {
            declare -r EPATCH_USER_SOURCE=${PORTAGE_CONFIGROOT%/}/$OVERLAY_DIR/'profiles/patches'
            declare -r EPATCH_SUFFIX='diff'
            declare -r ENV_DIR=${ENV_DIR:-/etc/vars.d}
            declare DIR F

            if ! [[ ${OLDDIR-} ]]; then
               # ok - color: green
               printf " \e[1;3m+\e[m $BASH_SOURCE\n"
            fi

            # fix: variables package name - force load
            if [[ ! ${SLOT-} && -f $ENV_DIR/portage ]]; then
               declare SLOT
               source $ENV_DIR/portage || return
               SLOT=$_SLOT
               unset -v _SLOT
            fi

            for DIR in {$EPATCH_USER_SOURCE,$PORTAGE_ACTUAL_DISTDIR/patches}/{${P}-${PR},${P},${PN},${PN}:${SLOT%/*}}; {
               if [[ -d $DIR/ ]]; then
                  [[ $BASHOPTS == *nullglob* ]] || shopt -s nullglob
                  [[ $SHELLOPTS == *noglob* ]] && set +o noglob
                  for F in $DIR/*.$EPATCH_SUFFIX; {
                     [[ $SHELLOPTS == *noglob* ]] || set -o noglob
                     [[ $BASHOPTS == *nullglob* ]] && shopt -u nullglob
                     if [[ ${F%.diff} == *_all || ${F%.diff} == *_$ABI || ${F%.diff} != *_??? ]]; then
                        #--set-utc
                        #patch --quiet -p1 -g0 -E --no-backup-if-mismatch < ${F} 2>&1
                        patch --quiet --force -p1 -g0 -E --no-backup-if-mismatch < ${F}
                        if (( $? == 0 )); then
                           if ! [[ ${OLDDIR-} ]]; then
                              # bug: phase-functions.sh
                              #  keep path in eapply_user in sync!
                              #if declare -F eapply_user &> /dev/null; then
                              #   if [[ ! -f ${T}/.portage_user_patches_applied ]]; then
                              #      printf ''> ${T}/.portage_user_patches_applied
                              #   fi
                              #fi
                              # ok - color: green
                              printf " \e[1;3m+\e[m ${F##*/}... ok\n"
                           fi
                        else
                           # error - color: red
                           printf " \e[;31m++\e[m ${F##*/}... \e[1;31merror\e[m\n"
                           return 1
                        fi
                     fi
                  }
                  [[ $SHELLOPTS == *noglob* ]] || set -o noglob
                  [[ $BASHOPTS == *nullglob* ]] && shopt -u nullglob
               fi
            }

            # autotools: rename configure.in to configure.ac internally
            # (automake-1.14 compat)
            #  https4://bugs.gentoo.org/show_bug.cgi?id=426262
            #if [[ $WANT_AUTOCONF > 2.13 ]]; then
            #   if [[ ! -f configure.ac && -f configure.in ]]; then
            #      mv --no-clobber configure.in configure.ac
            #      # ok - color: green
            #      printf ' \e[1;32m+\e[m fix: \e[1;34mconfigure.in\e[m => \e[1;34mconfigure.ac\e[m... \e[1;33mok\e[m\n'
            #   fi
            #fi

            # The ebuild phase 'prepare' has exited unexpectedly
            # failed
            :
         }


         _UserPatch() {
            unset -f $FUNCNAME
            declare OLDPWD=$OLDPWD DIR
            [[ $BASHOPTS == *nullglob* ]] || shopt -s nullglob
            [[ $SHELLOPTS == *noglob* ]] && set +o noglob
            for DIR in ${S}*; {
               [[ $SHELLOPTS == *noglob* ]] || set -o noglob
               [[ $BASHOPTS == *nullglob* ]] && shopt -u nullglob
               if [[ -d $DIR/ ]]; then
                  cd $DIR/
                  #printf " \e[1;3m+\e[m $PWD\n"
                  _PatchUserApply || return
                  cd $OLDPWD/
                  printf " \e[1;32m+\e[m cd $OLDPWD/... ok\n"
                  declare OLDDIR=$DIR
               fi
            }
            [[ $SHELLOPTS == *noglob* ]] || set -o noglob
            [[ $BASHOPTS == *nullglob* ]] && shopt -u nullglob
            unset -f _PatchUserApply
         }


         # before pre_src_$EBUILD_PHASE
         if declare -F before_src_$EBUILD_PHASE &> /dev/null; then
            before_src_$EBUILD_PHASE || return
         fi

         if declare -F _LoadEpatchUser &> /dev/null; then
            _LoadEpatchUser
         fi

         if (( EAPI >= 6 )); then
            # eapply_user (or default) must be called in src_prepare()!
            #  failed
            if [[ ! -f ${T}/.portage_user_patches_applied ]]; then
               printf ''> ${T}/.portage_user_patches_applied
            fi
         fi

         set +o nounset +o pipefail +o errexit +o noglob
      }
   fi
fi