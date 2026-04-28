#!/bin/bash
# Benchmarking test (guaranteed messaging, HA) — high-performance on-prem, 1k tier
# Reference: SolOS 10.8.1 SW broker
# Target hardware: modern AMD EPYC or Intel Xeon server, NVMe SSD, 25GbE NIC, no TLS, HA
# Note: 51200B interpolated from 20480B/102400B bandwidth; no f50 in SW broker sheet — estimated as f10 × 1.1
broker="${1}" #broker IP/DNS
testsetprefix="hiperf-1k-ha"
msg_type="persistent"
test_type="${msg_type}"

# Tests are being passed in as arrays.
# An array can have several tests separated by space.
# Each test need to be in the format:
# msg_size:fanout_number:overall_msg_rate:number_of_publisher_hosts:msg_type
# Several (up to 7) arrays/testsets can be passed in, if separated by ;

testarray1=""\
"512:1:123000:1:${msg_type} "\
"512:2:227000:1:${msg_type} "\
"512:5:454000:1:${msg_type} "\
"512:10:754000:1:${msg_type} "\
"512:50:829000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:111000:1:${msg_type} "\
"1024:2:206000:1:${msg_type} "\
"1024:5:407000:1:${msg_type} "\
"1024:10:617000:1:${msg_type} "\
"1024:50:679000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:84000:1:${msg_type} "\
"2048:2:157000:1:${msg_type} "\
"2048:5:310000:1:${msg_type} "\
"2048:10:462000:1:${msg_type} "\
"2048:50:508000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray4=""\
"4096:1:62000:1:${msg_type} "\
"4096:2:110000:1:${msg_type} "\
"4096:5:211000:1:${msg_type} "\
"4096:10:291000:1:${msg_type} "\
"4096:50:320000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray5=""\
"20480:1:19000:1:${msg_type} "\
"20480:2:33000:1:${msg_type} "\
"20480:5:56000:1:${msg_type} "\
"20480:10:64000:1:${msg_type} "\
"20480:50:70000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray6=""\
"51200:1:7400:1:${msg_type} "\
"51200:2:14000:1:${msg_type} "\
"51200:5:22400:1:${msg_type} "\
"51200:10:25500:1:${msg_type} "\
"51200:50:28000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray7=""\
"102400:1:3600:1:${msg_type} "\
"102400:2:7100:1:${msg_type} "\
"102400:5:11200:1:${msg_type} "\
"102400:10:12700:1:${msg_type} "\
"102400:50:14000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../engine/run-testset.sh ${broker} ${testsetprefix} ${test_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]} ${testarray7[@]}
