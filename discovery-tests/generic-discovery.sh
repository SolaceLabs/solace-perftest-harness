#!/bin/bash
# Generic discovery testset — prompts for all required parameters and runs a
# standard scenario matrix (100B, 1024B, 20480B × fanout 1, 5, 50) using
# exponential probe + binary search to find the maximum stable throughput.
#
# Usage: ./discovery-tests/generic-discovery.sh
#   or via the wrapper: ./start-generic-discovery-test.sh

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
echo " Solace Broker Discovery Test — Generic Setup"
echo "============================================================"
echo ""

prompt broker          "Broker IP or hostname"                   ""
prompt testsetprefix   "Result file prefix"                      "discovery"
prompt sshuser         "SSH user on test hosts"                  "perfharness"
prompt parallel_hosts  "Number of parallel pub/sub host pairs"   "1"

echo ""
echo "--- Message types ---"
echo "  1) Direct only"
echo "  2) Persistent only"
echo "  3) Both direct and persistent"
read -r -p "Selection [3]: " mt_sel
mt_sel="${mt_sel:-3}"

echo ""
echo "============================================================"
echo " Running discovery for: ${broker}"
echo " Prefix: ${testsetprefix}   SSH user: ${sshuser}   Hosts: ${parallel_hosts}"
echo "============================================================"
echo ""

export sshuser
export search_upper_bound_direct=25000000
export search_upper_bound_nonpersistent=20000000
export search_upper_bound_persistent=5000000

h=${parallel_hosts}

# Build scenario arrays — standard matrix: 100B, 1024B, 20480B × fanout 1, 5, 50
direct_arr1="100:1:${h}:direct 100:5:${h}:direct 100:50:${h}:direct ;"
direct_arr2="1024:1:${h}:direct 1024:5:${h}:direct 1024:50:${h}:direct ;"
direct_arr3="20480:1:${h}:direct 20480:5:${h}:direct 20480:50:${h}:direct ;"

persist_arr1="100:1:${h}:persistent 100:5:${h}:persistent 100:50:${h}:persistent ;"
persist_arr2="1024:1:${h}:persistent 1024:5:${h}:persistent 1024:50:${h}:persistent ;"
persist_arr3="20480:1:${h}:persistent 20480:5:${h}:persistent 20480:50:${h}:persistent ;"

case "${mt_sel}" in
  1)
    msg_type="direct"
    ${BASH_SOURCE%/*}/../engine/run-binsearch-testset.sh "${broker}" "${testsetprefix}" "${msg_type}" \
      ";${direct_arr1}" "${direct_arr2}" "${direct_arr3}"
    ;;
  2)
    msg_type="persistent"
    ${BASH_SOURCE%/*}/../engine/run-binsearch-testset.sh "${broker}" "${testsetprefix}" "${msg_type}" \
      ";${persist_arr1}" "${persist_arr2}" "${persist_arr3}"
    ;;
  *)
    msg_type="mixed"
    ${BASH_SOURCE%/*}/../engine/run-binsearch-testset.sh "${broker}" "${testsetprefix}" "${msg_type}" \
      ";${direct_arr1}" "${direct_arr2}" "${direct_arr3}" \
      "${persist_arr1}" "${persist_arr2}" "${persist_arr3}"
    ;;
esac
