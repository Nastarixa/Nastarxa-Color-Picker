# CSP Animator Toolkit — Tutorial

A step-by-step guide to every feature in the Nastarxa CSP Animator Toolkit.

---

## Table of Contents

1. [Installation & First Run](#installation--first-run)
2. [Main GUI](#main-gui)
3. [IB GUI (InBetween Bar)](#ib-gui-inbetween-bar)
4. [Link GUI](#link-gui)
5. [Color GUI](#color-gui)
6. [Pie Menu](#pie-menu)
7. [Quick Pie Hotkeys](#quick-pie-hotkeys)
8. [CapsLock System](#capslock-system)
9. [Tab Combos](#tab-combos)
10. [Light Table & Onion Skin](#light-table--onion-skin)
11. [Modes](#modes)
12. [Hotkey Settings](#hotkey-settings)
13. [System Settings](#system-settings)
14. [Feature Switcher](#feature-switcher)
15. [Timer & Stopwatch](#timer--stopwatch)
16. [Color History](#color-history)
17. [Guide Centre](#guide-centre)
18. [Preset Import / Export](#preset-import--export)
19. [ Troubleshooting](#troubleshooting)

---

## Installation & First Run

### Requirements

- **Windows** with AutoHotkey v2.0+ installed
- **Clip Studio Paint** 5.0.4 or newer (recommended)
- CSP Auto Action presets: `Animation_autoaction.laf` (required) and `Nastar.laf` (recommended)

### Steps

1. Download and extract the toolkit folder.
2. Double-click `Nastarxa_CSP_Animator_Toolkit.ahk` to run.
3. The **First Run Wizard** opens automatically on first launch.
4. Follow the checklist:
   - Verify CSP Auto Action presets are installed in CSP.
   - Set up CSP keyboard shortcuts as shown in the wizard.
   - Calibrate Light Table detection (System Settings).
5. Click the **HK** button on the Main GUI to enable custom shortcuts.

> **Tip:** Keep HK OFF until setup is complete. Custom shortcuts are paused on first launch.

---

## Main GUI

The Main GUI is your control center. Open it with `Alt+F1`.

### Buttons

| Button | Action |
|--------|--------|
| **Guide** | Opens the full toolkit guide |
| **K** | Opens Hotkey Settings |
| **Gear** | Opens System Settings |
| **Pie Oven** | Opens pie menu editor |
| **Link** | Opens Link Button Manager |
| **Color** | Opens Color Palette GUI |
| **IB** | Opens InBetween Bar |
| **Reset** | Reset GUI positions to a monitor |
| **HK** | Pause / resume all custom shortcuts |
| **Pie** | Open a hover-activated pie menu |
| **Pie Set** | Edit pie labels, actions, colors |
| **Status** | Check HK, LT, requirements, conflicts |
| **Debug** | View activity log |
| **Dev** | Release tools (developer) |

### Right-click

Right-click the Main GUI for quick access to: Opacity, Debug Log, Backup/Restore, and Pie Oven.

---

## IB GUI (InBetween Bar)

The InBetween Bar provides visual ratio presets for inbetween frame work in the animation timeline.

### How to Open

- Click the **IB** button on the Main GUI
- Default hotkey: `Ctrl+1` through `Ctrl+0` for direct ratio presets

### What It Does

- Shows a horizontal bar with preset inbetween ratios (e.g., 25%, 50%, 75%)
- Click a preset to apply that ratio to the current inbetween
- The bar sits at the top of your screen in a compact, always-on-top strip

### Tips

- The IB bar position is saved per monitor and restored on launch
- Adjust opacity in the Opacity slider (right-click Main GUI)
- Disable via the Feature Switcher if you don't use inbetweening

---

## Link GUI

The Link GUI is a button bar that opens your saved links, scripts, and files from one row of buttons.

### How to Open

- Click the **Link** button on the Main GUI
- Default hotkey: toggle via Main GUI

### What It Does

- Displays a row of labeled buttons
- Each button can open: a URL, a file, a folder, or run a toolkit function
- Buttons are customizable: add, remove, reorder, change colors and labels

### Managing Links

1. Open the **Link Button Manager** (click **Link** on Main GUI or use the context menu)
2. **Add** a new button: click "New", fill in Label, Action (URL/path/function), and Color
3. **Edit** an existing button: click it in the list, change fields, click Save
4. **Reorder**: drag buttons up/down in the list
5. **Delete**: select a button and click Remove

### Button Actions

| Type | Example | What Happens |
|------|---------|--------------|
| URL | `https://google.com` | Opens in default browser |
| File path | `C:\Documents\notes.txt` | Opens with associated app |
| Folder | `D:\Projects` | Opens in Explorer |
| Function | `ShowCSPGuide` | Runs the toolkit function |

### Keys Guide

Click the **Keys Guide** button in the Link Manager for a reference on AHK key syntax used in button actions.

---

## Color GUI

The Color GUI is a floating color palette with your custom colors, quick paint actions, pickers, and color history.

### How to Open

- Click the **Color** button on the Main GUI
- Toggle visibility from the Main GUI

### What It Does

- Displays a grid of color swatches you define
- Click a swatch to send that color to CSP
- Includes a color picker (pick color from screen)
- Quick paint actions: Deselect, Inverse Selection, and more
- Color history tracks recently used colors

### Managing Colors

1. Open the **Color Manager** (right-click the Color GUI or use the context menu)
2. **Add** a color: click New, enter hex code or use the picker, set a label
3. **Edit**: click an existing color, modify fields, save
4. **Reorder**: drag colors in the list
5. **Delete**: select and remove

### Color Picker

- Click the **Picker** button on the Color GUI
- Move your mouse over CSP and click to sample a color
- The sampled color is added to your palette

### Shortcut Labels

Color GUI labels for shortcut-type items (Deselect, Inverse Sel, etc.) update automatically when you remap hotkeys in Hotkey Settings.

---

## Pie Menu

Pie menus are radial menus that open on a hotkey hold, letting you pick actions by flicking in a direction.

### How to Open

- Hold the pie open hotkey (default: varies per pie)
- Or click **Pie** on the Main GUI

### How Many Pies

- **Pie 1 through Pie 4** — four independent pie menus
- Each pie has up to **8 slots** arranged in a circle
- Each slot can hold: a shortcut, a submenu (opens another pie), or be disabled

### What Each Slot Can Do

| Type | Behavior |
|------|----------|
| **Shortcut** | Sends a key combo to CSP (e.g., Ctrl+Z for Undo) |
| **Submenu** | Opens another pie (Pie 2-4) as a sub-menu |
| **Disabled** | Slot is empty, no action on flick |

### Customizing Pies

1. Open **Pie Oven** (click **Pie Oven** on Main GUI)
2. Select which pie to edit (Pie 1-4)
3. For each slot:
   - **Label**: text shown on the pie slice
   - **Action**: shortcut key combo, function name, or submenu target
   - **Color**: slice background color
   - **Requirement**: optional condition (e.g., only active in Tracing mode)
4. Set the **Open Hotkey** for each pie (the key that opens it)
5. Click **Save**

### Pie Style

In Pie Oven, choose the visual style:
- **Normal** — standard radial layout
- **Left** — left-aligned (for right-hand use)
- **Right** — right-aligned (for left-hand use)

### Sub-Pies

Sub-pies let you nest one pie inside another. Set a slot's action type to "Submenu" and choose which pie opens. Sub-pies can go up to 3 levels deep.

---

## Quick Pie Hotkeys

Quick Pie Hotkeys are extra per-slot hotkeys bound directly to actions, without opening the pie menu.

### How They Work

- Each pie slot can have an optional **Quick Hotkey** — a keyboard shortcut that triggers the same action as flicking that slot
- Quick hotkeys fire instantly without opening the pie GUI
- Useful for actions you use very frequently

### Setting Up

1. Open **Pie Oven**
2. Click **Pie Quick** button (or open Quick Pie Hotkeys from the pie menu)
3. For each slot, set a **Quick Hotkey** key combo
4. Save

### Example

- Pie 1, Slot 1 = Undo (Ctrl+Z)
- Quick Hotkey for Slot 1 = `F1`
- Now pressing `F1` fires Undo without opening the pie

### Quick Pie Presets

- Built-in presets ship with the toolkit
- Import/Export via the Preset Wizard (Share Presets button)
- Presets are per-mode — each mode can have different quick pie layouts

---

## CapsLock System

The CapsLock system repurposes CapsLock as a modifier key for painting tools and actions.

### How It Works

1. **Hold CapsLock** past the threshold (default 80ms)
2. The toolkit sends `Ctrl+Shift+Alt` modifiers to CSP
3. Press a key while holding — CSP sees `Ctrl+Shift+Alt+<key>`
4. Release CapsLock — modifiers release, normal typing resumes

### CapsLock Slots

While CapsLock is held, pressing **1-0** or **backtick** can trigger custom actions:

- Configure slots in **System Settings** → CapsLock section
- Each slot can run a function, send keys, or open a pie
- Slots are checked BEFORE the hold threshold — configured slots consume the keypress

### CapsLock vs Regular Hotkeys

| Feature | Regular Hotkey | CapsLock Hold |
|---------|---------------|---------------|
| Fires on | Single keypress | Key while CapsLock held |
| Modifiers | Part of the shortcut | Auto-sent by toolkit |
| Use case | Toggle actions | Painting tool combos |

### Adjusting Hold Threshold

- Open **System Settings** → CapsLock section
- Adjust the hold threshold slider (20-500ms, default 80ms)
- Lower = faster activation, higher = less accidental triggers

---

## Tab Combos

Tab Combos let you hold Tab and press a key to trigger tools and actions.

### How to Use

1. **Hold Tab**
2. Press a key (1-0, backtick, or letter keys)
3. The toolkit sends the corresponding action to CSP
4. Release Tab to return to normal

### Configuration

- Tab Combos are configured in **Hotkey Settings**
- Each combo can be: a shortcut, a function call, or disabled
- The Tab key itself sends `{Tab}` to CSP when pressed normally (not held)

### CapsLock + Tab

When both CapsLock and Tab are held, CapsLock slot actions take priority.

---

## Light Table & Onion Skin

Light Table (LT) and Onion Skin are CSP features for viewing multiple frames simultaneously.

### Toggle Hotkeys

| Action | Default Hotkey |
|--------|---------------|
| Toggle Onion Skin | `Alt+W` |
| Toggle Light Table | `Ctrl+Alt+W` |

### LT Lock

LT Lock keeps the Light Table state locked so it doesn't change when switching frames. Toggle it from the Main GUI or Hotkey Settings.

### LT Settings

Open **System Settings** → Light Table section to configure:
- Detection pixel coordinates (for auto-detecting LT state)
- Click coordinates (for toggling LT via automation)
- Calibrate these to your monitor and CSP layout

---

## Modes

Modes let you have different hotkey layouts for different workflows.

### Built-in Modes

| Mode | Purpose |
|------|---------|
| **Default** | Standard CSP shortcuts, no toolkit overrides |
| **Tracing** | Light Table tracing workflow — swapped A/D keys, onion skin shortcuts |
| **Animate** | Animation-focused — same A/D swap, full pie menus |
| **Painting** | Drawing-focused — brush shortcuts, color tools |
| **Setup** | Configuration mode — extra keys for setup tasks |

### Switching Modes

- Use the **Select Mode** panel (click mode name on IB bar)
- Or configure a mode-switch hotkey in Hotkey Settings
- Each mode remembers its own: hotkeys, pie menus, color items, link buttons

### Per-Mode Settings

Each mode has independent settings files:
- `hotkey_settings.ini` — custom hotkey overrides
- `pie_settings.ini` — pie menu layouts
- `color_settings.ini` — color palette
- `link_settings.ini` — link button list

### Mode Colors

Each mode can have a custom color shown on the IB drag separator. Set it in the Mode Editor.

### Reset Mode

To reset a mode's hotkeys to defaults:
1. Open Hotkey Settings
2. Click **Reset Sel** (selected hotkey) or **Reset All** (entire mode)
3. The mode reverts to its compiled defaults

---

## Hotkey Settings

The Hotkey Settings manager lets you browse, edit, disable, and add hotkeys.

### How to Open

- Click **K** on the Main GUI
- Default hotkey: varies

### What You Can Do

| Action | How |
|--------|-----|
| **Browse** | Scroll the list of all hotkeys |
| **Search** | Type in the search box to filter |
| **Edit** | Click a hotkey, change the key combo |
| **Disable** | Set key to `-` (minus) to disable |
| **Add** | Create new custom hotkeys |
| **Import/Export** | Share hotkey profiles between installations |

### Recording a New Key

1. Click the key field for a hotkey
2. Click **Record**
3. Press your desired key combination
4. The captured keys appear in the field
5. Click **Apply** to save

### Keyboard Shortcut Reference

Click the **?** button for a quick reference of AHK key notation.

### Import / Export

- **Export**: saves your hotkey profile to a file
- **Import**: loads a hotkey profile from a file
- Use the **Share Presets** button on Main GUI for a guided wizard

---

## System Settings

System Settings covers calibration, presets, auto-save, and advanced options.

### How to Open

- Click the **Gear** button on the Main GUI

### Light Table Calibration

- **Detection Pixel**: coordinates where CSP shows LT state
- **Click Coordinates**: where to click to toggle LT
- Use the calibration tools in System Settings to set these

### Auto Save

- Enable auto-save to protect your work
- Configurable interval
- Saves CSP's current document periodically

### CapsLock / Tab Hold

- Adjust the hold threshold (20-500ms)
- Configure CapsLock slot actions
- Enable/disable CapsLock and Tab systems

### Presets

- Manage CSP Auto Action presets
- Import/export preset configurations

### Coordinate Tools

- Detection pixel picker
- Click coordinate picker
- These tools help you calibrate for your specific monitor setup

---

## Feature Switcher

The Feature Switcher provides master on/off switches for major toolkit features.

### How to Open

- Click the **Feature** button on the Main GUI

### What It Controls

| Feature | Default | What It Disables |
|---------|---------|-----------------|
| Color GUI | ON | Color palette window |
| Link GUI | ON | Link launcher bar |
| IB GUI | ON | InBetween bar |
| Pie Menu | ON | All pie menus and sub-menus |
| CapsLock | ON | CapsLock modifier system |
| Tab Combos | ON | Tab hold combos |
| User Scripts | ON | User Scripts library |
| Pie Quick Hotkeys | ON | Quick pie keyboard shortcuts |
| Hotkey Cheat Sheet | ON | Cheat sheet overlay |
| Auto Mode Switch | OFF | Automatic mode switching |
| Guide Notifications | ON | Guide notification popups |
| Apply Block | ON | Keyboard shortcut interception |

### How It Works

- Toggling a feature OFF blocks its shortcut/show path
- The feature still exists in code but cannot be triggered
- Changes take effect immediately
- Switches are **universal** — shared across all modes

### Info Window

Click **Info** in the Feature Switcher for a detailed description of every switch.

---

## Timer & Stopwatch

A built-in timer with stopwatch and countdown modes.

### Hotkeys

| Action | Hotkey |
|--------|--------|
| Start / Pause | `Ctrl+Alt+Shift+4` |
| Stop | `Ctrl+Alt+Shift+2` |
| Lap | `Ctrl+Alt+Shift+3` |
| Countdown | `Ctrl+Alt+Shift+5` |
| Save | `Ctrl+Alt+Shift+1` |

### Stopwatch Mode

1. Press `Ctrl+Alt+Shift+4` to start
2. Press again to pause
3. Press `Ctrl+Alt+Shift+3` to record a lap time
4. Press `Ctrl+Alt+Shift+2` to stop and reset

### Countdown Mode

1. Press `Ctrl+Alt+Shift+5`
2. Enter minutes and seconds
3. Timer counts down and alarms when time's up
4. Notification and beep sound on completion

### Use Cases

- Time your animation sessions
- Track how long specific tasks take
- Set countdown timers for focused work periods

---

## Color History

Color History tracks your recently used colors for quick access.

### How to Open

- Right-click the Color GUI → Color History
- Or call `ShowColorHistory()` from a hotkey or link button

### What It Shows

- A list of recently used colors with hex codes
- Click a color to re-use it
- Colors are saved across sessions

---

## Guide Centre

The Guide Centre is a central hub for all help pages and guides.

### How to Open

- Click **Guide Centre** on the Main GUI (green button)

### What's Inside

**Guides & Wizards:**
- Full Toolkit Guide — comprehensive reference
- Recommended Shortcuts — CSP shortcut setup guide
- First Run Wizard — step-by-step setup checklist
- Modes Guide — how modes work

**Guide Notifications (Popups):**
- InBetween — quick guide for inbetweening
- Create New Layers — layer creation shortcuts
- Keyboard Shortcuts — shortcut reference
- AutoAction / Utility — CSP auto actions
- Animation — animation workflow tips

**Help Pages:**
- System Settings Help — calibration guidance
- Hotkey Settings Help — how to use the hotkey manager
- User Function (Metadata) Guide — writing user function scripts
- AHK Function (Script) Guide — AHK function field reference
- Keys Guide — AHK key syntax reference

---

## Preset Import / Export

Share your configuration between installations or back it up.

### How to Open

- Click **Share Presets** on the Main GUI (purple button)

### What You Can Share

- Hotkey profiles
- Pie menu layouts
- Color palettes
- Link button lists
- Feature switch states
- IB colors

### Export

1. Click **Share Presets**
2. Select which categories to export
3. Choose a save location
4. A single `.ini` bundle file is created

### Import

1. Click **Share Presets** → Import
2. Select the bundle file
3. Choose which categories to import
4. Existing files are backed up before overwrite

---

## Troubleshooting

### Shortcuts Not Working

1. Check the **HK** button — is it ON (green)?
2. Check the **Status Dashboard** — any conflicts or errors?
3. Verify CSP is the active window (most hotkeys require CSP)
4. Check the Feature Switcher — is the feature enabled?

### Light Table Detection Fails

1. Open **System Settings** → Light Table
2. Recalibrate Detection Pixel and Click Coordinates
3. Make sure CSP's Light Table tool is visible on screen

### Pie Menu Doesn't Open

1. Check the Feature Switcher — is Pie Menu enabled?
2. Verify the open hotkey in Pie Oven
3. Make sure no other app is intercepting the key

### GUIs Off-Screen

1. Click **Reset** on the Main GUI
2. Select the correct monitor
3. GUIs reposition to the selected monitor

### CapsLock Types Uppercase

The CapsLock system uses CapsLock as a modifier, not for typing. If you see uppercase letters:
1. Make sure CapsLock hold threshold is high enough
2. Check that CapsLock slot actions are configured correctly

### Mode Switch Not Working

1. Check Hotkey Settings for the mode-switch hotkey
2. Verify the mode exists in the Mode Editor
3. Try Reset Sel / Reset All to restore defaults

---

## Quick Reference

### Default Hotkeys

| Action | Hotkey |
|--------|--------|
| Main GUI | `Alt+F1` |
| Toggle Onion Skin | `Alt+W` |
| Toggle Light Table | `Ctrl+Alt+W` |
| Timer Start/Pause | `Ctrl+Alt+Shift+4` |
| Timer Stop | `Ctrl+Alt+Shift+2` |
| Timer Lap | `Ctrl+Alt+Shift+3` |
| Timer Countdown | `Ctrl+Alt+Shift+5` |
| Hotkey Cheat Sheet | `Ctrl+Shift+F2` |
| Show Debug Log | `Ctrl+Alt+F12` |

### File Locations

| File | Purpose |
|------|---------|
| `settings/gui_settings.ini` | GUI positions, system prefs (universal) |
| `settings/feature_switches.ini` | Feature on/off toggles (universal) |
| `settings/hotkey_settings.ini` | Default mode hotkeys |
| `settings/pie_settings.ini` | Default mode pie menus |
| `settings/color_settings.ini` | Default mode colors |
| `settings/link_settings.ini` | Default mode links |
| `settings/modes/<mode_id>/` | Per-mode settings folders |

### Getting Help

- Open the **Guide Centre** from the Main GUI
- Press `Ctrl+Shift+F2` for the Hotkey Cheat Sheet
- Check the **Status Dashboard** for diagnostics
- View the **Debug Log** for activity tracing
