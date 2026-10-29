#!/usr/bin/env bash
# =============================================================================
# Project Lumia Music — Windows 10 VM Provisioner for WPInternals
# Configures a QEMU/KVM virtual machine with automated Nokia USB passthrough
# =============================================================================
set -euo pipefail

VM_DIR="/home/alfy/claude/lumia-music/vm"
DISK_IMG="${VM_DIR}/win10_wpinternals.qcow2"
DISK_SIZE="35G"
RAM_MB=4096
CPUS=4

mkdir -p "$VM_DIR"

echo "=== Windows 10 KVM Provisioner for WPInternals ==="

# Check KVM access
if [ ! -w /dev/kvm ]; then
    echo "⚠️ Warning: /dev/kvm is not writable by current user ($USER)."
    echo "You may need: sudo usermod -aG kvm $USER"
fi

# Create virtual disk if not existing
if [ ! -f "$DISK_IMG" ]; then
    echo "Creating sparse QCOW2 disk: ${DISK_IMG} (${DISK_SIZE})..."
    qemu-img create -f qcow2 "$DISK_IMG" "$DISK_SIZE"
else
    echo "Existing disk image found: ${DISK_IMG}"
fi

cat << 'EOF' > "${VM_DIR}/run_vm.sh"
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
EOF

chmod +x "${VM_DIR}/run_vm.sh"

echo "VM runner generated at: ${VM_DIR}/run_vm.sh"
echo "VM disk prepared at: ${DISK_IMG}"
