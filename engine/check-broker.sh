#!/bin/bash
# Pre-flight SEMP broker configuration check.
# Reads SEMP credentials from credentials.yaml, queries SEMP v2 REST API,
# and reports numbered findings before a test run starts.
#
# Usage: check-broker.sh <creds_file> <has_persistent: 0|1> [pub|sub|""]
#
# Side prefix controls which credential fields to read:
#   ""    -> semp_host, broker_vpn, broker_username  (single-broker mode)
#   "pub" -> pub_semp_host, pub_broker_vpn, pub_broker_username
#   "sub" -> sub_semp_host, sub_broker_vpn, sub_broker_username
#
# Exit codes:
#   0  = no issues found, or SEMP not configured -- test proceeds normally
#   1  = findings found, user chose to proceed (or non-interactive)
#   2  = findings found, user declined to run

if ! command -v curl &>/dev/null; then
  echo "Error: curl not found in PATH. Please install curl."
  exit 1
fi

creds_file="$1"
has_persistent="${2:-0}"
side_prefix="${3:-}"   # "" | "pub" | "sub"

# ---- Field reader: extracts a scalar value from credentials.yaml ----
# Handles inline comments, surrounding quotes, and spaces.
_field() {
  grep -m1 "^$1:" "${creds_file}" 2>/dev/null \
    | sed "s/^$1://;s/#.*//;s/[[:space:]]//g;s/^\"//;s/\"$//"
}

# ---- Read a SEMP-specific field, adding side prefix if set ----
_semp_field() {
  local key="${side_prefix:+${side_prefix}_}$1"
  _field "${key}"
}

# ---- Read a broker credential field, adding side prefix if set ----
_broker_cred() {
  if [ -z "${side_prefix}" ]; then
    _field "$1"
  else
    _field "${side_prefix}_$1"
  fi
}

# ---- Load SEMP connection details ----
semp_host=$(_semp_field "semp_host")
[ -z "${semp_host}" ] && exit 0   # Not configured -- skip silently

semp_port=$(_semp_field "semp_port")
: "${semp_port:=8080}"
semp_user=$(_semp_field "semp_username")
: "${semp_user:=admin}"
semp_pass=$(_semp_field "semp_password")
: "${semp_pass:=admin}"
semp_tls=$(_semp_field "semp_tls")

broker_vpn=$(_broker_cred "broker_vpn")
broker_user=$(_broker_cred "broker_username")
broker_protocol=$(_field "${side_prefix:+${side_prefix}_}broker_protocol")
: "${broker_protocol:=smf}"

if [ -z "${broker_vpn}" ]; then
  echo "  WARNING: broker_vpn not set -- skipping pre-flight check."
  exit 0
fi

# ---- Build SEMP v2 base URL ----
if [ "${semp_tls}" = "true" ]; then
  _scheme="https"
else
  _scheme="http"
fi
_base="${_scheme}://${semp_host}:${semp_port}/SEMP/v2/config"

# ---- SEMP GET helper ----
_get() {
  curl -s -u "${semp_user}:${semp_pass}" \
    --connect-timeout 5 --max-time 10 \
    "${_base}/$1" 2>/dev/null
}

# ---- Extract a scalar field from a SEMP v2 JSON response ----
# Works for boolean, integer, and quoted-string values.
_jf() {
  echo "$1" | grep -o "\"$2\":[^,}]*" | head -1 \
    | sed 's/^[^:]*: *//' | tr -d ' "'
}

# ---- Findings accumulator ----
_findings=()
_add() { _findings+=("$*"); }

# ---- Word-wrap a finding line to 78 chars ----
# prefix (e.g. "  [1] ") starts the first line; continuation is 6 spaces.
_wrap() {
  local pfx="$1" text="$2" cont="      " max=78
  local cur="${pfx}"
  local -a words
  IFS=' ' read -ra words <<< "${text}"
  for w in "${words[@]}"; do
    if [ "${cur}" = "${pfx}" ]; then
      cur="${pfx}${w}"
    elif [ $(( ${#cur} + 1 + ${#w} )) -le ${max} ]; then
      cur="${cur} ${w}"
    else
      printf '%s\n' "${cur}"
      cur="${cont}${w}"
    fi
  done
  [ -n "${cur}" ] && printf '%s\n' "${cur}"
}

# ---- Print all accumulated findings ----
_print_findings() {
  local i=1
  for f in "${_findings[@]}"; do
    _wrap "  [${i}] " "${f}"
    (( i++ ))
  done
}

# ---- Print banner ----
_label=""
[ -n "${side_prefix}" ] && _label=" (${side_prefix}-side broker)"
echo ""
echo "============================================================"
echo " Solace Broker Pre-flight Check${_label}"
echo "============================================================"
printf "  Broker: %s  VPN: %s  User: %s  Protocol: %s\n\n" \
  "${semp_host}" "${broker_vpn}" "${broker_user}" "${broker_protocol}"

# ---- Check 1: SEMP reachability ----
echo "  Checking broker configuration via SEMP..."
_about=$(_get "about")
_curl_rc=$?

if [ ${_curl_rc} -ne 0 ] || [ -z "${_about}" ]; then
  echo "  WARNING: Cannot reach SEMP at ${_scheme}://${semp_host}:${semp_port}"
  echo "  (curl exit code: ${_curl_rc})"
  echo "  Skipping pre-flight checks -- tests will proceed."
  echo ""
  exit 0
fi
if ! echo "${_about}" | grep -q '"meta"'; then
  echo "  WARNING: Unexpected response from SEMP -- may not be a SEMP v2 endpoint."
  echo "  Check semp_host and semp_port in credentials.yaml."
  echo "  Skipping pre-flight checks -- tests will proceed."
  echo ""
  exit 0
fi
if echo "${_about}" | grep -q '"UNAUTHORIZED"'; then
  echo "  WARNING: SEMP authentication failed."
  echo "  Check semp_username and semp_password in credentials.yaml."
  echo "  Skipping pre-flight checks -- tests will proceed."
  echo ""
  exit 0
fi

# ---- Check 2-3: VPN exists and is enabled ----
_vpn_resp=$(_get "msgVpns/${broker_vpn}")
_skip=false

if echo "${_vpn_resp}" | grep -qE '"NOT_FOUND"|"INVALID_PATH"'; then
  _add "VPN '${broker_vpn}' does not exist on broker ${semp_host}. Create the VPN or correct broker_vpn in credentials.yaml."
  _skip=true
elif echo "${_vpn_resp}" | grep -q '"meta"'; then
  _vpn_enabled=$(_jf "${_vpn_resp}" "enabled")
  _vpn_gm=$(_jf "${_vpn_resp}" "guaranteedMsgingEnabled")
  _vpn_spool=$(_jf "${_vpn_resp}" "maxMsgSpoolUsage")

  [ "${_vpn_enabled}" = "false" ] && \
    _add "VPN '${broker_vpn}' is disabled. Enable it in the broker management interface before running tests."

  # ---- Checks 4-5: Guaranteed messaging (persistent only) ----
  if [ "${has_persistent}" = "1" ]; then
    [ "${_vpn_gm}" = "false" ] && \
      _add "Guaranteed messaging is not enabled on VPN '${broker_vpn}'. Persistent/non-persistent tests will fail. Enable it in Message VPN settings → Guaranteed Messaging."
    [ "${_vpn_spool}" = "0" ] && \
      _add "Spool quota on VPN '${broker_vpn}' is 0 MB. Persistent messages cannot be queued. Set a non-zero spool size in the VPN settings."
  fi
fi

if [ "${_skip}" = "false" ]; then

  # ---- Check 6: Client username exists and is enabled ----
  _cu_resp=$(_get "msgVpns/${broker_vpn}/clientUsernames/${broker_user}")

  if echo "${_cu_resp}" | grep -q '"NOT_FOUND"'; then
    _add "Client username '${broker_user}' does not exist on VPN '${broker_vpn}'. Create it or correct broker_username in credentials.yaml."
  elif echo "${_cu_resp}" | grep -q '"meta"'; then
    _cu_enabled=$(_jf "${_cu_resp}" "enabled")
    _cp_name=$(_jf "${_cu_resp}" "clientProfileName")
    _acl_name=$(_jf "${_cu_resp}" "aclProfileName")

    [ "${_cu_enabled}" = "false" ] && \
      _add "Client username '${broker_user}' is disabled on VPN '${broker_vpn}'. Enable it in the broker management interface."

    # ---- Checks 7-9: Client profile guaranteed messaging (persistent only) ----
    if [ "${has_persistent}" = "1" ] && [ -n "${_cp_name}" ]; then
      _cp_resp=$(_get "msgVpns/${broker_vpn}/clientProfiles/${_cp_name}")
      if echo "${_cp_resp}" | grep -q '"meta"'; then
        _cp_ep=$(_jf "${_cp_resp}" "allowGuaranteedEndpointCreateEnabled")
        _cp_send=$(_jf "${_cp_resp}" "allowGuaranteedMsgSendEnabled")
        _cp_recv=$(_jf "${_cp_resp}" "allowGuaranteedMsgReceiveEnabled")

        [ "${_cp_ep}" = "false" ] && \
          _add "'Allow Guaranteed Endpoint Create' is not enabled on client profile '${_cp_name}'. Subscriber cannot provision queues. Enable in Client Profiles → Guaranteed Messaging Permissions."
        [ "${_cp_send}" = "false" ] && \
          _add "'Allow Guaranteed Send' is not enabled on client profile '${_cp_name}'. Publishers cannot send persistent messages. Enable in Client Profiles → Guaranteed Messaging Permissions."
        [ "${_cp_recv}" = "false" ] && \
          _add "'Allow Guaranteed Receive' is not enabled on client profile '${_cp_name}'. Subscribers cannot receive guaranteed messages. Enable in Client Profiles → Guaranteed Messaging Permissions."
      fi
    fi

    # ---- Checks 10-12: ACL profile connect/publish/subscribe default actions ----
    if [ -n "${_acl_name}" ]; then
      _acl_resp=$(_get "msgVpns/${broker_vpn}/aclProfiles/${_acl_name}")
      if echo "${_acl_resp}" | grep -q '"meta"'; then
        _connect_default=$(_jf "${_acl_resp}" "clientConnectDefaultAction")
        _pub_default=$(_jf "${_acl_resp}" "publishTopicDefaultAction")
        _sub_default=$(_jf "${_acl_resp}" "subscribeTopicDefaultAction")

        if [ "${_connect_default}" = "disallow" ]; then
          _exc=$(_get "msgVpns/${broker_vpn}/aclProfiles/${_acl_name}/clientConnectExceptions")
          if ! echo "${_exc}" | grep -qE '"clientConnectException"'; then
            _add "ACL profile '${_acl_name}' blocks client connections by default and has no exceptions. All sdkperf clients will be refused with CLIENT_ACL_DENIED (403). Set clientConnectDefaultAction to 'allow' in the ACL profile."
          fi
        fi

        if [ "${_pub_default}" = "disallow" ]; then
          _exc=$(_get "msgVpns/${broker_vpn}/aclProfiles/${_acl_name}/publishTopicExceptions")
          if ! echo "${_exc}" | grep -qE '"publishTopicException"[[:space:]]*:[[:space:]]*"[^"]*[>*#]'; then
            _add "ACL profile '${_acl_name}' blocks publish by default and has no wildcard exception. Publishers will silently send 0 messages. Add a publish topic exception (e.g. '>') in the ACL profile, or switch to allow-by-default."
          fi
        fi

        if [ "${_sub_default}" = "disallow" ]; then
          _exc=$(_get "msgVpns/${broker_vpn}/aclProfiles/${_acl_name}/subscribeTopicExceptions")
          if ! echo "${_exc}" | grep -qE '"subscribeTopicException"[[:space:]]*:[[:space:]]*"[^"]*[>*#]'; then
            _add "ACL profile '${_acl_name}' blocks subscribe by default and has no wildcard exception. Subscribers will receive 0 messages. Add a subscribe topic exception (e.g. '>') in the ACL profile, or switch to allow-by-default."
          fi
        fi
      fi
    fi
  fi

fi  # end _skip=false block

# ---- Output findings ----
echo ""
if [ ${#_findings[@]} -eq 0 ]; then
  echo "  No issues detected."
  echo ""
  exit 0
fi

echo "  Findings:"
echo ""
_print_findings
echo ""

# ---- Prompt (interactive only) ----
if [ -t 1 ]; then
  read -r -p "Run anyway? (Y/n): " _ans
  echo ""
  [[ "${_ans}" =~ ^[Nn]$ ]] && exit 2
else
  echo "  (Non-interactive mode -- proceeding despite findings.)"
  echo ""
fi

exit 1
