Hotkey Settings Field Guide

Each hotkey entry in Hotkey Settings has several fields.
This guide explains what each one means.

---

## Shortcut

The key combination that triggers this action.

Example: Alt+D
This means holding Alt and pressing D will fire the hotkey.

You can customize this by clicking the shortcut field and pressing a new key combination. Multiple shortcuts can be assigned using pipe separator, e.g. Alt+D|Ctrl+Alt+D.

Disabled hotkeys show a dash (-) instead of a key combo.

---

## Requirement

A condition that must be true for this hotkey to work.

Example: CSP Active, Animation Enabled

Common requirements:

- CSP Active — CSP window must be in focus
- Animation Enabled — Animation mode must be active
- Nastar Enabled — Toolkit must be running (CSP detected)
- Tracing Mode — Tracing/Light Table mode must be on

If the requirement is not met, the hotkey will not fire even if the shortcut key is pressed. "(none)" means the hotkey always works regardless of context.

---

## AHK Function

The internal AutoHotkey function that runs when this hotkey fires. This is the code that actually performs the action (sends keystrokes, toggles settings, etc).

You generally do not need to change this. It is shown for reference and debugging. Some functions accept parameters that modify their behavior.

---

## Context

Which window conditions must be met for the hotkey to register. This controls where the hotkey is active.

Common contexts:

- csp — Only when CSP is the active window
- csp_nav — Navigation mode (CSP + Nav active)
- csp_caps — CapsLock hold mode (CapsLock held)
- csp_reset — Reset guard active
- csp_lwin — LWin hold mode (LWin held)
- global — Always active, any window
- bg — Background, fires even when CSP is not focused

This is different from Requirement. Context controls which hotkey "group" the shortcut belongs to. Multiple hotkeys can share the same shortcut key if they are in different contexts (e.g. Alt+D in csp context vs global).

---

## Outside CSP

Whether this hotkey can be triggered from outside CSP.

**Yes** — The hotkey fires even when CSP is not the active window. It will activate CSP first, then send the action. Useful for tools you want available from any application.

**No** — The hotkey only fires when CSP is already the active window. This is the default for most drawing and animation actions.

---

## Target

The specific window or process this hotkey is restricted to.

When set, the hotkey only fires when the specified target window is active, even within CSP. This lets you bind hotkeys to specific CSP panels or tools.

Examples:

- win1 — Default target (main CSP window)
- any — Any window in the target group
- (empty) — Uses the default target (win1)

Most hotkeys leave this empty and use the default. Only customize this if you need per-panel hotkeys.

---

## Status

Whether this hotkey is currently enabled or disabled.

**Enabled** — The shortcut key is active and will fire the action when pressed.

**Disabled** — The shortcut key is inactive. You can disable a hotkey by setting its shortcut to dash (-) in the shortcut field.

Disabled hotkeys are hidden from the Cheat Sheet overlay but remain in the settings for easy re-enable.

---

## Effective

The actual key that will be sent to CSP when this hotkey fires. This may differ from the base shortcut if the mode overrides it.

Example: Base shortcut is Alt+D, but the mode defines its own Alt+D for a different action. The Effective key shows what ACTUALLY fires in this mode.

If no mode override exists, Effective equals the base shortcut. If the mode disables it, Effective shows (-).

---

## Mode Switch Keys

These are global keys that switch between toolkit modes (Drawing, Animation, Tracing, etc).

They are always active and cannot be disabled. They work from any window, not just CSP.

The currently active mode is marked with "(active)".
