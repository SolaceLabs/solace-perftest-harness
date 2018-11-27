#!/bin/bash
#Simple wrapper script around ansible playbook to update host OS of VMRs...
export ANSIBLE_FORCE_COLOR=true
export ANSIBLE_HOST_KEY_CHECKING=False
echo "Running ansible-playbook update-vmr-os.yaml with args: " $@
ansible-playbook -i host update-vmr-os.yaml $@ | tee run-update.log
echo

#rm -rf run-update.log
