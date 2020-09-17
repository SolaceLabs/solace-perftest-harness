#!/bin/bash
#Test set (direct messaging) to run against a small enterprise software broker (2 cores)
vmrs="${1}" #broker IP/DNS
testsetprefix="ent-2core-max"
msg_type="mixed"
msg_type1="direct"
msg_type2="persistent"

# Tests are being passed in as arrays. 
# An array can have several tests separated by space.
# Each test need to be in the format:
# msg_size:fanout_number:number_of_publisher_hosts:msg_type
# Several (up to 7) arrays/testsets can be passed in, if separated by ;

testarray1=""\
"100:1:1:${msg_type1} "\
"100:2:1:${msg_type1} "\
"100:5:1:${msg_type1} "\
"100:10:1:${msg_type1} "\
"100:50:1:${msg_type1} "\
"100:100:1:${msg_type1} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:1:${msg_type2} "\
"1024:2:1:${msg_type2} "\
"1024:5:1:${msg_type2} "\
"1024:10:1:${msg_type2} "\
"1024:50:1:${msg_type2} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../run-smart-testset.sh ${vmrs} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]}
