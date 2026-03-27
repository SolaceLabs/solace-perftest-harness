#!/bin/bash
#Test set (direct messaging) to run against a large enterprise software broker (8 cores)
broker="${1}" #broker IP/DNS
testsetprefix="8core"
msg_type="direct"

# Tests are being passed in as arrays. 
# An array can have several tests separated by space.
# Each test need to be in the format:
# msg_size:fanout_number:overall_msg_rate:number_of_publisher_hosts:msg_type
# Several (up to 7) arrays/testsets can be passed in, if separated by ;

testarray1=""\
"100:1:1300000:4:${msg_type} "\
"100:2:1550000:4:${msg_type} "\
"100:5:3000000:4:${msg_type} "\
"100:10:3300000:4:${msg_type} "\
"100:50:4000000:2:${msg_type} "\
"100:100:4000000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:716000:4:${msg_type} "\
"1024:2:826000:4:${msg_type} "\
"1024:5:1000000:4:${msg_type} "\
"1024:10:1100000:4:${msg_type} "\
"1024:50:1100000:2:${msg_type} "\
"1024:100:1200000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:439000:4:${msg_type} "\
"2048:2:650000:4:${msg_type} "\
"2048:5:520000:4:${msg_type} "\
"2048:10:610000:4:${msg_type} "\
"2048:50:650000:2:${msg_type} "\
"2048:100:725000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;

testarray4=""\
"10240:1:100000:4:${msg_type} "\
"10240:2:132000:4:${msg_type} "\
"10240:5:110000:4:${msg_type} "\
"10240:10:140000:4:${msg_type} "\
"10240:50:120000:2:${msg_type} "\
"10240:100:110000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;

testarray5=""\
"20480:1:50000:4:${msg_type} "\
"20480:2:65000:4:${msg_type} "\
"20480:5:110000:4:${msg_type} "\
"20480:10:80000:4:${msg_type} "\
"20480:50:38000:2:${msg_type} "\
"20480:100:38000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;

testarray6=""\
"51200:1:20000:4:${msg_type} "\
"51200:2:26000:4:${msg_type} "\
"51200:5:27000:4:${msg_type} "\
"51200:10:26000:4:${msg_type} "\
"51200:50:23000:2:${msg_type} "\
"51200:100:22000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;

testarray7=""\
"102400:1:10000:4:${msg_type} "\
"102400:2:13000:4:${msg_type} "\
"102400:5:14000:4:${msg_type} "\
"102400:10:13000:4:${msg_type} "\
"102400:50:13000:2:${msg_type} "\
"102400:100:11000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../engine/run-testset.sh ${broker} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]} ${testarray7[@]}
