# 🛡️ Project Lumia Music — Disaster Recovery & Rollback Plan
**Target Device:** Nokia Lumia 520 (RM-914, `fame_row`)  
**Phase:** Two — Recovery Feasibility & Safety Gate  
**Author:** Antigravity Engineering  
**Status:** DRAFT / PENDING HARDWARE CHECKS  

---

## 1. Safety Principles & Risk Containment

Before modifying any partition or bootloader configuration on the target Lumia 520:
1. **Never flash without raw partition backups:** We must obtain block-level dumps of all critical boot, calibration, and radio partitions (`DPP`, `EFIESP`, `MODEM`, `SBL*`, `UEFI`) via WPInternals Mass Storage Mode before writing any custom payload.
2. **eMMC Manufacturer Gate (Hard Stop):**
   - Certain Samsung eMMC revisions used in Lumia 520 units suffer from internal firmware lockup when partition structures or MBR/GPT layouts are rewritten.
   - If eMMC CID reveals Samsung (Vendor `0x15` / `SEC`), **FLASHING IS STRICTLY HALTED**.
   - If eMMC CID reveals SK Hynix (`0x90`), Toshiba (`0x11`), or SanDisk (`0x45`), we proceed under standard precautions.
3. **Power Margin Requirement:** The device battery (BL-5J) must be charged to **at least 80%** prior to any flash or unlock operation. USB bus power alone cannot sustain the phone if it enters a high-drain bootloop.

---

## 2. Lumia 520 Partition Architecture

The internal 8 GiB eMMC contains standard Qualcomm/Windows Phone partitioning:

| Partition | Label | Criticality | Purpose |
|---|---|---|---|
| 1 | `MODEM_FSG` | 🔴 High | Cellular / radio configuration |
| 2 | `SSD` | 🟡 Medium | Secure Software Download flags |
| 3 | `SBL1` | 🔴 Extreme | Secondary Bootloader 1 (PBL handoff) |
| 4 | `SBL2` | 🔴 Extreme | Secondary Bootloader 2 |
| 5 | `SBL3` | 🔴 Extreme | Secondary Bootloader 3 |
| 6 | `UEFI` | 🔴 Extreme | Windows Phone UEFI firmware |
| 7 | `RPM` | 🔴 High | Resource Power Manager firmware |
| 8 | `TZ` | 🔴 High | Qualcomm TrustZone |
| 9 | `WINSECAPP` | 🟡 Medium | Windows Security Application |
| 10 | `BACKUP_BS_NV` | 🔴 Extreme | Baseband / NVRAM backup |
| 11 | `DPP` | 🔴 EXTREME | Device Provisioning Partition (Factory radio cal, IMEI, unique per unit) |
| 12 | `PLAT` | 🟡 Medium | Platform data |
| 13 | `EFIESP` | 🔴 High | EFI System Partition (BCD, bootmgr) |
| 14 | `MainOS` | 🟢 Low | Windows Phone OS system files |
| 15 | `Data` | 🟢 Low | User data & app storage |

> [!CAUTION]
> **Partition `DPP` (Device Provisioning Partition)** contains factory RF calibration data, DRM keys, and the unique device IMEI calibration. If `DPP` is corrupted or wiped without a backup, cellular and Wi-Fi/Bluetooth hardware calibration cannot be reconstructed.

---

## 3. Recovery Pathways Matrix

Depending on the failure mode, the following recovery pathways are established:

```
                      ┌───────────────────────────────────────┐
                      │          Phone State Failure          │
                      └──────────────────┬────────────────────┘
                                         │
         ┌───────────────────────────────┼───────────────────────────────┐
         ▼                               ▼                               ▼
┌──────────────────┐           ┌──────────────────┐           ┌──────────────────┐
│ Soft Bootloop /  │           │ Flash Mode Only  │           │ Hard Brick (QDL) │
│ Android Won't    │           │ (Gear/Lightning  │           │ Qualcomm 9008    │
│ Boot             │           │ or Nokia Logo)   │           │ Black Screen     │
└────────┬─────────┘           └────────┬─────────┘           └────────┬─────────┘
         │                              │                              │
         ▼                              ▼                              ▼
┌──────────────────┐           ┌──────────────────┐           ┌──────────────────┐
│ TWRP Recovery    │           │ WPInternals /    │           │ Qualcomm Sahara/ │
│ / Fastboot       │           │ Thor2 / WDRT     │           │ Firehose Tool    │
│ Reflash ZIP /    │           │ Full FFU Flash   │           │ Emergency HEX /  │
│ Restore Backup   │           │ Back to Stock WP │           │ Programmer Flash │
└──────────────────┘           └──────────────────┘           └──────────────────┘
```

### Path A: Soft Brick / OS Recovery (TWRP available)
- **Trigger:** Android fails to boot (stuck on LineageOS boot animation), but TWRP recovery is accessible (Hold Volume Down + Power during reboot).
- **Remedy:** Connect via USB, execute ADB/TWRP command line:
  - Format `/data` and `/cache`
  - Re-push LineageOS 14.1 ZIP and reflash
  - Or restore TWRP nandroid backup from microSD card.

### Path B: Bootloader / UEFI Recovery (Flash Mode available)
- **Trigger:** Phone boots only to Nokia logo, spinning gears, or lightning bolt + gear screen.
- **Entry Combination:** Power off -> Hold `Volume Down` -> Connect USB cable to PC until big gear or lightning bolt appears.
- **Remedy:**
  1. Boot Windows VM with WPInternals / Windows Device Recovery Tool.
  2. Select **Flash -> Flash original FFU**.
  3. Select matching RM-914 FFU file (matched to device product code `059xxxx`).
  4. Flashing takes ~3-5 minutes and restores the phone to factory stock Windows Phone 8.0/8.1.

### Path C: Emergency Download (EDL / Qualcomm 9008 mode)
- **Trigger:** Phone is completely unresponsive, black screen, vibrates once or not at all, enumerates as `05c6:9008` (Qualcomm CDMA Technologies MSM).
- **Remedy:**
  1. Requires emergency programmer files: `MPRG8227.hex` and `8227_msimage.mbn`.
  2. WPInternals or open-source `qdl` tool uploads Sahara programmer to initialize DDR RAM.
  3. Writes partition tables and SBL/UEFI to restore Flash Mode.

---

## 4. Pre-Flashing Full Backup Protocol (WPInternals Mass Storage Mode)

Once WPInternals unlocks the bootloader, the phone can be booted into **Mass Storage Mode**. In this mode, the entire eMMC is presented as a raw USB Mass Storage disk:

```bash
# Verify raw disk detection on Linux host or inside VM
lsblk -o NAME,SIZE,TYPE,FSTYPE,LABEL,PARTLABEL

# Image entire eMMC (8GB raw disk, e.g. /dev/sdX)
sudo dd if=/dev/sdX of=/home/alfy/claude/lumia-music/recovery/lumia520_raw_emmc_full.img bs=4M status=progress conv=sync,noerror

# Extract isolated critical partitions
sudo dd if=/dev/disk/by-partlabel/DPP of=/home/alfy/claude/lumia-music/recovery/DPP_backup.img bs=4M status=progress
sudo dd if=/dev/disk/by-partlabel/MODEM_FSG of=/home/alfy/claude/lumia-music/recovery/MODEM_FSG_backup.img bs=4M status=progress
sudo dd if=/dev/disk/by-partlabel/EFIESP of=/home/alfy/claude/lumia-music/recovery/EFIESP_backup.img bs=4M status=progress

# Generate SHA256 checksums
sha256sum /home/alfy/claude/lumia-music/recovery/*.img > /home/alfy/claude/lumia-music/recovery/backup_checksums.sha256
```

---

## 5. Decision Gate: eMMC Health & Manufacturer Verification

```
                      [ Connect Phone to WPInternals ]
                                     │
                      [ Read eMMC CID Register ]
                                     │
                        Is Vendor ID 0x15 (Samsung)?
                                     │
                 ┌───────────────────┴───────────────────┐
                 │                                       │
              [ YES ]                                 [ NO ]
                 │                                       │
                 ▼                                       ▼
    🛑 CRITICAL STOP:                        ✅ PASS SAFETY GATE:
    Known brick risk on RM-914              SK Hynix / Toshiba / SanDisk
    Document finding                        Proceed to Full Backup
    Do NOT rewrite partition table          and Unlock
```

---

## 6. Emergency Contacts and Resources
- LumiaDB RM-914 Repository: `https://lumiadb.com/device/RM-914/`
- Android4Lumia Telegram Support: `@android4lumia`
- WPInternals Documentation: `https://github.com/ReneLergner/WPinternals`
