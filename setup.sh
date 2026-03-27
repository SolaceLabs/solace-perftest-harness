#!/bin/bash
# Interactive setup wizard for the Solace Performance Test Harness.
# Explains infrastructure requirements, prompts for host names, populates
# config/host, and guides SSH key setup.

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
host_file="${script_dir}/config/host"
creds_file="${script_dir}/config/credentials.yaml"

# --- Helper ---
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

clear
cat <<'EOF'
============================================================
  Solace Performance Test Harness — Setup
============================================================

OVERVIEW
--------
This harness uses Ansible to deploy sdkperf_c to remote Linux
test hosts and drive publisher/consumer load against a Solace
broker. Before running any tests you need:

  1. A Solace broker (software or hardware appliance) to test
  2. Linux performance hosts with network access to the broker
  3. SSH key access from this controller to all test hosts
  4. The sdkperf_c binary placed in pubSubTools/ on this machine

PERFORMANCE HOSTS
-----------------
Minimum:  1 publisher host + 1 subscriber host (2 hosts total)
Ideal:    4 publisher hosts + 4 subscriber hosts (8 hosts total)

For accurate results, hosts should have:
  - Multiple CPU cores (4+ recommended; sdkperf uses one process
    per core by default)
  - Fast network interfaces (10 GbE strongly recommended)
  - Direct, low-latency connectivity to the broker under test
  - Linux OS with bash available

With a single publisher and single subscriber host you can still
characterise the broker, but throughput will be limited by what
one host can source or sink — typically ~1.2 GB/s on 10 GbE.
For small messages (100B–1KB) multiple hosts are needed to push
the broker toward its packet-rate limits.

Publisher hosts send messages; subscriber hosts receive them.
You can use the same host for both roles in a pinch, but this
shares CPU and NIC bandwidth between the two roles and will
produce lower and less representative results.

EOF

read -r -p "Press Enter to continue to host configuration..."
echo ""

# --- SSH key setup guidance ---
cat <<'EOF'
============================================================
  SSH KEY SETUP
============================================================

The harness connects to test hosts over SSH using Ansible.
Ansible requires password-free (key-based) SSH access from
this controller machine to every publisher and subscriber host.

Steps to set up SSH keys:

  1. Generate an SSH key pair on this controller (if you don't
     already have one):

       ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa

  2. Copy the public key to each test host:

       ssh-copy-id <ssh-user>@<pubhost1>
       ssh-copy-id <ssh-user>@<subhost1>
       (repeat for every host you configure below)

  3. Verify password-free login works:

       ssh <ssh-user>@<pubhost1> echo "OK"

  The SSH user must exist on all hosts and be the same user
  across all publisher and subscriber hosts. The default user
  is 'perfharness'; override it per-testset via the sshuser
  variable in your discovery or benchmarking script.

  The user needs read/write access to their home directory on
  each host (sdkperf_c and scripts are copied there by Ansible).

EOF

read -r -p "Press Enter to continue to host configuration..."
echo ""

# --- Host configuration ---
cat <<'EOF'
============================================================
  HOST CONFIGURATION
============================================================

You will now configure the publisher and subscriber hosts.
Enter hostnames or IP addresses. You can add up to 4 of each;
press Enter with no input to stop adding hosts for that group.

EOF

prompt sshuser "SSH user on test hosts" "perfharness"
echo ""

pub_hosts=()
sub_hosts=()

echo "--- Publisher hosts (send messages to the broker) ---"
for i in 1 2 3 4; do
  if [ $i -eq 1 ]; then
    read -r -p "  Publisher host ${i} (required): " h
    while [ -z "${h}" ]; do
      echo "  At least one publisher host is required."
      read -r -p "  Publisher host ${i} (required): " h
    done
  else
    read -r -p "  Publisher host ${i} (or Enter to stop): " h
  fi
  [ -z "${h}" ] && break
  pub_hosts+=("${h}")
done

echo ""
echo "--- Subscriber hosts (receive messages from the broker) ---"
for i in 1 2 3 4; do
  if [ $i -eq 1 ]; then
    read -r -p "  Subscriber host ${i} (required): " h
    while [ -z "${h}" ]; do
      echo "  At least one subscriber host is required."
      read -r -p "  Subscriber host ${i} (required): " h
    done
  else
    read -r -p "  Subscriber host ${i} (or Enter to stop): " h
  fi
  [ -z "${h}" ] && break
  sub_hosts+=("${h}")
done

# --- Broker credentials ---
cat <<'EOF'
============================================================
  BROKER CREDENTIALS
============================================================

Enter the credentials sdkperf will use to connect to the
broker. These are saved to config/credentials.yaml, which
is gitignored and will not be committed to the repository.

The client username must exist on the broker VPN and have:
  - Publish permission
  - Subscribe permission
  - Allow Guaranteed Endpoint Create (for persistent tests)

EOF

prompt broker_vpn      "Broker VPN name"       "perftest-harness"
prompt broker_username "Client username"        "perftestharness"
prompt broker_password "Client password"        "default"

# --- Write config/credentials.yaml ---
echo ""
echo "Writing ${creds_file}..."

cat > "${creds_file}" <<EOF
---
# Solace broker credentials for sdkperf
# This file is gitignored — do not commit it.

broker_vpn: ${broker_vpn}
broker_username: ${broker_username}
broker_password: ${broker_password}
sshuser: ${sshuser}
EOF

echo "  Done."
echo ""

# --- Write config/host ---
echo "Writing ${host_file}..."

{
  echo "########################################################"
  echo "# Ansible inventory for Solace performance test harness #"
  echo "########################################################"
  echo "[pubhost]"
  for h in "${pub_hosts[@]}"; do
    echo "${h}"
  done
  echo "[subhost]"
  for h in "${sub_hosts[@]}"; do
    echo "${h}"
  done
} > "${host_file}"

echo ""
echo "============================================================"
echo "  Setup complete"
echo "============================================================"
echo ""
echo "Publisher hosts:"
for h in "${pub_hosts[@]}"; do echo "  ${h}"; done
echo "Subscriber hosts:"
for h in "${sub_hosts[@]}"; do echo "  ${h}"; done
echo ""
echo "Broker VPN:  ${broker_vpn}"
echo "Username:    ${broker_username}"
echo "SSH user:    ${sshuser}"
echo ""

# --- Next steps ---
cat <<'EOF'
============================================================
  NEXT STEPS
============================================================

  1. Place the sdkperf_c binary (and LICENSES file) in:
       pubSubTools/

     Download sdkperf from the Solace developer portal:
       https://solace.com/downloads/

  2. Ensure SSH key access is set up for all configured hosts
     (see instructions above).

  3. Create a client username on your broker VPN with:
       - Publish permission
       - Subscribe permission
       - Allow Guaranteed Endpoint Create (for persistent tests)
     Credentials are stored in config/credentials.yaml and can
     be updated there at any time.

  4. Run a discovery test to find your broker's maximum throughput:
       ./start-generic-discovery-test.sh

     Or run a fixed-target benchmarking test:
       ./start-benchmarking-test.sh

EOF
