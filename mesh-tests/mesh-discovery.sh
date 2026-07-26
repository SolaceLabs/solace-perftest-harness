#!/bin/bash
# Mesh discovery testset — f=1 only.
# Characterises the throughput of a VPN bridge, MNR, or DMR link by running
# publishers against one broker and subscribers against a second broker.
# Messages traverse the inter-broker link; the measured rate is the link ceiling.
#
# Only fanout=1 scenarios are included: at higher fanout the bridge carries a
# fraction (1/fanout) of total consumer bandwidth, so the bottleneck shifts to
# the subscriber-side broker and NIC rather than the inter-broker link itself.
# f=1 is the only scenario that directly stresses the bridge link.
#
# Usage: ./mesh-tests/mesh-discovery.sh [pub-broker-ip] [sub-broker-ip]
#
# If broker IPs/hostnames are not given on the command line, they are read from
# config/credentials.yaml (pub_broker and sub_broker fields).
#
# Estimated runtime:
#   6 scenarios x ~10 min each = ~60 min

pub_broker="${1:-}"
sub_broker="${2:-}"
testsetprefix="mesh-discovery"
msg_type="mixed"

# Tests are in the format: msg_size:fanout:number_of_publisher_hosts:msg_type
# Adjust parallel_pub_hosts to match your config/host [pubhost] count.

# --- Direct messaging ---
testarray1=""\
"100:1:1:direct "\
"1024:1:1:direct "\
"20480:1:1:direct "\
";"

# --- Persistent (guaranteed) messaging ---
testarray2=""\
"100:1:1:persistent "\
"1024:1:1:persistent "\
"20480:1:1:persistent "\
";"

${BASH_SOURCE%/*}/../engine/run-binsearch-testset-mesh.sh \
  "${pub_broker}" "${sub_broker}" ${testsetprefix} ${msg_type} \
  ";"${testarray1[@]} ${testarray2[@]}
