#!/bin/bash
#Test set (guaranteed messaging) to run against a small enterprise software broker (2 cores) (no redundancy)
broker="${1}" #broker IP/DNS
testsetprefix="1k-noha"
msg_type="persistent"

# Tests are being passed in as arrays. 
# An array can have several tests separated by space.
# Each test need to be in the format:
# msg_size:fanout_number:overall_msg_rate:number_of_publisher_hosts:msg_type
# Several (up to 7) arrays/testsets can be passed in, if separated by ;

testarray1=""\
"512:1:20000:1:${msg_type} "\
"512:2:35000:1:${msg_type} "\
"512:5:70000:1:${msg_type} "\
"512:10:100000:1:${msg_type} "\
"512:50:135000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:20000:1:${msg_type} "\
"1024:2:35000:1:${msg_type} "\
"1024:5:70000:1:${msg_type} "\
"1024:10:90000:1:${msg_type} "\
"1024:50:125000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:18000:1:${msg_type} "\
"2048:2:30000:1:${msg_type} "\
"2048:5:55000:1:${msg_type} "\
"2048:10:67000:1:${msg_type} "\
"2048:50:110000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray4=""\
"4096:1:15000:1:${msg_type} "\
"4096:2:28000:1:${msg_type} "\
"4096:5:40000:1:${msg_type} "\
"4096:10:50000:1:${msg_type} "\
"4096:50:54000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray5=""\
"20480:1:3500:1:${msg_type} "\
"20480:2:6000:1:${msg_type} "\
"20480:5:8000:1:${msg_type} "\
"20480:10:10000:1:${msg_type} "\
"20480:50:10000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray6=""\
"51200:1:1100:1:${msg_type} "\
"51200:2:2000:1:${msg_type} "\
"51200:5:4000:1:${msg_type} "\
"51200:10:2500:1:${msg_type} "\
"51200:50:2000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray7=""\
"102400:1:600:1:${msg_type} "\
"102400:2:1000:1:${msg_type} "\
"102400:5:1500:1:${msg_type} "\
"102400:10:2000:1:${msg_type} "\
"102400:50:2000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../engine/run-testset.sh ${broker} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]} ${testarray7[@]}
