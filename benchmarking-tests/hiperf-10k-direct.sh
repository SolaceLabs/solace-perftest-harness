#!/bin/bash
# Benchmarking test (direct messaging) — high-performance on-prem, 10k tier (4 physical cores)
# Reference: SolOS 10.8.1 SW broker spreadsheet (AMD Ryzen 9 3900X, NVMe, 10GbE) × 1.25 (no-TLS uplift)
# Target hardware: modern AMD EPYC or Intel Xeon server, NVMe SSD, 25GbE NIC, no TLS
# Note: 51200B/102400B derived from 20480B bandwidth; plateau scenarios assume 25GbE+ NIC
# 4 pub hosts for f1-f10; 2 pub hosts for f50
broker="${1}" #broker IP/DNS
testsetprefix="hiperf-10k"
msg_type="direct"

# Tests are being passed in as arrays.
# An array can have several tests separated by space.
# Each test need to be in the format:
# msg_size:fanout_number:overall_msg_rate:number_of_publisher_hosts:msg_type
# Several (up to 7) arrays/testsets can be passed in, if separated by ;

testarray1=""\
"100:1:2930000:4:${msg_type} "\
"100:2:4150000:4:${msg_type} "\
"100:5:8730000:4:${msg_type} "\
"100:10:11030000:4:${msg_type} "\
"100:50:11500000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:486000:4:${msg_type} "\
"1024:2:790000:4:${msg_type} "\
"1024:5:1356000:4:${msg_type} "\
"1024:10:1386000:4:${msg_type} "\
"1024:50:1420000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:296000:4:${msg_type} "\
"2048:2:501000:4:${msg_type} "\
"2048:5:703000:4:${msg_type} "\
"2048:10:701000:4:${msg_type} "\
"2048:50:720000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray4=""\
"10240:1:68000:4:${msg_type} "\
"10240:2:112000:4:${msg_type} "\
"10240:5:143000:4:${msg_type} "\
"10240:10:142000:4:${msg_type} "\
"10240:50:145000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray5=""\
"20480:1:37000:4:${msg_type} "\
"20480:2:58000:4:${msg_type} "\
"20480:5:72000:4:${msg_type} "\
"20480:10:71000:4:${msg_type} "\
"20480:50:73000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray6=""\
"51200:1:15000:4:${msg_type} "\
"51200:2:23000:4:${msg_type} "\
"51200:5:29000:4:${msg_type} "\
"51200:10:29000:4:${msg_type} "\
"51200:50:30000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray7=""\
"102400:1:7500:4:${msg_type} "\
"102400:2:12000:4:${msg_type} "\
"102400:5:14000:4:${msg_type} "\
"102400:10:14000:4:${msg_type} "\
"102400:50:14500:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../engine/run-testset.sh ${broker} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]} ${testarray7[@]}
