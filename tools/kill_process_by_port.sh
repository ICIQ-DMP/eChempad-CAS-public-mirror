#!/usr/bin/env bash
if [ -z "$1" ]; then
  echo "You need to supply the first argument to supply port, defaulting to port 8443"
  port="8443"
else
  port="$1"
fi

pid="$(netstat -tulpn 2>/dev/null | grep "${port}" | tr -s " " | cut -d " " -f7 | uniq)"

if [ -n "${pid}" ] && [ "${pid}" != "-" ]; then
  pid="$(echo "${pid}" | cut -d "/" -f1)"
  echo "Killing process ${pid}"
  echo "${pid}" | xargs kill -9
else
  echo "No process listening to port ${port}"
fi

sleep 1