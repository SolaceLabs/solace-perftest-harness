#!/bin/bash
# Benchmarking test (guaranteed messaging, non-HA) — high-performance on-prem, 100k tier
# Reference: SolOS 10.8.1 SW broker
# Target hardware: modern AMD EPYC or Intel Xeon server, NVMe SSD, 25GbE NIC, no TLS, non-HA
# 4 pub hosts for f1-f10; 2 pub hosts for f50
broker="${1}" #broker IP/DNS
testsetprefix="hiperf-100k-noha"
msg_type="persistent"
test_type="${msg_type}"

# Tests are being passed in as arrays.
# An array can have several tests separated by space.
# Each test need to be in the format:
# msg_size:fanout_number:overall_msg_rate:number_of_publisher_hosts:msg_type
# Several (up to 7) arrays/testsets can be passed in, if separated by ;

testarray1=""\
"512:1:364000:4:${msg_type} "\
"512:2:652000:4:${msg_type} "\
"512:5:966000:4:${msg_type} "\
"512:10:1492000:4:${msg_type} "\
"512:50:1641000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:314000:4:${msg_type} "\
"1024:2:545000:4:${msg_type} "\
"1024:5:767000:4:${msg_type} "\
"1024:10:1083000:4:${msg_type} "\
"1024:50:1191000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:232000:4:${msg_type} "\
"2048:2:395000:4:${msg_type} "\
"2048:5:539000:4:${msg_type} "\
"2048:10:604000:4:${msg_type} "\
"2048:50:664000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray4=""\
"4096:1:161000:4:${msg_type} "\
"4096:2:276000:4:${msg_type} "\
"4096:5:290000:4:${msg_type} "\
"4096:10:320000:4:${msg_type} "\
"4096:50:353000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray5=""\
"20480:1:48000:4:${msg_type} "\
"20480:2:65000:4:${msg_type} "\
"20480:5:61000:4:${msg_type} "\
"20480:10:67000:4:${msg_type} "\
"20480:50:74000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray6=""\
"51200:1:19000:4:${msg_type} "\
"51200:2:26000:4:${msg_type} "\
"51200:5:24200:4:${msg_type} "\
"51200:10:26900:4:${msg_type} "\
"51200:50:29600:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray7=""\
"102400:1:5600:4:${msg_type} "\
"102400:2:13200:4:${msg_type} "\
"102400:5:12400:4:${msg_type} "\
"102400:10:13700:4:${msg_type} "\
"102400:50:15000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../engine/run-testset.sh ${broker} ${testsetprefix} ${test_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]} ${testarray7[@]}
