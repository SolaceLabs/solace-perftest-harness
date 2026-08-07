#!/bin/bash
# Performance test script to spin up a couple of consumers to be used with sdkpublishers.sh
# The script takes the following arguments:
# ./${name}.sh <timeout> <number_of_clients> <topic> <fanout> <add_args>
# with timeout            = the time in seconds for how long to run the test
#      number_of_clients  = how many client processes to run (should match your publishers)
#      topic              = the base topic prefix to subscribe to
#      fanout             = the number of consumers on each topic
#      add_args           = any additional arguments to pass to sdkperf
# 
#Adjust the following according to your needs and infrastructure
#number of cores to distribute your processes across - used by taskset to pin consumers to cores.
#Should match the number of cores on the perf host running the consumers.
no_cores=${NO_CORES:-4}
core_offset=1

#set cleanup to false, if you need to debug something and look at the output
cleanup_at_end="true"

#use permanent queues or temporary topic endpoints
endpoints="queues"
#endpoints="topicendpoint"

#Change the following constants only,if you really have to
name=sdkconsumers

# Protocol-aware binary and session properties
sdkperf_bin="${SDKPERF_BINARY:-sdkperf_c}"

# SMF-only session properties (connect/reconnect, acknowledgement window)
if [ "${PROTOCOL:-smf}" = "smf" ]; then
  epl="SOLCLIENT_SESSION_PROP_CONNECT_TIMEOUT_MS,500,\
SOLCLIENT_SESSION_PROP_CONNECT_RETRIES,-1,\
SOLCLIENT_SESSION_PROP_RECONNECT_RETRIES,-1,\
SOLCLIENT_SESSION_PROP_RECONNECT_RETRY_WAIT_MS,200,\
SOLCLIENT_SESSION_PROP_CONNECT_RETRIES_PER_HOST,1"
  rc=100
  asw_flag="-asw=255"
  nagle_flag="-nagle"
else
  epl=""
  rc=""
  asw_flag=""
  nagle_flag=""
fi

#Trap control-c to graciously shut down the clients and give chance to collect stats...
trap 'killallp' INT

killallp() {
    trap '' INT TERM     # ignore INT and TERM while shutting down
    echo " "
    echo "**** Shutting down... ****"
    # Java-based tools (mqtt/amqp) spawn a 'java' process; kill that.
    # SMF (sdkperf_c) is a native binary; kill by binary name.
    if [ "${PROTOCOL:-smf}" = "smf" ]; then
      killall -2 "${sdkperf_bin}"  2>/dev/null
      sleep 3
      killall -15 "${sdkperf_bin}" 2>/dev/null
      sleep 3
      killall -9 "${sdkperf_bin}"  2>/dev/null
    else
      killall -2 java  2>/dev/null
      sleep 3
      killall -15 java 2>/dev/null
      sleep 3
      killall -9 java  2>/dev/null
    fi
    wait
    wait
}

#wait for background processes to finish
waitall() {
  while [ $# -gt 0 ]; do
    wait $1 2>/dev/null
    shift
  done
}

#remove temporary files
cleanup() {
  rm -f result.txt
  rm -f ${name}_stats2.txt
  rm -f ${name}_stats3.txt

  rm -f result_sub.txt
  rm -f ${name}_stats_*.txt
  rm -f ${name}_stats-r1.txt
  rm -f ${name}_stats-r2.txt
}

#####################
####### main ########
#####################
#check dependencies
for _dep in taskset killall; do
  if ! command -v "${_dep}" &>/dev/null; then
    echo "Error: ${_dep} not found in PATH. Please install it."
    exit 1
  fi
done
unset _dep

#check input arguments
if [ $# -eq 0 ]; then
  echo "usage: ./${name}.sh <timeout> <number_of_clients> <topic> <fanout> <add_args>"
  exit 1
fi
if ! [ $1 -eq $1 2>/dev/null ]; then
  echo " number_of_clients needs to be an integer"
  exit 1
fi
timeout=$1
number_of_clients=$2
topic=$3
fanout=$4
add_args=${@:5}
# Disable TLS certificate validation for SMF test environments using tcps://
if [ "${PROTOCOL:-smf}" = "smf" ] && echo "${add_args}" | grep -q "tcps://"; then
  epl="${epl},SOLCLIENT_SESSION_PROP_SSL_VALIDATE_CERTIFICATE,0"
fi
unset pids
cleanup

echo "Starting ${number_of_clients} clients... (fanout: ${fanout})"
#j controls the core the task will be pinned to
j=$core_offset
last_core=$(expr ${core_offset} + ${no_cores})
for i in `seq 1 ${number_of_clients}`; do
  if [[ $j -gt ${last_core} ]]; then
    #if j gets greater than the cores available, restart at core_offset
    j=${core_offset}
  fi
  #cores are actually numbered starting from 0, so use c for core number
  c=$((${j}-1))
  for ((f=1; f<=${fanout}; f++)); do
    echo "fanout:${f}/${fanout}"
    if [ "${PROTOCOL:-smf}" = "smf" ] && [[ ${add_args} == *"persistent"* ]]; then
      if [[ "${endpoints}" = "queues" ]]; then
        taskset -c ${c} ./${sdkperf_bin} ${asw_flag} -epl=${epl} -rc=${rc} -stl=${topic}_${i} -pe -sql=${topic}_${i}_${f} -pea=0 ${nagle_flag} ${add_args} &> ${name}_stats_${i}_${f}.txt &
      else
        taskset -c ${c} ./${sdkperf_bin} ${asw_flag} -epl=${epl} -rc=${rc} -stl=${topic}_${i} -pe -tte=1 -pea=0 ${nagle_flag} ${add_args} &> ${name}_stats_${i}_${f}.txt &
      fi
      echo
    else
      taskset -c ${c} ./${sdkperf_bin} ${asw_flag} ${epl:+-epl=${epl}} ${rc:+-rc=${rc}} -stl=${topic}_${i} ${nagle_flag} ${add_args} &> ${name}_stats_${i}_${f}.txt &
    fi
    pid=$!
    pids="${pids} ${pid}"
  done
  j=$((${j}+1))
done
echo "Running..."
#echo "Pids: ${pids}"
echo "[Press Ctrl+C or wait ${timeout}s to end...]"

sleep ${timeout}

killallp
#wait for last process to finish
waitall $pids
sleep 2
echo "Done, gathering stats...!"
echo " "
if grep -qE "Computed receive|Computed subscriber" ${name}_stats_*.txt; then
  echo "Computing results"
  cat ${name}_stats_*.txt | grep -E "Computed receive|Computed subscriber" > ${name}_stats-r1.txt
  awk 'BEGIN { FS= " " } ; { print $NF }' ${name}_stats-r1.txt > ${name}_stats-r2.txt
  sum=`cat ${name}_stats-r2.txt | awk '{ sum += $1; } END { print sum; }'`
  echo "Sum across consumers: ${sum} (msg/sec)" | tee result_sub.txt
  if grep -q 'Exception\|Error' ${name}_stats_*.txt; then
    echo "Warnings (non-fatal errors in sdkperf output, rate was still computed):"
    cat ${name}_stats_*.txt | grep 'Exception\|Error'
  fi
else
  echo "Errors occured during run:" | tee result_sub.txt
  cat ${name}_stats_*.txt | grep 'Exception\|Error' | tee -a result_sub.txt
fi
if [[ "${cleanup_at_end}" = "true" ]]; then
  cleanup
fi
