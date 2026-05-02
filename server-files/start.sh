#!/usr/bin/env bash
# Zephyr's Wake — NeoForge Server Startup Script
# Usage: ./start.sh [MEMORY]
#   MEMORY defaults to 4G if not set

set -euo pipefail

MEMORY="${1:-${MC_MEMORY:-4G}}"
NEOFORGE_ARGS="@libraries/net/neoforged/neoforge/21.1.228/unix_args.txt"

echo "Starting Zephyr's Wake server with ${MEMORY} memory..."

java \
  -Xms"${MEMORY}" -Xmx"${MEMORY}" \
  -XX:+UseG1GC \
  -XX:+ParallelRefProcEnabled \
  -XX:MaxGCPauseMillis=200 \
  -XX:+UnlockExperimentalVMOptions \
  -XX:+DisableExplicitGC \
  -XX:G1NewSizePercent=30 \
  -XX:G1MaxNewSizePercent=40 \
  -XX:G1HeapRegionSize=8M \
  -XX:G1ReservePercent=20 \
  -XX:G1HeapWastePercent=5 \
  -XX:G1MixedGCCountTarget=4 \
  -XX:InitiatingHeapOccupancyPercent=15 \
  -XX:G1MixedGCLiveThresholdPercent=90 \
  -XX:G1RSetUpdatingPauseTimePercent=5 \
  -XX:SurvivorRatio=32 \
  -XX:+PerfDisableSharedMem \
  -XX:MaxTenuringThreshold=1 \
  -Dusing.aikars.flags=https://mcflags.emc.gs \
  -Daikars.new.flags=true \
  "${NEOFORGE_ARGS}" \
  nogui "$@"
