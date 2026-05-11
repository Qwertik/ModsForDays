#!/usr/bin/env bash
# Zephyr's Wake — NeoForge Server Bootstrap & Start Script
# Downloads the NeoForge installer, installs the server, accepts EULA, and starts.
# Usage: ./startserver.sh [MEMORY]
#   MEMORY defaults to MC_MEMORY env var, or 4G if unset.

set -euo pipefail

NEOFORGE_VERSION="21.1.228"
INSTALLER_URL="https://maven.neoforged.net/releases/net/neoforged/neoforge/${NEOFORGE_VERSION}/neoforge-${NEOFORGE_VERSION}-installer.jar"
INSTALLER_JAR="neoforge-${NEOFORGE_VERSION}-installer.jar"
ARGS_FILE="libraries/net/neoforged/neoforge/${NEOFORGE_VERSION}/unix_args.txt"

MEMORY="${1:-${MC_MEMORY:-4G}}"

# --- Install NeoForge if needed ---
if [ ! -f "${ARGS_FILE}" ]; then
    echo "NeoForge server not installed. Installing..."

    if [ ! -f "${INSTALLER_JAR}" ]; then
        echo "Downloading NeoForge ${NEOFORGE_VERSION} installer..."
        curl -fLO "${INSTALLER_URL}"
    fi

    echo "Running NeoForge installer..."
    java -jar "${INSTALLER_JAR}" --installServer
    echo "NeoForge installed successfully."
fi

# --- Accept EULA ---
if [ ! -f "eula.txt" ] || ! grep -q "eula=true" eula.txt 2>/dev/null; then
    echo "eula=true" > eula.txt
    echo "EULA accepted."
fi

# --- Start server ---
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
  @"${ARGS_FILE}" \
  nogui "$@"
