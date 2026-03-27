#!/bin/bash
# Lists available benchmarking tests and prompts the user to select one to run.
#
# Usage: ./start-benchmarking-test.sh

script_dir="${BASH_SOURCE%/*}"
test_dir="${script_dir}/benchmarking-tests"

# Collect test scripts (excluding archive/)
mapfile -t scripts < <(find "${test_dir}" -maxdepth 1 -name '*.sh' | sort)

if [ ${#scripts[@]} -eq 0 ]; then
  echo "No benchmarking tests found in ${test_dir}."
  exit 1
fi

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

selected="${scripts[$(( sel - 1 ))]}"

read -r -p "Broker IP or hostname: " broker
while [ -z "${broker}" ]; do
  echo "  This field is required."
  read -r -p "Broker IP or hostname: " broker
done

echo ""
echo "Running: $(basename "${selected}") against ${broker}"
echo ""

bash "${selected}" "${broker}"
