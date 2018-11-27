#!/bin/bash
#Test set (guaranteed messaging) to run against a large GKE VMR group (similar to 8 cores) (no redundancy)
#vmrs="35.195.124.89" #large k8s VMRs
vmrs="${1}"
testsetprefix="large-gke-noha"
msg_type="persistent"

testarray1=""\
"512:1:80000:4:${msg_type} "\
"512:2:140000:4:${msg_type} "\
"512:5:270000:4:${msg_type} "\
"512:10:400000:4:${msg_type} "\
"512:50:620000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:74000:4:${msg_type} "\
"1024:2:150000:4:${msg_type} "\
"1024:5:270000:4:${msg_type} "\
"1024:10:390000:4:${msg_type} "\
"1024:50:625000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:59000:4:${msg_type} "\
"2048:2:120000:4:${msg_type} "\
"2048:5:226000:4:${msg_type} "\
"2048:10:324000:4:${msg_type} "\
"2048:50:525000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray4=""\
"4096:1:44000:4:${msg_type} "\
"4096:2:89000:4:${msg_type} "\
"4096:5:1770000:4:${msg_type} "\
"4096:10:180000:4:${msg_type} "\
"4096:50:190000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray5=""\
"20480:1:6000:4:${msg_type} "\
"20480:2:13000:4:${msg_type} "\
"20480:5:35000:4:${msg_type} "\
"20480:10:37000:4:${msg_type} "\
"20480:50:50000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray6=""\
"51200:1:2000:4:${msg_type} "\
"51200:2:7000:4:${msg_type} "\
"51200:5:14000:4:${msg_type} "\
"51200:10:16000:4:${msg_type} "\
"51200:50:17000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray7=""\
"102400:1:1000:4:${msg_type} "\
"102400:2:2700:4:${msg_type} "\
"102400:5:5000:4:${msg_type} "\
"102400:10:6000:4:${msg_type} "\
"102400:50:10000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../run-testset.sh ${vmrs} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]} ${testarray7[@]}
