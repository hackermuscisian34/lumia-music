#!/usr/bin/env bash
# =============================================================================
# Project Lumia Music — Download Integrity Verifier
# Verifies ROM, firmware, and tool downloads against known checksums
# =============================================================================
set -euo pipefail

LOGDIR="/home/alfy/claude/lumia-music/logs"
MANIFEST_DIR="/home/alfy/claude/lumia-music/manifests"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOGFILE="${LOGDIR}/verify_downloads_${TIMESTAMP}.log"

mkdir -p "$LOGDIR" "$MANIFEST_DIR"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"; }

log "=== Project Lumia Music — Download Integrity Verifier ==="

# Safety check: never execute downloaded content
DOWNLOAD_DIR="${1:-}"
if [ -z "$DOWNLOAD_DIR" ]; then
    log "Usage: $0 <download-directory>"
    log "This script verifies file integrity. It does NOT download or execute anything."
    exit 1
fi

if [ ! -d "$DOWNLOAD_DIR" ]; then
    log "❌ Directory does not exist: $DOWNLOAD_DIR"
    exit 1
fi

MANIFEST_FILE="${MANIFEST_DIR}/verified_checksums.txt"

log ""
log "--- Computing SHA256 checksums for all files in: $DOWNLOAD_DIR ---"

find "$DOWNLOAD_DIR" -type f | sort | while IFS= read -r file; do
    HASH=$(sha256sum "$file" | awk '{print $1}')
    SIZE=$(stat --format=%s "$file")
    BASENAME=$(basename "$file")
    log "  ${BASENAME}: sha256=${HASH} size=${SIZE} bytes"
    echo "${HASH}  ${file}" >> "$MANIFEST_FILE"
done

log ""
log "--- Checking against known good checksums ---"

# NOTE: No checksums are fabricated. Only checksums obtained from
# official sources will be placed here. Currently, no official
# checksums have been independently obtained for Android4Lumia ROMs.
log "⚠️  No independently verified checksums are available yet."
log "    Official Android4Lumia project does not publish SHA256 checksums"
log "    for ROM builds on their download page."
log "    Checksums are recorded for future comparison only."

log ""
log "--- Device compatibility filename check ---"

# Check if any downloaded files match known naming patterns
FAME_PATTERN="fame|lumia.520|lumia.52"
OTHER_DEVICE_PATTERNS="idol3|citrus|hapanero|surya|mido"

find "$DOWNLOAD_DIR" -type f -name "*.zip" -o -name "*.img" -o -name "*.ffu" | while IFS= read -r file; do
    BASENAME=$(basename "$file" | tr '[:upper:]' '[:lower:]')
    
    if echo "$BASENAME" | grep -qiE "$FAME_PATTERN"; then
        log "✅ ${BASENAME} — matches Lumia 520 (fame) naming pattern"
    elif echo "$BASENAME" | grep -qiE "$OTHER_DEVICE_PATTERNS"; then
        log "❌ ${BASENAME} — appears to be for a DIFFERENT device! DO NOT FLASH!"
    else
        log "⚠️  ${BASENAME} — device target unclear. Verify manually before use."
    fi
done

log ""
log "--- Manifest saved to: ${MANIFEST_FILE} ---"
log "=== Verification complete ==="
