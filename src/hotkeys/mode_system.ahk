; MODE SYSTEM
; ============================================================
; Per-mode settings with global switch hotkeys.
; Each mode owns its own settings snapshot; edit hotkeys normally while that
; mode is active instead of using a separate override layer.
; Extracted from hotkey_core.ahk so mode logic stays editable in one file.
;
; INI layout (hotkey_settings.ini):
;   [Modes]
;     order  = default,work,study
;     active = work
;   [Mode_<id>]
;     name      = Work Mode
;     switch    = ^!+w            (optional global switch hotkey)
;
; While a mode is active, Hotkey Settings reads/writes that mode's own files.
; Default mode remains the base configuration.
;
; The five built-in modes always exist: default, setup, tracing, animate, painting.
; "default" cannot be edited or deleted; the other built-ins can be edited
; (name/switch/target/settings) but not deleted.
; Dependencies (defined elsewhere, resolved at runtime):
;   HK_ReapplyAll / HotIfConditionGlobal  -> hotkey_core.ahk
;   ShowNotify / DebugLog                 -> csp_runtime.ahk
;   HOTKEY_SETTINGS_FILE                  -> main script

; Mode system: HK_Modes[id] -> Map("name","switch","autoTarget"); HK_ModeOrder keeps GUI order
global HK_Modes := Map()
global HK_ModeOrder := []
global HK_Mode := "default"
global HK_RegisteredModeHotkey := Map()
; Persisted picker preference: show built-in (advanced) modes in mode pickers.
global _ShowAdvancedModes := 0

; Ordered list of built-in modes: [id, display name].
HK_SystemModeDefs() {
    return [
        ["default",  "Default Mode"],
        ["setup",    "Setup Mode"],
        ["tracing",  "Tracing Mode"],
        ["animate",  "Animate Mode"],
        ["painting", "Painting Mode"]
    ]
}

HK_IsSystemMode(id) {
    for pair in HK_SystemModeDefs()
        if pair[1] = id
            return true
    return false
}

; Whether a mode should appear in a mode picker. The built-in system modes
; (setup/tracing/animate/painting) are secondary now that every mode owns its
; own settings, so they are hidden unless the picker's "advanced" filter is on
; or the mode is currently active (so you always see where you are).
HK_ShowModeInPicker(id, showAdvanced, activeId := "") {
    if activeId = ""
        activeId := HK_ModeActive()
    if id = "default" || id = activeId
        return true
    return !HK_IsSystemMode(id) || showAdvanced
}

HK_LoadModes(ini) {
    global HK_Modes, HK_ModeOrder, HK_Mode
    HK_Modes := Map()
    HK_ModeOrder := []
    HK_Mode := "default"
    defaultColors := Map("setup", "546E7A", "tracing", "7E57C2", "animate", "FF9800", "painting", "00897B")
    for pair in HK_SystemModeDefs() {
        modeColor := defaultColors.Has(pair[1]) ? defaultColors[pair[1]] : ""
        HK_Modes[pair[1]] := Map("name", pair[2], "switch", "", "overrides", Map(), "autoTarget", "", "color", modeColor)
        HK_ModeOrder.Push(pair[1])
    }
    if !FileExist(ini)
        return
    order := ""
    try order := IniRead(ini, "Modes", "order", "")
    catch
        order := ""
    for id in StrSplit(order, ",") {
        id := Trim(id)
        if id = ""
            continue
        if HK_Modes.Has(id) {
            ; reload persisted customizations for a built-in mode
            HK_LoadModeSection(ini, id)
            continue
        }
        if HK_LoadModeSection(ini, id)
            HK_ModeOrder.Push(id)
    }
    defaultSwitches := Map("default", "^!+F13", "setup", "^!+F14", "tracing", "^!+F15", "animate", "^!+F16", "painting", "^!+F17")
    for id, key in defaultSwitches {
        if HK_Modes.Has(id) && HK_Modes[id].Get("switch", "") = ""
            HK_Modes[id]["switch"] := key
    }
    active := ""
    try active := IniRead(ini, "Modes", "active", "")
    catch
        active := ""
    active := Trim(active)
    ; Self-heal: if the persisted active mode was dropped from the order but its
    ; definition is still in the file, re-register it and persist the fixed
    ; order so boot lands on the right mode instead of silently falling back to
    ; the first entry.
    if active != "" && !HK_Modes.Has(active) && HK_LoadModeSection(ini, active) {
        HK_ModeOrder.Push(active)
        orderList := ""
        for oid in HK_ModeOrder
            orderList .= (orderList = "" ? "" : ",") oid
        try IniWrite(orderList, ini, "Modes", "order")
    }
    if active = "" || !HK_Modes.Has(active)
        active := HK_ModeOrder[1]
    HK_Mode := active
}

; Parses the body of a "[Mode_<id>]" section into a definition map.
HK_ParseModeSectionText(sectionText, fallbackName := "") {
    m := Map("name", fallbackName, "switch", "", "overrides", Map(), "autoTarget", "", "color", "")
    for line in StrSplit(sectionText, "`n") {
        if !InStr(line, "=")
            continue
        k := Trim(SubStr(line, 1, InStr(line, "=") - 1))
        v := Trim(SubStr(line, InStr(line, "=") + 1))
        if k = "name"
            m["name"] := v
        else if k = "switch"
            m["switch"] := v
        else if k = "autoTarget"
            m["autoTarget"] := v
        else if k = "color"
            m["color"] := v
    }
    return m
}

HK_LoadModeSection(ini, id) {
    global HK_Modes
    try sec := IniRead(ini, "Mode_" id)
    catch
        sec := ""
    if sec = ""
        return false
    HK_Modes[id] := HK_ParseModeSectionText(sec, id)
    return true
}

HK_SaveModes() {
    global HK_Modes, HK_Mode, HK_ModeOrder, HOTKEY_SETTINGS_FILE
    ; Mode definitions, the order list and the active marker are global state and
    ; must survive in the base hotkey file. The per-mode snapshot may be a stale
    ; copy, so this never targets the currently active mode's folder.
    ini := ModeSettingsBaseFile("hotkey_settings.ini")
    orderList := ""
    for id in HK_ModeOrder {
        if !HK_Modes.Has(id)
            continue
        orderList .= (orderList = "" ? "" : ",") id
    }
    try {
        IniDelete(ini, "Modes")
        IniWrite(orderList, ini, "Modes", "order")
        IniWrite(HK_Mode, ini, "Modes", "active")
        for id in HK_ModeOrder {
            if !HK_Modes.Has(id) || id = "default"
                continue
            m := HK_Modes[id]
            IniDelete(ini, "Mode_" id)
            IniWrite(m.Get("name", id), ini, "Mode_" id, "name")
            if m.Get("switch", "") != ""
                IniWrite(m["switch"], ini, "Mode_" id, "switch")
            if m.Get("autoTarget", "") != ""
                IniWrite(m["autoTarget"], ini, "Mode_" id, "autoTarget")
            if m.Get("color", "") != ""
                IniWrite(m["color"], ini, "Mode_" id, "color")
        }
    }
}

HK_ModeActive() {
    global HK_Mode
    return HK_Mode = "" ? "default" : HK_Mode
}

; The hotkey an action should actually use while the active mode is applied.
; Priority: 1) user scripts, 2) active mode's normal hotkey settings.
;   - User scripts are owned by the user and never touched by modes.
;   - If a user script owns the action's key, the action is deactivated ("-").
; m is accepted for call-site compatibility but is not consulted - mode hotkey
; changes live in each mode's own hotkey_settings.ini (loaded into HK_Custom),
; so the active mode is the only one this can reason about.
HK_ModeEffectiveKey(id, baseKey, m := 0) {
    d := HK_FindDef(id)
    if IsObject(d) && d.HasOwnProp("user") && d.user
        return baseKey
    if baseKey = "" || baseKey = "-"
        return baseKey
    if HK_UserScriptUsesKey(baseKey, id)
        return "-"
    return baseKey
}

; True if a user script (priority 1) is bound to the given hotkey.
HK_UserScriptUsesKey(key, excludeId := "") {
    if key = "" || key = "-"
        return false
    myKeys := HK_SplitKeys(key)
    for d in HotkeyDefs {
        if d.id = excludeId
            continue
        if !(d.HasOwnProp("user") && d.user)
            continue
        if !HK_IsRequirementEnabled(d)
            continue
        otherKey := HK_Get(d.id, d.def)
        otherKeys := HK_SplitKeys(otherKey)
        for _, mk in myKeys {
            for _, ok in otherKeys {
                if Trim(mk) = Trim(ok)
                    return true
            }
        }
    }
    return false
}

global _ModeLoadGui := 0

ShowModeLoadWindow(name, color := "") {
    global _ModeLoadGui
    if IsObject(_ModeLoadGui) {
        try _ModeLoadGui.Destroy()
        _ModeLoadGui := 0
    }
    monW := 360
    monH := 90
    monNum := MonitorGetPrimary()
    MonitorGet(monNum, &mL, &mT, &mR, &mB)
    cx := mL + ((mR - mL) // 2) - (monW // 2)
    cy := mT + ((mB - mT) // 2) - (monH // 2)
    _ModeLoadGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20", "ModeLoad")
    bgColor := color != "" ? color : "1E1F22"
    _ModeLoadGui.BackColor := bgColor
    _ModeLoadGui.MarginX := 0
    _ModeLoadGui.MarginY := 0
    _ModeLoadGui.SetFont("s12 c" ContrastColor(bgColor), "Segoe UI Black")
    _ModeLoadGui.AddText("x0 y8 w" monW " h28 +0x201", "Switching Mode...")
    _ModeLoadGui.SetFont("s14 c" ContrastColor(bgColor), "Segoe UI Black")
    _ModeLoadGui.AddText("x0 y+2 w" monW " h36 +0x201", name)
    _ModeLoadGui.Show("x" cx " y" cy " w" monW " h" monH " NA")
}

CloseModeLoadWindow() {
    global _ModeLoadGui
    if IsObject(_ModeLoadGui) {
        try _ModeLoadGui.Destroy()
        _ModeLoadGui := 0
    }
}

HK_SwitchMode(id, fromAuto := false, *) {
    global HK_Modes, HK_Mode, HOTKEY_SETTINGS_FILE
    if !HK_Modes.Has(id) || HK_Mode = id
        return
    if !fromAuto
        HK_AutoSwitchSuppress()
    prev := HK_Mode
    prevName := HK_Modes.Has(prev) ? HK_Modes[prev].Get("name", prev) : prev
    newColor := HK_Modes[id].Get("color", "")
    ShowModeLoadWindow(HK_Modes[id].Get("name", id), newColor != "" ? "0x" newColor : "")
    ModeSettingsSaveCurrent()
    HK_Mode := id
    ModeSettingsEnsureModeFiles(id)
    ModeSettingsRetarget(id)
    IniWrite(id, HOTKEY_SETTINGS_FILE, "Modes", "active")
    IniWrite(id, ModeSettingsBaseFile("hotkey_settings.ini"), "Modes", "active")
    SettingsSyncIniWatcher()
    HK_Load()
    if !HK_Modes.Has(id) {
        def := Map("name", id, "switch", "", "overrides", Map(), "autoTarget", "", "color", "")
        sec := ""
        try sec := IniRead(ModeSettingsBaseFile("hotkey_settings.ini"), "Mode_" id)
        catch
            sec := ""
        if sec = ""
            try sec := IniRead(ModeSettingsModeDir(id) "\hotkey_settings.ini", "Mode_" id)
            catch
                sec := ""
        if sec != ""
            def := HK_ParseModeSectionText(sec, id)
        HK_Modes[id] := def
        HK_ModeOrder.Push(id)
        HK_Mode := id
        HK_SaveModes()
        DebugLog("Mode '" id "' was missing from the base order; re-registered and healed.")
    }
    ModeSettingsLoadCurrent()
    HK_ReapplyAll()
    HK_ApplyModeFlags(id, prev)
    HK_FiredEvent("Mode: " HK_Modes[id].Get("name", id))
    CloseModeLoadWindow()
    modeColor := HK_Modes[id].Get("color", "")
    global NotifyEnabled, NotifyMonitor, NotifyPosition
    if NotifyEnabled {
        monOpt := NotifyMonitor > 0 ? " mon=" NotifyMonitor : ""
        try Notify.Show("Mode Changed", HK_Modes[id].Get("name", id) " is now active",,,,, 'dur=1.5 ts=10 ms=7 pad=8,4,6,6,6,6,2,3 mf=Segoe UI Black mfo=norm Bold mali=Center pos=CT' monOpt (modeColor != "" ? " bc=0x" modeColor : ""))
    }
}

; Cycles to the next visible mode. Used by Alt+click on the IB separator.
HK_CycleMode() {
    global HK_Modes, HK_ModeOrder, HK_Mode
    n := HK_ModeOrder.Length
    if n < 2
        return
    start := 0
    for idx, id in HK_ModeOrder {
        if id = HK_Mode {
            start := idx
            break
        }
    }
    if start = 0
        return
    target := ""
    Loop n {
        start := start = n ? 1 : start + 1
        id := HK_ModeOrder[start]
        if !HK_Modes.Has(id)
            continue
        if HK_ShowModeInPicker(id, false, HK_Mode) {
            target := id
            break
        }
    }
    if target != ""
        HK_SwitchMode(target)
}

; Persists the picker's "show advanced modes" preference to gui_settings.ini.
HK_SaveShowAdvancedModesState() {
    global _ShowAdvancedModes, SETTINGS_FILE
    try IniWrite(_ShowAdvancedModes ? 1 : 0, SETTINGS_FILE, "Settings", "ShowAdvancedModes")
    catch as e
        DebugLog("Failed to save ShowAdvancedModes state: " e.Message)
}

HK_RegisterModeHotkeys() {
    global HK_Modes, HK_ModeOrder, HK_Mode, HK_RegisteredModeHotkey
    for _, key in HK_RegisteredModeHotkey {
        HotIf(HotIfConditionGlobal)
        try Hotkey(key, "Off")
        HotIf()
    }
    HK_RegisteredModeHotkey := Map()
    used := Map()
    HotIf(HotIfConditionGlobal)
    for id in HK_ModeOrder {
        if id = HK_Mode
            continue
        m := HK_Modes.Get(id, 0)
        if !IsObject(m)
            continue
        switchKey := m.Get("switch", "")
        if switchKey = ""
            continue
        if used.Has(switchKey) {
            DebugLog("Mode switch conflict: " switchKey " used by " used[switchKey] " and " id)
            SettingsDiagPush("WARN", "Mode switch conflict", HK_DisplayKey(switchKey) " used by " used[switchKey] " and " id)
            HK_IssueAdd("mode:" id, "switch hotkey " HK_DisplayKey(switchKey) " conflicts with mode " used[switchKey])
            HK_IssueAdd("mode:" used[switchKey], "switch hotkey " HK_DisplayKey(switchKey) " conflicts with mode " id)
            continue
        }
        used[switchKey] := id
        try {
            Hotkey(switchKey, HK_SwitchMode.Bind(id))
            HK_RegisteredModeHotkey[id] := switchKey
        } catch as e {
            DebugLog("Failed to register mode switch hotkey for " id ": " switchKey " - " e.Message)
            SettingsDiagPush("ERR", "Mode switch register failed", id " on " HK_DisplayKey(switchKey) ": " e.Message)
            HK_IssueAdd("mode:" id, "failed to register switch hotkey " HK_DisplayKey(switchKey))
        }
    }
    HotIf()
}

; ============================================================
; Per-mode auto-toggle flags (mode_flags.ini)
; ============================================================
; Each mode can force runtime toggles while it is active. The file lives in
; the mode's settings folder (settings\<mode_id>\mode_flags.ini), so it rides
; along with mode bundles, mode backups and the full config backup/restore.
;
;   [Flags]
;   ltLock   = 1        ; LT Lock always on
;   nav      = 0        ; Navigation always off
;
; Semantics per flag key:
;   - key present + 1  -> hard-forced ON every poll while the mode is active
;   - key present + 0  -> hard-forced OFF every poll while the mode is active
;   - key absent       -> the mode does not manage the toggle (user is free)
;
; On switch-away to a mode that does not manage a toggle the previous mode
; forced, the toggle is released (set to its off state). Active flags are
; enforced continuously by HK_EnforceModeFlags, called from the CheckCSP poll.

; [flagId, display label] pairs. flagId is the INI key and the runtime toggle.
HK_ModeFlagDefs() {
    return [
        ["ltLock",    "LT Lock"],
        ["nav",       "Navigation"],
        ["capslock",  "CapsLock hold"],
        ["tabCombos", "Tab hold"],
        ["reset",     "Reset keys"],
        ["lwin",      "LWin hold"]
    ]
}

HK_ModeFlagFile(id) {
    return ModeSettingsModeDir(id) "\mode_flags.ini"
}

; Flag map of a mode (flagId -> bool). Only explicitly set keys appear.
HK_ModeFlags(id := "") {
    if id = ""
        id := HK_ModeActive()
    flags := Map()
    path := HK_ModeFlagFile(id)
    if !FileExist(path)
        return flags
    for pair in HK_ModeFlagDefs() {
        name := pair[1]
        try v := IniReadIntSafe(path, "Flags", name, "", 0, 1)
        catch
            v := ""
        if v != ""
            flags[name] := !!v
    }
    return flags
}

; Writes a mode's whole flag map, deleting the file when nothing is forced.
HK_SaveModeFlags(id, flags) {
    if flags.Count = 0 {
        if FileExist(HK_ModeFlagFile(id))
            try FileDelete(HK_ModeFlagFile(id))
        return
    }
    try {
        if !DirExist(ModeSettingsModeDir(id))
            DirCreate(ModeSettingsModeDir(id))
        IniDelete(HK_ModeFlagFile(id), "Flags")
        for name, on in flags
            IniWrite(on ? 1 : 0, HK_ModeFlagFile(id), "Flags", name)
    }
}

; Writes a single flag value (used by the switch-away snapshot).
HK_WriteModeFlag(id, name, on) {
    try {
        if !DirExist(ModeSettingsModeDir(id))
            DirCreate(ModeSettingsModeDir(id))
        IniWrite(on ? 1 : 0, HK_ModeFlagFile(id), "Flags", name)
    }
}

; Current runtime state of a toggle the mode flags can manage.
HK_ModeFlagRuntime(name) {
    global LTLock, NavEnabled, CapslockEnabled, TabCombosEnabled, ResetEnabled, LWinEnabled
    switch name {
        case "ltLock":    return LTLock
        case "nav":       return NavEnabled
        case "capslock":  return CapslockEnabled
        case "tabCombos": return TabCombosEnabled
        case "reset":     return ResetEnabled
        case "lwin":      return LWinEnabled
    }
    return false
}

; Forces a runtime toggle to a state, keeping the toolbar/IB buttons and the
; toggle-specific side effects (capslock/tab re-registration, reset watchdog)
; in sync. Returns true when the value actually changed.
HK_ApplyModeToggle(flag, on) {
    global LTLock, IB_LockBtn, NavEnabled, CapslockEnabled, TabCombosEnabled, ResetEnabled, LWinEnabled
    on := !!on
    changed := false
    switch flag {
        case "ltLock":
            changed := (LTLock != on)
            LTLock := on
            if IsObject(IB_LockBtn) {
                IB_LockBtn.Text := LTLock ? IconUse("🔒", "⊠") : IconUse("🔓", "⊡")
                IB_LockBtn.Opt("Background" (LTLock ? "C62828" : "2A2A2A") " c" (LTLock ? "FFFFFF" : "AAAAAA"))
            }
        case "nav":
            changed := (NavEnabled != on)
            NavEnabled := on
            UpdateModeButtons()
        case "capslock":
            changed := (CapslockEnabled != on)
            CapslockEnabled := on
            UpdateModeButtons()
            if changed
                try HK_ReapplyCaps()
        case "tabCombos":
            changed := (TabCombosEnabled != on)
            TabCombosEnabled := on
            UpdateModeButtons()
            if changed
                HK_ReapplyTab()
        case "reset":
            changed := (ResetEnabled != on)
            ResetEnabled := on
            UpdateModeButtons()
            if changed
                try UpdateResetWatchdog()
        case "lwin":
            changed := (LWinEnabled != on)
            LWinEnabled := on
            UpdateModeButtons()
    }
    if changed
        DebugLog("Mode flag '" flag "' forced " (on ? "ON" : "OFF"))
    return changed
}

; Applies flag maps directly: forces every flag present in newFlags to its
; value, and releases toggles present in prevFlags but not in newFlags.
HK_ApplyFlagMaps(newFlags, prevFlags) {
    for pair in HK_ModeFlagDefs() {
        name := pair[1]
        if newFlags.Has(name)
            HK_ApplyModeToggle(name, newFlags[name])
        else if prevFlags.Has(name)
            HK_ApplyModeToggle(name, false)
    }
}

; Applies the new mode's forced toggles, releasing toggles the previous mode
; forced that the new mode does not manage. prevId empty => no release.
HK_ApplyModeFlags(newId, prevId := "") {
    newFlags := HK_ModeFlags(newId)
    prevFlags := prevId = "" ? Map() : HK_ModeFlags(prevId)
    HK_ApplyFlagMaps(newFlags, prevFlags)
}

; Writes the current runtime toggle states back into the flags a mode already
; manages (never adds new keys), so forced flags survive a switch-away and an
; external edit to the runtime state cannot desync the mode snapshot.
HK_SnapshotModeFlags(id := "") {
    if id = ""
        id := ModeSettingsActive()
    flags := HK_ModeFlags(id)
    if flags.Count = 0
        return
    for name, on in flags {
        current := HK_ModeFlagRuntime(name)
        HK_WriteModeFlag(id, name, current)
    }
}

; Continuously enforces the active mode's flags. Idempotent: toggles already at
; their forced state are untouched, so an aligned poll costs nothing.
HK_EnforceModeFlags() {
    flags := HK_ModeFlags()
    if flags.Count = 0
        return
    for name, on in flags
        HK_ApplyModeToggle(name, on)
}

; ============================================================
; Auto mode switching
; ============================================================
; When the "Auto Mode Switch" feature is on, the CheckCSP poll watches the
; active window and switches to any mode whose "auto target window" matches.
; Per-mode target assignment lives in HK_Modes[id]["autoTarget"] (persisted as
; "autoTarget" in the mode's [Mode_<id>] section):
;   ""      = auto-switch off for this mode
;   "win<n>" = switch to this mode when that target window is active
;   "any"    = switch to this mode when any enabled target window is active
; A manual mode switch suppresses auto-switching briefly so the poll cannot
; fight the user; the suppression is skipped for auto-triggered switches.

global _AutoModeSwitchSuppressUntil := 0

HK_AutoSwitchSuppress() {
    global _AutoModeSwitchSuppressUntil
    _AutoModeSwitchSuppressUntil := A_TickCount + 8000
}

; Returns the mode id to auto-switch to for the currently active window, or "".
HK_AutoSwitchTargetMode() {
    global HK_Modes, HK_ModeOrder, HK_TargetWindows
    active := HK_ModeActive()
    for id in HK_ModeOrder {
        if id = active
            continue
        m := HK_Modes.Get(id, 0)
        if !IsObject(m)
            continue
        tgt := m.Get("autoTarget", "")
        if tgt = ""
            continue
        if tgt = "any" {
            if HK_TargetActive()
                return id
            continue
        }
        t := HK_TargetWindows.Get(tgt, 0)
        if !IsObject(t) || !t.Get("enabled", 0)
            continue
        for exe in HK_TargetExeList(t)
            if WinActive("ahk_exe " exe)
                return id
    }
    return ""
}

; Poll entry point, called from CheckCSP. Feature-gated and debounced.
HK_AutoSwitchPoll() {
    global _AutoModeSwitchSuppressUntil
    if !FeatureEnabled("automode")
        return
    if A_TickCount < _AutoModeSwitchSuppressUntil
        return
    target := HK_AutoSwitchTargetMode()
    if target = ""
        return
    HK_SwitchMode(target, true)
}
