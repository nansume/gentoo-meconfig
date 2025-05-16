#!/lib/shell/env bash5
# Copyright (C) 2020 Artem Slepnev, Shellgen
# License GPLv3: GNU GPL version 3



if [[ ${EBUILD_PHASE-} == 'setup' ]]; then
   #if declare -F _ReCFLAGS &> /dev/null; then
   #   unset -f _ReCFLAGS

   #if [[ -e ${PORTAGE_CONFIGROOT%/}/etc/portage/bashrc.d/optsize.env ]]; then
   #   source ${PORTAGE_CONFIGROOT%/}/etc/portage/bashrc.d/optsize.env
   #   if declare -F _ReCFLAGS > /dev/null; then
   #      _ReCFLAGS
   #   fi
   #fi


   declare SIZE
   # memsize free: MemFree <= 1500000
   #mapfile -n 1 -s 1' SIZE < /proc/meminfo || return
   # memsize available: MemAvailable <= 1500000
   mapfile -ts '2' -n '1' -d $'\n' SIZE < /proc/meminfo || return
   declare -i SIZE=${SIZE//[^0-9]/}

   # memsize available: MemAvailable <= 1500000
   if [[ ${CFLAGS-} ]] && (( SIZE <= '1500000' )); then
      CFLAGS=${CFLAGS/ -pipe/}
      [[ ${FFLAGS-} ]] && FFLAGS=${FFLAGS/ -pipe/}
      [[ ${FCFLAGS-} ]] && FCFLAGS=${FCFLAGS/ -pipe/}
      CXXFLAGS=${CFLAGS:?}

      _ReCFLAGS() {
         unset -f $FUNCNAME
         CFLAGS=${CFLAGS/ -ftree-vectorize/}
         CXXFLAGS=${CFLAGS:?}
         MAKEOPTS=${MAKEOPTS/2/1}
         #FEATURES="${FEATURES} ccache noclean
         #CCACHE_DIR="${PORTAGE_TMPDIR}/ccache
         #CCACHE_SIZE="1.0G
         #CCACHE_SIZE="0.4G
         #PORTAGE_TMPDIR+=_disk

         #[[ ${PORTAGE_TMPDIR-} ]] || exit 1
         #mapfile -tn 20 < /proc/mounts
         #if [[ ${MAPFILE[@]} == *" $PORTAGE_TMPDIR $FSTYPE ro* ]]; then
         #   mount -o remount,rw $PORTAGE_TMPDIR
         #fi
         #unset MAPFILE
      }


      #case $CATEGORY/$PN in
      #   dev-libs/boost|sys-devel/gcc)
      #      #pkg_pretend() {
      #      #   _ReCFLAGS
      #      #}
      #      #if [[ ${EBUILD_PHASE} == postrm ]]; then
      #      #   unset -f _ReCFLAGS
      #      #fi
      #   ;;
      #   */*)
      #      unset -f _ReCFLAGS
      #   ;;
      #esac

      if ! [[ ${CCACHE_DIR-} ]]; then
         unset -f _ReCFLAGS
      fi


      if declare -F _ReCFLAGS &> /dev/null; then
         _ReCFLAGS || return
         # ok - color: green
         printf " \e[1;3m+\e[;00m $BASH_SOURCE\n"
      fi
   fi
   unset -v SIZE
fi