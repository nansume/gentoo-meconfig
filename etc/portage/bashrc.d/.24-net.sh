#!/lib/shell/env bash5
# Copyright (C) 2019 Artem Slepnev, Shellgen
# License GPLv3+: GNU GPL version 3 or later
# gnu.org/licenses/gpl.html



_NetDevList() {
   unset -f $FUNCNAME
   if [[ -e /proc/net/dev ]]; then
      mapfile -ts 2 -n 10 NETDEV_LIST < /proc/net/dev
      NETDEV_LIST=(${NETDEV_LIST[@]%:*})
   else
      return
   fi

   declare -r IFS=$'\n'
   declare _ROUTE_LIST
   mapfile -ts 0 -n 20 -d $'\n' _ROUTE_LIST < <(exec ip -4 route)
   ROUTE_LIST=(${_ROUTE_LIST[*]})
   mapfile -ts 0 -n 30 -d $'\n' _ROUTE_LIST < <(exec ip -6 route)
   ROUTE_LIST+=(${_ROUTE_LIST[*]})
}


#  178.248.233.6 via 192.168.0.1 dev eth0 metric 203
#  192.88.99.1 via 192.168.0.1 dev eth0 metric 203
#  192.168.0.0/24 dev eth0 proto kernel scope link src 192.168.0.136
#  204.187.15.12 via 192.168.0.1 dev eth0 metric 203

#  ::/96 dev sit0 proto kernel metric 256 pref medium
#  anycast 200:: dev tun0 proto kernel metric 0 pref medium
#  200::/7 dev tun0 proto kernel metric 256 pref medium
#  anycast 2001:: dev teredo proto kernel metric 0 pref medium
#  2001::/32 dev teredo proto kernel metric 256 pref medium
#  2002:bcf3:f0cc:cbed:2c25:eeab:9dee:81d dev sit0 proto kernel metric 256 pref medium
#  2606:4700:10::6814:a60b via ::192.88.99.1 dev sit0 metric 1 pref medium
#  2a00:1a28:1157:3ef::2 via ::192.88.99.1 dev sit0 metric 1 pref medium
#  anycast fe80:: dev eth0 proto kernel metric 0 pref medium
#  anycast fe80:: dev tun0 proto kernel metric 0 pref medium
#  anycast fe80:: dev teredo proto kernel metric 0 pref medium
#  fe80::/64 dev eth0 proto kernel metric 256 pref medium
#  fe80::/64 dev tun0 proto kernel metric 256 pref medium
#  fe80::/64 dev teredo proto kernel metric 256 pref medium
#  ff00::/8 dev sit0 metric 256 pref medium
#  ff00::/8 dev eth0 metric 256 pref medium
#  ff00::/8 dev tun0 metric 256 pref medium
#  ff00::/8 dev teredo metric 256 pref medium
#  default via ::192.88.99.1 dev sit0 metric 1 pref medium
#  default dev teredo metric 10 pref medium
_RouteAppend() {
   unset -f $FUNCNAME
   declare NETDEV IPADDR
   for NETDEV in ${NETDEV_LIST[*]}; {
      case $NETDEV in
         eth0)
            source /lib/shell/so net

            declare IPADDR_GW=${IPADDR_GW:-192.168.0.1}

            if [[ ${ROUTE_LIST[*]} != *"$IPADDR_GW dev $NETDEV proto static scope link src $IPADDR_WAN_IPV4 metric 203"* ]]; then
               ip -4 route add $IPADDR_GW src $IPADDR_WAN_IPV4 dev $NETDEV metric 203 protocol static
               printf " \e[1;32m+\e[m \e[1;35mroute\e[m \e[;31madd\e[m: \e[1;37m$IPADDR_GW src $IPADDR_WAN_IPV4 dev $NETDEV\e[m\n"
            fi
            for IPADDR in \
             83.170.6.76 \
             46.151.26.194
            {
               if [[ ${ROUTE_LIST[*]} != *"$IPADDR via $IPADDR_GW dev $NETDEV proto static metric 203"* ]]; then
                  ip -4 route add $IPADDR via $IPADDR_GW dev $NETDEV metric 203 protocol static
                  printf " \e[1;32m+\e[m \e[1;35mroute\e[m \e[;31madd\e[m: \e[1;37m$IPADDR via $IPADDR_GW dev $NETDEV metric 203\e[m\n"
               fi
            }
            ip -4 route del $IPADDR_GW
            printf " \e[1;32m+\e[m \e[1;35mroute\e[m \e[;31mdel\e[m: \e[1;37m$IPADDR_GW src $IPADDR_WAN_IPV4 dev $NETDEV\e[m\n"
         ;;
         sit0)
            for IPADDR in \
             default
            {
               if [[ ${ROUTE_LIST[*]} != *"$IPADDR via ::192.88.99.1 dev $NETDEV proto static metric 1 pref medium"* ]]; then
                  ip -6 route add $IPADDR via ::192.88.99.1 dev $NETDEV metric 1 pref medium protocol static
                  printf " \e[1;32m+\e[m \e[1;35mroute\e[m \e[;31madd\e[m: \e[1;37m$IPADDR via ::192.88.99.1 dev $NETDEV metric 1\e[m\n"
               fi
            }
         ;;
      esac
   }
}


if [[ ${EBUILD_PHASE-} == setup ]]; then
   if ! declare -F _NetdevLo &> /dev/null; then
      source /lib/shell/so netw
   fi
   RC_ARG=stop _NetdevLo

   _NetDevList || return

   for NETDEV in ${NETDEV_LIST[*]}; {
      #ip route flush dev $NETDEV || return
      case $NETDEV in
         eth0)
            declare IPADDR_GW=192.168.0.1

            for IPADDR in \
             83.170.6.76 \
             46.151.26.194
            {
               if [[ ${ROUTE_LIST[*]} == *"$IPADDR via $IPADDR_GW dev $NETDEV proto static metric 203"* ]]; then
                  ip -4 route del $IPADDR
                  printf " \e[1;32m+\e[m \e[1;35mroute\e[m \e[;31mdel\e[m: \e[1;37m$IPADDR\e[m\n"
               fi
            }
         ;;
         sit0)
            for IPADDR in \
             default
            {
               if [[ ${ROUTE_LIST[*]} == *"$IPADDR via ::192.88.99.1 dev $NETDEV proto static metric 1 pref medium"* ]]; then
                  ip -6 route del $IPADDR
                  printf " \e[1;32m+\e[m \e[1;35mroute\e[m \e[;31mdel\e[m: \e[1;37m$IPADDR\e[m\n"
               fi
            }
         ;;
      esac
   }
   unset -v NETDEV_LIST ROUTE_LIST NETDEV IPADDR
   # ok - color: green
   printf " \e[1;32m+\e[m ${BASH_SOURCE##*/}... \e[1;33mok\e[m\n"
elif [[ ${EBUILD_PHASE:-empty} == empty ]]; then
   _RouteDefault() {
      unset -f $FUNCNAME
      if [[ ${EBUILD_PHASE:-empty} == empty ]]; then
         declare NETDEV_LIST ROUTE_LIST
         if _NetDevList; then
            _RouteAppend || return
            # ok - color: green
            printf " \e[1;32m+\e[m route default... \e[1;33mok\e[m\n"
         fi
      fi
   }


   #.installed
   #if [[ -e ${T%/temp}/.packaged && ! -e ${T%/temp}/.instprepped ]] ||\
   # [[ -e ${T%/temp}/.instprepped && ! -e ${T%/temp}/.packaged ]]; then
      case ${EBUILD_PHASE:-empty} in
         empty)
            if [[ ${PRE_EBUILD_PHASE:-empty} == package ||\
             ${PRE_EBUILD_PHASE:-empty} == postinst ]]; then
            if ! _RouteDefault; then
               # error - color: red
               printf " \e[;31m++\e[m \e[;33m${EBUILD_PHASE:-empty}\e[m... \e[1;31merror\e[m\n"
            fi
            fi
         ;;
      esac
   #fi
fi