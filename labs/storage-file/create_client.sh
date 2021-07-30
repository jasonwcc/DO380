#!/bin/bash

echo "Creating a redis client to check the queue..."
oc run redis-client \
  --image=redis \
  -l=app=client \
  --generator=run-pod/v1 \
  --timeout 60s
echo "Waiting for redis client readiness..."

ready='false'
while [[ $ready != 'true' ]] ; do
   echo "Waiting for redis client readiness..."
   ready=$(oc get pod redis-client -o jsonpath='{.status.containerStatuses[0].ready}')
   sleep 1
done
echo 'Redis client ready!'


