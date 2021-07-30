#!/usr/bin/bash

ansible-playbook /usr/local/lib/ansible/certs/wildcard.yml -e cert_path=$(pwd) -e "not_after=+3650d" -e update_cert=True -e combined_name=wildcard-combined
