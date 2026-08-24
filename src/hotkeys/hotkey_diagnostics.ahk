; HOTKEY DIAGNOSTICS / HEALTH / REPORTS
; ============================================================
; Safe mode, status dashboard, setup validator, action scanner, config doctor and report windows.
; Extracted from hotkey_core.ahk.


UpdateModeButtons() {
    global NavEnabled, NavBtn, CapslockEnabled, CapslockBtn, TabCombosEnabled, TabCombosBtn, LWinEnabled, LWinBtn, ResetEnabled, ResetBtn
    if IsObject(NavBtn) {
        NavBtn.Text := NavEnabled ? IconUse("🖐", "◆") : IconUse("🚫", "X")
        NavBtn.Opt("Background" (NavEnabled ? "E65100" : "2A2A2A") " cFFFFFF")
    }
    if IsObject(CapslockBtn) {
        CapslockBtn.Text := CapslockEnabled ? IconUse("⇪", "C") : IconUse("🚫", "X")
        CapslockBtn.Opt("Background" (CapslockEnabled ? "1565C0" : "2A2A2A") " cFFFFFF")
    }
    if IsObject(TabCombosBtn) {
        TabCombosBtn.Text := TabCombosEnabled ? "Tab" : IconUse("🚫", "X")
        TabCombosBtn.Opt("Background" (TabCombosEnabled ? "2E7D32" : "2A2A2A") " cFFFFFF")
    }
    if IsObject(LWinBtn) {
        LWinBtn.Text := LWinEnabled ? IconUse("⊞", "W") : IconUse("🚫", "X")
        LWinBtn.Opt("Background" (LWinEnabled ? "FF6F00" : "2A2A2A") " cFFFFFF")
    }
    if IsObject(ResetBtn) {
        ResetBtn.Text := ResetEnabled ? IconUse("↺", "R") : IconUse("🚫", "X")
        ResetBtn.Opt("Background" (ResetEnabled ? "6D28D9" : "2A2A2A") " cFFFFFF")
    }
}

SafeMode(*) {
    global HotkeysPaused, NavEnabled, CapslockEnabled, TabCombosEnabled, LWinEnabled, ResetEnabled
    global _TypingState
    global SafeModeActive, SafeModeState, SETTINGS_FILE
    if SafeModeActive {
        HotkeysPaused := SafeModeState.Has("HotkeysPaused") ? SafeModeState["HotkeysPaused"] : false
        NavEnabled := SafeModeState.Has("NavEnabled") ? SafeModeState["NavEnabled"] : true
        CapslockEnabled := SafeModeState.Has("CapslockEnabled") ? SafeModeState["CapslockEnabled"] : true
        TabCombosEnabled := SafeModeState.Has("TabCombosEnabled") ? SafeModeState["TabCombosEnabled"] : true
        LWinEnabled := SafeModeState.Has("LWinEnabled") ? SafeModeState["LWinEnabled"] : true
        ResetEnabled := SafeModeState.Has("ResetEnabled") ? SafeModeState["ResetEnabled"] : true
        SafeModeActive := false
        SafeModeState := Map()
        for k, _ in _TypingState
            _TypingState[k] := false
        ReleaseHeldInputs()
        HK_ReapplyAll()
        UpdateResetWatchdog()
        UpdateModeButtons()
        UpdateHotkeysPauseButton()
        UpdateSafeModeButton()
        try IniWrite(0, SETTINGS_FILE, "SafeMode", "Active")
        try SettingsSyncIniWatcher()
        DebugLog("Safe Mode restored previous states")
        ShowNotify("Safe Mode", "Restored previous toggles")
        return
    }
    SafeModeState := Map(
        "HotkeysPaused", HotkeysPaused,
        "NavEnabled", NavEnabled,
        "CapslockEnabled", CapslockEnabled,
        "TabCombosEnabled", TabCombosEnabled,
        "LWinEnabled", LWinEnabled,
        "ResetEnabled", ResetEnabled
    )
    SafeModeActive := true
    HotkeysPaused := true
    NavEnabled := false
    CapslockEnabled := false
    TabCombosEnabled := false
    LWinEnabled := false
    ResetEnabled := false
    for k, _ in _TypingState
        _TypingState[k] := false
    ReleaseHeldInputs()
    HK_ReapplyAll()
    UpdateResetWatchdog()
    UpdateModeButtons()
    UpdateHotkeysPauseButton()
    UpdateSafeModeButton()
    try {
        IniWrite(1, SETTINGS_FILE, "SafeMode", "Active")
        IniWrite(SafeModeState["HotkeysPaused"] ? 1 : 0, SETTINGS_FILE, "SafeMode", "HotkeysPaused")
        IniWrite(SafeModeState["NavEnabled"] ? 1 : 0, SETTINGS_FILE, "SafeMode", "NavEnabled")
        IniWrite(SafeModeState["CapslockEnabled"] ? 1 : 0, SETTINGS_FILE, "SafeMode", "CapslockEnabled")
        IniWrite(SafeModeState["TabCombosEnabled"] ? 1 : 0, SETTINGS_FILE, "SafeMode", "TabCombosEnabled")
        IniWrite(SafeModeState["LWinEnabled"] ? 1 : 0, SETTINGS_FILE, "SafeMode", "LWinEnabled")
        IniWrite(SafeModeState["ResetEnabled"] ? 1 : 0, SETTINGS_FILE, "SafeMode", "ResetEnabled")
    }
    try SettingsSyncIniWatcher()
    DebugLog("Safe Mode enabled")
    ShowNotify("Safe Mode", "ON - hotkeys paused, modes off")
}

UpdateSafeModeButton() {
    global MainGUI, SafeModeActive
    if !GuiHasCtrl(MainGUI, "btnSafe")
        return
    MainGUI.btnSafe.Text := SafeModeActive ? "SAFE" : "Safe"
    MainGUI.btnSafe.Opt("Background" (SafeModeActive ? "E53935" : "B71C1C") " cFFFFFF")
    UpdateStartupHealthBadge()
}

StartupHealthSnapshot() {
    global SETTINGS_FILE, PIE_SETTINGS_FILE, HOTKEY_SETTINGS_FILE, LINK_SETTINGS_FILE, COLOR_SETTINGS_FILE, SETTINGS_DIR, CONFIG_VERSION
    global PieConfigs, PieQuickHotkeys, PieCount, PieHotkeys, PieNames, PieEnabled
    global LinkItems, ColorItems, SafeModeActive, _settingsNeedUpgrade
    global FirstRunSetup, HotkeyDefs
    if SafeModeActive
        return Map("state", "GUARD", "color", "B71C1C", "detail", "Safe Mode is active", "issues", ["Safe Mode is active"], "count", 1)
    if FirstRunSetup || !FileExist(SETTINGS_FILE)
        return Map("state", "SETUP", "color", "1565C0", "detail", "First run or settings not saved yet", "issues", ["First run or settings not saved yet"], "count", 1)

    issues := []
    try {
        if !DirExist(SETTINGS_DIR)
            issues.Push("settings folder missing")

        files := [
            ["main", SETTINGS_FILE],
            ["pie", PIE_SETTINGS_FILE],
            ["hotkey", HOTKEY_SETTINGS_FILE],
            ["link", LINK_SETTINGS_FILE],
            ["color", COLOR_SETTINGS_FILE]
        ]
        for info in files {
            label := info[1], path := info[2]
            if !FileExist(path) {
                issues.Push(label " settings missing")
                continue
            }
            if IniDuplicateSectionCount(path) || IniDuplicateKeyCount(path)
                issues.Push(label " settings duplicate data")
        }

        cfgVer := FileExist(SETTINGS_FILE) ? IniReadIntSafe(SETTINGS_FILE, "Settings", "ConfigVersion", 0, 0) : 0
        if cfgVer != CONFIG_VERSION || _settingsNeedUpgrade
            issues.Push("config version needs update")

        if !(PieCount >= 1 && PieCount <= 4)
            issues.Push("pie count invalid")
        if PieConfigs.Length < PieCount || PieHotkeys.Length < 4 || PieNames.Length < 4 || PieEnabled.Length < 4
            issues.Push("pie data incomplete")

        quickIssues := 0
        for item in PieQuickHotkeys {
            if !item.Get("enabled", 1) || PieQuickNormalizeScope(item.Get("scope", "all")) = "disabled"
                continue
            if PieQuickIsReservedKey(item.Get("key", "")) || Trim(item.Get("action", "")) = ""
                quickIssues++
        }
        if quickIssues
            issues.Push(quickIssues " quick-pie issue(s)")

        if !IsObject(LinkItems) || LinkItems.Length = 0
            issues.Push("link items not loaded")
        if !IsObject(ColorItems) || ColorItems.Length = 0
            issues.Push("color items not loaded")

        blockedReq := 0
        for d in HotkeyDefs {
            if d.HasOwnProp("enabled") && !d.enabled
                continue
            req := HK_NormalizeRequirement(HK_GetRequirement(d))
            if req != "" && !HK_IsRequirementEnabled(d)
                blockedReq++
        }
        if blockedReq
            issues.Push(blockedReq " enabled hotkey(s) blocked by requirements")
    } catch as err {
        issues.Push("health check error: " err.Message)
    }

    if issues.Length
        return Map("state", "WARN", "color", "F9A825", "detail", issues[1], "issues", issues, "count", issues.Length)
    return Map("state", "OK", "color", "2E7D32", "detail", "Startup settings look healthy", "issues", [], "count", 0)
}

UpdateStartupHealthBadge(*) {
    global MainGUI
    if !GuiHasCtrl(MainGUI, "btnHealthBadge")
        return
    snap := StartupHealthSnapshot()
    MainGUI.btnHealthBadge.Text := "Health: " snap["state"]
    MainGUI.btnHealthBadge.Opt("Background" snap["color"] " cFFFFFF")
    detail := snap["detail"]
    if snap.Has("issues") && IsObject(snap["issues"]) && snap["issues"].Length > 1 {
        detail := ""
        for issue in snap["issues"]
            detail .= (detail = "" ? "" : "`n") issue
    }
    AddHoverPopup(MainGUI.btnHealthBadge,
        "Startup Health: " snap["state"] "\n"
        detail "\n\n"
        "OK = saved settings look healthy.\n"
        "SETUP = first run / settings not saved yet.\n"
        "WARN = config issue found.\n"
        "GUARD = Safe Mode is active.\n\n"
        "Click to open Settings Health.")
}

RestoreSafeMode() {
    global HotkeysPaused, NavEnabled, CapslockEnabled, TabCombosEnabled, LWinEnabled, ResetEnabled
    global SafeModeActive, SafeModeState, SETTINGS_FILE
    try {
        wasActive := IniRead(SETTINGS_FILE, "SafeMode", "Active", 0)
    } catch
        wasActive := 0
    if wasActive != 1
        return
    SafeModeState := Map(
        "HotkeysPaused", !!IniReadIntSafe(SETTINGS_FILE, "SafeMode", "HotkeysPaused", 1, 0, 1),
        "NavEnabled",    !!IniReadIntSafe(SETTINGS_FILE, "SafeMode", "NavEnabled", 0, 0, 1),
        "CapslockEnabled", !!IniReadIntSafe(SETTINGS_FILE, "SafeMode", "CapslockEnabled", 0, 0, 1),
        "TabCombosEnabled", !!IniReadIntSafe(SETTINGS_FILE, "SafeMode", "TabCombosEnabled", 0, 0, 1),
        "LWinEnabled",   !!IniReadIntSafe(SETTINGS_FILE, "SafeMode", "LWinEnabled", 0, 0, 1),
        "ResetEnabled",  !!IniReadIntSafe(SETTINGS_FILE, "SafeMode", "ResetEnabled", 0, 0, 1)
    )
    SafeModeActive := true
    HotkeysPaused := true
    NavEnabled := false
    CapslockEnabled := false
    TabCombosEnabled := false
    LWinEnabled := false
    ResetEnabled := false
    HK_ReapplyAll()
    UpdateResetWatchdog()
    UpdateSafeModeButton()
    DebugLog("Safe Mode restored from INI")
}

global _statusGUI := 0

; Scans the current configuration for hotkey collisions the user should know
; about before applying: effective hotkeys (base keys adjusted by the active
; active mode) shared by two or more actions, and mode switch hotkeys
; shared by two or more modes. Pure config check - nothing is registered.
; Returns an array of human-readable collision lines.
HK_ScanCollisions() {
    global HK_Modes, HK_ModeOrder
    active := HK_ModeActive()
    m := 0
    if IsObject(HK_Modes.Get(active, 0))
        m := HK_Modes[active]
    lines := []
    usedBy := Map()
    for d in HotkeyDefs {
        if !HK_IsRequirementEnabled(d)
            continue
        base := HK_Get(d.id, d.def)
        if base = "" || base = "-"
            continue
        eff := HK_ModeEffectiveKey(d.id, base, m)
        if eff = "" || eff = "-"
            continue
        if !usedBy.Has(eff)
            usedBy[eff] := []
        usedBy[eff].Push(d)
    }
    for key, defs in usedBy {
        if defs.Length < 2
            continue
        names := ""
        for d in defs
            names .= (names = "" ? "" : " / ") d.desc
        lines.Push(HK_DisplayKey(key) ": " names)
    }
    switchUsed := Map()
    for id in HK_ModeOrder {
        mm := HK_Modes.Get(id, 0)
        if !IsObject(mm)
            continue
        sw := mm.Get("switch", "")
        if sw = ""
            continue
        if switchUsed.Has(sw) {
            lines.Push("Mode switch " HK_DisplayKey(sw) ": " switchUsed[sw] " / " mm.Get("name", id))
        } else
            switchUsed[sw] := mm.Get("name", id)
    }
    return lines
}

; Non-blocking warning shown right after a user-triggered save/apply. Silently
; returns when no collisions exist.
HK_WarnCollisions() {
    lines := HK_ScanCollisions()
    if lines.Length = 0
        return
    body := "Collision" (lines.Length = 1 ? ": " : "s: ") "`n"
    shown := 0
    for ln in lines {
        body .= "- " ln "`n"
        shown++
        if shown >= 3
            break
    }
    if lines.Length > shown
        body .= "... " (lines.Length - shown) " more - see Status Dashboard"
    ShowNotify("Hotkey collision warning", body, "0xE53935")
}

BuildStatusDashboardText() {
    global HotkeysPaused, NavEnabled, CapslockEnabled, TabCombosEnabled, LWinEnabled, ResetEnabled
    global SafeModeActive
    global ReqAnimationEnabled, ReqNastarEnabled, AutoSaveOn, AutoSaveInterval, NotifyEnabled, NotifyMonitor
    global Scale, Speed, InbetweenMode, LTLock, _debugLog
    global HotkeyDefs
    global SCRIPT_VERSION
    cspOpen := WinExist("ahk_exe CLIPStudioPaint.exe") ? "Yes" : "No"
    cspActive := WinActive("ahk_exe CLIPStudioPaint.exe") ? "Yes" : "No"
    try ltState := IsLTActive() ? "On" : "Off"
    catch
        ltState := "Unknown"
    conflicts := 0
    disabledReq := 0
    scan := HK_ScanCollisions()
    conflicts := scan.Length
    for d in HotkeyDefs {
        if !HK_IsRequirementEnabled(d)
            disabledReq++
    }
    collSample := ""
    collShown := 0
    for ln in scan {
        collSample .= "    - " ln "`n"
        collShown++
        if collShown >= 4
            break
    }
    if scan.Length > collShown
        collSample .= "    ... " (scan.Length - collShown) " more`n"
    lastLog := _debugLog.Length ? _debugLog[_debugLog.Length] : "(none)"
    monitorLabel := NotifyMonitor = 0 ? "Primary" : "Monitor " NotifyMonitor
    return "Toolkit`n"
        . "  Version: " SCRIPT_VERSION "`n`n"
        . "CSP`n"
        . "  Open: " cspOpen "`n"
        . "  Active: " cspActive "`n"
        . "  Light Table Pixel: " ltState "`n`n"
        . "Hotkeys`n"
        . "  HK: " (HotkeysPaused ? "Paused" : "Active") " | Safe Mode: " (SafeModeActive ? "On" : "Off") "`n"
        . "  Nav: " (NavEnabled ? "On" : "Off") " | Capslock: " (CapslockEnabled ? "On" : "Off") " | Tab: " (TabCombosEnabled ? "On" : "Off") "`n"
        . "  LWin: " (LWinEnabled ? "On" : "Off") " | Reset Watchdog: " (ResetEnabled ? "On" : "Off") "`n"
        . "  Hotkey conflicts: " conflicts "`n"
        . collSample
        . "  Disabled by requirements: " disabledReq "`n`n"
        . "System`n"
        . "  Auto Save: " (AutoSaveOn ? "On every " AutoSaveInterval "s" : "Off") "`n"
        . "  Requirements: Animation_autoaction=" (ReqAnimationEnabled ? "Yes" : "No") ", Nastar=" (ReqNastarEnabled ? "Yes" : "No") "`n"
        . "  IB Direction: " InbetweenMode " | LT Lock: " (LTLock ? "On" : "Off") "`n"
        . "  UI Scale: " Round(Scale * 100) "% | Scroll Power: " Speed "`n"
        . "  Notifications: " (NotifyEnabled ? "On" : "Off") " | Monitor: " monitorLabel "`n`n"
        . "Last Debug`n"
        . "  " lastLog
}

RefreshStatusDashboard(*) {
    global _statusGUI
    if !IsObject(_statusGUI) || !_statusGUI.HasProp("statusEd")
        return
    _statusGUI.statusEd.Value := BuildStatusDashboardText()
}

ShowSettingsLoadDiagnostics(*) {
    ShowReportWindow(
        "Settings Load Diagnostics",
        SettingsDiagText(),
        [["Refresh", ShowSettingsLoadDiagnostics], ["Clear", ClearSettingsDiagnostics]]
    )
}

ShowStatusDashboard(*) {
    global _statusGUI
    txt := BuildStatusDashboardText()
    if IsObject(_statusGUI) {
        try if _statusGUI.Hwnd {
            _statusGUI.statusEd.Value := txt
            _statusGUI.Show()
            return
        }
    }
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Status Dashboard")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)
    boxW := S(642)
    btnW := S(76)
    btnGap := S(5)
    dlg.SetFont("s" S(9) " c000000", "Consolas")
    statusEd := dlg.AddEdit("xm w" boxW " h" S(320) " ReadOnly VScroll c000000 BackgroundFFFFFF", txt)
    dlg.statusEd := statusEd
    statusEd.SetFont("s" S(9), "Consolas")
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.AddButton("xm y+" S(12) " w" btnW " h" S(28), "Health").OnEvent("Click", ShowSettingsHealth)
    dlg.AddButton("x+" btnGap " yp w" btnW " h" S(28), "Self-Heal").OnEvent("Click", SelfHealSettings)
    dlg.AddButton("x+" btnGap " yp w" btnW " h" S(28), "Validator").OnEvent("Click", ShowCSPSetupValidator)
    dlg.AddButton("x+" btnGap " yp w" btnW " h" S(28), "Scanner").OnEvent("Click", ShowBrokenActionScanner)
    dlg.AddButton("x+" btnGap " yp w" btnW " h" S(28), "Conflict").OnEvent("Click", ShowActionConflictTester)
    dlg.AddButton("x+" btnGap " yp w" btnW " h" S(28), "Diag").OnEvent("Click", ShowSettingsLoadDiagnostics)
    dlg.AddButton("x+" btnGap " yp w" btnW " h" S(28), "Refresh").OnEvent("Click", RefreshStatusDashboard)
    btnClose := dlg.AddButton("x+" btnGap " yp w" btnW " h" S(28) " Default", "Close")
    btnClose.OnEvent("Click", (*) => (_statusGUI := 0, dlg.Destroy()))
    dlg.OnEvent("Close", (*) => (_statusGUI := 0))
    dlg.Show("AutoSize")
    _statusGUI := dlg
    SetTimer((*) => btnClose.Focus(), -10)
}

StatusLine(ok, label, detail := "") {
    return (ok ? "[OK] " : "[FIX] ") label (detail != "" ? " - " detail : "") "`r`n"
}

ShowCSPSetupValidator(*) {
    global SETTINGS_FILE, HotkeysPaused, ReqAnimationEnabled, ReqNastarEnabled, LT_X, LT_Y, LT_Color
    global LT_ClickX, LT_ClickY, ColorClick1X, ColorClick1Y, ColorClick2X, ColorClick2Y
    global PieCount, PieHotkeys, _pieDelayMs, _pieDeadzone, _pieStyle
    txt := "CSP Setup Validator`r`n"
        . "Checks what the toolkit can verify automatically. CSP shortcut assignments still need manual confirmation inside CSP.`r`n`r`n"
        . "How to read this:`r`n"
        . "- [OK] means the detected setting looks ready.`r`n"
        . "- [FIX] means open System Settings, CSP shortcut settings, or Auto Actions and adjust that item.`r`n"
        . "- Use this after first run, after importing settings, or when LT / pie hotkeys feel wrong.`r`n`r`n"
    txt .= StatusLine(FileExist(SETTINGS_FILE), "Settings file", SETTINGS_FILE)
    txt .= StatusLine(WinExist("ahk_exe CLIPStudioPaint.exe"), "Clip Studio Paint is running")
    txt .= StatusLine(HotkeysPaused, "HK starts paused/safe while setting up", HotkeysPaused ? "Paused" : "Active")
    txt .= StatusLine(ReqAnimationEnabled, "Animation_autoaction.laf enabled", ReqAnimationEnabled ? "Enabled" : "Disabled")
    txt .= StatusLine(ReqNastarEnabled, "Nastar.laf enabled", ReqNastarEnabled ? "Enabled" : "Disabled")
    ltColorVal := 0
    try
        ltColorVal := Integer(LT_Color)
    txt .= StatusLine(LT_X > 0 && LT_Y > 0, "LT detection pixel", "X " LT_X ", Y " LT_Y ", Color #" Format("{:06X}", ltColorVal))
    txt .= StatusLine(LT_ClickX > 0 && LT_ClickY > 0, "LT reset click coordinate", "X " LT_ClickX ", Y " LT_ClickY)
    txt .= StatusLine(ColorClick1X > 0 && ColorClick1Y > 0, "LT Image 1 click coordinate", "X " ColorClick1X ", Y " ColorClick1Y)
    txt .= StatusLine(ColorClick2X > 0 && ColorClick2Y > 0, "LT Image 2 click coordinate", "X " ColorClick2X ", Y " ColorClick2Y)
    txt .= StatusLine(PieCount >= 1 && PieCount <= 4, "Pie count", PieCount)
    txt .= StatusLine(_pieDelayMs >= 0 && _pieDelayMs <= 2000, "Pie hover delay", _pieDelayMs " ms")
    txt .= StatusLine(_pieDeadzone >= 0 && _pieDeadzone <= 300, "Pie deadzone", _pieDeadzone " px")
    txt .= StatusLine(true, "Pie style", PieNormalizeStyle(_pieStyle))
    Loop 4 {
        hk := PieHotkeys.Length >= A_Index ? PieNormalizeHotkey(PieHotkeys[A_Index]) : ""
        txt .= StatusLine(A_Index > PieCount || hk != "", "Pie " A_Index " open hotkey", A_Index > PieCount ? "Disabled by count" : hk)
    }
    txt .= "`r`nManual CSP shortcut checklist:`r`n"
        . "- Options > Animation cel palette > Enable/disable light table tool = Ctrl+Shift+Alt+W`r`n"
        . "- Menu commands > Edit > Change Canvas Size = Ctrl+/`r`n"
        . "- Menu commands > Edit > Canvas Properties = Ctrl+Shift+Alt+;`r`n"
        . "- Animation > Timeline > Change settings = Shift+Alt+S`r`n"
        . "- Auto Actions > Animation_autoaction: 50/33/66/25/75/40/60 = Ctrl+1..7`r`n"
    ShowReportWindow("CSP Setup Validator", txt)
}

ShowBrokenActionScanner(*) {
    global PieConfigs, PieNames, PieCount, LinkItems, HotkeyDefs, HK_UserDefs
    broken := 0
    txt := "Broken Action Scanner`r`n"
        . "This checks empty actions, missing files, disabled requirements, and missing AHK functions.`r`n`r`n"
        . "How to read this:`r`n"
        . "- [FIX] Empty action: edit that pie/link/hotkey and add an action, or disable the slot.`r`n"
        . "- [FIX] Missing script/file: browse to the new path, or keep the button empty and add it later.`r`n"
        . "- [FIX] Missing function: choose a loaded function from Function Picker or fix the function name.`r`n"
        . "- [FIX] Requirement disabled: enable Animation_autoaction.laf / Nastar.laf in System Settings if installed.`r`n`r`n"

    txt .= "Pie Menus`r`n"
    Loop PieCount {
        p := A_Index
        name := PieNames.Length >= p ? PieNames[p] : PieDefaultName(p)
        if PieConfigs.Length < p {
            txt .= StatusLine(false, "Pie " p " (" name ")", "Missing pie configuration")
            broken++
            continue
        }
        items := PieConfigs[p]
        for i, item in items {
            if !item.Get("enabled", 1) || item.Get("type", "disabled") = "disabled"
                continue
            type := item.Get("type", "disabled")
            action := Trim(item.Get("action", ""))
            label := item.Get("label", PieSlotName(i))
            prefix := "Pie " p " (" name ") / " PieSlotName(i) " / " label
            if action = "" {
                txt .= StatusLine(false, prefix, "Empty action")
                broken++
            } else if type = "function" && !PieFunctionAvailable(action) {
                txt .= StatusLine(false, prefix, "Missing function: " action)
                broken++
            } else if type = "script" && !FileExist(action) {
                txt .= StatusLine(false, prefix, "Missing script/file: " action)
                broken++
            } else if !PieRequirementEnabled(item.Get("requirement", "")) {
                txt .= StatusLine(false, prefix, "Requirement currently disabled: " HK_NormalizeRequirement(item.Get("requirement", "")))
                broken++
            }
        }
    }
    if broken = 0
        txt .= StatusLine(true, "Pie menus", "No broken active pie actions found")

    linkBroken := 0
    txt .= "`r`nLink Buttons`r`n"
    for idx, item in LinkItems {
        if !item.Get("enabled", true)
            continue
        t := item.Get("type", "")
        label := item.Get("label", item.Get("hover", "Link " idx))
        detail := "Link " idx " / " label
        if t = "script" {
            target := Trim(item.Get("target", ""))
            if target = "" || !FileExist(target) {
                txt .= StatusLine(false, detail, "Missing script/file: " target)
                linkBroken++, broken++
            }
        } else if t = "url" {
            target := Trim(item.Get("target", ""))
            if target = "" {
                txt .= StatusLine(false, detail, "Empty URL")
                linkBroken++, broken++
            }
        } else if t = "action" {
            keys := Trim(item.Get("keys", ""))
            if keys = "" {
                txt .= StatusLine(false, detail, "Empty keystroke action")
                linkBroken++, broken++
            }
        } else if t = "system" && item.Has("fn") {
            fnAction := item.Get("fn", "")
            fnName := PieExtractFunctionName(fnAction)
            if fnName = "" || !PieFunctionAvailable(fnName) {
                txt .= StatusLine(false, detail, "Missing system function: " fnAction)
                linkBroken++, broken++
            }
        }
    }
    if linkBroken = 0
        txt .= StatusLine(true, "Link buttons", "No broken enabled link actions found")

    userBroken := 0
    txt .= "`r`nUser Hotkeys`r`n"
    for d in HK_UserDefs {
        scriptFile := d.HasProp("scriptFile") ? d.scriptFile : ""
        if scriptFile = "" || !FileExist(scriptFile) {
            txt .= StatusLine(false, d.desc, "Missing user script file: " scriptFile)
            userBroken++, broken++
        }
    }
    if userBroken = 0
        txt .= StatusLine(true, "User hotkeys", "No missing user script files found")

    dupes := 0
    seen := Map()
    txt .= "`r`nHotkey Duplicates`r`n"
    for d in HotkeyDefs {
        key := HK_Get(d.id, d.def)
        norm := StrLower(Trim(key))
        if norm = "" || norm = "-"
            continue
        req := d.group "|" norm
        if seen.Has(req) {
            txt .= StatusLine(false, d.desc, "Duplicates " seen[req] " on " key)
            dupes++, broken++
        } else {
            seen[req] := d.desc
        }
    }
    if dupes = 0
        txt .= StatusLine(true, "Hotkey duplicates", "No duplicate active definitions found")

    txt .= "`r`nResult: " (broken = 0 ? "No broken actions found." : broken " issue(s) found.")
    ShowReportWindow("Broken Action Scanner", txt)
}

OpenDevTools(*) {
    global _DevToolsIncluded, _DevToolsHandler
    if _DevToolsIncluded && IsObject(_DevToolsHandler) {
        try {
            _DevToolsHandler.Call()
            return
        } catch as e {
            ShowReportWindow("Dev Tools Error", "Developer tools are included but failed to open.`r`n`r`n" e.Message)
            return
        }
    }
    try {
        ShowDevTools.Call()
    } catch {
        ShowReportWindow("Dev Tools Disabled",
            "Developer/release tools are not included in this build.`r`n`r`n"
            . "To enable them, include src\dev\dev.ahk from the main script.")
    }
}

DevToolsAvailable(*) {
    global _DevToolsIncluded, _DevToolsHandler
    if _DevToolsIncluded && IsObject(_DevToolsHandler)
        return true
    return IsSet(ShowDevTools) && Type(ShowDevTools) = "Func"
}

ShowActionConflictTester(*) {
    global HotkeyDefs, PieQuickHotkeys, PieCount, PieHotkeys
    txt := "Action Conflict Tester`r`n"
        . "Checks duplicate hotkeys, quick-pie collisions, reserved quick-pie keys, and duplicate pie open hotkeys.`r`n`r`n"
    issues := 0

    txt .= "Hotkey Conflicts`r`n"
    seen := Map()
    dupes := 0
    for d in HotkeyDefs {
        key := HK_Get(d.id, d.def)
        norm := StrLower(Trim(key))
        if norm = "" || norm = "-"
            continue
        bucket := d.group "|" norm
        if seen.Has(bucket) {
            txt .= "[FIX] " d.desc " duplicates " seen[bucket] " on " key "`r`n"
            dupes++, issues++
        } else
            seen[bucket] := d.desc
    }
    if dupes = 0
        txt .= "[OK] No duplicate hotkey definitions found.`r`n"

    txt .= "`r`nPie Quick Conflicts`r`n"
    quickIssues := 0
    seenQuick := Map()
    for item in PieQuickHotkeys {
        if !item.Get("enabled", 1)
            continue
        key := PieQuickNormalizeKey(item.Get("key", ""))
        scope := PieQuickNormalizeScope(item.Get("scope", "all"))
        if key = "" || key = "-" || scope = "disabled"
            continue
        label := item.Get("label", "Quick Hotkey")
        if PieQuickIsReservedKey(key) {
            txt .= "[FIX] " label " uses reserved key " key " (1-0 stay reserved for pie slots).`r`n"
            quickIssues++, issues++
            continue
        }
        bucket := scope "|" StrLower(key)
        if seenQuick.Has(bucket) {
            txt .= "[FIX] " label " conflicts with " seenQuick[bucket] " on " key " in " PieQuickScopeLabel(scope) ".`r`n"
            quickIssues++, issues++
        } else
            seenQuick[bucket] := label
    }
    if quickIssues = 0
        txt .= "[OK] No quick-pie collisions found.`r`n"

    txt .= "`r`nPie Open Hotkeys`r`n"
    pieOpenIssues := 0
    seenPie := Map()
    Loop PieCount {
        key := PieNormalizeHotkey(PieHotkeys.Length >= A_Index ? PieHotkeys[A_Index] : "")
        if key = "" || key = "-"
            continue
        if seenPie.Has(StrLower(key)) {
            txt .= "[FIX] Pie " A_Index " duplicates Pie " seenPie[StrLower(key)] " open hotkey " key ".`r`n"
            pieOpenIssues++, issues++
        } else
            seenPie[StrLower(key)] := A_Index
    }
    if pieOpenIssues = 0
        txt .= "[OK] Pie open hotkeys are unique.`r`n"

    txt .= "`r`nPie Open vs Hotkeys`r`n"
    pieVsHotkeyIssues := 0
    Loop PieCount {
        pieKey := PieNormalizeHotkey(PieHotkeys.Length >= A_Index ? PieHotkeys[A_Index] : "")
        if pieKey = ""
            continue
        for d in HotkeyDefs {
            hk := HK_Get(d.id, d.def)
            if StrLower(Trim(hk)) = StrLower(Trim(pieKey)) {
                txt .= "[FIX] Pie " A_Index " open hotkey " pieKey " matches hotkey " d.desc " (" d.group ").`r`n"
                pieVsHotkeyIssues++, issues++
            }
        }
    }
    if pieVsHotkeyIssues = 0
        txt .= "[OK] Pie open hotkeys do not overlap saved toolkit hotkeys.`r`n"

    txt .= "`r`nResult: " (issues = 0 ? "No action conflicts found." : issues " conflict issue(s) found.")
    ShowReportWindow("Action Conflict Tester", txt)
}

ShowConfigVersionReport(*) {
    global SETTINGS_FILE, PIE_SETTINGS_FILE, HOTKEY_SETTINGS_FILE, LINK_SETTINGS_FILE, COLOR_SETTINGS_FILE, CONFIG_VERSION, _settingsNeedUpgrade
    files := [
        ["Main settings", SETTINGS_FILE],
        ["Pie settings", PIE_SETTINGS_FILE],
        ["Hotkey settings", HOTKEY_SETTINGS_FILE],
        ["Link settings", LINK_SETTINGS_FILE],
        ["Color settings", COLOR_SETTINGS_FILE]
    ]
    txt := "Config Version Report`r`n"
        . "Use this when settings feel like they loaded defaults, after importing backups, or after big toolkit upgrades.`r`n`r`n"
    current := FileExist(SETTINGS_FILE) ? IniReadIntSafe(SETTINGS_FILE, "Settings", "ConfigVersion", 0, 0) : 0
    txt .= StatusLine(current = CONFIG_VERSION, "Main config version", current " / " CONFIG_VERSION)
    txt .= StatusLine(!_settingsNeedUpgrade, "Upgrade flag in memory", _settingsNeedUpgrade ? "Upgrade/save still needed" : "Up to date")
    txt .= "`r`nFiles`r`n"
    for info in files {
        label := info[1], path := info[2]
        exists := FileExist(path)
        txt .= StatusLine(exists, label, path)
        if exists
            txt .= StatusLine(true, label " size", FileGetSize(path) " bytes")
    }
    txt .= "`r`nDiagnostics snapshot`r`n"
        . SettingsDiagText()
    ShowReportWindow("Config Version Report", txt, [["Self-Heal", SelfHealSettings], ["Diagnostics", ShowSettingsLoadDiagnostics]])
}

ShowSettingsHealth(*) {
    ShowReportWindow("Settings Health", BuildSettingsHealthText(), [
        ["Self-Heal", SettingsHealthSelfHealRefresh, "refresh"],
        ["Version", ShowConfigVersionReport],
        ["Refresh", BuildSettingsHealthText, "refresh"]
    ])
}

SettingsHealthSelfHealRefresh(*) {
    SelfHealSettings()
    return BuildSettingsHealthText()
}

BuildSettingsHealthText(*) {
    global SETTINGS_FILE, PIE_SETTINGS_FILE, HOTKEY_SETTINGS_FILE, LINK_SETTINGS_FILE, COLOR_SETTINGS_FILE, SETTINGS_DIR, CONFIG_VERSION
    global PieConfigs, SubPieConfigs, PieQuickHotkeys, PieCount, PieHotkeys, PieNames
    global HotkeyDefs, LinkItems, HK_UserScriptDir
    UpdateStartupHealthBadge()
    snap := StartupHealthSnapshot()
    txt := "Settings Health`r`n"
        . "Checks split settings files, common data shape problems, and likely slow-save causes.`r`n`r`n"
        . "How to read this:`r`n"
        . "- [OK] means the settings file or data shape is healthy.`r`n"
        . "- [FIX] duplicate sections/keys can make settings harder to read and slower to save.`r`n"
        . "- [FIX] pie or quick-pie issues usually mean a reset/import was interrupted or a preset needs saving again.`r`n"
        . "- Backup settings before doing big cleanup if the current setup is important.`r`n`r`n"
        . "Startup Badge`r`n"
    if snap["state"] = "OK" {
        txt .= StatusLine(true, "Health badge state", snap["state"] " - " snap["detail"])
    } else {
        issues := (snap.Has("issues") && IsObject(snap["issues"]) && snap["issues"].Length) ? snap["issues"] : [snap["detail"]]
        firstIssue := true
        for issue in issues {
            label := firstIssue ? "Health badge state" : "Health badge issue"
            detail := firstIssue ? snap["state"] " - " issue : issue
            txt .= StatusLine(false, label, detail)
            firstIssue := false
        }
    }
    txt .= "`r`n"
    files := [
        ["Main settings", SETTINGS_FILE],
        ["Pie settings", PIE_SETTINGS_FILE],
        ["Hotkey settings", HOTKEY_SETTINGS_FILE],
        ["Link settings", LINK_SETTINGS_FILE],
        ["Color settings", COLOR_SETTINGS_FILE]
    ]
    txt .= "Files`r`n"
    for info in files {
        label := info[1], path := info[2]
        txt .= StatusLine(FileExist(path), label, path)
        if FileExist(path) {
            txt .= StatusLine(IniDuplicateSectionCount(path) = 0, label " duplicate sections", IniDuplicateSectionCount(path))
            txt .= StatusLine(IniDuplicateKeyCount(path) = 0, label " duplicate keys", IniDuplicateKeyCount(path))
            txt .= StatusLine(IniLegacyKeyCount(path) = 0, label " legacy keys", IniLegacyKeyCount(path))
        }
    }
    cfgVer := FileExist(SETTINGS_FILE) ? IniReadIntSafe(SETTINGS_FILE, "Settings", "ConfigVersion", 0, 0) : 0
    txt .= StatusLine(cfgVer = CONFIG_VERSION, "Config version", cfgVer " / " CONFIG_VERSION)
    txt .= StatusLine(DirExist(SETTINGS_DIR), "Settings folder", SETTINGS_DIR)
    txt .= StatusLine(true, "User script library folder", HK_UserScriptDir . (DirExist(HK_UserScriptDir) ? "" : " (does not exist; expected empty)"))

    txt .= "`r`nPie Data`r`n"
    txt .= StatusLine(PieCount >= 1 && PieCount <= 4, "Pie count", PieCount)
    txt .= StatusLine(PieConfigs.Length >= PieCount, "Pie config array", PieConfigs.Length " config(s)")
    Loop PieCount {
        p := A_Index
        name := PieNames.Length >= p ? PieNames[p] : PieDefaultName(p)
        hk := PieHotkeys.Length >= p ? PieNormalizeHotkey(PieHotkeys[p]) : ""
        cfgOk := PieConfigs.Length >= p && PieConfigs[p].Length >= 10
        txt .= StatusLine(cfgOk, "Pie " p " " name, (hk = "" ? "No open hotkey" : hk))
    }
    txt .= StatusLine(SubPieConfigs.Length >= 1, "Sub-pie configs", SubPieConfigs.Length)
    txt .= StatusLine(PieQuickHotkeys.Length >= 0, "Pie Quick Hotkeys", PieQuickHotkeys.Length)

    quickIssues := 0
    for item in PieQuickHotkeys {
        if !item.Get("enabled", 1) || PieQuickNormalizeScope(item.Get("scope", "all")) = "disabled"
            continue
        if PieQuickIsReservedKey(item.Get("key", "")) || Trim(item.Get("action", "")) = ""
            quickIssues++
    }
    txt .= StatusLine(quickIssues = 0, "Pie Quick active items", quickIssues ? quickIssues " issue(s)" : "No reserved/empty active quick actions")

    txt .= "`r`nRuntime Data`r`n"
    txt .= StatusLine(HotkeyDefs.Length > 0, "Hotkey definitions", HotkeyDefs.Length)
    txt .= StatusLine(LinkItems.Length > 0, "Link button items", LinkItems.Length)
    scriptCount := 0
    if DirExist(HK_UserScriptDir) {
        Loop Files HK_UserScriptDir "\*.ahk"
            scriptCount++
    }
    txt .= StatusLine(true, "User function/script files", scriptCount)

    txt .= "`r`nLegacy Keys`r`n"
    for info in files {
        label := info[1], path := info[2]
        if !FileExist(path)
            continue
        legacy := IniLegacyKeyReport(path)
        txt .= StatusLine(legacy = "", label, legacy = "" ? "No known stale keys found" : legacy)
    }

    txt .= "`r`nTip`r`n"
        . "If save feels slow, keep large/preset data in the split files under the settings folder. This health check also flags duplicate INI sections that make reads/writes heavier.`r`n"
    return txt
}

ShowConfigDoctor(*) {
    global SETTINGS_FILE, PIE_SETTINGS_FILE, HOTKEY_SETTINGS_FILE, LINK_SETTINGS_FILE, COLOR_SETTINGS_FILE, SETTINGS_DIR, CONFIG_VERSION
    global PieConfigs, SubPieConfigs, PieQuickHotkeys, PieCount, PieHotkeys, PieNames, PieEnabled
    global LinkItems, ColorItems, ColorLayout, _pieStyle, _pieDelayMs, _pieDeadzone, HK_UserScriptDir
    issues := 0
    txt := "Config Doctor`r`n"
        . "Checks settings drift that can make the toolkit load defaults, forget UI choices, or save slowly.`r`n"
        . "Use Self-Heal when this report shows missing files, duplicate INI data, stale version, or malformed pie/color data.`r`n`r`n"

    files := [
        ["Settings folder", SETTINGS_DIR, "dir"],
        ["Main settings", SETTINGS_FILE, "file"],
        ["Pie settings", PIE_SETTINGS_FILE, "file"],
        ["Hotkey settings", HOTKEY_SETTINGS_FILE, "file"],
        ["Link settings", LINK_SETTINGS_FILE, "file"],
        ["Color settings", COLOR_SETTINGS_FILE, "file"],
        ["User function folder", HK_UserScriptDir, "dir"]
    ]
    txt .= "Files`r`n"
    for info in files {
        label := info[1], path := info[2], kind := info[3]
        exists := kind = "dir" ? DirExist(path) : FileExist(path)
        if !exists
            issues++
        txt .= StatusLine(exists, label, path)
        if exists && kind = "file" {
            dupSec := IniDuplicateSectionCount(path)
            dupKey := IniDuplicateKeyCount(path)
            legacy := IniLegacyKeyCount(path)
            if dupSec || dupKey || legacy
                issues++
            txt .= StatusLine(dupSec = 0, label " duplicate sections", dupSec)
            txt .= StatusLine(dupKey = 0, label " duplicate keys", dupKey)
            txt .= StatusLine(legacy = 0, label " legacy keys", legacy ? IniLegacyKeyReport(path) : "None")
            txt .= StatusLine(FileGetSize(path) < 1024 * 1024, label " size", FileGetSize(path) " bytes")
        }
    }

    cfgVer := FileExist(SETTINGS_FILE) ? IniReadIntSafe(SETTINGS_FILE, "Settings", "ConfigVersion", 0, 0) : 0
    if cfgVer != CONFIG_VERSION
        issues++
    txt .= "`r`nRuntime Settings`r`n"
    txt .= StatusLine(cfgVer = CONFIG_VERSION, "Config version", cfgVer " / " CONFIG_VERSION)
    txt .= StatusLine(ColorLayout = "V" || ColorLayout = "H", "Color GUI layout", ColorLayout)
    txt .= StatusLine(PieNormalizeStyle(_pieStyle) = _pieStyle || _pieStyle != "", "Pie style", PieNormalizeStyle(_pieStyle))
    txt .= StatusLine(_pieDelayMs >= 0 && _pieDelayMs <= 2000, "Pie delay", _pieDelayMs " ms")
    txt .= StatusLine(_pieDeadzone >= 0 && _pieDeadzone <= 300, "Pie deadzone", _pieDeadzone " px")

    txt .= "`r`nPie Data`r`n"
    pieShapeOk := PieCount >= 1 && PieCount <= 4 && PieConfigs.Length >= PieCount && PieHotkeys.Length >= 4 && PieNames.Length >= 4
    if !pieShapeOk
        issues++
    txt .= StatusLine(PieCount >= 1 && PieCount <= 4, "Pie count", PieCount)
    txt .= StatusLine(PieConfigs.Length >= PieCount, "Pie config count", PieConfigs.Length " / " PieCount)
    txt .= StatusLine(PieHotkeys.Length >= 4, "Pie hotkey slots", PieHotkeys.Length)
    txt .= StatusLine(PieNames.Length >= 4, "Pie name slots", PieNames.Length)
    txt .= StatusLine(PieEnabled.Length >= 4, "Pie enable slots", PieEnabled.Length)
    Loop PieCount {
        p := A_Index
        ok := PieConfigs.Length >= p && PieConfigs[p].Length >= 10
        if !ok
            issues++
        txt .= StatusLine(ok, "Pie " p " slots", ok ? PieConfigs[p].Length : "Missing")
    }
    txt .= StatusLine(SubPieConfigs.Length >= 1, "Sub-pie configs", SubPieConfigs.Length)
    txt .= StatusLine(PieQuickHotkeys.Length >= 0, "Quick-pie hotkeys", PieQuickHotkeys.Length)

    txt .= "`r`nGUI Data`r`n"
    txt .= StatusLine(IsObject(LinkItems), "Link items loaded", IsObject(LinkItems) ? LinkItems.Length : "Not loaded")
    txt .= StatusLine(IsObject(ColorItems), "Color items loaded", IsObject(ColorItems) ? ColorItems.Length : "Not loaded")
    if IsObject(ColorItems) && ColorItems.Length = 0
        issues++

    txt .= "`r`nRepair Notes`r`n"
    txt .= "- Self-Heal creates missing split files, compacts duplicated INI data, reloads settings, and writes clean copies.`r`n"
    txt .= "- If a custom layout/pie preset is valuable, use Backup first from System Settings before repair.`r`n"
    txt .= "- If only one button is wrong, prefer that editor's Save/Reset over full Self-Heal.`r`n"
    txt .= "`r`nResult: " (issues = 0 ? "Config looks healthy." : issues " issue group(s) need attention.")
    ShowReportWindow("Config Doctor", txt, [["Self-Heal", SelfHealSettings], ["Health", ShowSettingsHealth], ["Version", ShowConfigVersionReport]])
}

IniDuplicateSectionCount(path) {
    sections := Map()
    dupes := 0
    try txt := FileRead(path, "UTF-8")
    catch
        return -1
    for line in StrSplit(txt, "`n", "`r") {
        if RegExMatch(Trim(line), "^\[(.+)\]$", &m) {
            sec := StrLower(Trim(m[1]))
            if sections.Has(sec)
                dupes++
            else
                sections[sec] := true
        }
    }
    return dupes
}

IniDuplicateKeyCount(path) {
    sectionKeys := Map()
    current := ""
    dupes := 0
    try txt := FileRead(path, "UTF-8")
    catch
        return -1
    for line in StrSplit(txt, "`n", "`r") {
        clean := Trim(line)
        if clean = "" || SubStr(clean, 1, 1) = ";"
            continue
        if RegExMatch(clean, "^\[(.+)\]$", &m) {
            current := StrLower(Trim(m[1]))
            if !sectionKeys.Has(current)
                sectionKeys[current] := Map()
            continue
        }
        if current != "" && RegExMatch(clean, "^([^=]+)=", &m) {
            key := StrLower(Trim(m[1]))
            keys := sectionKeys[current]
            if keys.Has(key)
                dupes++
            else
                keys[key] := true
        }
    }
    return dupes
}

IniLegacyKeyList(path) {
    path := StrLower(path)
    keys := []
    if InStr(path, "\gui_settings.ini") {
        keys.Push(["Settings", "CapslockHoldMs"])
        keys.Push(["Settings", "TabHoldMs"])
    }
    return keys
}

IniLegacyKeyCount(path) {
    count := 0
    for pair in IniLegacyKeyList(path) {
        sec := pair[1], key := pair[2]
        try {
            if IniRead(path, sec, key, "") != ""
                count++
        }
    }
    return count
}

IniLegacyKeyReport(path) {
    found := []
    for pair in IniLegacyKeyList(path) {
        sec := pair[1], key := pair[2]
        try {
            if IniRead(path, sec, key, "") != ""
                found.Push(sec "." key)
        }
    }
    return found.Length ? JoinTextList(found, ", ") : ""
}

JoinTextList(items, delim := ", ") {
    txt := ""
    for item in items
        txt .= (txt = "" ? "" : delim) item
    return txt
}

ShowReportWindow(title, text, extraButtons := 0) {
    dlg := Gui("+AlwaysOnTop +ToolWindow", title)
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)
    reportW := S(658)
    btnW := S(103)
    btnH := S(28)
    btnGap := S(8)
    state := {text:text}
    dlg.SetFont("s" S(9) " c000000", "Consolas")
    reportEd := dlg.AddEdit("xm w" reportW " h" S(440) " ReadOnly HScroll VScroll c000000 BackgroundFFFFFF", state.text)
    reportEd.SetFont("s" S(9), "Consolas")
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    xOpt := "xm"
    firstBtn := true
    dlg.AddButton(xOpt " y+" S(12) " w" btnW " h" btnH, "Copy").OnEvent("Click", (*) => CopyReportText(state.text, title))
    xOpt := "x+" btnGap " yp"
    firstBtn := false
    dlg.AddButton(xOpt " w" btnW " h" btnH, "Save...").OnEvent("Click", (*) => SaveReportText(title, state.text))
    xOpt := "x+" btnGap " yp"
    if IsObject(extraButtons) {
        for btnInfo in extraButtons {
            if !IsObject(btnInfo) || btnInfo.Length < 2
                continue
            cap := btnInfo[1], btnFn := btnInfo[2]
            if btnInfo.Length >= 3 && StrLower(Trim(btnInfo[3])) = "refresh" {
                boundFn := btnFn
                dlg.AddButton(xOpt " w" btnW " h" btnH, cap).OnEvent("Click", (*) => (
                    state.text := boundFn.Call(),
                    reportEd.Value := state.text,
                    UpdateStartupHealthBadge()
                ))
            } else {
                dlg.AddButton(xOpt " w" btnW " h" btnH, cap).OnEvent("Click", btnFn)
            }
            xOpt := "x+" btnGap " yp"
            firstBtn := false
        }
    }
    btnClose := dlg.AddButton(xOpt " w" btnW " h" btnH " Default", "Close")
    btnClose.OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("AutoSize")
    SetTimer((*) => btnClose.Focus(), -10)
}

CopyReportText(text, title := "Report") {
    if SetClipboardSafe(text, title)
        ShowNotify(title, "Copied to clipboard")
}

SaveReportText(title, text) {
    baseName := RegExReplace(title, "[^\w\-]+", "_")
    if baseName = ""
        baseName := "report"
    path := FileSelect("S16", A_MyDocuments "\" baseName ".txt", "Save Report", "Text Documents (*.txt)")
    if path = ""
        return false
    try {
        FileDelete(path)
    }
    try {
        FileAppend(text, path, "UTF-8")
        ShowNotify(title, "Saved report")
        DebugLog(title ": report saved to " path)
        return true
    } catch as e {
        DebugLog(title ": failed to save report - " e.Message)
        _HK_ResultPopup(title, "Failed to save report: " e.Message, "E53935")
        return false
    }
}
