#!/usr/bin/env bash
set -euo pipefail

APP='nginx'

(
for NODE in worker{01..03}
do
  PODS="$(oc get pods --no-headers -o wide -l app=${APP} --field-selector spec.nodeName=${NODE} 2>/dev/null | wc -l)"
  printf "%s\t%s\n" "${NODE}" "${PODS}"
done
) | \
column -t -o '	' -N "NODE,PODS" | \
sed -e 's/\ \+/\t/g'
