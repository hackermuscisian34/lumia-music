# Risks and Unknowns Register — Project Lumia Music
**Date:** 2026-10-29T17:00+05:30  
**Phase:** Zero — Environment and Device Discovery  
**Status:** COMPLETE

---

## 1. CRITICAL RISKS (Project-Threatening)

### RISK-001: Samsung eMMC Permanent Brick
- **Category:** Hardware
- **Status:** ⏳ UNMITIGATED — eMMC manufacturer unknown
- **Description:** Nokia Lumia 520 devices exist with Samsung eMMC flash chips that are known to permanently lock into read-only mode or brick entirely when alternative bootloaders or operating systems are flashed. This is an irreversible hardware failure.
- **Probability:** Medium (many Lumia 520 units have Samsung chips, but not all)
- **Impact:** Total device loss — no recovery possible
- **Mitigation:** Identify eMMC manufacturer BEFORE any destructive operation. Methods:
  1. Use WPInternals (requires Windows VM) to read eMMC CID register
  2. Check phone Settings > About for hardware revision clues
  3. Physical disassembly and visual inspection of the chip marking
  4. If Samsung eMMC is confirmed: **ABORT the project entirely**
- **Decision gate:** Phase One — before bootloader unlock

### RISK-002: Wired Audio (3.5mm Jack) Non-Functional
- **Category:** Hardware/Software compatibility
- **Status:** 🔴 CONFIRMED BLOCKER (partial)
- **Description:** The 3.5mm headphone jack does not function under Android4Lumia LineageOS 14.1. Audio routing drivers for the Qualcomm audio codec on this device were never fully reverse-engineered for Android.
- **Impact:** The user's specification explicitly requires "3.5 mm wired headphones" support. This requirement **cannot be met** with the available ROM.
- **Mitigation:** 
  - Bluetooth audio (A2DP) is reported working and can serve as the primary audio output
  - User must accept Bluetooth-only audio or declare this a NO-GO condition
- **Decision gate:** User acceptance required

### RISK-003: Insufficient RAM for Spotify
- **Category:** Hardware constraint
- **Status:** ⚠️ HIGH RISK — unverified
- **Description:** The Lumia 520 has only 512 MiB RAM. Android 7.1.1 system services, Google Play Services (required for Spotify authentication), and the Spotify app itself typically consume 600–1200 MiB combined. The phone may be unable to keep Spotify running.
- **Probability:** High
- **Impact:** Primary objective failure — Spotify may crash, fail to stream, or be unable to authenticate
- **Mitigation:**
  - Aggressive system debloating
  - Use microG instead of full Google Play Services
  - Create a swap file/partition
  - Use a minimal launcher
  - Test with Spotify Lite (if still available and compatible)
- **Decision gate:** Phase Three — can only be verified by actual device testing after ROM installation

---

## 2. HIGH RISKS

### RISK-004: WPInternals Requires Windows — No Windows PC Available
- **Category:** Tooling
- **Status:** ⚠️ Workaround identified
- **Description:** The bootloader unlock process exclusively requires WPInternals, a Windows-only .NET application. The user has no Windows PC.
- **Mitigation:** Run WPInternals inside a QEMU/KVM Windows VM on Arch Linux with USB passthrough. This is a documented and tested approach in the community.
- **Prerequisites:**
  1. Verify KVM/QEMU is available or installable
  2. Obtain a Windows 10/11 evaluation ISO
  3. Configure USB host passthrough for the Nokia device
  4. Install WDRT inside the VM for USB drivers
- **Residual risk:** USB passthrough can be flaky; phone may need to be re-detected across multiple boot modes

### RISK-005: Stock Firmware Recovery Dependency on Windows
- **Category:** Recovery
- **Status:** ⚠️ Same as RISK-004
- **Description:** If the phone becomes unbootable or needs to revert to Windows Phone, the recovery process (flashing FFU firmware) requires Windows-based tools (WDRT, thor2, or WPInternals).
- **Mitigation:** Same VM approach. Additionally, download and verify the correct stock FFU firmware for RM-914 BEFORE making any changes.
- **Open question:** Is the exact product code and matching FFU available for this specific device?

### RISK-006: Google Play Services Compatibility and Resource Impact
- **Category:** Software
- **Status:** ⚠️ Uncertain
- **Description:** Spotify requires Google Play Services for authentication and possibly DRM. On 512MB RAM, full GApps is impractical. Micro/Pico/Nano GApps variants may or may not provide enough framework support.
- **Mitigation:** Test with Pico GApps first. If that fails, try microG (open-source Play Services reimplementation). If neither works, Spotify authentication will fail.

---

## 3. MEDIUM RISKS

### RISK-007: ROM Download Integrity
- **Category:** Security
- **Status:** ⚠️ Checksums not yet located
- **Description:** The Android4Lumia project distributes ROM builds through its website and potentially third-party hosting. Official checksums for ROM builds have not been located.
- **Mitigation:** Verify downloads against any checksums published on the official website or Telegram channel. If no checksums exist, document the gap and rely on HTTPS download + manual comparison.

### RISK-008: Boot Loop or Soft-Brick During Initial Flash
- **Category:** Operational
- **Probability:** Medium
- **Impact:** Phone stuck in non-booting state requiring recovery via Windows tools
- **Mitigation:** Ensure recovery infrastructure (Windows VM + FFU backup) is fully operational before attempting any flash

### RISK-009: Spotify App Version Compatibility
- **Category:** Software
- **Status:** ⚠️ Uncertain
- **Description:** The current Spotify app requires Android 7.0+ but may also have implicit dependencies on newer WebView, TLS versions, or Play Services APIs that are only partially available on LineageOS 14.1.
- **Mitigation:** Test the current Play Store version. If it fails, attempt installation of the most recent Spotify version that explicitly lists Android 7.0 support. Do NOT use cracked or modified APKs.

---

## 4. LOW RISKS

### RISK-010: Bluetooth A2DP Audio Quality or Stability
- **Category:** Hardware/Software
- **Description:** Bluetooth audio is reported working but audio quality, codec support (SBC vs AAC vs aptX), and stability with screen off have not been independently verified on this exact hardware/ROM combination.
- **Mitigation:** Include in Phase Seven hardware acceptance tests

### RISK-011: Battery Drain
- **Category:** Operational
- **Description:** Android on non-native hardware typically has poor power management. The 1430 mAh battery may drain rapidly.
- **Mitigation:** Disable unused services, set aggressive sleep, test actual battery life

---

## 5. UNKNOWNS REGISTER

| ID | Unknown | Priority | How to Resolve |
|---|---|---|---|
| UNK-001 | eMMC chip manufacturer | 🔴 CRITICAL | WPInternals CID read or physical inspection |
| UNK-002 | Exact product code | 🟡 HIGH | Phone Settings > About, or WPInternals |
| UNK-003 | Current firmware version | 🟡 MEDIUM | Phone Settings > About |
| UNK-004 | KVM/QEMU availability on host | 🟡 HIGH | Check `kvm-ok` / `/dev/kvm` |
| UNK-005 | Matching stock FFU availability | 🟡 HIGH | LumiaDB lookup by product code |
| UNK-006 | Spotify actual behavior on 512MB/LOS14.1 | 🟡 HIGH | Can only be tested on device |
| UNK-007 | GApps Pico/microG compatibility with Spotify | 🟡 HIGH | Can only be tested on device |
| UNK-008 | Bluetooth A2DP codec support | 🟢 MEDIUM | Device testing |
| UNK-009 | Speaker audio routing | 🟢 LOW | Device testing |
| UNK-010 | USB MTP under Android | 🟢 LOW | Device testing |

---

## 6. Decision Tree

```
START
  │
  ├─ Is eMMC Samsung? ──────── YES → ❌ ABORT (permanent brick risk)
  │                     NO ↓
  ├─ Can Windows VM run WPInternals with USB passthrough?
  │                     NO → ❌ BLOCKED (no way to unlock bootloader)
  │                     YES ↓
  ├─ Can stock FFU be obtained and verified?
  │                     NO → ⚠️ HIGH RISK (no recovery path)
  │                     YES ↓
  ├─ Bootloader unlock succeeds?
  │                     NO → ❌ BLOCKED
  │                     YES ↓
  ├─ LineageOS 14.1 boots successfully?
  │                     NO → Attempt recovery via FFU
  │                     YES ↓
  ├─ Spotify installs and authenticates?
  │                     NO → Primary objective FAILED
  │                     YES ↓
  ├─ Spotify can stream over Wi-Fi + Bluetooth audio?
  │                     NO → Primary objective PARTIALLY FAILED
  │                     YES ↓
  └─ ✅ SUCCESS (Bluetooth-only audio mode)
       Note: Wired audio (3.5mm) confirmed broken
```
