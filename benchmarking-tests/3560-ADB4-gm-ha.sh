#!/bin/bash
# Guaranteed (persistent) messaging testset for Solace 3560 hardware appliance (ADB4 configuration),
# configured in HA mode (primary + backup + witness).
#
# Target rates are total consumer msgs/sec across all hosts:
#   100B/1024B: disk IOPS-limited; based on Solace 3560 published spec
#                 (640,000 at f=1, 2,800,000 at f=10 for 1KB)
#                 100B and 1KB show similar throughput as both are IOPS-limited (not bandwidth-limited)
#   4096B:      transitioning to disk write bandwidth-limited; rates interpolated between
#                 1KB (IOPS-limited) and 20KB (bandwidth-limited) regimes
#   20480B:     disk write bandwidth-limited; derived from londonlab measurements
#                 (~12k publish/sec = ~240 MB/s ADB write rate; consumer scales linearly with fanout)
#   f=50 values are estimates — update with measured results when available.
#
# Must be run against an HA-configured broker pair (primary + backup + witness).
# Requires 4 publisher hosts and 4 consumer hosts for full-rate testing.
# Test format: msg_size:fanout:overall_msg_rate:parallel_hosts:msg_type

broker="${1}"
testsetprefix="3560-ADB4-ha"
msg_type="persistent"

# 100B — disk IOPS-limited (similar throughput to 1KB; message size below IOPS/bandwidth crossover)
testarray1=""\
"100:1:620000:4:${msg_type} "\
"100:2:850000:4:${msg_type} "\
"100:5:1500000:4:${msg_type} "\
"100:10:2700000:4:${msg_type} "\
"100:50:4000000:4:${msg_type} "\
";"

# 1024B — disk IOPS-limited (spec: 640k at f=1, 2.8M at f=10)
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

# 20480B — disk write bandwidth-limited (~240 MB/s ADB write rate, ~12k publish/sec at any fanout)
testarray4=""\
"20480:1:11000:4:${msg_type} "\
"20480:2:22000:4:${msg_type} "\
"20480:5:55000:4:${msg_type} "\
"20480:10:110000:4:${msg_type} "\
"20480:50:550000:4:${msg_type} "\
";"

${BASH_SOURCE%/*}/../run-testset.sh ${broker} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]} ${testarray4[@]}
