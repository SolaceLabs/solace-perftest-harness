#!/bin/bash
#Test set (direct messaging) to run against a micro GCE VMR group (2 cores - small storage 64GB persistent SSD)
vmrs="10.132.0.28,10.132.0.33" #micro VMRs
testsetprefix="micro-direct"
msg_type="direct"

testarray1=""\
"100:1:390000:4:${msg_type} "\
"100:2:675000:4:${msg_type} "\
"100:5:1000000:4:${msg_type} "\
"100:10:1000000:4:${msg_type} "\
"100:50:1350000:2:${msg_type} "\
"100:100:1350000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:225000:4:${msg_type} "\
"1024:2:277000:4:${msg_type} "\
"1024:5:307000:4:${msg_type} "\
"1024:10:307000:4:${msg_type} "\
"1024:50:460000:2:${msg_type} "\
"1024:100:450000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:127000:4:${msg_type} "\
"2048:2:150000:4:${msg_type} "\
"2048:5:160000:4:${msg_type} "\
"2048:10:160000:4:${msg_type} "\
"2048:50:230000:2:${msg_type} "\
"2048:100:230000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray4=""\
"10240:1:30000:4:${msg_type} "\
"10240:2:33000:4:${msg_type} "\
"10240:5:33000:4:${msg_type} "\
"10240:10:34000:4:${msg_type} "\
"10240:50:46000:2:${msg_type} "\
"10240:100:46000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray5=""\
"20480:1:15000:4:${msg_type} "\
"20480:2:16000:4:${msg_type} "\
"20480:5:16500:4:${msg_type} "\
"20480:10:16500:4:${msg_type} "\
"20480:50:23000:2:${msg_type} "\
"20480:100:23000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray6=""\
"51200:1:6000:4:${msg_type} "\
"51200:2:6700:4:${msg_type} "\
"51200:5:6700:4:${msg_type} "\
"51200:10:6700:4:${msg_type} "\
"51200:50:8800:2:${msg_type} "\
"51200:100:9000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray7=""\
"102400:1:3000:4:${msg_type} "\
"102400:2:3300:4:${msg_type} "\
"102400:5:3300:4:${msg_type} "\
"102400:10:3300:4:${msg_type} "\
"102400:50:4700:2:${msg_type} "\
"102400:100:4700:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../run-testset.sh ${vmrs} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]} ${testarray7[@]}
