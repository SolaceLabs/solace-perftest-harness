#!/bin/bash
#Quick test set (mixed messaging) to run against a large software broker (8 cores)
vmrs="$1" #broker IP/DNS
testsetprefix="8core-quick"
msg_type="mixed"
msg_type1="direct"
msg_type2="persistent"

testarray1=""\
"1024:1:716000:4:${msg_type1} "\
"1024:2:826000:4:${msg_type1} "\
"1024:5:1000000:4:${msg_type1} "\
"1024:10:1100000:4:${msg_type1} "\
"1024:50:1100000:2:${msg_type1} "\
"1024:100:1200000:2:${msg_type1} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:51000:4:${msg_type2} "\
"1024:2:103000:4:${msg_type2} "\
"1024:5:200000:4:${msg_type2} "\
"1024:10:300000:4:${msg_type2} "\
"1024:50:540000:2:${msg_type2} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../run-testset.sh ${vmrs} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]}
