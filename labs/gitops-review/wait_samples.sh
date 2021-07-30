#!/bin/bash

# The samples operator is so quick to re-create resources that you'd harly have a need for this script
  
oc wait co/openshift-samples --for condition=Progressing \
    --timeout 90s

until [ "False" -eq "$(oc get co openshift-samples -o \
jsonpath='{.status.conditions[?(@.type == "Progressing")].status}')" ]
do
    sleep 3
done

