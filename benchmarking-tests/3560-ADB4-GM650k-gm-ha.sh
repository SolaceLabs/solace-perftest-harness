#!/bin/bash
# Guaranteed (persistent) messaging testset for Solace 3560 hardware appliance (ADB4 configuration),
# configured in HA mode (primary + backup + witness).
# Target rates are total consumer msgs/sec across all hosts:
#   100B/1024B: disk IOPS-limited; based on Solace 3560 published spec
#                 (~620,000 at f=1, ~3,800,000 at f=10 for 1KB; GM650 key)
#                 100B and 1KB show similar throughput as both are IOPS-limited (not bandwidth-limited)
#   4096B:      transitioning to disk write bandwidth-limited; rates interpolated between
#                 1KB (IOPS-limited) and 20KB (bandwidth-limited) regimes
#   20480B:     disk write bandwidth-limited; spec ~59k publish/sec at f=1 (~1.2 GB/s ADB write rate)
#                 consumer rate plateaus around f=10 (~432k); does NOT scale linearly to f=50
#   f=50 values are estimates — update with measured results when available.
#
# Must be run against an HA-configured broker pair (primary + backup + witness).
# Requires 4 publisher hosts and 4 consumer hosts for full-rate testing.
# Test format: msg_size:fanout:overall_msg_rate:parallel_hosts:msg_type

broker="${1}"
testsetprefix="3560-ADB4-GM650k-ha"
msg_type="persistent"
test_type="${msg_type}"

# 100B — disk IOPS-limited (similar throughput to 1KB; message size below IOPS/bandwidth crossover)
testarray1=""\
"100:1:620000:4:${msg_type} "\
"100:2:850000:4:${msg_type} "\
"100:5:1500000:4:${msg_type} "\
"100:10:2700000:4:${msg_type} "\
"100:50:4000000:4:${msg_type} "\
";"

# 1024B — disk IOPS-limited (spec: ~620k at f=1, ~3.8M at f=10; GM650 key)
testarray2=""\
"1024:1:620000:4:${msg_type} "\
"1024:2:850000:4:${msg_type} "\
"1024:5:1500000:4:${msg_type} "\
"1024:10:2700000:4:${msg_type} "\
"1024:50:4000000:4:${msg_type} "\
";"

# 4096B — disk write bandwidth-limited (interpolated between 1KB and 20KB regimes)
testarray3=""\
"4096:1:100000:4:${msg_type} "\
"4096:2:200000:4:${msg_type} "\
"4096:5:500000:4:${msg_type} "\
"4096:10:1000000:4:${msg_type} "\
"4096:50:2000000:4:${msg_type} "\
";"

# 20480B — disk write bandwidth-limited (~59k publish/sec = ~1.2 GB/s ADB write rate)
# consumer rate plateaus at ~432k from f=10 onwards; f=50 target capped below spec ceiling
testarray4=""\
"20480:1:11000:4:${msg_type} "\
"20480:2:22000:4:${msg_type} "\
"20480:5:55000:4:${msg_type} "\
"20480:10:110000:4:${msg_type} "\
"20480:50:200000:4:${msg_type} "\
";"

${BASH_SOURCE%/*}/../engine/run-testset.sh ${broker} ${testsetprefix} ${test_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]}
