#!/bin/bash
# Benchmarking test (direct messaging) — high-performance on-prem, 100k tier
# Reference: SolOS 10.8.1 SW broker
# Target hardware: modern AMD EPYC or Intel Xeon server, NVMe SSD, 25GbE NIC, no TLS
# Note: 51200B/102400B derived from 20480B bandwidth; plateau scenarios assume 25GbE+ NIC
# 4 pub hosts for f1-f10; 2 pub hosts for f50
broker="${1}" #broker IP/DNS
testsetprefix="hiperf-100k"
msg_type="direct"

# Tests are being passed in as arrays.
# An array can have several tests separated by space.
# Each test need to be in the format:
# msg_size:fanout_number:overall_msg_rate:number_of_publisher_hosts:msg_type
# Several (up to 7) arrays/testsets can be passed in, if separated by ;

testarray1=""\
"100:1:3140000:4:${msg_type} "\
"100:2:5090000:4:${msg_type} "\
"100:5:9370000:4:${msg_type} "\
"100:10:11010000:4:${msg_type} "\
"100:50:11500000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:513000:4:${msg_type} "\
"1024:2:835000:4:${msg_type} "\
"1024:5:1374000:4:${msg_type} "\
"1024:10:1397000:4:${msg_type} "\
"1024:50:1430000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:326000:4:${msg_type} "\
"2048:2:497000:4:${msg_type} "\
"2048:5:703000:4:${msg_type} "\
"2048:10:709000:4:${msg_type} "\
"2048:50:730000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray4=""\
"10240:1:114000:4:${msg_type} "\
"10240:2:143000:4:${msg_type} "\
"10240:5:142000:4:${msg_type} "\
"10240:10:144000:4:${msg_type} "\
"10240:50:146000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray5=""\
"20480:1:71000:4:${msg_type} "\
"20480:2:72000:4:${msg_type} "\
"20480:5:72000:4:${msg_type} "\
"20480:10:72000:4:${msg_type} "\
"20480:50:73000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray6=""\
"51200:1:28000:4:${msg_type} "\
"51200:2:29000:4:${msg_type} "\
"51200:5:29000:4:${msg_type} "\
"51200:10:29000:4:${msg_type} "\
"51200:50:30000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray7=""\
"102400:1:14000:4:${msg_type} "\
"102400:2:14500:4:${msg_type} "\
"102400:5:14500:4:${msg_type} "\
"102400:10:14500:4:${msg_type} "\
"102400:50:15000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../engine/run-testset.sh ${broker} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]} ${testarray7[@]}
