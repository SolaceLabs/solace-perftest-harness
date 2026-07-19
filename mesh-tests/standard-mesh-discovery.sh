#!/bin/bash
# Standard mesh discovery testset.
# Characterises the throughput of a VPN bridge, MNR, or DMR link by running
# publishers against one broker and subscribers against a second broker.
# Messages traverse the inter-broker link; the measured rate is the link ceiling.
#
# Usage: ./mesh-tests/standard-mesh-discovery.sh [pub-broker-ip] [sub-broker-ip]
#
# If broker IPs/hostnames are not given on the command line, they are read from
# config/credentials.yaml (pub_broker and sub_broker fields).
#
# Estimated runtime:
#   18 scenarios x ~10 min each = ~3 hours
#   (reduce search_iterations or runlength in run-binsearch-testset-mesh.sh to shorten)

pub_broker="${1:-}"
sub_broker="${2:-}"
testsetprefix="mesh-discovery"
msg_type="mixed"

# Tests are in the format: msg_size:fanout:number_of_publisher_hosts:msg_type
# Adjust parallel_pub_hosts to match your config/host [pubhost] count.

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

${BASH_SOURCE%/*}/../engine/run-binsearch-testset-mesh.sh \
  "${pub_broker}" "${sub_broker}" ${testsetprefix} ${msg_type} \
  ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} \
  ${testarray4[@]} ${testarray5[@]} ${testarray6[@]}
