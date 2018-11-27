#!/bin/bash
#Test set (direct messaging) to run against a large GKE VMR group (similar to 8 cores)
#vmrs="10.132.0.45" #large GKE VMR
vmrs="${1}" #large GKE VMR
testsetprefix="quick-gke"
msg_type="direct"

testarray1=""\
"1024:1:716000:4:${msg_type} "\
"1024:2:826000:4:${msg_type} "\
"1024:5:1000000:4:${msg_type} "\
"1024:10:1100000:4:${msg_type} "\
"1024:50:1100000:2:${msg_type} "\
"1024:100:1200000:2:${msg_type} "\
";" #need to  end with to separate the various test arrays;

${BASH_SOURCE%/*}/../run-testset.sh ${vmrs} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]} ${testarray5[@]} ${testarray6[@]} ${testarray7[@]}

