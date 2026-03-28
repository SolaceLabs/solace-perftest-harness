#!/bin/bash
# Builds a custom binary-search discovery testset and saves it under custom-sets/.
# Prompts for message types, sizes, fanout values and other parameters,
# then generates a self-contained script that can be re-run at any time.
#
# Usage: ./start-custom-discovery-test.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Prompt helper: prompt <varname> <label> [default] ---
prompt() {
  local var="$1" label="$2" default="$3" value
  if [ -n "${default}" ]; then
    read -r -p "${label} [${default}]: " value
    value="${value:-${default}}"
  else
    read -r -p "${label}: " value
    while [ -z "${value}" ]; do
      echo "  This field is required."
      read -r -p "${label}: " value
    done
  fi
  printf -v "${var}" '%s' "${value}"
}

echo "============================================================"
echo " Solace Broker — Custom Discovery Test Builder"
echo "============================================================"
echo ""
echo "This wizard creates a custom binary-search discovery testset"
echo "saved to custom-sets/ so it can be re-run at any time."
echo ""

# --- Basic parameters ---
prompt test_name "Test name (filename and result prefix)" ""
read -r -p "Broker hostname or IP (blank = prompt when run): " broker

default_sshuser=$(awk '/^sshuser:/{print $2}' "${SCRIPT_DIR}/config/credentials.yaml" 2>/dev/null)
: "${default_sshuser:=perfharness}"
prompt sshuser        "SSH user on test hosts"                 "${default_sshuser}"
prompt parallel_hosts "Number of parallel pub/sub host pairs"  "1"

# --- Message types ---
echo ""
echo "--- Message types ---"
echo "  1) Direct only"
echo "  2) Guaranteed (persistent) only"
echo "  3) Both direct and guaranteed"
read -r -p "Selection [3]: " mt_sel
mt_sel="${mt_sel:-3}"

case "${mt_sel}" in
  1) types_list="direct";               msg_type_label="direct" ;;
  2) types_list="persistent";           msg_type_label="persistent" ;;
  *) types_list="direct persistent";    msg_type_label="mixed" ;;
esac

# --- Message sizes ---
echo ""
echo "--- Message sizes (bytes, comma or space separated) ---"
echo "Common: 100, 1024, 4096, 20480"
read -r -p "Sizes [100,1024,20480]: " sizes_raw
sizes_raw="${sizes_raw:-100,1024,20480}"
sizes="${sizes_raw//,/ }"

# --- Fanout values ---
echo ""
echo "--- Fanout values (comma or space separated) ---"
echo "Number of consumer subscriptions per published message"
read -r -p "Fanouts [1,5,50]: " fanouts_raw
fanouts_raw="${fanouts_raw:-1,5,50}"
fanouts="${fanouts_raw//,/ }"

# --- Upper bounds ---
echo ""
echo "--- Search upper bounds (consumer msgs/sec) ---"
echo "Sets the ceiling for the exponential probe. Use a generous estimate"
echo "above the expected peak — too low caps results, too high adds probe steps."
prompt ub_direct      "Direct upper bound (msgs/sec)"         "5000000"
prompt ub_nonpersist  "Non-persistent upper bound (msgs/sec)" "2000000"
prompt ub_persist     "Guaranteed upper bound (msgs/sec)"     "1000000"

# --- Validate group count (runner supports up to 7 semicolon-delimited groups) ---
n_arrays=0
for mt in ${types_list}; do
  for s in ${sizes}; do
    n_arrays=$(( n_arrays + 1 ))
  done
done

if [ "${n_arrays}" -gt 7 ]; then
  echo ""
  echo "Error: this configuration produces ${n_arrays} scenario groups."
  echo "The binary search runner supports at most 7 groups."
  echo "Reduce the number of message sizes or use a single message type."
  exit 1
fi

# --- Sanitise test name for use as a filename ---
safe_name="${test_name//[^a-zA-Z0-9_-]/-}"
if [ "${safe_name}" != "${test_name}" ]; then
  echo ""
  echo "Note: test name sanitised to '${safe_name}' for use as a filename."
  test_name="${safe_name}"
fi

# --- Check for existing file ---
outfile="${SCRIPT_DIR}/custom-sets/${test_name}.sh"
if [ -f "${outfile}" ]; then
  echo ""
  read -r -p "File '${outfile}' already exists. Overwrite? [y/N]: " overwrite
  if ! [[ "${overwrite}" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi
fi

# --- Summary ---
echo ""
echo "============================================================"
echo " Test configuration"
echo "============================================================"
echo " Test name     : ${test_name}"
if [ -n "${broker}" ]; then
  echo " Broker        : ${broker}"
else
  echo " Broker        : (will prompt when the testset is run)"
fi
echo " SSH user      : ${sshuser}"
echo " Parallel hosts: ${parallel_hosts}"
echo " Message types : ${msg_type_label}"
echo " Message sizes : ${sizes}"
echo " Fanout values : ${fanouts}"
echo " Upper bounds  : direct=${ub_direct}  nonpersist=${ub_nonpersist}  persist=${ub_persist}"
echo " Scenario groups: ${n_arrays}"
echo "============================================================"
echo ""

# --- Generate the testset script ---
mkdir -p "${SCRIPT_DIR}/custom-sets"

{
  printf '#!/bin/bash\n'
  printf '# Custom discovery testset: %s\n' "${test_name}"
  printf '# Generated: %s\n' "$(date '+%Y-%m-%d')"
  printf '# Message types  : %s\n' "${msg_type_label}"
  printf '# Message sizes  : %s\n' "${sizes}"
  printf '# Fanout values  : %s\n' "${fanouts}"
  printf '# Parallel hosts : %s\n' "${parallel_hosts}"
  printf '#\n'
  printf '# Usage: ./custom-sets/%s.sh [broker_hostname_or_ip]\n' "${test_name}"
  printf '\n'

  # Broker setup in the generated script
  if [ -n "${broker}" ]; then
    printf 'broker="${1:-%s}"\n' "${broker}"
  else
    cat <<'BROKERBLOCK'
broker="${1}"
if [ -z "${broker}" ]; then
  read -r -p "Broker IP or hostname: " broker
  while [ -z "${broker}" ]; do
    echo "  This field is required."
    read -r -p "Broker IP or hostname: " broker
  done
fi
BROKERBLOCK
  fi

  printf '\ntestsetprefix="%s"\n' "${test_name}"
  printf 'msg_type="%s"\n' "${msg_type_label}"
  printf '\nexport sshuser=%s\n' "${sshuser}"
  printf 'export search_upper_bound_direct=%s\n' "${ub_direct}"
  printf 'export search_upper_bound_nonpersistent=%s\n' "${ub_nonpersist}"
  printf 'export search_upper_bound_persistent=%s\n' "${ub_persist}"
  printf '\n'

  # Testarray assignments — one per (message type, message size) combination.
  # Each array holds all fanout scenarios for that size/type, ';'-terminated.
  array_idx=0
  for mt in ${types_list}; do
    printf '# --- %s messaging ---\n' "${mt}"
    for s in ${sizes}; do
      array_idx=$(( array_idx + 1 ))
      printf 'testarray%d="' "${array_idx}"
      for f in ${fanouts}; do
        printf '%s:%s:%s:%s ' "${s}" "${f}" "${parallel_hosts}" "${mt}"
      done
      printf ';"\n'
    done
    printf '\n'
  done

  # Runner call — testarrays are passed unquoted so bash word-splits on the
  # embedded spaces; the runner reassembles them via 'echo ${@}' and cuts on ';'.
  printf '%s\n' '${BASH_SOURCE%/*}/../engine/run-binsearch-testset.sh ${broker} ${testsetprefix} ${msg_type} \'

  # Build the testarray argument string: ";"${testarray1} ${testarray2} ...
  runner_arrays='  ";"${testarray1}'
  for i in $(seq 2 "${array_idx}"); do
    runner_arrays="${runner_arrays} \${testarray${i}}"
  done
  printf '%s\n' "${runner_arrays}"

} > "${outfile}"

chmod +x "${outfile}"
echo "Testset written to: ${outfile}"
echo ""

# --- Optionally run immediately ---
read -r -p "Run this testset now? [y/N]: " run_now
if [[ "${run_now}" =~ ^[Yy]$ ]]; then
  if [ -n "${broker}" ]; then
    exec "${outfile}" "${broker}"
  else
    exec "${outfile}"
  fi
fi
