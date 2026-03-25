#!/bin/bash
# Binary search approach to find the max stable throughput for Solace broker performance testing.
#
# For each test scenario (msg_size, fanout, hosts, msg_type), performs a binary search
# over message rates to find the highest rate the broker can sustain end-to-end with
# consumers active. No prior knowledge of expected rates is required, and no empirical
# multipliers are used.
#
# Test format (same as run-smart-testset.sh - no target rate field):
#   msg_size:fanout_number:number_of_publisher_hosts:msg_type
#
# Several (up to 7) arrays/testsets can be passed in, separated by ;
# Example:
#   testarray1=""\
#   "100:1:4:direct "\
#   "100:5:4:direct "\
#   "100:50:2:direct "\
#   ";"
# See scripts in sub-folder smart-testsets for examples.

prompt_between_tests="false"

echo "Running run-binsearch-testset.sh with args: $@"
vmrs="$1"           # IP/hostname of the broker under test
testsetprefix="$2"  # prefix for log and result files
msg_type="$3"       # message type label used in result filename (informational)

runlength=60               # seconds per test run
search_iterations=10       # binary search iterations; precision = upper_bound / 2^iterations
allowed_error_margin=5     # consumer rate must be >= (100 - margin)% of target to count as a pass

# Per-type upper bounds (msgs/sec). Binary search starts at [0, upper_bound].
# Adjust these for your environment — too high wastes iterations, too low caps discovery.
search_upper_bound_direct=5000000
search_upper_bound_nonpersistent=2000000
search_upper_bound_persistent=1000000

log_dir=${BASH_SOURCE%/*}/temp
result_dir=${BASH_SOURCE%/*}/results

checkdependencies() {
  echo "Checking dependencies..."
  for e in rm cat sed grep ls dig sleep ansible-playbook; do
    if ! command -v ${e} &> /dev/null; then
      echo "${e} not found in PATH. Please install or update PATH."
      exit 1
    fi
  done
}

# Run a single test and tee output to logfile.
# Usage: run_single_test <msg_size> <fanout> <hosts> <mt> <target_rate> <logfile>
run_single_test() {
  local msg_size=$1 fanout=$2 hosts=$3 mt=$4 target_rate=$5 logfile=$6
  ./run-test.sh -e '{"vmrs":'${vmrs}',"parallel_hosts":'${hosts}',"target_msg_rate":'${target_rate}',"msg_size":'${msg_size}',"sdk_fanout":'${fanout}',"runlength":'${runlength}',"mt":"'${mt}'"}' | tee "${logfile}"
}

# Extract the total consumer rate from a run log.
# Usage: get_consumer_rate <logfile>
get_consumer_rate() {
  grep "all  consumers:" "$1" | awk 'BEGIN { FS=" " } { print $5 }'
}

# Binary search for the maximum stable consumer rate for a given scenario.
# Sets globals: max_stable_rate, max_stable_logfile
# Usage: find_max_rate <msg_size> <fanout> <hosts> <mt>
find_max_rate() {
  local msg_size=$1 fanout=$2 hosts=$3 mt=$4

  # Select upper bound based on message type
  local high
  case "${mt}" in
    persistent)
      high=${search_upper_bound_persistent} ;;
    nonpersistent)
      high=${search_upper_bound_nonpersistent} ;;
    *)
      high=${search_upper_bound_direct} ;;
  esac

  local low=0
  max_stable_rate=0
  max_stable_logfile=""

  echo ""
  echo "============================================================"
  echo "Binary search: msg_size=${msg_size} fanout=${fanout} hosts=${hosts} mt=${mt}"
  echo "Search range: [${low}, ${high}] over ${search_iterations} iterations"
  echo "Precision at end: ±$(( high / (1 << search_iterations) )) msgs/sec"
  echo "============================================================"

  for iter in $(seq 1 ${search_iterations}); do
    local mid=$(( (low + high) / 2 ))
    if [ ${mid} -le 0 ]; then
      echo "Midpoint reached zero, stopping search early."
      break
    fi

    local logfile="${log_dir}/${testsetprefix}_${mt}_${msg_size}_${fanout}_iter${iter}.log"
    echo ""
    echo "Iteration ${iter}/${search_iterations}: target=${mid} msgs/sec  [range: ${low} - ${high}]"

    run_single_test ${msg_size} ${fanout} ${hosts} ${mt} ${mid} "${logfile}"

    local receiver_rate
    receiver_rate=$(get_consumer_rate "${logfile}")

    if [ -z "${receiver_rate}" ] || ! [[ "${receiver_rate}" =~ ^[0-9]+$ ]]; then
      echo "Warning: could not parse consumer rate — treating as failure."
      high=${mid}
      continue
    fi

    local threshold=$(( mid - (mid / 100 * allowed_error_margin) ))
    echo "Achieved: ${receiver_rate}  Threshold: ${threshold}  (target ${mid} - ${allowed_error_margin}%)"

    if [[ ${receiver_rate} -ge ${threshold} ]]; then
      echo "=> PASS — searching higher half [${mid}, ${high}]"
      max_stable_rate=${mid}
      max_stable_logfile="${logfile}"
      low=${mid}
    else
      echo "=> FAIL — searching lower half [${low}, ${mid}]"
      high=${mid}
    fi
  done

  echo ""
  if [ ${max_stable_rate} -gt 0 ]; then
    echo "Max stable rate: ${max_stable_rate} msgs/sec  (precision: ±$(( (high - low) / 2 )) msgs/sec)"
  else
    echo "No passing rate found within [0, ${high}]. Check broker connectivity or raise search_upper_bound."
  fi
}

# ---- main ----

checkdependencies

# Parse passed-in test arrays (semicolon-delimited, same convention as run-smart-testset.sh)
testarray1=$(echo ${@} | cut -d ';' -f 2)
testarray2=$(echo ${@} | cut -d ';' -f 3)
testarray3=$(echo ${@} | cut -d ';' -f 4)
testarray4=$(echo ${@} | cut -d ';' -f 5)
testarray5=$(echo ${@} | cut -d ';' -f 6)
testarray6=$(echo ${@} | cut -d ';' -f 7)
testarray7=$(echo ${@} | cut -d ';' -f 8)

# Resolve hostname to IP if a plain name was given
if [ -z "${vmrs}" ] || [[ ${vmrs} != *"."* ]]; then
  ip=$(dig ${vmrs} +short)
  if [[ ${ip} != *"."* ]]; then
    echo "No valid router IP given to run against, exiting..."
    exit 1
  else
    vmrs=${ip}
    echo "Router IP set to: $vmrs"
  fi
else
  echo "Router IP set to: $vmrs"
fi

echo ""
echo "Running binary search testset for ${testsetprefix} ${msg_type} on ${vmrs}"

xIFS=$IFS
IFS=$';'
for testarray in ${testarray7} ${testarray6} ${testarray5} ${testarray4} ${testarray3} ${testarray2} ${testarray1}; do
  if [ -n "${testarray}" ]; then
    IFS=$xIFS
    for parameters in ${testarray}; do
      if [ -n "${parameters}" ]; then
        msg_size=$(echo ${parameters} | cut -d : -f 1)
        fanout=$(echo ${parameters}   | cut -d : -f 2)
        hosts=$(echo ${parameters}    | cut -d : -f 3)
        mt=$(echo ${parameters}       | cut -d : -f 4)

        if [ -n "${msg_size}" ] && [ -n "${fanout}" ] && [ -n "${hosts}" ] && [ -n "${mt}" ]; then
          if [[ "${prompt_between_tests}" = "true" ]]; then
            read -n 1 -s -r -p "[Press any key to continue to next scenario]"
            echo ""
          fi

          find_max_rate ${msg_size} ${fanout} ${hosts} ${mt}

          # Write the canonical result log for this scenario
          local_final_logfile="${log_dir}/${testsetprefix}_${mt}_${msg_size}_${fanout}.log"

          if [ ${max_stable_rate} -gt 0 ] && [ -n "${max_stable_logfile}" ]; then
            cp "${max_stable_logfile}" "${local_final_logfile}"
            echo "allowed error margin = ${allowed_error_margin} %" | tee -a "${local_final_logfile}"
            echo "Max stable rate found: ${max_stable_rate} msgs/sec" | tee -a "${local_final_logfile}"
            echo "Test: OK" | tee -a "${local_final_logfile}"
          else
            # No iteration passed — write a minimal failure log
            # Use the last iteration log if available (contains Ansible echo_end block for results parser)
            last_iter_log="${log_dir}/${testsetprefix}_${mt}_${msg_size}_${fanout}_iter${search_iterations}.log"
            if [ -f "${last_iter_log}" ]; then
              cp "${last_iter_log}" "${local_final_logfile}"
            else
              touch "${local_final_logfile}"
            fi
            echo "allowed error margin = ${allowed_error_margin} %" | tee -a "${local_final_logfile}"
            echo "Max stable rate found: 0 msgs/sec" | tee -a "${local_final_logfile}"
            echo "Test: Fail (no passing rate found)" | tee -a "${local_final_logfile}"
          fi

          rm -f "${log_dir}/${testsetprefix}_${mt}_${msg_size}_${fanout}_iter"*.log

          sleep 2
          echo
        else
          echo "One of msg_size, fanout, hosts or mt is empty, skipping..."
        fi
      else
        echo "Parameters is empty, skipping..."
      fi
    done
  else
    echo "Testarray is empty, skipping..."
  fi
done

# Compile results in the same format as run-testset.sh / run-smart-testset.sh
echo "Finished testset, compiling results..."
if ls "${log_dir}/${testsetprefix}"_*.log 1>/dev/null 2>&1; then
  cat $(ls -rt "${log_dir}/${testsetprefix}"_*.log) | egrep -A 14 "echo_end|RESULT" | grep -A 23 "echo_end" | tee "${result_dir}/${testsetprefix}_${msg_type}_result.txt"
fi

sleep 10
rm -f "${log_dir}/${testsetprefix}"_*.log
