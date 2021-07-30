#!/bin/bash

count=0
previous=0

while [ ${count} -lt 6 ]; do
    # Count nodes named "worker" and output if the number has changed
    count=$(oc get nodes -o name | grep worker | wc -l)
    if [ ${previous} -ne ${count} ]; then
        echo "Worker count is ${count}."
        previous="${count}"
    fi

    # Approve pending CSRs
    oc get csr -o json | jq '.items[] | select(.status == {}) | .metadata.name' | xargs -r oc adm certificate approve

    sleep 2
done
