# Project Lumia Music — Validation Toolkit

## Overview
This toolkit supports the safe transformation of a Nokia Lumia 520 (RM-914) into a dedicated Spotify music player. **All scripts are read-only and non-destructive** unless explicitly noted.

## Directory Structure
```
lumia-music/
├── docs/                        # Project documentation
│   ├── environment_report.md    # Host system analysis
│   ├── device_inventory.md      # Phone hardware details
│   ├── compatibility_matrix.md  # ROM and Spotify compatibility
│   └── risks_and_unknowns.md   # Risk register and decision tree
├── scripts/                     # Automation scripts
│   ├── inspect_usb.sh          # USB device detection (read-only)
│   ├── validate_environment.sh # Prerequisites checker
│   └── verify_downloads.sh     # Download integrity verifier
├── manifests/                   # Checksum manifests
├── logs/                        # Timestamped execution logs
│   └── README.md               # (this is auto-populated by scripts)
├── tests/                       # Hardware acceptance tests (Phase Seven)
├── recovery/                    # Recovery artifacts and plans
│   └── README.md
└── README.md                    # This file
```

## Quick Start
```bash
# 1. Validate the development environment
bash scripts/validate_environment.sh

# 2. Inspect USB devices (phone should be connected)
bash scripts/inspect_usb.sh

# 3. Verify downloaded files (after obtaining ROM/firmware)
bash scripts/verify_downloads.sh /path/to/downloads
```

## Safety Rules
- **No script in this toolkit will modify the phone** without explicit, reviewed authorization
- All scripts produce timestamped logs in `logs/`
- Downloaded files are verified but never executed by these scripts
- Device-specific files are checked against naming patterns to prevent cross-device firmware accidents

## Current Project Status
- **Phase:** Zero — Environment Discovery ✅ COMPLETE
- **Next Phase:** One — Authoritative Firmware Research (pending user review)
- **Overall Verdict:** CONDITIONAL GO — pending eMMC chip identification and user acceptance of Bluetooth-only audio

## Critical Prerequisites for Next Phase
1. ☐ Determine eMMC chip manufacturer (Samsung = ABORT)
2. ☐ User decision: Accept Bluetooth-only audio (3.5mm jack broken on Android)
3. ☐ Set up Windows VM with USB passthrough for WPInternals
4. ☐ Obtain matching stock FFU firmware for RM-914
