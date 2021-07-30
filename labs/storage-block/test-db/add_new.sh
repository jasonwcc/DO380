#!/bin/bash


cat add_data.sql | oc rsh postgresql-0 psql

