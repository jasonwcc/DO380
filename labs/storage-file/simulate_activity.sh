#!/bin/bash

QUEUE_NAME=uploads_queue
REDIS_IMAGE="redis"

function get_pod_by_label() {
  app_label=$1
  oc get pods --selector=app=$1 --no-headers | awk '{print $1}'
}

http_pod=$(get_pod_by_label httpd)
redis_pod=$(get_pod_by_label redis)

echo "HTTP pod: $http_pod"
echo "Redis pod: $redis_pod"

# Unpack the jpg photos from the tar archive
tar xzvf photos/photos.tar.gz -C photos

# Copy local files to web directory of the pod, to
# simulate recent  photo/image uploads.
oc rsync --exclude='*' --include='*.jpg' photos/ $http_pod:/var/www/html/data/uploads


# Create a Redis client pod, to add jobs to a work queue
oc run redis-client --image=redis -l=app=client --generator=run-pod/v1

status=$(oc get pods redis-client -o jsonpath='{.status.phase}')
ctr=0
while [[ "$status" != "Running" ]] && [[ $ctr -lt 20 ]] ; do
  ctr=$((ctr+1))
  sleep 1
  status=$(oc get pods redis-client -o jsonpath='{.status.phase}')
done

# Ensure the queue is currently empty
oc rsh redis-client redis-cli -h redis del "$QUEUE_NAME"

# Add each local photo to the work queue.
for photo in $(ls photos | grep '.jpg$'); do

  # Push the photo filename on to the end
  # of the 'uploads_queue' (rpush).
  echo "rpush $QUEUE_NAME $photo"

# From the redis client pod, open a redis-cli session
# to the redis service.
done | oc rsh redis-client redis-cli -h redis

