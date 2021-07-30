#!/bin/bash

set -x

POSTGRES_POD="postgresql-0"

cat /mnt/scripts/start_backup.sql | oc exec "$POSTGRES_POD" -- psql

oc exec "$POSTGRES_POD" -- tar czf - -C /var/lib/pgsql/data userdata | cat > /mnt/backup/backup.tar.gz

cat /mnt/scripts/stop_backup.sql | oc exec "$POSTGRES_POD" -- psql


