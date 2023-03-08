#!/bin/bash

set -e

cf_ips() {
  echo "# https://www.cloudflare.com/ips"

  for type in v4 v6; do
    echo "# IP$type"
    curl -s "https://www.cloudflare.com/ips-$type" | sed "s|\$|  1;|g"
    echo
  done

  echo "# Generated at $(LC_ALL=C date)"
}

#cf_ips > /azhdar/azhdar_xyz/azhdar.xyz/nginx/includes/allow-cloudflare.conf
(echo 'geo $realip_remote_addr $cloudflare_ip {' && \
 echo "default          0;" && \
 cf_ips && \
 echo "127.0.0.1  1;" && \
 echo "172.20.0.0/16  1; # App Net" && \
 echo "}") > /azhdar/azhdar_xyz/azhdar.xyz/nginx/includes/geo_cloudflare.conf