#!/bin/bash
# Benchmarking test (direct messaging) — Solace Cloud 1k, combined AWS+GCP minimum
# Passes on both: AWS r5.large (2 vCPU) and GCP n1-standard-4 (4 vCPU, Intel Haswell)
# Targets = min(AWS, GCP) per scenario — TLSv1.2 AES256-GCM-SHA384, HA + encrypted mate-link
# Note: 20480B values are near GCP measurement noise floor; slight non-monotonicity at that size is expected
broker="${1}" #broker IP/DNS
testsetprefix="cloud-2025-TLS-1k"
msg_type="direct"
test_type="${msg_type}"

# Tests are being passed in as arrays.
# An array can have several tests separated by space.
# Each test need to be in the format:
# msg_size:fanout_number:overall_msg_rate:number_of_publisher_hosts:msg_type
# Several (up to 7) arrays/testsets can be passed in, if separated by ;

testarray1=""\
"100:1:144600:1:${msg_type} "\
"100:2:266300:1:${msg_type} "\
"100:5:450700:1:${msg_type} "\
"100:10:450700:1:${msg_type} "\
"100:50:450600:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:33200:1:${msg_type} "\
"1024:2:66400:1:${msg_type} "\
"1024:5:82800:1:${msg_type} "\
"1024:10:82800:1:${msg_type} "\
"1024:50:82800:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:17800:1:${msg_type} "\
"2048:2:35400:1:${msg_type} "\
"2048:5:43500:1:${msg_type} "\
"2048:10:43500:1:${msg_type} "\
"2048:50:43400:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray4=""\
"10240:1:8000:1:${msg_type} "\
"10240:2:9100:1:${msg_type} "\
"10240:5:9100:1:${msg_type} "\
"10240:10:9000:1:${msg_type} "\
"10240:50:9000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray5=""\
"20480:1:4350:1:${msg_type} "\
"20480:2:4250:1:${msg_type} "\
"20480:5:4500:1:${msg_type} "\
"20480:10:4350:1:${msg_type} "\
"20480:50:4500:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray6=""\
"51200:1:1800:1:${msg_type} "\
"51200:2:1800:1:${msg_type} "\
"51200:5:1730:1:${msg_type} "\
"51200:10:1770:1:${msg_type} "\
"51200:50:1800:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../engine/run-testset.sh ${broker} ${testsetprefix} ${test_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]}
