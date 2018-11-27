#!/bin/bash
# Wrapper script to run ansible playbook start-sdk.yaml for perf testing Solace VMRs (single test) 
# and parsing achieved publisher and consumer rates

#set cleanup to false, if you need to debug something and look at the output
#cleanup_at_end="true"
cleanup_at_end="false"

cleanup() {
  #clean up log and temp files afterwards
  rm -rf run-tests.log
  rm -rf sum-pub.txt
  rm -rf sum-sub.txt
}

export ANSIBLE_FORCE_COLOR=true
export ANSIBLE_HOST_KEY_CHECKING=False
cleanup
echo "Running ansible-playbook start-sdk.yaml with args: " $@
ansible-playbook -i host start-sdk.yaml $@ | tee run-tests.log
echo
printf "RESULT ****************************************\n"
if grep -q 'Exception\|Error' run-tests.log; then
  #Check if any exceptions were logged by sdkperf processes and log them 
  echo "Errors occured during run:"
  cat run-tests.log | sed 's/\\n/\n/g' | grep 'Exception\|Error' | grep -v ansible | sort | uniq -c | sort -nr
else
  #If no exceptions occured, parse and print out achieved message rates
  #first publishers
  cat run-tests.log | sed 's/\\n/\n/g' | grep 'Sum across publishers:' | grep -v ansible | \
  awk 'BEGIN { FS= " " } ; { print $1" "$2" "$3" "$4" "$5 }' > sum-pub.txt
  sum_pub=`awk 'BEGIN { FS= " " }; { print $4 }' sum-pub.txt | awk '{ sum += $1; } END { print sum; }'`
  printf "Sum across all publishers: %9.0f (msgs/sec)\n" ${sum_pub}
  #then consumers
  cat run-tests.log | sed 's/\\n/\n/g' | grep 'Sum across consumers:' | grep -v ansible | \
  awk 'BEGIN { FS= " " } ; { print $1" "$2" "$3" "$4" "$5 }' > sum-sub.txt
  sum_sub=`awk 'BEGIN { FS= " " }; { print $4 }' sum-sub.txt | awk '{ sum += $1; } END { print sum; }'`
  printf "Sum across all  consumers: %9.0f (msgs/sec)\n" ${sum_sub}
fi
echo
if [[ "${cleanup_at_end}" = "true" ]]; then
  cleanup
fi

