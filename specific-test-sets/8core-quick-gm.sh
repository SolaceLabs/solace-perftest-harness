#!/bin/bash
#Quick test set (guaranteed messaging) to run against a large software broker (8 cores) (no redundancy)
vmrs="${1}" #broker IP/DNS
testsetprefix="8core-quick"
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

${BASH_SOURCE%/*}/../run-testset.sh ${vmrs} ${testsetprefix} ${msg_type} ";"${testarray[@]}
