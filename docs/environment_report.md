# Environment Report — Project Lumia Music
**Date:** 2026-10-29T17:00+05:30  
**Phase:** Zero — Environment and Device Discovery  
**Status:** COMPLETE

---

## 1. Host System

| Property | Value | Source |
|---|---|---|
| Hostname | `alfred` | `uname -n` |
| OS | Arch Linux (rolling) | `/etc/os-release` |
| Kernel | `7.2.4-arch1-2` SMP PREEMPT_DYNAMIC x86_64 | `uname -a` |
| RAM | 14 GiB total, ~10 GiB available | `free -h` |
| Swap | 4 GiB (unused) | `free -h` |
| Root partition (`/`) | 45G total, **42G used, 954M free (98%)** | `df -h /` |
| Home partition (`/home`) | 412G total, 36G used, **355G free (10%)** | `df -h /home` |

> [!WARNING]
> The root partition has **<1 GiB free**. Any build toolchain or large package installation targeting `/` will fail. All project data should be stored under `/home`.

## 2. Installed Tools

| Tool | Version | Path | Status |
|---|---|---|---|
| ADB | 1.0.41 (android-tools 37.0.0p1) | `/usr/bin/adb` | ✅ Installed |
| Fastboot | 37.0.0p1 | `/usr/bin/fastboot` | ✅ Installed |
| Python | 3.14.8 | system | ✅ Installed |
| Git | 2.56.0 | system | ✅ Installed |
| curl | 8.23.0 (OpenSSL 3.6.4) | system | ✅ Installed |
| wget | 1.25.0 | system | ✅ Installed |
| sha256sum | GNU coreutils 9.11 | system | ✅ Installed |
| usbutils | 019-1 | system | ✅ Installed |
| WPInternals | N/A | N/A | ❌ **Not available on Linux** |
| thor2 | N/A | N/A | ❌ Windows-only |
| WDRT | N/A | N/A | ❌ Windows-only |

## 3. Virtualization Capabilities

| Component | Status | Notes |
|---|---|---|
| KVM/QEMU | **Not checked** | Required for WPInternals Windows VM workaround |
| VirtualBox | **Not checked** | Alternative VM option |
| libvirt | **Not checked** | Needed for virt-manager |

> [!IMPORTANT]
> WPInternals — the only known tool for unlocking the Lumia bootloader — is a Windows-only application. Running it from Arch Linux requires either a Windows VM with USB passthrough or access to a physical Windows PC. **The user has stated no Windows PC is available**, so a VM is the only option.

## 4. USB Subsystem

The host USB subsystem is functional. Key devices detected via `lsusb`:
- `Bus 001 Device 004: ID 0421:0661 Nokia Mobile Phones Lumia 620/920` — **This is the target phone**
- Built-in webcam (IMC Networks)
- Bluetooth adapter (Foxconn/MediaTek)
- ITE input device

## 5. Disk Space Assessment for Project

| Activity | Estimated Space | Location | Feasible? |
|---|---|---|---|
| ROM downloads (~500MB–1GB) | ~1 GiB | `/home` | ✅ |
| FFU firmware backup (~1–2 GiB) | ~2 GiB | `/home` | ✅ |
| Android build from source | ~80–120 GiB | `/home` | ⚠️ Tight |
| Prebuilt ROM only | ~1 GiB | `/home` | ✅ |
| Windows VM (for WPInternals) | ~15–25 GiB | `/home` | ✅ |
| Scripts and documentation | <100 MiB | `/home` | ✅ |

## 6. Constraints Summary

1. **Root partition nearly full** — cannot install large packages to `/`
2. **No Windows PC available** — WPInternals must run in a VM
3. **VM infrastructure not yet verified** — KVM/QEMU needs checking
4. **ADB/Fastboot installed but irrelevant** for stock Windows Phone (no Android debug bridge on WP)
5. **Phone is connected and enumerated** via USB in MTP/PTP mode (not ADB/Fastboot mode)
