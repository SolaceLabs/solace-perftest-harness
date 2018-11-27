#!/bin/bash
#Test set (guaranteed messaging) to run against a micro GCE VMR group (2 cores - small storage 64GB persistent SSD)
vmrs="10.132.0.28,10.132.0.33" #micro VMRs
testsetprefix="micro-ha"
msg_type="persistent"

testarray1=""\
"512:1:15000:2:${msg_type} "\
"512:2:30000:2:${msg_type} "\
"512:5:63000:2:${msg_type} "\
"512:10:95000:2:${msg_type} "\
"512:50:135000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:13000:2:${msg_type} "\
"1024:2:26000:2:${msg_type} "\
"1024:5:58000:2:${msg_type} "\
"1024:10:88000:2:${msg_type} "\
"1024:50:122000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:12000:2:${msg_type} "\
"2048:2:23000:2:${msg_type} "\
"2048:5:51000:2:${msg_type} "\
"2048:10:76000:2:${msg_type} "\
"2048:50:105000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray4=""\
"4096:1:7000:2:${msg_type} "\
"4096:2:14000:2:${msg_type} "\
"4096:5:30000:2:${msg_type} "\
"4096:10:49000:2:${msg_type} "\
"4096:50:68000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray5=""\
"20480:1:1600:2:${msg_type} "\
"20480:2:3000:2:${msg_type} "\
"20480:5:7250:2:${msg_type} "\
"20480:10:8000:2:${msg_type} "\
"20480:50:8000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray6=""\
"51200:1:500:2:${msg_type} "\
"51200:2:1100:2:${msg_type} "\
"51200:5:2500:2:${msg_type} "\
"51200:10:3000:2:${msg_type} "\
"51200:50:3000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray7=""\
"102400:1:250:2:${msg_type} "\
"102400:2:450:2:${msg_type} "\
"102400:5:1300:2:${msg_type} "\
"102400:10:2000:2:${msg_type} "\
"102400:50:2000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../run-testset.sh ${vmrs} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]} ${testarray7[@]}
