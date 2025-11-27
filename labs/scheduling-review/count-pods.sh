#!/usr/bin/env bash
set -e

APP=$1

printf "%s\t\t%s\n" "NODE" "PODS"

for NODE in worker{01..03}
do
  PODS="$(oc get pods --no-headers -o wide -l app=${APP} --field-selector spec.nodeName=${NODE} 2>/dev/null | wc -l)"
  printf "%s\t%s\n" "${NODE}" "${PODS}"
done