#!/bin/bash
#Test set (direct messaging) to run against a small enterprise software broker (2 cores)
vmrs="${1}" #broker IP/DNS
testsetprefix="4core"
msg_type="mixed"
msg_type1="direct"
msg_type2="persistent"

testarray2=""\
"1024:1:550000:4:${msg_type1} "\
"1024:2:790000:4:${msg_type1} "\
"1024:5:550000:4:${msg_type1} "\
"1024:10:650000:4:${msg_type1} "\
"1024:50:850000:2:${msg_type1} "\
"1024:100:920000:2:${msg_type1} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:65000:2:${msg_type2} "\
"1024:2:120000:2:${msg_type2} "\
"1024:5:180000:2:${msg_type2} "\
"1024:10:250000:2:${msg_type2} "\
"1024:50:320000:2:${msg_type2} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../run-testset.sh ${vmrs} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]}
