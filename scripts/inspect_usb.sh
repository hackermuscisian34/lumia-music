#!/usr/bin/env bash
# =============================================================================
# Project Lumia Music — USB Device Inspector
# Safe, read-only USB enumeration and device identification
# =============================================================================
set -euo pipefail

LOGDIR="/home/alfy/claude/lumia-music/logs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOGFILE="${LOGDIR}/usb_inspect_${TIMESTAMP}.log"

mkdir -p "$LOGDIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"
}

log "=== Project Lumia Music — USB Device Inspector ==="
log "Host: $(uname -n) | Kernel: $(uname -r)"
log ""

# Nokia USB IDs
NOKIA_VID="0421"
NOKIA_PID_NORMAL="0661"
NOKIA_PID_FLASH="0661"  # May differ in flash mode
QUALCOMM_VID="05c6"
QUALCOMM_PID_9008="9008"

log "--- Checking for Nokia/Lumia USB devices ---"
NOKIA_FOUND=false

while IFS= read -r line; do
    if echo "$line" | grep -qi "nokia\|lumia\|${NOKIA_VID}"; then
        log "FOUND: $line"
        NOKIA_FOUND=true
    fi
done < <(lsusb 2>/dev/null)

# Check for Qualcomm emergency mode
while IFS= read -r line; do
    if echo "$line" | grep -qi "${QUALCOMM_VID}:${QUALCOMM_PID_9008}"; then
        log "⚠️  QUALCOMM 9008 EMERGENCY MODE DETECTED: $line"
        log "The phone may be in emergency download mode!"
        NOKIA_FOUND=true
    fi
done < <(lsusb 2>/dev/null)

if [ "$NOKIA_FOUND" = false ]; then
    log "❌ No Nokia/Lumia device found on USB bus."
    log "   Ensure the phone is connected and powered on."
    exit 1
fi

log ""
log "--- Detailed USB descriptor ---"
lsusb -v -d "${NOKIA_VID}:" 2>/dev/null >> "$LOGFILE" 2>&1 || true

log ""
log "--- USB device mode analysis ---"

# Determine phone mode from USB interfaces
if lsusb -v -d "${NOKIA_VID}:" 2>/dev/null | grep -q "Still Image Capture"; then
    log "📱 Phone appears to be in NORMAL MODE (MTP/PTP)"
    log "   This is expected for stock Windows Phone"
    log "   ADB and Fastboot are NOT available in this mode"
fi

if lsusb -v -d "${NOKIA_VID}:" 2>/dev/null | grep -q "iProduct.*RM-914"; then
    log "✅ Device confirmed as RM-914 variant"
fi

# Extract serial number
SERIAL=$(lsusb -v -d "${NOKIA_VID}:" 2>/dev/null | grep "iSerial" | awk '{print $3}' | head -1)
if [ -n "$SERIAL" ]; then
    log "🔑 Device serial: ${SERIAL}"
fi

log ""
log "--- ADB/Fastboot status (expected: no devices) ---"
ADB_OUT=$(adb devices -l 2>/dev/null || echo "adb failed")
FASTBOOT_OUT=$(fastboot devices 2>/dev/null || echo "fastboot failed")
log "ADB devices: ${ADB_OUT}"
log "Fastboot devices: ${FASTBOOT_OUT}"

if echo "$ADB_OUT" | grep -q "device$\|recovery$"; then
    log "✅ ADB device detected! (Unexpected for stock Windows Phone)"
elif echo "$FASTBOOT_OUT" | grep -q "fastboot"; then
    log "✅ Fastboot device detected! (Phone may be in bootloader mode)"
else
    log "ℹ️  No ADB or Fastboot device — normal for stock Windows Phone"
fi

log ""
log "--- Full lsusb listing ---"
lsusb 2>/dev/null >> "$LOGFILE"

log ""
log "=== Inspection complete. Log saved to: ${LOGFILE} ==="
echo "Log: ${LOGFILE}"
