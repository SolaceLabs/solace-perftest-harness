#!/bin/bash
# Discovery testset for emea8.londonlab using binary search.
# Finds the maximum stable throughput for a range of message sizes and fanouts
# without requiring prior knowledge of the broker's capabilities.
#
# Usage: ./discovery-tests/londonlab-discovery.sh [router_ip_or_hostname]
# Default router: emea8.londonlab
#
# Estimated runtime:
#   Direct tests:     9 scenarios x ~10 min = ~90 min
#   Persistent tests: 9 scenarios x ~10 min = ~90 min
#   Total: ~3 hours
#
# To run direct only: comment out the persistent arrays below.
# To shorten runs: reduce search_iterations or runlength in run-binsearch-testset.sh.

broker="${1:-emea8.londonlab}"
testsetprefix="londonlab-discovery"
msg_type="mixed"

# SSH user on the londonlab test hosts
export sshuser=choltfurth

# Upper bounds for Solace 3560 hardware appliance (msgs/sec).
# Based on published Solace 3560 ADB4 GM650k spec (SolOS 10.0.1):
#   Direct:      12.9M at f=1, 29M at f=10 (100B) — ceiling set above 29M spec peak
#   Nonpersist.: similar to direct, no separate official figure — match direct ceiling
#   Persistent:  620k at f=1, 4M at f=50 (100B/1KB, HA) — ceiling set above 4M spec peak
export search_upper_bound_direct=35000000
export search_upper_bound_nonpersistent=35000000
export search_upper_bound_persistent=7000000

# Tests are in the format: msg_size:fanout:number_of_publisher_hosts:msg_type
# Only 1 publisher host (emeaperf3) and 1 subscriber host (emeaperf4) available.

# --- Direct messaging ---
testarray1=""\
"100:1:1:direct "\
"100:5:1:direct "\
"100:50:1:direct "\
";"
testarray2=""\
"1024:1:1:direct "\
"1024:5:1:direct "\
"1024:50:1:direct "\
";"
testarray3=""\
"20480:1:1:direct "\
"20480:5:1:direct "\
"20480:50:1:direct "\
";"

# --- Persistent (guaranteed) messaging ---
testarray4=""\
"100:1:1:persistent "\
"100:5:1:persistent "\
"100:50:1:persistent "\
";"
testarray5=""\
"1024:1:1:persistent "\
"1024:5:1:persistent "\
"1024:50:1:persistent "\
";"
testarray6=""\
"20480:1:1:persistent "\
"20480:5:1:persistent "\
"20480:50:1:persistent "\
";"

${BASH_SOURCE%/*}/../engine/run-binsearch-testset.sh ${broker} ${testsetprefix} ${msg_type} \
  ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} \
  ${testarray4[@]} ${testarray5[@]} ${testarray6[@]}
