#!/bin/bash
# Benchmarking test (direct messaging) — self-managed software broker, 100k tier (16 vCPU)
# Reference: SolOS 10.8.x+, modern cloud VM or comparable on-prem hardware, no TLS, non-HA
# Targets calibrated against SW broker 10.8.1 spreadsheet (×0.45 cloud vCPU factor)
broker="${1}" #broker IP/DNS
testsetprefix="100k"
msg_type="direct"

# Tests are being passed in as arrays. 
# An array can have several tests separated by space.
# Each test need to be in the format:
# msg_size:fanout_number:overall_msg_rate:number_of_publisher_hosts:msg_type
# Several (up to 7) arrays/testsets can be passed in, if separated by ;

testarray1=""\
"100:1:1300000:4:${msg_type} "\
"100:2:1550000:4:${msg_type} "\
"100:5:3000000:4:${msg_type} "\
"100:10:3300000:4:${msg_type} "\
"100:50:4000000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:716000:4:${msg_type} "\
"1024:2:826000:4:${msg_type} "\
"1024:5:1000000:4:${msg_type} "\
"1024:10:1100000:4:${msg_type} "\
"1024:50:1100000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:439000:4:${msg_type} "\
"2048:2:650000:4:${msg_type} "\
"2048:5:700000:4:${msg_type} "\
"2048:10:720000:4:${msg_type} "\
"2048:50:750000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;

testarray4=""\
"10240:1:100000:4:${msg_type} "\
"10240:2:132000:4:${msg_type} "\
"10240:5:145000:4:${msg_type} "\
"10240:10:150000:4:${msg_type} "\
"10240:50:155000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;

testarray5=""\
"20480:1:50000:4:${msg_type} "\
"20480:2:75000:4:${msg_type} "\
"20480:5:110000:4:${msg_type} "\
"20480:10:120000:4:${msg_type} "\
"20480:50:130000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;

testarray6=""\
"51200:1:20000:4:${msg_type} "\
"51200:2:26000:4:${msg_type} "\
"51200:5:27000:4:${msg_type} "\
"51200:10:28000:4:${msg_type} "\
"51200:50:30000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;

testarray7=""\
"102400:1:10000:4:${msg_type} "\
"102400:2:13000:4:${msg_type} "\
"102400:5:14000:4:${msg_type} "\
"102400:10:15000:4:${msg_type} "\
"102400:50:16000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../engine/run-testset.sh ${broker} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]} ${testarray7[@]}
