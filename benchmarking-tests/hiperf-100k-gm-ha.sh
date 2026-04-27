#!/bin/bash
# Benchmarking test (guaranteed messaging, HA) — high-performance on-prem, 100k tier (8 physical cores)
# Reference: SolOS 10.8.1 SW broker spreadsheet (AMD Ryzen 9 3900X, NVMe, 10GbE) × 1.25 (no-TLS uplift)
# Target hardware: modern AMD EPYC or Intel Xeon server, NVMe SSD, 25GbE NIC, no TLS, HA
# 4 pub hosts for f1-f10; 2 pub hosts for f50
broker="${1}" #broker IP/DNS
testsetprefix="hiperf-100k-ha"
msg_type="persistent"

# Tests are being passed in as arrays.
# An array can have several tests separated by space.
# Each test need to be in the format:
# msg_size:fanout_number:overall_msg_rate:number_of_publisher_hosts:msg_type
# Several (up to 7) arrays/testsets can be passed in, if separated by ;

testarray1=""\
"512:1:260000:4:${msg_type} "\
"512:2:466000:4:${msg_type} "\
"512:5:920000:4:${msg_type} "\
"512:10:1421000:4:${msg_type} "\
"512:50:1563000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:224000:4:${msg_type} "\
"1024:2:389000:4:${msg_type} "\
"1024:5:730000:4:${msg_type} "\
"1024:10:1031000:4:${msg_type} "\
"1024:50:1134000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:166000:4:${msg_type} "\
"2048:2:282000:4:${msg_type} "\
"2048:5:513000:4:${msg_type} "\
"2048:10:575000:4:${msg_type} "\
"2048:50:633000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray4=""\
"4096:1:115000:4:${msg_type} "\
"4096:2:197000:4:${msg_type} "\
"4096:5:276000:4:${msg_type} "\
"4096:10:305000:4:${msg_type} "\
"4096:50:336000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray5=""\
"20480:1:34000:4:${msg_type} "\
"20480:2:46500:4:${msg_type} "\
"20480:5:58000:4:${msg_type} "\
"20480:10:64000:4:${msg_type} "\
"20480:50:70000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray6=""\
"51200:1:13600:4:${msg_type} "\
"51200:2:18600:4:${msg_type} "\
"51200:5:23000:4:${msg_type} "\
"51200:10:25600:4:${msg_type} "\
"51200:50:28200:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray7=""\
"102400:1:4000:4:${msg_type} "\
"102400:2:9400:4:${msg_type} "\
"102400:5:11800:4:${msg_type} "\
"102400:10:13000:4:${msg_type} "\
"102400:50:14300:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../engine/run-testset.sh ${broker} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]} ${testarray7[@]}
