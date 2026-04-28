#!/bin/bash
# Benchmarking test (guaranteed messaging) — Solace Cloud 10k, combined AWS+GCP minimum
# Passes on both: AWS r6in.xlarge (4 vCPU) and GCP n1-standard-8 (8 vCPU, Intel Haswell)
# Targets = min(AWS, GCP) per scenario — TLSv1.2 AES256-GCM-SHA384, HA + encrypted mate-link
# Note: GCP limits small-message/high-fanout scenarios (CPU-bound); AWS limits large-message scenarios (IOPS-bound)
# Note: 512B has slight non-monotonic f50 (measurement noise from GCP source data)
broker="${1}" #broker IP/DNS
testsetprefix="cloud-2025-TLS-10k"
msg_type="persistent"

# Tests are being passed in as arrays.
# An array can have several tests separated by space.
# Each test need to be in the format:
# msg_size:fanout_number:overall_msg_rate:number_of_publisher_hosts:msg_type
# Several (up to 7) arrays/testsets can be passed in, if separated by ;

testarray1=""\
"512:1:61900:1:${msg_type} "\
"512:2:99600:1:${msg_type} "\
"512:5:209900:1:${msg_type} "\
"512:10:283600:1:${msg_type} "\
"512:50:282600:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:54700:1:${msg_type} "\
"1024:2:91700:1:${msg_type} "\
"1024:5:145300:1:${msg_type} "\
"1024:10:220100:1:${msg_type} "\
"1024:50:282600:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:33300:1:${msg_type} "\
"2048:2:49000:1:${msg_type} "\
"2048:5:122600:1:${msg_type} "\
"2048:10:186500:1:${msg_type} "\
"2048:50:248400:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray4=""\
"8192:1:15100:1:${msg_type} "\
"8192:2:29200:1:${msg_type} "\
"8192:5:52600:1:${msg_type} "\
"8192:10:74400:1:${msg_type} "\
"8192:50:92200:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray5=""\
"65536:1:1900:1:${msg_type} "\
"65536:2:3800:1:${msg_type} "\
"65536:5:9500:1:${msg_type} "\
"65536:10:10200:1:${msg_type} "\
"65536:50:11600:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray6=""\
"204800:1:600:1:${msg_type} "\
"204800:2:1200:1:${msg_type} "\
"204800:5:3000:1:${msg_type} "\
"204800:10:3500:1:${msg_type} "\
"204800:50:3700:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../engine/run-testset.sh ${broker} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]}
