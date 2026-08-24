# Script Writing Rules

Coding conventions and architectural rules for the CSP Animator Toolkit.

---

## Language & Runtime

- **AutoHotkey v2.0 only** — every script starts with `#Requires AutoHotkey v2.0`
- Entry point: `Nastarxa_CSP_Animator_Toolkit.ahk` at repo root
- Single-instance by default (`#SingleInstance`)

---

## Include Order

Vendor modules first, then globals, then feature modules, auto-execute last:

```
1. src\vendor\Notify.ahk          (third-party, always first)
2. Main script globals             (all top-level globals under ; --- banners)
3. #Include src\hotkeys\*          (core → actions → engine → diagnostics)
4. #Include src\gui\*              (main GUI, IB bar, pie, preset wizard, collapsible button list, etc.)
5. #Include src\core\*
6. #Include src\features\*
7. #Include src\settings\*
8. #Include src\tools\*
9. #Include src\dev\*              (optional, can be excluded from release)
10. AUTO-EXECUTE block             (OnMessage, init calls, SetTimer)
```

Startup order inside the auto-execute block is strict. See the main script
for the exact sequence. Each call site documents why it must come where it does.

---

## Module Headers

Every module file starts with a header. Use the appropriate level:

**Standard** (most files):
```
; MODULE TITLE
; ============================================================
```

**Full** (settings/architecture modules):
```
; ============================================================
; Module: src\settings\file.ahk
; ============================================================
; Prose explaining architecture, file layout, and contracts.
```

Split-out modules carry a provenance note:
```
; Extracted from hotkey_core.ahk for modularity.
```

---

## Naming Conventions

| Scope | Pattern | Example |
|-------|---------|---------|
| Public API | `PascalCase` | `HK_ReapplyAll()`, `ShowNotify()` |
| Subsystem prefix | `HK_`, `IB_`, `Pie*`, `Mode*` | `HK_Custom`, `PieHotkeys` |
| Private/internal | `_lowerCamel` | `_capslockModActive`, `_HK_CaptureDlg` |
| Constants | `SCREAMING_SNAKE` | `HOLD_THRESHOLD_MS`, `CONTRAST_THRESHOLD` |
| Feature map keys | lowercase strings | `"colorgui"`, `"guidenotify"` |
| Hotkey IDs | `snake_case` | `toggle_onion`, `select_prev_cel`, `paint_red` |
| Action functions | `VerbNoun*` variadic | `HotkeyToggleOnion(*)`, `HotkeyIB1(*)` |
| Show functions | `Show<Name>()` | `ShowHotkeySettings()`, `ShowPieMenu()` |

---

## Global Variables

- Declare globals at the **top of the owning file** (or main script) under
  `; --- Feature Name ---` banner comments
- Re-declare with `global` inside any function that reads or mutates them
- Maps preferred over arrays for key-value data
- Use sentinel values for disabled state: `HK_FN_DISABLED := "__fn_disabled__"`
- Boolean state flags use `_underscoreCamel`: `_capslockModActive`

---

## Error Handling

- Wrap all external calls in `try`: `DllCall`, `IniRead`, `Hotkey()`, `Integer()`
- Provide explicit fallback returns or sentinel values
- Use `ToolkitSafeInt(value, fallback, min, max)` for integer parsing
- GUI creation wrapped in singleton check: `if IsObject(gui) { gui.Show(); return }`

---

## Hotkey System Rules

### HotkeyDefs Array

Each hotkey is an object in the `HotkeyDefs` array:

```ahk
{id:"toggle_onion", group:"csp", def:"!w", desc:"Toggle Onion Skin", fn:HotkeyToggleOnion}
```

Fields: `id` (snake_case), `group` (csp/csp_nav/csp_caps/csp_reset/global/bg),
`def` (default key), `desc` (display description), `fn` (function reference),
optional: `req` (requirement), `user` (flag for user-defined actions).

### Pipe-Separated Keys

Multiple shortcuts per hotkey use `|` separator:
```ahk
key := "!w|^!w"    ; Alt+W OR Ctrl+Alt+W
```
`HK_SplitKeys()` returns an array. Each key is registered independently.
All keys must be **lowercase** — AHK's `Send` is case-sensitive.

### HotIf Conditions

Hotkeys fire only when their `HotIf` condition is true:

| Condition | Context |
|-----------|---------|
| `HotIfConditionCSP` | CSP window is active |
| `HotIfConditionCapsTabBlock` | CSP active + CapsLock physically held |
| `HotIfConditionPieOpenKey` | Pie menu is open |
| `HotIfConditionGlobal` | Always (no window check) |

Conditions are functions. `HotIf(condFn)` sets the active condition for
subsequent `Hotkey()` calls. Always reset with `HotIf()` after a block.

### $ and ~ Prefixes

- `$` — hotkey fires only from **physical** keypresses, not `Send` commands
- `~` — native keystroke **passes through** to the active window alongside the callback
- No prefix — hotkey fires from both physical and Send-sent keys
- Combined: `~$` = physical only + pass through

### ApplyBlock System

`HK_ApplyBlock` Map blocks specific key combos from reaching CSP:

```ahk
HK_ApplyBlock := Map("^+1", "target", "^2", "target")
```

Registered under `HotIfConditionCSP` with `$` prefix. Empty sink swallows
the keystroke. Toggle with `HK_ApplyBlockSetState(true/false)` — used by
CapsLock hold engine to temporarily disable blocking.

---

## Lowercase Key Rule

**All shortcut keys stored in data files and user input must be lowercase.**

AHK v2 is case-sensitive for letters in `Send`:
- `Send("!w")` = Alt+w
- `Send("!W")` = Alt+Shift+W (uppercase implies Shift)

Enforcement points:
- `HK_NormalizeCapturedKey()` — lowercases single-char keys from capture dialog
- `HK_NormalizeSavedHotkeyValue()` — lowercases entire value before INI write
- `mode_settings.ahk` IniWrite calls — wrap with `StrLower()`
- `hotkey_profiles.ahk` import — uses `HK_NormalizeSavedHotkeyValue()`

Display functions (`HotkeyDisplayKeyName`) uppercase single chars for
**display only** — never stored.

---

## Mode Settings System

### Per-Mode Hotkey Overrides

Each mode has its own `hotkey_settings.ini` under `settings\<mode_id>\`:

```
settings\hotkey_settings.ini          (base / default mode)
settings\modes\tracing\hotkey_settings.ini
settings\modes\animate\hotkey_settings.ini
settings\modes\painting\hotkey_settings.ini
settings\modes\setup\hotkey_settings.ini
```

The default mode uses the base file directly. Other modes clone from base
on first use via `ModeSettingsCopyBaseTo()`.

### Version Seeding

Each category is seeded with a version string. On startup, if the stored
version doesn't match the code version, defaults are re-written:

```ahk
ModeSettingsSeedApplyBlock("tracing", applyBlockVersion)
```

User edits are preserved between versions only if the stored version matches.

### HK_Get Resolution

`HK_Get(id, def)` resolves the active key for a hotkey:
1. Check `HK_Custom[id]` (user override for current mode)
2. Fall back to `HotkeyDefs` compiled `def` value

### Disabled Sentinel: Always `"-"`, Never `""`

**Rule: when a hotkey must be disabled in a mode, set its value to `"-"` (minus), never to `""` (empty string).**

`HK_Get` at `hotkey_core.ahk:769` treats `""` as "not customized" and
falls back to the compiled default. An empty value in the INI is
**invisible** — the hotkey silently re-registers with its default key.

The correct sentinel is `"-"`:

```ahk
; WRONG — hotkey silently falls back to compiled default "!w"
pairs["toggle_onion"] := ""

; CORRECT — hotkey is properly disabled
pairs["toggle_onion"] := "-"
```

This applies everywhere a hotkey value is written:
- Mode settings seeding (`mode_settings.ahk` — `ModeSettingsSeedTracingMode`, etc.)
- Mode defaults file (`src\docs\mode_defaults.ini`)
- GUI disable action (`HK_Custom[d.id] := "-"`)
- Any `IniWrite` that disables a hotkey

**Checklist after changing a mode's hotkey defaults:**
1. Verify the seed code writes `"-"` not `""`
2. Verify the entry exists in `mode_defaults.ini` (used by Reset Sel/All)
3. Bump the seed version string so existing installations re-seed

---

## CapsLock Hold Engine

### How It Works

1. User holds CapsLock past threshold (`HOLD_THRESHOLD_MS = 80ms`)
2. Engine sends `{Ctrl Down}{Shift Down}{Alt Down}` — modifiers held
3. `HK_ApplyBlockSetState(false)` — disables ApplyBlock during hold
4. User presses keys → CSP sees `Ctrl+Shift+Alt+<key>`
5. CapsLock released → modifiers released, ApplyBlock re-enabled

### Two Detection Paths

- `CapslockMod()` — primary, polls in a `while GetKeyState("CapsLock","P")` loop
- `CapslockHoldPoll()` — alternate, timer-driven polling

Both paths must call `HK_ApplyBlockSetState(true)` on **every** exit where
hold was active (6 exit paths total). Missing one leaves ApplyBlock disabled.

### Slot System

CapsLock slots (1-0, backtick) can run custom actions when CapsLock is held.
Slots are checked BEFORE the hold threshold. Configured slots consume the
keypress. Unconfigured slot keys pass through to CSP during hold.

---

## GUI Conventions

### Dark Theme

```ahk
BackColor := "1E1F22"      ; dialog background
Background2A2A2A            ; input fields
Background4CAF50            ; success/confirm
BackgroundE53935            ; error/close
cFFFFFF                     ; primary text
cAAAAAA                     ; secondary text
c888888                     ; hint text
```

### DPI Scaling

All dimensions use `S(n)` scaler:
```ahk
dlg.AddText("xm w" S(207) " h" S(26), "Label")
```

### Singleton GUI Pattern

```ahk
ShowSomething() {
    static sGui := 0
    if IsObject(sGui) {
        sGui.Show()
        return
    }
    sGui := Gui("+AlwaysOnTop +ToolWindow", "Title")
    ; ... build GUI ...
}
```

### Notifications

Use `ShowNotify(title, message)` for user feedback. Bypass throttle
with `Notify.Show(opts)` when needed (e.g., during rapid-fire actions).

---

## Data Access Rules

### Safe Readers (mandatory for numerics)

Always use clamping helpers instead of raw `IniRead` + `Integer()`:

```ahk
val := IniReadIntSafe(file, section, key, default, minVal, maxVal)
val := IniReadFloatSafe(file, section, key, default, minVal, maxVal)
```

These clamp out-of-range values and never throw.

### Bounds-Checked Array Access

Never index arrays raw. Always guard with `.Length` check and fall back
to a default getter:

```ahk
val := PieHotkeys.Length >= idx ? PieHotkeys[idx] : PieDefaultHotkey(idx)
```

### Defensive Map Reads

INI-derived maps always use `.Get(key, default)` + normalization:

```ahk
item := Map()
item["type"] := StrLower(Trim(item.Get("type", "disabled")))
item["color"] := Trim(item.Get("color", "455A64"))
```

### Normalize Before Write

Always normalize stored keys before `IniWrite`:

```ahk
IniWrite(HK_NormalizeSavedHotkeyValue(key), file, sec, id)
IniWrite(PieNormalizeHotkey(hotkey), file, sec, key)
```

---

## Callback Rules

### Variadic `(*)` Required

All functions callable from `Hotkey()`, `OnEvent()`, or GUI events
must accept `(*)` catch-all:

```ahk
HotkeyToggleOnion(*) { ... }       ; OK
ToggleLTLock(*) { ... }            ; OK
MyFunc() { ... }                   ; WRONG — can't be used as callback
```

---

## Diagnostics

### SettingsDiagPush

The primary observability tool. 53+ call sites across the codebase:

```ahk
SettingsDiagPush(level, title, detail)
```

Levels: `OK`, `INFO`, `WARN`, `ERR`, `TRACE`.

Use `ERR` for failures that affect functionality. Use `WARN` for
recoverable issues. Use `INFO` for successful operations.

### DebugLog

Lower-level logging for action tracing:

```ahk
DebugLog("Toggle LT Lock ON")
```

Always end with the state (ON/OFF) for toggles.

---

## Settings Architecture

### External INI Watcher

`SettingsFilesSignature()` builds a `FileGetTime` fingerprint of all
settings files. `CheckIniChanges()` reloads changed categories.

**Rule: any new settings file must be registered in BOTH:**
1. `SettingsFilesSignature()` — add to the fingerprint
2. `CheckIniChanges()` — add to the reload sequence

### Config Versioning

`EnsureConfigVersion()` compares `CONFIG_VERSION` against stored
version. On mismatch, triggers upgrade logic. Self-heal rebuilds
missing/corrupt settings files automatically.

### Mode Settings Retargeting

Mode switching reassigns global path variables so existing
Load*/Save* helpers need no changes:

```ahk
PIE_SETTINGS_FILE := dir "\pie_settings.ini"
HOTKEY_SETTINGS_FILE := dir "\hotkey_settings.ini"
```

Three files are **universal** — they always live in the base settings
folder and are never retargeted per-mode:

| Global | File | Purpose |
|--------|------|---------|
| `SETTINGS_FILE` | `gui_settings.ini` | GUI layout, opacity, scale, system prefs, UI settings |
| `FEATURE_SETTINGS_FILE` | `feature_switches.ini` | Feature on/off toggles |

Everything else (hotkeys, pie, links, colors) is retargeted to
`settings\modes\<mode_id>\` on mode switch. The `default` mode
uses the base files directly.

### Mode-ID Filename Sanitization

```ahk
RegExReplace(id, "[\\/:\*\?`"<>\|]", "_")
StrReplace(name, " ", "_")
```

The `default` mode uses base files directly, no folder.

### Atomic File Writes

Use `AtomicFileWrite(path, content)` for any write that must survive
a crash mid-write. It writes to a `.tmp` sibling then uses `FileMove`
with overwrite. Used by `RepairDuplicateIniSectionsMerge`, preset
wizard, and any settings write that is critical.

```ahk
AtomicFileWrite(path, content)
```

### INI Section Parser

`IniReadSectionMap(file, section)` reads an entire INI section into
a `Map(key => value)`. Use when you need all keys in a section at once
rather than individual `IniRead` calls.

### Lowercase Shortcut Keys

AHK v2 treats uppercase letters as Shift modifier (`!W` = Alt+Shift+W).
All saved and user-input shortcut keys must be stored in **lowercase**.

Enforcement points:
- `HK_NormalizeCapturedKey` — normalizes captured keys to lowercase
- `HK_NormalizeSavedHotkeyValue` — normalizes loaded INI values to lowercase
- `HotkeyDefs` — compiled `def` values use lowercase (`!w`, not `!W`)
- Mode settings seeding — all shortcut values lowercase

Display functions (`HotkeyDisplayName`) still `StrUpper` for UI labels only.

---

## Feature Switcher Rules

### Universal Setting

Feature switches are shared across all modes — they are **not** per-mode.
`FEATURE_SETTINGS_FILE` always points to the base `feature_switches.ini`,
never retargeted by `ModeSettingsRetarget()`.

### Single Source of Truth

All feature metadata lives in one `_FeatureDefs` Map:

```ahk
_FeatureDefs := Map(
    "colorgui", {iniKey:"ColorGUI", label:"Color GUI", on:true, desc:"..."},
    ...
)
```

Accessor functions (`FeatureEnabled`, `FeatureLabel`, `FeatureDefaultOn`, `FeatureSwitchOrder`, `FeatureInfoDescriptions`) all derive from `_FeatureDefs`. `FeatureSwitches` Map is populated from `_FeatureDefs` at load time.

**Rule: never add a separate parallel structure for feature metadata.**

### Block-at-Activation

Feature switches gate the shortcut/show path, not UI visibility.
A disabled feature still exists in code but cannot be triggered.

### Default-Enabled Lookup

```ahk
FeatureSwitches.Get(name, true)  ; unknown features default to enabled
```

---

## Toggle Button Restyle

Standard trio for updating button state:

```ahk
if IsObject(btn) {
    btn.Text := IconUse("🔒", "⊠")
    btn.Opt("Background4CAF50 cFFFFFF")
    btn.Redraw()
}
```

`IconUse(emoji, fallback)` returns the emoji on supported systems,
falls back to ASCII glyph.

---

## Notifications

```ahk
ShowNotify(title, message)                    ; default gray
ShowNotify(title, message, "0x4CAF50")        ; success green
ShowNotify(title, message, "0xE53935")        ; error red
```

Bypass throttle with `Notify.Show(opts)` for rapid-fire actions.

---

## Module Header Dependencies

Some modules list runtime dependencies in the header:

```
; Dependencies (defined elsewhere, resolved at runtime):
;   HK_ReapplyAll -> hotkey_core.ahk
;   ModeSettingsRetarget -> mode_settings.ahk
```

Add this block when a module calls functions from other modules
that aren't statically resolved at compile time.

---

## Typing State

Typing-related booleans are consolidated into a single `_TypingState`
Map with keys: `"nav"`, `"caps"`, `"tab"`, `"lwin"`, `"hk"`.

```ahk
_TypingState["nav"] := false
```

Never create new `_typingPrev*` globals — add a key to `_TypingState` instead.

---

## File Organization

- `core/` — CSP state helpers, notifications, debug log
- `dev/` — optional developer/release helpers (excluded from clean release)
- `docs/` — guide/wizard text, shortcut docs, icon references, tutorial
- `features/` — runtime behavior: toggle commands, feature switcher, Pie Oven, mode switcher
- `gui/` — all GUI modules (main GUI, IB bar, pie menu, hotkey settings, capture, preset wizard, collapsible button list, etc.)
- `hotkeys/` — definitions, registration, capture logic, mode system, CapsLock engine
- `includes/` — helper includes for generated/user-facing scripts
- `presets/` — default presets and profile data
- `settings/` — INI persistence, mode settings, profile import/export, backup/restore
- `tools/` — external/runtime tools (CSP monitor)
- `vendor/` — third-party dependencies (Notify.ahk)

### Guide Text in `guide_wizard.ahk`

**All guide text, help content, and reference displays belong in `src\docs\guide_wizard.ahk`**, not in the GUI module that triggers them. This includes:

- Guide/show functions (e.g. `ShowTutorial()`, `ShowGuideCentre()`, `HK_CheatSheetGuideShow()`)
- Guide text builders (e.g. `HK_CheatSheetGuideText()`, `ShowKeysGuide()`)
- Guide GUI globals (e.g. `_HK_GuideGui`)
- First-run setup text, cheat sheet text, function browser help

**Rule: never embed guide/help text directly in `gui/*.ahk` files.** The GUI modules only contain the button/entry point that calls into `guide_wizard.ahk`.

### Split Rules

- Keep startup order in the main script
- Keep globals in the main script unless a dedicated globals module exists
- Prefer moving complete function blocks; avoid changing logic while moving
- Run AutoHotkey validation after structural changes
- Keep release-only helpers in `dev/`
