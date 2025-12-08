#!/bin/bash

# Change this variable with your kubeconfig file path
export KUBECONFIG="/home/student/DO380/labs/auth-tls/robot-cert/health-robot.config"

# Set the PATH variable
export PATH=/home/student/.local/bin:/home/student/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/student/.venv/labs/bin

log_file="/tmp/cluster.log"


# Verify that the script can connect to the cluster

context=$( oc whoami -c )
username=$( oc whoami )
echo "Connected to the cluster as the '${username}' user"

if [ -z "${context}" ]
then
    echo "✘ Please setup a correct KUBECONFIG file in the variable"
    exit 1
else
    api=$( oc whoami --show-server )

    if ! curl --fail -k -s --connect-timeout 9 "${api}/healthz" &>/dev/null
    then
        status=$(curl --fail -k -s --connect-timeout 9 -o /dev/null -w "%{http_code}" "${api}/healthz")
        if [ "${status}" != "401" ]
        then
            echo "✘ Cannot connect to OpenShift at '${api}'"
            exit 2
        else
            echo "✘ The API health endpoint '${api}/healthz' requires authentication, proceeding anyway."
        fi
    fi
    if ! oc get nodes -o name &>/dev/null
    then
        echo "✘ Please setup a valid KUBECONFIG file for a cluster administrator."
        exit 1
    else
        if ! oc get clusterversion -o name &>/dev/null
        then
            echo "✘ Cannot get a clusterversion resource. Proceeding under the assumption this is a Microshift cluster."
        else
            version=$( oc get clusterversion version -o jsonpath='{.status.desired.version}' )
            echo "✔ OpenShift is reacheable and up, at version: '${version}'"
        fi
    fi
fi


# Verify the status for all the pods in the cluster
# If pods are at pending, failed, or unknown state, then write the error to the log file defined in the log_file variable

pending=$( oc get pod -A -o jsonpath="{.items[?(@.status.phase=='Pending')].metadata.namespace}" )
failed=$( oc get pod -A -o jsonpath="{.items[?(@.status.phase=='Failed')].metadata.namespace}" )
unknown=$( oc get pod -A -o jsonpath="{.items[?(@.status.phase=='Unknown')].metadata.namespace}" )

if [ -n "${failed}" -o -n "${unknown}" -o -n "${pending}" ]
then
    if [ -n "${failed}" ]
    then
        date >> "${log_file}"
        echo '✘ Namespaces with failed pods:' | tee -a "${log_file}"
        echo "✘ $( echo ${failed} | tr ' ' '\n' | sort | uniq )" | tee -a "${log_file}"
    else
        echo "✔ There are no failed pods."
    fi

    if [ -n "${unknown}" ]
    then
        date >> "${log_file}"
        echo '✘ Namespaces with pods in an unknown stage:' | tee -a "${log_file}"
        echo "✘ $( echo ${unknown} | tr ' ' '\n' | sort | uniq )" | tee -a "${log_file}"
    else
        echo "✔ There are no pods in an unknown state."
    fi

    if [ -n "${pending}" ]
    then
        date >> "${log_file}"
        echo '✘ Namespaces with pending pods:' | tee -a "${log_file}"
        echo "✘ $( echo ${pending} | tr ' ' '\n' | sort | uniq )" | tee -a "${log_file}"
    else
        echo "✔ There are no pending pods."
    fi
    exit 1
else
    echo "✔ All pods are either running or succeeded."
fi
