#!/bin/bash

SERVER_JAR=${SERVER_JAR:-"server.jar"}
STOP_COMMAND=${STOP_COMMAND:-"stop"}
MIN_MEMORY=${MIN_MEMORY:-"2G"}
MAX_MEMORY=${MAX_MEMORY:-"4G"}
JAVA_ARGS=${JAVA_ARGS:-"-XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+AlwaysActAsServerClassMachine -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+UseNUMA -XX:AllocatePrefetchStyle=3 -XX:NmethodSweepActivity=1 -XX:ReservedCodeCacheSize=400M -XX:NonNMethodCodeHeapSize=12M -XX:ProfiledCodeHeapSize=194M -XX:NonProfiledCodeHeapSize=194M -XX:-DontCompileHugeMethods -XX:+PerfDisableSharedMem -XX:+UseFastUnorderedTimeStamps -XX:+UseCriticalJavaThreadPriority -XX:+EagerJVMCI -Dgraal.TuneInlinerExploration=1 -Dgraal.CompilerConfiguration=enterprise -XX:+UseG1GC -XX:MaxGCPauseMillis=130 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=28 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=20 -XX:G1MixedGCCountTarget=3 -XX:InitiatingHeapOccupancyPercent=10 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=0 -XX:SurvivorRatio=32 -XX:MaxTenuringThreshold=1 -XX:G1SATBBufferEnqueueingThresholdPercent=30 -XX:G1ConcMarkStepDurationMillis=5"}

INPUT_PIPE="/tmp/minecraft-input.pipe"

cd /data

terminate() {
  echo "Caught SIGTERM signal. Stopping server..."
  echo "$STOP_COMMAND" >> $INPUT_PIPE
}
trap terminate SIGTERM

# auto accept eula
echo "eula=true" > eula.txt

# create a named pipe to use as the servers stdin
rm $INPUT_PIPE 2> /dev/null
mkfifo $INPUT_PIPE

if [ -n "$START_SCRIPT" ]; then
  if [ ! -e "$START_SCRIPT" ]; then
    echo "Start script not found!"
    exit 1
  fi
  
  echo "Running start script $START_SCRIPT"
  "/./data/$START_SCRIPT" < $INPUT_PIPE &
else
  if [ ! -e "$SERVER_JAR" ]; then
    echo "$SERVER_JAR not found!"
    echo "Place your server jar into data/ and change the SERVER_JAR environment variable accordingly."
    exit 1
  fi

  echo "Running java -Xmx$MAX_MEMORY -Xms$MIN_MEMORY $JAVA_ARGS -jar $SERVER_JAR nogui"
  java -Xmx$MAX_MEMORY -Xms$MIN_MEMORY $JAVA_ARGS -jar $SERVER_JAR nogui < $INPUT_PIPE &
fi

# remember the pid of the server
server=$!

# redirect stdin to server
cat <&0 > $INPUT_PIPE &

# wait two times here
# the first wait will get interrupted by SIGTERM and the trap will execute
# the second wait waits for the server to actually stop
# in the case of the server stopping on its own, both calls to wait will just terminate immediately
wait $server
wait $server
