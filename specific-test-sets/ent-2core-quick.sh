#!/bin/bash
#Test set (direct messaging) to run against a small enterprise software broker (2 cores)
broker="${1}" #broker IP/DNS
testsetprefix="2core"
msg_type="mixed"
msg_type1="direct"
msg_type2="persistent"

# Tests are being passed in as arrays. 
# An array can have several tests separated by space.
# Each test need to be in the format:
# msg_size:fanout_number:overall_msg_rate:number_of_publisher_hosts:msg_type
# Several (up to 7) arrays/testsets can be passed in, if separated by ;

testarray1=""\
"100:1:525000:1:${msg_type1} "\
"100:2:900000:1:${msg_type1} "\
"100:5:1350000:1:${msg_type1} "\
"100:10:1350000:1:${msg_type1} "\
"100:50:1350000:1:${msg_type1} "\
"100:100:1350000:1:${msg_type1} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:20000:1:${msg_type2} "\
"1024:2:35000:1:${msg_type2} "\
"1024:5:70000:1:${msg_type2} "\
"1024:10:90000:1:${msg_type2} "\
"1024:50:125000:1:${msg_type2} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../run-testset.sh ${broker} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]}
