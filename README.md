# 🖌️ Nastarxa CSP Animator Toolkit

> 🎞️ Animation workflow toolkit for Clip Studio Paint.

Automate repetitive animation tasks, streamline Light Table workflows, and speed up production with custom hotkeys and animation utilities.

![Version](https://img.shields.io/badge/version-2.2.2-blue)
![Platform](https://img.shields.io/badge/platform-Windows-lightgrey)
![Language](https://img.shields.io/badge/language-AutoHotkey_v2-green)

---

## Release Notes

See [CHANGELOG.md](CHANGELOG.md) for version history.

---

## Known Issues

* Ahk2Exe builds require AutoHotkey v2 and `Ahk2Exe.exe` to be installed under `C:\Program Files\AutoHotkey\Compiler`.
* CSP coordinate-based features still require the user to calibrate Detection Pixel and Click Coordinates on their own monitor/layout.

---

## Features

### 🎬 Animation Workflow

* Inbetween Bar (IB) with visual ratio presets
* Light Table automation and LT Lock
* Onion Skin shortcuts
* Timeline navigation tools
* Auto Save while working
* Timer / Stopwatch with Countdown and Pomodoro modes (double-click the timer bar to open the dialog)

### 🎨 Drawing & Layer Tools

* Fast layer creation shortcuts
* Layer color utilities
* Opacity presets
* Merge, transfer, and rasterize operations
* Paint color line tools (Red, Green, Blue, Pink, Cyan, Orange, Purple)
* Screen Color Picker (`Shift+Ctrl+B`) — works outside CSP

### 🔗 Productivity Tools

* Custom Link Launcher with Toggle Layout (horizontal/vertical)
* Color Palette GUI with Toggle Layout (horizontal/vertical)
* Color Picker under cursor
* Timer / Stopwatch with Countdown and Pomodoro modes
* Notification Center for reviewing recent toast notifications (open from Guide Centre)
* Debug Log
* Feature Switcher for universal on/off control of major toolkit features (shared across all modes)
* Hotkey Cheat Sheet overlay (`Ctrl+Shift+F2`) showing the active mode's effective hotkeys and mode-switch keys
* Auto Mode Switch that switches the active mode based on the foreground window
* Preset Import/Export Wizard for sharing hotkeys, pies, colors, links, and settings between installations
* Select Layer Window: remaps Ctrl to Tab+Enter inside CSP's Select Layer dialog

### ⌨ Hotkey Manager

* Edit any shortcut
* Import / Export profiles
* Disable unused shortcuts
* Temporarily pause all custom shortcuts from the Main GUI
* Blocks custom hotkeys while typing in CSP dialogs, including shortcut fields whose title becomes blank by reusing the last non-empty window title
* Per-mode **Apply Block** to intercept and block specific key combinations from reaching CSP (Mode Editor → `Apply Block`)
* In **Tracing**, **Animate**, and **Painting** modes, `A`/`D` and `Alt+A`/`Alt+D` are swapped: bare `A`/`D` select cels, `Alt+A`/`Alt+D` move frames. Default/Setup keep standard CSP layout.
* Typing Title Lists editor (`Edit Lists` in the Typing Safeguard Inspector) to view, add, remove, or reset all three typing title lists (CSP dialogs, toolkit dialogs, CSP non-typing exceptions)
* Hotkey Cheat Sheet overlay (`Ctrl+Shift+F2`) listing the active mode's effective hotkeys and every mode's switch hotkey, with live refresh while open
* Conflict detection with a non-blocking warning after save/apply and a conflict count on the Status Dashboard
* Search and filter

---

## 🖼 Image Preview

![1](docs/images/1.png)
![2](docs/images/2.png)
![3](docs/images/3.png)
![4](docs/images/4.png)
![5](docs/images/5.png)
![6](docs/images/6.png)
![7](docs/images/7.png)
![8](docs/images/8.png)
![9](docs/images/9.png)

---

## Requirements

* AutoHotkey v2.0+
* Clip Studio Paint **5.0.4 or newer** (recommended)
* CSP Auto Action presets:
  - `Animation_autoaction.laf`
  - `Nastar.laf`

---

## Installation

1. Install AutoHotkey v2.
2. Place all files in the same folder.
3. Run `Nastarxa_CSP_Animator_Toolkit.ahk` or `Nastarxa_CSP_Animator_Toolkit.exe`.
4. Settings files will be created automatically inside the `settings` folder.
5. Press `Alt+F1` to open the Main Control window.

---

## Source Layout

The main script is now a small entrypoint with globals, startup order, and `#Include` statements.

Code is organized under `src/`:

* `src/core` - CSP state helpers, light table helpers, notifications, debug log.
* `src/dev` - optional developer/release helpers that can be included or excluded from clean release output.
* `src/docs` - Markdown guide files rendered by the guide wizard (editable live via Reload Guides), recommended shortcut docs, icon references, and runtime documentation assets.
* `src/features` - toolkit commands, system settings, Pie Oven, Timer/Worklog, and feature panels.
* `src/gui` - Main GUI, IB, Color, Link, Pie, Hotkey Settings, Function Browser, hotkey capture, CapsLock slot editor, Pie Quick hotkeys, opacity/scale, hover popup, color info, and window dragging.
* `src/hotkeys` - hotkey definitions, hotkey registration, hotkey requirements, and capture support.
* `src/includes` - helper include files used by generated or user-facing script runners.
* `src/presets` - default presets and callable profile data, such as guide, pie, and UI presets.
* `src/settings` - INI persistence, profile import/export, auto-save interval, backup/restore.
* `src/tools` - small external/runtime tools such as CSP restart monitor.
* `src/vendor` - bundled dependencies, including `Notify.ahk`.

See `src/README.md` for the full module map.

---

## Quick Start

### First Launch

1. Open the Main GUI (`Alt+F1`)
2. On first run, `HK` is `OFF`. Keep custom shortcuts paused until setup is done.
3. **Check CSP AutoAction presets FIRST** — Open CSP's Auto Actions palette and verify these two presets are installed (hotkeys will silently fail without them):
   - `Animation_autoaction.laf` ← REQUIRED
   - `Nastar.laf` ←  Optional (recommended, many features depend on it)
4. Set up CSP shortcuts:

   * Options > Animation cel palette > Enable/disable light table tool = `Ctrl+Shift+Alt+W`
   * Menu commands > Edit > Change Canvas Size = `Ctrl+/`
   * Menu commands > Edit > Canvas Properties = `Ctrl+Shift+Alt+;`
   * Menu commands > Edit > Clear work history > Canvas work time (CSP 4.1+) = `Ctrl+Shift+Alt+\`
   * Menu commands > Animation > Timeline > Change settings = `Shift+Alt+S`
   * Menu commands > Animation > Show animation cels > Check cel motion by key input = `Ctrl+Shift+Alt+1`, `Ctrl+Shift+Alt+2`, `Ctrl+Shift+Alt+3`
   * Auto Actions > Animation_autoaction > `50` = `Ctrl+1`, `33` = `Ctrl+2`, `66` = `Ctrl+3`, `25` = `Ctrl+4`, `75` = `Ctrl+5`, `40` = `Ctrl+6`, `60` = `Ctrl+7`

5. Click `⚙ System Settings` and configure with AHK Window Spy using `Mouse Position: Screen`:

   * Detection Pixel: `Enable/Disable Light Table Tool` in the Animation cels window
   * LT Reset: `Reset position of layers on light table`
   * LT Image 1: `First image of cel-specific light table`
   * LT Image 2: `Third image of cel-specific light table`

   In System Settings, check the boxes under "CSP AutoAction Presets" to confirm which presets you have installed.

6. Click `HK` in the Main GUI to turn custom shortcuts on.

### Nastar Hotkey Highlights

Hotkeys and pie slots can specify a **requirement** field (e.g. `req:"Nastar.laf"`).
When the requirement is unchecked in **System Settings** → **CSP AutoAction Presets**, the hotkey is automatically unregistered and won't fire.
This also disables the matching pie slot actions.

The following shortcuts require the `Nastar.laf` preset checkbox to be enabled:

* `Ctrl+Shift+Alt+G` - Create Folder and Insert Layer
* `Ctrl+Shift+Alt+Q` - Isolate Layer
* `Ctrl+Alt+G` - Ungroup Layer Folder
* `Ctrl+Shift+Alt+D` - Duplicate Layer
* `Alt+D` - Select Next Cel; if Light Table is active, reset LT first and wait until it deactivates
* `Alt+A` - Select Previous Cel; if Light Table is active, reset LT first and wait until it deactivates
* `Ctrl+Alt+D` - When Light Table is active, call `Alt+D` without resetting LT
* `Ctrl+Alt+A` - When Light Table is active, call `Alt+A` without resetting LT
* **Select Lightable Cell** in System Settings toggles mode: 1 = Alt+A/D reset LT first (guard), Ctrl+Alt+A/D bypass reset; 2 = normal CSP behavior, no LT reset
* `Ctrl+Shift+Alt+End` - Paint Check: Layer (A action)
* `Ctrl+Shift+Alt+Home` - Paint Checker: Image (A action)
* `Ctrl+Shift+Alt+Del` - Delete Paint Checker (B action on Paint Check items)

### Main GUI

| Button | Function |
| ------ | -------- |
| `IB` | Show or hide the Inbetween Bar |
| `Link` | Show or hide the Link Launcher |
| `Color` | Show or hide the Color Palette |
| `X` | Hide the Main GUI |
| `?` | Open the Guide, First Run Setup, and Recommended Shortcut helper |
| `⟲` | Reset all toolkit GUI positions |
| `🎨` | Open Color GUI Manager |
| `🔗` | Open Link Button Manager |
| `⚙` | Open System Settings |
| `⌨` | Open Hotkey Settings |
| `GUI` | GUI opacity, UI scale, scroll power, notification toggle, and monitor selector |
| `Debug` | Open Debug Log |
| `HK` / `OFF` | Pause or resume custom shortcuts |
| `Status` | Open Status Dashboard |
| `Safe` | Toggle Safe Mode |
| `Health: OK/SETUP/WARN/GUARD` | Startup Health Badge; click to open Settings Health |
| `Mode: Default` | Open Mode Selector to switch active mode |
| `Pie Oven` | Open Pie Menu, open hotkey, profile, and Sub Pie manager |
| `◉ Feature Switcher` | Master on/off switches that block each feature's activation (shortcut, GUI button, and show path) |

Right-click Main GUI for opacity, pause/resume hotkeys, status, setup validator, broken action scanner, safe mode, pie actions, debug, backup, and restore.

---

## Included Tools

### Inbetween Bar (IB)

Animation helper toolbar with:

* Inbetween presets
* Direction mode toggle: `Start > End` or `End > Start`
* `Start > End` means the smaller number layer is above the edit layer and the bigger number layer is below
* `End > Start` means the bigger number layer is above the edit layer and the smaller number layer is below
* Layer shortcuts
* LT controls
* Auto Save controls
* Active mode indicator on the drag-separator (shows current mode name; double-click to switch modes)
* Timer / Stopwatch with start, pause, stop/reset, lap, save, and load
* Timer shortcuts: `Ctrl+Alt+F5` start/pause toggle, `Ctrl+Alt+F6` lap, `Ctrl+Alt+F7` stop/reset with save prompt, `Ctrl+Alt+F8` save
* Timer PNG saves also create a same-name TXT sidecar so the timer can be loaded back later; TXT files load directly
* While the timer is running, the stop button changes to `Lap`
* Save Timer window lets you edit lap names before saving; defaults are `Lap 1`, `Lap 2`, `Lap 3`, and so on
* Timer TXT and PNG saves include all laps
* Right-click for opacity / context menu

### Color Palette

Dynamic toolbar driven by the **ColorItems** array (persisted per mode in `settings/<mode_id>/color_settings.ini`; legacy `[ColorItems]` data in the global `gui_settings.ini` is migrated automatically on first load).

Default items include:

Note: icon glyphs are decorative and may vary by font/encoding; the real behavior is stored in each item's type/action fields.

* Fill colors (Paper, Main, Sub, Paint, Transparent)
* Paint color lines: Red, Green, Blue, Pink, Cyan, Orange, Purple
* Utilities: Deselect (`⊘`), Inverse Selection (`⇄`), Isolate Layer (`◎`), Toggle Draft (`👁`), Vector Paths (`🖌`)
* Folder tools: Open Folder (`📂`), Close All Folders (`📁`)
* Layout toggle (`🔁`) to switch horizontal/vertical
* Color Info picker with Follow cursor / Draggable mode
* Color Info middle-click copy can output HEX without `#` or RGB text, depending on System Settings
* Middle-click clipboard picker with HEX / RGB output
* Color History dialog (up to 20 recent picks, persists across restarts, select entry + copy HEX or RGB)
* Right-click for opacity / context menu

Each item has a **type** that determines its behavior (see Type System below).
Open the **Color Manager** (`🎨` Main GUI button or right-click Color Palette) to:

* **Add** new items (opens ColorItem dialog)
* **Edit** existing items (double-click or select + Edit)
* **Remove** items (multi-select supported)
* **Reorder** with ▲Up / ▼Down buttons
* **Toggle ON/OFF** — sets type to `disabled` (keeps original type stored in `_origType`)
* **Reset All** — restore factory defaults
* **Save** / **Apply** / **Close**

Color items can also be marked as a **toggle button**. Toggle buttons alternate between Action A and Action B, and support shortcut, function, URL, and script item types.
Right-click a Color GUI button to use **Test Action A** or **Test Action B** without changing the saved button.

### Link Launcher

Custom button toolbar using the same type system as the Color Palette.
Current default Link Launcher buttons:

* `Worktime` - reset worktime
* `Canvas` - open Canvas Properties
* `Timeline` - open Timeline settings/tool
* `Change Canvas Size` - change canvas size
* `Sheets` - add/open your Google Sheets link; empty target opens an add-link popup first
* `Drive` - add/open your Google Drive link; empty target opens an add-link popup first
* `Search` - open Nastarixa repositories: `https://github.com/Nastarixa?tab=repositories`

Open the **Link Button Manager** (`🔗` Main GUI button or right-click Link Launcher) to:

* **Add** / **Edit** / **Remove** buttons
* **Reorder** with ▲Up / ▼Down
* **Toggle ON/OFF** — sets type to `disabled`
* **Reset All** — restore defaults
* Per-button icon bold toggle
* Right-click for opacity / context menu

Link buttons can also be marked as a **toggle button**. Toggle buttons alternate between Action A and Action B, and support shortcut, function, URL, and script item types.
Right-click a Link GUI button to use **Test Action A** or **Test Action B** without changing the saved button.

### Pie Menu

Blender-style quick menu centered on the cursor.

* Opens from the Main GUI `Pie N` button or the hotkey configured in Pie Oven
* Pressing the same pie hotkey again closes the currently open pie
* Holds its position so you can move the cursor toward a slot
* Hovering an enabled slot runs its AHK function, shortcut, URL, script, or submenu after the configured hover delay
* Default hover delay is `65ms`; submenu hover delay is automatically 20% faster
* Clicking an enabled slot runs it immediately
* While a pie is open, press `1`-`0` to activate slots 1-10 without hovering; these temporary keys are disabled when the pie closes
* Pie Quick Hotkeys can be edited from Hotkey Settings > Quick Pie; they only run while a pie is open and can be scoped to Pie 1, Pie 2, Pie 3, Pie 4, or all pies
* Pie Quick Presets are available from Hotkey Settings > Quick Pie > Presets and save to `settings\pie_quick_presets`
* Loading a Pie Quick Preset adds missing entries to the current list; it does not replace existing quick hotkeys
* Use `Save as Preset` in Pie Quick Hotkeys to save the current quick list as a reusable preset
* Clicking the center box or any empty/outside area closes the pie without running a slot
* `Pie N Set` edits label, type, action text, requirement, color, and enabled state
* `Preview` in `Pie N Set` opens a safe visual-only preview of the current pie layout
* Function actions accept either `FunctionName` or `FunctionName()` notation
* Function Picker now opens the Function Browser, so every `Pick` button can search, filter by source, test, copy, preview, or insert a callable function directly into the current field
* Function Browser opens from Hotkey Settings and shows built-in, hotkey-linked, and user-script callable functions with source categories, colored category legend/filter, summaries, usage preview, direct insert support, a `Used by` panel showing where the selected function is assigned, and `Jump...` to open the related editor when that function is already in use
* Pie Oven controls how many pie menus exist, each pie menu's name, each open hotkey, hover delay, center deadzone, layout style, profile import/export, and Sub Pie management
* Pie Oven row `Save`, row `Test`, Sub Pie `Preview`, and Sub Pie `Test` all use the current visible `Delay`, `Dead`, and `Style` values so style changes do not get written back to old values by accident
* Pie layout styles: `Normal`, `Left`, and `Right`; Left/Right curve all slot boxes around one side and hide slot names
* Pie profiles can be exported/imported from Pie Oven without changing other toolkit settings
* Default open hotkeys: Pie 1 `Tab`, Pie 2 `Shift+Tab`, Pie 3 `Ctrl+Tab`, Pie 4 `Ctrl+Shift+Tab`
* Pie 1 defaults to named layer functions that perform `Shift+1` through `Shift+0`
* Pie 1 layer order: `Shift+1` Black, `Shift+2` Red, `Shift+3` Blue, `Shift+4` Green, `Shift+5` Pink, `Shift+6` Cyan, `Shift+7` Orange, `Shift+8` Uranuri / Shadow, `Shift+9` Paint, `Shift+0` Rough
* Pie 2 defaults to named Create functions that perform: `Alt+1` New Paper Layer, `Alt+2` New Raster Layer, `Alt+3` New Vector Layer, `Alt+4` New Colored Vector Layer, `Alt+5` New Dummy Layer, `Alt+6` Separate Black Line + Paint, `Alt+7` New Pink Vector Layer, `Alt+8` New Cyan Vector Layer, `Alt+9` New Orange Vector Layer, `Alt+0` New Animation Folder
* Pie 3 defaults to named Utility functions that perform: `Ctrl+Shift+1` Set as Keyframe Color, `Ctrl+Shift+2` Set as Reference Color, `Ctrl+Shift+3` Remove Keyframe Color, `Ctrl+Shift+=` Change LT Color to Half Color Green, `Ctrl+Shift+-` Change LT Color to Half Color Purple, `Ctrl+Shift+5` Change LT Color to Normal, `Ctrl+Shift+7` Change Paper Color Purple, `Ctrl+Shift+8` Change Paper Color Green, `Ctrl+Shift+9` Change Paper Color White, `Ctrl+Shift+6` Layer Color Black
* Pie 4 defaults to a Guide / layer navigation hub using named functions: Guide submenu, Hotkeys, Layer Up, Layer Down, Layer Above `[`, Layer Below `]`, Status, System, Safe Mode, and Show MainGUI
* Slot type `submenu` opens a separate Sub Pie; use Pie Oven > Sub Pie Set to add, edit, or remove Sub Pies
* Slot type `nav` provides `back` (navigate to previous pie) and `close` (close current pie) actions
* Pie Oven includes a sub-pie navigation bar (◀ dropdown ▶ Preview Test) to browse and test sub-pies, plus a Delete Sub button
* Press `Esc` while the pie is open to close it without running a slot

### Feature Switcher

Master on/off switches that block each feature's activation path instead of just hiding the UI:

* Open from the Main GUI `◉ Feature Switcher` button
* `Info` opens the Feature Switcher Info window describing every switchable feature with its default and current state (refreshable)
* Toggling a feature **OFF** unregisters its shortcuts and blocks every show path — pie slots, quick pie, CapsLock slots, and the user-script hotkey are all gated while the switch is off
* Covers: Color GUI, Link GUI, IB GUI, Pie Menu, CapsLock combos, Tab combos, User Scripts, Pie Quick Hotkeys, Hotkey Cheat Sheet, and Auto Mode Switch
* Switching takes effect immediately: hotkeys are re-registered, hidden GUIs stay hidden, an open pie closes, the Main GUI buttons update, and a popup notification confirms the change
* `Enable All` / `Disable All` reset every switch at once
* Switches are universal: `settings\feature_switches.ini` (shared across all modes)
* Editing `feature_switches.ini` externally is detected and applied exactly like an in-GUI toggle

### Apply Block

Per-mode key interception: block specific keyboard shortcuts from reaching CSP when the toolkit is active in that mode.

* Open from any mode's **Mode Editor** → `Apply Block` button
* **Add** captures a key combination via keyboard; **Delete** removes the selected key; **Toggle Scope** switches between `target` (CSP window only) and `global` (always intercepted)
* Tracing and Animate modes ship with Ctrl+backtick, Ctrl+2–0, and Ctrl+Shift+1–3 blocked by default (same keys the old feature-switch `blocknum` used to intercept)
* Default, Setup, and Painting modes start with an empty block list
* Apply Block keys are registered before normal hotkey groups so they take precedence
* Blocked keys are intercepted by a no-op sink — CSP never sees the keypress while the toolkit is active under the key's scope
* Settings persist per-mode in `[ApplyBlock]` sections of `settings/<mode_id>/hotkey_settings.ini` (or the base `settings/hotkey_settings.ini` for Default mode)

### Type System

Color Palette and Link Launcher items use a shared type system.
Each item has a **type** field that controls what happens when clicked:

| Type | Behavior | Required Fields |
|------|----------|-----------------|
| `shortcut` | Sends keystrokes (`keys` + optional `extra`) to CSP | `keys` |
| `function` | Calls an AHK function by name. Pie slots use the pie runner; Color/Link items use the toolkit function runner. | `action` |
| `url` | Opens a URL or file path in default handler | `target` |
| `script` | Runs a `.ahk` or `.exe` file | `target` |
| `sep` | Renders as a visual section header (no action) | `label` |
| `disabled` | Placeholder slot — skipped/not rendered in GUI | (none) |

### Hotkey Settings

Manage every shortcut:

* Edit
* Disable
* Import
* Export
* Reset
* Resolve duplicate hotkey conflicts by disabling the other conflicting shortcut
* Requirement column showing when each hotkey can run
* AHK Function column and editor field for assigning an existing script function
* Function Picker for choosing loaded toolkit functions without typing function names manually
* Includes a "Callable Functions" column (3rd column in User Function Library) showing functions auto-detected by scanning all `.ahk` sources
* User Function Library manager for creating, editing, deleting, and copying paths for scripts in `user_hotkey_scripts`
* Add/Edit User Function includes a `Recorder` helper that builds editable user-script functions from lowercase shortcut steps, delay steps, and `Add Fn` function-call steps picked directly through Function Browser
* The recorder keeps recording manual and safe: it only adds explicit Send, Delay, or Function steps, then inserts the generated script for review before saving
* User-script hotkeys cache their generated runtime wrapper after the first run, reducing repeated trigger latency
* Hotkey profile export/import includes custom hotkeys, function assignments, requirements, and activation flags
* Details view showing the current/default AHK function
* Add new custom hotkeys with action name, hotkey, requirement, AHK function name, and script
* User hotkey scripts are saved outside the main toolkit in `user_hotkey_scripts`
* CSP typing dialogs are guarded so text/shortcut input is not intercepted by custom hotkeys
* Main edit dialogs now support `Apply` without closing for live updates while tuning existing hotkeys, pie quick items, and pie slots

### Validator, Scanner, and Health Popups

These helper popups are available from the Debug Log, Status Dashboard, and Main GUI right-click menu.

* `Validator` checks first-run readiness: settings file, CSP running state, HK pause state, AutoAction preset toggles, LT coordinates, pie count, pie delay, deadzone, style, and pie open hotkeys
* `Scanner` checks broken actions: empty pie actions, missing function names, missing script paths, empty URLs, disabled requirements, missing user hotkey script files, and duplicate hotkeys
* `Conflict` checks duplicate hotkeys, quick-pie collisions, reserved quick-pie keys, and duplicate pie open hotkeys
* `Health` checks settings structure: split settings files, duplicate INI sections/keys, pie config shape, sub-pie data, quick-pie data, link data, and user function/script library folder
* `Doctor` checks settings drift: missing split files, duplicate INI data, stale config version, malformed pie/color data, and likely fallback-to-default causes
* `Typing` opens the Typing Safeguard Inspector, showing active title, preserved title, focused control, and the current `IsTyping()` decision
* `Self-Heal` rebuilds missing split setting files, compacts settings, reloads runtime data, then resaves clean copies
* `Dev` opens release helpers: Release Checklist, Version Check, Preset Hub, Clean Release Folder, Build Release Package, Open Release Folder, optional `src/dev` release inclusion, optional Ahk2Exe build, `CSP_Tools_and_AutoAction_Presets.zip` export, One-Click Release Audit, Preset Tester, Function Doctor, Settings Integrity, and Broken Icon Scanner
* `[OK]` means the item looks ready
* `[FIX]` means that item needs attention in System Settings, Pie Oven, Hotkey Settings, Link Manager, or CSP itself
* Use `Backup` before large cleanup if the current configuration is important

---

## Configuration

Settings are stored in separate INI files inside the `settings` folder for faster save/load and safer backups:

```ini
settings/gui_settings.ini
settings/pie_settings.ini
settings/hotkey_settings.ini
settings/link_settings.ini
```

Main `settings/gui_settings.ini` sections:

```ini
[Settings]
[IB]
[Color]
[Link]
[LT]
[Coords]
[ColorInfo]
[Paths]
[LinkItems]
```

Legacy `[ColorItems]` data in `gui_settings.ini` is migrated into the active mode's `color_settings.ini` on first load and is no longer written to the global file.

Split setting files:
- `pie_settings.ini` - pie menus, sub-pies, pie hotkeys, pie style, pie slot data
- `hotkey_settings.ini` - custom hotkeys, user-added hotkeys, pie quick hotkeys, function assignments, requirements
- `link_settings.ini` - Link GUI button list and editable link button data
- `color_settings.ini` - Color GUI button list and editable color button data

Current behavior: `settings/link_settings.ini` is the primary Link GUI settings file and `settings/color_settings.ini` is the primary Color GUI settings file.

### Modes and Per-Mode Settings

Switching modes (Mode Selector on the Main GUI) applies that mode's own settings for the action-oriented categories. Each custom mode gets a folder under `settings` with one file per per-mode category:

```ini
settings/<mode_id>/pie_settings.ini      # pie menus, sub-pies, pie open hotkeys, style, slot data
settings/<mode_id>/hotkey_settings.ini   # custom hotkeys, pie quick hotkeys, function assignments, requirements
settings/<mode_id>/link_settings.ini     # Link GUI button list and button data
settings/<mode_id>/color_settings.ini    # Color GUI button list and button data
```

The `default` mode uses the base files directly (`settings/pie_settings.ini`, `settings/hotkey_settings.ini`, `settings/link_settings.ini`, `settings/color_settings.ini`). The first time a mode is used, its folder is created from a copy of the base settings so it starts from the current configuration; switching away saves the mode's state back into its folder. Mode definitions, the mode order, and the active-mode marker stay in the base `settings/hotkey_settings.ini` so modes survive restarts.

Each mode can have its own **color** (hex string) shown on the IB drag separator. Set it in the Mode Editor — leave blank for the default blue (`3949AB`). Quick-pick preset buttons (R/G/B/O/V/C/Gr) are available.

The **Manage Modes** dialog includes a **Guide** button (opens the Modes guide) and a **Diff All** button that opens a list of every mode's differences vs Default (hotkey settings plus pie/link/color changes). Selecting a mode and clicking **Diff** (or double-clicking in the overview) shows the full change list.

Global settings are shared by every mode and are never per-mode:

```ini
settings/gui_settings.ini                # system settings, GUI positions, colors, color history, paths
settings/feature_switches.ini            # feature on/off switches (shared across all modes)
settings/pie_quick_presets/              # Pie Quick Preset library
```


Key settings under `[Settings]`:
- `Scale`, `Speed` — UI scale percentage and scroll power
- `IB_Opacity`, `Color_Opacity`, `Link_Opacity` — per-GUI transparency (0–255)
- `NotifyEnabled` — enable/disable on-screen popup notifications (0 or 1)
- `NotifyMonitor` — target monitor for notifications (0 = primary, 1+ = specific monitor)
- `AutoSaveInterval` — seconds between auto-saves
- `HoldThresholdMs` — Shared CapsLock / Tab hold threshold in milliseconds before those combo modes activate. Range: `20-500`, default: `80`
- `TabHoldMode` — (deprecated) Previously controlled Tab hold behavior; Tab now auto-detects which pie uses the Tab hotkey.
- `DebugSaveOnExit` — whether debug log is saved on script exit

Key settings under `[ColorInfo]`:
- `OffsetX`, `OffsetY` — follow-cursor offset. Defaults: `-20`, `50`
- `TickMs` — color info refresh interval in milliseconds. Default: `60`
- `MiddlePick` — middle mouse copies the current color while Color Info is active
- `ClipboardFormat` — clipboard output format. Default: `RGB`; `HEX` copies hex without `#`

---

## Advanced Features

* LT Lock auto-kill
* CSP restart monitor
* GUI opacity controls with live preview and save-only persistence
* Manual UI scale for small monitors
* Adjustable scroll up/down power
* Temporary custom shortcut pause toggle
* CapsLock tap keeps normal CapsLock behavior; CapsLock hold only allows `` ` `` through `=` while held, blocking other keys to prevent accidental Windows/CSP shortcuts
* CapsLock+1-0 can be assigned from Hotkey Settings > CapsLock 1-0; disabled slots keep their saved data but do not run
* CapsLock hold timing is editable in System Settings > Hold Threshold
* Tab tap sends normal Tab; Tab hold opens whichever pie has Tab assigned as its hotkey (auto-detected from Pie Oven settings)
* Reset-key watchdog for stuck Ctrl / Shift / Alt / Win states
* Coordinate Pick buttons in System Settings
* Hotkey Stress Test from System Settings to watch Tab, CapsLock, modifiers, mouse buttons, and number-row key transitions
* Status Dashboard
* CSP Setup Validator from Status Dashboard, Debug Log, or the Main GUI right-click menu
* Broken Action Scanner from Status Dashboard, Debug Log, or the Main GUI right-click menu
* Action Conflict Tester from Status Dashboard or Debug Log
* Hotkey collision warning after save/apply — a non-blocking popup lists the conflicting shortcuts (first 3, with a pointer to the Status Dashboard) whenever two actions share a key in the active mode or two modes share a switch hotkey
* Hotkey Cheat Sheet overlay (`Ctrl+Shift+F2`) — always-on-top dark panel listing the active mode's effective hotkeys grouped by context plus every mode's switch hotkey; refreshes live while open and remembers its position
* Auto Mode Switch — automatically switches the active mode based on the foreground window or active CSP target (feature switch, default OFF)
* Typing Title Lists editor — view, add, remove, and reset the CSP dialog / toolkit dialog / CSP non-typing exception title lists from the Typing Safeguard Inspector's `Edit Lists` button
* Settings Health report from Status Dashboard or Debug Log to check split settings, duplicate INI data, pie configs, quick-pie data, and user script folders
* Config Doctor from Debug Log or Function Browser to diagnose settings drift and fallback-to-default causes
* Typing Safeguard Inspector from Debug Log or Function Browser to diagnose CSP text fields that still allow toolkit hotkeys; its `Edit Lists` button opens the Typing Title Lists editor
* Settings Self-Heal from Status Dashboard, Debug Log, or Settings Health report, with a visible repair progress window
* Safe Mode
* Hotkey Conflict Resolver
* First Run Wizard
* Backup / Restore with timestamped split-settings folders in `settings\settings_backups`
* Backup / Restore also includes `.ahk` files from `user_hotkey_scripts` so user-created hotkey functions can be restored with their settings
* Export JSON / Import JSON use one lightweight config file for selected runtime settings
* Settings Export Bundle creates a portable settings folder under `Documents\Nastarxa_CSP_Settings_Bundles`
* Import Bundle opens a chooser for JSON config or a Settings Export Bundle folder
* Settings Snapshot Before Save creates timestamped `before_save_*` backups before System Settings and Pie Oven writes
* Dev tools from Debug Log create a clean release folder, optionally exclude `src/dev`, open the release folder, check version consistency, create the tools/presets zip, build an EXE with Ahk2Exe, scan for broken icon text, and run release/audit checks before sharing
* `Build Release Package` runs the clean release flow and zips the resulting release folder; the live `settings` folder is intentionally not copied into release output
* Hover tooltips
* Background color picker
* Global hotkeys

---

## 📄 License

MIT
See [LICENSE](/LICENSE).

---

## ⚠️ Third-Party Project Notice

This project is an independent third-party tool and is **not affiliated with, endorsed by, sponsored by, or officially supported by Clip Studio Paint (CELSYS)**.

All trademarks, product names, and copyrights belong to their respective owners.

This toolkit was created by the community to improve animation workflows and automate repetitive tasks through AutoHotkey scripts.

### MIT License Freedom

This project is released under the **MIT License**, which gives you broad freedom to:

* Use the software for personal or commercial projects
* Modify the source code
* Distribute original or modified versions
* Incorporate portions of the code into your own projects
* Learn from, adapt, and extend the implementation
* Share improvements with others

The software is provided **"as is"**, without warranty of any kind. Use it at your own risk.

Always back up your Clip Studio Paint settings and projects before using automation tools.

---

## ⚠️ Disclaimer

This project was developed with the assistance of AI tools.
AI was used to support code writing, refactoring, and documentation, while the design direction, features, and final implementation were guided and reviewed by the author.
