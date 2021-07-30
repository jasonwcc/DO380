#!/bin/bash

watch "oc get deployment,pod,imagestream,istag; \
 echo; oc get deployment/hello -o json | \
 jq '.spec.template.spec.containers[0].image'; echo; \
 curl -s hello.apps.ocp4.example.com"