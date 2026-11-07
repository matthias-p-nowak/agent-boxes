

FROM alpine:3.21
RUN apk add --no-cache iptables iptables-legacy
COPY firewall.sh /usr/local/bin/firewall.sh
RUN chmod 755 /usr/local/bin/firewall.sh
ENTRYPOINT ["/usr/local/bin/firewall.sh"]
