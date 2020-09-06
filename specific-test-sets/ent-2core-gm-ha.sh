#!/bin/bash
#Test set (guaranteed messaging) to run against a small enterprise software broker (2 cores)
vmrs="${1}" #broker IP/DNS
testsetprefix="2core-ha"
msg_type="persistent"

# Tests are being passed in as arrays. 
# An array can have several tests separated by space.
# Each test need to be in the format:
# msg_size:fanout_number:overall_msg_rate:number_of_publisher_hosts:msg_type
# Several (up to 7) arrays/testsets can be passed in, if separated by ;

testarray1=""\
"512:1:15000:1:${msg_type} "\
"512:2:30000:1:${msg_type} "\
"512:5:63000:1:${msg_type} "\
"512:10:95000:1:${msg_type} "\
"512:50:135000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:13000:1:${msg_type} "\
"1021:2:26000:1:${msg_type} "\
"1024:5:58000:1:${msg_type} "\
"1024:10:88000:1:${msg_type} "\
"1024:50:122000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:12000:1:${msg_type} "\
"2048:2:23000:1:${msg_type} "\
"2048:5:51000:1:${msg_type} "\
"2048:10:76000:1:${msg_type} "\
"2048:50:105000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray4=""\
"4096:1:9000:1:${msg_type} "\
"4096:2:19000:1:${msg_type} "\
"4096:5:37000:1:${msg_type} "\
"4096:10:49000:1:${msg_type} "\
"4096:50:68000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray5=""\
"20480:1:2000:1:${msg_type} "\
"20480:2:4000:1:${msg_type} "\
"20480:5:8000:1:${msg_type} "\
"20480:10:8000:1:${msg_type} "\
"20480:50:8000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray6=""\
"51200:1:1500:1:${msg_type} "\
"51200:2:1500:1:${msg_type} "\
"51200:5:3000:1:${msg_type} "\
"51200:10:3000:1:${msg_type} "\
"51200:50:3000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray7=""\
"102400:1:600:1:${msg_type} "\
"102400:2:1000:1:${msg_type} "\
"102400:5:1300:1:${msg_type} "\
"102400:10:2000:1:${msg_type} "\
"102400:50:2000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../run-testset.sh ${vmrs} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]} ${testarray7[@]}
