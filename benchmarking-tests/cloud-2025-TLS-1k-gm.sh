#!/bin/bash
# Benchmarking test (guaranteed messaging) — Solace Cloud 1k, combined AWS+GCP minimum
# Passes on both: AWS r5.large (2 vCPU) and GCP n1-standard-4 (4 vCPU, Intel Haswell)
# Targets = min(AWS, GCP) per scenario — TLSv1.2 AES256-GCM-SHA384, HA + encrypted mate-link
# Note: AWS limits every scenario (EBS GP2 IOPS-bound); GCP SSD_PD delivers substantially higher rates
# Note: 204800B has non-monotonic f50 (measurement noise from AWS source data)
broker="${1}" #broker IP/DNS
testsetprefix="cloud-2025-TLS-1k"
msg_type="persistent"

# Tests are being passed in as arrays.
# An array can have several tests separated by space.
# Each test need to be in the format:
# msg_size:fanout_number:overall_msg_rate:number_of_publisher_hosts:msg_type
# Several (up to 7) arrays/testsets can be passed in, if separated by ;

testarray1=""\
"512:1:20500:1:${msg_type} "\
"512:2:32800:1:${msg_type} "\
"512:5:53400:1:${msg_type} "\
"512:10:78600:1:${msg_type} "\
"512:50:97200:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:17000:1:${msg_type} "\
"1024:2:28500:1:${msg_type} "\
"1024:5:52700:1:${msg_type} "\
"1024:10:74300:1:${msg_type} "\
"1024:50:81100:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:13600:1:${msg_type} "\
"2048:2:23100:1:${msg_type} "\
"2048:5:36200:1:${msg_type} "\
"2048:10:39500:1:${msg_type} "\
"2048:50:42600:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray4=""\
"8192:1:4900:1:${msg_type} "\
"8192:2:7500:1:${msg_type} "\
"8192:5:9400:1:${msg_type} "\
"8192:10:10300:1:${msg_type} "\
"8192:50:11000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray5=""\
"65536:1:600:1:${msg_type} "\
"65536:2:900:1:${msg_type} "\
"65536:5:1200:1:${msg_type} "\
"65536:10:1300:1:${msg_type} "\
"65536:50:1400:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray6=""\
"204800:1:200:1:${msg_type} "\
"204800:2:300:1:${msg_type} "\
"204800:5:400:1:${msg_type} "\
"204800:10:400:1:${msg_type} "\
"204800:50:350:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../engine/run-testset.sh ${broker} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]}
