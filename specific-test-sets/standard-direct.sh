#!/bin/bash
#Test set (direct messaging) to run against a small standard software broker (2 cores)
broker="${1}" #broker IP/DNS
testsetprefix="standard"
msg_type="direct"

# Tests are being passed in as arrays. 
# An array can have several tests separated by space.
# Each test need to be in the format:
# msg_size:fanout_number:overall_msg_rate:number_of_publisher_hosts:msg_type
# Several (up to 7) arrays/testsets can be passed in, if separated by ;

testarray1=""\
"100:1:10000:1:${msg_type} "\
"100:2:20000:1:${msg_type} "\
"100:5:50000:1:${msg_type} "\
"100:10:100000:1:${msg_type} "\
"100:50:1350000:1:${msg_type} "\
"100:100:1350000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:10000:1:${msg_type} "\
"1024:2:20000:1:${msg_type} "\
"1024:5:50000:1:${msg_type} "\
"1024:10:100000:1:${msg_type} "\
"1024:50:460000:1:${msg_type} "\
"1024:100:490000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:10000:1:${msg_type} "\
"2048:2:20000:1:${msg_type} "\
"2048:5:50000:1:${msg_type} "\
"2048:10:100000:1:${msg_type} "\
"2048:50:230000:1:${msg_type} "\
"2048:100:300000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray4=""\
"10240:1:10000:1:${msg_type} "\
"10240:2:20000:1:${msg_type} "\
"10240:5:44000:1:${msg_type} "\
"10240:10:45000:1:${msg_type} "\
"10240:50:46000:1:${msg_type} "\
"10240:100:46000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray5=""\
"20480:1:10000:1:${msg_type} "\
"20480:2:20000:1:${msg_type} "\
"20480:5:22000:1:${msg_type} "\
"20480:10:22000:1:${msg_type} "\
"20480:50:23000:1:${msg_type} "\
"20480:100:23000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray6=""\
"51200:1:8000:1:${msg_type} "\
"51200:2:9000:1:${msg_type} "\
"51200:5:9000:1:${msg_type} "\
"51200:10:9000:1:${msg_type} "\
"51200:50:9000:1:${msg_type} "\
"51200:100:9000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray7=""\
"102400:1:4000:1:${msg_type} "\
"102400:2:4500:1:${msg_type} "\
"102400:5:4600:1:${msg_type} "\
"102400:10:4600:1:${msg_type} "\
"102400:50:4700:1:${msg_type} "\
"102400:100:4700:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../run-testset.sh ${broker} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]} ${testarray7[@]}
