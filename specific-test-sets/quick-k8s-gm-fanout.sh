#!/bin/bash
#Quick test set (guaranteed messaging) to run against a large GKE VMR group (similar to 8 cores) (no redundancy)
vmrs="${1}" #large k8s VMRs
testsetprefix="fanout-k8s"
msg_type="persistent"

testarray1=""\
"2048:300:320000:4:${msg_type} "\
"2048:5:150000:4:${msg_type} "\
";" #need to  end with to separate the various test arrays;

testarray=""\
"102400:50:10000:2:${msg_type} "\
"51200:50:17000:2:${msg_type} "\
"20480:50:40000:2:${msg_type} "\
"4096:50:222000:3:${msg_type} "\
"1024:50:490000:3:${msg_type} "\
"512:50:520000:3:${msg_type} "\
"1024:50:625000:4:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../run-testset.sh ${vmrs} ${testsetprefix} ${msg_type} ";"${testarray1[@]}
#${BASH_SOURCE%/*}/../run-testset.sh ${vmrs} ${testsetprefix} ${msg_type} ";"${testarray[@]}
