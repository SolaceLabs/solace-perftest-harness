#!/bin/bash
#Test set (direct messaging) to run against a small software broker (2 cores)
vmrs="${1}" #broker IP/DNS
testsetprefix="2core-gke"
msg_type="direct"

testarray1=""\
"100:1:525000:4:${msg_type} "\
"100:2:900000:4:${msg_type} "\
"100:5:1350000:4:${msg_type} "\
"100:10:1350000:4:${msg_type} "\
"100:50:1350000:2:${msg_type} "\
"100:100:1350000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:300000:4:${msg_type} "\
"1024:2:370000:4:${msg_type} "\
"1024:5:410000:4:${msg_type} "\
"1024:10:410000:4:${msg_type} "\
"1024:50:460000:2:${msg_type} "\
"1024:100:490000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:170000:4:${msg_type} "\
"2048:2:200000:4:${msg_type} "\
"2048:5:215000:4:${msg_type} "\
"2048:10:215000:4:${msg_type} "\
"2048:50:230000:2:${msg_type} "\
"2048:100:300000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray4=""\
"10240:1:40000:4:${msg_type} "\
"10240:2:44000:4:${msg_type} "\
"10240:5:44000:4:${msg_type} "\
"10240:10:45000:4:${msg_type} "\
"10240:50:46000:2:${msg_type} "\
"10240:100:46000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray5=""\
"20480:1:20000:4:${msg_type} "\
"20480:2:22000:4:${msg_type} "\
"20480:5:22000:4:${msg_type} "\
"20480:10:22000:4:${msg_type} "\
"20480:50:23000:2:${msg_type} "\
"20480:100:23000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray6=""\
"51200:1:8000:4:${msg_type} "\
"51200:2:9000:4:${msg_type} "\
"51200:5:9000:4:${msg_type} "\
"51200:10:9000:4:${msg_type} "\
"51200:50:9000:2:${msg_type} "\
"51200:100:9000:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray7=""\
"102400:1:4000:4:${msg_type} "\
"102400:2:4500:4:${msg_type} "\
"102400:5:4600:4:${msg_type} "\
"102400:10:4600:4:${msg_type} "\
"102400:50:4700:2:${msg_type} "\
"102400:100:4700:1:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../run-testset.sh ${vmrs} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]} ${testarray7[@]}
