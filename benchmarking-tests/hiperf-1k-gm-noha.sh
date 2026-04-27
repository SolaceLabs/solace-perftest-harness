#!/bin/bash
# Benchmarking test (guaranteed messaging, non-HA) — high-performance on-prem, 1k tier (2 physical cores)
# Reference: SolOS 10.8.1 SW broker spreadsheet × 1.25 (no-TLS) × 1.4 f1/f2 uplift for no mate-link writes
# Target hardware: modern AMD EPYC or Intel Xeon server, NVMe SSD, 25GbE NIC, no TLS, non-HA
broker="${1}" #broker IP/DNS
testsetprefix="hiperf-1k-noha"
msg_type="persistent"

# Tests are being passed in as arrays.
# An array can have several tests separated by space.
# Each test need to be in the format:
# msg_size:fanout_number:overall_msg_rate:number_of_publisher_hosts:msg_type
# Several (up to 7) arrays/testsets can be passed in, if separated by ;

testarray1=""\
"512:1:172000:1:${msg_type} "\
"512:2:318000:1:${msg_type} "\
"512:5:477000:1:${msg_type} "\
"512:10:791000:1:${msg_type} "\
"512:50:870000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:155000:1:${msg_type} "\
"1024:2:288000:1:${msg_type} "\
"1024:5:427000:1:${msg_type} "\
"1024:10:648000:1:${msg_type} "\
"1024:50:713000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:118000:1:${msg_type} "\
"2048:2:220000:1:${msg_type} "\
"2048:5:326000:1:${msg_type} "\
"2048:10:485000:1:${msg_type} "\
"2048:50:534000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray4=""\
"4096:1:87000:1:${msg_type} "\
"4096:2:154000:1:${msg_type} "\
"4096:5:222000:1:${msg_type} "\
"4096:10:306000:1:${msg_type} "\
"4096:50:337000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray5=""\
"20480:1:27000:1:${msg_type} "\
"20480:2:46000:1:${msg_type} "\
"20480:5:59000:1:${msg_type} "\
"20480:10:67000:1:${msg_type} "\
"20480:50:74000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray6=""\
"51200:1:10400:1:${msg_type} "\
"51200:2:19600:1:${msg_type} "\
"51200:5:23500:1:${msg_type} "\
"51200:10:26800:1:${msg_type} "\
"51200:50:29500:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray7=""\
"102400:1:5000:1:${msg_type} "\
"102400:2:9900:1:${msg_type} "\
"102400:5:11800:1:${msg_type} "\
"102400:10:13300:1:${msg_type} "\
"102400:50:14700:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../engine/run-testset.sh ${broker} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]} ${testarray7[@]}
