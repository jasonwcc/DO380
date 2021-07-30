#!/bin/bash

cat select_all.sql | oc rsh postgresql-0 psql


