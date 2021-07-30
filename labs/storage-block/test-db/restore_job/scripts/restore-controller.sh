#!/bin/bash

set -x

NUM_REPLICAS=$(oc get statefulset postgresql -o jsonpath='{.spec.replicas}')

# Scale down postgres, so backup restore job can attach
# to the volume
oc scale --replicas=0   statefulset postgresql --timeout=1m

# Execute the backup restore job
oc create -f restore-job.yml

started=$(oc get job restore-db -o jsonpath='{.status.startTime}')
echo "Data restore started:  $started"

# Continue to check the completion of the data restore.
# TODO: fix messages and sleep order
completed=$(oc get job restore-db -o jsonpath='{.status.completionTime}')
while [[ -z "$completed" ]]; do
  if oc get jobs restore-db ; then
    completed=$(oc get jobs restore-db -o jsonpath='{.status.completionTime}')
  else
    completed="restore-db job not found..."
  fi
  echo "Waiting for job to complete..."
  sleep 1
done
echo "Data restore complete: $started"

# Delete the job, to delete the restore pod.
# This allows the postgres pod to reattach to the volume.
oc delete job restore-db --timeout=1m


# Now scale up the database
oc scale --replicas="$NUM_REPLICAS" statefulset postgresql --timeout=1m


