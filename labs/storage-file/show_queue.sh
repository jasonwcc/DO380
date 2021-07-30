#!/bin/bash

QUEUE_NAME=uploads_queue

if ! oc get pods redis-client > /dev/null ; then
  ./create_client.sh
fi

# Display the entire range of items in the uploads queue,
# beginning on the left side of the queue (lrange).
oc rsh redis-client redis-cli -h redis lrange "$QUEUE_NAME" 0 -1


