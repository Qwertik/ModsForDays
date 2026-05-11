#!/usr/bin/env bash
set -euo pipefail

# Build a server pack from packwiz metadata.
# Downloads mod jars via CurseForge API, copies configs and startup scripts,
# then zips everything into a ready-to-upload archive.
#
# Usage:
#   CF_API_KEY="$2a$10$..." ./build-server-pack.sh                              # version from pack.toml
#   CF_API_KEY="$2a$10$..." ./build-server-pack.sh v0.14.0                      # override version
#   CF_API_KEY="$2a$10$..." ./build-server-pack.sh v0.14.0 /path/to/client.zip  # fallback for restricted mods

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# --- Validate dependencies ---
for cmd in curl jq zip; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "ERROR: '$cmd' is required but not found." >&2
    exit 1
  fi
done

if [[ -z "${CF_API_KEY:-}" ]]; then
  echo "ERROR: CF_API_KEY environment variable is required." >&2
  echo "Get your key from https://console.curseforge.com/" >&2
  exit 1
fi

# --- Determine version and optional client zip fallback ---
if [[ -n "${1:-}" ]]; then
  VERSION="$1"
else
  VERSION="v$(grep '^version' pack.toml | head -1 | sed 's/version = "//;s/"//')"
fi
CLIENT_ZIP="${2:-}"
echo "Building server pack: Zephyr's Wake ${VERSION}"

# --- Clean previous build ---
BUILD_DIR="$SCRIPT_DIR/server-build"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/mods"

# --- Collect non-client mod file IDs ---
FILE_IDS=""
MOD_COUNT=0
SKIPPED=0

for f in mods/*.pw.toml; do
  SIDE=$(grep '^side' "$f" | head -1 | sed 's/side = "//;s/"//')
  if [[ "$SIDE" == "client" ]]; then
    SKIPPED=$((SKIPPED + 1))
    continue
  fi
  FILE_ID=$(grep 'file-id' "$f" | head -1 | sed 's/.*= //')
  [[ -n "$FILE_IDS" ]] && FILE_IDS="${FILE_IDS},"
  FILE_IDS="${FILE_IDS}${FILE_ID}"
  MOD_COUNT=$((MOD_COUNT + 1))
done

echo "Found ${MOD_COUNT} server/both mods (skipped ${SKIPPED} client-only)"

if [[ "$MOD_COUNT" -eq 0 ]]; then
  echo "ERROR: No mods to include in server pack." >&2
  exit 1
fi

# --- Batch-fetch download URLs from CurseForge API ---
echo "Fetching download URLs from CurseForge..."
CF_RESPONSE=$(mktemp)
trap 'rm -f "$CF_RESPONSE"' EXIT

HTTP_CODE=$(curl -s -w '%{http_code}' -o "$CF_RESPONSE" -X POST \
  -H "x-api-key: ${CF_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"fileIds\": [${FILE_IDS}]}" \
  "https://api.curseforge.com/v1/mods/files")

if [[ "$HTTP_CODE" != "200" ]]; then
  echo "ERROR: CurseForge API returned HTTP ${HTTP_CODE}" >&2
  cat "$CF_RESPONSE" >&2
  exit 1
fi

# --- Separate downloadable vs restricted mods ---
TOTAL=$(jq '.data | length' "$CF_RESPONSE")
BLOCKED_COUNT=$(jq '[.data[] | select(.downloadUrl == null)] | length' "$CF_RESPONSE")
DOWNLOADABLE=$((TOTAL - BLOCKED_COUNT))

# --- Download available jars in parallel ---
if [[ "$DOWNLOADABLE" -gt 0 ]]; then
  echo "Downloading ${DOWNLOADABLE} mod jars..."
  CURL_CONFIG=$(mktemp)
  trap 'rm -f "$CF_RESPONSE" "$CURL_CONFIG"' EXIT

  jq -r '.data[] | select(.downloadUrl != null) | "url = \"\(.downloadUrl)\"\noutput = \"'"$BUILD_DIR"'/mods/\(.fileName)\""' \
    "$CF_RESPONSE" > "$CURL_CONFIG"

  curl --parallel --parallel-max 8 -fL -K "$CURL_CONFIG"
fi

# --- Handle restricted mods via client zip fallback ---
if [[ "$BLOCKED_COUNT" -gt 0 ]]; then
  echo ""
  echo "${BLOCKED_COUNT} mod(s) have restricted distribution (downloadUrl: null):"
  jq -r '.data[] | select(.downloadUrl == null) | "  - \(.displayName) (\(.fileName))"' "$CF_RESPONSE"

  if [[ -z "$CLIENT_ZIP" ]]; then
    echo "" >&2
    echo "ERROR: No client zip provided to extract restricted mods from." >&2
    echo "Re-run with a client zip as the second argument:" >&2
    echo "  CF_API_KEY=... ./build-server-pack.sh ${VERSION} /path/to/client.zip" >&2
    exit 1
  fi

  if [[ ! -f "$CLIENT_ZIP" ]]; then
    echo "ERROR: Client zip not found: ${CLIENT_ZIP}" >&2
    exit 1
  fi

  echo "Extracting restricted mods from client zip: $(basename "$CLIENT_ZIP")"
  EXTRACTED=0
  while IFS= read -r FILENAME; do
    if unzip -j -o "$CLIENT_ZIP" "mods/$FILENAME" -d "$BUILD_DIR/mods/" &>/dev/null; then
      echo "  Extracted: $FILENAME"
      EXTRACTED=$((EXTRACTED + 1))
    else
      echo "  ERROR: '$FILENAME' not found in client zip" >&2
    fi
  done < <(jq -r '.data[] | select(.downloadUrl == null) | .fileName' "$CF_RESPONSE")

  if [[ "$EXTRACTED" -ne "$BLOCKED_COUNT" ]]; then
    echo "ERROR: Could not extract all restricted mods from client zip." >&2
    exit 1
  fi
fi

DOWNLOADED=$(ls -1 "$BUILD_DIR/mods/" | wc -l)
echo ""
echo "Total mods staged: ${DOWNLOADED}/${TOTAL}"

if [[ "$DOWNLOADED" -ne "$TOTAL" ]]; then
  echo "ERROR: Expected ${TOTAL} jars but only got ${DOWNLOADED}." >&2
  exit 1
fi

# --- Copy configs and data directories ---
for dir in config kubejs defaultconfigs; do
  if [[ -d "$dir" ]]; then
    cp -r "$dir" "$BUILD_DIR/"
    echo "Copied ${dir}/"
  fi
done

# --- Copy startup scripts ---
cp server-files/startserver.sh "$BUILD_DIR/"
cp server-files/startserver.bat "$BUILD_DIR/"
chmod +x "$BUILD_DIR/startserver.sh"
echo "Copied startup scripts"

# --- Create zip ---
OUTPUT_DIR="$SCRIPT_DIR/../server_builds"
mkdir -p "$OUTPUT_DIR"
ZIP_NAME="ZephyrsWake-${VERSION}-server.zip"
(cd "$BUILD_DIR" && zip -r "$OUTPUT_DIR/$ZIP_NAME" .)

echo ""
echo "Server pack built: ${OUTPUT_DIR}/${ZIP_NAME}"
echo "  Mods: ${DOWNLOADED}"
echo "  Size: $(du -h "$OUTPUT_DIR/$ZIP_NAME" | cut -f1)"
