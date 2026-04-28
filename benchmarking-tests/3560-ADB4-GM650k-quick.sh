#!/bin/bash
#Quick test set to run against a 3560 with an ADB4.
broker="${1}" #broker IP/DNS
testsetprefix="3560-ADB4-GM650k-quick"
msg_type1="direct"
msg_type2="persistent"
test_type="mixed"

# Tests are being passed in as arrays. 
# An array can have several tests separated by space.
# Each test need to be in the format:
# msg_size:fanout_number:overall_msg_rate:number_of_publisher_hosts:msg_type
# Several (up to 7) arrays/testsets can be passed in, if separated by ;

# 100B — broker CPU / packet-rate limited (spec: 12.9M at f=1, 29M at f=10)
testarray1=""\
"100:1:10000000:4:${msg_type1} "\
"100:2:12000000:4:${msg_type1} "\
"100:5:20000000:4:${msg_type1} "\
"100:10:23000000:4:${msg_type1} "\
"100:50:24000000:4:${msg_type1} "\
";" #need to  end with to separate the various test arrays;

# 1024B — disk IOPS-limited (spec: ~620k at f=1, ~3.8M at f=10; GM650 key)
testarray2=""\
"1024:1:620000:4:${msg_type2} "\
"1024:2:850000:4:${msg_type2} "\
"1024:5:1500000:4:${msg_type2} "\
"1024:10:2700000:4:${msg_type2} "\
"1024:50:4000000:4:${msg_type2} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../engine/run-testset.sh ${broker} ${testsetprefix} ${test_type} ";"${testarray1[@]} ${testarray2[@]}
