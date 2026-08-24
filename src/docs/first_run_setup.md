## PRIORITY SETUP - KEEP HK OFF UNTIL DONE

FIRST RUN

Custom shortcuts are paused on first launch.
The Main GUI HK button will display OFF.

Complete the setup below before enabling HK.

RECOMMENDED: Clip Studio Paint 5.0.4 or newer.
Older versions may lack features this toolkit depends on.

---

## CHECK CSP AUTOACTION PRESETS

Open CSP and verify these presets before setting shortcuts:

1) In CSP, go to Auto Actions palette
2) Check you have these two presets:
   - **Animation_autoaction.laf** — REQUIRED
   - **Nastar.laf** — Optional (recommended, many features depend on it)

If missing, download or create them before proceeding.

SKIP this step at your own risk — hotkeys for inbetween presets will silently fail without these presets.

---

## SETUP CSP SHORTCUTS

OPTIONS > Animation cel palette:

- Enable/Disable Light Table Tool = Ctrl+Shift+Alt+W

MENU COMMANDS > Edit:

- Change Canvas Size = Ctrl+/
- Canvas Properties = Ctrl+Shift+Alt+;

Clear work history:

- Canvas work time (CSP 4.1+) = Ctrl+Shift+Alt+\

MENU COMMANDS > Animation, Timeline:

- Change Settings = Shift+Alt+S

Show Animation Cels > Check Cel Motion:

- Ctrl+Shift+Alt+1
- Ctrl+Shift+Alt+2
- Ctrl+Shift+Alt+3

AUTO ACTIONS > Animation_autoaction.laf (Required CSP AutoAction Preset):

| Action | Shortcut |
| --- | --- |
| 50 | Ctrl+1 |
| 33 | Ctrl+2 |
| 66 | Ctrl+3 |
| 25 | Ctrl+4 |
| 75 | Ctrl+5 |
| 40 | Ctrl+6 |
| 60 | Ctrl+7 |

---

## SETUP LT DETECTION SETTINGS

Use AHK Window Spy. Copy values from: Mouse Position: Screen.

DETECTION PIXEL

- Check the Enable/Disable Light Table Tool button in the Animation Cels window.
- Enter its Screen X and Y coordinates.

CLICK COORDINATES

- LT Reset — Reset position of layers on light table
- LT Image 1 — First image of cel-specific light table
- LT Image 2 — Third image of cel-specific light table

CSP AUTOACTION PRESETS (in System Settings)

- Open System Settings
- Check the boxes under CSP AutoAction Presets:
  - Animation_autoaction.laf
  - Nastar.laf
- Unchecked presets will disable hotkeys that need them.

---

## FINISH

After everything is configured, click HK in the Main GUI.

Status should change: OFF -> HK

Custom shortcuts are now active.
