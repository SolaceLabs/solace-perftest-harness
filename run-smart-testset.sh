#!/bin/bash
# Wrapper script to run a whole set of smart perf tests against Solace VMRs.
# Tests are being passed in as arrays. 
# An array can have several tests separated by space.
# Each test need to be in the format:
# msg_size:fanout_number:number_of_publisher_hosts:msg_type
# Several (up to 7) arrays/testsets can be passed in, if separated by ;
# Example format for one test set:
# testarray1=""\
# "100:1:4:direct "\
# "100:2:4:direct "\
# "100:5:4:direct "\
# "100:10:4:direct "\
# "100:50:2:direct "\
# "100:100:2:direct "\
# ";" #need to  end with to separate the various test arrays;
# See scripts in sub-folder specific-test-sets for examples.

prompt_between_tests="false" #set to false, if you want to run tests fully automatic
#prompt_between_tests="true" #set to false, if you want to run tests fully automatic

echo "Running run-smart-testset.sh with args: $@"
vmrs="$1" #ip to connect to vmrs for testing
testsetprefix="$2" #prefix for log files and results
msg_type="$3" #message type for test:direct, nonpersistent or persistent

runlength=60 #how long to run reach test for in seconds
allowed_error_margin=5 #allowed error margin in pct"

log_dir=${BASH_SOURCE%/*}/temp #directory for temp files
result_dir=${BASH_SOURCE%/*}/results #directory to store results in

checkdependencies() {
  echo "Checking dependencies..."
  for e in rm cat sed grep ls dig let sleep ansible-playbook; do
    if ! command -v ${e} &> /dev/null; then
      echo ${e} " not found in PATH. Please install or update PATH"
      exit 1
    fi
  done 
}

#main routine
checkdependencies
# Parse passed in test arrays
testarray1=("`echo ${@} | cut -d ';' -f 2`")
echo "testarray1=${testarray1}"
testarray2=("`echo ${@} | cut -d ';' -f 3`")
echo "testarray2=${testarray2}"
testarray3=("`echo ${@} | cut -d ';' -f 4`")
echo "testarray3=${testarray3}"
testarray4=("`echo ${@} | cut -d ';' -f 5`")
echo "testarray4=${testarray4}"
testarray5=("`echo ${@} | cut -d ';' -f 6`")
echo "testarray5=${testarray5}"
testarray6=("`echo ${@} | cut -d ';' -f 7`")
echo "testarray6=${testarray6}"
testarray7=("`echo ${@} | cut -d ';' -f 8`")
echo "testarray7=${testarray7}"

if [ -z "${vmrs}" ] || [[ ${vmrs} != *"."* ]]; then
  #not an ip, try to resolve
  ip=$(dig ${vmrs} +short)
  if [[ ${ip} != *"."* ]]; then
  	echo "no valid router ip given to run against, exiting..."
  	exit 1
  else
  	vmrs=${ip}
  	echo "router ip set to: $vmrs"
  fi
else
  echo "router ip set to: $vmrs"
fi


echo "Running testset for ${testsetprefix} ${msg_type} on ${vmrs}"...
for testarray in ${testarray7} ${testarray6} ${testarray5} ${testarray4} ${testarray3} ${testarray2} ${testarray1}; do
  if [ -n "${testarray}" ]; then
    for parameters in ${testarray}; do
      if [ -n "${parameters}" ]; then
        # Parse parameters for a single test
        echo "parameters=${parameters}"
        msg_size=`echo ${parameters} | cut -d : -f 1`
        fanout=`echo ${parameters} | cut -d : -f 2`
        hosts=`echo ${parameters} | cut -d : -f 3`
        mt=`echo ${parameters} | cut -d : -f 4`
        if [ ! -z "${msg_size}" ] && [ ! -z "${fanout}" ] && [ ! -z "${hosts}" ] && [ ! -z "${mt}" ]; then
          if [[ "${prompt_between_tests}" = "true" ]]; then
            read -n 1 -s -r -p "[Press any key to hit it off]" #uncomment, if you want to be prompted before starting test 
            echo ""
          fi
          #Call wrapper script for running a single test to determine the max publisher rate first
          ./run-test.sh -e '{"vmrs":'${vmrs}',"parallel_hosts":'${hosts}',"target_msg_rate":'0',"msg_size":'${msg_size}',"sdk_fanout":'0',"runlength":'${runlength}',"mt":"'${mt}'"}' | tee ${log_dir}/${testsetprefix}_${mt}_${msg_size}_${fanout}.log
		  publisherrate=`cat ${log_dir}/${testsetprefix}_${mt}_${msg_size}_${fanout}.log | grep "all publishers:" | awk 'BEGIN { FS= " " }; { print $5 }'`
		  msgrate=$(echo ${publisherrate} | awk '{print int($1*0.829)}' )
		  
		  echo "Calculated max stable rate:   " ${msgrate} " (msgs/sec)"
		  echo

		  #Now run test script again with calculated max stable rate for publishers and receivers
          ./run-test.sh -e '{"vmrs":'${vmrs}',"parallel_hosts":'${hosts}',"target_msg_rate":'${msgrate}',"msg_size":'${msg_size}',"sdk_fanout":'${fanout}',"runlength":'${runlength}',"mt":"'${mt}'"}' | tee ${log_dir}/${testsetprefix}_${mt}_${msg_size}_${fanout}.log
          #Parse and log results and check for success/failure
          receiver_rate=`cat ${log_dir}/${testsetprefix}_${mt}_${msg_size}_${fanout}.log | grep "all  consumers:" | awk 'BEGIN { FS= " " }; { print $5 }'`
          echo "allowed error margin = ${allowed_error_margin} %" | tee -a ${log_dir}/${testsetprefix}_${mt}_${msg_size}_${fanout}.log
          let withinerrormargin="$msgrate - ( $msgrate / 100 * $allowed_error_margin )"
          echo "target rate - error margin = ${withinerrormargin}" | tee -a ${log_dir}/${testsetprefix}_${mt}_${msg_size}_${fanout}.log
          if [[ $withinerrormargin -lt $receiver_rate ]]; then
            echo "Achieved rate $receiver_rate >= $withinerrormargin" | tee -a ${log_dir}/${testsetprefix}_${mt}_${msg_size}_${fanout}.log
            echo "Test: OK" | tee -a ${log_dir}/${testsetprefix}_${mt}_${msg_size}_${fanout}.log
          else
            echo "Achieved rate $receiver_rate < $withinerrormargin" | tee -a ${log_dir}/${testsetprefix}_${mt}_${msg_size}_${fanout}.log
            echo "Test: Fail" | tee -a ${log_dir}/${testsetprefix}_${mt}_${msg_size}_${fanout}.log
          fi
          sleep 2 #delay to allow temp logs to finish writing
          echo
        else
          echo "one of msg_size, fanout, hosts or mt is empty, skipping..."
        fi
      else
        echo "parameters is empty, skipping..."
      fi
    done
  else
    echo "testarray is empty, skipping..."
  fi
done
#Write only the test summary along with the result to the result file (without all the ansible log output)
echo "Finished testset, compiling results..."
cat $(ls -rt ${log_dir}/${testsetprefix}_*.log) | egrep -A 14 "echo_end|RESULT"|grep -A 23 "echo_end" | tee ${result_dir}/${testsetprefix}_${msg_type}_result.txt
sleep 10 #delay cleanup in case someone is watching/tailing the test
rm -f ${log_dir}/${testsetprefix}_*.log #clean up log files
