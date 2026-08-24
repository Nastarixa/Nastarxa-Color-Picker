; BACKUP / RESTORE CONFIG
ExportConfigJSON(dest := "") {
    global MainGUI_X, MainGUI_Y, IB_X, IB_Y, ColorGUI_X, ColorGUI_Y, LinkGUI_X, LinkGUI_Y, ColorLayout
    global Scale, PieScale, Speed, IB_Opacity, Color_Opacity, Link_Opacity
    global InbetweenMode, InbetweenIndex, LT_Color, LT_ClickX, LT_ClickY
    global ColorClick1X, ColorClick1Y, ColorClick2X, ColorClick2Y
    global PickerPath, FishbonePath, ResizerPath, SheetsURL, DriveURL
    global AutoSaveInterval, _useUltimateSaveAs, _timerAskFileName
    global HOLD_THRESHOLD_MS, _tabBlockPassthrough, _selectCelMode, _capsBlockOutput
    global CONTRAST_THRESHOLD
    global NotifyEnabled, NotifyMonitor, NotifyPosition
    global NavEnabled, CapslockEnabled, TabCombosEnabled, LWinEnabled, ResetEnabled
    global _IBTheme, _IBColors, _ccOffsetX, _ccOffsetY, _ccTickMs, _ccFollowCursor, _ccX, _ccY
    global _ccMiddlePickEnabled, _ccClipboardFormat
    global ReqAnimationEnabled, ReqNastarEnabled
    global _HoverState
    global _pieStyle, _pieQuickHintsVisible, _pieQuickSlotHintsPos, _pieQuickHintCount
    global CONFIG_VERSION

    if dest = ""
        dest := A_MyDocuments "\CSP_config_export_" FormatTime(, "yyyyMMdd_HHmmss") ".json"

    config := Map(
        "version", CONFIG_VERSION,
        "exported", FormatTime(, "yyyy-MM-dd HH:mm:ss"),
        "main", Map(
            "x", MainGUI_X, "y", MainGUI_Y
        ),
        "ib", Map(
            "x", IB_X, "y", IB_Y,
            "mode", InbetweenMode, "index", InbetweenIndex,
            "opacity", IB_Opacity, "theme", _IBTheme, "colors", _IBColors.Clone()
        ),
        "color", Map(
            "x", ColorGUI_X, "y", ColorGUI_Y,
            "layout", ColorLayout, "opacity", Color_Opacity
        ),
        "link", Map(
            "x", LinkGUI_X, "y", LinkGUI_Y,
            "layout", LinkLayout,
            "opacity", Link_Opacity
        ),
        "display", Map(
            "scale", Scale, "pieScale", PieScale, "speed", Speed
        ),
        "notify", Map(
            "enabled", NotifyEnabled, "monitor", NotifyMonitor, "position", NotifyPosition
        ),
        "colorInfo", Map(
            "offsetX", _ccOffsetX, "offsetY", _ccOffsetY,
            "tickMs", _ccTickMs,
            "followCursor", _ccFollowCursor, "middlePick", _ccMiddlePickEnabled,
            "clipboardFormat", _ccClipboardFormat, "x", _ccX, "y", _ccY
        ),
        "paths", Map(
            "picker", PickerPath, "fishbone", FishbonePath,
            "resizer", ResizerPath, "sheets", SheetsURL, "drive", DriveURL,
            "ltColor", LT_Color, "ltClickX", LT_ClickX, "ltClickY", LT_ClickY,
            "color1X", ColorClick1X, "color1Y", ColorClick1Y,
            "color2X", ColorClick2X, "color2Y", ColorClick2Y
        ),
        "toggles", Map(
            "nav", NavEnabled, "capslock", CapslockEnabled,
            "tabCombos", TabCombosEnabled, "lWin", LWinEnabled,
            "reset", ResetEnabled, "reqAnimation", ReqAnimationEnabled,
            "reqNastar", ReqNastarEnabled
        ),
        "timing", Map(
        "holdThresholdMs", HOLD_THRESHOLD_MS,
        "contrastThreshold", CONTRAST_THRESHOLD,
        "tabBlockPassthrough", _tabBlockPassthrough,
        "capsBlockOutput", _capsBlockOutput,
            "autoSaveInterval", AutoSaveInterval,
            "useUltimateSaveAs", _useUltimateSaveAs,
            "timerAskFile", _timerAskFileName,
            "selectCelMode", _selectCelMode
        ),
        "tooltips", Map(
            "delayMs", _HoverState.Get("delay", 500),
            "enabled", _HoverState.Get("enabled", true)
        ),
        "pieMenu", Map(
            "style", _pieStyle,
            "quickHints", _pieQuickHintsVisible,
            "slotQuickHintsPos", _pieQuickSlotHintsPos,
            "quickHintCount", _pieQuickHintCount
        )
    )

    try {
        json := _MapToJSON(config, 1)
        tmp := dest ".tmp"
        try FileDelete(tmp)
        FileAppend(json, tmp, "UTF-8")
        FileMove(tmp, dest, 1)
        _HK_ResultPopup("Export", "Config exported to:`n" dest, "4CAF50")
        DebugLog("Config exported to " dest)
        return dest
    } catch as err {
        _HK_ResultPopup("Export Error", "Export failed: " err.Message, "E53935")
        return ""
    }
}

ImportConfigJSON(src := "") {
    if src = "" {
        src := FileSelect(3, A_MyDocuments, "Select config JSON to import", "Config JSON (*.json)")
        if src = ""
            return
    }
    if !FileExist(src) {
        _HK_ResultPopup("Import Error", "File not found: " src, "E53935")
        return
    }
    try {
        raw := FileRead(src, "UTF-8")
        config := _JSONToMap(raw)
    } catch as err {
        _HK_ResultPopup("Import Error", "Failed to parse JSON: " err.Message, "E53935")
        return
    }
    if !(config is Map) {
        _HK_ResultPopup("Import Error", "Invalid JSON structure — expected an object.", "E53935")
        return
    }

    cDlg := Gui("+AlwaysOnTop +ToolWindow", "Import Config")
    cDlg.BackColor := "1E1F22"
    cDlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    cDlg.MarginX := S(14)
    cDlg.MarginY := S(14)
    cDlg.AddText("cFFD54F", "Import config from:`n" src)
    cDlg.AddText("xm y+" S(8) " cAAAAAA", "This will overwrite current settings. A backup will be created first.")
    result := false
    cDlg.AddButton("xm y+10 w" S(80) " h" S(26) " cFFFFFF", "Import").OnEvent("Click", (*) => (result := true, cDlg.Destroy()))
    cDlg.AddButton("x+8 yp w" S(80) " h" S(26), "Cancel").OnEvent("Click", (*) => cDlg.Destroy())
    cDlg.Show("AutoSize")
    GuiWaitForCloseSafe(cDlg)
    if !result
        return

    try {
        CreateConfigBackup("before_import", false)
        _ApplyConfigMap(config)
        _HK_ResultPopup("Import", "Config imported. Restart for full effect.", "4CAF50")
    } catch as err {
        _HK_ResultPopup("Import Error", "Import failed: " err.Message, "E53935")
    }
}

ShowImportConfigChoice(*) {
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Import Config")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)
    dlg.AddText("xm w" S(360) " cFFD54F", "Import configuration")
    dlg.AddText("xm y+6 w" S(420) " cAAAAAA", "Choose what to import. A backup is created before settings are overwritten.")
    dlg.AddText("xm y+8 w" S(420) " cFFFFFF", "Import JSON")
    dlg.AddText("xm y+2 w" S(420) " cAAAAAA", "Use for lightweight config exported by Export JSON. It restores selected runtime settings such as GUI positions, opacity, scale, LT coordinates, paths, toggles, timing, and IB colors.")
    dlg.AddText("xm y+8 w" S(420) " cFFFFFF", "Import Mode Bundle")
    dlg.AddText("xm y+2 w" S(420) " cAAAAAA", "Use to migrate a single mode between installations or restore its backup. It imports a mode's split INI settings and definition from a Mode Bundle folder.")
    btnW := S(135), btnH := S(28), gap := S(8)
    btnJson := dlg.AddButton("xm y+" S(12) " w" btnW " h" btnH, "Import JSON")
    btnJson.importDlg := dlg
    btnJson.OnEvent("Click", _ImportChoiceJSON)
    btnBundle := dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Import Mode Bundle")
    btnBundle.importDlg := dlg
    btnBundle.OnEvent("Click", _ImportChoiceBundle)
    btnClose := dlg.AddButton("x+" gap " yp w" btnW " h" btnH " Default", "Cancel")
    btnClose.OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("AutoSize")
    SetTimer((*) => btnClose.Focus(), -10)
}

_ImportChoiceJSON(ctrl, *) {
    try ctrl.importDlg.Destroy()
    SetTimer(ImportConfigJSON, -10)
}

_ImportChoiceBundle(ctrl, *) {
    try ctrl.importDlg.Destroy()
    SetTimer(ImportSettingsBundle, -10)
}

ExportTheme(dest := "") {
    global Scale, PieScale, IB_Opacity, Color_Opacity, Link_Opacity
    global _IBTheme, _IBColors, ColorLayout, LinkLayout
    global _ccOffsetX, _ccOffsetY, _ccTickMs, _ccFollowCursor, _ccMiddlePickEnabled, _ccClipboardFormat
    global _pieStyle, _pieQuickHintsVisible, _pieQuickSlotHintsPos, _pieQuickHintCount
    global _HoverState
    global NotifyEnabled, NotifyMonitor, NotifyPosition

    if dest = ""
        dest := A_MyDocuments "\CSP_theme_" FormatTime(, "yyyyMMdd_HHmmss") ".json"

    ibColorsClone := Map()
    try ibColorsClone := _IBColors.Clone()
    catch
        ibColorsClone := Map()

    hoverEnabled := true
    hoverDelay := 500
    try {
        hoverEnabled := _HoverState.Get("enabled", true)
        hoverDelay := _HoverState.Get("delay", 500)
    }

    data := Map(
        "version", 1,
        "exported", FormatTime(, "yyyy-MM-dd HH:mm:ss"),
        "scale", Scale,
        "pieScale", PieScale,
        "ib", Map(
            "opacity", IB_Opacity,
            "theme", _IBTheme,
            "colors", ibColorsClone
        ),
        "color", Map(
            "opacity", Color_Opacity,
            "layout", ColorLayout
        ),
        "link", Map(
            "opacity", Link_Opacity,
            "layout", LinkLayout
        ),
        "colorInfo", Map(
            "offsetX", _ccOffsetX,
            "offsetY", _ccOffsetY,
            "tickMs", _ccTickMs,
            "followCursor", _ccFollowCursor,
            "middlePick", _ccMiddlePickEnabled,
            "clipboardFormat", _ccClipboardFormat
        ),
        "pieMenu", Map(
            "style", _pieStyle,
            "quickHints", _pieQuickHintsVisible,
            "slotQuickHintsPos", _pieQuickSlotHintsPos,
            "quickHintCount", _pieQuickHintCount
        ),
        "tooltips", Map(
            "enabled", hoverEnabled,
            "delayMs", hoverDelay
        ),
        "notify", Map(
            "enabled", NotifyEnabled,
            "monitor", NotifyMonitor,
            "position", NotifyPosition
        )
    )

    try {
        json := _MapToJSON(data, 1)
        tmp := dest ".tmp"
        try FileDelete(tmp)
        FileAppend(json, tmp, "UTF-8")
        FileMove(tmp, dest, 1)
        _HK_ResultPopup("Theme Export", "Theme exported to:`n" dest, "4CAF50")
        DebugLog("Theme exported to " dest)
        return dest
    } catch as err {
        _HK_ResultPopup("Theme Export Error", "Export failed: " err.Message, "E53935")
        return ""
    }
}

ImportTheme(src := "") {
    global SETTINGS_FILE, PIE_SETTINGS_FILE
    global Scale, PieScale, IB_Opacity, Color_Opacity, Link_Opacity
    global _IBTheme, _IBColors, ColorLayout, LinkLayout
    global _ccOffsetX, _ccOffsetY, _ccTickMs, _ccFollowCursor, _ccMiddlePickEnabled, _ccClipboardFormat
    global _pieStyle, _pieQuickHintsVisible, _pieQuickSlotHintsPos, _pieQuickHintCount
    global _HoverState
    global NotifyEnabled, NotifyMonitor, NotifyPosition

    if src = "" {
        src := FileSelect(1, A_MyDocuments, "Select theme JSON to import", "Theme JSON (*.json)")
        if src = ""
            return
    }
    if !FileExist(src) {
        _HK_ResultPopup("Theme Import Error", "File not found: " src, "E53935")
        return
    }
    try {
        raw := FileRead(src, "UTF-8")
        data := _JSONToMap(raw)
    } catch as err {
        _HK_ResultPopup("Theme Import Error", "Failed to parse JSON: " err.Message, "E53935")
        return
    }
    if !(data is Map) {
        _HK_ResultPopup("Theme Import Error", "Invalid JSON structure — expected an object.", "E53935")
        return
    }

    cDlg := Gui("+AlwaysOnTop +ToolWindow", "Import Theme")
    cDlg.BackColor := "1E1F22"
    cDlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    cDlg.MarginX := S(14)
    cDlg.MarginY := S(14)
    cDlg.AddText("cFFD54F", "Import theme from:`n" src)
    cDlg.AddText("xm y+" S(8) " cAAAAAA", "This will overwrite current visual settings (scale, colors, layout, tooltips).")
    result := false
    cDlg.AddButton("xm y+10 w" S(80) " h" S(26) " cFFFFFF", "Import").OnEvent("Click", (*) => (result := true, cDlg.Destroy()))
    cDlg.AddButton("x+8 yp w" S(80) " h" S(26), "Cancel").OnEvent("Click", (*) => cDlg.Destroy())
    cDlg.Show("AutoSize")
    GuiWaitForCloseSafe(cDlg)
    if !result
        return

    try {
        CreateConfigBackup("before_theme_import", false)
        if data.Has("scale") {
            v := data["scale"]
            if v >= 0.5 && v <= 1.5
                Scale := v
        }
        if data.Has("pieScale") {
            v := data["pieScale"]
            if v >= 0.5 && v <= 1.5
                PieScale := v
        }
        ib := data.Get("ib", Map())
        if ib.Count {
            if ib.Has("opacity") && ib["opacity"] >= 0 && ib["opacity"] <= 255
                IB_Opacity := ib["opacity"]
            _IBTheme := ib.Get("theme", _IBTheme)
            if ib.Has("colors")
                for k, v in ib["colors"]
                    _IBColors[k] := v
        }
        clr := data.Get("color", Map())
        if clr.Count {
            if clr.Has("opacity") && clr["opacity"] >= 0 && clr["opacity"] <= 255
                Color_Opacity := clr["opacity"]
            ColorLayout := clr.Get("layout", ColorLayout)
        }
        lnk := data.Get("link", Map())
        if lnk.Count {
            if lnk.Has("opacity") && lnk["opacity"] >= 0 && lnk["opacity"] <= 255
                Link_Opacity := lnk["opacity"]
            if lnk.Has("layout")
                LinkLayout := lnk["layout"]
        }
        ci := data.Get("colorInfo", Map())
        if ci.Count {
            _ccOffsetX := ci.Get("offsetX", _ccOffsetX)
            _ccOffsetY := ci.Get("offsetY", _ccOffsetY)
            _ccTickMs := Max(15, Min(1000, ci.Get("tickMs", _ccTickMs)))
            _ccFollowCursor := ci.Get("followCursor", _ccFollowCursor)
            _ccMiddlePickEnabled := ci.Get("middlePick", _ccMiddlePickEnabled)
            _ccClipboardFormat := ci.Get("clipboardFormat", _ccClipboardFormat)
            BackupRestoreApplyColorInfoRuntimeState()
        }
        pm := data.Get("pieMenu", Map())
        if pm.Count {
            _pieStyle := PieNormalizeStyle(pm.Get("style", _pieStyle))
            _pieQuickHintsVisible := PieSafeInt(pm.Get("quickHints", _pieQuickHintsVisible), 1, 0, 1)
            _pieQuickSlotHintsPos := PieQuickSlotPosNorm(pm.Get("slotQuickHintsPos", _pieQuickSlotHintsPos))
            _pieQuickHintCount := PieSafeInt(pm.Get("quickHintCount", _pieQuickHintCount), 20, 1, 99)
        }
        tip := data.Get("tooltips", Map())
        if tip.Count {
            if !IsObject(_HoverState)
                _HoverState := Map("map", Map(), "popup", 0, "last", 0, "pending", 0, "pendingX", 0, "pendingY", 0, "delay", 500, "enabled", true)
            if tip.Has("enabled")
                _HoverState["enabled"] := tip["enabled"]
            if tip.Has("delayMs")
                _HoverState["delay"] := tip["delayMs"]
        }
        ntf := data.Get("notify", Map())
        if ntf.Count {
            NotifyEnabled := ntf.Get("enabled", NotifyEnabled)
            NotifyMonitor := ntf.Get("monitor", NotifyMonitor)
            NotifyPosition := ntf.Get("position", NotifyPosition)
        }
        SaveGUIPositions()
        IniWrite(_HoverState["enabled"] ? 1 : 0, SETTINGS_FILE, "Settings", "TooltipEnabled")
        IniWrite(_HoverState["delay"], SETTINGS_FILE, "Settings", "TooltipDelay")
        IniWrite(_pieStyle, PIE_SETTINGS_FILE, "PieMenu", "Style")
        IniWrite(_pieQuickHintsVisible ? 1 : 0, PIE_SETTINGS_FILE, "PieMenu", "QuickHints")
        IniWrite(_pieQuickSlotHintsPos, PIE_SETTINGS_FILE, "PieMenu", "SlotQuickHintsPos")
        IniWrite(_pieQuickHintCount, PIE_SETTINGS_FILE, "PieMenu", "QuickHintCount")
        _HK_ResultPopup("Theme Import", "Theme applied. Restart for full effect.", "4CAF50")
    } catch as err {
        _HK_ResultPopup("Theme Import Error", "Import failed: " err.Message, "E53935")
    }
}

_ApplyConfigMap(config) {
    global PIE_SETTINGS_FILE
    global MainGUI_X, MainGUI_Y
    global IB_X, IB_Y, InbetweenMode, InbetweenIndex, IB_Opacity, _IBTheme, _IBColors
    global ColorGUI_X, ColorGUI_Y, ColorLayout, Color_Opacity
    global LinkGUI_X, LinkGUI_Y, LinkLayout, Link_Opacity
    global MainGUI, IB_GUI, ColorGUI, LinkGUI
    global Scale, PieScale, Speed
    global NotifyEnabled, NotifyMonitor, NotifyPosition
    global _ccOffsetX, _ccOffsetY, _ccTickMs, _ccFollowCursor, _ccMiddlePickEnabled, _ccClipboardFormat, _ccX, _ccY
    global PickerPath, FishbonePath, ResizerPath, SheetsURL, DriveURL
    global LT_ClickX, LT_ClickY, ColorClick1X, ColorClick1Y, ColorClick2X, ColorClick2Y
    global NavEnabled, CapslockEnabled, TabCombosEnabled, LWinEnabled, ResetEnabled
    global ReqAnimationEnabled, ReqNastarEnabled
    global HOLD_THRESHOLD_MS, _tabBlockPassthrough, AutoSaveInterval, _useUltimateSaveAs, _timerAskFileName, _selectCelMode, _capsBlockOutput
    global CONTRAST_THRESHOLD
    global LT_Color, _HoverState
    global _pieStyle, _pieQuickHintsVisible, _pieQuickSlotHintsPos, _pieQuickHintCount

    main := config.Get("main", Map())
    if main.Count {
        MainGUI_X := main.Get("x", MainGUI_X)
        MainGUI_Y := main.Get("y", MainGUI_Y)
    }

    ib := config.Get("ib", Map())
    if ib.Count {
        IB_X := ib.Get("x", IB_X)
        IB_Y := ib.Get("y", IB_Y)
        InbetweenMode := ib.Get("mode", InbetweenMode)
        InbetweenIndex := ib.Get("index", InbetweenIndex)
        IB_Opacity := Max(0, Min(255, ib.Get("opacity", IB_Opacity)))
        _IBTheme := ib.Get("theme", _IBTheme)
        if ib.Has("colors")
            for k, v in ib["colors"]
                _IBColors[k] := v
    }

    clr := config.Get("color", Map())
    if clr.Count {
        ColorGUI_X := clr.Get("x", ColorGUI_X)
        ColorGUI_Y := clr.Get("y", ColorGUI_Y)
        ColorLayout := clr.Get("layout", ColorLayout)
        Color_Opacity := Max(0, Min(255, clr.Get("opacity", Color_Opacity)))
    }

    lnk := config.Get("link", Map())
    if lnk.Count {
        LinkGUI_X := lnk.Get("x", LinkGUI_X)
        LinkGUI_Y := lnk.Get("y", LinkGUI_Y)
        LinkLayout := lnk.Get("layout", LinkLayout)
        Link_Opacity := Max(0, Min(255, lnk.Get("opacity", Link_Opacity)))
    }

    dsp := config.Get("display", Map())
    if dsp.Count {
        Scale := Max(0.5, Min(1.5, dsp.Get("scale", Scale)))
        PieScale := Max(0.5, Min(1.5, dsp.Get("pieScale", PieScale)))
        Speed := dsp.Get("speed", Speed)
    }

    ntf := config.Get("notify", Map())
    if ntf.Count {
        NotifyEnabled := ntf.Get("enabled", NotifyEnabled)
        NotifyMonitor := ntf.Get("monitor", NotifyMonitor)
        NotifyPosition := ntf.Get("position", NotifyPosition)
    }

    ci := config.Get("colorInfo", Map())
    if ci.Count {
        _ccOffsetX := ci.Get("offsetX", _ccOffsetX)
        _ccOffsetY := ci.Get("offsetY", _ccOffsetY)
        _ccTickMs := Max(15, Min(1000, ci.Get("tickMs", _ccTickMs)))
        _ccFollowCursor := ci.Get("followCursor", _ccFollowCursor)
        _ccMiddlePickEnabled := ci.Get("middlePick", _ccMiddlePickEnabled)
        _ccClipboardFormat := ci.Get("clipboardFormat", _ccClipboardFormat)
        _ccX := ci.Get("x", _ccX)
        _ccY := ci.Get("y", _ccY)
        BackupRestoreApplyColorInfoRuntimeState()
    }

    pth := config.Get("paths", Map())
    if pth.Count {
        PickerPath := pth.Get("picker", PickerPath)
        FishbonePath := pth.Get("fishbone", FishbonePath)
        ResizerPath := pth.Get("resizer", ResizerPath)
        SheetsURL := pth.Get("sheets", SheetsURL)
        DriveURL := pth.Get("drive", DriveURL)
        LT_Color := pth.Get("ltColor", LT_Color)
        LT_ClickX := pth.Get("ltClickX", LT_ClickX)
        LT_ClickY := pth.Get("ltClickY", LT_ClickY)
        ColorClick1X := pth.Get("color1X", ColorClick1X)
        ColorClick1Y := pth.Get("color1Y", ColorClick1Y)
        ColorClick2X := pth.Get("color2X", ColorClick2X)
        ColorClick2Y := pth.Get("color2Y", ColorClick2Y)
    }

    tog := config.Get("toggles", Map())
    if tog.Count {
        NavEnabled := tog.Get("nav", NavEnabled)
        CapslockEnabled := tog.Get("capslock", CapslockEnabled)
        TabCombosEnabled := tog.Get("tabCombos", TabCombosEnabled)
        LWinEnabled := tog.Get("lWin", LWinEnabled)
        ResetEnabled := tog.Get("reset", ResetEnabled)
        ReqAnimationEnabled := tog.Get("reqAnimation", ReqAnimationEnabled)
        ReqNastarEnabled := tog.Get("reqNastar", ReqNastarEnabled)
    }

    tim := config.Get("timing", Map())
    if tim.Count {
        HOLD_THRESHOLD_MS := tim.Get("holdThresholdMs", HOLD_THRESHOLD_MS)
        CONTRAST_THRESHOLD := tim.Get("contrastThreshold", CONTRAST_THRESHOLD)
        _tabBlockPassthrough := !!tim.Get("tabBlockPassthrough", _tabBlockPassthrough)
        _capsBlockOutput := !!tim.Get("capsBlockOutput", _capsBlockOutput)
        AutoSaveInterval := tim.Get("autoSaveInterval", AutoSaveInterval)
        _useUltimateSaveAs := tim.Get("useUltimateSaveAs", _useUltimateSaveAs)
        _timerAskFileName := tim.Get("timerAskFile", _timerAskFileName)
        _selectCelMode := tim.Get("selectCelMode", _selectCelMode)
    }

    ltCfg := config.Get("lt", Map())
    if ltCfg.Count {
        LT_Color := ltCfg.Get("color", LT_Color)
    }

    tip := config.Get("tooltips", Map())
    if tip.Count {
        if !IsObject(_HoverState)
            _HoverState := Map("map", Map(), "popup", 0, "last", 0, "pending", 0, "pendingX", 0, "pendingY", 0, "delay", 500, "enabled", true)
        _HoverState["delay"] := tip.Get("delayMs", _HoverState.Get("delay", 500))
        _HoverState["enabled"] := tip.Get("enabled", _HoverState.Get("enabled", true))
    }

    pm := config.Get("pieMenu", Map())
    if pm.Count {
        _pieStyle := PieNormalizeStyle(pm.Get("style", _pieStyle))
        _pieQuickHintsVisible := PieSafeInt(pm.Get("quickHints", _pieQuickHintsVisible), 1, 0, 1)
        _pieQuickSlotHintsPos := PieQuickSlotPosNorm(pm.Get("slotQuickHintsPos", _pieQuickSlotHintsPos))
        _pieQuickHintCount := PieSafeInt(pm.Get("quickHintCount", _pieQuickHintCount), 20, 1, 99)
        try IniWrite(_pieStyle, PIE_SETTINGS_FILE, "PieMenu", "Style")
        try IniWrite(_pieQuickHintsVisible ? 1 : 0, PIE_SETTINGS_FILE, "PieMenu", "QuickHints")
        try IniWrite(_pieQuickSlotHintsPos, PIE_SETTINGS_FILE, "PieMenu", "SlotQuickHintsPos")
        try IniWrite(_pieQuickHintCount, PIE_SETTINGS_FILE, "PieMenu", "QuickHintCount")
    }

    ; Align any live GUI windows to imported coordinates before SaveGUIPositions
    ; reads their current positions back from the OS.
    try if SafeGuiHwnd(MainGUI)
        MainGUI.Move(MainGUI_X, MainGUI_Y)
    try if SafeGuiHwnd(IB_GUI)
        IB_GUI.Move(IB_X, IB_Y)
    try if SafeGuiHwnd(ColorGUI)
        ColorGUI.Move(ColorGUI_X, ColorGUI_Y)
    try if SafeGuiHwnd(LinkGUI)
        LinkGUI.Move(LinkGUI_X, LinkGUI_Y)

    SaveGUIPositions()
    SaveConfigurablePaths()
    try RefreshIBRequirementState()
}

; helpers for JSON serialization
_MapToJSON(val, indent := 0) {
    pad := ""
    Loop indent
        pad .= "    "
    innerPad := pad . "    "
    if IsObject(val) {
        if val is Map {
            if val.Count = 0
                return "{}"
            out := "{`n"
            first := true
            for k, v in val {
                if !first
                    out .= ",`n"
                first := false
                out .= innerPad . Chr(0x22) . k . Chr(0x22) . ": " . _MapToJSON(v, indent + 1)
            }
            out .= "`n" . pad . "}"
            return out
        }
        if val is Array {
            if val.Length = 0
                return "[]"
            out := "[`n"
            for i, v in val {
                if i > 1
                    out .= ",`n"
                out .= innerPad . _MapToJSON(v, indent + 1)
            }
            out .= "`n" . pad . "]"
            return out
        }
    }
    if val is Integer || val is Float
        return val
    s := StrReplace(val, "\", "\\\\")
    s := StrReplace(s, Chr(0x22), "\" . Chr(0x22))
    s := StrReplace(s, "`n", "\\n")
    s := StrReplace(s, "`r", "\\r")
    s := StrReplace(s, "`t", "\\t")
    return Chr(0x22) . s . Chr(0x22)
}

_JSONToMap(raw) {
    ; Use the htmlfile JavaScript engine for parsing, then convert COM values
    ; through explicit JS Array/Object helpers. Plain Object.keys() here would
    ; resolve as an AHK symbol and can fail during config/theme import.
    doc := _JSONDoc()
    try {
        jsonObj := doc.parentWindow.JSON.parse(raw)
        return _JSValToAHK(jsonObj)
    } catch as err
        throw Error("JSON parse failed: " err.Message)
}

_JSONDoc() {
    static doc := ""
    if doc = "" {
        try doc := ComObject("htmlfile")
        catch
            throw Error("JSON import requires Internet Explorer engine (mshtml)")
        doc.write("<meta http-equiv=" Chr(34) "Content-Type" Chr(34) " content=" Chr(34) "text/html; charset=utf-8" Chr(34) ">")
    }
    return doc
}

_JSValToAHK(val) {
    if !IsObject(val)
        return val
    try {
        if ComObjType(val) = 9 { ; IDispatch — treat as JS object/array
            doc := _JSONDoc()
            if doc.parentWindow.Array.isArray(val)
                return _JSArrayToAHK(val)
            return _JSObjectToAHK(val)
        }
    }
    return val
}

_JSObjectToAHK(obj) {
    m := Map()
    try keys := _JSONDoc().parentWindow.Object.keys(obj)
    catch
        return m
    try len := keys.length
    catch
        len := 0
    Loop len {
        k := keys[A_Index - 1]
        m[k] := _JSValToAHK(obj[k])
    }
    return m
}

_JSArrayToAHK(arr) {
    result := []
    try len := arr.length
    catch
        return result
    Loop len
        result.Push(_JSValToAHK(arr[A_Index - 1]))
    return result
}

; ============================================================

BackupRestoreApplyColorInfoRuntimeState() {
    global _ccTickMs, _ccFollowCursor, _ccMiddlePickEnabled, _ccClipboardFormat
    _ccClipboardFormat := StrUpper(Trim(_ccClipboardFormat))
    if _ccClipboardFormat != "HEX"
        _ccClipboardFormat := "RGB"
    try ColorInfoSetFollowMode(_ccFollowCursor, false)
    try ColorInfoSetMiddlePick(_ccMiddlePickEnabled, false)
    try ColorInfoSetClipboardFormat(_ccClipboardFormat, false)
    try ColorInfoSetTickMs(_ccTickMs, false)
}

; ============================================================

ConfigBackupDir() {
    global SETTINGS_DIR
    dir := SETTINGS_DIR "\settings_backups"
    if !DirExist(dir)
        DirCreate(dir)
    return dir
}

BackupUserScriptFiles(destRoot) {
    global HK_UserScriptDir
    scriptSrc := ""
    try scriptSrc := HK_UserScriptDir
    if scriptSrc = "" || !DirExist(scriptSrc)
        return 0
    scriptDest := destRoot "\user_hotkey_scripts"
    try DirCreate(scriptDest)
    copied := 0
    try {
        Loop Files scriptSrc "\*.ahk", "F" {
            try FileCopy(A_LoopFileFullPath, scriptDest "\" A_LoopFileName, 1)
            copied++
        }
    }
    return copied
}

RestoreUserScriptFiles(srcRoot) {
    global HK_UserScriptDir
    scriptSrc := srcRoot "\user_hotkey_scripts"
    if !DirExist(scriptSrc)
        return 0
    scriptDest := ""
    try scriptDest := HK_UserScriptDir
    if scriptDest = ""
        return 0
    try {
        if !DirExist(scriptDest)
            DirCreate(scriptDest)
    }
    restored := 0
    try {
        Loop Files scriptSrc "\*.ahk", "F" {
            try FileCopy(A_LoopFileFullPath, scriptDest "\" A_LoopFileName, 1)
            restored++
        }
    }
    return restored
}

; The settings bundle feature is per-mode now. A bundle carries one mode's
; category settings so it can be moved between installations or backed up on
; its own. The full-settings path is covered by Backup/Restore instead.
ExportSettingsBundle(*) {
    return ModeSettingsExportBundle()
}

ImportSettingsBundle(src := "") {
    return ModeSettingsImportBundle(src)
}

CreateConfigBackup(label := "manual", notify := true) {
    global SETTINGS_DIR
    if !DirExist(SETTINGS_DIR)
        throw Error("Settings folder not found: " SETTINGS_DIR)
    label := RegExReplace(label, "[^\w-]", "_")
    ts := FormatTime(, "yyyyMMdd_HHmmss")
    bak := ConfigBackupDir() "\settings_" label "_" ts
    try DirCreate(bak)
    copied := 0
    try {
        Loop Files SETTINGS_DIR "\*.ini", "F" {
            try FileCopy(A_LoopFileFullPath, bak "\" A_LoopFileName, 1)
            copied++
        }
    }
    modeDirs := 0
    Loop Files SETTINGS_DIR "\*", "D" {
        ; skip the backup folders themselves; everything else is a per-mode settings folder
        if A_LoopFileName = "settings_backups" || A_LoopFileName = "mode_backups"
            continue
        try {
            DirCopy(A_LoopFileFullPath, bak "\" A_LoopFileName)
            modeDirs++
        } catch as err
            DebugLog("Config backup: skipped mode folder " A_LoopFileName ": " err.Message)
    }
    scriptCopied := BackupUserScriptFiles(bak)
    if copied < 1
        throw Error("No settings files found in: " SETTINGS_DIR)
    DebugLog("Config backed up to " bak " (" copied " ini, " modeDirs " mode folders, " scriptCopied " user scripts)")
    if notify
        _HK_ResultPopup("Backup", "Backup saved:`n" bak, "4CAF50")
    return bak
}

CreateSettingsSnapshotBeforeSave(scope := "settings") {
    try {
        path := CreateConfigBackup("before_save_" scope, false)
        DebugLog("Settings snapshot before save: " path)
        return path
    } catch as e {
        DebugLog("Settings snapshot skipped: " e.Message)
        return ""
    }
}

BackupConfig(*) {
    try {
        CreateConfigBackup("manual", true)
    } catch as e {
        _HK_ResultPopup("Backup Error", "Backup failed: " e.Message, "E53935")
    }
}

; Copies base settings INI files, per-mode folders and user scripts from a
; backup folder back into the settings tree. Returns a Map with counts.
RestoreConfigFromFolder(dir) {
    global SETTINGS_DIR
    restored := 0
    Loop Files dir "\*.ini", "F" {
        FileCopy(A_LoopFileFullPath, SETTINGS_DIR "\" A_LoopFileName, 1)
        restored++
    }
    modeRestored := 0
    Loop Files dir "\*", "D" {
        if A_LoopFileName = "user_hotkey_scripts" || A_LoopFileName = "mode_backups"
            continue
        modeName := A_LoopFileName
        tgt := SETTINGS_DIR "\" modeName
        if !DirExist(tgt)
            DirCreate(tgt)
        Loop Files dir "\" modeName "\*.ini", "F"
            FileCopy(A_LoopFileFullPath, tgt "\" A_LoopFileName, 1), modeRestored++
    }
    scriptRestored := RestoreUserScriptFiles(dir)
    return Map("ini", restored, "mode", modeRestored, "scripts", scriptRestored)
}

RestoreConfig(*) {
    global SETTINGS_DIR
    bakDir := ConfigBackupDir()
    if !DirExist(bakDir) {
        _HK_ResultPopup("Restore Error", "No backups found.", "E53935")
        return
    }
    folders := []
    Loop Files bakDir "\*", "D"
        folders.Push(A_LoopFileName)
    if folders.Length = 0 {
        _HK_ResultPopup("Restore Error", "No backups found in:" bakDir, "E53935")
        return
    }
    cDlg := Gui("+AlwaysOnTop +ToolWindow", "Restore Config")
    cDlg.BackColor := "1E1F22"
    cDlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    cDlg.MarginX := S(14)
    cDlg.MarginY := S(14)
    cDlg.AddText("xm w" S(480) " cAAAAAA", "Select a backup folder to restore:")
    lv := cDlg.AddListView("xm y+8 w" S(480) " h" S(200) " Grid +Report c000000", ["#", "Backup Folder"])
    for i, f in folders
        lv.Add("", i, f)
    lv.ModifyCol(1, 0)
    lv.ModifyCol(2, S(470))
    result := ""
    cDlg.AddButton("xm y+10 w" S(80) " h" S(26) " cFFFFFF", "Restore").OnEvent("Click", (*) => (
        row := lv.GetNext(0, "Focused"),
        result := row > 0 ? folders[Integer(lv.GetText(row, 1))] : "",
        cDlg.Destroy()
    ))
    cDlg.AddButton("x+6 yp w" S(80) " h" S(26), "Cancel").OnEvent("Click", (*) => cDlg.Destroy())
    cDlg.Show("AutoSize")
    GuiWaitForCloseSafe(cDlg)
    if result = ""
        return
    dir := bakDir "\" result
    if !DirExist(dir)
        return
    try {
        CreateConfigBackup("before_restore", false)
        if !DirExist(SETTINGS_DIR)
            DirCreate(SETTINGS_DIR)
        r := RestoreConfigFromFolder(dir)
        if r["ini"] < 1
            throw Error("No INI files found in selected backup.")
        DebugLog("Config restored from " dir " (" r["ini"] " ini, " r["mode"] " mode files, " r["scripts"] " user scripts)")
        try LoadGUIPositions()
        try _LoadIBThemeFromIni()
        try HK_Load()
        try LoadPieItems()
        try LoadLinkItems()
        try LoadColorItems()
        try RefreshIBRequirementState()
        _HK_ResultPopup("Restore", "Config restored and reloaded. Restart the script if any GUI elements appear incorrect.", "4CAF50")
    } catch as e {
        _HK_ResultPopup("Restore Error", "Restore failed: " e.Message, "E53935")
    }
}

; ============================================================
; Per-mode backup / restore. A mode backup captures the mode's settings folder
; snapshot plus its definition (name, switch hotkey, override map), which lives
; in the base hotkey file rather than the mode folder. Backups are stored under
; settings_backups\mode_backups\ so the full-config backup/restore ignores them.
; ============================================================

ModeBackupsRoot() {
    return ConfigBackupDir() "\mode_backups"
}

; Backs up one custom mode. Returns the created backup folder path.
CreateModeBackup(id, notify := true) {
    global HK_Modes
    if !HK_Modes.Has(id) || id = "default"
        throw Error("Cannot back up mode: " id)
    m := HK_Modes[id]
    ts := FormatTime(, "yyyyMMdd_HHmmss")
    safe := StrReplace(RegExReplace(id, "[\\/:\*\?`"<>\|]", "_"), " ", "_")
    bak := ModeBackupsRoot() "\mode_" safe "_" ts
    DirCreate(bak)
    ; 1) the mode's settings folder snapshot
    srcDir := ModeSettingsModeDir(id)
    if DirExist(srcDir)
        DirCopy(srcDir, bak "\settings")
    ; 2) the mode definition in the same text format HK_SaveModes writes
    name := m.Get("name", id)
    def := "name=" name "`n"
    if m.Get("switch", "") != ""
        def .= "switch=" m["switch"] "`n"
    try FileAppend(def, bak "\mode_definition.ini", "UTF-8")
    DebugLog("Mode backup created: " bak)
    if notify
        _HK_ResultPopup("Mode Backup", "Backup saved:`n" bak, "4CAF50")
    return bak
}

; Lists a mode's backups, newest first.
ModeBackupList(id) {
    base := ModeBackupsRoot()
    res := []
    if !DirExist(base)
        return res
    safe := StrReplace(RegExReplace(id, "[\\/:\*\?`"<>\|]", "_"), " ", "_")
    Loop Files base "\mode_" safe "_*", "D"
        res.InsertAt(1, A_LoopFilePath)
    return res
}

; Applies a mode backup (definition + settings folder) back into the live mode.
RestoreModeConfig(id, path) {
    global HK_Modes
    if !DirExist(path)
        return false
    defFile := path "\mode_definition.ini"
    if FileExist(defFile) {
        try defText := FileRead(defFile)
        catch
            defText := ""
        m := HK_ParseModeSectionText(defText, id)
        name := m.Get("name", id)
        if name = "" || name = id
            name := IsObject(HK_Modes.Get(id, 0)) ? HK_Modes[id].Get("name", id) : id
        HK_Modes[id] := m
        HK_Modes[id]["name"] := name
    }
    snap := path "\settings"
    if DirExist(snap) {
        tgt := ModeSettingsModeDir(id)
        if !DirExist(tgt)
            DirCreate(tgt)
        Loop Files snap "\*.ini", "F"
            FileCopy(A_LoopFileFullPath, tgt "\" A_LoopFileName, 1)
    }
    HK_SaveModes()
    HK_Load()
    HK_ReapplyAll()
    try UpdateMainModeButton()
    try UpdateIBModeIndicator()
    return true
}

; Restore picker dialog for a single mode's backups.
ShowModeRestoreDialog(id) {
    global HK_Modes
    m := HK_Modes.Get(id, 0)
    name := IsObject(m) ? m.Get("name", id) : id
    list := ModeBackupList(id)
    if list.Length = 0 {
        ShowNotify("Modes", "No backups found for '" name "'")
        return
    }
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Restore Mode")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)
    dlg.AddText("xm w" S(480) " cAAAAAA", "Restore a backup for mode '" name "'?")
    lv := dlg.AddListView("xm y+8 w" S(480) " h" S(200) " Grid +Report c000000", ["#", "Backup"])
    for i, p in list {
        SplitPath(p, &leaf)
        lv.Add("", i, leaf)
    }
    lv.ModifyCol(1, 0)
    lv.ModifyCol(2, S(470))
    result := ""
    dlg.AddButton("xm y+10 w" S(80) " h" S(26) " cFFFFFF", "Restore").OnEvent("Click", (*) => (
        row := lv.GetNext(0, "Focused"),
        result := row > 0 ? list[Integer(lv.GetText(row, 1))] : "",
        dlg.Destroy()
    ))
    dlg.AddButton("x+6 yp w" S(80) " h" S(26), "Cancel").OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("AutoSize")
    GuiWaitForCloseSafe(dlg)
    if result = ""
        return
    try {
        CreateConfigBackup("before_mode_restore", false)
        RestoreModeConfig(id, result)
        _HK_ResultPopup("Mode Restore", "Mode '" name "' restored and reloaded.", "4CAF50")
    } catch as e {
        _HK_ResultPopup("Mode Restore Error", "Restore failed: " e.Message, "E53935")
    }
}

; ============================================================
