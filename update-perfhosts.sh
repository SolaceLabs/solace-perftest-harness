#!/bin/bash
#Simple wrapper script for ansible playbook to update OS of all perf hosts...
export ANSIBLE_FORCE_COLOR=true
export ANSIBLE_HOST_KEY_CHECKING=False
echo "Running ansible-playbook update-perfhosts.yaml with args: " $@
ansible-playbook -i host update-perfhosts.yaml $@ | tee run-update.log
echo

#rm -rf run-update.log
