#!/bin/bash
#Quick test set (guaranteed messaging) to run against a large GKE VMR group (similar to 8 cores) (no redundancy)
vmrs="${1}" #large k8s VMRs
testsetprefix="quick-k8s"
msg_type="persistent"

testarray1=""\
"1024:1:55000:4:${msg_type} "\
"1024:2:100000:4:${msg_type} "\
"1024:5:210000:4:${msg_type} "\
"1024:10:320000:4:${msg_type} "\
";" #need to  end with to separate the various test arrays;

testarray=""\
"1024:4:55000:4:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../run-testset.sh ${vmrs} ${testsetprefix} ${msg_type} ";"${testarray1[@]}
