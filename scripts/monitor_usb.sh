#!/usr/bin/env bash
# =============================================================================
# Project Lumia Music — Real-time USB State & Mode Monitor
# Watches for Nokia Lumia USB mode transitions:
# - Normal Boot (MTP/PTP): 0421:0661
# - Flash Mode / SimpleIO: 0421:0660 or 0421:066e
# - Qualcomm Emergency Download (EDL): 05c6:9008
# - Qualcomm Diagnostic: 05c6:900e
# - Android ADB / Fastboot: 18d1:* / 0421:*
# =============================================================================
set -euo pipefail

LOGDIR="/home/alfy/claude/lumia-music/logs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOGFILE="${LOGDIR}/usb_monitor_${TIMESTAMP}.log"
mkdir -p "$LOGDIR"

echo "=== Nokia Lumia USB State Monitor ==="
echo "Logging events to: ${LOGFILE}"
echo "Press Ctrl+C to stop monitoring."
echo "----------------------------------------"

LAST_STATE=""

log_state() {
    local msg="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ${msg}" | tee -a "$LOGFILE"
}

check_device() {
    # Check for Nokia Vendor ID 0421
    if lsusb 2>/dev/null | grep -q "0421:0661"; then
        echo "NORMAL_MTP"
    elif lsusb 2>/dev/null | grep -qE "0421:0660|0421:066e"; then
        echo "FLASH_MODE"
    elif lsusb 2>/dev/null | grep -q "05c6:9008"; then
        echo "QUALCOMM_EDL_9008"
    elif lsusb 2>/dev/null | grep -q "05c6:900e"; then
        echo "QUALCOMM_DIAG_900e"
    elif lsusb 2>/dev/null | grep -qE "18d1:4ee7|0421:0662"; then
        echo "ANDROID_ADB"
    elif lsusb 2>/dev/null | grep -qE "18d1:d00d|0421:0663"; then
        echo "ANDROID_FASTBOOT"
    elif lsusb 2>/dev/null | grep -q "0421:"; then
        local raw
        raw=$(lsusb 2>/dev/null | grep "0421:" | head -1)
        echo "NOKIA_UNKNOWN (${raw})"
    elif lsusb 2>/dev/null | grep -q "05c6:"; then
        local raw
        raw=$(lsusb 2>/dev/null | grep "05c6:" | head -1)
        echo "QUALCOMM_OTHER (${raw})"
    else
        echo "DISCONNECTED"
    fi
}

# Initial state check
CURRENT=$(check_device)
LAST_STATE="$CURRENT"
log_state "Initial detected state: ${CURRENT}"

# Monitor loop
while true; do
    CURRENT=$(check_device)
    if [ "$CURRENT" != "$LAST_STATE" ]; then
        log_state "STATE TRANSITION: [${LAST_STATE}] ---> [${CURRENT}]"
        
        # Display context on transition
        case "$CURRENT" in
            "NORMAL_MTP")
                log_state "  -> Phone booted normally into Windows Phone (MTP/PTP mode)."
                ;;
            "FLASH_MODE")
                log_state "  -> Phone entered Flash Mode (SimpleIO / Bootloader). Ready for WPInternals / Thor2."
                ;;
            "QUALCOMM_EDL_9008")
                log_state "  -> ALERT: Phone in Emergency Download Mode (Qualcomm 9008 / Sahara)."
                ;;
            "ANDROID_ADB")
                log_state "  -> Phone running Android with ADB enabled."
                ;;
            "ANDROID_FASTBOOT")
                log_state "  -> Phone running Fastboot bootloader."
                ;;
            "DISCONNECTED")
                log_state "  -> Device disconnected from USB bus."
                ;;
        esac
        
        LAST_STATE="$CURRENT"
    fi
    sleep 1
done
