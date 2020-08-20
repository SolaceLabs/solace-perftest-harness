#!/bin/bash
#Test set (direct messaging) to run against a small standard software broker (2 cores)
vmrs="${1}" #broker IP/DNS
testsetprefix="standard"
msg_type="mixed"
msg_type1="persistent"
msg_type2="direct"

testarray1=""\
"1024:1:10000:1:${msg_type1} "\
"1024:2:20000:1:${msg_type1} "\
"1024:5:50000:1:${msg_type1} "\
"1024:10:100000:1:${msg_type1} "\
"1024:50:460000:1:${msg_type1} "\
"1024:100:490000:1:${msg_type1} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:10000:2:${msg_type2} "\
"1024:2:20000:2:${msg_type2} "\
"1024:5:50000:2:${msg_type2} "\
"1024:10:90000:3:${msg_type2} "\
"1024:50:125000:2:${msg_type2} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../run-testset.sh ${vmrs} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]}
