#!/bin/bash
#Test set (direct messaging) to run against a medium enterprise software broker (4 cores)
broker="${1}" #broker IP/DNS
testsetprefix="4core"
msg_type="direct"

# Tests are being passed in as arrays. 
# An array can have several tests separated by space.
# Each test need to be in the format:
# msg_size:fanout_number:overall_msg_rate:number_of_publisher_hosts:msg_type
# Several (up to 7) arrays/testsets can be passed in, if separated by ;

testarray1=""\
"100:1:1000000:4:${msg_type} "\
"100:2:1550000:4:${msg_type} "\
"100:5:2000000:4:${msg_type} "\
"100:10:2100000:4:${msg_type} "\
"100:50:2800000:2:${msg_type} "\
"100:100:2800000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:550000:4:${msg_type} "\
"1024:2:790000:4:${msg_type} "\
"1024:5:550000:4:${msg_type} "\
"1024:10:650000:4:${msg_type} "\
"1024:50:850000:2:${msg_type} "\
"1024:100:920000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:433000:4:${msg_type} "\
"2048:2:550000:4:${msg_type} "\
"2048:5:550000:4:${msg_type} "\
"2048:10:550000:4:${msg_type} "\
"2048:50:550000:2:${msg_type} "\
"2048:100:550000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray4=""\
"10240:1:90000:4:${msg_type} "\
"10240:2:95000:4:${msg_type} "\
"10240:5:95000:4:${msg_type} "\
"10240:10:95000:4:${msg_type} "\
"10240:50:95000:2:${msg_type} "\
"10240:100:95000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray5=""\
"20480:1:45000:4:${msg_type} "\
"20480:2:50000:4:${msg_type} "\
"20480:5:50000:4:${msg_type} "\
"20480:10:50000:4:${msg_type} "\
"20480:50:50000:2:${msg_type} "\
"20480:100:50000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray6=""\
"51200:1:18000:4:${msg_type} "\
"51200:2:20000:4:${msg_type} "\
"51200:5:20000:4:${msg_type} "\
"51200:10:20000:4:${msg_type} "\
"51200:50:20000:2:${msg_type} "\
"51200:100:20000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray7=""\
"102400:1:10000:4:${msg_type} "\
"102400:2:10000:4:${msg_type} "\
"102400:5:10000:4:${msg_type} "\
"102400:10:10000:4:${msg_type} "\
"102400:50:10000:2:${msg_type} "\
"102400:100:10000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../engine/run-testset.sh ${broker} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]} ${testarray7[@]}
