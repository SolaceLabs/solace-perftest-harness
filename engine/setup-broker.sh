#!/bin/bash
# Creates or updates the client profile, ACL profile, and client username
# required for the Solace performance test harness on a Solace broker.
# Uses SEMP v2 REST API. Called by setup.sh; can also be run standalone.
#
# Usage: setup-broker.sh <creds_file> [pub|sub|""]
#
# Side prefix controls which credential fields to read:
#   ""    -> semp_host, broker_vpn, broker_username, broker_password
#   "pub" -> pub_semp_host, pub_broker_vpn, pub_broker_username, ...
#   "sub" -> sub_semp_host, ...
#
# Resources created/updated (all named after the broker VPN):
#   - Client profile:    Allow Guaranteed Endpoint Create/Send/Receive enabled
#   - ACL profile:       publish and subscribe default action = allow
#   - Client username:   enabled, password set, assigned to above profiles
#
# All operations are idempotent: safe to run on an already-configured broker.
#
# Exit codes: 0 = all operations succeeded, 1 = one or more errors

if ! command -v curl &>/dev/null; then
  echo "Error: curl not found in PATH. Please install curl."
  exit 1
fi

creds_file="$1"
side_prefix="${2:-}"

# ---- Field reader (same approach as check-broker.sh) ----
_field() {
  grep -m1 "^$1:" "${creds_file}" 2>/dev/null \
    | sed "s/^$1://;s/#.*//;s/[[:space:]]//g;s/^\"//;s/\"$//"
}
_semp_field() { _field "${side_prefix:+${side_prefix}_}$1"; }
_broker_cred() {
  if [ -z "${side_prefix}" ]; then _field "$1"; else _field "${side_prefix}_$1"; fi
}

# ---- Load credentials ----
semp_host=$(_semp_field "semp_host")
if [ -z "${semp_host}" ]; then
  echo "Error: semp_host not configured. Run setup.sh to add SEMP credentials."
  exit 1
fi

semp_port=$(_semp_field "semp_port");     : "${semp_port:=8080}"
semp_user=$(_semp_field "semp_username"); : "${semp_user:=admin}"
semp_pass=$(_semp_field "semp_password"); : "${semp_pass:=admin}"
semp_tls=$(_semp_field  "semp_tls")

broker_vpn=$(_broker_cred  "broker_vpn")
broker_user=$(_broker_cred "broker_username")
broker_pass=$(_broker_cred "broker_password")

if [ -z "${broker_vpn}" ]; then
  echo "Error: broker_vpn not set in credentials.yaml."
  exit 1
fi

# ---- Build SEMP v2 base URL ----
if [ "${semp_tls}" = "true" ]; then _scheme="https"; else _scheme="http"; fi
_base="${_scheme}://${semp_host}:${semp_port}/SEMP/v2/config"

# Profile names: both client profile and ACL profile are named after the VPN
_profile="${broker_vpn}"

# ---- SEMP REST helpers ----
_curl_get() {
  curl -s -u "${semp_user}:${semp_pass}" \
    --connect-timeout 5 --max-time 10 \
    "${_base}/$1" 2>/dev/null
}
_curl_post() {
  curl -s -u "${semp_user}:${semp_pass}" \
    --connect-timeout 5 --max-time 10 \
    -X POST -H "Content-Type: application/json" -d "$1" \
    "${_base}/$2" 2>/dev/null
}
_curl_patch() {
  curl -s -u "${semp_user}:${semp_pass}" \
    --connect-timeout 5 --max-time 10 \
    -X PATCH -H "Content-Type: application/json" -d "$1" \
    "${_base}/$2" 2>/dev/null
}

# ---- JSON escape: escapes backslash and double-quote ----
_je() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }

# ---- Response helpers ----
_has_semp_error() { echo "$1" | grep -q '"error"'; }
_semp_error_msg() {
  echo "$1" | grep -o '"description":"[^"]*"' | head -1 \
    | sed 's/"description":"//;s/"$//'
}

# ---- Step counter and output helpers ----
_errors=0
_step=0

_ok()  { (( _step++ )); printf '  [%d] %s\n' "${_step}" "$*"; }
_err() { (( _step++ )); (( _errors++ )); printf '  [%d] ERROR: %s\n' "${_step}" "$*"; }

# ---- Banner ----
_label=""; [ -n "${side_prefix}" ] && _label=" (${side_prefix}-side broker)"
echo ""
echo "============================================================"
echo " Solace Broker Client Setup${_label}"
echo "============================================================"
printf "  SEMP: %s:%s  VPN: %s\n" "${semp_host}" "${semp_port}" "${broker_vpn}"
printf "  Client username:    %s\n" "${broker_user}"
printf "  Client/ACL profile: %s\n\n" "${_profile}"

# ---- Connectivity and auth check ----
echo "  Connecting to SEMP..."
_about=$(_curl_get "about")
_curl_rc=$?

if [ ${_curl_rc} -ne 0 ] || [ -z "${_about}" ] || ! echo "${_about}" | grep -q '"meta"'; then
  echo "  ERROR: Cannot reach SEMP at ${_scheme}://${semp_host}:${semp_port}"
  echo "  (curl exit code: ${_curl_rc})"
  exit 1
fi
if echo "${_about}" | grep -q '"UNAUTHORIZED"'; then
  echo "  ERROR: SEMP authentication failed."
  echo "  Check semp_username and semp_password in credentials.yaml."
  exit 1
fi

# ---- Verify VPN exists ----
_vpn_resp=$(_curl_get "msgVpns/$(_je "${broker_vpn}")")
if echo "${_vpn_resp}" | grep -qE '"NOT_FOUND"|"INVALID_PATH"'; then
  echo "  ERROR: VPN '${broker_vpn}' does not exist on this broker."
  echo "  Create the VPN first, then re-run this script."
  exit 1
fi
echo "  VPN '${broker_vpn}' found."
echo ""

# ===========================================================================
# Step 1: Client profile
# ===========================================================================
_cp_path="msgVpns/$(_je "${broker_vpn}")/clientProfiles/$(_je "${_profile}")"
_cp_settings='"allowGuaranteedEndpointCreateEnabled":true,"allowGuaranteedMsgSendEnabled":true,"allowGuaranteedMsgReceiveEnabled":true'

_cp_exist=$(_curl_get "${_cp_path}")
if echo "${_cp_exist}" | grep -q '"NOT_FOUND"'; then
  _r=$(_curl_post \
    "{\"clientProfileName\":\"$(_je "${_profile}")\",\"msgVpnName\":\"$(_je "${broker_vpn}")\",${_cp_settings}}" \
    "msgVpns/$(_je "${broker_vpn}")/clientProfiles")
  if _has_semp_error "${_r}"; then
    _err "Client profile '${_profile}': create failed — $(_semp_error_msg "${_r}")"
  else
    _ok "Client profile '${_profile}': created"
    echo "      Allow Guaranteed Endpoint Create, Send, Receive: enabled"
  fi
else
  _r=$(_curl_patch "{${_cp_settings}}" "${_cp_path}")
  if _has_semp_error "${_r}"; then
    _err "Client profile '${_profile}': update failed — $(_semp_error_msg "${_r}")"
  else
    _ok "Client profile '${_profile}': already exists — settings confirmed"
    echo "      Allow Guaranteed Endpoint Create, Send, Receive: enabled"
  fi
fi

# ===========================================================================
# Step 2: ACL profile
# ===========================================================================
_acl_path="msgVpns/$(_je "${broker_vpn}")/aclProfiles/$(_je "${_profile}")"
_acl_settings='"publishTopicDefaultAction":"allow","subscribeTopicDefaultAction":"allow"'

_acl_exist=$(_curl_get "${_acl_path}")
if echo "${_acl_exist}" | grep -q '"NOT_FOUND"'; then
  _r=$(_curl_post \
    "{\"aclProfileName\":\"$(_je "${_profile}")\",\"msgVpnName\":\"$(_je "${broker_vpn}")\",${_acl_settings}}" \
    "msgVpns/$(_je "${broker_vpn}")/aclProfiles")
  if _has_semp_error "${_r}"; then
    _err "ACL profile '${_profile}': create failed — $(_semp_error_msg "${_r}")"
  else
    _ok "ACL profile '${_profile}': created"
    echo "      Publish default: allow  Subscribe default: allow"
  fi
else
  _r=$(_curl_patch "{${_acl_settings}}" "${_acl_path}")
  if _has_semp_error "${_r}"; then
    _err "ACL profile '${_profile}': update failed — $(_semp_error_msg "${_r}")"
  else
    _ok "ACL profile '${_profile}': already exists — settings confirmed"
    echo "      Publish default: allow  Subscribe default: allow"
  fi
fi

# ===========================================================================
# Step 3: Client username
# ===========================================================================
_cu_path="msgVpns/$(_je "${broker_vpn}")/clientUsernames/$(_je "${broker_user}")"
_cu_profile_fields="\"clientProfileName\":\"$(_je "${_profile}")\",\"aclProfileName\":\"$(_je "${_profile}")\",\"enabled\":true"

_cu_exist=$(_curl_get "${_cu_path}")
if echo "${_cu_exist}" | grep -q '"NOT_FOUND"'; then
  _r=$(_curl_post \
    "{\"clientUsername\":\"$(_je "${broker_user}")\",\"password\":\"$(_je "${broker_pass}")\",${_cu_profile_fields},\"msgVpnName\":\"$(_je "${broker_vpn}")\"}" \
    "msgVpns/$(_je "${broker_vpn}")/clientUsernames")
  if _has_semp_error "${_r}"; then
    _err "Client username '${broker_user}': create failed — $(_semp_error_msg "${_r}")"
  else
    _ok "Client username '${broker_user}': created"
    echo "      Profile: ${_profile}  ACL: ${_profile}  Enabled: true"
  fi
else
  _r=$(_curl_patch \
    "{\"password\":\"$(_je "${broker_pass}")\",${_cu_profile_fields}}" \
    "${_cu_path}")
  if _has_semp_error "${_r}"; then
    _err "Client username '${broker_user}': update failed — $(_semp_error_msg "${_r}")"
  else
    _ok "Client username '${broker_user}': already exists — password and profiles updated"
    echo "      Profile: ${_profile}  ACL: ${_profile}  Enabled: true"
  fi
fi

# ---- Done ----
echo ""
if [ ${_errors} -eq 0 ]; then
  echo "  Setup complete."
else
  printf "  Completed with %d error(s) — review messages above.\n" "${_errors}"
fi

exit ${_errors}
