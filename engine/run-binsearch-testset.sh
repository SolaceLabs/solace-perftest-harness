#!/bin/bash
# Binary search approach to find the max stable throughput for Solace broker performance testing.
#
# For each test scenario (msg_size, fanout, hosts, msg_type), performs an exponential probe
# followed by a binary search to find the highest rate the broker can sustain end-to-end with
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
# See scripts in sub-folder discovery-tests for examples.

prompt_between_tests="false"

echo "Running run-binsearch-testset.sh with args: $@"
broker="$1"           # IP/hostname of the broker under test
testsetprefix="$2"  # prefix for log and result files
msg_type="$3"       # message type label used in result filename (informational)

runlength=60               # seconds per test run
search_iterations=10       # binary search iterations after probe; precision = probe_range / 2^iterations
allowed_error_margin=5     # consumer rate must be >= (100 - margin)% of target to count as a pass
precision_pct=1            # stop binary search early when range narrows to ±this % of midpoint
precision_threshold=500    # absolute minimum precision floor (msgs/sec) — applies at very low rates
inter_iteration_cooldown=5 # seconds to wait between iterations (allows broker/queues to settle)
: ${sshuser:=perfharness}  # SSH user on test hosts; override via export in calling testset script

# Per-type upper bounds (msgs/sec). Exponential probe starts at upper_bound/1024.
# Adjust these for your environment — too high means more probe steps, too low caps discovery.
# Can be overridden by the calling testset script via exported environment variables.
: ${search_upper_bound_direct:=5000000}
: ${search_upper_bound_nonpersistent:=2000000}
: ${search_upper_bound_persistent:=1000000}

log_dir=${BASH_SOURCE%/*}/../temp
result_dir=${BASH_SOURCE%/*}/../results

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
  "${BASH_SOURCE%/*}/run-test.sh" -e '{"broker":"'${broker}'","parallel_hosts":'${hosts}',"target_msg_rate":'${target_rate}',"msg_size":'${msg_size}',"sdk_fanout":'${fanout}',"runlength":'${runlength}',"mt":"'${mt}'","sshuser":"'${sshuser}'"}' | tee "${logfile}"
}

# Extract the total consumer rate from a run log.
# Usage: get_consumer_rate <logfile>
get_consumer_rate() {
  grep "all  consumers:" "$1" | awk 'BEGIN { FS=" " } { print $5 }'
}

# Exponential probe + binary search for the maximum stable consumer rate for a given scenario.
# Sets globals: max_stable_rate, max_stable_logfile, last_logfile
# Usage: find_max_rate <msg_size> <fanout> <hosts> <mt>
find_max_rate() {
  local msg_size=$1 fanout=$2 hosts=$3 mt=$4

  # Select upper bound based on message type
  local upper
  case "${mt}" in
    persistent)    upper=${search_upper_bound_persistent} ;;
    nonpersistent) upper=${search_upper_bound_nonpersistent} ;;
    *)             upper=${search_upper_bound_direct} ;;
  esac

  local low=0
  local high=${upper}
  max_stable_rate=0
  max_stable_logfile=""
  last_logfile=""

  echo ""
  echo "============================================================"
  echo "Binary search: msg_size=${msg_size} fanout=${fanout} hosts=${hosts} mt=${mt}"
  echo "Upper bound: ${upper} msgs/sec"
  echo "============================================================"

  # Phase 1: exponential probe — double from upper/1024 until first failure.
  # This tightens the search range before binary search, avoiding wasted iterations
  # when the true max is much lower than the upper bound (e.g. 20KB persistent).
  local probe_rate=$(( upper / 1024 ))
  # Ensure probe start represents at least 100 publish msgs/sec (avoids sdkperf
  # ramp-up noise causing false failures at very low rates for high-fanout scenarios).
  local probe_min=$(( 100 * fanout ))
  [ ${probe_min} -lt 100 ] && probe_min=100
  [ ${probe_rate} -lt ${probe_min} ] && probe_rate=${probe_min}
  local probe_iter=0

  echo ""
  echo "--- Phase 1: exponential probe (starting at ${probe_rate} msgs/sec) ---"

  while [ ${probe_rate} -le ${upper} ]; do
    probe_iter=$(( probe_iter + 1 ))
    local logfile="${log_dir}/${testsetprefix}_${mt}_${msg_size}_${fanout}_probe${probe_iter}.log"
    echo ""
    echo "Probe ${probe_iter}: target=${probe_rate} msgs/sec  [current range: ${low} - ${high}]"

    run_single_test ${msg_size} ${fanout} ${hosts} ${mt} ${probe_rate} "${logfile}"
    last_logfile="${logfile}"

    local receiver_rate
    receiver_rate=$(get_consumer_rate "${logfile}")

    if [ -z "${receiver_rate}" ] || ! [[ "${receiver_rate}" =~ ^[0-9]+$ ]]; then
      echo "Warning: could not parse consumer rate — treating as failure."
      high=${probe_rate}
      [ ${inter_iteration_cooldown} -gt 0 ] && sleep ${inter_iteration_cooldown}
      break
    fi

    local threshold=$(( probe_rate * (100 - allowed_error_margin) / 100 ))
    echo "Achieved: ${receiver_rate}  Threshold: ${threshold}  (target ${probe_rate} - ${allowed_error_margin}%)"

    if [[ ${receiver_rate} -ge ${threshold} ]]; then
      echo "=> PASS — doubling probe rate"
      max_stable_rate=${probe_rate}
      max_stable_logfile="${logfile}"
      low=${probe_rate}
      probe_rate=$(( probe_rate * 2 ))
      [ ${inter_iteration_cooldown} -gt 0 ] && sleep ${inter_iteration_cooldown}
    else
      echo "=> FAIL — binary search will run in [${low}, ${probe_rate}]"
      high=${probe_rate}
      [ ${inter_iteration_cooldown} -gt 0 ] && sleep ${inter_iteration_cooldown}
      break
    fi
  done

  # If probe passed all the way to the upper bound, clamp high
  if [ ${probe_rate} -gt ${upper} ]; then
    high=${upper}
  fi

  echo ""
  echo "--- Phase 2: binary search in [${low}, ${high}] over up to ${search_iterations} iterations ---"
  echo "Will stop early at ±${precision_pct}% of midpoint (floor: ±${precision_threshold} msgs/sec)"

  for iter in $(seq 1 ${search_iterations}); do
    local mid=$(( (low + high) / 2 ))

    # Early exit when range narrows to ±precision_pct% of midpoint (or absolute floor, whichever is larger)
    local pct_stop=$(( mid * precision_pct / 100 ))
    [ ${pct_stop} -lt ${precision_threshold} ] && pct_stop=${precision_threshold}
    if [ $(( high - low )) -le $(( pct_stop * 2 )) ]; then
      echo "Precision target ±${precision_pct}% (±${pct_stop} msgs/sec) reached (range $(( high - low )) msgs/sec), stopping early."
      break
    fi
    if [ ${mid} -le 0 ]; then
      echo "Midpoint reached zero, stopping search early."
      break
    fi

    local logfile="${log_dir}/${testsetprefix}_${mt}_${msg_size}_${fanout}_iter${iter}.log"
    echo ""
    echo "Iteration ${iter}/${search_iterations}: target=${mid} msgs/sec  [range: ${low} - ${high}]"

    run_single_test ${msg_size} ${fanout} ${hosts} ${mt} ${mid} "${logfile}"
    last_logfile="${logfile}"

    local receiver_rate
    receiver_rate=$(get_consumer_rate "${logfile}")

    if [ -z "${receiver_rate}" ] || ! [[ "${receiver_rate}" =~ ^[0-9]+$ ]]; then
      echo "Warning: could not parse consumer rate — treating as failure."
      high=${mid}
      [ ${inter_iteration_cooldown} -gt 0 ] && sleep ${inter_iteration_cooldown}
      continue
    fi

    local threshold=$(( mid * (100 - allowed_error_margin) / 100 ))
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

    [ ${inter_iteration_cooldown} -gt 0 ] && sleep ${inter_iteration_cooldown}
  done

  echo ""
  if [ ${max_stable_rate} -gt 0 ]; then
    echo "Max stable rate: ${max_stable_rate} msgs/sec  (precision: ±$(( (high - low) / 2 )) msgs/sec)"
  else
    echo "No passing rate found within [0, ${upper}]. Check broker connectivity or raise search_upper_bound."
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
if [ -z "${broker}" ] || [[ ${broker} != *"."* ]]; then
  ip=$(dig ${broker} +short)
  if [[ ${ip} != *"."* ]]; then
    echo "No valid router IP given to run against, exiting..."
    exit 1
  else
    broker=${ip}
    echo "Router IP set to: $broker"
  fi
else
  echo "Router IP set to: $broker"
fi

echo ""
echo "Running binary search testset for ${testsetprefix} ${msg_type} on ${broker}"

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
            # No iteration passed — use the last log written (contains Ansible output for results parser)
            if [ -n "${last_logfile}" ] && [ -f "${last_logfile}" ]; then
              cp "${last_logfile}" "${local_final_logfile}"
            else
              touch "${local_final_logfile}"
            fi
            echo "allowed error margin = ${allowed_error_margin} %" | tee -a "${local_final_logfile}"
            echo "Max stable rate found: 0 msgs/sec" | tee -a "${local_final_logfile}"
            echo "Test: Fail (no passing rate found)" | tee -a "${local_final_logfile}"
          fi

          rm -f "${log_dir}/${testsetprefix}_${mt}_${msg_size}_${fanout}_iter"*.log
          rm -f "${log_dir}/${testsetprefix}_${mt}_${msg_size}_${fanout}_probe"*.log

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
