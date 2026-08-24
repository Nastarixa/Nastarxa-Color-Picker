; GUI - Inbetween (IB) Bar
; ============================================================

CreateIBGui() => ToolScaleCall(CreateIBGui_Impl)

CreateIBGui_Impl() {
    global IB_GUI, IB_Text, IB_LTInd, IB_Buttons, InbetweenData, IB_ModeBtn, IB_EmptyBtn
    global IB_LockBtn, AutoSaveBtn, NavBtn, CapslockBtn, TabCombosBtn, ResetBtn, LWinBtn, _timerDisplay, _tmrPlay, _tmrPause, _rBtn, _saveBtn, _loadBtn, _ccBtnIB, _timerLastLapText, ReqAnimationEnabled
    if IsObject(IB_GUI) {
        try if IB_GUI.Hwnd
            return
    }

    LoadIBSettingsFromIni()
    IB_GUI := Gui("+AlwaysOnTop -Caption +ToolWindow")
    IB_GUI.BackColor := "1E1E1E"
    IB_GUI.SetFont("s" S(8) " cFFFFFF", "Segoe UI")

    btnW := S(20)
    btnH := S(18)
    gap := S(2)

    ; --- Row 1: LT indicator + IB text + Nav / Capslock / Tab / LWin ---
    IB_LTInd := IB_GUI.AddText("xm w" S(6) " h" S(22) " 0x200 BackgroundE53935")
    IB_GUI.SetFont("s" S(7) " cFFFFFF  Bold", "Segoe UI")

    IB_Text := IB_GUI.AddText("x+0 yp w" S(96) " h" S(22) " 0x200 Center cFFFFFF Background252525", "50 |-----|-----|>")

    IB_EmptyBtn := IB_GUI.AddText("x+" S(2) " yp w" S(16) " h" S(22) " Center +0x200 Background555555 cbbbbbb", IconUse("∅", "○"))
    IB_EmptyBtn.SetFont("s" S(7) " Bold", "Segoe UI")
    IB_EmptyBtn.OnEvent("Click", (*) => SelectIB(8))
    AddHoverPopup(IB_EmptyBtn, "Empty slot`n(Ctrl+`)")

    IB_ModeBtn := IB_GUI.AddText("x+" S(2) " yp w" S(31) " h" S(22) " Center +0x200 Background455A64 cFFFFFF", InbetweenModeLabel())
    IB_ModeBtn.SetFont("s" S(6) " Bold", "Segoe UI")
    IB_ModeBtn.OnEvent("Click", ToggleInbetweenMode)
    AddHoverPopup(IB_ModeBtn, "Toggle IB direction`nS>E: smaller layer above edit`nE>S: bigger layer above edit")

    NavBtn := IB_GUI.AddText("x+" S(6) " yp w" btnW " h" S(22) " Center +0x200 BackgroundE65100 cFFFFFF", IconUse("🖐", "◆"))
    NavBtn.SetFont("s" S(7), "Segoe UI")
    NavBtn.OnEvent("Click", ToggleNav)
    AddHoverPopup(NavBtn, "Toggle Space Nav`n(Ctrl+F5)")

    CapslockBtn := IB_GUI.AddText("x+" S(4) " yp w" btnW " h" S(22) " Center +0x200 Background1565C0 cFFFFFF", IconUse("⇪", "C"))
    CapslockBtn.SetFont("s" S(7), "Segoe UI")
    CapslockBtn.OnEvent("Click", ToggleCapslock)
    AddHoverPopup(CapslockBtn, "Toggle CapsLock Mod`n(Ctrl+F6)")

    TabCombosBtn := IB_GUI.AddText("x+" S(4) " yp w" btnW " h" S(22) " Center +0x200 Background2E7D32 cFFFFFF", "Tab")
    TabCombosBtn.SetFont("s" S(6), "Segoe UI")
    TabCombosBtn.OnEvent("Click", ToggleTabCombos)
    AddHoverPopup(TabCombosBtn, "Toggle Tab combos`n(Ctrl+F7)")

    LWinBtn := IB_GUI.AddText("x+" S(4) " yp w" btnW " h" S(22) " Center +0x200 BackgroundFF6F00 cFFFFFF", IconUse("⊞", "W"))
    LWinBtn.SetFont("s" S(6), "Segoe UI")
    LWinBtn.OnEvent("Click", ToggleLWin)
    AddHoverPopup(LWinBtn, "Toggle LWin Right-click`n(Ctrl+F9)")

    ; --- Row 2: Inbetween number buttons + Lock / AutoSave / ColorInfo / Reset ---
    IB_Buttons := []
    i := 0
    for index, d in InbetweenData {
        if index = 8
            continue
        RegExMatch(d.bar, "^\d+", &m)
        num := m[0]
        if i = 0
            btn := IB_GUI.AddText("xm y+" S(4) " w" btnW " h" btnH " Center +0x200", num)
        else
            btn := IB_GUI.AddText("x+" gap " yp w" btnW " h" btnH " Center +0x200", num)
        btn.SetFont("s" S(7) " Bold", "Segoe UI")
        btn.Opt("Background2A2A2A cCCCCCC")
        btn.index := index
        btn.OnEvent("Click", IB_SelectClick)
        AddHoverPopup(btn, num "% - " InbetweenModeLabel())
        IB_Buttons.Push(btn)
        i++
    }

    IB_LockBtn := IB_GUI.AddText("x+" S(6) " yp w" btnW " h" btnH " Center +0x200 Background2A2A2A cAAAAAA", IconUse("🔒", "⊠"))
    IB_LockBtn.SetFont("s" S(7), "Segoe UI")
    IB_LockBtn.OnEvent("Click", ToggleLTLock)
    AddHoverPopup(IB_LockBtn, "Toggle LT Lock`n(Ctrl+F2)")

    AutoSaveBtn := IB_GUI.AddText("x+" S(4) " yp w" btnW " h" btnH " Center +0x200 Background2A2A2A cAAAAAA", IconUse("💤", "○"))
    AutoSaveBtn.SetFont("s" S(7), "Segoe UI")
    AutoSaveBtn.OnEvent("Click", ToggleAutoSave)
    AddHoverPopup(AutoSaveBtn, "Toggle Auto Save`n(Ctrl+F4)")

    _ccBtnIB := IB_GUI.AddText("x+" S(4) " yp w" btnW " h" btnH " Center +0x200 Background444444 cFFFFFF", IconUse("🎨", "C"))
    _ccBtnIB.SetFont("s" S(7), "Segoe UI")
    _ccBtnIB.OnEvent("Click", ToggleColorInfo)
    AddHoverPopup(_ccBtnIB, "Toggle Cursor Color Info")

    ResetBtn := IB_GUI.AddText("x+" S(4) " yp w" btnW " h" btnH " Center +0x200 Background6D28D9 cFFFFFF", IconUse("↺", "R"))
    ResetBtn.SetFont("s" S(8), "Segoe UI")
    ResetBtn.OnEvent("Click", ToggleReset)
    AddHoverPopup(ResetBtn, "Toggle Reset Keys`nON/OFF (Ctrl+F8)")

    ; --- Row 3: Timer / Stopwatch ---
    _timerDisplay := IB_GUI.AddText("xm y+" S(6) " w" S(76) " h" S(14) " 0x200 Center cFFFFFF Background333333", "00:00:00")
    _timerDisplay.SetFont("s" S(7) " cFFFFFF", "Consolas")
    _timerDisplay.OnEvent("DoubleClick", (*) => TimerCountdownShow())
    AddHoverPopup(_timerDisplay, "Timer`nDouble-click: Countdown mode")
    _tmrPlay := IB_GUI.AddText("x+" S(2) " yp w" S(14) " h" S(14) " 0x200 Center cFFFFFF Background2E7D32", IconUse("▶", ">"))
    _tmrPlay.SetFont("s" S(6), "Segoe UI")
    _tmrPlay.OnEvent("Click", TimerToggle)
    AddHoverPopup(_tmrPlay, "Start Timer")
    _tmrPause := IB_GUI.AddText("xp yp w" S(14) " h" S(14) " 0x200 Center cFFFFFF BackgroundE65100 Hidden", IconUse("❚❚", "||"))
    _tmrPause.SetFont("s" S(6), "Segoe UI")
    _tmrPause.OnEvent("Click", TimerToggle)
    AddHoverPopup(_tmrPause, "Pause Timer")
    _rBtn := IB_GUI.AddText("x+" S(2) " yp w" S(24) " h" S(14) " 0x200 Center cFFFFFF BackgroundC62828", IconUse("■", "X"))
    _rBtn.SetFont("s" S(6), "Segoe UI")
    _rBtn.OnEvent("Click", TimerStopOrLap)
    AddHoverPopup(_rBtn, "Stop Timer`nChanges to Lap while running")

    _saveBtn := IB_GUI.AddText("x+" S(2) " yp w" S(15) " h" S(14) " 0x200 Center cFFFFFF Background1565C0", IconUse("💾", "S"))
    _saveBtn.SetFont("s" S(6), "Segoe UI")
    _saveBtn.OnEvent("Click", TimerSave)
    AddHoverPopup(_saveBtn, "Save Timer Log")

    _loadBtn := IB_GUI.AddText("x+" S(2) " yp w" S(15) " h" S(14) " 0x200 Center cFFFFFF Background6D28D9", IconUse("↥", "L"))
    _loadBtn.SetFont("s" S(7), "Segoe UI")
    _loadBtn.OnEvent("Click", TimerLoad)
    AddHoverPopup(_loadBtn, "Load Timer Log`nTXT directly, PNG via same-name TXT")

    ; drag handle (remaining space on same row)
    IB_GUI.dragBottom := IB_GUI.AddText("x+" S(6) " yp w" S(92) " h" S(14) " +0x200 Center cDDDDDD Background555555", _timerLastLapText)
    IB_GUI.dragBottom.SetFont("s" S(6), "Segoe UI")
    IB_GUI.dragBottom.OnEvent("DoubleClick", (*) => ShowModeSelector())
    IB_GUI.dragBottom.OnEvent("Click", IB_SeparatorClick)
    AddHoverPopup(IB_GUI.dragBottom, "Active mode`nDouble-click: switch mode`nAlt+click: next mode")

    ; --- Context menu ---
    IB_GUI.OnEvent("ContextMenu", IB_ContextMenu)
    UpdateIBButtons()
    if ReqAnimationEnabled
        UpdateInbetweenModeButton()
    UpdateModeButtons()
    UpdateIBGui(InbetweenIndex)
    UpdateIBModeIndicator()
    IB_GUI._ready := true
}

IB_SelectClick(btn, *) {
    SelectIB(btn.index)
}

; Click on the separator label. Plain click is ignored (it's the drag handle);
; Alt+click cycles to the next visible mode.
IB_SeparatorClick(ctrl, *) {
    if GetKeyState("Alt")
        HK_CycleMode()
}

InbetweenModeLabel() {
    global InbetweenMode
    return InbetweenMode = "Start > End" ? "S>E" : "E>S"
}

; Shows the active mode name in the bottom-right drag separator.
; A pending timer lap text temporarily replaces it.
; When hotkeys are paused, shows "Hotkey Off" instead of the mode name.
UpdateIBModeIndicator() {
    global IB_GUI, HK_Mode, HK_Modes, _timerLastLapText, HotkeysPaused
    if !IsObject(IB_GUI) || !IB_GUI.HasProp("dragBottom")
        return
    if _timerLastLapText != "" {
        IB_GUI.dragBottom.Text := _timerLastLapText
        IB_GUI.dragBottom.Opt("Background455A64 cDDDDDD")
        return
    }
    if HotkeysPaused {
        IB_GUI.dragBottom.Text := "Hotkey Off"
        IB_GUI.dragBottom.Opt("BackgroundE53935 cFFFFFF")
        return
    }
    id := HK_ModeActive()
    name := "Default"
    modeColor := ""
    if id != "default" && IsObject(HK_Modes) && HK_Modes.Has(id) {
        if HK_Modes[id].Has("name")
            name := HK_Modes[id]["name"]
        if HK_Modes[id].Has("color") && HK_Modes[id]["color"] != ""
            modeColor := HK_Modes[id]["color"]
    } else if id != "default"
        name := id
    IB_GUI.dragBottom.Text := name
    bgColor := modeColor != "" ? PieSafeColor(modeColor) : "3949AB"
    IB_GUI.dragBottom.Opt("Background" bgColor " c" ContrastColor(bgColor))
}

UpdateInbetweenModeButton() {
    global IB_ModeBtn, InbetweenMode, _IBColors
    if !IsObject(IB_ModeBtn)
        return
    IB_ModeBtn.Text := InbetweenModeLabel()
    local bg := InbetweenMode = "Start > End" ? _IBColors.Get("s2e", "4CAF50") : _IBColors.Get("e2s", "E53935")
    IB_ModeBtn.Opt("Background" bg " c" ContrastColor(bg))
}

RefreshIBRequirementState() {
    global InbetweenIndex
    try UpdateIBButtons()
    try UpdateIBGui(InbetweenIndex)
}

SelectIB(index) {
    global InbetweenIndex, InbetweenData, InbetweenMode, LTLock, SETTINGS_FILE, ReqAnimationEnabled
    if !ReqAnimationEnabled {
        UpdateIBGui(index)
        return
    }
    if LTLock
        return ShowNotify("LT Lock", "Locked - IB disabled")
    if index < 1
        index := 1
    else if index > InbetweenData.Count
        index := InbetweenData.Count
    InbetweenIndex := index
    d := InbetweenData[index]
    if index = 8 {
        try {
            IniWrite(InbetweenIndex, SETTINGS_FILE, "IB", "Index")
            IniWrite(InbetweenMode, SETTINGS_FILE, "IB", "Mode")
        }
        try SettingsSyncIniWatcher()
        ResetLT()
        ShowNotify("Empty", "Reset Light Table", d.color)
        UpdateIBGui(index)
        return
    }
    HotkeySendCSP("^" index)
    Sleep 30
    HotkeySendCSP("+^!w")
    try {
        IniWrite(InbetweenIndex, SETTINGS_FILE, "IB", "Index")
        IniWrite(InbetweenMode, SETTINGS_FILE, "IB", "Mode")
    }
    try SettingsSyncIniWatcher()
    ShowNotify(d.bar, d.desc, d.color)
    UpdateIBGui(index)
}

UpdateIBButtons() {
    global IB_Buttons, InbetweenData, IB_EmptyBtn, InbetweenIndex, IB_ModeBtn, ReqAnimationEnabled
    if !ReqAnimationEnabled {
        for btn in IB_Buttons {
            if !IsObject(btn)
                continue
            btn.Text := IconUse("🚫", "X")
            btn.Opt("Background2A2A2A cFFFFFF")
            AddHoverPopup(btn, "Animation_autoaction.laf is disabled")
        }
        if IsObject(IB_EmptyBtn) {
            IB_EmptyBtn.Text := IconUse("🚫", "X")
            IB_EmptyBtn.Opt("Background2A2A2A cFFFFFF")
            AddHoverPopup(IB_EmptyBtn, "Animation_autoaction.laf is disabled")
        }
        if IsObject(IB_ModeBtn) {
            IB_ModeBtn.Text := IconUse("🚫", "X")
            IB_ModeBtn.Opt("Background2A2A2A cFFFFFF")
            AddHoverPopup(IB_ModeBtn, "Animation_autoaction.laf is disabled")
        }
        return
    }
    for btn in IB_Buttons {
        if !IsObject(btn)
            continue
        d := InbetweenData[btn.index]
        RegExMatch(d.bar, "^\d+", &m)
        btn.Text := m[0]
        AddHoverPopup(btn, m[0] "% - " InbetweenModeLabel())
    }
    if IsObject(IB_EmptyBtn) {
        IB_EmptyBtn.Text := IconUse("∅", "○")
        d := InbetweenData[8]
        bg := d.HasOwnProp("color") ? d.color : "555555"
        if InbetweenIndex = 8
            IB_EmptyBtn.Opt("Background" bg)
        else
            IB_EmptyBtn.Opt("Background555555")
    }
    UpdateInbetweenModeButton()
}

SetInbetweenMode(mode, save := true) {
    global InbetweenMode, InbetweenData, InbetweenIndex, SETTINGS_FILE, _IBColors
    InbetweenMode := NormalizeInbetweenMode(mode)
    InbetweenData := BuildInbetweenData(InbetweenMode)
    UpdateIBButtons()
    UpdateInbetweenModeButton()
    UpdateIBGui(InbetweenIndex)
    local bgCol := InbetweenMode = "Start > End" ? _IBColors.Get("s2e", "4CAF50") : _IBColors.Get("e2s", "E53935")
    ShowNotify("IB Direction", InbetweenMode, "0x" bgCol)
    if save {
        try {
            IniWrite(InbetweenMode, SETTINGS_FILE, "IB", "Mode")
            IniWrite(InbetweenIndex, SETTINGS_FILE, "IB", "Index")
        }
        try SettingsSyncIniWatcher()
    }
    DebugLog("IB mode set to " InbetweenMode)
}

ToggleInbetweenMode(*) {
    global InbetweenMode, InbetweenIndex, ReqAnimationEnabled
    if !ReqAnimationEnabled {
        UpdateIBButtons()
        UpdateIBGui(InbetweenIndex)
        return
    }
    SetInbetweenMode(InbetweenMode = "Start > End" ? "End > Start" : "Start > End")
}

; Timer / Worklog functions live in src\features\timer_worklog.ahk

IB_ContextMenu(guiObj, ctrl, item, isRightClick, x, y) {
    global IB_GUI, IBVisible, IBManualHide, MainGUI, IBShortcutsEnabled
    m := Menu()
    m.Add("IB Change Shortcuts", ToggleIBShortcuts)
    if IBShortcutsEnabled = "" || IBShortcutsEnabled
        m.Check("IB Change Shortcuts")
    m.Add("IB keys: Ctrl+`, Ctrl+2-8", (*) => {})
    m.Disable("IB keys: Ctrl+`, Ctrl+2-8")
    m.Add()
    m.Add("Hide IB GUI", (*) => (IB_GUI.Hide(), IBVisible := false, IBManualHide := true,
        GuiHasCtrl(MainGUI, "btnIB") ? MainGUI.btnIB.Opt("BackgroundE53935 cFFFFFF") : "",
        DebugLog("IB hidden via context menu")))
    m.Add("Switch IB Direction", ToggleInbetweenMode)
    m.Add("Opacity...", ShowOpacitySlider.Bind("IB"))
    m.Add("Auto Save Interval...", SetAutoSaveInterval)
    m.Add("Load Timer...", TimerLoad)
    m.Add("Debug Log", ShowDebugGUI)
    m.Show()
}

ToggleIBShortcuts(*) {
    global IBShortcutsEnabled, SETTINGS_FILE
    enabled := IBShortcutsEnabled = "" ? true : IBShortcutsEnabled
    IBShortcutsEnabled := !enabled
    try IniWrite(IBShortcutsEnabled ? 1 : 0, SETTINGS_FILE, "IB", "ShortcutsEnabled")
    if IBShortcutsEnabled
        ShowNotify("IB Change Shortcuts", "Enabled - Ctrl+`, Ctrl+2-8 active")
    else
        ShowNotify("IB Change Shortcuts", "Disabled - only Ctrl+1 works")
    return IBShortcutsEnabled
}

UpdateIBGui(index) {
    global IB_Text, IB_GUI, InbetweenData, InbetweenIndex, ReqAnimationEnabled
    if !IsObject(IB_Text) || !IsObject(IB_GUI)
        return
    if !ReqAnimationEnabled {
        IB_Text.Value := "- disabled -"
        IB_GUI.BackColor := "1E1E1E"
        return
    }
    d := InbetweenData.Has(index) ? InbetweenData[index] : ""
    if !IsObject(d) {
        IB_Text.Value := "-"
        IB_GUI.BackColor := "1E1E1E"
        return
    }
    IB_Text.Value := d.bar
    bg := d.HasOwnProp("color") ? d.color : "1E1E1E"
    IB_GUI.BackColor := bg
    IB_GUI.SetFont("cFFFFFF")
    IB_Text.SetFont()
}

IB_PositionGui() {
    global IB_GUI, IB_X, IB_Y, IB_Opacity
    if !FeatureEnabled("ibgui")
        return
    try if !IB_GUI.Hwnd
        return
    try if !IB_GUI._ready
        return
    IB_GUI.Show("x" IB_X " y" IB_Y " NoActivate")
    try _ZFixGUI(IB_GUI)
    if IB_Opacity < 255
        WinSetTransparent(IB_Opacity, IB_GUI)
}

; ============================================================
