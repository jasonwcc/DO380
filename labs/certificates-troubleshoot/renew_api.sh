#!/usr/bin/bash

ansible-playbook /usr/local/lib/ansible/certs/custom.yml -e cert_path=$(pwd) -e cert_name=api -e 'cert_comment="Master API Certificate"' -e "not_after=+3650d" -e update_cert=True -e combined_name=api-combined
