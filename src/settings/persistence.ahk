; PERSISTENCE — INI positions
; ============================================================

IniReadIntSafe(file, section, key, default, min := "", max := "") {
    try val := Integer(IniRead(file, section, key, default))
    catch
        val := default
    if min != "" && val < min
        val := min
    if max != "" && val > max
        val := max
    return val
}

IniReadFloatSafe(file, section, key, default, min := "", max := "") {
    try val := Float(IniRead(file, section, key, default))
    catch
        val := default
    if min != "" && val < min
        val := min
    if max != "" && val > max
        val := max
    return val
}

; Reads an entire INI section into a Map(key => value). Returns empty Map on error.
IniReadSectionMap(file, section) {
    result := Map()
    try raw := IniRead(file, section)
    catch
        return result
    for line in StrSplit(raw, "`n", "`r") {
        clean := Trim(line)
        if clean = "" || SubStr(clean, 1, 1) = ";"
            continue
        pos := InStr(clean, "=")
        if !pos
            continue
        key := Trim(SubStr(clean, 1, pos - 1))
        val := Trim(SubStr(clean, pos + 1))
        if key != ""
            result[key] := val
    }
    return result
}

AtomicFileWrite(path, content) {
    tmpPath := path ".tmp"
    try {
        FileDelete(tmpPath)
        FileAppend(content, tmpPath, "UTF-8")
        FileMove(tmpPath, path, 1)
        return true
    } catch as err {
        SettingsDiagPush("ERR", "Atomic write failed", path ": " err.Message)
        try FileDelete(tmpPath)
        return false
    }
}

EnsureConfigVersion() {
    global SETTINGS_FILE, CONFIG_VERSION, _settingsNeedUpgrade
    EnsureMainSettingsFile()
    if !FileExist(SETTINGS_FILE) {
        SettingsDiagPush("WARN", "Config version check skipped", "Settings file missing.")
        return
    }
    current := IniReadIntSafe(SETTINGS_FILE, "Settings", "ConfigVersion", 0, 0)
    if current < CONFIG_VERSION {
        IniWrite(CONFIG_VERSION, SETTINGS_FILE, "Settings", "ConfigVersion")
        _settingsNeedUpgrade := false
        try SettingsSyncIniWatcher()
        DebugLog("Config version updated: " current " -> " CONFIG_VERSION)
        SettingsDiagPush("OK", "Config version upgraded", current " -> " CONFIG_VERSION)
    } else {
        _settingsNeedUpgrade := false
        SettingsDiagPush("INFO", "Config version OK", "Version " current)
    }
}

SelfHealSettings(*) {
    global SETTINGS_DIR
    progress := 0
    if !DirExist(SETTINGS_DIR)
        DirCreate(SETTINGS_DIR)
    SettingsDiagPush("INFO", "Self-heal started", SETTINGS_DIR)
    try {
        progress := SettingsProgressStart("Settings Self-Heal", "Preparing repair...", 5)
        SettingsProgressStep(progress, "Ensuring settings files...", 15)
        EnsureMainSettingsFile()
        EnsureSplitSettingsFiles()
        SettingsProgressStep(progress, "Compacting duplicated INI data...", 28)
        CompactSplitSettingsFiles()
        SettingsProgressStep(progress, "Updating config version...", 38)
        EnsureConfigVersion()
        SettingsProgressStep(progress, "Reloading saved settings...", 52)
        LoadGUIPositions()
        _LoadIBThemeFromIni()
        LoadConfigurablePaths()
        LoadLinkItems()
        LoadColorItems()
        LoadPieItems()
        HK_Load()
        SettingsProgressStep(progress, "Writing cleaned settings...", 72)
        SaveGUIPositions()
        SaveConfigurablePaths()
        SaveLinkItems()
        SaveColorItems()
        SavePieItems()
        HK_Save()
        EnsureSplitSettingsFiles()
        SettingsProgressStep(progress, "Reapplying runtime state...", 90)
        HK_ReapplyAll()
        try RefreshIBRequirementState()
        try SettingsSyncIniWatcher()
        UpdateStartupHealthBadge()
        RefreshStatusDashboard()
        SettingsProgressStep(progress, "Done.", 100)
        Sleep(100)
        DebugLog("Self-heal completed for settings files")
        SettingsDiagPush("OK", "Self-heal completed", "Reloaded and rewrote split settings.")
        ShowNotify("Settings Self-Heal", "Repair completed")
    } finally {
        if IsObject(progress)
            SettingsProgressClose(progress)
    }
}

EnsureMainSettingsFile(force := false) {
    global SETTINGS_DIR, SETTINGS_FILE, CONFIG_VERSION
    if !force && FileExist(SETTINGS_FILE) {
        RepairDuplicateIniSectionsMerge(SETTINGS_FILE)
        return false
    }
    if !DirExist(SETTINGS_DIR)
        DirCreate(SETTINGS_DIR)
    try {
        ; Create only a skeleton here. Saving full GUI state before loading can
        ; accidentally bake startup defaults over saved GUI positions.
        IniWrite(CONFIG_VERSION, SETTINGS_FILE, "Settings", "ConfigVersion")
        try SettingsSyncIniWatcher()
        if FileExist(SETTINGS_FILE) {
            SettingsDiagPush("OK", "Rebuilt main settings file", SETTINGS_FILE)
            DebugLog("Rebuilt missing main settings file: " SETTINGS_FILE)
            return true
        }
    } catch as err {
        SettingsDiagPush("ERR", "Main settings rebuild failed", err.Message)
    }
    return false
}

EnsureSplitSettingsFiles() {
    global SETTINGS_DIR, SETTINGS_FILE, PIE_SETTINGS_FILE, HOTKEY_SETTINGS_FILE, LINK_SETTINGS_FILE, COLOR_SETTINGS_FILE
    if !DirExist(SETTINGS_DIR)
        try DirCreate(SETTINGS_DIR)
    rebuilt := []
    if !FileExist(SETTINGS_FILE) {
        if EnsureMainSettingsFile(true)
            rebuilt.Push("main")
    }
    if !FileExist(PIE_SETTINGS_FILE) {
        try {
            SavePieItems()
            if FileExist(PIE_SETTINGS_FILE)
                rebuilt.Push("pie")
        } catch as err {
            SettingsDiagPush("ERR", "Pie settings rebuild failed", err.Message)
        }
    }
    if !FileExist(HOTKEY_SETTINGS_FILE) {
        try {
            HK_Save()
            if FileExist(HOTKEY_SETTINGS_FILE)
                rebuilt.Push("hotkey")
        } catch as err {
            SettingsDiagPush("ERR", "Hotkey settings rebuild failed", err.Message)
        }
    }
    if !FileExist(LINK_SETTINGS_FILE) {
        try {
            SaveLinkItems()
            if FileExist(LINK_SETTINGS_FILE)
                rebuilt.Push("link")
        } catch as err {
            SettingsDiagPush("ERR", "Link settings rebuild failed", err.Message)
        }
    }
    if !FileExist(COLOR_SETTINGS_FILE) {
        try {
            LoadColorItems()
            SaveColorItems()
            if FileExist(COLOR_SETTINGS_FILE)
                rebuilt.Push("color")
        } catch as err {
            SettingsDiagPush("ERR", "Color settings rebuild failed", err.Message)
        }
    }
    if rebuilt.Length {
        msg := JoinTextList(rebuilt, ", ")
        SettingsDiagPush("OK", "Rebuilt missing split settings", msg)
        DebugLog("Rebuilt missing split settings: " msg)
        try SettingsSyncIniWatcher()
    }
    return rebuilt.Length
}

RepairDuplicateIniSectionsMerge(path) {
    if !FileExist(path)
        return false
    try txt := FileRead(path)
    catch
        return false

    sectionOrder := []
    sections := Map()
    current := ""
    changed := false

    for line in StrSplit(txt, "`n", "`r") {
        clean := Trim(line)
        if RegExMatch(clean, "^\[(.+)\]$", &m) {
            current := Trim(m[1])
            low := StrLower(current)
            if sections.Has(low) {
                changed := true
            } else {
                sections[low] := Map("name", current, "keys", Map(), "order", [])
                sectionOrder.Push(low)
            }
            continue
        }
        if current = "" || clean = "" || SubStr(clean, 1, 1) = ";"
            continue
        pos := InStr(line, "=")
        if !pos
            continue
        key := Trim(SubStr(line, 1, pos - 1))
        val := SubStr(line, pos + 1)
        low := StrLower(current)
        sec := sections[low]
        keys := sec["keys"]
        order := sec["order"]
        if !keys.Has(key)
            order.Push(key)
        keys[key] := val
    }

    if !changed
        return false

    out := ""
    for _, low in sectionOrder {
        sec := sections[low]
        out .= "[" sec["name"] "]`r`n"
        keys := sec["keys"]
        for _, key in sec["order"]
            out .= key "=" keys[key] "`r`n"
        out .= "`r`n"
    }
    try {
        AtomicFileWrite(path, RTrim(out, "`r`n") "`r`n")
        DebugLog("Repaired duplicate INI sections: " path)
        SettingsDiagPush("OK", "Repaired duplicate INI sections", path)
        return true
    } catch as err {
        SettingsDiagPush("ERR", "Duplicate INI repair failed", err.Message)
    }
    return false
}

LoadGUIPositions() {
    global SETTINGS_FILE
    global CapslockEnabled, TabCombosEnabled, _TypingState, SafeModeActive
    global MainGUI_X, MainGUI_Y
    global IB_X, IB_Y
    global InbetweenMode, InbetweenData, InbetweenIndex
    global ColorGUI_X, ColorGUI_Y, ColorLayout
    global LinkGUI_X, LinkGUI_Y, LinkLayout
    global LT_X, LT_Y, LT_Color
    global Scale, PieScale, Speed
    global IB_Opacity, Color_Opacity, Link_Opacity
    global AutoSaveInterval, _useUltimateSaveAs
    global _ccOffsetX, _ccOffsetY, _ccTickMs, _ccFollowCursor, _ccX, _ccY, _ccMiddlePickEnabled, _ccClipboardFormat
    global _debugSaveOnExit
    global ReqAnimationEnabled, ReqNastarEnabled, _settingsNeedUpgrade
    global NotifyEnabled, NotifyMonitor, NotifyPosition
    global HOLD_THRESHOLD_MS, _tabBlockPassthrough, _timerAskFileName, _selectCelMode, _capsBlockOutput, _FiredOSD
    global CONTRAST_THRESHOLD
    global _ShowAdvancedModes
    global _HoverState

    EnsureMainSettingsFile()
    if !FileExist(SETTINGS_FILE) {
        SettingsDiagPush("WARN", "GUI settings load skipped", "Main settings file missing; using in-memory defaults.")
        return
    }

    fallbackCount := 0
    ; Per-section try blocks so a corrupt [IB] section doesn't prevent
    ; [Color], [Settings], [ColorInfo], etc. from loading.
    try {
        IB_X       := IniReadIntSafe(SETTINGS_FILE, "IB",    "X",      IB_X)
        IB_Y       := IniReadIntSafe(SETTINGS_FILE, "IB",    "Y",      IB_Y)
        LoadIBSettingsFromIni()
    } catch as err {
        DebugLog("LoadGUIPositions [IB] error: " err.Message)
        SettingsDiagPush("ERR", "LoadGUIPositions [IB] failed", err.Message)
    }
    try {
        ColorGUI_X := IniReadIntSafe(SETTINGS_FILE, "Color", "X",      ColorGUI_X)
        ColorGUI_Y := IniReadIntSafe(SETTINGS_FILE, "Color", "Y",      ColorGUI_Y)
        ColorLayout:= IniRead(SETTINGS_FILE, "Color", "Layout", ColorLayout)
    } catch as err {
        DebugLog("LoadGUIPositions [Color] error: " err.Message)
        SettingsDiagPush("ERR", "LoadGUIPositions [Color] failed", err.Message)
    }
    try {
        LinkGUI_X  := IniReadIntSafe(SETTINGS_FILE, "Link",  "X",      LinkGUI_X)
        LinkGUI_Y  := IniReadIntSafe(SETTINGS_FILE, "Link",  "Y",      LinkGUI_Y)
        LinkLayout := IniRead(SETTINGS_FILE, "Link", "Layout", LinkLayout)
    } catch as err {
        DebugLog("LoadGUIPositions [Link] error: " err.Message)
        SettingsDiagPush("ERR", "LoadGUIPositions [Link] failed", err.Message)
    }
    try {
        mainXSaved := IniRead(SETTINGS_FILE, "Main", "X", "")
        mainYSaved := IniRead(SETTINGS_FILE, "Main", "Y", "")
        if mainXSaved != "" || mainYSaved != "" {
            MainGUI_X := IniReadIntSafe(SETTINGS_FILE, "Main", "X", MainGUI_X)
            MainGUI_Y := IniReadIntSafe(SETTINGS_FILE, "Main", "Y", MainGUI_Y)
        } else {
            MainGUI_X := LinkGUI_X
            MainGUI_Y := Max(0, LinkGUI_Y - 260)
        }
    } catch as err {
        DebugLog("LoadGUIPositions [Main] error: " err.Message)
        SettingsDiagPush("ERR", "LoadGUIPositions [Main] failed", err.Message)
    }
    try {
        LT_X       := IniReadIntSafe(SETTINGS_FILE, "LT",    "X",      LT_X)
        LT_Y       := IniReadIntSafe(SETTINGS_FILE, "LT",    "Y",      LT_Y)
        LT_Color   := NormalizeLTColor(IniRead(SETTINGS_FILE, "LT", "Color", LT_Color))
    } catch as err {
        DebugLog("LoadGUIPositions [LT] error: " err.Message)
        SettingsDiagPush("ERR", "LoadGUIPositions [LT] failed", err.Message)
    }
    try {
        Scale      := IniReadFloatSafe(SETTINGS_FILE, "Settings", "Scale", Scale, 0.5, 1.5)
        PieScale   := IniReadFloatSafe(SETTINGS_FILE, "Settings", "PieScale", PieScale, 0.5, 1.5)
        Speed      := IniReadIntSafe(SETTINGS_FILE, "Settings", "Speed", Speed, 1, 100)
        IB_Opacity   := IniReadIntSafe(SETTINGS_FILE, "Settings", "IB_Opacity", IB_Opacity, 0, 255)
        Color_Opacity := IniReadIntSafe(SETTINGS_FILE, "Settings", "Color_Opacity", Color_Opacity, 0, 255)
        Link_Opacity  := IniReadIntSafe(SETTINGS_FILE, "Settings", "Link_Opacity", Link_Opacity, 0, 255)
        AutoSaveInterval := IniReadIntSafe(SETTINGS_FILE, "Settings", "AutoSaveInterval", 60, 10, 3600)
        _useUltimateSaveAs := !!IniReadIntSafe(SETTINGS_FILE, "Settings", "UseUltimateSaveAs", 1, 0, 1)
        CapslockEnabled := !!IniReadIntSafe(SETTINGS_FILE, "Settings", "CapslockEnabled", CapslockEnabled ? 1 : 0, 0, 1)
        TabCombosEnabled := !!IniReadIntSafe(SETTINGS_FILE, "Settings", "TabCombosEnabled", TabCombosEnabled ? 1 : 0, 0, 1)
        HOLD_THRESHOLD_MS := IniReadIntSafe(SETTINGS_FILE, "Settings", "HoldThresholdMs", HOLD_THRESHOLD_MS, 20, 500)
        CONTRAST_THRESHOLD := IniReadIntSafe(SETTINGS_FILE, "Settings", "ContrastThreshold", CONTRAST_THRESHOLD, 0, 255)
        _tabBlockPassthrough := !!IniReadIntSafe(SETTINGS_FILE, "Settings", "TabBlockPassthrough", 0, 0, 1)
        _capsBlockOutput := !!IniReadIntSafe(SETTINGS_FILE, "Settings", "CapsBlockOutput", 0, 0, 1)
        _timerAskFileName := IniReadIntSafe(SETTINGS_FILE, "Settings", "TimerAskFile", 1, 0, 1)
        _debugSaveOnExit := IniReadIntSafe(SETTINGS_FILE, "Settings", "DebugSaveOnExit", 0, 0, 1)
        _HoverState["enabled"] := !!IniReadIntSafe(SETTINGS_FILE, "Settings", "TooltipEnabled", 1, 0, 1)
        _HoverState["delay"] := IniReadIntSafe(SETTINGS_FILE, "Settings", "TooltipDelay", 500, 0, 2000)
        val := IniRead(SETTINGS_FILE, "Settings", "ReqAnimation", "")
        if val = "" {
            ReqAnimationEnabled := 0
            _settingsNeedUpgrade := true
            fallbackCount++
        } else
            try ReqAnimationEnabled := Integer(val)
            catch {
                ReqAnimationEnabled := 0
                _settingsNeedUpgrade := true
                fallbackCount++
            }
        val := IniRead(SETTINGS_FILE, "Settings", "ReqNastar", "")
        if val = "" {
            ReqNastarEnabled := 0
            _settingsNeedUpgrade := true
            fallbackCount++
        } else
            try ReqNastarEnabled := Integer(val)
            catch {
                ReqNastarEnabled := 0
                _settingsNeedUpgrade := true
                fallbackCount++
            }
        NotifyEnabled := IniReadIntSafe(SETTINGS_FILE, "Settings", "NotifyEnabled", 1, 0, 1)
        NotifyMonitor := IniReadIntSafe(SETTINGS_FILE, "Settings", "NotifyMonitor", 0)
        NotifyPosition := IniRead(SETTINGS_FILE, "Settings", "NotifyPosition", "TC")
        _selectCelMode := IniReadIntSafe(SETTINGS_FILE, "Settings", "SelectCelMode", 1, 1, 2)
        _FiredOSD := IniReadIntSafe(SETTINGS_FILE, "Settings", "FiredOSD", 0, 0, 1)
        _ShowAdvancedModes := !!IniReadIntSafe(SETTINGS_FILE, "Settings", "ShowAdvancedModes", 0, 0, 1)
    } catch as err {
        DebugLog("LoadGUIPositions [Settings] error: " err.Message)
        SettingsDiagPush("ERR", "LoadGUIPositions [Settings] failed", err.Message)
    }
    try {
        _ccOffsetX := IniReadIntSafe(SETTINGS_FILE, "ColorInfo", "OffsetX", -20)
        _ccOffsetY := IniReadIntSafe(SETTINGS_FILE, "ColorInfo", "OffsetY", 50)
        _ccTickMs := IniReadIntSafe(SETTINGS_FILE, "ColorInfo", "TickMs", 60, 15, 1000)
        _ccFollowCursor := !!IniReadIntSafe(SETTINGS_FILE, "ColorInfo", "FollowCursor", 1, 0, 1)
        _ccMiddlePickEnabled := !!IniReadIntSafe(SETTINGS_FILE, "ColorInfo", "MiddlePick", 0, 0, 1)
        _ccClipboardFormat := StrUpper(Trim(IniRead(SETTINGS_FILE, "ColorInfo", "ClipboardFormat", "RGB")))
        if _ccClipboardFormat != "HEX"
            _ccClipboardFormat := "RGB"
        _ccX := IniReadIntSafe(SETTINGS_FILE, "ColorInfo", "X", _ccX)
        _ccY := IniReadIntSafe(SETTINGS_FILE, "ColorInfo", "Y", _ccY)
    } catch as err {
        DebugLog("LoadGUIPositions [ColorInfo] error: " err.Message)
        SettingsDiagPush("ERR", "LoadGUIPositions [ColorInfo] failed", err.Message)
    }
    _CleanupStaleIniKeys()
    SettingsDiagPush(fallbackCount ? "WARN" : "OK", "Loaded GUI/runtime settings", SETTINGS_FILE " | fallback/default fields: " fallbackCount)
}

_LoadIBThemeFromIni() {
    global _IBTheme, _IBColors, SETTINGS_FILE
    try {
        _IBTheme := IniRead(SETTINGS_FILE, "Settings", "IBTheme", "Default")
        if !_IBTheme
            _IBTheme := "Default"
        presets := IBThemePresets()
        if _IBTheme = "Custom" {
            for key in ["25","33","40","60","66","75","empty","25_se","33_se","40_se","60_se","66_se","75_se","empty_se","25_es","33_es","40_es","60_es","66_es","75_es","empty_es","s2e","e2s"] {
                val := IniRead(SETTINGS_FILE, "IBColors", key, _IBColors.Get(key, "555555"))
                _IBColors[key] := NormalizeHexColorText(val, _IBColors.Get(key, "555555"))
            }
        } else {
            base := presets.Get(_IBTheme, presets["Default"])
            for key, val in base
                _IBColors[key] := NormalizeHexColorText(val, _IBColors.Get(key, "555555"))
        }
    } catch as err {
        DebugLog("_LoadIBThemeFromIni error: " err.Message)
        SettingsDiagPush("ERR", "IB theme load failed", err.Message)
    }
}

_CleanupStaleIniKeys() {
    global SETTINGS_FILE
    staleKeys := [["Settings","CapslockHoldMs"],["Settings","TabHoldMs"]]
    for k in ["2","3","4","5","6","7","8","9","10"]  ; stale numeric-only IB color keys
        staleKeys.Push(["IBColors", k])
    for pair in staleKeys {
        sec := pair[1], key := pair[2]
        try {
            if IniRead(SETTINGS_FILE, sec, key, "") != ""
                IniDelete(SETTINGS_FILE, sec, key)
        }
    }
}

_iniWatcherLastTime := ""
_savedGUIConfig := ""
SettingsFilesSignature() {
    global SETTINGS_FILE, HOTKEY_SETTINGS_FILE, PIE_SETTINGS_FILE, LINK_SETTINGS_FILE, COLOR_SETTINGS_FILE, FEATURE_SETTINGS_FILE
    cur := ""
    for fn in [SETTINGS_FILE, HOTKEY_SETTINGS_FILE, PIE_SETTINGS_FILE, LINK_SETTINGS_FILE, COLOR_SETTINGS_FILE, FEATURE_SETTINGS_FILE]
        cur .= fn ":" (FileExist(fn) ? FileGetTime(fn) : "missing") "|"
    return cur
}

SettingsSyncIniWatcher() {
    global _iniWatcherLastTime
    _iniWatcherLastTime := SettingsFilesSignature()
}

CheckIniChanges() {
    global SETTINGS_FILE, HOTKEY_SETTINGS_FILE, PIE_SETTINGS_FILE, LINK_SETTINGS_FILE, COLOR_SETTINGS_FILE, FEATURE_SETTINGS_FILE, _iniWatcherLastTime
    EnsureMainSettingsFile()
    cur := SettingsFilesSignature()
    if _iniWatcherLastTime = ""
        _iniWatcherLastTime := cur
    else if cur != _iniWatcherLastTime {
        _iniWatcherLastTime := cur
        DebugLog("Settings files changed externally — reloading")
        SettingsDiagPush("INFO", "External settings change detected", "Reloading split settings.")
        LoadGUIPositions()
        _LoadIBThemeFromIni()
        LoadConfigurablePaths()
        if IsObject(IB_GUI)
            RefreshIBRequirementState()
        LoadColorItems()
        LoadLinkItems()
        LoadPieItems()
        HK_Load()
        LoadFeatureSwitches()
        FeatureApplyAll()
        SettingsSyncIniWatcher()
        SettingsDiagPush("OK", "External settings reload complete")
    }
}

LoadIBSettingsFromIni() {
    global SETTINGS_FILE, InbetweenMode, InbetweenData, InbetweenIndex, IBShortcutsEnabled
    if !FileExist(SETTINGS_FILE)
        return
    try InbetweenMode := NormalizeInbetweenMode(IniRead(SETTINGS_FILE, "IB", "Mode", InbetweenMode))
    catch
        InbetweenMode := "off"
    InbetweenData := BuildInbetweenData(InbetweenMode)
    try InbetweenIndex := Integer(IniRead(SETTINGS_FILE, "IB", "Index", InbetweenIndex))
    catch
        InbetweenIndex := 1
    if InbetweenIndex < 1
        InbetweenIndex := 1
    else if InbetweenIndex > InbetweenData.Count
        InbetweenIndex := InbetweenData.Count
    try IBShortcutsEnabled := IniRead(SETTINGS_FILE, "IB", "ShortcutsEnabled", 1) = "1"
    catch
        IBShortcutsEnabled := true
    SettingsDiagPush("INFO", "Loaded IB settings", "Mode=" InbetweenMode ", Index=" InbetweenIndex ", Shortcuts=" (IBShortcutsEnabled ? "On" : "Off"))
}

SaveGUIPositions() {
    global SETTINGS_FILE
    global IB_GUI, ColorGUI, LinkGUI, MainGUI
    global _ccGUI
    global IB_X, IB_Y, ColorGUI_X, ColorGUI_Y, LinkGUI_X, LinkGUI_Y, MainGUI_X, MainGUI_Y
    global InbetweenMode, InbetweenIndex
    global ColorLayout, LinkLayout
    global Scale, PieScale, Speed
    global AutoSaveInterval, _useUltimateSaveAs
    global _ccOffsetX, _ccOffsetY, _ccTickMs, _ccFollowCursor, _ccX, _ccY, _ccMiddlePickEnabled, _ccClipboardFormat
    global _timerAskFileName
    global _debugSaveOnExit
    global ReqAnimationEnabled, ReqNastarEnabled
    global NotifyEnabled, NotifyMonitor, NotifyPosition
    global HOLD_THRESHOLD_MS, _tabBlockPassthrough, LT_Color, LT_X, LT_Y, IB_Opacity, Color_Opacity, Link_Opacity, _capsBlockOutput
    global CapslockEnabled, TabCombosEnabled, _TypingState, SafeModeActive
    global _HoverState
    global _savedGUIConfig
    global _selectCelMode, _IBTheme, _IBColors

    if IsObject(IB_GUI) {
        try {
            IB_GUI.GetPos(&_nx, &_ny)
            DebugLog("IB pos: was (" IB_X "," IB_Y "), now (" _nx "," _ny ")")
            IB_X := _nx, IB_Y := _ny
        }
    }
    if IsObject(ColorGUI) {
        try {
            ColorGUI.GetPos(&_nx, &_ny)
            DebugLog("Color pos: was (" ColorGUI_X "," ColorGUI_Y "), now (" _nx "," _ny ")")
            ColorGUI_X := _nx, ColorGUI_Y := _ny
        }
    }
    if IsObject(LinkGUI) {
        try {
            LinkGUI.GetPos(&_nx, &_ny)
            DebugLog("Link pos: was (" LinkGUI_X "," LinkGUI_Y "), now (" _nx "," _ny ")")
            LinkGUI_X := _nx, LinkGUI_Y := _ny
        }
    }
    if IsGuiVisibleSafe(MainGUI) {
        try {
            MainGUI.GetPos(&_nx, &_ny)
            MainGUI_X := _nx, MainGUI_Y := _ny
        }
    }
    if !_ccFollowCursor && IsObject(_ccGUI) {
        try {
            _ccGUI.GetPos(&_nx, &_ny)
            _ccX := _nx, _ccY := _ny
        }
    }
    persistCapslockEnabled := CapslockEnabled ? 1 : 0
    persistTabCombosEnabled := TabCombosEnabled ? 1 : 0
    if _TypingState["caps"] || SafeModeActive
        persistCapslockEnabled := IniReadIntSafe(SETTINGS_FILE, "Settings", "CapslockEnabled", _TypingState["caps"] ? 1 : 0, 0, 1)
    if _TypingState["tab"] || SafeModeActive
        persistTabCombosEnabled := IniReadIntSafe(SETTINGS_FILE, "Settings", "TabCombosEnabled", _TypingState["tab"] ? 1 : 0, 0, 1)

    cur := MainGUI_X "|" MainGUI_Y
        . "|" IB_X "|" IB_Y "|" InbetweenMode "|" InbetweenIndex
        . "|" ColorGUI_X "|" ColorGUI_Y "|" ColorLayout
        . "|" LinkGUI_X "|" LinkGUI_Y "|" LinkLayout
        . "|" LT_X "|" LT_Y "|" LT_Color "|" Scale "|" PieScale "|" Speed
        . "|" IB_Opacity "|" Color_Opacity "|" Link_Opacity
        . "|" persistCapslockEnabled "|" persistTabCombosEnabled
        . "|" (_HoverState["enabled"] ? 1 : 0) "|" _HoverState["delay"]
        . "|" AutoSaveInterval "|" (_useUltimateSaveAs ? 1 : 0) "|" HOLD_THRESHOLD_MS "|" (_tabBlockPassthrough ? 1 : 0) "|" (_capsBlockOutput ? 1 : 0) "|" _timerAskFileName "|" _debugSaveOnExit
        . "|" ReqAnimationEnabled "|" ReqNastarEnabled
        . "|" NotifyEnabled "|" NotifyMonitor "|" NotifyPosition
        . "|" _ccOffsetX "|" _ccOffsetY "|" _ccTickMs "|" (_ccFollowCursor ? 1 : 0) "|" (_ccMiddlePickEnabled ? 1 : 0) "|" _ccClipboardFormat "|" _ccX "|" _ccY
        . "|" _selectCelMode "|" _IBTheme
    for key, val in _IBColors
        cur .= "|" key "=" NormalizeHexColorText(val, "555555")
    if FileExist(SETTINGS_FILE) && cur = _savedGUIConfig
        return
    _savedGUIConfig := cur

    try {
        if IsObject(IB_GUI) {
            IniWrite(IB_X, SETTINGS_FILE, "IB", "X")
            IniWrite(IB_Y, SETTINGS_FILE, "IB", "Y")
        }
        IniWrite(MainGUI_X, SETTINGS_FILE, "Main", "X")
        IniWrite(MainGUI_Y, SETTINGS_FILE, "Main", "Y")
        IniWrite(InbetweenMode, SETTINGS_FILE, "IB", "Mode")
        IniWrite(InbetweenIndex, SETTINGS_FILE, "IB", "Index")
        if IsObject(ColorGUI) {
            IniWrite(ColorGUI_X, SETTINGS_FILE, "Color", "X")
            IniWrite(ColorGUI_Y, SETTINGS_FILE, "Color", "Y")
        }
        IniWrite(ColorLayout, SETTINGS_FILE, "Color", "Layout")
        if IsObject(LinkGUI) {
            IniWrite(LinkGUI_X, SETTINGS_FILE, "Link", "X")
            IniWrite(LinkGUI_Y, SETTINGS_FILE, "Link", "Y")
        }
        IniWrite(LinkLayout, SETTINGS_FILE, "Link", "Layout")
        IniWrite(LT_X, SETTINGS_FILE, "LT", "X")
        IniWrite(LT_Y, SETTINGS_FILE, "LT", "Y")
        IniWrite(LT_Color, SETTINGS_FILE, "LT", "Color")
        IniWrite(Scale, SETTINGS_FILE, "Settings", "Scale")
        IniWrite(PieScale, SETTINGS_FILE, "Settings", "PieScale")
        IniWrite(Speed, SETTINGS_FILE, "Settings", "Speed")
        IniWrite(IB_Opacity, SETTINGS_FILE, "Settings", "IB_Opacity")
        IniWrite(Color_Opacity, SETTINGS_FILE, "Settings", "Color_Opacity")
        IniWrite(Link_Opacity, SETTINGS_FILE, "Settings", "Link_Opacity")
        IniWrite(persistCapslockEnabled, SETTINGS_FILE, "Settings", "CapslockEnabled")
        IniWrite(persistTabCombosEnabled, SETTINGS_FILE, "Settings", "TabCombosEnabled")
        IniWrite(_HoverState["enabled"] ? 1 : 0, SETTINGS_FILE, "Settings", "TooltipEnabled")
        IniWrite(_HoverState["delay"], SETTINGS_FILE, "Settings", "TooltipDelay")
        IniWrite(AutoSaveInterval, SETTINGS_FILE, "Settings", "AutoSaveInterval")
        IniWrite(_useUltimateSaveAs ? 1 : 0, SETTINGS_FILE, "Settings", "UseUltimateSaveAs")
        IniWrite(HOLD_THRESHOLD_MS, SETTINGS_FILE, "Settings", "HoldThresholdMs")
        IniWrite(CONTRAST_THRESHOLD, SETTINGS_FILE, "Settings", "ContrastThreshold")
        IniWrite(_tabBlockPassthrough ? 1 : 0, SETTINGS_FILE, "Settings", "TabBlockPassthrough")
        IniWrite(_capsBlockOutput ? 1 : 0, SETTINGS_FILE, "Settings", "CapsBlockOutput")
        IniWrite(ReqAnimationEnabled, SETTINGS_FILE, "Settings", "ReqAnimation")
        IniWrite(ReqNastarEnabled, SETTINGS_FILE, "Settings", "ReqNastar")
        IniWrite(_timerAskFileName, SETTINGS_FILE, "Settings", "TimerAskFile")
        IniWrite(_debugSaveOnExit, SETTINGS_FILE, "Settings", "DebugSaveOnExit")
        IniWrite(NotifyEnabled, SETTINGS_FILE, "Settings", "NotifyEnabled")
        IniWrite(NotifyMonitor, SETTINGS_FILE, "Settings", "NotifyMonitor")
        IniWrite(NotifyPosition, SETTINGS_FILE, "Settings", "NotifyPosition")
        IniWrite(_ccOffsetX, SETTINGS_FILE, "ColorInfo", "OffsetX")
        IniWrite(_ccOffsetY, SETTINGS_FILE, "ColorInfo", "OffsetY")
        IniWrite(_ccTickMs, SETTINGS_FILE, "ColorInfo", "TickMs")
        IniWrite(_ccFollowCursor ? 1 : 0, SETTINGS_FILE, "ColorInfo", "FollowCursor")
        IniWrite(_ccMiddlePickEnabled ? 1 : 0, SETTINGS_FILE, "ColorInfo", "MiddlePick")
        IniWrite(_ccClipboardFormat, SETTINGS_FILE, "ColorInfo", "ClipboardFormat")
        IniWrite(_ccX, SETTINGS_FILE, "ColorInfo", "X")
        IniWrite(_ccY, SETTINGS_FILE, "ColorInfo", "Y")
        IniWrite(_selectCelMode, SETTINGS_FILE, "Settings", "SelectCelMode")
        IniWrite(_IBTheme, SETTINGS_FILE, "Settings", "IBTheme")
        for key, val in _IBColors {
            val := NormalizeHexColorText(val, "555555")
            _IBColors[key] := val
            IniWrite(val, SETTINGS_FILE, "IBColors", key)
        }
        SettingsSyncIniWatcher()
    }
}

LoadConfigurablePaths() {
    global SETTINGS_FILE
    global PickerPath, FishbonePath, ResizerPath, SheetsURL, DriveURL
    global LT_ClickX, LT_ClickY, ColorClick1X, ColorClick1Y, ColorClick2X, ColorClick2Y
    global _timerAskFileName
    EnsureMainSettingsFile()
    if !FileExist(SETTINGS_FILE) {
        SettingsDiagPush("WARN", "Configurable paths load skipped", "Main settings file missing; using defaults.")
        return
    }
    try {
        PickerPath   := IniRead(SETTINGS_FILE, "Paths", "ColorPicker", PickerPath)
        FishbonePath := IniRead(SETTINGS_FILE, "Paths", "Fishbone",    FishbonePath)
        ResizerPath  := IniRead(SETTINGS_FILE, "Paths", "BatchResizer",ResizerPath)
        SheetsURL    := IniRead(SETTINGS_FILE, "Paths", "Sheets",      SheetsURL)
        DriveURL     := IniRead(SETTINGS_FILE, "Paths", "Drive",       DriveURL)
        LT_ClickX    := IniReadIntSafe(SETTINGS_FILE, "Coords","LT_ClickX",   LT_ClickX)
        LT_ClickY    := IniReadIntSafe(SETTINGS_FILE, "Coords","LT_ClickY",   LT_ClickY)
        ColorClick1X := IniReadIntSafe(SETTINGS_FILE, "Coords","Color1X",     ColorClick1X)
        ColorClick1Y := IniReadIntSafe(SETTINGS_FILE, "Coords","Color1Y",     ColorClick1Y)
        ColorClick2X := IniReadIntSafe(SETTINGS_FILE, "Coords","Color2X",     ColorClick2X)
        ColorClick2Y := IniReadIntSafe(SETTINGS_FILE, "Coords","Color2Y",     ColorClick2Y)
    } catch as err {
        DebugLog("LoadConfigurablePaths error: " err.Message)
        SettingsDiagPush("ERR", "Configurable paths load failed", err.Message)
    }
    SettingsDiagPush("OK", "Loaded configurable paths/coords", SETTINGS_FILE)
}

SaveConfigurablePaths() {
    global SETTINGS_FILE
    global PickerPath, FishbonePath, ResizerPath, SheetsURL, DriveURL
    global LT_ClickX, LT_ClickY, ColorClick1X, ColorClick1Y, ColorClick2X, ColorClick2Y
    IniWrite(PickerPath,   SETTINGS_FILE, "Paths",  "ColorPicker")
    IniWrite(FishbonePath, SETTINGS_FILE, "Paths",  "Fishbone")
    IniWrite(ResizerPath,  SETTINGS_FILE, "Paths",  "BatchResizer")
    IniWrite(SheetsURL,    SETTINGS_FILE, "Paths",  "Sheets")
    IniWrite(DriveURL,     SETTINGS_FILE, "Paths",  "Drive")
    IniWrite(LT_ClickX,    SETTINGS_FILE, "Coords", "LT_ClickX")
    IniWrite(LT_ClickY,    SETTINGS_FILE, "Coords", "LT_ClickY")
    IniWrite(ColorClick1X, SETTINGS_FILE, "Coords", "Color1X")
    IniWrite(ColorClick1Y, SETTINGS_FILE, "Coords", "Color1Y")
    IniWrite(ColorClick2X, SETTINGS_FILE, "Coords", "Color2X")
    IniWrite(ColorClick2Y, SETTINGS_FILE, "Coords", "Color2Y")
    try SettingsSyncIniWatcher()
}

LinkItemsDefaults() {
    global LinkItems, PickerPath, FishbonePath, ResizerPath, SheetsURL, DriveURL
    LinkItems := []
    _LI(t, i, l, h, c, n, a*) {
        m := Map("type",t,"icon",i,"label",l,"hover",h,"color",c,"note",n)
        loop a.Length // 2
            m[a[A_Index * 2 - 1]] := a[A_Index * 2]
        return m
    }
    LinkItems.Push(_LI("sep","","Main","","",""))
    LinkItems.Push(_LI("system","◈","Main Ctl","Toggle Main Control`n(Alt+F1)","455A64","open main gui window","fn","ToggleMainWindow","system",true))
    LinkItems.Push(_LI("sep","","Guide","","",""))
    LinkItems.Push(_LI("system","G","Guide","Toolkit Guide`n(Guide)","9C27B0","open guide use","fn","ShowCSPGuide","system",true))
    LinkItems[2]["icon"] := "◆"
    LinkItems[2]["iconSize"] := 11
    LinkItems[4]["iconSize"] := 11
    LinkItems.Push(_LI("sep","","Action","","",""))
    LinkItems.Push(_LI("action","🕑","Worktime","Worktime Reset","32A0F5","reset worktime","keys","{Shift Down}{CTRL Down}{Alt Down}{\}{Shift Up}{CTRL Up}{Alt Up}","extra","{Enter}"))
    LinkItems.Push(_LI("action","🖼️","Canvas","Canvas Properties","DB133B","edit the canvas properties","keys","{Shift Down}{CTRL Down}{Alt Down}{;}{Shift Up}{CTRL Up}{Alt Up}"))
    LinkItems.Push(_LI("action","🎞","Timeline","Timeline Tool","B388FF","edit animation timeline","keys","{Shift Down}{Alt Down}{s}{Shift Up}{Alt Up}"))
    LinkItems.Push(_LI("action","「」","Change Canvas Size","Change Canvas Size","B59560","change canvas size","keys","{Ctrl Down}{/}{Ctrl Up}"))
    LinkItems.Push(_LI("sep","","Link","","",""))
    LinkItems.Push(_LI("url","📊","Sheets","Google Sheets","0F9D58","add/open Google Sheets link","target",""))
    LinkItems.Push(_LI("sep","","Drive","","",""))
    LinkItems.Push(_LI("url","📁","Drive","Google Drive","4285F4","add/open Google Drive link","target",""))
    LinkItems.Push(_LI("sep","","Script","","",""))
    LinkItems.Push(_LI("url","🔎","Search","Search Nastarixa Script","455A64","open Nastarixa repositories","target","https://github.com/Nastarixa?tab=repositories"))
    LinkItems.Push(_LI("sep","","---","","",""))
    LinkItems.Push(_LI("function","↕","Toggle Layout","Toggle Horizontal/Vertical","777777","Switch Link GUI between vertical and horizontal layout.","action","ToggleLinkLayout"))
    for idx, item in LinkItems {
        if item.Get("type", "") != "sep" && !item.Has("iconSize")
            item["iconSize"] := 10
    }
}

LoadLinkItems() {
    global SETTINGS_FILE, LINK_SETTINGS_FILE, LinkItems
    LinkItemsDefaults()
    ini := FileExist(LINK_SETTINGS_FILE) ? LINK_SETTINGS_FILE : SETTINGS_FILE
    if !FileExist(ini) {
        SettingsDiagPush("WARN", "Link items load skipped", "No link settings file found; using defaults.")
        return
    }
    try {
        cnt := IniRead(ini, "LinkItems", "count", 0)
        if cnt <= 0 {
            SettingsDiagPush("INFO", "Link items using defaults", ini " has no saved editable link items.")
            return
        }
        userItems := []
    loop cnt {
        i := A_Index
        t := IniRead(ini, "LinkItems", i "_type", "")
        if t = ""
            continue
        m := Map("type", t)
        for key in ["icon","icon2","iconBold","iconSize","label","hover","note","color","color2","keys","extra","target","action","_origType","enabled","toggle","keys2","extra2","target2","action2"] {
            v := IniRead(ini, "LinkItems", i "_" key, "")
            if v != "" {
                if key = "color" || key = "color2"
                    v := PieSafeColor(v)
                if key = "icon" || key = "icon2"
                    v := IconDec(v)
                if key = "enabled" && v = "0" && m.Get("type","") != "disabled" {
                    m["_origType"] := m.Get("type","shortcut")
                    m["type"] := "disabled"
                } else if key != "enabled" {
                    m[key] := StrReplace(v, "\n", "`n")
                }
            }
        }
        userItems.Push(m)
    }
    ui := 1
    for idx, item in LinkItems {
        if item.Get("system", false) || item.Get("type","") = "system"
            continue
        if ui <= userItems.Length {
            LinkItems[idx] := userItems[ui]
            ui++
        }
    }
    while ui <= userItems.Length {
        if userItems[ui].Get("type","") != "system" {
            LinkItems.Push(userItems[ui])
        }
        ui++
    }
    if LinkItemsRepairBrokenIcons()
        SaveLinkItems()
    SettingsDiagPush("OK", "Loaded link items", ini " | loaded " userItems.Length " editable item(s), total " LinkItems.Length)
    } catch as err {
        DebugLog("LoadLinkItems error: " err.Message)
        SettingsDiagPush("ERR", "Link items load failed", err.Message)
    }
}

LinkItemsRepairBrokenIcons() {
    global LinkItems
    current := LinkItems
    defaults := []
    LinkItemsDefaults()
    for _, item in LinkItems
        defaults.Push(item.Clone())
    LinkItems := current

    lookup := Map()
    for _, def in defaults {
        key := LinkItemLookupKey(def)
        if key != "" && def.Has("icon")
            lookup[key] := def
    }

    changed := false
    for _, item in LinkItems {
        icon := Trim(item.Get("icon", ""))
        key := LinkItemLookupKey(item)
        if !lookup.Has(key)
            continue
        def := lookup[key]
        defIcon := Trim(def.Get("icon", ""))
        fallbackIcons := Map("?", true, "❔", true, "⏱", true, "◆", true, "▶", true, "▤", true, "⊞", true, "◎", true)
        if !(icon = "?" || SubStr(icon, 1, 2) = "??" || (defIcon != "" && icon != defIcon && fallbackIcons.Has(icon)))
            continue
        item["icon"] := def.Get("icon", "")
        if def.Has("iconSize")
            item["iconSize"] := def.Get("iconSize", 8)
        if def.Has("iconBold")
            item["iconBold"] := def.Get("iconBold", true)
        changed := true
    }
    return changed
}

LinkItemLookupKey(item) {
    for key in ["hover", "label", "target", "keys", "fn"] {
        val := Trim(item.Get(key, ""))
        if val != ""
            return key ":" val
    }
    return ""
}

IconEnc(s) {
    if s = "" || SubStr(s, 1, 2) = "\x"
        return s
    out := ""
    Loop Parse s
        out .= "\x" Format("{:04X}", Ord(A_LoopField))
    return out
}

IconDec(s) {
    if s = "" || SubStr(s, 1, 2) != "\x"
        return IconSafe(s)
    out := ""
    p := 1, len := StrLen(s)
    while p + 5 <= len {
        if SubStr(s, p, 2) = "\x" {
            hex := SubStr(s, p + 2, 4)
            if RegExMatch(hex, "^[0-9A-Fa-f]{4}$")
                out .= Chr(Integer("0x" hex))
            p += 6
        } else {
            out .= SubStr(s, p, 1)
            p++
        }
    }
    return IconSafe(out)
}

IconSafe(val, default := "") {
    if val = "" || val = "?" || val = "??"
        return default
    if InStr(val, Chr(0xFFFD))
        return default
    return val
}

IconTestRender(icon, fontName := "Segoe UI", fontSize := 9) {
    if icon = "" || StrLen(icon) != 1
        return true
    static cache := Map()
    if cache.Has(icon)
        return cache[icon]
    hdc := DllCall("GetDC", "ptr", 0, "ptr")
    hFont := DllCall("CreateFontW", "int", -fontSize, "uint", 0, "uint", 0, "uint", 0
        , "uint", 400, "uint", 0, "uint", 0, "uint", 0, "uint", 1
        , "uint", 0, "uint", 0, "uint", 0, "uint", 0, "wstr", fontName, "ptr")
    hOld := DllCall("SelectObject", "ptr", hdc, "ptr", hFont, "ptr")
    SIZE := Buffer(8)
    ok := DllCall("GetTextExtentPoint32W", "ptr", hdc, "wstr", icon, "int", 1, "ptr", SIZE, "int")
    cx := NumGet(SIZE, 0, "int")
    DllCall("SelectObject", "ptr", hdc, "ptr", hOld)
    DllCall("DeleteObject", "ptr", hFont)
    DllCall("ReleaseDC", "ptr", 0, "ptr", hdc)
    result := ok != 0 && cx > 1
    cache[icon] := result
    return result
}

IconUse(icon, default := "") {
    if icon = ""
        return default
    safe := IconSafe(icon)
    if safe = ""
        return default
    iconRefPath := A_ScriptDir "\src\docs\IconRef.ini"
    if !FileExist(iconRefPath)
        return safe
    static _backupMap := ""
    if _backupMap = "" {
        _backupMap := Map()
        try {
            for entry in StrSplit(IniRead(iconRefPath, "Backup"), "`n") {
                if InStr(entry, "=") {
                    parts := StrSplit(entry, "=",, 2)
                    keyHex := parts[1]
                    valHex := parts[2]
                    if SubStr(keyHex, 1, 2) = "\x" && SubStr(valHex, 1, 2) = "\x" {
                        _backupMap[IconDec(keyHex)] := IconDec(valHex)
                    }
                }
            }
        }
    }
    if IsObject(_backupMap) && _backupMap.Has(safe) {
        if !IconTestRender(safe) {
            return _backupMap[safe]
        }
    }
    return safe
}

SaveLinkItems() {
    global LINK_SETTINGS_FILE, LinkItems
    IniDelete(LINK_SETTINGS_FILE, "LinkItems")
    cnt := 0
    for idx, item in LinkItems {
        if item.Get("type","") = "system"
            continue
        cnt++
        i := cnt
        linkType := item.Get("type","")
        IniWrite(linkType, LINK_SETTINGS_FILE, "LinkItems", i "_type")
        for key in ["icon","icon2","iconBold","iconSize","label","hover","note","color","color2","keys","extra","target","action","_origType","toggle","keys2","extra2","target2","action2","enabled"] {
            if item.Has(key) {
                v := item[key]
                if (key = "keys" || key = "extra" || key = "keys2" || key = "extra2" || key = "action" || key = "action2") && (linkType = "shortcut" || linkType = "action")
                    v := PieQuickNormalizeShortcutAction(v)
                if key = "keys" || key = "hover"
                    v := StrReplace(v, "`n", "\n")
                if key = "color" || key = "color2"
                    v := PieSafeColor(v)
                if key = "icon" || key = "icon2"
                    v := IconEnc(IconSafe(v))
                IniWrite(v, LINK_SETTINGS_FILE, "LinkItems", i "_" key)
            }
        }
    }
    IniWrite(cnt, LINK_SETTINGS_FILE, "LinkItems", "count")
    try SettingsSyncIniWatcher()
}

; ============================================================

