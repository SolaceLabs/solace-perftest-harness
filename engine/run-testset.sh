#!/bin/bash
# Wrapper script to run a whole set of perf tests against Solace brokers.
# Tests are being passed in as arrays. 
# An array can have several tests separated by space.
# Each test need to be in the format:
# msg_size:fanout_number:target_msg_rate:number_of_publisher_hosts:msg_type
# Several (up to 7) arrays/testsets can be passed in, if separated by ;
# Example format for one test set:
# testarray1=""\
# "100:1:1300000:4:direct "\
# "100:2:1550000:4:direct "\
# "100:5:3000000:4:direct "\
# "100:10:3300000:4:direct "\
# "100:50:4000000:2:direct "\
# "100:100:4000000:2:direct "\
# ";" #need to  end with to separate the various test arrays;
# See scripts in sub-folder benchmarking-tests for examples.

prompt_between_tests="false" #set to false, if you want to run tests fully automatic
#prompt_between_tests="true" #set to false, if you want to run tests fully automatic

echo "Running run-testset.sh with args: $@"
broker="$1" #ip to connect to broker for testing
testsetprefix="$2" #prefix for log files and results
msg_type="$3" #message type for test:direct, nonpersistent or persistent

runlength=60 #how long to run reach test for in seconds
allowed_error_margin=5 #allowed error margin in pct"
: ${sshuser:=$(awk '/^sshuser:/{print $2}' "${BASH_SOURCE%/*}/../config/credentials.yaml" 2>/dev/null)}
: ${sshuser:=perfharness}  # fallback if not set by caller or credentials.yaml

log_dir=${BASH_SOURCE%/*}/../temp #directory for temp files
result_dir=${BASH_SOURCE%/*}/../results #directory to store results in

checkdependencies() {
  echo "Checking dependencies..."
  for e in rm cat sed grep ls dig let sleep ansible-playbook; do
    if ! command -v ${e} &> /dev/null; then
      echo ${e} " not found in PATH. Please install or update PATH"
      exit 1
    fi
  done
}

checkcredentials() {
  local creds="${BASH_SOURCE%/*}/../config/credentials.yaml"
  if [ ! -f "${creds}" ]; then
    echo "Error: config/credentials.yaml not found."
    echo "Run ./setup.sh to create it."
    exit 1
  fi
  local missing=()
  for field in broker_vpn broker_username broker_password; do
    grep -q "^${field}:" "${creds}" || missing+=("${field}")
  done
  if [ ${#missing[@]} -gt 0 ]; then
    echo "Error: the following fields are missing from config/credentials.yaml:"
    printf '  %s\n' "${missing[@]}"
    echo "Run ./setup.sh to add them, or copy config/credentials.yaml.example."
    exit 1
  fi
}

#main routine
checkdependencies
checkcredentials

# Gather host and core info for the result file header
_host_file="${BASH_SOURCE%/*}/../config/host"
_creds="${BASH_SOURCE%/*}/../config/credentials.yaml"
_pub_cores=$(awk '/^pub_cores:/{print $2}' "${_creds}" 2>/dev/null); : ${_pub_cores:=unknown}
_sub_cores=$(awk '/^sub_cores:/{print $2}' "${_creds}" 2>/dev/null); : ${_sub_cores:=unknown}
mapfile -t _pub_hosts < <(awk '/^\[pubhost\]/{f=1;next} /^\[/{f=0} f && /[^[:space:]]/ && !/^#/{print $1}' "${_host_file}" 2>/dev/null)
mapfile -t _sub_hosts < <(awk '/^\[subhost\]/{f=1;next} /^\[/{f=0} f && /[^[:space:]]/ && !/^#/{print $1}' "${_host_file}" 2>/dev/null)
_pub_host_str=$(IFS=', '; echo "${_pub_hosts[*]:-none}")
_sub_host_str=$(IFS=', '; echo "${_sub_hosts[*]:-none}")

# Parse passed in test arrays
testarray1=$(echo ${@} | cut -d ';' -f 2)
echo "testarray1=${testarray1}"
testarray2=$(echo ${@} | cut -d ';' -f 3)
echo "testarray2=${testarray2}"
testarray3=$(echo ${@} | cut -d ';' -f 4)
echo "testarray3=${testarray3}"
testarray4=$(echo ${@} | cut -d ';' -f 5)
echo "testarray4=${testarray4}"
testarray5=$(echo ${@} | cut -d ';' -f 6)
echo "testarray5=${testarray5}"
testarray6=$(echo ${@} | cut -d ';' -f 7)
echo "testarray6=${testarray6}"
testarray7=$(echo ${@} | cut -d ';' -f 8)
echo "testarray7=${testarray7}"

if [ -z "${broker}" ] || [[ ${broker} != *"."* ]]; then
  #not an ip, try to resolve
  ip=$(dig ${broker} +short)
  if [[ ${ip} != *"."* ]]; then
  	echo "no valid router ip given to run against, exiting..."
  	exit 1
  else
  	broker=${ip}
  	echo "router ip set to: $broker"
  fi
else
  echo "router ip set to: $broker"
fi


echo "Running testset for ${testsetprefix} ${msg_type} on ${broker}"...
xIFS=$IFS #remember internal field separator
IFS=$';'  #set ifs to ; for this for loop
for testarray in ${testarray7} ${testarray6} ${testarray5} ${testarray4} ${testarray3} ${testarray2} ${testarray1}; do
  if [ -n "${testarray}" ]; then
    echo "testarray=${testarray}"
    IFS=$xIFS #reset ifs for next for loop
    for parameters in ${testarray}; do
      if [ -n "${parameters}" ]; then
        # Parse parameters for a single test
        echo "parameters=${parameters}"
        msg_size=`echo ${parameters} | cut -d : -f 1`
        fanout=`echo ${parameters} | cut -d : -f 2`
        msgrate=`echo ${parameters} | cut -d : -f 3`
        hosts=`echo ${parameters} | cut -d : -f 4`
        mt=`echo ${parameters} | cut -d : -f 5`
        if [ ! -z "${msg_size}" ] && [ ! -z "${fanout}" ] && [ ! -z "${msgrate}" ] && [ ! -z "${hosts}" ] && [ ! -z "${mt}" ]; then
          if [[ "${prompt_between_tests}" = "true" ]]; then
            read -n 1 -s -r -p "[Press any key to hit it off]" #uncomment, if you want to be prompted before starting test 
            echo ""
          fi
          #Call wrapper script for running a single test
          "${BASH_SOURCE%/*}/run-test.sh" -e '{"broker":'${broker}',"parallel_hosts":'${hosts}',"target_msg_rate":'${msgrate}',"msg_size":'${msg_size}',"sdk_fanout":'${fanout}',"runlength":'${runlength}',"mt":"'${mt}'","sshuser":"'${sshuser}'"}' | tee ${log_dir}/${testsetprefix}_${mt}_${msg_size}_${fanout}.log
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
          echo "one of msg_size, fanout, msgrate, hosts or mt is empty, skipping..."
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
{
  printf "Test environment\n"
  printf "  Publisher hosts  (%d): %s\n" "${#_pub_hosts[@]}" "${_pub_host_str}"
  printf "  Subscriber hosts (%d): %s\n" "${#_sub_hosts[@]}" "${_sub_host_str}"
  printf "  Publisher host cores:  %s\n" "${_pub_cores}"
  printf "  Subscriber host cores: %s\n\n" "${_sub_cores}"
  cat $(ls -rt ${log_dir}/${testsetprefix}_*.log) | egrep -A 16 "echo_end|RESULT" | grep -A 25 "echo_end"
} | tee ${result_dir}/${testsetprefix}_${msg_type}_result.txt
sleep 10 #delay cleanup in case someone is watching/tailing the test
rm -f ${log_dir}/${testsetprefix}_*.log #clean up log files
