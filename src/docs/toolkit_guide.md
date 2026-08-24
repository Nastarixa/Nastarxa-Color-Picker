Nastarxa CSP Animator Toolkit is an AutoHotkey v2 helper for Clip Studio Paint animation work. It adds focused hotkeys, small tool GUIs, Light Table helpers, guide popups, link buttons, and editable pie menus.

Recommended: Clip Studio Paint 5.0.4 or newer.

---

## FIRST RUN CHECKLIST - do this before turning HK ON

Custom shortcuts start paused on first run. The Main GUI HK button shows OFF so CSP setup can be finished safely. After the setup below is done, click HK to turn custom shortcuts ON.

### 1) Check CSP AutoAction presets

Open CSP's Auto Actions palette and verify these two presets exist:

- **Animation_autoaction.laf** — REQUIRED
- **Nastar.laf** — Optional (recommended, many features depend on it)

Without the required preset, inbetween preset hotkeys cannot run.

### 2) Set CSP shortcuts

Options > Animation cel palette:

- Enable/disable light table tool = Ctrl+Shift+Alt+W

Menu commands > Edit:

- Change Canvas Size = Ctrl+/
- Canvas Properties = Ctrl+Shift+Alt+;
- Clear work history > Canvas work time (CSP 4.1+) = Ctrl+Shift+Alt+\

Menu commands > Animation:

- Timeline > Change settings = Shift+Alt+S
- Show animation cels > Check cel motion by key input =
  Ctrl+Shift+Alt+1, Ctrl+Shift+Alt+2, Ctrl+Shift+Alt+3

Auto Actions > Animation_autoaction:

- 50 = Ctrl+1, 33 = Ctrl+2, 66 = Ctrl+3
- 25 = Ctrl+4, 75 = Ctrl+5, 40 = Ctrl+6, 60 = Ctrl+7

### 3) Calibrate System Settings

Use AHK Window Spy and copy Mouse Position: Screen X/Y.

| Setting | Where |
| --- | --- |
| Detection Pixel | Enable/Disable Light Table Tool position |
| LT Reset | Reset position of layers on light table |
| LT Image 1 | First image of cel-specific light table |
| LT Image 2 | Third image of cel-specific light table |

---

## TOOLKIT OVERVIEW

What this toolkit gives you:

- Context-sensitive hotkeys (CSP-only, background, global)
- Inbetween Bar — select inbetween ratios with Ctrl+1~7
- Navigation — Space to pan, toggleable auto-hold
- Light Table automation — pixel detection for LT state
- CapsLock modifier — holds Ctrl+Shift+Alt while pressed, with editable hold time and optional CapsLock+1-0 assigned actions
- Backtick combos — inbetween types, layers, actions
- Color Palette GUI — fill, paint, utils, folder buttons, toggleable H/V layout, optional Action A/B toggle buttons, and right-click action tester
- Layer shortcuts — new layers, opacity, visibility, vector paths, draft toggle, open/close folder
- Link Launcher — open tools, folders, URLs from GUI, with optional Action A/B toggle buttons and right-click action tester
- Timer / Stopwatch — track work time with save/load (PNG/TXT)
- Color Info — real-time hex/RGB picker under cursor, optional draggable mode, and middle-click clipboard copy
- Auto Save — periodic file save (configurable interval)
- Hotkey customization — edit/disable/import/export all keys
- Opacity settings — transparency, UI scale, scroll power, notification toggle and monitor selection, reset
- HK pause — temporarily disable all custom shortcuts
- Pie Menu — cursor-centered hover menu for shortcuts/functions/scripts/nav/show-pie actions, with sub-pies, profiles, and pie quick keys
- Debug Log — view script activity in real time
- CSP Setup Validator — check setup, coordinates, presets, pies
- Broken Action Scanner — find missing actions, scripts, functions
- Dev Tools — release checklist, version check, preset hub, clean release folder, build release package, open release folder, optional dev-tools release include, tools/presets zip, release audit, preset tester, function doctor, settings integrity, broken icon scan
- Hover tooltips — descriptions on all GUI buttons
- Tool GUI toggle (^F1) — show/hide all tool GUIs
- CSP crash monitor — prompts restart if CSP closes
- Backup / Restore — full settings backup

---

## HOW TO USE

### Requirements

- AutoHotkey v2.0+ installed
- Clip Studio Paint running
- CSP Auto Actions presets [Animation_autoaction.laf] and [Nastar.laf] installed in CSP

### Getting Started

1) Run the script.
2) Finish the first-run checklist above.
3) Open the Main GUI with Alt+F1.
4) Use System Settings (?) for LT detection, presets, auto-save, CapsLock hold timing, and coordinate tools. Use Pie Oven for pie menus, sub-pies, profiles, and pie hotkeys.
5) Use Hotkey Settings (?) to record, edit, disable, or add hotkeys.

### Main GUI Buttons

| Button | Purpose |
| --- | --- |
| Guide | This guide |
| K | Hotkey Settings (browse, edit, import/export hotkeys) |
| Gear | System Settings (LT calibration, presets, auto-save, CapsLock/Tab hold) |
| Pie Oven | Pie menus, sub-pies, profiles, and pie hotkeys |
| Link | Link Button Manager (add/edit/reorder links) |
| Reset | Reset GUI positions |
| HK | Pause/resume all custom shortcuts |
| Pie | Open a hover-activated pie menu |
| Pie Set | Edit pie labels, actions, colors, and requirements |
| Opacity | Transparency, UI scale, scroll power, notification toggle & monitor, and Reset |

Right-click Main GUI for opacity / debug / backup / restore.

- Status — check HK, LT, requirements, conflicts, last debug line, and open Validator / Scanner
- Safe — toggle safe mode; first press pauses/modes off, second restores
- Debug — view activity log, save/clear log, and open Validator / Scanner
- Dev — release checklist, version check, clean release copy, and broken icon scanner

### Validator / Scanner / Health

**Validator** — first-run readiness check. Use it after setup, import, or calibration changes. [FIX] usually means open System Settings or CSP shortcut settings.

**Scanner** — broken action check. Finds empty pie actions, missing functions, missing script paths, empty URLs, disabled requirements, user script issues, and duplicate hotkeys.

**Health** — settings structure check. Checks split settings files, duplicate INI data, pie/sub-pie shape, quick-pie data, link data, and user function library folder. Backup before large cleanup if the current setup is important.

**Doctor** — config drift check. Finds missing split files, duplicate INI data, stale config version, malformed pie/color data, and likely fallback-to-default causes.

**Typing** — typing safeguard inspector. Shows active title, preserved title, focused control, and whether IsTyping() is currently blocking toolkit hotkeys. Edit Lists opens the Typing Title Lists editor to add new titles, disable/enable, delete, or reset the window titles used by the safeguard to defaults. New Cat creates extra named lists of any of the three matching behaviors (CSP dialog, toolkit dialog, or non-typing exception); Del Cat removes a custom list.

**Hotkey Stress Test** — live key transition monitor. Open it from System Settings > Hold Threshold to diagnose Tab, CapsLock, modifier, mouse-button, and number-row timing.

**Dev Tools** — release helper window.

- Release Checklist checks required files and release readiness.
- Version Check compares SCRIPT_VERSION, README badge, and latest release folder.
- Preset Hub opens profile/preset import-export tools in one place.
- Clean Release Folder creates a fresh release copy without live settings.
- Build Release Package creates a clean release folder and zips it for sharing.
- Include Dev Tools lets you keep or remove src/dev from clean release output.
- Make EXE on release builds a compiled toolkit with Ahk2Exe and CSPToolkit.ico.
- Open Release Folder opens the latest clean release folder or the release root.
- Tools/Presets Zip creates CSP_Tools_and_AutoAction_Presets.zip from CSP_AutoAction_Presets and CSP_Tools.
- Release Audit combines health, icon scan, preset test, and function checks.
- Preset Tester checks quick-pie preset files without loading them.
- Function Doctor checks missing callable functions across hotkeys and GUIs.
- Settings Integrity opens the Settings Health report.
- Broken Icon Scanner finds mojibake/fallback icon text before release.

### Pie Defaults

| Pie | Content |
| --- | --- |
| Pie 1 | Layer Pie: named functions that perform Shift+1..0 layer colors |
| Pie 2 | Create Pie: named functions that perform Alt+1..0 create actions |
| Pie 3 | Utility Pie: named functions for Ctrl+Shift utility and paper colors |
| Pie 4 | Guide Pie: Guide submenu and layer navigation functions |

Pie Oven changes names, open hotkeys, delay, deadzone, style, export/import profiles, sub-pies, or reset pies to defaults.

- Action Preview inspects a pie slot summary without opening the editor.
- Pie saves create before-save snapshots in settings\settings_backups.
- Default delay is 65ms. Submenu hover delay is 20% faster.
- Styles: Normal, Left, Right.
- Row Save/Test and Sub Pie Preview/Test use the current visible Delay, Dead, and Style values from Pie Oven.
- Left/Right curve all slot boxes around one side and hide slot names.
- While a pie is open, press 1-0 to activate slots 1-10 directly.
- Hotkey Settings > Quick Pie adds editable A/D/L-style quick keys that only run while a pie is open and can target one pie or all pies.
- Quick Pie > Presets loads additively; existing quick hotkeys are kept.
- Quick Pie > Save as Preset saves the current list as a reusable preset.

### Hotkey Settings Tips

- Use Record to capture a key combo, or type directly
- Prepend ^ (Ctrl), + (Shift), ! (Alt), # (Win)
- Enter - (dash) to disable a hotkey
- CapsLock 1-0 opens the assignment popup for CapsLock+number slots
- Function Browser tests, copies, inserts, and shows where functions are used
- User Function Library > Add/Edit > Record can build a user script from shortcut, function-call, and delay steps, then you can edit it
- Click How to Use inside Hotkey Settings for details
- CSP typing dialogs, including blank-title shortcut fields, reuse the last non-empty window title and block custom hotkeys so input is not intercepted

Resolve — select a conflict row and disable the other duplicate.

### IB GUI Controls

| Control | Action |
| --- | --- |
| Hand | Toggle Navigation |
| Caps | Toggle CapsLock mod |
| Win | Toggle LWin mod |
| S>E / E>S | Toggle IB direction mode |
| Reset | Reset stuck keys |
| HEX | Toggle Color Info |
| Lock / Unlock | LT Lock |
| Save / Sleep | Auto Save toggle |
| Timer | Timer controls (start, pause, lap/stop, save, load) |
| 1~7 | Select inbetween ratio |

- Start > End: smaller layer above edit, bigger layer below
- End > Start: bigger layer above edit, smaller layer below
- Hand(orange) Caps(blue) Tab(green) Reset(purple) — ON/OFF state
- Right-click for opacity / context menu

### Color GUI Buttons

| Button | Action |
| --- | --- |
| Fill R / G / B / A | Red, green, blue, alpha/transparent fill |
| Colors P / C / O / Pu | Pink, cyan, orange, purple paint |
| Utils | Deselect / Invert / Isolate / Draft / Vector paths |
| Folders | Open folder / Close all folder |
| H/V | Toggle horizontal/vertical layout |

Fill / Utils labels shown in vertical mode, hidden in horizontal. Right-click for opacity / context menu.

### Link Launcher

- Default links: Worktime, Canvas, Timeline, Change Canvas Size, Sheets placeholder, Drive placeholder, Search Nastarixa Script
- Empty URL/path buttons ask you to add the target before opening
- Add/edit/remove/reorder links via Link Manager
- Right-click any tool GUI for opacity / context menu
- Right-click Main GUI for backup/restore config

### Hotkey Categories

- Toggleable groups — Nav, CapsLock, Tab, Reset, LWin
- Always-on — inbetween bar, color palette, layers
- Background — hotkeys when CSP is behind other windows

---

## HOTKEY REFERENCE

### Inbetween Bar

| Key | Action |
| --- | --- |
| Ctrl+1~7 | Select inbetween type (bar shows ratio) |
| Ctrl+F2 / Alt+L | Toggle LT lock |
| Ctrl+F4 | Toggle auto save (every 60s) |
| Lock button | Locks light table when active |
| Auto Save button | Saves file every 60 seconds |
| Ctrl+Alt+F5 | Timer start/pause toggle |
| Ctrl+Alt+F6 | Timer lap |
| Ctrl+Alt+F7 | Timer stop/reset with save prompt |
| Ctrl+Alt+F8 | Timer save |
| Timer Lap button | While running, the red stop button becomes Lap |
| Save Timer window | Edit lap names before saving PNG/TXT |
| Timer Load | Load TXT directly, or PNG when same-name TXT sidecar exists |

### Navigation (toggleable)

| Key | Action |
| --- | --- |
| Space | Pan (auto-hold LButton on press, release on key up) |
| Ctrl+Space | Pan with Ctrl modifier |
| Ctrl+Shift+Space | Quick Space tap (single press) |
| Shift+Alt+Space | Pan with Shift+Alt modifier |
| Hand button / Ctrl+F5 | Toggle navigation ON/OFF |

### CapsLock Mod (toggleable)

| Key | Action |
| --- | --- |
| CapsLock tap | Normal CapsLock toggle |
| CapsLock hold | Holds Ctrl+Shift+Alt until CapsLock is physically released |
| Hold time | System Settings > Hold Threshold, default 60ms |
| CapsLock+1-0 | Optional assigned actions from Hotkey Settings > CapsLock 1-0 |
| Unassigned 1-0 | Pass through as Ctrl+Shift+Alt+number while held |
| While held | Only Backtick / 1-0 / - / = pass through; other keys are blocked |
| Caps button / Ctrl+F6 | Toggle CapsLock modifier ON/OFF |

### Tab Combos (toggleable)

| Key | Action |
| --- | --- |
| Tab tap | Sends normal Tab |
| Tab hold | Opens Pie 1 / Last Pie / Disabled from System Settings |
| Shift/Ctrl/Alt+Tab | Pass through normally |
| Tab button / Ctrl+F7 | Toggle Tab hold/combo behavior ON/OFF |

### Backtick Combos

#### Ctrl+Backtick — Inbetween types

    Ctrl+1    50 |-----|-----|>
    Ctrl+2    S>E 66 |-------|---|>   /   E>S 33 |---|-------|>
    Ctrl+3    S>E 33 |---|-------|>   /   E>S 66 |-------|---|>
    Ctrl+4    S>E 75 |--------|--|>   /   E>S 25 |--|--------|>
    Ctrl+5    S>E 25 |--|--------|>   /   E>S 75 |--------|--|>
    Ctrl+6    S>E 60 |------|----|>   /   E>S 40 |----|------|>
    Ctrl+7    S>E 40 |----|------|>   /   E>S 60 |------|----|>

#### Alt+Backtick — Create New

| Key | Action |
| --- | --- |
| Alt+1 | New Paper Layer |
| Alt+2 | New Raster Layer |
| Alt+3 | New Vector Layer |
| Alt+4 | New Colored Vector Layer |
| Alt+5 | New Dummy Layer |
| Alt+6 | Separate Black Line + Paint |
| Alt+7 | New Pink Vector Layer |
| Alt+8 | New Cyan Vector Layer |
| Alt+9 | New Orange Vector Layer |
| Alt+0 | New Animation Folder |

#### Shift+Backtick — Quick Reference

| Key | Action |
| --- | --- |
| V | Flip Layer |
| Shift+C | Reset Color |
| Alt+C | Transparent Color |
| Alt+V | Toggle Layer Visible |
| Shift+B | Opacity 100 |
| Alt+B | Opacity 50 |
| Ctrl+Alt+B | Opacity 25 |
| Ctrl+B | Toggle Layer Color |
| Ctrl+Shift+Alt+C | Paint Red Line |
| Ctrl+Shift+Alt+B | Paint Blue Line |
| Ctrl+Shift+Alt+V | Paint Green Line |
| Ctrl+Shift+Alt+N | Paint Pink Line |
| Ctrl+Shift+Alt+M | Paint Cyan Line |
| Ctrl+Shift+Alt+, | Paint Orange Line |
| Ctrl+Shift+Alt+. | Paint Purple Line |
| Ctrl+Shift+Alt+F | Paint Alpha/Transparent |
| Ctrl+Shift+Alt+Insert | Set to Paint: Animation |
| Ctrl+Shift+Alt+PageUp | Set Cels to Track |
| Ctrl+Shift+Q | Set as Reference Layer |
| Ctrl+Shift+Alt+Q | Isolate Layer |
| Ctrl+Shift+F | Set as Draft Layer |
| Ctrl+Shift+Alt+' | Toggle Draft Layers Visibility |
| Ctrl+Shift+G | Clip to Layer Below |
| Ctrl+Shift+R | Lock Layer |
| Ctrl+Shift+E | Lock Layer Transparent |
| Ctrl+Shift+W | Lock Animation Cel |
| Ctrl+Shift+X | Delete Cel from Timeline |
| Shift+X | Delete Cel from Light Table |
| Ctrl+Shift+Alt+D | Duplicate Layer |
| Ctrl+Shift+Alt+G | Create Folder and Insert Layer |
| Ctrl+Alt+G | Ungroup Layer Folder |
| Ctrl+; | Rasterize Layer |
| Ctrl+Shift+Alt+[ | Vector Paths |
| Ctrl+Shift+Alt+= | Open Folder |
| Ctrl+Shift+Alt+- | Close All Folder |
| Capslock | LightTable |
| Shift+Tab | Reset LightTable |

#### Ctrl+Shift+Backtick — AutoAction

| Key | Action |
| --- | --- |
| Ctrl+Shift+1 | Set Layer as Keyframe Color |
| Ctrl+Shift+2 | Set Layer as Reference Color |
| Ctrl+Shift+3 | Remove Layer Color |
| Ctrl+Shift+4 | Change LT Image 1/3 Half Color |
| Ctrl+Shift+5 | Normal Color |
| Ctrl+Shift+6 | Layer Color Black |
| Ctrl+Shift+7 | Change Paper Color Purple |
| Ctrl+Shift+8 | Change Paper Color Green |
| Ctrl+Shift+9 | Change Paper Color White |

#### Ctrl+Alt+Backtick — Animation

| Key | Action |
| --- | --- |
| Ctrl+Alt+W | Toggle Lighttable |
| Alt+W | Toggle Onionskin |
| Shift+Alt+W | Add Onionskin to Lighttable |
| Shift+X | Delete Cel from Light Table |

### Color Palette

| Button | Action |
| --- | --- |
| R / G / B / A | Fill red/green/blue/alpha-transparent (Ctrl+Shift+Alt+C/V/B/F) |
| P / C / O / Pu | Paint pink/cyan/orange/purple (Ctrl+Shift+Alt+N/M/,/.) |
| Set | Set to Paint: Animation (Ctrl+Shift+Alt+Insert) |
| Cels | Set Cels to Track (Ctrl+Shift+Alt+PageUp) |
| Paint Check Layer | A: Ctrl+Shift+Alt+End / B: Delete Paint Checker |
| Paint Check Image | A: Ctrl+Shift+Alt+Home / B: Delete Paint Checker |
| Deselect | Deselect (Ctrl+D) |
| Invert | Inverse selection (Ctrl+Shift+I) |
| Isolate | Isolate layer (Ctrl+Shift+Alt+Q) |
| Draft | Toggle draft layers visibility (Ctrl+Shift+Alt+') |
| Vector | Vector paths (Ctrl+Shift+Alt+[) |
| Open / Close | Open folder / Close all folder (Ctrl+Shift+Alt+= / -) |
| H/V | Toggle horizontal/vertical layout |

### Layer Shortcuts

| Key | Action |
| --- | --- |
| Shift+1~0 | New layer: Black, Red, Blue, Green, Pink, Cyan, Orange, Uranuri/Shadow, Paint, Rough |
| Alt+1~9 / 0 | New: Paper, Raster, Vector, Colored Vector, Dummy, Separate Black, Pink/Cyan/Orange Vector, Folder |
| Ctrl+Shift+1 | Set layer keyframe color |
| Ctrl+Shift+2 | Set layer reference color |
| Ctrl+Shift+3 | Remove layer color |
| Ctrl+Shift+4 | Change LT Image 1/3 Half Color |
| Ctrl+Shift+5 | Normal Color |
| Ctrl+Shift+6 | Layer Color Black |
| Ctrl+Shift+7 | Change Paper Color Purple |
| Ctrl+Shift+8 | Change Paper Color Green |
| Ctrl+Shift+9 | Change Paper Color White |
| Ctrl+F1 | Toggle tool GUIs |

### Quick Actions

| Key | Action |
| --- | --- |
| Shift+B | Opacity 100 |
| Alt+B | Opacity 50 |
| Ctrl+Alt+B | Opacity 25 |
| Ctrl+B | Toggle layer color |
| Alt+W | Toggle onion skin |
| Alt+V | Toggle layer visibility |
| X | Swap brush primary/secondary |
| Alt+C | Toggle brush transparent |
| Shift+C | Reset color |
| Ctrl+Alt+Shift+X | Delete layer |
| Ctrl+Shift+X | Delete cel from timeline |
| Shift+X | Delete cel from lighttable |
| Alt+; | Transfer down vector + rasterize |
| Ctrl+Alt+Shift+R | Transfer down vector |
| Ctrl+Alt+Shift+E | Merge down layer |
| Ctrl+Alt+Shift+T | Change color expression to gray |
| Alt+Shift+Z | Move layer up |
| Alt+Shift+X | Move layer down |
| [ | Go to top layer |
| ] | Go to bottom layer |
| Ctrl+Alt+Shift+D | Duplicate layer |
| Ctrl+Alt+Shift+G | Create folder and insert layer |
| Ctrl+Alt+G | Ungroup layer folder |
| Alt+A | Select previous cel (resets active LT first) |
| Alt+D | Select next cel (resets active LT first) |

### Link Launcher

| Link | Action |
| --- | --- |
| Worktime | Worktime reset |
| Canvas | Canvas properties |
| Timeline | Timeline tool |
| Change Canvas Size | Change canvas size |
| Sheets | Add/open your Google Sheets link |
| Drive | Add/open your Google Drive link |
| Search | Search Nastarixa Script repositories |

Empty URL/path buttons open an add-target popup first.

### IB GUI Toggle Buttons

| Button | Toggles |
| --- | --- |
| Hand (orange) | Navigation |
| Caps (blue) | CapsLock Mod |
| Reset (purple) | Reset stuck modifier keys |

When ON, stale Ctrl/Shift/Alt/Win states auto-release after the physical key is already up. Each glows its own color when ON, dark OFF.

### Reset Stuck Keys (toggleable)

| Key | Action |
| --- | --- |
| Ctrl+Alt+Shift+Backspace | Release all held modifiers |
| Reset button / Ctrl+F8 | Toggle reset hotkey ON/OFF |
