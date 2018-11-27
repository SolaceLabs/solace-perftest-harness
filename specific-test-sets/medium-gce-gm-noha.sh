#!/bin/bash
#Test set (guaranteed messaging) to run against a medium GCE VMR group (4 cores) (no redundancy)
vmrs="10.132.0.3,10.132.0.14" #medium VMRs
testsetprefix="medium-noha"
msg_type="persistent"

testarray1=""\
"512:1:50000:2:${msg_type} "\
"512:2:71000:2:${msg_type} "\
"512:5:120000:2:${msg_type} "\
"512:10:190000:2:${msg_type} "\
"512:50:430000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:65000:2:${msg_type} "\
"1024:2:120000:2:${msg_type} "\
"1024:5:180000:2:${msg_type} "\
"1024:10:250000:2:${msg_type} "\
"1024:50:320000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:30000:2:${msg_type} "\
"2048:2:70000:2:${msg_type} "\
"2048:5:130000:3:${msg_type} "\
"2048:10:140000:2:${msg_type} "\
"2048:50:320000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray4=""\
"4096:1:21000:2:${msg_type} "\
"4096:2:40000:2:${msg_type} "\
"4096:5:50000:2:${msg_type} "\
"4096:10:50000:2:${msg_type} "\
"4096:50:50000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray5=""\
"20480:1:4000:2:${msg_type} "\
"20480:2:9000:2:${msg_type} "\
"20480:5:21000:2:${msg_type} "\
"20480:10:21000:2:${msg_type} "\
"20480:50:25000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray6=""\
"51200:1:1000:2:${msg_type} "\
"51200:2:3000:2:${msg_type} "\
"51200:5:8000:2:${msg_type} "\
"51200:10:8000:2:${msg_type} "\
"51200:50:10000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray7=""\
"102400:1:1000:2:${msg_type} "\
"102400:2:1000:2:${msg_type} "\
"102400:5:2000:2:${msg_type} "\
"102400:10:3000:2:${msg_type} "\
"102400:50:4000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../run-testset.sh ${vmrs} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]} ${testarray7[@]}
