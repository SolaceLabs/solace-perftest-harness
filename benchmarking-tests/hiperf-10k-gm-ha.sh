#!/bin/bash
# Benchmarking test (guaranteed messaging, HA) — high-performance on-prem, 10k tier
# Reference: SolOS 10.8.1 SW broker
# Target hardware: modern AMD EPYC or Intel Xeon server, NVMe SSD, 25GbE NIC, no TLS, HA
# 4 pub hosts for f1-f10; 2 pub hosts for f50
broker="${1}" #broker IP/DNS
testsetprefix="hiperf-10k-ha"
msg_type="persistent"

# Tests are being passed in as arrays.
# An array can have several tests separated by space.
# Each test need to be in the format:
# msg_size:fanout_number:overall_msg_rate:number_of_publisher_hosts:msg_type
# Several (up to 7) arrays/testsets can be passed in, if separated by ;

testarray1=""\
"512:1:194000:4:${msg_type} "\
"512:2:364000:4:${msg_type} "\
"512:5:653000:4:${msg_type} "\
"512:10:1042000:4:${msg_type} "\
"512:50:1146000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:161000:4:${msg_type} "\
"1024:2:280000:4:${msg_type} "\
"1024:5:568000:4:${msg_type} "\
"1024:10:836000:4:${msg_type} "\
"1024:50:920000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:136000:4:${msg_type} "\
"2048:2:213000:4:${msg_type} "\
"2048:5:433000:4:${msg_type} "\
"2048:10:575000:4:${msg_type} "\
"2048:50:633000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray4=""\
"4096:1:85000:4:${msg_type} "\
"4096:2:150000:4:${msg_type} "\
"4096:5:269000:4:${msg_type} "\
"4096:10:305000:4:${msg_type} "\
"4096:50:336000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray5=""\
"20480:1:28000:4:${msg_type} "\
"20480:2:42000:4:${msg_type} "\
"20480:5:58000:4:${msg_type} "\
"20480:10:64000:4:${msg_type} "\
"20480:50:70000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray6=""\
"51200:1:11200:4:${msg_type} "\
"51200:2:16800:4:${msg_type} "\
"51200:5:23000:4:${msg_type} "\
"51200:10:25600:4:${msg_type} "\
"51200:50:28200:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray7=""\
"102400:1:4300:4:${msg_type} "\
"102400:2:7600:4:${msg_type} "\
"102400:5:11600:4:${msg_type} "\
"102400:10:13000:4:${msg_type} "\
"102400:50:14300:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../engine/run-testset.sh ${broker} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]} ${testarray7[@]}
