# Changelog

All notable changes to the Nastarxa CSP Animator Toolkit.

## 2.2.2

* **Guide texts moved to editable Markdown files**: all long help content now lives in `src\docs\*.md` (Toolkit Guide, First Run Setup, Recommended Shortcuts, Hotkey Field Guide, System Settings Help, IB Bar Guide, Timer Guide, Toggles Guide). Edit an MD file and click **Reload Guides** - changes appear without restarting.
* New **Pomodoro mode** inside the Countdown dialog (double-click the timer bar): Work/Break phases alternate automatically, each finished work session records a lap named Pomo W1, Pomo W2 ..., a LONG break comes after every N cycles, and a Restart button plus live phase status show while running.
* Fixed: pausing a countdown (manually or via CSP focus auto-pause) no longer eats wall time - resuming now ends at the correct wall-clock moment.
* Countdown dialog redesigned with **Countdown / Pomodoro section titles** and an inline how-to guide covering both modes.
* New **Notification Center**: recent toasts are recorded (last 100); open from Guide Centre to review history or clear it.
* Missing MD guide files now notify once per file instead of stacking one popup per tab.
* Fixed startup/runtime crash risk: notification history and MD guide caches are initialized at load (AHK v2 throws when reading never-assigned globals).
* GUI theme colors centralized in `src\gui\theme.ahk` (`TC("token")` helper) and adopted by all guide dialogs.
* Guide Centre "IB GUI Feature" row renamed to "IB GUI Features" with three evenly sized buttons (IB / Toggles / Timer).
* Added COUNTDOWN and POMODORO sections to the Timer Guide documentation.
* Removed unused files: standalone unit-test harness `verify_unit.ahk` and empty validation artifacts `validate_err.txt` / `validate_out.txt`.

## 2.2.1

* **Reset GUI positions layout redesigned**: IB bar on top, Link/Color/Main GUIs side by side in one row below. Single-monitor setups show all four panels in a clean two-row layout.
* **Select Monitor popup now appears at the mouse cursor** on the correct monitor (not always monitor 1). Dropdown defaults to the monitor the cursor is currently on.
* **Feature Switcher is now a universal setting** — shared across all modes, not per-mode. Switches stay consistent when you change modes.
* New **Timer Countdown** mode (`Ctrl+Alt+Shift+5`): enter minutes and seconds, timer counts down and alarms when time's up with a notification and beep. Countdown resets on pause/stop. Double-click timer display in IB to open countdown dialog.
* New **Screen Color Picker** (`Shift+Ctrl+B`): pick screen color from any application, works outside CSP.
* New **Preset Import/Export Wizard** (`↗ Share Presets` button): unified dialog for sharing hotkeys, pie menus, color items, link buttons, IB colors, and feature switches between installations. Backs up existing files before import.
* New **Collapsible Button List** class (`CollapsibleButtonList`) — shared GUI framework for collapsible section button grids. Available for new GUIs and gradual migration of existing ones.
* Color GUI **shortcut labels now resolve from live hotkey bindings** — `keyLabel` values update dynamically based on current hotkey assignments instead of using hardcoded defaults.
* Color GUI labels for shortcut-type items (Deselect, Inverse Sel, etc.) now refresh automatically when hotkeys are remapped.
* **LoadGUIPositions split** into per-section try blocks — a corrupt `[IB]` section no longer prevents `[Color]`, `[Settings]`, `[ColorInfo]`, etc. from loading.
* Hotkey conflict logs downgraded from **ERR** to **WARN** in diagnostics (conflicts are not fatal).
* All shortcut keys enforced to **lowercase** across capture, storage, and seeding to prevent AHK v2 uppercase-letter-means-Shift modifier bugs.
* `toggle_lt` non-Tracing mode shortcut fix: `HK_NormalizeSavedHotkeyValue` now strips `!w` from `toggle_lt` when not in Tracing mode, preventing conflict with `toggle_onion`'s `!w`.
* Fixed: bare `Integer()` crashes replaced with `ToolkitSafeInt` in opacity/contrast and color info (prevents fatal errors from corrupt INI values).
* Fixed: bare `IniWrite`/`IniDelete` calls wrapped in `try` blocks across mode settings, mode system, and feature switcher (prevents crashes from read-only files).
* Fixed: **Select Layer Window** — remaps Ctrl to Tab+Enter inside CSP's "Select layer" dialog for quick layer selection. Feature switch `SelectLayer` in Feature Switcher.
* Fixed: remaining bare `IniWrite`/`DirCreate`/`FileCopy` calls wrapped in `try` across `auto_save_interval`, `mode_system`, `system_settings`, `backup_restore`, `color_palette`, `hotkey_settings`, `pie_menu`, `timer_history`, `pie_quick_hotkeys`.
* Fixed: missing UTF-8 encoding in `pie_menu` pie INI rewrite (prevents corruption of non-ASCII slot names).
* Fixed: empty-string sentinel inconsistency in hotkey diagnostics pie-open collision check (now correctly skips disabled hotkeys with value `"-"`).
* CSP **5.0.4+** recommendation added to README and guide wizard.
* Apply Block feature switch added — can be toggled on/off in the Feature Switcher.
* **Script Writing Rules** document (`src/docs/script_rules.md`) created with coding conventions for AHK v2 in this project.
* Link GUI now has **Toggle Layout** (horizontal/vertical) via right-click context menu, matching Color GUI's layout toggle. Layout persisted as `LinkLayout` in `[Link] Layout`.

## 2.2.0

* Fixed: **Reset Guard** (`Ctrl+Shift+Alt+Space`) now blocks key combinations (e.g. `Ctrl+Shift+Alt+R`) in addition to bare keys — the guard registers `$^!+keyName` variants alongside `$*keyName` so modifier combos are intercepted when the guard is active.
* Tracing mode: **Toggle Light Table** (`toggle_lt`) now has a double shortcut — `Alt+W` and `Ctrl+Alt+W` — so both bindings fire the same action in Tracing mode.
* New **Font Color Contrast** setting in System Settings — editable luminance threshold (0–255, default 185) that controls when automatic font color switches between dark and light text on mode-colored backgrounds. Persisted as `ContrastThreshold` in `[Settings]` and included in JSON export/import.

## 2.1.1

* Fixed: closing the **Hotkey Cheat Sheet** (Close button or `toggle_cheat_sheet`) could leave the window on screen — inside the full toolkit `Destroy()` can silently return without destroying the native window, so the close path now force-destroys the window (`DestroyWindow`) if it is still alive after the standard destroy.
* Hotkey Cheat Sheet toggle rebound from `Alt+F2` to `Ctrl+Shift+F2` by default (still rebindable in Hotkey Settings, `toggle_cheat_sheet`) and exempted from the typing safeguard so it always toggles.
* Setup mode remap: added `feature_half_green` (`6`) and `feature_half_purple` (`7`) for LT half-color actions, and moved `color_gray` to `8` / `layer_1` to `9`.
* Fixed: Dev Tools **Pie Quick Preset Tester** falsely reported every bundled and user quick-pie preset as "Missing quick hotkey key" — the audit split preset `Ids` on commas (they are pipe-separated) and read the key from the wrong INI field (`Key` instead of `Hotkey`). The audit now validates all 45 preset files cleanly.
* Fixed: the **Mode Diff** overview and per-mode diff showed `0` hotkey differences for every mode — the hotkey comparison only read the active mode's in-memory keys, never the diffed mode's own `hotkey_settings.ini`. The diff now compares the base file against the mode's own file (`HK_DiffHotkeysFile`) using the same id/value normalization as `HK_Load`, so the Hotkeys column reports real per-mode changes (Setup mode: 18).
* The **Select Mode** panel now has a `Hotkey Cheat Sheet` button that toggles the cheat sheet overlay (respects the feature switch; shows a notification when the cheat sheet feature is off).
* Fixed: a custom mode whose persisted `active=` entry was dropped from the `order=` list (e.g. after an edited/corrupted `[Modes]` block) crashed the mode switch with a missing-mode error. Mode loading now self-heals: `HK_LoadModes` re-registers the orphaned active mode from its `[Mode_<id>]` def and persists the fixed order, and `HK_SwitchMode` re-registers from the base def (falling back to the mode's own snapshot) when a switch still cannot find the target — so the switch completes and the base file heals instead of throwing.
* **Typing Title Lists** editor now supports per-item **Disable / Enable** plus **Delete** in each list category (CSP dialog titles, toolkit dialog titles, CSP non-typing exceptions), shown in a two-column **Title / Status** view. Disabled titles stay visible with a `Disabled` status and stop matching until re-enabled; Delete permanently removes an item (built-in titles go back to the built-in defaults on Reset). Disabled state persists in `gui_settings.ini` (`TypingDialogDis`/`TypingSelfDis`/`TypingNonDis`) and applies to the typing safeguard immediately.
* The **Typing Title Lists** editor can now manage an arbitrary number of **custom list categories**. `New Cat` creates a named list with one of the three matching behaviors (CSP dialog title, toolkit dialog title, or CSP non-typing exception); `Del Cat` removes a custom list (built-ins cannot be deleted). Custom lists merge into the same safeguard checks as their behavior type, and their categories, titles, and disabled state persist in `gui_settings.ini` (`[TypingCategories]` plus per-category `TypingCust_*` sections).
* New per-mode **Apply Block** editor: the `Apply Block` button in the Mode Editor opens a per-mode window for managing intercepted key combinations. Keys listed here are blocked from reaching CSP when the toolkit is active in that mode. Each key has a **Scope** — `target` (only when the CSP window is active) or `global` (always intercepted). Tracing and Animate modes ship with Ctrl+backtick, Ctrl+2-0, and Ctrl+Shift+1-3 blocked by default (the same keys the old feature-switch `blocknum` used to intercept). Default, Setup, and Painting modes start with an empty block list. Keys can be added via keyboard capture or removed/toggled from the list. Apply Block settings persist per-mode in `[ApplyBlock]` sections of `hotkey_settings.ini`.
* New per-mode **Mode Color**: the Mode Editor now has a color picker (hex input + R/G/B/O/V/C/Gr presets) that sets the background color of the mode name on the IB drag separator. Each mode can have its own color; leave blank for the default blue (`3949AB`).
* In **Tracing**, **Animate**, and **Painting** modes, `A`/`D` and `Alt+A`/`Alt+D` are now swapped: bare `A`/`D` select the previous/next cel (sending `Alt+A`/`Alt+D` to CSP), and `Alt+A`/`Alt+D` move the previous/next frame (sending bare `A`/`D` to CSP). Default and Setup modes keep the standard CSP layout (`A`/`D` for frame navigation, `Alt+A`/`Alt+D` for cel navigation).
* Apply Block editor now has **Presets** row: **Tracing** (blocks Ctrl+backtick/2-9/0 and Ctrl+Shift+1-3), **Animate** (same as Tracing), **Drawing** (blocks number keys 1-9/0 that change brush size), and **Clear** (removes all blocked keys). One click loads the preset into the list.
* Mode color now affects the **Select Mode** and **Manage Modes** panels — the active mode's cell uses its custom color instead of hardcoded blue.
* Mode switch notification now uses the target mode's color for the toast background.
* New **Layer Select** hotkeys: `Layer: Second Layer` through `Layer: Tenth Layer` — same CSP keys as the color layers (Shift+2 through Shift+0) but with numbered names in the notification. All 9 start empty (`-`) and disabled so users can enable them in Hotkey Settings if they prefer numbered layer names over color names.
* Apply Block defaults updated: Alt+Shift+W is now blocked by default in Tracing and Painting modes only (version bumped to `2026-08-18-apply-block-2`). Animate, Default, and Setup modes are unaffected.
* Built-in modes now have unique default colors: Setup (Blue Grey `#546E7A`), Tracing (Purple `#7E57C2`), Animate (Orange `#FF9800`), Painting (Teal `#00897B`). Default mode stays empty (falls back to `#3949AB`).
* New **Guide Notifications** feature switch in the Feature Switcher (default ON). Disabling it blocks all guide notification popups (InBetween, Create, Shortcuts, AutoAction, Animation) from appearing.

## 2.1.0

* New **Hotkey Cheat Sheet** overlay (`Alt+F2` by default, rebindable in Hotkey Settings, `toggle_cheat_sheet`): an always-on-top dark panel listing the active mode's effective hotkeys grouped by context, plus every mode's switch hotkey. It refreshes live every 1.5s so mode switches and hotkey edits show up immediately, and its position is remembered in `gui_settings.ini`. Gated by the new **Hotkey Cheat Sheet** feature switch (default ON).
* New **Auto Mode Switch**: automatically switches the active mode based on the foreground window (or the currently active CSP target). Gated by the new **Auto Mode Switch** feature switch (default OFF). Manual mode switches suppress auto-switching for a short debounce so the mode does not immediately flip back.
* New **Hotkey collision detection**: on save/apply, the toolkit scans the active mode's effective hotkeys (base keys adjusted by overrides) plus every mode's switch hotkey, and shows a non-blocking warning when two actions share a key. The Status Dashboard now reports the conflict count and shows the first few conflicts. Pure config check — nothing is auto-changed.
* New **Feature Switcher Info** window: the `Info` button on the Feature Switcher opens a read-only report describing every switchable feature, its default state, and its current state (Refresh keeps it live).
* New **Typing Title Lists editor**: the Typing Safeguard Inspector's `Edit Lists` button opens an editor for all three typing title lists — CSP dialog titles, toolkit dialog titles, and CSP non-typing exceptions. Each list supports viewing all items, adding a title, removing a title, and resetting back to the built-in defaults. Custom additions and removals persist in `gui_settings.ini` (`TypingDialogAdd/Del`, `TypingSelfAdd/Del`, `TypingNonAdd/Del`) and apply to the typing safeguard immediately.
* Feature Switcher now also covers the **Hotkey Cheat Sheet** and **Auto Mode Switch** switches (11 switches total).
* Performance: user-script hotkeys now cache their generated runtime wrapper instead of rewriting a temporary runner on every trigger.
* Performance: CapsLock/Tab hold polling is more responsive, and full hotkey refresh no longer reapplies pie-open hotkeys twice.
* Fixed: the Typing Safeguard Inspector and Feature Switcher Info `Refresh` buttons no longer spawn a duplicate window on every click — they now re-render the existing window in place.

## 2.0.1

* New **Feature Switcher** (`◉ Feature Switcher` button on the Main GUI): master on/off switches that block each feature's activation path — its shortcuts, GUI button, and show path — instead of only hiding the UI.
* Feature switches cover: Color GUI, Link GUI, IB GUI, Pie Menu, CapsLock combos, Tab combos, User Scripts, and Pie Quick Hotkeys.
* Feature switches are persisted per-mode in `settings\feature_switches.ini` (Default mode) or `settings\<mode_id>\feature_switches.ini` (custom modes) under the `[Features]` section, so each mode keeps its own on/off state.
* `Enable All` / `Disable All` buttons toggle every feature at once.
* Toggling a switch applies immediately: affected hotkeys are re-registered, hidden GUIs cannot be re-shown, an open pie closes, the Main GUI buttons update, and a popup notification confirms the change.
* Hardened feature-switch gating: User Scripts are now blocked from every activation path (pie slots, quick pie, CapsLock slots, and the user-script hotkey), and sub-pie opens including the Pie Oven `Test` button are blocked while the Pie Menu switch is off.
* External edits to `feature_switches.ini` now take the same path as an in-GUI toggle, so toggling a feature off from the file also closes an open pie and re-registers hotkeys.
* Startup now honors the feature switches for initial GUI visibility so disabled GUIs no longer flash on screen before being hidden.
* Reset positions dialog (`⟲` on the Main GUI) now also includes a UI Scale slider (50–150%) with live preview; picking a monitor and a scale in one dialog applies both, and Cancel/close restores the previous scale.
* GUI Settings slider titles renamed for clarity: `IB GUI`, `Color GUI`, and `Link GUI` are now `IB GUI Opacity`, `Color GUI Opacity`, and `Link GUI Opacity`.
* Release tooling audit: verified Ahk2Exe discovery, AutoHotkey v2 U64 base detection, icon/main-script lookup, tools/presets zip readability, and clean-release/package documentation.

## 2.0.0

* New Mode System with five built-in modes: Default, Setup, Tracing, Animate, and Painting.
* Mode selector button on Main GUI above Pie Oven — click to switch modes.
* IB drag-separator shows the active mode name; double-click opens the mode selector.
* Mode Manager (`Manage` in selector) for creating, editing, deleting, and switching custom modes.
* Each mode can have a switch hotkey and per-action hotkey overrides.
* Mode overrides let you temporarily reassign shortcuts while a mode is active.
* Painting Mode is a non-deletable built-in mode with an empty override set for customization.
* Indicator swap: timer lap text temporarily replaces the mode name on the IB drag-separator; the mode name restores when laps clear.
* Mode panel drag handles: selector and manager panels are draggable by their header strips; a drag must move past a small threshold, so a plain click never moves the panel.
* Fixed mode selector/manager panel rebuilds: destroyed controls are physically removed (DllCall DestroyWindow) and every panel element is placed with an explicit Move, so toggling the advanced filter no longer drifts the window or leaves stale controls.
* Fixed mode switching so the newly active mode's pie open hotkeys and quick-pie hotkeys are registered: per-mode settings are loaded before hotkeys are reapplied, so switching never leaves the previous mode's keys live.
* Color GUI buttons are now per-mode: each mode stores its own color button list in `settings\<mode_id>\color_settings.ini` (the `default` mode uses the base `settings\color_settings.ini`), and legacy `[ColorItems]` data in the global `gui_settings.ini` is migrated automatically on first load.
* Color GUI Button Manager now shows the active mode in its title and a `Mode:` badge, matching the Link GUI Button Manager.
* Removed the in-bar mode badge from the Link and Color GUIs; the active mode is still shown in their manager dialogs, Hotkey Settings, and Pie Oven.
* Documented per-mode vs. global settings (pie/hotkey/link/color are per-mode; gui settings and pie quick presets stay global).
* Manage Modes now has a Guide button that opens the Modes guide and a Diff All button that lists every mode's differences vs Default in one window; the per-mode Diff view now also covers Color buttons and compares against the real base files (pie/link/color), with the Default mode reported as "no differences".
* User Function Recorder workflow polished: Add/Edit User Function can build scripts from explicit lowercase Send steps, Delay steps, and Add Fn function calls inserted from Function Browser.
* Function Browser insert mode now supports callback targets, allowing User Action Recorder and editor Pick buttons to share the same callable-function picker safely.
* Documentation refresh: main README source layout now matches the current `src` folders, and release/dev tool notes document the current audit, build, and packaging flow.
* Audit pass: AutoHotkey validation, active include scan, settings duplicate-key scan, and common AHK v2 footgun scan pass cleanly for the current tree.

## 1.7.0

* New Quick Pie Hints bar with per-hint coloring, scope prioritization, configurable count (1–99), and reorderable quick keys.
* Quick Pie Hotkey editor now includes per-item color picker and move up/down buttons.
* Added Tab block passthrough toggle to prevent Tab from reaching CSP when Tab hold is active.
* Fixed Tab hold breakage on Pie Oven save/reset/import operations.
* Tab pie hotkeys now close the open pie without leaking Tab output to the active application when Tab blocking is enabled.
* Hints position changed from bottom-right to bottom-center by default.
* Pie Oven now saves, resets, exports, and imports Quick Pie hint visibility, hint position, and hint count.
* Quick Pie items now show color in the list view.
* Added real-time search filter to presets window.
* Removed Quick Pie Oven popup.
* Sort-safe listviews: all editors now prevent or survive column-header sort so edit/delete always targets the correct item.
* Shortcut actions now consistently lowercased across ALL systems (Quick Pie, Pie slots, CapsLock slots, Color palette, Link buttons, function browser, hotkey settings). Added `PieQuickNormalizeShortcutAction` helper with automatic `{}` brace wrapping for multi-character keys (F3→{f3}, Delete→{delete}, Backspace→{bs}, etc.) so `Send` sends the correct key instead of literal text. Multi-key chord shortcuts (e.g. `{Shift Down}{A}{Shift Up}`) are preserved as-is.
* Removed Tab mode dropdown (Pie 1 / Last Pie / Disabled) from Hold Threshold — Tab hold now auto-detects whichever pie has the Tab hotkey assigned. Default hold threshold changed from 60ms to 80ms.
* Added post-close delay for reliable CSP focus.
* Various stability and polish improvements.

## 1.6.0

* Improve Dev Tools for release preparation, including release audit, version consistency checks, clean release folder creation, optional tools/presets zip creation, and optional Ahk2Exe build support.
* Improve IB color presets with clearer preset organization and the new Colorful category for vivid, neon, rainbow, candy, and cold/hot styles.
* Improved release packaging safeguards so clean release output can be checked before sharing.
