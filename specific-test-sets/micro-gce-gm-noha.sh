#!/bin/bash
#Test set (guaranteed messaging) to run against a micro GCE VMR group (2 cores - small storage 64GB persistent SSD) (no redundancy)
vmrs="10.132.0.28,10.132.0.33" #micro VMRs
testsetprefix="micro-noha"
msg_type="persistent"

testarray1=""\
"512:1:20000:2:${msg_type} "\
"512:2:35000:2:${msg_type} "\
"512:5:65000:2:${msg_type} "\
"512:10:100000:2:${msg_type} "\
"512:50:130000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:18000:2:${msg_type} "\
"1024:2:33000:2:${msg_type} "\
"1024:5:70000:2:${msg_type} "\
"1024:10:90000:3:${msg_type} "\
"1024:50:125000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:12000:2:${msg_type} "\
"2048:2:24000:2:${msg_type} "\
"2048:5:50000:3:${msg_type} "\
"2048:10:67000:3:${msg_type} "\
"2048:50:110000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray4=""\
"4096:1:7000:2:${msg_type} "\
"4096:2:14000:2:${msg_type} "\
"4096:5:30000:3:${msg_type} "\
"4096:10:50000:3:${msg_type} "\
"4096:50:54000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray5=""\
"20480:1:1500:2:${msg_type} "\
"20480:2:3000:2:${msg_type} "\
"20480:5:7000:2:${msg_type} "\
"20480:10:10000:2:${msg_type} "\
"20480:50:10000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray6=""\
"51200:1:500:2:${msg_type} "\
"51200:2:1000:2:${msg_type} "\
"51200:5:2300:2:${msg_type} "\
"51200:10:2500:2:${msg_type} "\
"51200:50:2000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray7=""\
"102400:1:300:2:${msg_type} "\
"102400:2:500:2:${msg_type} "\
"102400:5:1500:2:${msg_type} "\
"102400:10:2000:2:${msg_type} "\
"102400:50:2000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../run-testset.sh ${vmrs} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]} ${testarray7[@]}
