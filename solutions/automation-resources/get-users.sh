#!/bin/sh

filter='?(.name=="htpasswd_provider")'

secret_name=$(oc get oauth cluster \
  -o jsonpath="{.spec.identityProviders[$filter].htpasswd.fileData.name}")

secret_file=$(oc extract secret/$secret_name -n openshift-config --confirm)

cut -d : -f 1 <$secret_file
rm $secret_file
