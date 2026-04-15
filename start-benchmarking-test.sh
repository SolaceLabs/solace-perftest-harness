#!/bin/bash
# Lists available benchmarking tests and prompts the user to select one to run.
#
# Usage:
#   ./start-benchmarking-test.sh                     # fully interactive
#   ./start-benchmarking-test.sh <test>              # prompts for broker only
#   ./start-benchmarking-test.sh <test> <broker>     # fully non-interactive
#
# <test> can be a test name (e.g. ent-1k-quick) or menu number (e.g. 14)

script_dir="${BASH_SOURCE%/*}"
test_dir="${script_dir}/benchmarking-tests"

# Collect test scripts
mapfile -t scripts < <(find "${test_dir}" -maxdepth 1 -name '*.sh' | sort)

if [ ${#scripts[@]} -eq 0 ]; then
  echo "No benchmarking tests found in ${test_dir}."
  exit 1
fi

# Resolve test selection
if [ -n "$1" ]; then
  arg="$1"
  if [[ "${arg}" =~ ^[0-9]+$ ]]; then
    if [ "${arg}" -ge 1 ] && [ "${arg}" -le "${#scripts[@]}" ]; then
      sel="${arg}"
    else
      echo "Error: test number ${arg} is out of range (1-${#scripts[@]})."
      exit 1
    fi
  else
    name="${arg%.sh}"
    sel=""
    for i in "${!scripts[@]}"; do
      if [ "$(basename "${scripts[$i]}" .sh)" = "${name}" ]; then
        sel=$(( i + 1 ))
        break
      fi
    done
    if [ -z "${sel}" ]; then
      echo "Error: no test named '${name}' found."
      echo "Available tests:"
      for i in "${!scripts[@]}"; do
        printf "  %2d) %s\n" $(( i + 1 )) "$(basename "${scripts[$i]}" .sh)"
      done
      exit 1
    fi
  fi
else
  echo "============================================================"
  echo " Available benchmarking tests"
  echo "============================================================"
  for i in "${!scripts[@]}"; do
    printf "  %2d) %s\n" $(( i + 1 )) "$(basename "${scripts[$i]}" .sh)"
  done
  echo ""
  while true; do
    read -r -p "Select a test [1-${#scripts[@]}]: " sel
    if [[ "${sel}" =~ ^[0-9]+$ ]] && [ "${sel}" -ge 1 ] && [ "${sel}" -le "${#scripts[@]}" ]; then
      break
    fi
    echo "  Please enter a number between 1 and ${#scripts[@]}."
  done
fi

selected="${scripts[$(( sel - 1 ))]}"

# Resolve broker
if [ -n "$2" ]; then
  broker="$2"
else
  read -r -p "Broker IP or hostname: " broker
  while [ -z "${broker}" ]; do
    echo "  This field is required."
    read -r -p "Broker IP or hostname: " broker
  done
fi

echo ""
echo "Running: $(basename "${selected}") against ${broker}"
echo ""

bash "${selected}" "${broker}"
