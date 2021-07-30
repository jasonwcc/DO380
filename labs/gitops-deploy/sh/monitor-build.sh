#!/bin/bash
  
token=$( cat ~/developer-token.txt )
host=$( oc get route jenkins -o jsonpath='{.spec.host}' )
job="https://${host}/job/hello/job/master"

if json=$( curl --fail -sk "${job}/lastBuild/api/json" --user "developer-admin-edit-view:${token}" )
then
  number=$( echo "${json}" | jq -r '.number' )
  result=$( echo "${json}" | jq -r '.result' )
  echo "Result of the last build (#${number}) from hello/master is: ${result}."
else
  echo "Error from curl invoking the Jenkins API: $?"
fi
