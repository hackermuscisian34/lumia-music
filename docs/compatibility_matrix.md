# Compatibility Matrix — Project Lumia Music
**Date:** 2026-10-29T17:00+05:30  
**Phase:** Zero — Environment and Device Discovery  
**Status:** COMPLETE

---

## 1. ROM Candidates for Nokia Lumia 520 (RM-914, codename "fame")

| ROM | Android Version | API Level | Arch | Source | Status |
|---|---|---|---|---|---|
| Android4Lumia LineageOS 13.0 | 6.0 Marshmallow | 23 | ARMv7 | [cm-13.0 branch](https://github.com/Android4Lumia/android_device_nokia_fame/tree/cm-13.0) | Available (older) |
| **Android4Lumia LineageOS 14.1** | **7.1.1 Nougat** | **25** | **ARMv7** | [cm-14.1 branch](https://github.com/Android4Lumia/android_device_nokia_fame/tree/cm-14.1) | **Best candidate** |
| PostmarketOS / mainline Linux | N/A | N/A | N/A | Community | No known port for fame |
| Windows 10 Mobile | N/A | N/A | N/A | Microsoft | Does not support Spotify in 2026 |

## 2. Spotify Compatibility Analysis

| Requirement | LOS 13.0 (Android 6.0) | LOS 14.1 (Android 7.1.1) | Verdict |
|---|---|---|---|
| **Minimum Android version** | ❌ Android 7.0+ required | ✅ Android 7.1.1 meets minimum | **Only LOS 14.1 qualifies** |
| CPU architecture (ARMv7) | ✅ Supported | ✅ Supported | OK |
| RAM (512 MiB) | ⚠️ Far below recommended | ⚠️ Far below recommended | **HIGH RISK** |
| Google Play Services | ⚠️ Optional GApps, very tight on 512MB | ⚠️ Optional GApps, very tight on 512MB | **Uncertain** |
| DRM (Widevine) | ❓ Unknown on this port | ❓ Unknown on this port | **Uncertain** |
| Network (streaming) | ✅ Wi-Fi works | ✅ Wi-Fi works | OK |

> [!WARNING]
> **Spotify's minimum is Android 7.0+**, making LineageOS 14.1 the ONLY viable ROM. However, with only **512 MiB RAM**, running Spotify + Google Play Services + Android system simultaneously is extremely constrained. The app may crash, fail to load, or be unable to stream reliably.

## 3. Hardware Feature Matrix on Android4Lumia LineageOS 14.1

| Feature | Status | Impact on Music Player | Source |
|---|---|---|---|
| **Wi-Fi** | ✅ Working | Essential for Spotify streaming | XDA / A4L docs |
| **Bluetooth** | ✅ Working | Essential for BT headphones | XDA / A4L docs |
| **Bluetooth A2DP** | ⚠️ Reported working, unverified on RM-914 | Primary audio output | Community reports |
| **3.5mm headphone jack** | ❌ **BROKEN** | **BLOCKER for wired audio** | XDA / A4L docs |
| **Speaker** | ⚠️ Partially working (reports vary) | Secondary audio output | Community reports |
| Touchscreen | ✅ Working | Essential for UI | XDA / A4L docs |
| Display | ✅ Working (480×800) | Essential for UI | XDA / A4L docs |
| Cellular/RIL | ❌ Broken | Not needed for music player | XDA / A4L docs |
| Camera | ❌ Broken | Not needed | XDA / A4L docs |
| Accelerometer | ❌ Broken | Minor (no auto-rotate) | XDA / A4L docs |
| Proximity sensor | ❌ Broken | Not needed | XDA / A4L docs |
| Light sensor | ❌ Broken | Minor (no auto-brightness) | XDA / A4L docs |
| GPS | ❌ Broken | Not needed | XDA / A4L docs |
| USB MTP | ⚠️ Uncertain | Nice to have for file transfer | Unverified |

## 4. Critical Blocker Summary

| # | Blocker | Severity | Mitigation |
|---|---|---|---|
| 1 | **3.5mm headphone jack is BROKEN** on Android4Lumia | 🔴 CRITICAL | Bluetooth-only audio; user specification requires both BT and wired |
| 2 | **512 MiB RAM** may be insufficient for Spotify | 🔴 CRITICAL | Aggressive debloating, swap file, lite launcher |
| 3 | **eMMC manufacturer unknown** — Samsung chips brick permanently | 🔴 CRITICAL | Must identify before any flashing |
| 4 | **WPInternals requires Windows** — user has no Windows PC | 🟡 HIGH | Windows VM with USB passthrough |
| 5 | **Google Play Services** may not fit in available RAM | 🟡 HIGH | Try microG or Pico GApps variant |
| 6 | **Recovery from failed flash** requires Windows tools | 🟡 HIGH | Same VM solution |

## 5. Overall Feasibility Summary

```
┌─────────────────────────────────────────────────────┐
│           PROJECT LUMIA MUSIC — FEASIBILITY          │
├─────────────────────────────────────────────────────┤
│ Spotify on Android:        CONDITIONAL               │
│   - ROM exists:            ✅ LOS 14.1 for fame      │
│   - Android version:       ✅ 7.1.1 meets minimum    │
│   - RAM sufficiency:       ❌ 512MB severely limited  │
│   - Wired audio:           ❌ Headphone jack broken   │
│   - Bluetooth audio:       ✅ Reported working        │
│   - Wi-Fi streaming:       ✅ Working                 │
│                                                       │
│ Recovery & Safety:         HIGH RISK                  │
│   - Bootloader unlock:     Requires Windows (VM)      │
│   - eMMC chip risk:        UNKNOWN — must check       │
│   - Stock firmware restore:Requires Windows (VM)      │
│                                                       │
│ OVERALL:                   CONDITIONAL GO             │
│ (Bluetooth-only audio, pending eMMC check,            │
│  pending Spotify RAM viability testing)               │
└─────────────────────────────────────────────────────┘
```
