#!/bin/sh
export PUBLIC_IP=$(curl https://ipinfo.io/ip)
nohup sudo consul agent \
  -server \
  -datacenter=azure \
  -bootstrap-expect=1 \
  -data-dir=/var/lib/consul \
  -node=server-one \
  -bind=0.0.0.0 \
  -advertise-wan=$PUBLIC_IP \
  -config-dir=/etc/consul.d &