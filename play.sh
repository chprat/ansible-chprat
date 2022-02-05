#!/bin/bash
set -e
ansible-playbook $1 -i inventory.yml -e "@vars/become.yml" --vault-password-file=vault.txt
