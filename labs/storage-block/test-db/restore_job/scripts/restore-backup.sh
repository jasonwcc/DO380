#!/bin/bash

set -x

rm -Rf /mnt/data/userdata

tar xf /mnt/backup/backup.tar.gz -C /mnt/data

echo 'Restore complete'
