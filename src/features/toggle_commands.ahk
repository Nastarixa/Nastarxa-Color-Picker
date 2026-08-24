;FEATURES - Toggle commands
; ============================================================

ToggleLTLock(*) {
    global LTLock, IB_LockBtn
    if HK_ModeFlags().Has("ltLock") && HK_ModeFlags()["ltLock"] {
        if !LTLock
            HK_ApplyModeToggle("ltLock", true)
        ShowNotify("LT Lock", "Locked by " ModeSettingsActiveName())
        DebugLog("LT Lock unlock blocked by active mode")
        return
    }
    LTLock := !LTLock
    if IsObject(IB_LockBtn) {
        IB_LockBtn.Text := LTLock ? IconUse("🔒", "⊠") : IconUse("🔓", "⊡")
        IB_LockBtn.Opt("Background" (LTLock ? "C62828" : "2A2A2A") " c" (LTLock ? "FFFFFF" : "AAAAAA"))
    }
    DebugLog("LT Lock " (LTLock ? "ON" : "OFF"))
    ShowNotify("LT Lock", LTLock ? "🔒 ON" : "🔓 OFF")
}

ToggleAutoSave(*) {
    global AutoSaveOn, AutoSaveBtn
    AutoSaveOn := !AutoSaveOn
    if IsObject(AutoSaveBtn) {
        AutoSaveBtn.Text := AutoSaveOn ? IconUse("💾", "■") : IconUse("💤", "○")
        AutoSaveBtn.Opt("Background" (AutoSaveOn ? "2E7D32" : "2A2A2A") " c" (AutoSaveOn ? "FFFFFF" : "AAAAAA"))
        AutoSaveBtn.Redraw()
    }
    DebugLog("Auto Save " (AutoSaveOn ? "ON" : "OFF"))
    ShowNotify("Auto Save", AutoSaveOn ? "ON (every 60s)" : "OFF")
}

ToggleNav(*) {
    global NavEnabled, NavBtn, _TypingState
    NavEnabled := !NavEnabled
    if IsObject(NavBtn) {
        NavBtn.Text := NavEnabled ? "🖐" : "🚫"
        NavBtn.Opt("Background" (NavEnabled ? "E65100" : "2A2A2A") " cFFFFFF")
    }
    _TypingState["nav"] := false
    DebugLog("Navigation " (NavEnabled ? "ON" : "OFF"))
    ShowNotify("Navigation", NavEnabled ? "ON" : "OFF")
}

ToggleCapslock(*) {
    global CapslockEnabled, CapslockBtn, _TypingState, SETTINGS_FILE
    CapslockEnabled := !CapslockEnabled
    if IsObject(CapslockBtn) {
        CapslockBtn.Text := CapslockEnabled ? "⇪" : "🚫"
        CapslockBtn.Opt("Background" (CapslockEnabled ? "1565C0" : "2A2A2A") " cFFFFFF")
    }
    _TypingState["caps"] := false
    try IniWrite(CapslockEnabled ? 1 : 0, SETTINGS_FILE, "Settings", "CapslockEnabled")
    try SettingsSyncIniWatcher()
    try HK_ReapplyCaps()
    DebugLog("Capslock " (CapslockEnabled ? "ON" : "OFF"))
    ShowNotify("Capslock", CapslockEnabled ? "ON" : "OFF")
}

ToggleTabCombos(*) {
    global TabCombosEnabled, TabCombosBtn, _TypingState, SETTINGS_FILE
    TabCombosEnabled := !TabCombosEnabled
    if IsObject(TabCombosBtn) {
        TabCombosBtn.Text := TabCombosEnabled ? "Tab" : "🚫"
        TabCombosBtn.Opt("Background" (TabCombosEnabled ? "2E7D32" : "2A2A2A") " cFFFFFF")
    }
    _TypingState["tab"] := false
    try IniWrite(TabCombosEnabled ? 1 : 0, SETTINGS_FILE, "Settings", "TabCombosEnabled")
    try SettingsSyncIniWatcher()
    HK_ReapplyAll()
    DebugLog("Tab Combos " (TabCombosEnabled ? "ON" : "OFF"))
    ShowNotify("Tab Combos", TabCombosEnabled ? "ON" : "OFF")
}
ToggleReset(*) {
    global ResetEnabled, ResetBtn
    ResetEnabled := !ResetEnabled
    UpdateResetWatchdog()
    if IsObject(ResetBtn) {
        ResetBtn.Text := ResetEnabled ? "↻" : "🚫"
        ResetBtn.Opt("Background" (ResetEnabled ? "6D28D9" : "2A2A2A") " cFFFFFF")
    }
    DebugLog("Reset Keys " (ResetEnabled ? "ON" : "OFF"))
    ShowNotify("Reset Keys", ResetEnabled ? "ON" : "OFF")
}

ToggleLWin(*) {
    global LWinEnabled, LWinBtn, _TypingState
    LWinEnabled := !LWinEnabled
    if IsObject(LWinBtn) {
        LWinBtn.Text := LWinEnabled ? "⊞" : "🚫"
        LWinBtn.Opt("Background" (LWinEnabled ? "FF6F00" : "2A2A2A") " cFFFFFF")
    }
    _TypingState["lwin"] := false
    DebugLog("LWin Right-click " (LWinEnabled ? "ON" : "OFF"))
    ShowNotify("LWin Right-click", LWinEnabled ? "ON" : "OFF")
}
ToggleReqAnimFromGUI(ctrl, *) {
    global ReqAnimationEnabled, SETTINGS_FILE
    global InbetweenIndex
    global ColorGUI, ColorGUIVisible, ColorGUI_X, ColorGUI_Y
    global LinkGUI, LinkGUIVisible, LinkGUI_X, LinkGUI_Y
    ReqAnimationEnabled := ctrl.Value
    try IniWrite(ReqAnimationEnabled, SETTINGS_FILE, "Settings", "ReqAnimation")
    try SettingsSyncIniWatcher()
    HK_ReapplyAll()
    HK_RefreshSettingsList()
    try RefreshIBRequirementState()
    _RebuildColorGui()
    _RebuildLinkGui()
}

ToggleReqNastarFromGUI(ctrl, *) {
    global ReqNastarEnabled, _useUltimateSaveAs, SETTINGS_FILE
    global ColorGUI, ColorGUIVisible, ColorGUI_X, ColorGUI_Y
    global LinkGUI, LinkGUIVisible, LinkGUI_X, LinkGUI_Y
    ReqNastarEnabled := ctrl.Value
    gui := ctrl.Gui
    try SystemSettingsRefreshRequirementHints(gui)
    try IniWrite(ReqNastarEnabled, SETTINGS_FILE, "Settings", "ReqNastar")
    try SettingsSyncIniWatcher()
    HK_ReapplyAll()
    HK_RefreshSettingsList()
    _RebuildColorGui()
    _RebuildLinkGui()
}


