#!/bin/bash
# Benchmarking test (guaranteed messaging) — Solace Cloud 100k, combined AWS+GCP minimum
# Passes on both: AWS r6in.4xlarge (16 vCPU) and GCP n1-standard-16 (16 vCPU, Intel Haswell)
# Targets = min(AWS, GCP) per scenario — TLSv1.2 AES256-GCM-SHA384, HA + encrypted mate-link
# Note: GCP limits small-message/high-fanout scenarios (CPU-bound); AWS limits large-message/low-fanout (IOPS-bound)
broker="${1}" #broker IP/DNS
testsetprefix="cloud-2025-TLS-100k"
msg_type="persistent"

# Tests are being passed in as arrays.
# An array can have several tests separated by space.
# Each test need to be in the format:
# msg_size:fanout_number:overall_msg_rate:number_of_publisher_hosts:msg_type
# Several (up to 7) arrays/testsets can be passed in, if separated by ;

testarray1=""\
"512:1:80800:1:${msg_type} "\
"512:2:146600:1:${msg_type} "\
"512:5:303100:1:${msg_type} "\
"512:10:492000:1:${msg_type} "\
"512:50:585000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:72600:1:${msg_type} "\
"1024:2:131800:1:${msg_type} "\
"1024:5:272300:1:${msg_type} "\
"1024:10:442000:1:${msg_type} "\
"1024:50:454100:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:54400:1:${msg_type} "\
"2048:2:103000:1:${msg_type} "\
"2048:5:202600:1:${msg_type} "\
"2048:10:304700:1:${msg_type} "\
"2048:50:310500:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray4=""\
"8192:1:15100:1:${msg_type} "\
"8192:2:30100:1:${msg_type} "\
"8192:5:73900:1:${msg_type} "\
"8192:10:105200:1:${msg_type} "\
"8192:50:112000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray5=""\
"65536:1:1900:1:${msg_type} "\
"65536:2:3800:1:${msg_type} "\
"65536:5:9500:1:${msg_type} "\
"65536:10:14200:1:${msg_type} "\
"65536:50:14200:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray6=""\
"204800:1:600:1:${msg_type} "\
"204800:2:1200:1:${msg_type} "\
"204800:5:3000:1:${msg_type} "\
"204800:10:3600:1:${msg_type} "\
"204800:50:4500:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../engine/run-testset.sh ${broker} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]}
