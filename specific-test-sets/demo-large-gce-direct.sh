#!/bin/bash
# Demo script to show off perf tests with a subset of tests against a large GCE VMR
vmrs="10.132.0.16,10.132.0.17" #large GCE VMRs
testsetprefix="demo"
msg_type="direct"

testarray1=""\
"100:1:1300000:4:${msg_type} "\
"100:2:1550000:4:${msg_type} "\
"100:5:3000000:4:${msg_type} "\
"100:10:3300000:4:${msg_type} "\
"100:50:4000000:2:${msg_type} "\
"100:100:4000000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:716000:4:${msg_type} "\
"1024:2:826000:4:${msg_type} "\
"1024:5:1000000:4:${msg_type} "\
"1024:10:1100000:4:${msg_type} "\
"1024:50:1100000:2:${msg_type} "\
"1024:100:1200000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:439000:4:${msg_type} "\
"2048:2:650000:4:${msg_type} "\
"2048:5:520000:4:${msg_type} "\
"2048:10:610000:4:${msg_type} "\
"2048:50:650000:2:${msg_type} "\
"2048:100:725000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;

testarray4=""\
"10240:1:100000:4:${msg_type} "\
"10240:2:132000:4:${msg_type} "\
"10240:5:110000:4:${msg_type} "\
"10240:10:140000:4:${msg_type} "\
"10240:50:120000:2:${msg_type} "\
"10240:100:110000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../run-testset.sh ${vmrs} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]}
