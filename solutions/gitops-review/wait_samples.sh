#!/bin/bash
  
oc wait co/authentication --for condition=Progressing \
    --timeout 90s

oc rollout status -n openshift-authentication deployment/oauth-openshift \
    --timeout 90s

while [ -n "$(oc get pod -n openshift-authentication -o \
jsonpath='{.items[?(@.metadata.deletionTimestamp != "")].metadata.name}')" ]
do
    sleep 3
done

