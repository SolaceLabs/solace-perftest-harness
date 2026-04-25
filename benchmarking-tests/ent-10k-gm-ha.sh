#!/bin/bash
# Benchmarking test (guaranteed messaging, HA) — self-managed software broker, 10k tier (8 vCPU)
# Reference: SolOS 10.8.x+, modern cloud VM or comparable on-prem hardware, no TLS, HA
# f1/f2 targets calibrated to match/exceed Cloud AWS 10k (TLS+HA) — our no-TLS setup should beat these
broker="${1}" #broker IP/DNS
testsetprefix="10k-ha"
msg_type="persistent"

# Tests are being passed in as arrays. 
# An array can have several tests separated by space.
# Each test need to be in the format:
# msg_size:fanout_number:overall_msg_rate:number_of_publisher_hosts:msg_type
# Several (up to 7) arrays/testsets can be passed in, if separated by ;

testarray1=""\
"512:1:80000:4:${msg_type} "\
"512:2:100000:4:${msg_type} "\
"512:5:120000:4:${msg_type} "\
"512:10:185000:4:${msg_type} "\
"512:50:240000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:70000:4:${msg_type} "\
"1024:2:85000:4:${msg_type} "\
"1024:5:123000:4:${msg_type} "\
"1024:10:195000:4:${msg_type} "\
"1024:50:195000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:50000:4:${msg_type} "\
"2048:2:60000:4:${msg_type} "\
"2048:5:87000:4:${msg_type} "\
"2048:10:128000:4:${msg_type} "\
"2048:50:128000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray4=""\
"4096:1:30000:4:${msg_type} "\
"4096:2:35000:4:${msg_type} "\
"4096:5:58000:4:${msg_type} "\
"4096:10:74000:4:${msg_type} "\
"4096:50:77000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray5=""\
"20480:1:6000:4:${msg_type} "\
"20480:2:6000:4:${msg_type} "\
"20480:5:15000:4:${msg_type} "\
"20480:10:17000:4:${msg_type} "\
"20480:50:28000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray6=""\
"51200:1:2500:4:${msg_type} "\
"51200:2:3000:4:${msg_type} "\
"51200:5:5500:4:${msg_type} "\
"51200:10:8000:4:${msg_type} "\
"51200:50:12000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray7=""\
"102400:1:1500:4:${msg_type} "\
"102400:2:2000:4:${msg_type} "\
"102400:5:3000:4:${msg_type} "\
"102400:10:3000:4:${msg_type} "\
"102400:50:5000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../engine/run-testset.sh ${broker} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]} ${testarray7[@]}
