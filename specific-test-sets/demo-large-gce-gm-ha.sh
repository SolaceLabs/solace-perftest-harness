#!/bin/bash
# Demo script to show off perf tests with a subset of tests against a large GCE VMR
vmrs="10.132.0.16,10.132.0.17" #large GCE VMRs
testsetprefix="demo"
msg_type="persistent"

testarray1=""\
"512:1:57500:4:${msg_type} "\
"512:2:122000:4:${msg_type} "\
"512:5:220000:4:${msg_type} "\
"512:10:325000:4:${msg_type} "\
"512:50:550000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:51000:4:${msg_type} "\
"1024:2:103000:4:${msg_type} "\
"1024:5:200000:4:${msg_type} "\
"1024:10:300000:4:${msg_type} "\
"1024:50:540000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:38000:4:${msg_type} "\
"2048:2:80000:4:${msg_type} "\
"2048:5:150000:4:${msg_type} "\
"2048:10:270000:4:${msg_type} "\
"2048:50:520000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray4=""\
"4096:1:26000:4:${msg_type} "\
"4096:2:50000:4:${msg_type} "\
"4096:5:118000:4:${msg_type} "\
"4096:10:123000:4:${msg_type} "\
"4096:50:290000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../run-testset.sh ${vmrs} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]}

