#!/bin/bash
# Benchmarking test (direct messaging) — Solace Cloud 10k, combined AWS+GCP minimum
# Passes on both: AWS r6in.xlarge (4 vCPU) and GCP n1-standard-8 (8 vCPU, Intel Haswell)
# Targets = min(AWS, GCP) per scenario — TLSv1.2 AES256-GCM-SHA384, HA + encrypted mate-link
# Note: 10240B/20480B/51200B are flat across all fanouts — GCP NIC-limited at those sizes
broker="${1}" #broker IP/DNS
testsetprefix="cloud-2025-TLS-10k"
msg_type="direct"

# Tests are being passed in as arrays.
# An array can have several tests separated by space.
# Each test need to be in the format:
# msg_size:fanout_number:overall_msg_rate:number_of_publisher_hosts:msg_type
# Several (up to 7) arrays/testsets can be passed in, if separated by ;

testarray1=""\
"100:1:379200:1:${msg_type} "\
"100:2:719600:1:${msg_type} "\
"100:5:1628000:1:${msg_type} "\
"100:10:1678100:1:${msg_type} "\
"100:50:1678100:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:119300:1:${msg_type} "\
"1024:2:204700:1:${msg_type} "\
"1024:5:219100:1:${msg_type} "\
"1024:10:219100:1:${msg_type} "\
"1024:50:219100:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:74900:1:${msg_type} "\
"2048:2:109600:1:${msg_type} "\
"2048:5:109600:1:${msg_type} "\
"2048:10:109600:1:${msg_type} "\
"2048:50:109600:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray4=""\
"10240:1:21700:1:${msg_type} "\
"10240:2:21700:1:${msg_type} "\
"10240:5:21700:1:${msg_type} "\
"10240:10:21700:1:${msg_type} "\
"10240:50:21700:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray5=""\
"20480:1:10900:1:${msg_type} "\
"20480:2:10900:1:${msg_type} "\
"20480:5:10900:1:${msg_type} "\
"20480:10:10900:1:${msg_type} "\
"20480:50:10900:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray6=""\
"51200:1:4400:1:${msg_type} "\
"51200:2:4400:1:${msg_type} "\
"51200:5:4400:1:${msg_type} "\
"51200:10:4400:1:${msg_type} "\
"51200:50:4400:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../engine/run-testset.sh ${broker} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]}
