## 1. Overview

PRIORITY SETUP

1) Detection Pixel
   Pick a pixel from CSP's Enable/Disable Light Table button area. Use AHK Window Spy and copy Mouse Position: Screen X/Y.

2) CSP AutoAction Presets
   Check only the CSP presets you actually installed:
   - Animation_autoaction.laf
   - Nastar.laf

3) Click Coordinates
   Calibrate LT Reset, Image 1, and Image 2 if CSP moves.

4) Keep HK off during first setup
   After setup is done, turn HK on from the Main GUI.

Use Save All when finished. Use Reset All only when you want the whole System Settings page to return to toolkit defaults.

## 2. Detection

### Detection Pixel

What it does:
Reads one screen pixel to know if Light Table is ON.

How to pick:

- Open CSP Animation Cels window.
- Pick a pixel from the Enable/Disable Light Table button area.
- Avoid the icon color. Use the button edge or background color.
- Expected should match the color shown there while LT is ON.

Fields:

| Field | Meaning |
| --- | --- |
| X / Y | Screen coordinate from AHK Window Spy |
| Expected | The ON-state color for the selected pixel |
| Found | The color currently found at that X/Y |
| Test | Compares Expected vs Found |

### Click Coordinates

| Field | Target |
| --- | --- |
| LT Reset | Reset position of layers on light table |
| Image 1 | First image of cel-specific light table |
| Image 2 | Third image of cel-specific light table |

Recalibrate these when CSP window or Animation Cels palette moves.

## 3. Color Info

### Mode

- Follow cursor — the color info box follows the mouse.
- Draggable — the box stays where you drag it.

### Offset

X/Y offset applies only in Follow cursor mode.
Default: X -20, Y 50.

### Tick

How often Color Info refreshes, in milliseconds.
Default: 60ms. Lower is more responsive; higher is lighter.

### Middle click copy

When ON, middle mouse copies the current screen color. This only works while Color Info is active.

### Clipboard

- RGB copies as: 225,193,126
- HEX copies as: E1C17E
- Default: RGB

## 4. Presets

### Animation_autoaction.laf

Required by IB / inbetween hotkeys: Ctrl+1 through Ctrl+7.

### Nastar.laf

Required by most layer, color, create, feature, folder, checker, and utility actions.

### If a preset is unchecked

Hotkeys and GUI buttons requiring that preset are blocked. The Requirement Preview button shows what will be affected.

Use this to safely disable actions when CSP does not have the matching AutoAction preset installed.

## 5. Timing

### Hold Threshold

Time: How long CapsLock or Tab must be held before hold behavior starts. Range: 20-500ms. Default: 80ms.

Enable CapsLock hold: Same state as the Caps button in the IB GUI. When off, CapsLock hold actions are disabled.

Enable Tab hold: Same state as the Tab button in the IB GUI. When off, Tab combos and Tab hold behavior are disabled.

Tab auto-detect: Holding Tab past threshold opens whichever pie currently has Tab assigned as its hotkey (default: Pie 1). If no pie uses Tab, a plain Tab is sent instead. Block Tab output prevents any Tab from reaching CSP.

### Select Light Table Cell

Mode 1: Alt+A / Alt+D resets LT first, then selects cel. Ctrl+Alt+A / Ctrl+Alt+D bypasses the reset.

Mode 2: Alt+A / Alt+D sends normal CSP select behavior only.

## 6. Backup

### Auto Save

Interval: Automatically saves the current CSP file every N seconds. Range: 10-3600 seconds. Default: 60s.

Save As mode: Ultimate Save As is the default and requires Nastar.laf. Normal Save As opens the Save As dialog only.

### Backup / Import

Backup: Creates a timestamped local backup.

Restore: Restores from a local backup.

Export JSON: Lightweight single config file for core settings.

Import JSON: Imports that lightweight config file.

Export Mode Bundle: Exports one mode's settings as a portable bundle folder in Documents.

Import Mode Bundle: Opens the same import chooser as first run: JSON config or a Mode Bundle folder for a single mode.
