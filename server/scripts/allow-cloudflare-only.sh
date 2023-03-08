#!/bin/bash

set -e

cf_ips() {
  echo "# https://www.cloudflare.com/ips"

  for type in v4 v6; do
    echo "# IP$type"
    curl -s "https://www.cloudflare.com/ips-$type" | sed "s|^|allow |g" | sed "s|\$|;|g"
    echo
  done

  echo "# Generated at $(LC_ALL=C date)"
}

cf_ips > /azhdar/azhdar_xyz/azhdar.xyz/nginx/includes/allow-cloudflare.conf
(cf_ips && echo "allow 127.0.0.0/8;" && echo "allow 172.0.0.0/8;" && echo "deny all; # deny all remaining ips") > /azhdar/azhdar_xyz/azhdar.xyz/nginx/includes/allow-cloudflare-only.conf