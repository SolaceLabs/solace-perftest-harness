#!/bin/bash
# Benchmarking test (direct messaging) — high-performance on-prem, 1k tier
# Reference: SolOS 10.8.1 SW broker 
# Target hardware: modern AMD EPYC or Intel Xeon server, NVMe SSD, 25GbE NIC, no TLS
# Note: 51200B/102400B derived from 20480B bandwidth; plateau scenarios assume 25GbE+ NIC
# 2 pub hosts for 100B (high pps load); 1 pub host for all other sizes
broker="${1}" #broker IP/DNS
testsetprefix="hiperf-1k"
msg_type="direct"

# Tests are being passed in as arrays.
# An array can have several tests separated by space.
# Each test need to be in the format:
# msg_size:fanout_number:overall_msg_rate:number_of_publisher_hosts:msg_type
# Several (up to 7) arrays/testsets can be passed in, if separated by ;

testarray1=""\
"100:1:2460000:2:${msg_type} "\
"100:2:3960000:2:${msg_type} "\
"100:5:7300000:2:${msg_type} "\
"100:10:10300000:2:${msg_type} "\
"100:50:10800000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:590000:1:${msg_type} "\
"1024:2:940000:1:${msg_type} "\
"1024:5:1320000:1:${msg_type} "\
"1024:10:1350000:1:${msg_type} "\
"1024:50:1370000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:400000:1:${msg_type} "\
"2048:2:640000:1:${msg_type} "\
"2048:5:660000:1:${msg_type} "\
"2048:10:680000:1:${msg_type} "\
"2048:50:690000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray4=""\
"10240:1:84000:1:${msg_type} "\
"10240:2:132000:1:${msg_type} "\
"10240:5:139000:1:${msg_type} "\
"10240:10:139000:1:${msg_type} "\
"10240:50:140000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray5=""\
"20480:1:59000:1:${msg_type} "\
"20480:2:68000:1:${msg_type} "\
"20480:5:70000:1:${msg_type} "\
"20480:10:70000:1:${msg_type} "\
"20480:50:71000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray6=""\
"51200:1:23000:1:${msg_type} "\
"51200:2:28000:1:${msg_type} "\
"51200:5:35000:1:${msg_type} "\
"51200:10:35000:1:${msg_type} "\
"51200:50:36000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray7=""\
"102400:1:12000:1:${msg_type} "\
"102400:2:14000:1:${msg_type} "\
"102400:5:17000:1:${msg_type} "\
"102400:10:17000:1:${msg_type} "\
"102400:50:17500:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../engine/run-testset.sh ${broker} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]} ${testarray7[@]}
