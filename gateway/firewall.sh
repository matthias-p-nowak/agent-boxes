#!/bin/sh
set -eu

# Prefer the nftables backend, but retain compatibility with kernels that do not
# support nftables inside Docker network namespaces.
IPTABLES=iptables
IP6TABLES=ip6tables
if ! "$IPTABLES" -P OUTPUT ACCEPT >/dev/null 2>&1; then
    IPTABLES=iptables-legacy
fi
if ! "$IP6TABLES" -P OUTPUT ACCEPT >/dev/null 2>&1; then
    IP6TABLES=ip6tables-legacy
fi

"$IPTABLES" -P OUTPUT DROP
"$IP6TABLES" -P OUTPUT DROP
"$IPTABLES" -F OUTPUT
"$IPTABLES" -A OUTPUT -o lo -j ACCEPT
"$IPTABLES" -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
"$IPTABLES" -A OUTPUT -d 192.168.0.0/16 -p tcp --dport 9931 -j ACCEPT
"$IPTABLES" -A OUTPUT -d 192.168.0.0/16 -p tcp --dport 15001:65535 -j ACCEPT
"$IPTABLES" -A OUTPUT -d 10.0.0.0/8 -j DROP
"$IPTABLES" -A OUTPUT -d 169.254.0.0/16 -j DROP
"$IPTABLES" -A OUTPUT -d 172.16.0.0/12 -j DROP
"$IPTABLES" -A OUTPUT -d 192.168.0.0/16 -j DROP
"$IPTABLES" -A OUTPUT -j ACCEPT
"$IP6TABLES" -F OUTPUT
"$IP6TABLES" -A OUTPUT -j DROP
touch /run/firewall-ready
exec sleep infinity
