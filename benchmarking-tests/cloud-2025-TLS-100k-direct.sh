#!/bin/bash
# Benchmarking test (direct messaging) — Solace Cloud 100k, combined AWS+GCP minimum
# Passes on both: AWS r6in.4xlarge (16 vCPU) and GCP n1-standard-16 (16 vCPU, Intel Haswell)
# Targets = min(AWS, GCP) per scenario — TLSv1.2 AES256-GCM-SHA384, HA + encrypted mate-link
# Note: 10240B/20480B/51200B are flat across all fanouts — GCP NIC-limited at those sizes
# Note: 10240B has slight non-monotonicity at f2 (measurement noise from GCP source data)
broker="${1}" #broker IP/DNS
testsetprefix="cloud-2025-TLS-100k"
msg_type="direct"

# Tests are being passed in as arrays.
# An array can have several tests separated by space.
# Each test need to be in the format:
# msg_size:fanout_number:overall_msg_rate:number_of_publisher_hosts:msg_type
# Several (up to 7) arrays/testsets can be passed in, if separated by ;

testarray1=""\
"100:1:632100:2:${msg_type} "\
"100:2:1208800:2:${msg_type} "\
"100:5:2630700:2:${msg_type} "\
"100:10:3524300:2:${msg_type} "\
"100:50:3524100:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:200500:1:${msg_type} "\
"1024:2:360100:1:${msg_type} "\
"1024:5:417400:1:${msg_type} "\
"1024:10:438300:1:${msg_type} "\
"1024:50:438300:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:126200:1:${msg_type} "\
"2048:2:207000:1:${msg_type} "\
"2048:5:219200:1:${msg_type} "\
"2048:10:219200:1:${msg_type} "\
"2048:50:219200:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray4=""\
"10240:1:43500:1:${msg_type} "\
"10240:2:45500:1:${msg_type} "\
"10240:5:43500:1:${msg_type} "\
"10240:10:43500:1:${msg_type} "\
"10240:50:43500:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray5=""\
"20480:1:21800:1:${msg_type} "\
"20480:2:21900:1:${msg_type} "\
"20480:5:21900:1:${msg_type} "\
"20480:10:21900:1:${msg_type} "\
"20480:50:21900:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray6=""\
"51200:1:8800:1:${msg_type} "\
"51200:2:8800:1:${msg_type} "\
"51200:5:8800:1:${msg_type} "\
"51200:10:8800:1:${msg_type} "\
"51200:50:8800:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../engine/run-testset.sh ${broker} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]}
