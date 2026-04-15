#!/bin/bash
# analyse-result-set.sh
# Parses Solace perftest-harness result files and provides diagnostic guidance.
#
# Usage: ./engine/analyse-result-set.sh [file|dir ...]
#        With no arguments, scans results/ directory for *_result.txt files.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Locate files ───────────────────────────────────────────────────────────────
if [ $# -gt 0 ]; then
  files=()
  for arg in "$@"; do
    if [ -d "${arg}" ]; then
      mapfile -t found < <(find "${arg}" -name '*_result.txt' | sort)
      files+=("${found[@]}")
    elif [ -f "${arg}" ]; then
      files+=("${arg}")
    else
      echo "WARNING: not found: ${arg}"
    fi
  done
else
  mapfile -t files < <(find "${SCRIPT_DIR}/../results" -name '*_result.txt' | sort)
fi

if [ ${#files[@]} -eq 0 ]; then
  echo "No *_result.txt files found. Pass file or directory paths as arguments."
  exit 1
fi

echo "============================================================"
echo " Solace Performance Test — Result Analysis"
echo "============================================================"
printf "Analysing %d file(s)...\n" "${#files[@]}"

# ── Per-file loop ──────────────────────────────────────────────────────────────
for file in "${files[@]}"; do
  [ -f "${file}" ] || { echo "WARNING: not found: ${file}"; continue; }

  echo ""
  echo "============================================================"
  printf " %s\n" "$(basename "${file}")"
  echo "============================================================"

  # Print Test environment header if present (new-format files)
  env_block=$(head -8 "${file}" | grep -A6 'Test environment' | sed 's/^/  /')
  [ -n "${env_block}" ] && { echo "${env_block}"; echo ""; }

  # ── Parse all scenarios from the file ─────────────────────────────────────────
  # awk emits one TSV line per completed scenario:
  # msg_size fanout msg_type parallel_hosts parallel_procs target_rate pub_rate con_rate is_discovery result clock_errors has_errors
  mapfile -t scenario_lines < <(awk '
    BEGIN { reset() }

    function reset() {
      sz=""; fo=""; mt=""; ph=""; pp=""
      tr=""; pr=""; cr=""; disc=0
      res=""; ce=0; he=0
      in_echo=0; in_result=0; in_err=0
    }

    function emit(    out) {
      if (sz != "" && res != "") {
        printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
          sz, fo, mt, ph, pp, tr, (pr==""?0:pr), (cr==""?0:cr), disc, res, ce, he
        reset()
      }
    }

    { gsub(/\x1B\[[0-9;]*m/, "") }

    /TASK \[echo_end\]/ { emit(); in_echo=1; in_result=0; in_err=0; next }
    /^RESULT \*+/       { in_result=1; in_echo=0; in_err=0; next }
    /^Errors occured/   { in_err=1; he=1; next }
    /^--$/              { if (in_result && sz != "" && res == "") { res="Fail"; emit() }
                          in_err=0 }

    in_echo && /Message size/      { match($0,/[0-9]+/); sz=substr($0,RSTART,RLENGTH) }
    in_echo && /Fanout/            { match($0,/[0-9]+/); fo=substr($0,RSTART,RLENGTH) }
    in_echo && /Message type/      { if ($0~/direct/) mt="direct";
                                     else if ($0~/nonpersistent/) mt="nonpersistent";
                                     else if ($0~/persistent/) mt="persistent" }
    in_echo && /Parallel hosts/    { match($0,/[0-9]+/); ph=substr($0,RSTART,RLENGTH) }
    in_echo && /Parallel processes/{ match($0,/[0-9]+/); pp=substr($0,RSTART,RLENGTH) }
    in_echo && /Target message rate/ { match($0,/[0-9]+/); tr=substr($0,RSTART,RLENGTH) }

    in_result && /Sum across all publishers/  { match($0,/[0-9]+/); pr=substr($0,RSTART,RLENGTH)+0 }
    in_result && /Sum across all  consumers/  { match($0,/[0-9]+/); cr=substr($0,RSTART,RLENGTH)+0 }
    in_result && /Max stable rate found/      { disc=1; match($0,/[0-9]+/); tr=substr($0,RSTART,RLENGTH) }
    in_result && /^Test: OK/                  { res="OK";   emit() }
    in_result && /^Test: Fail/                { res="Fail"; emit() }

    in_err && /Error in clock/  { ce++ }
    in_err && /Error|Exception/ { he=1 }

    END { emit() }
  ' "${file}")

  if [ ${#scenario_lines[@]} -eq 0 ]; then
    echo "  (no completed scenarios found)"
    continue
  fi

  # ── Print scenario table ───────────────────────────────────────────────────────
  printf "  %-7s  %-6s  %-13s  %5s  %10s  %10s  %6s\n" \
    "Size" "Fanout" "Type" "Hosts" "Pub/s" "Con/s" "Result"
  printf "  %-7s  %-6s  %-13s  %5s  %10s  %10s  %6s\n" \
    "-------" "------" "-------------" "-----" "----------" "----------" "------"

  pass=0; fail=0
  for line in "${scenario_lines[@]}"; do
    IFS=$'\t' read -r sz fo mt ph pp tr pr cr disc res ce he <<< "${line}"
    printf "  %6sB  %6s  %-13s  %5s  %10d  %10d  %s\n" \
      "${sz}" "${fo}" "${mt}" "${ph:-1}" "${pr}" "${cr}" "${res}"
    if [ "${res}" = "OK" ]; then (( pass++ )); else (( fail++ )); fi
  done
  echo ""
  printf "  %d/%d tests passed\n" "${pass}" "$((pass + fail))"
  echo ""

  # ── Collect arrays for analysis ────────────────────────────────────────────────
  a_sz=(); a_fo=(); a_mt=(); a_ph=(); a_pp=(); a_tr=()
  a_pr=(); a_cr=(); a_disc=(); a_res=(); a_ce=(); a_he=()
  for line in "${scenario_lines[@]}"; do
    IFS=$'\t' read -r sz fo mt ph pp tr pr cr disc res ce he <<< "${line}"
    a_sz+=("${sz}"); a_fo+=("${fo}"); a_mt+=("${mt}"); a_ph+=("${ph:-1}")
    a_pp+=("${pp:-1}"); a_tr+=("${tr:-0}"); a_pr+=("${pr:-0}"); a_cr+=("${cr:-0}")
    a_disc+=("${disc}"); a_res+=("${res}"); a_ce+=("${ce:-0}"); a_he+=("${he:-0}")
  done
  n=${#a_sz[@]}

  # ── Diagnostic checks ──────────────────────────────────────────────────────────
  findings=()

  # Helper: append a finding
  note() { findings+=("$1"); }

  # ── Clock errors (publisher host CPU saturation) ───────────────────────────────
  for (( i=0; i<n; i++ )); do
    if [ "${a_ce[$i]}" -gt 0 ] 2>/dev/null; then
      note "Publisher host CPU saturation [${a_sz[$i]}B ${a_mt[$i]} f=${a_fo[$i]}]: \"Error in clock\" means sdkperf cannot sustain the requested rate — the publisher VM CPU is saturated. Use a larger instance, or reduce parallel processes per host (pub_cores in credentials.yaml)."
    fi
  done

  # ── Flat publisher rate across scenarios (absolute cap) ────────────────────────
  min_pr=999999999; max_pr=0
  min_tr=999999999; max_tr=0
  for (( i=0; i<n; i++ )); do
    pr="${a_pr[$i]}"; tr="${a_tr[$i]}"
    [ "${pr}" -gt 0 ] 2>/dev/null && [ "${pr}" -lt "${min_pr}" ] && min_pr="${pr}"
    [ "${pr}" -gt "${max_pr}" ] 2>/dev/null && max_pr="${pr}"
    [ "${tr}" -gt 0 ] 2>/dev/null && [ "${tr}" -lt "${min_tr}" ] && min_tr="${tr}"
    [ "${tr}" -gt "${max_tr}" ] 2>/dev/null && max_tr="${tr}"
  done
  if [ "${n}" -ge 3 ] && [ "${min_pr}" -gt 0 ] && [ "${max_pr}" -gt 0 ] 2>/dev/null; then
    pr_range_ratio=$(( max_pr * 100 / min_pr ))
    tr_range_ratio=$(( max_tr * 100 / (min_tr > 0 ? min_tr : 1) ))
    # Publisher rates all within 5× of each other, but targets span >10×
    if [ "${pr_range_ratio}" -lt 500 ] && [ "${tr_range_ratio}" -gt 1000 ] && [ "${fail}" -gt 0 ]; then
      note "Publisher rate bottleneck: publish rates are nearly flat (${min_pr}–${max_pr} msg/sec) across tests whose targets span ${min_tr}–${max_tr} msg/sec. The publisher host or its network connection cannot push more traffic regardless of target. Ensure the publisher host is co-located with the broker (same datacenter/VPC/subnet) and has adequate CPU and NIC capacity."
    fi
  fi

  # ── Low absolute publisher rate → WAN/network bottleneck ──────────────────────
  if [ "${n}" -ge 2 ] && [ "${max_pr}" -gt 0 ] && [ "${max_pr}" -lt 50000 ] 2>/dev/null; then
    # Compute bandwidth range: if rates don't scale with msg size, it's bandwidth-limited
    # Check by comparing 100B and >=1024B scenarios
    bw_100=0; bw_1k=0
    for (( i=0; i<n; i++ )); do
      [ "${a_pr[$i]}" -le 0 ] 2>/dev/null && continue
      bw_kbs=$(( a_pr[$i] * a_sz[$i] / 1024 ))
      [ "${a_sz[$i]}" -le 200 ] && [ "${bw_kbs}" -gt "${bw_100}" ] && bw_100="${bw_kbs}"
      [ "${a_sz[$i]}" -ge 1024 ] && [ "${bw_kbs}" -gt "${bw_1k}" ] && bw_1k="${bw_kbs}"
    done
    # If both bandwidths are similar and both low, it's network-capped
    if [ "${bw_100}" -gt 0 ] && [ "${bw_1k}" -gt 0 ] 2>/dev/null; then
      ratio=$(( bw_100 * 100 / bw_1k ))
      if [ "${ratio}" -gt 50 ] && [ "${ratio}" -lt 200 ] && [ "${bw_100}" -lt 5000 ]; then
        note "Network bandwidth bottleneck: publisher throughput is ~${bw_100} KB/s for 100B and ~${bw_1k} KB/s for 1KB — similar bandwidth regardless of message size. This is consistent with a WAN or throttled link between the publisher host and the broker. Publisher hosts must be in the same datacenter/AZ/subnet as the broker for accurate results."
      fi
    elif [ "${max_pr}" -lt 10000 ] && [ "${fail}" -eq "${n}" ]; then
      note "Very low publisher rate (max ${max_pr} msg/sec across all tests). If the publisher host is not co-located with the broker, all results will reflect network latency and bandwidth, not broker performance."
    fi
  fi

  # ── Per-scenario checks ────────────────────────────────────────────────────────
  # Track whether a publisher-side bottleneck was already identified (suppresses
  # fanout delivery false positives caused by throttled publishers)
  pub_bottleneck_flagged=false
  [ "${#findings[@]}" -gt 0 ] && pub_bottleneck_flagged=true

  for (( i=0; i<n; i++ )); do
    sz="${a_sz[$i]}"; fo="${a_fo[$i]}"; mt="${a_mt[$i]}"
    ph="${a_ph[$i]}"; pr="${a_pr[$i]}"; cr="${a_cr[$i]}"; tr="${a_tr[$i]}"
    res="${a_res[$i]}"

    [ "${sz}" -le 0 ] 2>/dev/null && continue
    [ "${pr}" -le 0 ] 2>/dev/null && continue

    # Bandwidth in KB/s
    pub_bw_kbs=$(( pr * sz / 1024 ))
    con_bw_kbs=$(( cr * sz / 1024 ))
    pub_bw_per_host_kbs=$(( pub_bw_kbs / (ph > 0 ? ph : 1) ))

    # Publisher NIC: always flag near 10 GbE (hard ceiling regardless of pass/fail)
    # Only flag near 1 GbE if test failed (otherwise it's not the bottleneck)
    if [ "${pub_bw_per_host_kbs}" -gt 1037598 ] 2>/dev/null; then
      note "${sz}B ${mt} f=${fo}: Publisher NIC near 10 GbE limit (~$(( pub_bw_per_host_kbs / 1024 )) MB/s per host). To go higher, add more publisher hosts (increase parallel_hosts)."
    elif [ "${pub_bw_per_host_kbs}" -gt 103760 ] && [ "${res}" = "Fail" ] 2>/dev/null; then
      note "${sz}B ${mt} f=${fo}: Publisher throughput ~$(( pub_bw_per_host_kbs / 1024 )) MB/s per host — near 1 GbE NIC capacity. If the publisher host has a 1 GbE NIC, this is the bottleneck. Upgrade to 10 GbE or add more publisher hosts."
    fi

    # Consumer NIC: always flag near 10 GbE; only flag near 1 GbE on failure
    if [ "${con_bw_kbs}" -gt 1037598 ] 2>/dev/null; then
      note "${sz}B ${mt} f=${fo}: Consumer NIC near 10 GbE limit (~$(( con_bw_kbs / 1024 )) MB/s). To go higher, add more subscriber hosts."
    elif [ "${con_bw_kbs}" -gt 103760 ] && [ "${res}" = "Fail" ] 2>/dev/null; then
      note "${sz}B ${mt} f=${fo}: Consumer throughput ~$(( con_bw_kbs / 1024 )) MB/s — near 1 GbE NIC capacity. If the subscriber host has a 1 GbE NIC, this is the bottleneck. Add more subscriber hosts or upgrade to 10 GbE."
    fi

    # Persistent storage IOPS: only flag on failure, and only when the pub rate
    # is clearly below the target (not just a conservative low-target test)
    if [ "${mt}" = "persistent" ] && [ "${res}" = "Fail" ] && \
       [ "${pr}" -lt 5000 ] && [ "${tr}" -gt 10000 ] 2>/dev/null; then
      note "${sz}B persistent f=${fo}: Publisher achieved only ${pr} msg/sec (target ${tr}). At 1 write per message, this is ~${pr} IOPS — possibly storage IOPS limited on the broker (e.g. AWS EBS gp3 default is 3000 IOPS). Check broker storage performance; for cloud deployments increase EBS IOPS or use instance-store volumes."
    fi

    # Fanout delivery integrity: consumer rate should be ≈ pub_rate × fanout.
    # Suppress when publisher itself is the bottleneck (fanout drop is a symptom,
    # not an independent issue) or when the test passed (minor rounding is fine).
    if ! ${pub_bottleneck_flagged} && [ "${res}" = "Fail" ] && \
       [ "${fo}" -gt 1 ] && [ "${cr}" -gt 0 ] 2>/dev/null; then
      expected=$(( pr * fo ))
      threshold=$(( expected * 90 / 100 ))
      if [ "${cr}" -lt "${threshold}" ] 2>/dev/null; then
        pct=$(( cr * 100 / (expected > 0 ? expected : 1) ))
        note "${sz}B ${mt} f=${fo}: Consumer received ${cr} msg/sec but expected ${pr}×${fo}=${expected} (~${pct}% delivery). Messages are being dropped or not delivered to all subscribers. Check: VPN message spool quota, ACL restrictions on subscriptions, or subscriber connection errors."
      fi
    fi
  done

  # ── All persistent fail, direct OK ────────────────────────────────────────────
  d_ok=0; p_fail=0; p_total=0
  for (( i=0; i<n; i++ )); do
    if [ "${a_mt[$i]}" = "direct" ]     && [ "${a_res[$i]}" = "OK"   ]; then (( d_ok++ ));   fi
    if [ "${a_mt[$i]}" = "persistent" ]; then (( p_total++ )); fi
    if [ "${a_mt[$i]}" = "persistent" ] && [ "${a_res[$i]}" = "Fail" ]; then (( p_fail++ )); fi
  done
  if [ "${d_ok}" -gt 0 ] && [ "${p_total}" -gt 0 ] && [ "${p_fail}" -eq "${p_total}" ]; then
    note "All persistent tests fail while direct tests pass. Common causes: (1) VPN message spool quota is 0 MB — check broker VPN configuration; (2) 'Allow Guaranteed Endpoint Create' not enabled in the client profile; (3) Guaranteed Messaging service not enabled on the VPN."
  fi

  # ── Publisher rate near target but all fail → broker is bottleneck ─────────────
  if [ "${fail}" -gt 0 ] && [ "${fail}" -eq "${n}" ] && [ "${max_pr}" -gt 50000 ] 2>/dev/null; then
    pub_at_target=0
    for (( i=0; i<n; i++ )); do
      pr="${a_pr[$i]}"; tr="${a_tr[$i]}"; fo="${a_fo[$i]:-1}"; ph="${a_ph[$i]:-1}"
      expected_pub=$(( tr / (fo > 0 ? fo : 1) / (ph > 0 ? ph : 1) ))
      if [ "${expected_pub}" -gt 0 ] 2>/dev/null; then
        pct=$(( pr * 100 / expected_pub ))
        if [ "${pct}" -ge 85 ]; then (( pub_at_target++ )); fi
      fi
    done
    if [ "${pub_at_target}" -gt $(( n / 2 )) ]; then
      note "Publisher rates are near target but tests fail — the broker cannot sustain the requested load. Check broker CPU utilisation, memory, and NIC throughput. Consider reducing the test targets to find the broker's actual capacity, or run a discovery test."
    fi
  fi

  # ── Print findings ─────────────────────────────────────────────────────────────
  if [ ${#findings[@]} -eq 0 ]; then
    echo "  No issues detected."
  else
    echo "  Findings:"
    for (( f=0; f<${#findings[@]}; f++ )); do
      echo ""
      printf "  [%d] %s\n" $(( f + 1 )) "${findings[$f]}" | fold -s -w 78 | \
        sed '2,$ s/^/      /'
    done
    echo ""
  fi

  unset a_sz a_fo a_mt a_ph a_pp a_tr a_pr a_cr a_disc a_res a_ce a_he findings

done

echo ""
echo "============================================================"
echo " Analysis complete"
echo "============================================================"
