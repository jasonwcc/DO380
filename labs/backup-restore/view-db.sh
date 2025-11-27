#!/bin/sh
if [[ "$1" == "-n" ]]; then
  if [ -z "$2" ]; then
    echo "namespace missing"
    exit 1
  fi
  NS="-n $2"
  shift 2
fi
if [ -z "$1" ]; then
  set -x 
  oc exec $NS -c mariadb deploy/mariadb -- \
  bash -c \
  'mariadb -u ${MARIADB_USER} \
    -p"${MARIADB_PASSWORD}" \
    ${MARIADB_DATABASE} -te \
    "SELECT * FROM application_logs ORDER BY id DESC LIMIT 5;"'
else
  set -x 
  oc exec $NS -c mariadb deploy/mariadb -- \
  bash -c \
  "mariadb -u \${MARIADB_USER} -p\"\${MARIADB_PASSWORD}\" \
    \${MARIADB_DATABASE} -te \
    \"SELECT * FROM application_logs WHERE time <= \\\"$1\\\" \
    ORDER BY id DESC LIMIT 5;\""
fi
