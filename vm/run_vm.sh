#!/usr/bin/env bash
set -euo pipefail

VM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISK_IMG="${VM_DIR}/win10_wpinternals.qcow2"
ISO="${1:-}"

if [ -z "$ISO" ] && [ ! -f "${VM_DIR}/installed.flag" ]; then
    echo "Usage for initial installation: $0 <path-to-windows10.iso>"
    exit 1
fi

CDROM_ARG=""
if [ -n "$ISO" ] && [ -f "$ISO" ]; then
    CDROM_ARG="-cdrom ${ISO} -boot order=d"
fi

echo "Starting Windows 10 VM with Nokia & Qualcomm USB passthrough..."

exec qemu-system-x86_64 \
    -enable-kvm \
    -m 4096 \
    -smp 4 \
    -cpu host \
    -drive file="${DISK_IMG}",format=qcow2,if=virtio,aio=native,cache=none \
    ${CDROM_ARG} \
    -net nic,model=e1000 -net user \
    -device qemu-xhci,id=xhci \
    -device usb-host,bus=xhci.0,vendorid=0x0421 \
    -device usb-host,bus=xhci.0,vendorid=0x05c6 \
    -vga virtio \
    -display gtk,gl=on \
    -usb \
    -device usb-tablet
