#!/usr/bin/env bash
if [ -z "$1" ]; then
  echo "You need to supply the first argument to supply port, defaulting to port 8443"
  port="8443"
else
  port="$1"
fi

pid="$(netstat -tulpn 2>/dev/null | grep "${port}" | tr -s " " | cut -d " " -f7 | cut -d "/" -f1)"

if [ -n "${pid}" ]; then
  kill -9 "${pid}"
else
  echo "No process listening to port ${port}"
fi