# Source Layout

`Nastarxa_CSP_Animator_Toolkit.ahk` is the entrypoint. It keeps global defaults, startup order, and `#Include` statements.

Edit feature code inside these folders:

- `core/` - CSP state helpers, light table helpers, notifications, debug log.
- `dev/` - optional developer/release helpers. This folder can be excluded from clean release output from the Dev Tools window.
- `docs/` - guide/wizard UI text, recommended shortcut docs, icon references, and small documentation assets used by runtime helpers.
- `features/` - toolkit commands, system settings, Pie Oven, Timer/Worklog, and feature panels that are more runtime behavior than documentation.
- `gui/` - all GUI modules: main GUI, IB bar, color palette, link launcher, pie menu, hotkey settings, Function Browser, hotkey capture, CapsLock slot editor, Pie Quick hotkeys, opacity/scale, hover popup, color info, window dragging.
- `hotkeys/` - hotkey definitions, hotkey registration, hotkey requirements, capture logic support.
- `includes/` - helper include files used by generated or user-facing script runners.
- `presets/` - default presets and callable profile data, such as guide, pie, and UI presets.
- `settings/` - INI persistence, profile import/export, auto-save interval, backup/restore.
- `tools/` - small external/runtime tools such as CSP restart monitor.
- `vendor/` - third-party or bundled dependencies. `Notify.ahk` lives here.

Split rules:

- Keep startup order in the main script.
- Keep globals in the main script unless a future refactor creates a dedicated globals module.
- Prefer moving complete function blocks; avoid changing logic while moving files.
- Run AutoHotkey validation after every structural change.
- Keep release-only helpers in `dev/` so release builds can include or exclude them safely.
- Dev Tools can build a release EXE with `Ahk2Exe.exe` from `C:\Program Files\AutoHotkey\Compiler`, using the v2 U64 base and `CSPToolkit.ico`.
- Dev Tools includes `Preset Hub` for existing preset/profile import-export actions.
- Dev Tools includes `Build Release Package`, which creates a clean release folder and then zips it as a shareable release package.

Script writing rules:

- **Before editing any `.ahk` file, read `docs/script_rules.md` first.** It contains non-obvious constraints (disabled sentinel `"-"` not `""`, lowercase key rule, mode seeding checklist) that cause silent bugs if violated.
- See `docs/script_rules.md` for the full coding conventions: naming, headers, global declarations, error handling, hotkey system, mode settings, CapsLock hold engine, GUI dark theme, and file organization.
- Every new module must include the module header format documented there.
- Follow the lowercase key rule: all shortcut keys stored in data must be lowercase.
- Wrap all external calls in `try` with explicit fallbacks.
- Use `S(n)` for all GUI dimensions (DPI scaling).
- Use `IniReadIntSafe`/`IniReadFloatSafe` for numeric reads (mandatory clamping).
- All callbacks must use `(*)` variadic catch-all.
- New settings files must register in `SettingsFilesSignature()` AND `CheckIniChanges()`.
- Use `SettingsDiagPush(level, title, detail)` for observability (OK/INFO/WARN/ERR/TRACE).

Release helpers:

- Settings Health now reports each startup badge issue as its own `[FIX]` line instead of hiding extra problems behind `+N more`.
- Self-Heal recreates missing split settings files, reloads runtime data, refreshes the health badge, and refreshes the Settings Health text when launched from that window.
- The Recommended Shortcut window includes a `Guide Popups` launcher for the callable guide notification functions used by `presets/guide.ini`.
- Guide Detail sub-pie defaults include the guide notification functions:
  `GuideIBNotify`, `GuideCreateNotify`, `GuideShortcutNotify`, `GuideAutoActionNotify`, and `GuideAnimationNotify`.
