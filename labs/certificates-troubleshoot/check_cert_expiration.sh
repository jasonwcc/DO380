#!/usr/bin/bash

# The following variables WARN_INTERVAL, ALERT_INTERVAL, SHOW_ISSUER, and LOG_FILE
# can be overridden if exported prior to running this script. This should also allow
# these variables to be set in a configmap if this script is run in a container.

if [ -z "${WARN_INTERVAL}" ]
then
  WARN_INTERVAL="2 months"
fi

if [ -z "${ALERT_INTERVAL}" ]
then
  ALERT_INTERVAL="2 days"
fi

if [ -z "${SHOW_ISSUER}" ]
then
  SHOW_ISSUER="true"
fi

if [ -z "${LOG_FILE}" ]
then
  LOG_FILE=/tmp/cert_exp_info.txt
fi

if [ -f ${LOG_FILE} ]
then
  rm -f ${LOG_FILE}
fi

# Helper function to locate an entry inside an array
in_array() {
  local value=${1}[@]
  local pointer=${2}

  for i in ${!value}; do
    if [[ ${i} == ${pointer} ]]; then
      return 0
    fi
  done
  return 1
}

# We might want to modify this script so that it ignores certificates that have
# been signed by specific issuers. For example, I might not care about the
# certificates handled internally by OpenShift.

# The array defines a list of issuers to exclude.
declare -a exclude_issuers=(
  "kube-control-plane-signer"
  "kube-apiserver-lb-signer"
  "kube-apiserver-localhost-signer"
  "kube-apiserver-service-network-signer"
  "kube-apiserver-to-kubelet-signer"
  "openshift-kube-apiserver-operator_aggregator-client-signer"
  "openshift-kube-controller-manager-operator_csr-signer-signer"
)

# In addition to logging and displaying a message, we might modify this script
# to take an additional action if a certificate will expire SOON or VERY SOON.

for PROJECT in $(oc get projects -o name | cut -d/ -f2)
do
  for SECRET in $(oc get secrets -n ${PROJECT} -o name --field-selector type=kubernetes.io/tls)
  do
    SECRET_CERT="$(oc get ${SECRET} -n ${PROJECT} -o jsonpath='{.data.*}')"
    if [ -n "${SECRET_CERT}" ]
    then
      IFS=$'\n' read -r -d '' -a CERT_INFO < <( echo "${SECRET_CERT}" | base64 -di | openssl x509 -noout -enddate -issuer && printf '\0' )
      CERT_EXP="$(echo "${CERT_INFO[0]}" | cut -d= -f2)"
      # CERT_ISSUER="$(echo "${CERT_INFO[1]}" | sed 's/^issuer=//')"
      CERT_ISSUER="$(echo "${CERT_INFO[1]}" | sed 's/^issuer=// ; s/^OU.*, // ; s/CN = // ; s/@.*//')"

      if in_array exclude_issuers "${CERT_ISSUER}"
      then
        continue;
      fi

      if [ $(date +%s) -gt $(date --date="${CERT_EXP}" +%s) ]
      then
        echo "EXPIRED: ${SECRET} -n ${PROJECT} : ${CERT_EXP}" | tee -a ${LOG_FILE}

        if [ "${SHOW_ISSUER}" == "true" ]
        then
          echo "${CERT_ISSUER}" | tee -a ${LOG_FILE}
          echo ""
        fi
      elif [ $(date --date="${CERT_EXP}" +%s) -lt $(date --date="now +${WARN_INTERVAL}" +%s) ]
      then
        if [ $(date --date="${CERT_EXP}" +%s) -lt $(date --date="now +${ALERT_INTERVAL}" +%s) ]
        then
          echo "VERY SOON: ${SECRET} -n ${PROJECT} : ${CERT_EXP}" | tee -a ${LOG_FILE}
        else
          echo "SOON: ${SECRET} -n ${PROJECT} : ${CERT_EXP}" | tee -a ${LOG_FILE}
        fi

        if [ "${SHOW_ISSUER}" == "true" ]
        then
          echo "${CERT_ISSUER}" | tee -a ${LOG_FILE}
          echo ""
        fi
      fi
      # fi
    fi
  done
done

for PROJECT in $(oc get projects -o name | cut -d/ -f2)
do
  for ROUTE in $(oc get routes -n ${PROJECT} -o name)
  do
    ROUTE_CERT="$(oc get ${ROUTE} -n ${PROJECT} -o jsonpath='{.spec.tls.certificate}')"
    if [ -n "${ROUTE_CERT}" ]
    then
      IFS=$'\n' read -r -d '' -a CERT_INFO < <( echo "${ROUTE_CERT}" | openssl x509 -noout -enddate -issuer && printf '\0' )
      ROUTE_CERT_EXP="$(echo ${CERT_INFO[0]} | cut -d= -f2)"
      ROUTE_CERT_ISSUER="$(echo ${CERT_INFO[1]} | sed 's/^issuer=//')"
      if [ $(date +%s) -gt $(date --date="${ROUTE_CERT_EXP}" +%s) ]
      then
        echo "EXPIRED: ${ROUTE} -n ${PROJECT} : ${ROUTE_CERT_EXP}" | tee -a ${LOG_FILE}
        if [ "${SHOW_ISSUER}" == "true" ]
        then
          echo "${ROUTE_CERT_ISSUER}" | tee -a ${LOG_FILE}
          echo ""
        fi
      elif [ $(date --date="${ROUTE_CERT_EXP}" +%s) -lt $(date --date="now +${WARN_INTERVAL}" +%s) ]
      then
        if [ $(date --date="${CERT_EXP}" +%s) -lt $(date --date="now +${ALERT_INTERVAL}" +%s) ]
        then
          echo "VERY SOON: ${ROUTE} -n ${PROJECT} : ${ROUTE_CERT_EXP}" | tee -a ${LOG_FILE}
        else
          echo "SOON: ${ROUTE} -n ${PROJECT} : ${ROUTE_CERT_EXP}" | tee -a ${LOG_FILE}
        fi

        if [ "${SHOW_ISSUER}" == "true" ]
        then
          echo "${ROUTE_CERT_ISSUER}" | tee -a ${LOG_FILE}
          echo ""
        fi
      fi
     fi
  done
done
