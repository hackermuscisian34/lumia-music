# Device Inventory — Nokia Lumia 520
**Date:** 2026-10-29T17:00+05:30  
**Phase:** Zero — Environment and Device Discovery  
**Status:** COMPLETE

---

## 1. Verified Device Identity (from USB enumeration)

| Property | Value | Source |
|---|---|---|
| USB Vendor ID | `0x0421` (Nokia Mobile Phones) | `lsusb -v` |
| USB Product ID | `0x0661` | `lsusb -v` |
| iManufacturer | **Nokia** | USB descriptor string |
| iProduct | **Nokia Lumia 520 (RM-914)** | USB descriptor string |
| iSerial | `00000015BC8066090000000000000000` | USB descriptor string |
| USB Speed | High Speed (480 Mbps) | USB negotiation |
| Bus/Device | Bus 001 Device 004 | `lsusb` |
| Power | Bus Powered, MaxPower 100mA | USB descriptor |
| bcdUSB | 2.00 | USB descriptor |

## 2. USB Interface Analysis

The phone exposes **4 interfaces** in its current mode:

| Interface | Class | Description | Significance |
|---|---|---|---|
| 0 | **Imaging (6/1/1)** | Still Image Capture / PTP (PIMA 15470) | MTP/PTP file transfer mode |
| 1 | Vendor Specific (255/255/255) | Nokia proprietary | Possibly care suite / diagnostics |
| 2 | Vendor Specific (255/255/255) | Nokia proprietary | Possibly care suite / diagnostics |
| 3 | Vendor Specific (255/255/255) | Nokia proprietary | Possibly care suite / diagnostics |

> [!NOTE]
> The phone is in **normal boot mode**, presenting MTP/PTP + Nokia vendor interfaces. It does **NOT** expose ADB or Fastboot interfaces. This is expected — Windows Phone does not support Android Debug Bridge.

## 3. Known Hardware Specifications (from documentation)

| Component | Specification | Source |
|---|---|---|
| SoC | Qualcomm Snapdragon S4 Plus (MSM8227) | Nokia official spec |
| CPU | Dual-core Krait 1.0 GHz (ARMv7) | Nokia official spec |
| GPU | Adreno 305 | Nokia official spec |
| RAM | **512 MiB** | Nokia official spec |
| Storage | 8 GiB internal eMMC | Nokia official spec |
| Display | 4.0" IPS LCD, 480 × 800 pixels | Nokia official spec |
| Touch | Capacitive multitouch | Nokia official spec |
| Wi-Fi | 802.11 b/g/n (2.4 GHz) | Nokia official spec |
| Bluetooth | 4.0 LE | Nokia official spec |
| Audio | 3.5mm headphone jack | Nokia official spec |
| Camera | 5 MP rear (no front camera on most variants) | Nokia official spec |
| Battery | BL-5J, 1430 mAh, removable | Nokia official spec |
| SIM | Micro-SIM | Nokia official spec |
| USB | Micro-USB 2.0 | Nokia official spec |

## 4. Unverified / Unknown Properties

| Property | Status | How to Determine | Risk Level |
|---|---|---|---|
| **eMMC manufacturer** | ❓ UNKNOWN | Requires WPInternals or hardware disassembly | 🔴 **CRITICAL** — Samsung eMMC chips are known to brick permanently |
| Product code / firmware variant | ❓ UNKNOWN | Readable via WPInternals or phone Settings > About | 🟡 Medium — needed for correct FFU matching |
| Current firmware version | ❓ UNKNOWN | Phone Settings > About | 🟡 Medium |
| Bootloader lock state | ❓ Presumed LOCKED | Default state for all retail Lumia units | 🟡 Expected |
| Secure Boot state | ❓ Presumed ENABLED | Default state | 🟡 Expected |

> [!CAUTION]
> **The eMMC manufacturer is the single most critical unknown.** If this device has a Samsung eMMC chip, the entire flashing process carries a significant risk of permanent, unrecoverable brick. This MUST be determined before any destructive operation.

## 5. Device Communication Capabilities from Arch Linux

| Protocol | Available? | Notes |
|---|---|---|
| ADB | ❌ No | Windows Phone does not support ADB |
| Fastboot | ❌ No | Not available in current mode |
| MTP/PTP | ✅ Yes | File transfer possible |
| Nokia vendor USB | ⚠️ Partial | Vendor interfaces present but no Linux tooling exists |
| Mass Storage | ❌ Not yet | Requires bootloader unlock via WPInternals first |
| Qualcomm 9008 | ❌ Not yet | Emergency download mode, needs special entry |
