#!/bin/bash
# Mesh throughput binary search runner.
# Finds the maximum stable throughput of a VPN bridge, MNR, or DMR link by running
# publishers against one broker and subscribers against a second. Messages traverse
# the inter-broker link, so the measured rate is the link's throughput ceiling.
#
# For each test scenario (msg_size, fanout, hosts, msg_type), performs an exponential
# probe followed by a binary search to find the highest rate the link can sustain.
#
# Test format (same as run-binsearch-testset.sh):
#   msg_size:fanout_number:number_of_publisher_hosts:msg_type
#
# Several (up to 7) arrays/testsets can be passed in, separated by ;
# Example:
#   testarray1=""\
#   "100:1:1:direct "\
#   "1024:1:1:direct "\
#   ";"
# See mesh-tests/standard-mesh-discovery.sh for a full example.

prompt_between_tests="false"

echo "Running run-binsearch-testset-mesh.sh with args: $@"

# $1/$2 override credentials.yaml pub_broker/sub_broker
pub_broker="${1:-}"
sub_broker="${2:-}"
testsetprefix="$3"  # prefix for log and result files
msg_type="$4"       # message type label used in result filename (informational)

runlength=60               # seconds per test run
search_iterations=10       # binary search iterations after probe; precision = probe_range / 2^iterations
allowed_error_margin=5     # consumer rate must be >= (100 - margin)% of target to count as a pass
precision_pct=1            # stop binary search early when range narrows to +/-this % of midpoint
precision_threshold=500    # absolute minimum precision floor (msgs/sec) - applies at very low rates
inter_iteration_cooldown=5 # seconds to wait between iterations (allows broker/queues to settle)
: ${sshuser:=$(awk '/^sshuser:/{gsub(/[[:space:]]/, "", $2); print $2}' "${BASH_SOURCE%/*}/../config/credentials.yaml" 2>/dev/null)}
: ${sshuser:=perfharness}  # fallback if not set by caller or credentials.yaml

# Per-type upper bounds (msgs/sec). Exponential probe starts at upper_bound/1024.
# Adjust these for your environment -- too high means more probe steps, too low caps discovery.
# Can be overridden by the calling testset script via exported environment variables.
: ${mesh_upper_bound_direct:=5000000}
: ${mesh_upper_bound_nonpersistent:=2000000}
: ${mesh_upper_bound_persistent:=1000000}

log_dir=${BASH_SOURCE%/*}/../temp
result_dir=${BASH_SOURCE%/*}/../results
mkdir -p "${log_dir}" "${result_dir}"

# Summary tracking arrays (populated during the test loop)
_sum_msg_sizes=()
_sum_fanouts=()
_sum_mts=()
_sum_max_rates=()
_sum_results=()
_abort=false

checkdependencies() {
  echo "Checking dependencies..."
  for e in rm cat sed grep ls dig sleep ansible-playbook; do
    if ! command -v ${e} &> /dev/null; then
      echo "${e} not found in PATH. Please install or update PATH."
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

  # If not provided via CLI, read pub_broker/sub_broker from credentials.yaml
  if [ -z "${pub_broker}" ]; then
    pub_broker=$(grep '^pub_broker:' "${creds}" | awk '{print $2}' | tr -d '"')
  fi
  if [ -z "${sub_broker}" ]; then
    sub_broker=$(grep '^sub_broker:' "${creds}" | awk '{print $2}' | tr -d '"')
  fi

  local missing=()
  [ -z "${pub_broker}" ] && missing+=("pub_broker (CLI arg \$1 or credentials.yaml)")
  [ -z "${sub_broker}" ] && missing+=("sub_broker (CLI arg \$2 or credentials.yaml)")
  for field in pub_broker_vpn pub_broker_username pub_broker_password \
               sub_broker_vpn sub_broker_username sub_broker_password; do
    grep -q "^${field}:" "${creds}" || missing+=("${field}")
  done
  if [ ${#missing[@]} -gt 0 ]; then
    echo "Error: the following mesh credentials are missing:"
    printf '  %s\n' "${missing[@]}"
    echo "Run ./setup.sh to add them, or copy config/credentials.yaml.example."
    exit 1
  fi
}

# Run a single test and tee output to logfile.
# Usage: run_single_test <msg_size> <fanout> <hosts> <mt> <target_rate> <logfile>
run_single_test() {
  local msg_size=$1 fanout=$2 hosts=$3 mt=$4 target_rate=$5 logfile=$6
  "${BASH_SOURCE%/*}/run-test.sh" -e '{"pub_broker":"'${pub_broker}'","sub_broker":"'${sub_broker}'","parallel_hosts":'${hosts}',"target_msg_rate":'${target_rate}',"msg_size":'${msg_size}',"sdk_fanout":'${fanout}',"runlength":'${runlength}',"mt":"'${mt}'","sshuser":"'${sshuser}'"}' | tee "${logfile}"
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
    persistent)    upper=${mesh_upper_bound_persistent} ;;
    nonpersistent) upper=${mesh_upper_bound_nonpersistent} ;;
    *)             upper=${mesh_upper_bound_direct} ;;
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

  # Phase 1: exponential probe -- double from upper/1024 until first failure.
  local probe_rate=$(( upper / 1024 ))
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
      echo "Warning: could not parse consumer rate -- treating as failure."
      high=${probe_rate}
      [ ${inter_iteration_cooldown} -gt 0 ] && sleep ${inter_iteration_cooldown}
      break
    fi

    local threshold=$(( probe_rate * (100 - allowed_error_margin) / 100 ))
    echo "Achieved: ${receiver_rate}  Threshold: ${threshold}  (target ${probe_rate} - ${allowed_error_margin}%)"

    if [[ ${receiver_rate} -ge ${threshold} ]]; then
      echo "=> PASS -- doubling probe rate"
      max_stable_rate=${probe_rate}
      max_stable_logfile="${logfile}"
      low=${probe_rate}
      probe_rate=$(( probe_rate * 2 ))
      [ ${inter_iteration_cooldown} -gt 0 ] && sleep ${inter_iteration_cooldown}
    else
      echo "=> FAIL -- binary search will run in [${low}, ${probe_rate}]"
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
  echo "Will stop early at +-${precision_pct}% of midpoint (floor: +-${precision_threshold} msgs/sec)"

  for iter in $(seq 1 ${search_iterations}); do
    local mid=$(( (low + high) / 2 ))

    local pct_stop=$(( mid * precision_pct / 100 ))
    [ ${pct_stop} -lt ${precision_threshold} ] && pct_stop=${precision_threshold}
    if [ $(( high - low )) -le $(( pct_stop * 2 )) ]; then
      echo "Precision target +-${precision_pct}% (+-${pct_stop} msgs/sec) reached (range $(( high - low )) msgs/sec), stopping early."
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
      echo "Warning: could not parse consumer rate -- treating as failure."
      high=${mid}
      [ ${inter_iteration_cooldown} -gt 0 ] && sleep ${inter_iteration_cooldown}
      continue
    fi

    local threshold=$(( mid * (100 - allowed_error_margin) / 100 ))
    echo "Achieved: ${receiver_rate}  Threshold: ${threshold}  (target ${mid} - ${allowed_error_margin}%)"

    if [[ ${receiver_rate} -ge ${threshold} ]]; then
      echo "=> PASS -- searching higher half [${mid}, ${high}]"
      max_stable_rate=${mid}
      max_stable_logfile="${logfile}"
      low=${mid}
    else
      echo "=> FAIL -- searching lower half [${low}, ${mid}]"
      high=${mid}
    fi

    [ ${inter_iteration_cooldown} -gt 0 ] && sleep ${inter_iteration_cooldown}
  done

  echo ""
  if [ ${max_stable_rate} -gt 0 ]; then
    echo "Max stable rate: ${max_stable_rate} msgs/sec  (precision: +/- $(( (high - low) / 2 )) msgs/sec)"
  else
    echo "No passing rate found within [0, ${upper}]. Check broker connectivity or raise mesh_upper_bound."
  fi
}

# ---- main ----

checkdependencies
checkcredentials

# Gather host and core info for the result file header
_host_file="${BASH_SOURCE%/*}/../config/host"
_creds="${BASH_SOURCE%/*}/../config/credentials.yaml"
_pub_cores=$(awk '/^pub_cores:/{gsub(/[[:space:]]/, "", $2); print $2}' "${_creds}" 2>/dev/null); : ${_pub_cores:=unknown}
_sub_cores=$(awk '/^sub_cores:/{gsub(/[[:space:]]/, "", $2); print $2}' "${_creds}" 2>/dev/null); : ${_sub_cores:=unknown}
mapfile -t _pub_hosts < <(awk '/^\[pubhost\]/{f=1;next} /^\[/{f=0} f && /[^[:space:]]/ && !/^#/{print $1}' "${_host_file}" 2>/dev/null)
mapfile -t _sub_hosts < <(awk '/^\[subhost\]/{f=1;next} /^\[/{f=0} f && /[^[:space:]]/ && !/^#/{print $1}' "${_host_file}" 2>/dev/null)
_pub_host_str=$(IFS=', '; echo "${_pub_hosts[*]:-none}")
_sub_host_str=$(IFS=', '; echo "${_sub_hosts[*]:-none}")

# Parse passed-in test arrays (semicolon-delimited, same convention as run-binsearch-testset.sh)
# Args: pub_broker sub_broker testsetprefix msg_type ;testarray1 ;testarray2 ...
testarray1=$(echo ${@} | cut -d ';' -f 2)
testarray2=$(echo ${@} | cut -d ';' -f 3)
testarray3=$(echo ${@} | cut -d ';' -f 4)
testarray4=$(echo ${@} | cut -d ';' -f 5)
testarray5=$(echo ${@} | cut -d ';' -f 6)
testarray6=$(echo ${@} | cut -d ';' -f 7)
testarray7=$(echo ${@} | cut -d ';' -f 8)

# Resolve pub_broker hostname to IP
if [ -z "${pub_broker}" ] || [[ ${pub_broker} != *"."* ]]; then
  ip=$(dig ${pub_broker} +short)
  if [[ ${ip} != *"."* ]]; then
    echo "No valid pub_broker IP given to run against, exiting..."
    exit 1
  else
    pub_broker=${ip}
    echo "Pub broker IP set to: ${pub_broker}"
  fi
else
  echo "Pub broker IP set to: ${pub_broker}"
fi

# Resolve sub_broker hostname to IP
if [ -z "${sub_broker}" ] || [[ ${sub_broker} != *"."* ]]; then
  ip=$(dig ${sub_broker} +short)
  if [[ ${ip} != *"."* ]]; then
    echo "No valid sub_broker IP given to run against, exiting..."
    exit 1
  else
    sub_broker=${ip}
    echo "Sub broker IP set to: ${sub_broker}"
  fi
else
  echo "Sub broker IP set to: ${sub_broker}"
fi

echo ""
echo "Running mesh binary search testset for ${testsetprefix} ${msg_type}"
echo "  Publisher-side broker (messages enter): ${pub_broker}"
echo "  Subscriber-side broker (messages exit): ${sub_broker}"

xIFS=$IFS
IFS=$';'
for testarray in ${testarray7} ${testarray6} ${testarray5} ${testarray4} ${testarray3} ${testarray2} ${testarray1}; do
  [ "${_abort}" = "true" ] && break
  if [ -n "${testarray}" ]; then
    IFS=$xIFS
    for parameters in ${testarray}; do
      [ "${_abort}" = "true" ] && break
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

          # Abort if no consumer rate was received at all (broker unreachable / credentials wrong)
          if [ -z "${last_logfile}" ] || ! grep -q "all  consumers:" "${last_logfile}" 2>/dev/null; then
            echo "ERROR: No consumer rate received -- broker may be unreachable or credentials incorrect. Aborting remaining scenarios."
            _abort=true
            break
          fi

          # Write the canonical result log for this scenario
          local_final_logfile="${log_dir}/${testsetprefix}_${mt}_${msg_size}_${fanout}.log"

          if [ ${max_stable_rate} -gt 0 ] && [ -n "${max_stable_logfile}" ]; then
            cp "${max_stable_logfile}" "${local_final_logfile}"
            echo "allowed error margin = ${allowed_error_margin} %" | tee -a "${local_final_logfile}"
            echo "Max stable rate found: ${max_stable_rate} msgs/sec" | tee -a "${local_final_logfile}"
            echo "Test: OK" | tee -a "${local_final_logfile}"
          else
            if [ -n "${last_logfile}" ] && [ -f "${last_logfile}" ]; then
              cp "${last_logfile}" "${local_final_logfile}"
            else
              touch "${local_final_logfile}"
            fi
            echo "allowed error margin = ${allowed_error_margin} %" | tee -a "${local_final_logfile}"
            echo "Max stable rate found: 0 msgs/sec" | tee -a "${local_final_logfile}"
            echo "Test: Fail (no passing rate found)" | tee -a "${local_final_logfile}"
          fi

          _sum_msg_sizes+=("${msg_size}")
          _sum_fanouts+=("${fanout}")
          _sum_mts+=("${mt}")
          _sum_max_rates+=("${max_stable_rate}")
          if [ ${max_stable_rate} -gt 0 ]; then
            _sum_results+=("OK")
          else
            _sum_results+=("Fail")
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

# Compile results
echo "Finished testset, compiling results..."
if ls "${log_dir}/${testsetprefix}"_*.log 1>/dev/null 2>&1; then
  {
    . "${BASH_SOURCE%/*}/../VERSION"
    printf "Test environment\n"
    printf "  Publisher hosts  (%d): %s\n" "${#_pub_hosts[@]}" "${_pub_host_str}"
    printf "  Subscriber hosts (%d): %s\n" "${#_sub_hosts[@]}" "${_sub_host_str}"
    printf "  Publisher host cores:  %s\n" "${_pub_cores}"
    printf "  Subscriber host cores: %s\n" "${_sub_cores}"
    printf "  Publisher-side broker: %s\n" "${pub_broker}"
    printf "  Subscriber-side broker:%s\n" "${sub_broker}"
    printf "  Harness version:       %s (%s)\n\n" "${HARNESS_VERSION}" "${HARNESS_DATE}"
    cat $(ls -rt "${log_dir}/${testsetprefix}"_*.log) | egrep -A 16 "echo_end|RESULT" | grep -A 25 "echo_end"
  } | tee "${result_dir}/${testsetprefix}_${msg_type}_result.txt"
fi

# Print per-scenario summary table and append to result file
if [ ${#_sum_msg_sizes[@]} -gt 0 ]; then
  {
    echo ""
    echo "============================================================"
    echo " Results summary"
    echo "============================================================"
    printf "  %-8s  %6s  %-13s  %15s  %s\n" \
      "Msg size" "Fanout" "Type" "Max stable rate" "Result"
    printf "  %-8s  %6s  %-13s  %15s  %s\n" \
      "--------" "------" "-------------" "---------------" "------"
    _pass=0; _fail=0
    for (( _i=0; _i<${#_sum_msg_sizes[@]}; _i++ )); do
      printf "  %7sB  %6d  %-13s  %15d  %s\n" \
        "${_sum_msg_sizes[$_i]}" \
        "${_sum_fanouts[$_i]}" \
        "${_sum_mts[$_i]}" \
        "${_sum_max_rates[$_i]}" \
        "${_sum_results[$_i]}"
      if [ "${_sum_results[$_i]}" = "OK" ]; then
        (( _pass++ ))
      else
        (( _fail++ ))
      fi
    done
    echo "============================================================"
    printf "  %d/%d scenarios passed\n" "${_pass}" "$(( _pass + _fail ))"
    echo "============================================================"
  } | tee -a "${result_dir}/${testsetprefix}_${msg_type}_result.txt"
fi

# Run automated analysis on the completed result file
if [ -f "${result_dir}/${testsetprefix}_${msg_type}_result.txt" ]; then
  echo ""
  "${BASH_SOURCE%/*}/analyse-result-set.sh" "${result_dir}/${testsetprefix}_${msg_type}_result.txt"
fi

sleep 10
rm -f "${log_dir}/${testsetprefix}"_*.log
