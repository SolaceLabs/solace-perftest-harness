#!/bin/bash
# Direct messaging testset for Solace 3560 hardware appliance (ADB4 configuration).
#
# Target rates are total consumer msgs/sec across all hosts:
#   100B:   broker CPU / packet-rate limited; based on Solace 3560 published spec
#             (11,000,000 at f=1, 24,000,000 at f=10)
#   1024B:  network bandwidth-limited with 4x 10GbE test hosts (~5 GB/s)
#   20480B: network bandwidth-limited (~60k/host measured on londonlab; ~240k at 4 hosts)
#
# Requires 4 publisher hosts and 4 consumer hosts for full-rate testing.
# Test format: msg_size:fanout:overall_msg_rate:parallel_hosts:msg_type

broker="${1}"
testsetprefix="3560-ADB4"
msg_type="direct"

# 100B — broker CPU / packet-rate limited (spec: 11M at f=1, 24M at f=10)
testarray1=""\
"100:1:10000000:4:${msg_type} "\
"100:2:12000000:4:${msg_type} "\
"100:5:20000000:4:${msg_type} "\
"100:10:23000000:4:${msg_type} "\
"100:50:24000000:4:${msg_type} "\
";"

# 1024B — network bandwidth-limited; consumer rate plateaus at ~4M with 4x 10GbE sub hosts
testarray2=""\
"1024:1:3600000:4:${msg_type} "\
"1024:2:4000000:4:${msg_type} "\
"1024:5:4000000:4:${msg_type} "\
"1024:10:4000000:4:${msg_type} "\
"1024:50:4000000:4:${msg_type} "\
";"

# 20480B — network bandwidth-limited; fanout has minimal impact on total consumer rate
testarray3=""\
"20480:1:200000:4:${msg_type} "\
"20480:2:230000:4:${msg_type} "\
"20480:5:240000:4:${msg_type} "\
"20480:10:240000:4:${msg_type} "\
"20480:50:240000:4:${msg_type} "\
";"

${BASH_SOURCE%/*}/../run-testset.sh ${broker} ${testsetprefix} ${msg_type} ";"${testarray1[@]} ${testarray2[@]} ${testarray3[@]}
