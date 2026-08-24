; GUI OPACITY SLIDER
; ============================================================

ShowOpacitySlider(target, *) {
    global IB_Opacity, Color_Opacity, Link_Opacity, Scale, PieScale, Speed
    global NotifyEnabled, NotifyMonitor, NotifyPosition, ReqAnimationEnabled
    global SETTINGS_FILE, CONTRAST_THRESHOLD
    global _IBTheme, _IBColors, _HoverState
    if target = "Main" {
        dlg := Gui("+AlwaysOnTop +ToolWindow", "GUI Settings")
        dlg.BackColor := "1E1F22"
        dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
        dlg.MarginX := S(14)
        dlg.MarginY := S(14)
        v1 := OpacityValueToPercent(IB_Opacity)
        v2 := OpacityValueToPercent(Color_Opacity)
        v3 := OpacityValueToPercent(Link_Opacity)
        o1 := IB_Opacity, o2 := Color_Opacity, o3 := Link_Opacity
        scalePct := Max(50, Min(150, Round(Scale * 100)))
        origScale := Scale
        pieScalePct := Max(50, Min(150, Round(PieScale * 100)))
        origPieScale := PieScale
        speedVal := Max(1, Min(100, Speed))
        origSpeed := speedVal
        origNotifyEnabled := NotifyEnabled
        origNotifyMonitor := NotifyMonitor
        origNotifyPosition := NotifyPosition
        origTooltipEnabled := _HoverState.Get("enabled", true)
        origTooltipDelay := _HoverState.Get("delay", 500)
        origIBTheme := _IBTheme
        origIBColors := _IBColors.Clone()
        origContrastThreshold := CONTRAST_THRESHOLD
        saved := false
        resetState := (*) => (
            v1 := 100,
            v2 := 100,
            v3 := 100,
            scalePct := 100,
            pieScalePct := 100,
            speedVal := 15,
            s1.Value := v1,
            s2.Value := v2,
            s3.Value := v3,
            sScale.Value := scalePct,
            sPieScale.Value := pieScalePct,
            sSpeed.Value := speedVal,
            Speed := speedVal,
            PieScale := 1.0,
            SetOpacity("IB", 255, false),
            SetOpacity("Color", 255, false),
            SetOpacity("Link", 255, false),
            PreviewGuiScale(1.0),
            NotifyEnabled := true,
            NotifyMonitor := 0,
            NotifyPosition := "TC",
            cbNotify.Value := 1,
            ddlMon.Choose(1),
            ddlPos.Choose(1),
            chkTooltip.Value := 1,
            edTooltipDelay.Value := 500,
            edContrastThresh.Value := 185,
            ddlTheme.Choose("Default"),
            _PreviewThemePreset("Default", inp, sw)
        )
        colW := S(280)
        ; --- LEFT COLUMN: Sliders ---
        dlg.AddText("xm", "IB GUI Opacity:")
        dlg.AddText("xm y+" S(4) " w" S(28) " cAAAAAA", "0%")
        s1 := dlg.AddSlider("x+" S(4) " yp w" S(155) " Range0-100 Tooltip", v1)
        dlg.AddText("x+" S(4) " yp w" S(38) " Right cAAAAAA", "100%")
        s1.OnEvent("Change", (*) => (
            v1 := s1.Value,
            SetOpacity("IB", OpacityPercentToValue(v1), false)
        ))
        dlg.AddText("xm y+" S(18), "Color GUI Opacity:")
        dlg.AddText("xm y+" S(4) " w" S(28) " cAAAAAA", "0%")
        s2 := dlg.AddSlider("x+" S(4) " yp w" S(155) " Range0-100 Tooltip", v2)
        dlg.AddText("x+" S(4) " yp w" S(38) " Right cAAAAAA", "100%")
        s2.OnEvent("Change", (*) => (
            v2 := s2.Value,
            SetOpacity("Color", OpacityPercentToValue(v2), false)
        ))
        dlg.AddText("xm y+" S(18), "Link GUI Opacity:")
        dlg.AddText("xm y+" S(4) " w" S(28) " cAAAAAA", "0%")
        s3 := dlg.AddSlider("x+" S(4) " yp w" S(155) " Range0-100 Tooltip", v3)
        dlg.AddText("x+" S(4) " yp w" S(38) " Right cAAAAAA", "100%")
        s3.OnEvent("Change", (*) => (
            v3 := s3.Value,
            SetOpacity("Link", OpacityPercentToValue(v3), false)
        ))
        dlg.AddText("xm y+" S(18), "UI Scale:")
        dlg.AddText("xm y+" S(4) " w" S(28) " cAAAAAA", "50%")
        sScale := dlg.AddSlider("x+" S(4) " yp w" S(155) " Range50-150 Tooltip", scalePct)
        dlg.AddText("x+" S(4) " yp w" S(38) " Right cAAAAAA", "150%")
        sScale.OnEvent("Change", (*) => (
            scalePct := sScale.Value,
            PreviewGuiScale(scalePct / 100.0)
        ))
        dlg.AddText("xm y+" S(18), "Pie Scale:")
        dlg.AddText("xm y+" S(4) " w" S(28) " cAAAAAA", "50%")
        sPieScale := dlg.AddSlider("x+" S(4) " yp w" S(155) " Range50-150 Tooltip", pieScalePct)
        dlg.AddText("x+" S(4) " yp w" S(38) " Right cAAAAAA", "150%")
        sPieScale.OnEvent("Change", (*) => (
            pieScalePct := sPieScale.Value,
            PieScale := pieScalePct / 100.0
        ))
        dlg.AddText("xm y+" S(18), "Scroll Power:")
        dlg.AddText("xm y+" S(4) " w" S(28) " cAAAAAA", "1 (slow)")
        sSpeed := dlg.AddSlider("x+" S(4) " yp w" S(155) " Range1-100 Tooltip", speedVal)
        dlg.AddText("x+" S(0) " yp w" S(38) " Right cAAAAAA", "100 (fast)")
        sSpeed.OnEvent("Change", (*) => (Speed := sSpeed.Value))

        ; --- LEFT COLUMN: Tooltip Popup ---
        dlg.AddText("xm y+" S(10) " cFFFFFF", "Tooltip Popup:")
        chkTooltip := dlg.AddCheckbox("xm y+" S(4) " cAAAAAA", "Enable hover tooltips")
        chkTooltip.Value := _HoverState.Get("enabled", true)
        dlg.AddText("xm y+" S(6) " cAAAAAA", "Delay:")
        edTooltipDelay := dlg.AddEdit("xp y+4 w" S(50) " c000000 BackgroundFFFFFF", _HoverState.Get("delay", 500))
        dlg.AddText("x+6 yp+1 cAAAAAA", "ms (0-2000)")

        ; --- LEFT COLUMN: Font Color Contrast ---
        dlg.AddText("xm y+" S(16) " cFFFFFF", "Font Color Contrast:")
        dlg.AddText("xm y+" S(4) " cAAAAAA", "Luminance threshold for auto font color on")
        dlg.AddText("xm y+" S(4) " cAAAAAA", "colored backgrounds. Higher = prefer dark text.")
        dlg.AddText("xm y+" S(4), "Threshold:")
        edContrastThresh := dlg.AddEdit("x+" S(4) " yp w" S(50) " c000000 BackgroundFFFFFF", CONTRAST_THRESHOLD)
        dlg.AddText("x+6 yp+1 cAAAAAA", "0-255 (default 185)")

        ; --- RIGHT COLUMN: Notifications ---
        rightX := "xm+" (colW - S(15))
        dlg.AddText(rightX " y" S(14) " cFFFFFF", "Notifications:")
        cbNotify := dlg.AddCheckbox(rightX " y+" S(4) " cAAAAAA", "Enable Notification Popups")
        cbNotify.Value := NotifyEnabled
        cbNotify.OnEvent("Click", (*) => (
            NotifyEnabled := cbNotify.Value
        ))
        monCount := MonitorGetCount()
        monOpts := ["Primary"]
        Loop monCount
            monOpts.Push("Monitor " A_Index)
        ddlMon := dlg.AddDropDownList(rightX " y+" S(8) " w" S(325) " Choose" (NotifyMonitor = 0 ? 1 : NotifyMonitor + 1), monOpts)
        ddlMon.OnEvent("Change", (*) => (
            NotifyMonitor := ddlMon.Value - 1
        ))
        posOpts := ["TC — Top Center","TL — Top Left","TR — Top Right"
            ,"CT — Center","CTL — Center Left","CTR — Center Right"
            ,"BC — Bottom Center","BL — Bottom Left","BR — Bottom Right"]
        posCodes := ["TC","TL","TR","CT","CTL","CTR","BC","BL","BR"]
        posIdx := 1
        for i, code in posCodes {
            if code = NotifyPosition {
                posIdx := i
                break
            }
        }
        dlg.AddText(rightX " y+" S(4) " cAAAAAA", "Position:")
        ddlPos := dlg.AddDropDownList(rightX " y+" S(2) " w" S(325) " Choose" posIdx, posOpts)
        ddlPos.OnEvent("Change", (*) => (
            NotifyPosition := posCodes[ddlPos.Value]
        ))

        ; --- RIGHT COLUMN: IB Color ---
        dlg.AddText(rightX " y+" S(16) " cFFFFFF", "IB Color:")
        dlg.SetFont("s8 cFF9800", "Segoe UI")
        dlg.AddText("x+6 yp+1 w" S(190) (ReqAnimationEnabled ? " Hidden" : ""), "Requires Animation_autoaction.laf")
        dlg.SetFont("s9 cAAAAAA", "Segoe UI")
        themePresets := IBThemePresetNames()
        themeIdx := 1
        for i, name in themePresets {
            if name = _IBTheme {
                themeIdx := i
                break
            }
        }
        ddlTheme := dlg.AddDropDownList(rightX " y+4 w" S(150) " Choose" themeIdx, themePresets)
        _prevThemeIdx := themeIdx
        ddlTheme.OnEvent("Change", (*) => (
            SubStr(ddlTheme.Text, 1, 3) = "---" ? (
                ddlTheme.Choose(_prevThemeIdx)
            ) : (
                ddlTheme.Text = "Custom" ? "" : _PreviewThemePreset(ddlTheme.Text, inp, sw),
                _prevThemeIdx := ddlTheme.Value
            )
        ))

        dlg.AddButton("x+" S(6) " yp w" S(80) " h" S(22), "IB Export").OnEvent("Click", (*) => ExportIBColorProfile(inp, ddlTheme))
        dlg.AddButton("x+" S(6) " yp w" S(80) " h" S(22), "IB Import").OnEvent("Click", (*) => ImportIBColorProfile(inp, sw, ddlTheme, false))
        colsW := S(60)
        inp := Map()
        sw := Map()
        gridX1 := rightX
        gridX2 := "x" (colW + S(170))
        cellLabelW := S(62)
        swW := S(18)
        AddIBColorCell(xOpt, label, key, fallback) {
            dlg.AddText(xOpt " yp w" cellLabelW " cAAAAAA", label)
            val := NormalizeHexColorText(_IBColors.Get(key, fallback), fallback)
            inp[key] := dlg.AddEdit("x+4 yp w" colsW " c000000 BackgroundFFFFFF Limit8", val)
            sw[key] := dlg.AddText("x+5 yp w" swW " h" S(18) " +0x200 Background" val, "")
        }
        dlg.AddText(rightX " y+" S(10) " cFFFFFF", "Start > End")
        dlg.AddText(rightX " y+" S(2) " h1 w" S(325) " Background444444", "")
        dlg.AddText(rightX " y+" S(5) " w0 h" S(18), "")
        AddIBColorCell(gridX1, "33:", "33_se", _IBColors.Get("33", "795548"))
        AddIBColorCell(gridX2, "66:", "66_se", _IBColors.Get("66", "81C784"))
        dlg.AddText(rightX " y+" S(10) " w0 h" S(18), "")
        AddIBColorCell(gridX1, "25:", "25_se", _IBColors.Get("25", "5D4037"))
        AddIBColorCell(gridX2, "75:", "75_se", _IBColors.Get("75", "43A047"))
        dlg.AddText(rightX " y+" S(10) " w0 h" S(18), "")
        AddIBColorCell(gridX1, "40:", "40_se", _IBColors.Get("40", "FFB300"))
        AddIBColorCell(gridX2, "60:", "60_se", _IBColors.Get("60", "2E7D32"))

        dlg.AddText(rightX " y+" S(9) " cFFFFFF", "End > Start")
        dlg.AddText(rightX " y+" S(2) " h1 w" S(325) " Background444444", "")
        dlg.AddText(rightX " y+" S(5) " w0 h" S(18), "")
        AddIBColorCell(gridX1, "33:", "33_es", _IBColors.Get("33", "795548"))
        AddIBColorCell(gridX2, "66:", "66_es", _IBColors.Get("66", "81C784"))
        dlg.AddText(rightX " y+" S(10) " w0 h" S(18), "")
        AddIBColorCell(gridX1, "25:", "25_es", _IBColors.Get("25", "5D4037"))
        AddIBColorCell(gridX2, "75:", "75_es", _IBColors.Get("75", "43A047"))
        dlg.AddText(rightX " y+" S(10) " w0 h" S(18), "")
        AddIBColorCell(gridX1, "40:", "40_es", _IBColors.Get("40", "FFB300"))
        AddIBColorCell(gridX2, "60:", "60_es", _IBColors.Get("60", "2E7D32"))

        dlg.AddText(rightX " y+" S(9) " cFFFFFF", "Special")
        dlg.AddText(rightX " y+" S(2) " h1 w" S(325) " Background444444", "")
        dlg.AddText(rightX " y+" S(5) " w0 h" S(18), "")
        AddIBColorCell(gridX1, "S>E:", "s2e", "4CAF50")
        AddIBColorCell(gridX2, "Empty S:", "empty_se", _IBColors.Get("empty", "555555"))
        dlg.AddText(rightX " y+" S(10) " w0 h" S(18), "")
        AddIBColorCell(gridX1, "E>S:", "e2s", "E53935")
        AddIBColorCell(gridX2, "Empty E:", "empty_es", _IBColors.Get("empty", "555555"))
        ; Register swatch preview updates
        _IBColorEdit(ed, s, *) {
            ddlTheme.Choose("Custom")
            c := RegExReplace(RegExReplace(Trim(ed.Value), "i)^(#|0x)", ""), "[^0-9A-Fa-f]", "")
            if RegExMatch(c, "i)^[0-9A-F]{1,6}$") {
                Loop 6 - StrLen(c)
                    c .= "0"
                s.Opt("Background" c)
                s.Redraw()
            }
        }
        for key, ed in inp
            ed.OnEvent("Change", _IBColorEdit.Bind(ed, sw[key]))

        ; Save / Reset / Close buttons at bottom
        dlg.AddText("xm y+" S(55) " w" S(590) " h1 Background444444", "")
        dlg.AddButton("xm y+" S(8) " w" S(105) " h" S(26) " c4CAF50", "Theme Export").OnEvent("Click", (*) => ExportTheme())
        dlg.AddButton("x+" S(6) " yp w" S(105) " h" S(26) " cFF9800", "Theme Import").OnEvent("Click", (*) => ImportTheme())
        dlg.AddButton("x+" S(49) " yp w" S(107) " h" S(26), "Reset").OnEvent("Click", (*) => resetState())
        _GuiSettingsSave(*) {
            saved := true
            _ApplyThemeColors(inp, sw, ddlTheme.Text)
            Speed := sSpeed.Value
            SetOpacity("IB", OpacityPercentToValue(v1))
            SetOpacity("Color", OpacityPercentToValue(v2))
            SetOpacity("Link", OpacityPercentToValue(v3))
            ApplyGuiScale(sScale.Value / 100.0)
            PieScale := sPieScale.Value / 100.0
            try {
                IniWrite(PieScale, SETTINGS_FILE, "Settings", "PieScale")
                IniWrite(NotifyEnabled ? 1 : 0, SETTINGS_FILE, "Settings", "NotifyEnabled")
                IniWrite(NotifyMonitor, SETTINGS_FILE, "Settings", "NotifyMonitor")
                IniWrite(NotifyPosition, SETTINGS_FILE, "Settings", "NotifyPosition")
                IniWrite(chkTooltip.Value ? 1 : 0, SETTINGS_FILE, "Settings", "TooltipEnabled")
                IniWrite(ToolkitSafeInt(edTooltipDelay.Value, 500, 0, 2000), SETTINGS_FILE, "Settings", "TooltipDelay")
            }
            _HoverState["enabled"] := !!chkTooltip.Value
            _HoverState["delay"] := ToolkitSafeInt(edTooltipDelay.Value, 500, 0, 2000)
            n := ToolkitSafeInt(edContrastThresh.Value, CONTRAST_THRESHOLD, 0, 255)
            CONTRAST_THRESHOLD := n
            try IniWrite(CONTRAST_THRESHOLD, SETTINGS_FILE, "Settings", "ContrastThreshold")
            dlg.Destroy()
        }
        dlg.AddButton("x+" S(6) " yp w" S(107) " h" S(26), "Save").OnEvent("Click", _GuiSettingsSave)
        dlg.AddButton("x+" S(6) " yp w" S(97) " h" S(26), "Close").OnEvent("Click", _CloseGuiSettings)
        _CloseGuiSettings(*) {
            global _IBTheme, _IBColors, _HoverState, Speed, PieScale, NotifyEnabled, NotifyMonitor, NotifyPosition, CONTRAST_THRESHOLD
            if !saved {
                Speed := origSpeed
                PreviewGuiScale(origScale)
                PieScale := origPieScale
                SetOpacity("IB", o1, false)
                SetOpacity("Color", o2, false)
                SetOpacity("Link", o3, false)
                NotifyEnabled := origNotifyEnabled
                NotifyMonitor := origNotifyMonitor
                NotifyPosition := origNotifyPosition
                _HoverState["enabled"] := origTooltipEnabled
                _HoverState["delay"] := origTooltipDelay
                CONTRAST_THRESHOLD := origContrastThreshold
                _IBTheme := origIBTheme
                _IBColors := origIBColors.Clone()
                RebuildIBFromTheme()
            }
            try dlg.Destroy()
        }
        dlg.OnEvent("Close", _CloseGuiSettings)
        dlg.Show("AutoSize")
        return
    }
    cur := target = "IB" ? IB_Opacity : target = "Color" ? Color_Opacity : Link_Opacity
    orig := cur
    pct := OpacityValueToPercent(cur)
    saved := false
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Opacity — " target)
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)
    dlg.AddText("xm", "Opacity:")
    dlg.AddText("xm y+" S(4) " w" S(28) " cAAAAAA", "0%")
    sl := dlg.AddSlider("x+" S(8) " yp w" S(155) " Range0-100 Tooltip", pct)
    dlg.AddText("x+" S(8) " yp w" S(38) " Right cAAAAAA", "100%")
    sl.OnEvent("Change", (*) => (
        pct := sl.Value,
        SetOpacity(target, OpacityPercentToValue(pct), false)
    ))
    dlg.AddText("xm y+" S(4), "Tip: Right-click any tool GUI for quick access")
    dlg.AddButton("xm y+" S(8) " w" S(80) " h" S(26), "Save").OnEvent("Click", (*) => (
        saved := true,
        SetOpacity(target, OpacityPercentToValue(pct)),
        dlg.Destroy()
    ))
    _CloseOpacityPopup(*) {
        if !saved
            SetOpacity(target, orig, false)
        try dlg.Destroy()
    }
    dlg.AddButton("x+" S(6) " yp w" S(80) " h" S(26), "Close").OnEvent("Click", _CloseOpacityPopup)
    dlg.OnEvent("Close", _CloseOpacityPopup)
    dlg.Show("AutoSize")
}

OpacityValueToPercent(value) {
    try n := Integer(value)
    catch
        return 0
    return Round((n * 100) / 255)
}

OpacityPercentToValue(percent) {
    try n := Integer(percent)
    catch
        return 0
    return Max(0, Min(255, Round((n * 255) / 100)))
}

SetOpacity(target, value, save := true) {
    global IB_Opacity, Color_Opacity, Link_Opacity, IB_GUI, ColorGUI, LinkGUI, SETTINGS_FILE
    if target = "IB" {
        IB_Opacity := value
        if IsObject(IB_GUI)
            WinSetTransparent(value, IB_GUI)
    } else if target = "Color" {
        Color_Opacity := value
        if IsObject(ColorGUI)
            WinSetTransparent(value, ColorGUI)
    } else if target = "Link" {
        Link_Opacity := value
        if IsObject(LinkGUI)
            WinSetTransparent(value, LinkGUI)
    }
    if save {
        try IniWrite(value, SETTINGS_FILE, "Settings", target "_Opacity")
        try SettingsSyncIniWatcher()
        DebugLog("Set " target " opacity to " value)
    }
}

PreviewGuiScale(newScale) {
    GuiScaleApply(newScale, false)
}

ApplyGuiScale(newScale) {
    GuiScaleApply(newScale, true)
}

GuiScaleApply(newScale, persist := true) {
    global Scale, MainGUI, IB_GUI, ColorGUI, LinkGUI
    global MainGUIVisible, IBVisible, ColorGUIVisible, LinkGUIVisible
    global IBManualHide, ColorManualHide, LinkManualHide

    newScale := Round(newScale * 100) / 100
    if newScale < 0.5
        newScale := 0.5
    else if newScale > 1.5
        newScale := 1.5
    if Abs(newScale - Scale) < 0.001 {
        if persist
            SaveGUIPositions()
        return
    }

    mainX := mainY := 0
    haveMainPos := false
    if IsObject(MainGUI) {
        MainGUI.GetPos(&mainX, &mainY)
        haveMainPos := true
    }

    Scale := newScale

    if IsObject(MainGUI)
        MainGUI.Destroy()
    if IsObject(IB_GUI)
        IB_GUI.Destroy()
    if IsObject(ColorGUI)
        ColorGUI.Destroy()
    if IsObject(LinkGUI)
        LinkGUI.Destroy()

    CreateMainGui()
    CreateIBGui()
    CreateColorGui()
    CreateLinkGUI()

    if MainGUIVisible {
        if haveMainPos
            MainGUI.Show("x" mainX " y" mainY " NoActivate")
        else
            MainGUI.Show("NoActivate")
    } else {
        MainGUI.Hide()
    }

    if IBVisible && !IBManualHide
        IB_PositionGui()
    else if IsObject(IB_GUI)
        IB_GUI.Hide()

    if ColorGUIVisible && !ColorManualHide
        PositionColorGui()
    else if IsObject(ColorGUI)
        ColorGUI.Hide()

    if LinkGUIVisible && !LinkManualHide
        PositionLinkGUI()
    else if IsObject(LinkGUI)
        LinkGUI.Hide()

    if persist {
        SaveGUIPositions()
        DebugLog("GUI scale set to " newScale)
    } else {
        DebugLog("Preview GUI scale set to " newScale)
    }
}
; ============================================================

_ApplyThemePreset(name, inpMap, swMap, persist := true) {
    global _IBColors, _IBTheme, SETTINGS_FILE
    presets := IBThemePresets()
    colors := presets.Get(name, presets["Default"])
    for key, val in colors {
        val := NormalizeHexColorText(val, "555555")
        _IBColors[key] := val
        if persist {
            try IniWrite(val, SETTINGS_FILE, "IBColors", key)
        }
    }
    _IBTheme := name
    if persist {
        try IniWrite(_IBTheme, SETTINGS_FILE, "Settings", "IBTheme")
        try SettingsSyncIniWatcher()
    }
    RebuildIBFromTheme()
    for key, ctrl in inpMap {
        ctrl.Value := NormalizeHexColorText(_IBColors.Get(key, "555555"), "555555")
        if swMap.Has(key) {
            swMap[key].Opt("Background" NormalizeHexColorText(_IBColors.Get(key, "555555"), "555555"))
            swMap[key].Redraw()
        }
    }
}
_PreviewThemePreset(name, inpMap, swMap) {
    _ApplyThemePreset(name, inpMap, swMap, false)
}

_ApplyThemeColors(inp, swMap, themeName := "Custom") {
    global _IBColors, _IBTheme, SETTINGS_FILE
    for key, ctrl in inp {
        val := NormalizeHexColorText(ctrl.Value, _IBColors.Get(key, "555555"))
        ctrl.Value := val
        _IBColors[key] := val
        try IniWrite(val, SETTINGS_FILE, "IBColors", key)
        if swMap.Has(key) {
            swMap[key].Opt("Background" val)
            swMap[key].Redraw()
        }
    }
    _IBTheme := themeName != "" ? themeName : "Custom"
    try IniWrite(_IBTheme, SETTINGS_FILE, "Settings", "IBTheme")
    try SettingsSyncIniWatcher()
    RebuildIBFromTheme()
}

IBColorProfileKeys() {
    return ["33_se","66_se","25_se","75_se","40_se","60_se"
        ,"33_es","66_es","25_es","75_es","40_es","60_es"
        ,"s2e","e2s","empty_se","empty_es"]
}

ExportIBColorProfile(inpMap := 0, ddlTheme := 0, *) {
    global _IBColors, _IBTheme
    ts := FormatTime(, "dd-MM-yyyy")
    fn := FileSelect("S16", A_MyDocuments "\ib_color_" ts ".ini", "Export IB Color Profile", "INI (*.ini)")
    if fn = ""
        return
    try {
        IniWrite("Nastarxa CSP IB Color Profile", fn, "Profile", "Type")
        themeName := IsObject(ddlTheme) ? ddlTheme.Text : _IBTheme
        IniWrite(themeName, fn, "Profile", "Theme")
        for _, key in IBColorProfileKeys() {
            val := IsObject(inpMap) && inpMap.Has(key)
                ? NormalizeHexColorText(inpMap[key].Value, _IBColors.Get(key, "555555"))
                : NormalizeHexColorText(_IBColors.Get(key, "555555"), "555555")
            IniWrite(val, fn, "IBColors", key)
        }
        ShowNotify("IB Color", "Exported profile", "0x4CAF50")
        DebugLog("Exported IB color profile to " fn)
    } catch as e {
        ShowNotify("IB Color", "Export failed", "0xE53935")
        DebugLog("IB color export failed: " e.Message)
    }
}

ImportIBColorProfile(inpMap := 0, swMap := 0, ddlTheme := 0, saveNow := false, *) {
    global _IBColors, _IBTheme, SETTINGS_FILE
    fn := FileSelect("3", A_MyDocuments "\ib_color_profile_*.ini", "Import IB Color Profile", "INI (*.ini)")
    if fn = ""
        return
    try {
        imported := 0
        for _, key in IBColorProfileKeys() {
            raw := IniRead(fn, "IBColors", key, "")
            if Trim(raw) = ""
                continue
            val := NormalizeHexColorText(raw, _IBColors.Get(key, "555555"))
            _IBColors[key] := val
            if saveNow
                IniWrite(val, SETTINGS_FILE, "IBColors", key)
            imported++
            if IsObject(inpMap) && inpMap.Has(key)
                inpMap[key].Value := val
            if IsObject(swMap) && swMap.Has(key) {
                swMap[key].Opt("Background" val)
                swMap[key].Redraw()
            }
        }
        if imported = 0 {
            ShowNotify("IB Color", "No IBColors found", "0xE53935")
            return
        }
        _IBTheme := "Custom"
        if saveNow
            IniWrite("Custom", SETTINGS_FILE, "Settings", "IBTheme")
        if IsObject(ddlTheme)
            ddlTheme.Choose("Custom")
        if saveNow
            try SettingsSyncIniWatcher()
        RebuildIBFromTheme()
        ShowNotify("IB Color", "Imported " imported " colors", "0x4CAF50")
        DebugLog("Imported IB color profile from " fn)
    } catch as e {
        ShowNotify("IB Color", "Import failed", "0xE53935")
        DebugLog("IB color import failed: " e.Message)
    }
}

RebuildIBFromTheme() {
    global InbetweenMode, InbetweenData, InbetweenIndex
    InbetweenData := BuildInbetweenData(InbetweenMode)
    UpdateIBButtons()
    UpdateInbetweenModeButton()
    UpdateModeButtons()
    UpdateIBGui(InbetweenIndex)
}

; ============================================================

