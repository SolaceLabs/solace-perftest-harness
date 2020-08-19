#!/bin/bash
#Test set (guaranteed messaging) to run against a medium software broker (4 cores)
vmrs="${1}" #broker IP/DNS
testsetprefix="4core-ha"
msg_type="persistent"

testarray1=""\
"512:1:40000:4:${msg_type} "\
"512:2:71000:4:${msg_type} "\
"512:5:120000:4:${msg_type} "\
"512:10:185000:4:${msg_type} "\
"512:50:240000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray2=""\
"1024:1:34000:4:${msg_type} "\
"1024:2:65000:4:${msg_type} "\
"1024:5:123000:4:${msg_type} "\
"1024:10:195000:4:${msg_type} "\
"1024:50:195000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray3=""\
"2048:1:22000:4:${msg_type} "\
"2048:2:43000:4:${msg_type} "\
"2048:5:87000:4:${msg_type} "\
"2048:10:128000:4:${msg_type} "\
"2048:50:128000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray4=""\
"4096:1:14000:4:${msg_type} "\
"4096:2:27000:4:${msg_type} "\
"4096:5:580000:4:${msg_type} "\
"4096:10:74000:4:${msg_type} "\
"4096:50:77000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray5=""\
"20480:1:3000:4:${msg_type} "\
"20480:2:6000:4:${msg_type} "\
"20480:5:15000:4:${msg_type} "\
"20480:10:17000:4:${msg_type} "\
"20480:50:28000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray6=""\
"51200:1:1500:4:${msg_type} "\
"51200:2:2000:4:${msg_type} "\
"51200:5:5500:4:${msg_type} "\
"51200:10:8000:4:${msg_type} "\
"51200:50:12000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;
testarray7=""\
"102400:1:1000:4:${msg_type} "\
"102400:2:1000:4:${msg_type} "\
"102400:5:3000:4:${msg_type} "\
"102400:10:3000:4:${msg_type} "\
"102400:50:5000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../run-testset.sh ${vmrs} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]} ${testarray7[@]}
