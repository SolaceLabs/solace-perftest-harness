#!/bin/bash
# Wrapper script to run ansible playbook start-sdk.yaml for perf testing Solace brokers (single test)
# and parsing achieved publisher and consumer rates

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#set cleanup to false, if you need to debug something and look at the output
cleanup_at_end="true"
#cleanup_at_end="false"

cleanup() {
  #clean up log and temp files afterwards
  rm -rf "${script_dir}/run-tests.log"
  rm -rf "${script_dir}/sum-pub.txt"
  rm -rf "${script_dir}/sum-sub.txt"
}

checkdependencies() {
  echo "Checking dependencies..."
  for e in rm cat sed grep sort uniq awk ansible-playbook; do
    if ! command -v ${e} &> /dev/null; then
      echo ${e} " not found in PATH. Please install or update PATH"
      exit 1
    fi
  done 
}

export ANSIBLE_FORCE_COLOR=true
export ANSIBLE_HOST_KEY_CHECKING=False
checkdependencies
cleanup
echo "Running ansible-playbook start-sdk.yaml with args: " $@
ansible-playbook -i "${script_dir}/../config/host" "${script_dir}/start-sdk.yaml" $@ | tee "${script_dir}/run-tests.log"
echo
printf "RESULT ****************************************\n"
# Always parse rates first. Teardown exceptions from sdkperf -pea=0 queue cleanup are
# non-fatal and must not suppress valid rate data. Only fall back to the error branch
# if no rates were actually computed (i.e. publisher or consumer produced 0 msg/s).
#first publishers
cat "${script_dir}/run-tests.log" | sed 's/\x1B\[[0-9;]*m//g' | sed 's/\\n/\n/g' | grep 'Sum across publishers:' | grep -v ansible | \
awk 'BEGIN { FS= " " } ; { print $1" "$2" "$3" "$4" "$5 }' > "${script_dir}/sum-pub.txt"
sum_pub=`awk 'BEGIN { FS= " " }; { print $4 }' "${script_dir}/sum-pub.txt" | awk '{ sum += $1; } END { print sum; }'`
#then consumers
cat "${script_dir}/run-tests.log" | sed 's/\x1B\[[0-9;]*m//g' | sed 's/\\n/\n/g' | grep 'Sum across consumers:' | grep -v ansible | \
awk 'BEGIN { FS= " " } ; { print $1" "$2" "$3" "$4" "$5 }' > "${script_dir}/sum-sub.txt"
sum_sub=`awk 'BEGIN { FS= " " }; { print $4 }' "${script_dir}/sum-sub.txt" | awk '{ sum += $1; } END { print sum; }'`
if [[ -n "${sum_pub}" && "${sum_pub}" != "0" && -n "${sum_sub}" && "${sum_sub}" != "0" ]]; then
  printf "Sum across all publishers: %9.0f (msgs/sec)\n" ${sum_pub}
  printf "Sum across all  consumers: %9.0f (msgs/sec)\n" ${sum_sub}
  if grep -q 'Exception\|Error' "${script_dir}/run-tests.log"; then
    echo "Warnings (non-fatal errors in sdkperf output, rates were still computed):"
    cat "${script_dir}/run-tests.log" | sed 's/\\n/\n/g' | grep 'Exception\|Error' | grep -v ansible | sort | uniq -c | sort -nr
  fi
else
  #No valid rates found - report errors
  echo "Errors occured during run:"
  cat "${script_dir}/run-tests.log" | sed 's/\\n/\n/g' | grep 'Exception\|Error' | grep -v ansible | sort | uniq -c | sort -nr
fi
echo
if [[ "${cleanup_at_end}" = "true" ]]; then
  cleanup
fi

