#!/bin/bash
#Test set (guaranteed messaging) to run against a large GCE VMR group (8 cores)
vmrs="35.187.90.140" #large GCE VMR ext IP
#vmrs="10.132.0.16,10.132.0.17" #large GCE VMRs
#vmrs="35.195.248.125" #large GKE VMR
testsetprefix="large-ha"
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
testarray5=""\
"20480:1:5000:4:${msg_type} "\
"20480:2:13000:4:${msg_type} "\
"20480:5:25000:4:${msg_type} "\
"20480:10:30000:4:${msg_type} "\
"20480:50:40000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray6=""\
"51200:1:2000:4:${msg_type} "\
"51200:2:4000:4:${msg_type} "\
"51200:5:9500:4:${msg_type} "\
"51200:10:12700:4:${msg_type} "\
"51200:50:17000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray7=""\
"102400:1:1000:4:${msg_type} "\
"102400:2:2100:4:${msg_type} "\
"102400:5:5000:4:${msg_type} "\
"102400:10:6000:4:${msg_type} "\
"102400:50:10000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../run-testset.sh ${vmrs} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]} ${testarray7[@]}
