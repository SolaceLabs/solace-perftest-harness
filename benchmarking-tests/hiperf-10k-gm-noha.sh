#!/bin/bash
# Benchmarking test (guaranteed messaging, non-HA) — high-performance on-prem, 10k tier
# Reference: SolOS 10.8.1 SW broker
# Target hardware: modern AMD EPYC or Intel Xeon server, NVMe SSD, 25GbE NIC, no TLS, non-HA
# 4 pub hosts for f1-f10; 2 pub hosts for f50
broker="${1}" #broker IP/DNS
testsetprefix="hiperf-10k-noha"
msg_type="persistent"

# Tests are being passed in as arrays.
# An array can have several tests separated by space.
# Each test need to be in the format:
# msg_size:fanout_number:overall_msg_rate:number_of_publisher_hosts:msg_type
# Several (up to 7) arrays/testsets can be passed in, if separated by ;

testarray1=""\
"512:1:272000:4:${msg_type} "\
"512:2:510000:4:${msg_type} "\
"512:5:686000:4:${msg_type} "\
"512:10:1094000:4:${msg_type} "\
"512:50:1203000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:225000:4:${msg_type} "\
"1024:2:392000:4:${msg_type} "\
"1024:5:596000:4:${msg_type} "\
"1024:10:878000:4:${msg_type} "\
"1024:50:966000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:190000:4:${msg_type} "\
"2048:2:298000:4:${msg_type} "\
"2048:5:455000:4:${msg_type} "\
"2048:10:604000:4:${msg_type} "\
"2048:50:664000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray4=""\
"4096:1:119000:4:${msg_type} "\
"4096:2:210000:4:${msg_type} "\
"4096:5:282000:4:${msg_type} "\
"4096:10:320000:4:${msg_type} "\
"4096:50:353000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray5=""\
"20480:1:39000:4:${msg_type} "\
"20480:2:59000:4:${msg_type} "\
"20480:5:61000:4:${msg_type} "\
"20480:10:67000:4:${msg_type} "\
"20480:50:74000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray6=""\
"51200:1:15700:4:${msg_type} "\
"51200:2:23500:4:${msg_type} "\
"51200:5:24200:4:${msg_type} "\
"51200:10:26900:4:${msg_type} "\
"51200:50:29600:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray7=""\
"102400:1:6000:4:${msg_type} "\
"102400:2:10600:4:${msg_type} "\
"102400:5:12200:4:${msg_type} "\
"102400:10:13700:4:${msg_type} "\
"102400:50:15000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../engine/run-testset.sh ${broker} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]} ${testarray7[@]}
