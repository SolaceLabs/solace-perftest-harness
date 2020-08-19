#!/bin/bash
#Test set (direct messaging) to run against a small software broker (2 cores)
vmrs="${1}" #broker IP/DNS
testsetprefix="2core"
msg_type="direct"

testarray2=""\
"1024:1:300000:1:${msg_type} "\
"1024:2:370000:1:${msg_type} "\
"1024:5:410000:1:${msg_type} "\
"1024:10:410000:1:${msg_type} "\
"1024:50:460000:1:${msg_type} "\
"1024:100:490000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../run-testset.sh ${vmrs} ${testsetprefix} ${msg_type} ";"${testarray2[@]}
