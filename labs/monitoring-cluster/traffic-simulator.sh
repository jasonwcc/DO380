#! /bin/bash

while true;
do
    curl http://budget.apps.ocp4.example.com/api/loadtest/v1/cpu/1 & curl http://frontend-dev-monitor.apps.ocp4.example.com/?[1-100] > /dev/null & curl http://exoplanets.apps.ocp4.example.com/?[1-100] > /dev/null
    sleep 10
done