#!/lib/shell/env bash5
# Copyright (C) 2019 Artem Slepnev, Shellgen
# License GPLv3: GNU GPL version 3



if [[ -d /sys/devices/system/cpu/cpufreq/policy0/ ]]; then
   case ${EBUILD_PHASE-} in
      setup|install)
         if ! declare -F _CpuSet &> /dev/null; then
            # _CpuSet _CpuOn add
            source /lib/shell/power || return

            _CpuSetDefault() {
               unset -f $FUNCNAME
               case ${EBUILD_PHASE:-empty} in
                  install|empty)
                     if [[ $BASH_SOURCE == */temp/environment ]]; then
                        declare -r FREQ_SET=min
                        declare -r _LIST=$CPUFREQ_DIR/scaling_${FREQ_SET}_freq

                        _CpuOn 0 || true
                        _CpuSet
                        declare -p > /tmp/ebuild_error.log
                        printf " \e[;31m++\e[m ${BASH_SOURCE[*]}... \e[1;31merror\e[m\n"
                        printf " \e[;31m++\e[m ${FUNCNAME[*]}... \e[1;31merror\e[m\n"
                     fi
                     #return 0
                  ;;
               esac
            }
         fi
      ;;
   esac

   case ${EBUILD_PHASE-} in
      setup)
         if declare -F pre_pkg_$EBUILD_PHASE &> /dev/null; then
            # error - color: red
            printf " \e[;31m++\e[m pre_pkg_$EBUILD_PHASE... \e[1;31merror\e[m\n"
            return 1
         else
            _MakeOptSet() {
               unset -f $FUNCNAME
               #if [[ ! ${MAXCPU-} && -s /etc/lst.d/cpu ]]; then
               #   read -n 1 MAXCPU < /etc/lst.d/cpu || return
               #   # ok - color: green
               #   printf " \e[1;32m+\e[m /etc/lst.d/cpu: cpumax... read\n"
               #fi
               declare -p MAXCPU
               #declare -p MAKEOPTS

               if [[ ${MAXCPU-} && ${MAKEOPTS-} ]]; then
                  declare -i JOBS=$MAXCPU
                  JOBS+=1
                  MAKEOPTS=${MAKEOPTS/--jobs=?/--jobs=$JOBS}
                  MAKEOPTS=${MAKEOPTS/--load-average=?/--load-average=$MAXCPU}
                  # ok - color: green
                  printf " \e[1;32m+\e[m jobs=$JOBS \e[1;33mload-average=$MAXCPU\e[m\n"
               else
                  # error - color: red
                  printf " \e[;31m++\e[m $FUNCNAME... \e[1;31merror\e[m\n"
                  return 1
               fi
            }


            pre_pkg_setup() {
               set -o errexit -o pipefail -o nounset
               unset -f $FUNCNAME

               # before pre_pkg_setup
               if declare -F before_pkg_$EBUILD_PHASE &> /dev/null; then
                  before_pkg_setup || return
               fi

               declare -r CPUFREQ_DIR=/sys/devices/system/cpu/cpufreq/policy0
               declare -r FREQ_SET=max
               declare _LIST=$CPUFREQ_DIR/scaling_${FREQ_SET}_freq
               declare -r _LIST+=\ $CPUFREQ_DIR/scaling_min_freq

               _CpuOn 1 || return
               _MakeOptSet || return
               _CpuSet || return
               # ok - color: green
               printf " \e[1;32m+\e[m $BASH_SOURCE... \e[1;33mok\e[m\n"
               set +o nounset +o pipefail +o errexit
            }
         fi
      ;;
      install)
         if declare -F post_src_$EBUILD_PHASE &> /dev/null; then
            # error - color: red
            printf " \e[;31m++\e[m post_src_$EBUILD_PHASE... \e[1;31merror\e[m\n"
            return 1
         else
            post_src_install() {
               set -o errexit -o pipefail -o nounset
               unset -f $FUNCNAME

               declare -r CPUFREQ_DIR=/sys/devices/system/cpu/cpufreq/policy0
               declare -r FREQ_SET=min
               declare -r _LIST=$CPUFREQ_DIR/scaling_${FREQ_SET}_freq

               _CpuOn 0 || true
               _CpuSet || return
               # ok - color: green
               printf " \e[1;32m+\e[m cpuset... \e[1;33mdefault\e[m\n"

               if declare -F after_src_$EBUILD_PHASE &> /dev/null; then
                  after_src_$EBUILD_PHASE || return
               fi
               set +o nounset +o pipefail +o errexit
            }
         fi
      ;;
   esac
elif [[ ${EBUILD_PHASE-} == setup ]]; then
   # error - color: red
   printf " \e[;31m++\e[m ${BASH_SOURCE#*/??-}... \e[1;31merror\e[m\n"
   return 1
fi