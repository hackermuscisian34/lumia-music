#!/usr/bin/env bash
# =============================================================================
# Project Lumia Music — Environment Validator
# Checks all prerequisites for the project
# =============================================================================
set -euo pipefail

LOGDIR="/home/alfy/claude/lumia-music/logs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOGFILE="${LOGDIR}/env_validate_${TIMESTAMP}.log"
PASS=0
FAIL=0
WARN=0

mkdir -p "$LOGDIR"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"; }
pass() { log "✅ PASS: $*"; PASS=$((PASS + 1)); }
fail() { log "❌ FAIL: $*"; FAIL=$((FAIL + 1)); }
warn() { log "⚠️  WARN: $*"; WARN=$((WARN + 1)); }

log "=== Project Lumia Music — Environment Validator ==="
log ""

# --- Required tools ---
log "--- Checking required tools ---"

for tool in adb fastboot lsusb python3 git curl wget sha256sum; do
    if command -v "$tool" &>/dev/null; then
        VER=$($tool --version 2>/dev/null | head -1 || echo "version unknown")
        pass "$tool found: $VER"
    else
        fail "$tool not found"
    fi
done

# --- Virtualization ---
log ""
log "--- Checking virtualization (required for WPInternals) ---"

if [ -e /dev/kvm ]; then
    pass "KVM available (/dev/kvm exists)"
else
    fail "KVM not available — cannot run Windows VM for WPInternals"
fi

if command -v qemu-system-x86_64 &>/dev/null; then
    pass "QEMU installed: $(qemu-system-x86_64 --version 2>/dev/null | head -1)"
else
    fail "QEMU not installed"
fi

if command -v virt-manager &>/dev/null; then
    pass "virt-manager installed"
else
    warn "virt-manager not installed (optional GUI for VM management)"
fi

if systemctl is-active libvirtd &>/dev/null; then
    pass "libvirtd is active"
else
    warn "libvirtd is not active"
fi

# --- Disk space ---
log ""
log "--- Checking disk space ---"

HOME_AVAIL=$(df --output=avail /home 2>/dev/null | tail -1 | tr -d ' ')
HOME_AVAIL_GB=$((HOME_AVAIL / 1024 / 1024))

if [ "$HOME_AVAIL_GB" -ge 50 ]; then
    pass "/home has ${HOME_AVAIL_GB} GiB free (>50 GiB needed for VM + ROMs)"
elif [ "$HOME_AVAIL_GB" -ge 20 ]; then
    warn "/home has ${HOME_AVAIL_GB} GiB free (tight for VM + builds)"
else
    fail "/home has only ${HOME_AVAIL_GB} GiB free (insufficient)"
fi

ROOT_AVAIL=$(df --output=avail / 2>/dev/null | tail -1 | tr -d ' ')
ROOT_AVAIL_MB=$((ROOT_AVAIL / 1024))
if [ "$ROOT_AVAIL_MB" -lt 1024 ]; then
    warn "Root partition has only ${ROOT_AVAIL_MB} MiB free — avoid installing packages to /"
fi

# --- USB device ---
log ""
log "--- Checking for Nokia Lumia USB device ---"

if lsusb 2>/dev/null | grep -q "0421:0661"; then
    pass "Nokia Lumia device detected on USB bus"
    PRODUCT=$(lsusb -v -d 0421:0661 2>/dev/null | grep "iProduct" | head -1 | sed 's/.*iProduct.*[0-9]  //')
    log "  Product: ${PRODUCT}"
else
    warn "Nokia Lumia not detected on USB — ensure phone is connected"
fi

# --- Summary ---
log ""
log "=========================================="
log "  PASS: ${PASS}  |  WARN: ${WARN}  |  FAIL: ${FAIL}"
log "=========================================="

if [ "$FAIL" -gt 0 ]; then
    log "❌ Environment has failures that must be resolved before proceeding"
    exit 1
elif [ "$WARN" -gt 0 ]; then
    log "⚠️  Environment is usable but has warnings to address"
    exit 0
else
    log "✅ Environment is fully ready"
    exit 0
fi
