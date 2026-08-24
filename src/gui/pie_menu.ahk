; GUI - Pie Menu
; ============================================================

PieItemsDefaults() {
    global PieItems, PieConfigs, SubPieConfigs, SubPieNames, PieCount, PieHotkeys, PieNames, PieEnabled, _pieDelayMs, _pieDeadzone, _pieStyle, _pieQuickHintsVisible, _pieQuickSlotHintsPos, _pieQuickHintCount
    PieResetDefaults(false)
}

PieResetDefaults(save := true) {
    global PieItems, PieConfigs, SubPieConfigs, SubPieNames, PieCount, PieHotkeys, PieNames, PieEnabled, _pieDelayMs, _pieDeadzone, _pieStyle, _pieQuickHintsVisible, _pieQuickSlotHintsPos, _pieQuickHintCount
    PieCount := 4
    _pieDelayMs := 65
    _pieDeadzone := 42
    _pieStyle := "Normal"
    _pieQuickHintsVisible := 1
    _pieQuickSlotHintsPos := "bottom-center"
    _pieQuickHintCount := 20
    PieEnabled := [1, 1, 1, 1]
    PieHotkeys := [PieDefaultHotkey(1), PieDefaultHotkey(2), PieDefaultHotkey(3), PieDefaultHotkey(4)]
    PieNames := [PieDefaultName(1), PieDefaultName(2), PieDefaultName(3), PieDefaultName(4)]
    PieConfigs := [PieDefaultConfig(1), PieDefaultConfig(2), PieDefaultConfig(3), PieDefaultConfig(4)]
    SubPieNames := [SubPieDefaultName(1)]
    SubPieConfigs := [SubPieDefaultConfig(1)]
    PieItems := PieConfigs[1]
    if save
        SavePieItems()
}

PieEnsureEnabledDefaults() {
    global PieEnabled, PieCount
    if !IsObject(PieEnabled)
        PieEnabled := []
    Loop 4 {
        fallback := A_Index <= PieCount ? 1 : 0
        if PieEnabled.Length < A_Index
            PieEnabled.Push(fallback)
        else
            PieEnabled[A_Index] := PieSafeInt(PieEnabled[A_Index], fallback, 0, 1)
    }
}

PieIsEnabled(idx) {
    global PieEnabled, PieCount
    idx := PieSafeInt(idx, 1, 1, 4)
    PieEnsureEnabledDefaults()
    if PieEnabled.Length < idx
        return idx <= PieCount
    return !!PieSafeInt(PieEnabled[idx], idx <= PieCount ? 1 : 0, 0, 1)
}

PieEnabledCount() {
    lastEnabled := 0
    Loop 4 {
        if PieIsEnabled(A_Index)
            lastEnabled := A_Index
    }
    return Max(lastEnabled, 1)
}

PieFirstEnabledIndex() {
    Loop 4 {
        if PieIsEnabled(A_Index)
            return A_Index
    }
    return 1
}

PieDefaultName(idx) {
    return idx = 1 ? "Layer Pie" : idx = 2 ? "Create Pie" : idx = 3 ? "Utility Pie" : idx = 4 ? "Guide Pie" : "Pie " idx
}

PieDefaultHotkey(idx) {
    return idx = 1 ? "Tab" : idx = 2 ? "+Tab" : idx = 3 ? "^Tab" : idx = 4 ? "^+Tab" : ""
}

PieGuideDefaultConfig(pieIndex := 4) {
    return [
        Map("slot", 1, "label", "Guide",       "type", "submenu", "action", "", "requirement", "", "color", "9C27B0", "enabled", 1, "subPie", 1),
        Map("slot", 2, "label", "Hotkeys",     "type", "function", "action", "ShowHotkeySettings", "requirement", "", "color", "455A64", "enabled", 1),
        Map("slot", 3, "label", "Layer Up",    "type", "function", "action", "HotkeyLayerUp(1)", "requirement", REQ_NASTAR, "color", "4CAF50", "enabled", 1),
        Map("slot", 4, "label", "Layer Down",  "type", "function", "action", "HotkeyLayerDown(1)", "requirement", REQ_NASTAR, "color", "E53935", "enabled", 1),
        Map("slot", 5, "label", "Layer Above", "type", "function", "action", "HotkeyTopLayer(1)", "requirement", REQ_NASTAR, "color", "2196F3", "enabled", 1),
        Map("slot", 6, "label", "Layer Below", "type", "function", "action", "HotkeyBottomLayer(1)", "requirement", REQ_NASTAR, "color", "FB8C00", "enabled", 1),
        Map("slot", 7, "label", "Status",      "type", "function", "action", "ShowStatusDashboard", "requirement", "", "color", "1565C0", "enabled", 1),
        Map("slot", 8, "label", "System",      "type", "function", "action", "ShowLTSettings", "requirement", "", "color", "607D8B", "enabled", 1),
        Map("slot", 9, "label", "Safe Mode",   "type", "function", "action", "SafeMode", "requirement", "", "color", "B71C1C", "enabled", 1),
        Map("slot", 10, "label", "Show MainGUI", "type", "function", "action", "ShowMainGUI", "requirement", "", "color", "263238", "enabled", 1)
    ]
}

SubPieDefaultName(idx) {
    return idx = 1 ? "Guide Detail" : "Sub Pie " idx
}

SubPieDefaultConfig(idx) {
    if idx = 1 {
        return [
            Map("slot", 1, "label", "Guide",       "type", "function", "action", "ShowCSPGuide", "requirement", "", "color", "9C27B0", "enabled", 1),
            Map("slot", 2, "label", "Shortcut", "type", "function", "action", "ShowCSPRecommended", "requirement", "", "color", "1565C0", "enabled", 1),
            Map("slot", 3, "label", "First Run",   "type", "function", "action", "FirstRunWizard", "requirement", "", "color", "607D8B", "enabled", 1),
            Map("slot", 4, "label", "IB Popup",    "type", "function", "action", "GuideIBNotify", "requirement", "", "color", "2E7D32", "enabled", 1),
            Map("slot", 5, "label", "Create Popup","type", "function", "action", "GuideCreateNotify", "requirement", "", "color", "FF9800", "enabled", 1),
            Map("slot", 6, "label", "Shortcut Popup", "type", "function", "action", "GuideShortcutNotify", "requirement", "", "color", "455A64", "enabled", 1),
            Map("slot", 7, "label", "Utility Popup", "type", "function", "action", "GuideAutoActionNotify", "requirement", "", "color", "795548", "enabled", 1),
            Map("slot", 8, "label", "Animation Popup", "type", "function", "action", "GuideAnimationNotify", "requirement", "", "color", "C2185B", "enabled", 1),
            Map("slot", 9, "label", "Back",        "type", "nav", "action", "back", "requirement", "", "color", "263238", "enabled", 1),
            Map("slot", 10, "label", "Close",      "type", "nav", "action", "close", "requirement", "", "color", "B71C1C", "enabled", 1)
        ]
    }
    return PieDefaultConfig(99)
}

PieDefaultConfig(idx) {
    if idx = 1 {
        return [
            Map("slot", 1, "label", "Black",   "type", "function", "action", "HotkeyLayerBlack", "requirement", REQ_NASTAR, "color", "1E1E1E", "enabled", 1),
            Map("slot", 2, "label", "Red",     "type", "function", "action", "HotkeyLayerRed", "requirement", REQ_NASTAR, "color", "BF0000", "enabled", 1),
            Map("slot", 3, "label", "Blue",    "type", "function", "action", "HotkeyLayerBlue", "requirement", REQ_NASTAR, "color", "1565C0", "enabled", 1),
            Map("slot", 4, "label", "Green",   "type", "function", "action", "HotkeyLayerGreen", "requirement", REQ_NASTAR, "color", "2E7D32", "enabled", 1),
            Map("slot", 5, "label", "Pink",    "type", "function", "action", "HotkeyLayerPink", "requirement", REQ_NASTAR, "color", "C11C84", "enabled", 1),
            Map("slot", 6, "label", "Cyan",    "type", "function", "action", "HotkeyLayerCyan", "requirement", REQ_NASTAR, "color", "00BCD4", "enabled", 1),
            Map("slot", 7, "label", "Orange",  "type", "function", "action", "HotkeyLayerOrange", "requirement", REQ_NASTAR, "color", "FF9800", "enabled", 1),
            Map("slot", 8, "label", "Uranuri / Shadow", "type", "function", "action", "HotkeyLayerUranuri", "requirement", REQ_NASTAR, "color", "795548", "enabled", 1),
            Map("slot", 9, "label", "Paint",   "type", "function", "action", "HotkeyLayerPaint", "requirement", REQ_NASTAR, "color", "607D8B", "enabled", 1),
            Map("slot", 10, "label", "Rough",  "type", "function", "action", "HotkeyLayerRough", "requirement", REQ_NASTAR, "color", "546E7A", "enabled", 1)
        ]
    }
    if idx = 2 {
        return [
            Map("slot", 1, "label", "New Paper Layer",          "type", "function", "action", "HotkeyCreatePaperLayer(1)", "requirement", REQ_NASTAR, "color", "795548", "enabled", 1),
            Map("slot", 2, "label", "New Raster Layer",         "type", "function", "action", "HotkeyCreateRasterLayer(1)", "requirement", REQ_NASTAR, "color", "546E7A", "enabled", 1),
            Map("slot", 3, "label", "New Vector Layer",         "type", "function", "action", "HotkeyCreateVectorLayer(1)", "requirement", REQ_NASTAR, "color", "1565C0", "enabled", 1),
            Map("slot", 4, "label", "Colored Vector Layer",     "type", "function", "action", "HotkeyCreateColoredVectorLayer(1)", "requirement", REQ_NASTAR, "color", "2E7D32", "enabled", 1),
            Map("slot", 5, "label", "New Dummy Layer",          "type", "function", "action", "HotkeyCreateDummyLayer(1)", "requirement", REQ_NASTAR, "color", "3E8CEC", "enabled", 1),
            Map("slot", 6, "label", "Separate Black Line + Paint", "type", "function", "action", "HotkeySeparateBlackLine(1)", "requirement", REQ_NASTAR, "color", "3A3A3A", "enabled", 1),
            Map("slot", 7, "label", "Pink Vector Layer",        "type", "function", "action", "HotkeyCreatePinkVectorLayer(1)", "requirement", REQ_NASTAR, "color", "C11C84", "enabled", 1),
            Map("slot", 8, "label", "Cyan Vector Layer",        "type", "function", "action", "HotkeyCreateCyanVectorLayer(1)", "requirement", REQ_NASTAR, "color", "00BCD4", "enabled", 1),
            Map("slot", 9, "label", "Orange Vector Layer",      "type", "function", "action", "HotkeyCreateOrangeVectorLayer(1)", "requirement", REQ_NASTAR, "color", "FF9800", "enabled", 1),
            Map("slot", 10, "label", "New Animation Folder",    "type", "function", "action", "HotkeyCreateAnimationFolder(1)", "requirement", REQ_NASTAR, "color", "607D8B", "enabled", 1)
        ]
    }
    if idx = 3 {
        return [
            Map("slot", 1, "label", "Keyframe Color",       "type", "function", "action", "HotkeyFeatureKeyframeColor(1)", "requirement", REQ_NASTAR, "color", "E53935", "enabled", 1),
            Map("slot", 2, "label", "Reference Color",      "type", "function", "action", "HotkeyFeatureReferenceColor(1)", "requirement", REQ_NASTAR, "color", "1565C0", "enabled", 1),
            Map("slot", 3, "label", "Remove Key Color",     "type", "function", "action", "HotkeyFeatureRemoveLayerColor(1)", "requirement", REQ_NASTAR, "color", "546E7A", "enabled", 1),
            Map("slot", 4, "label", "LT Half Green",        "type", "function", "action", "HotkeyFeatureHalfGreen(1)", "requirement", REQ_NASTAR, "color", "2E7D32", "enabled", 1),
            Map("slot", 5, "label", "LT Half Purple",       "type", "function", "action", "HotkeyFeatureHalfPurple(1)", "requirement", REQ_NASTAR, "color", "8E24AA", "enabled", 1),
            Map("slot", 6, "label", "Normal Color",         "type", "function", "action", "HotkeyFeatureNormalColor(1)", "requirement", REQ_NASTAR, "color", "607D8B", "enabled", 1),
            Map("slot", 7, "label", "Paper Purple",         "type", "function", "action", "HotkeyFeaturePaperPurple(1)", "requirement", REQ_NASTAR, "color", "7E57C2", "enabled", 1),
            Map("slot", 8, "label", "Paper Green",          "type", "function", "action", "HotkeyFeaturePaperGreen(1)", "requirement", REQ_NASTAR, "color", "43A047", "enabled", 1),
            Map("slot", 9, "label", "Paper White",          "type", "function", "action", "HotkeyFeaturePaperWhite(1)", "requirement", REQ_NASTAR, "color", "6D6D6D", "enabled", 1),
            Map("slot", 10, "label", "Layer Color Black",   "type", "function", "action", "HotkeyFeatureLayerColorBlack(1)", "requirement", REQ_NASTAR, "color", "1E1E1E", "enabled", 1)
        ]
    }
    if idx = 4
        return PieGuideDefaultConfig(4)
    return [
        Map("slot", 1, "label", "Disabled", "type", "disabled", "action", "",                    "requirement", "", "color", "555555", "enabled", 0),
        Map("slot", 2, "label", "Disabled", "type", "disabled", "action", "",                    "requirement", "", "color", "555555", "enabled", 0),
        Map("slot", 3, "label", "Disabled", "type", "disabled", "action", "",                    "requirement", "", "color", "555555", "enabled", 0),
        Map("slot", 4, "label", "Disabled", "type", "disabled", "action", "",                    "requirement", "", "color", "555555", "enabled", 0),
        Map("slot", 5, "label", "Disabled", "type", "disabled", "action", "",                    "requirement", "", "color", "555555", "enabled", 0),
        Map("slot", 6, "label", "Disabled", "type", "disabled", "action", "",                    "requirement", "", "color", "555555", "enabled", 0),
        Map("slot", 7, "label", "Disabled", "type", "disabled", "action", "",                    "requirement", "", "color", "555555", "enabled", 0),
        Map("slot", 8, "label", "Disabled", "type", "disabled", "action", "",                    "requirement", "", "color", "555555", "enabled", 0),
        Map("slot", 9, "label", "Disabled", "type", "disabled", "action", "",                    "requirement", "", "color", "555555", "enabled", 0),
        Map("slot", 10, "label", "Disabled","type", "disabled", "action", "",                    "requirement", "", "color", "555555", "enabled", 0)
    ]
}

PieSafeInt(value, fallback := 0, minVal := "", maxVal := "") {
    try n := Integer(value)
    catch
        n := fallback
    if minVal != "" && n < minVal
        n := minVal
    if maxVal != "" && n > maxVal
        n := maxVal
    return n
}

PieSlotName(idx) {
    names := ["Top Right", "Top Left", "Right Top", "Left Top", "Right", "Left", "Right Bottom", "Left Bottom", "Bottom Right", "Bottom Left"]
    return idx >= 1 && idx <= names.Length ? names[idx] : "Slot " idx
}

PieSlotBadge(i, enabled := true, hasSubmenu := false) {
    if !enabled
        return IconUse("🚫", "X")
    if hasSubmenu
        return IconUse(Chr(0x2630), Chr(0x2261))
    return i = 10 ? "0" : String(i)
}

PieNormalizeStyle(style) {
    style := StrLower(Trim(style))
    if style = "left" || style = "all textbox on left"
        return "Left"
    if style = "right" || style = "all textbox on right"
        return "Right"
    return "Normal"
}

PieStyleValue(style) {
    style := PieNormalizeStyle(style)
    return style = "Left" ? 2 : style = "Right" ? 3 : 1
}

PieLayoutPositions(w, h, slotW, slotH, style := "Normal") {
    cx := w // 2, cy := h // 2
    style := PieNormalizeStyle(style)
    if style = "Left" {
        return [
            [cx + PieS(2),           cy - PieS(134)], ; Top Right
            [cx - slotW - PieS(4),   cy - PieS(134)], ; Top Left
            [cx - slotW - PieS(48),  cy - PieS(98)],  ; Right Top
            [cx - slotW - PieS(88),  cy - PieS(68)],  ; Left Top
            [cx - slotW - PieS(118), cy - PieS(38)],  ; Right
            [cx - slotW - PieS(118), cy - PieS(2)],   ; Left
            [cx - slotW - PieS(96),  cy + PieS(28)],  ; Right Bottom
            [cx - slotW - PieS(48),  cy + PieS(58)],  ; Left Bottom
            [cx - slotW - PieS(4),   cy + PieS(88)],  ; Bottom Right
            [cx + PieS(2),           cy + PieS(88)]   ; Bottom Left
        ]
    }
    if style = "Right" {
        leftPositions := PieLayoutPositions(w, h, slotW, slotH, "Left")
        rightPositions := []
        for _, pos in leftPositions {
            rightPositions.Push([w - pos[1] - slotW, pos[2]])
        }
        return rightPositions
    }
    return [
        [cx - slotW - PieS(8), PieS(48)],
        [cx + PieS(8), PieS(48)],
        [cx - slotW - PieS(88), cy - slotH - PieS(45)],
        [cx + PieS(88), cy - slotH - PieS(45)],
        [cx - slotW - PieS(102), cy - slotH // 2],
        [cx + PieS(102), cy - slotH // 2],
        [cx - slotW - PieS(88), cy + PieS(45)],
        [cx + PieS(88), cy + PieS(45)],
        [cx - slotW - PieS(8), h - slotH - PieS(48)],
        [cx + PieS(8), h - slotH - PieS(48)]
    ]
}

LoadPieItems() {
    global PieItems, PieConfigs, SubPieConfigs, SubPieNames, PieCount, PieHotkeys, PieNames, PieEnabled, SETTINGS_FILE, PIE_SETTINGS_FILE, _pieDelayMs, _pieDeadzone, _pieStyle, _pieQuickHintsVisible, _pieQuickSlotHintsPos, _pieQuickHintCount
    PieItemsDefaults()
    ini := FileExist(PIE_SETTINGS_FILE) ? PIE_SETTINGS_FILE : SETTINGS_FILE
    if !FileExist(ini) {
        SettingsDiagPush("WARN", "Pie settings load skipped", "No pie settings file found; using defaults.")
        return
    }
    try {
        PieCount := PieSafeInt(IniRead(ini, "PieMenu", "PieCount", 4), 1, 1, 4)
        _pieDelayMs := PieSafeInt(IniRead(ini, "PieMenu", "DelayMs", 65), 65, 0, 1000)
        _pieDeadzone := PieSafeInt(IniRead(ini, "PieMenu", "Deadzone", 42), 42, 0, 200)
        _pieStyle := PieNormalizeStyle(IniRead(ini, "PieMenu", "Style", "Normal"))
        _pieQuickHintsVisible := PieSafeInt(IniRead(ini, "PieMenu", "QuickHints", 1), 1, 0, 1)
        _pieQuickSlotHintsPos := IniRead(ini, "PieMenu", "SlotQuickHintsPos", "bottom-center")
        _pieQuickHintCount := PieSafeInt(IniRead(ini, "PieMenu", "QuickHintCount", 20), 20, 1, 99)
        PieConfigs := []
        PieHotkeys := []
        PieNames := []
        PieEnabled := []
        Loop 4 {
            p := A_Index
            PieEnabled.Push(PieSafeInt(IniRead(ini, "PieMenu", "Pie" p "Enabled", p <= PieCount ? 1 : 0), p <= PieCount ? 1 : 0, 0, 1))
            PieHotkeys.Push(PieNormalizeHotkey(IniRead(ini, "PieMenu", "Pie" p "Hotkey", PieDefaultHotkey(p))))
            PieNames.Push(IniRead(ini, "PieMenu", "Pie" p "Name", PieDefaultName(p)))
            config := PieDefaultConfig(p)
            Loop config.Length {
                i := A_Index
                sec := "PieMenu_" p "_" i
                item := config[i]
                item["label"] := IniRead(ini, sec, "Label", item.Get("label", PieSlotName(i)))
                item["type"] := IniRead(ini, sec, "Type", item.Get("type", "disabled"))
                item["action"] := IniRead(ini, sec, "Action", item.Get("action", ""))
                item["requirement"] := HK_NormalizeRequirement(IniRead(ini, sec, "Requirement", item.Get("requirement", "")))
                item["color"] := PieSafeColor(IniRead(ini, sec, "Color", item.Get("color", "455A64")))
                item["enabled"] := PieSafeInt(IniRead(ini, sec, "Enabled", item.Get("enabled", 1)), 1, 0, 1)
                oldSubmenu := PieSafeInt(IniRead(ini, sec, "Submenu", item.Get("submenu", 0)), 0, 0, 1)
                oldSubmenuKey := IniRead(ini, sec, "SubmenuKey", item.Get("submenuKey", ""))
                if oldSubmenu || item.Get("type", "") = "submenu" {
                    item["type"] := "submenu"
                    item["subPie"] := PieSafeInt(IniRead(ini, sec, "SubPie", oldSubmenuKey = "guide" ? 1 : item.Get("subPie", 1)), 1, 1, 99)
                    item["enabled"] := 1
                }
                config[i] := item
            }
            PieConfigs.Push(config)
        }
        PieCount := PieEnabledCount()
        LoadSubPieItems()
        PieEnsureGuideDetailNotifySlots()
        LoadPieQuickHotkeys()
        PieItems := PieConfigs[PieFirstEnabledIndex()]
    } catch as err {
        DebugLog("LoadPieItems error: " err.Message)
        SettingsDiagPush("ERR", "Pie settings load failed", err.Message)
    }
    SettingsDiagPush("OK", "Loaded pie settings", ini " | pies=" PieCount ", subpies=" SubPieConfigs.Length ", quick=" PieQuickHotkeys.Length)
    SettingsDiagPush("TRACE", "Pie names", PieNames[1] " | " PieNames[2] " | " PieNames[3] " | " PieNames[4])
    SettingsDiagPush("TRACE", "Pie enabled", PieEnabled[1] " " PieEnabled[2] " " PieEnabled[3] " " PieEnabled[4])
    SettingsDiagPush("TRACE", "Pie delay/dead/style", _pieDelayMs "/" _pieDeadzone "/" _pieStyle)
    SettingsDiagPush("TRACE", "Pie hotkeys", PieHotkeys[1] " | " PieHotkeys[2] " | " PieHotkeys[3] " | " PieHotkeys[4])
}

PieEnsureGuideDetailNotifySlots() {
    global SubPieConfigs, SubPieNames
    if SubPieConfigs.Length < 1
        return false
    guideName := SubPieNames.Length >= 1 ? SubPieNames[1] : SubPieDefaultName(1)
    if StrLower(Trim(guideName)) != "guide detail"
        return false
    defaults := SubPieDefaultConfig(1)
    changed := false
    for slot in [4, 5, 6, 7, 8] {
        if SubPieConfigs[1].Length < slot
            continue
        item := SubPieConfigs[1][slot]
        if !IsObject(item)
            continue
        t := StrLower(Trim(item.Get("type", "disabled")))
        a := Trim(item.Get("action", ""))
        if t = "disabled" || a = "" {
            SubPieConfigs[1][slot] := defaults[slot]
            changed := true
        }
    }
    if changed
        SettingsDiagPush("OK", "Guide detail sub-pie repaired", "Added guide notification popup slots")
    return changed
}

LoadSubPieItems() {
    global SETTINGS_FILE, PIE_SETTINGS_FILE, SubPieConfigs, SubPieNames
    try {
        SubPieConfigs := []
        SubPieNames := []
        ini := FileExist(PIE_SETTINGS_FILE) ? PIE_SETTINGS_FILE : SETTINGS_FILE
        count := PieSafeInt(IniRead(ini, "SubPieMenu", "Count", 1), 1, 1, 30)
        Loop count {
            s := A_Index
            SubPieNames.Push(IniRead(ini, "SubPieMenu", "Sub" s "Name", SubPieDefaultName(s)))
            config := SubPieDefaultConfig(s)
            Loop config.Length {
                i := A_Index
                sec := "SubPieMenu_" s "_" i
                item := config[i]
                item["label"] := IniRead(ini, sec, "Label", item.Get("label", PieSlotName(i)))
                item["type"] := IniRead(ini, sec, "Type", item.Get("type", "disabled"))
                item["action"] := IniRead(ini, sec, "Action", item.Get("action", ""))
                item["requirement"] := HK_NormalizeRequirement(IniRead(ini, sec, "Requirement", item.Get("requirement", "")))
                item["color"] := PieSafeColor(IniRead(ini, sec, "Color", item.Get("color", "455A64")))
                item["enabled"] := PieSafeInt(IniRead(ini, sec, "Enabled", item.Get("enabled", 1)), 1, 0, 1)
                if item.Get("type", "") = "submenu"
                    item["subPie"] := PieSafeInt(IniRead(ini, sec, "SubPie", item.Get("subPie", 1)), 1, 1, 99)
                config[i] := item
            }
            SubPieConfigs.Push(PieNormalizeConfigSlots(config, SubPieDefaultConfig(s)))
        }
        SettingsDiagPush("INFO", "Loaded sub-pie settings", count " sub-pie config(s)")
    } catch as err {
        DebugLog("LoadSubPieItems error: " err.Message)
        SettingsDiagPush("ERR", "Sub-pie settings load failed", err.Message)
    }
}

SavePieItems() {
    global PieConfigs, SubPieConfigs, SubPieNames, PieCount, PieHotkeys, PieNames, PieEnabled, PIE_SETTINGS_FILE, _pieDelayMs, _pieDeadzone, _pieStyle, _pieQuickHintsVisible, _pieQuickSlotHintsPos, _pieQuickHintCount
    try {
        PieRepairDuplicateIniSections(PIE_SETTINGS_FILE, ["PieMenu", "SubPieMenu"])
        PieEnsureEnabledDefaults()
        PieCount := PieEnabledCount()
        IniWrite(PieCount, PIE_SETTINGS_FILE, "PieMenu", "PieCount")
        IniWrite(_pieDelayMs, PIE_SETTINGS_FILE, "PieMenu", "DelayMs")
        IniWrite(_pieDeadzone, PIE_SETTINGS_FILE, "PieMenu", "Deadzone")
        IniWrite(PieNormalizeStyle(_pieStyle), PIE_SETTINGS_FILE, "PieMenu", "Style")
        IniWrite(_pieQuickHintsVisible ? 1 : 0, PIE_SETTINGS_FILE, "PieMenu", "QuickHints")
        IniWrite(_pieQuickSlotHintsPos, PIE_SETTINGS_FILE, "PieMenu", "SlotQuickHintsPos")
        IniWrite(_pieQuickHintCount, PIE_SETTINGS_FILE, "PieMenu", "QuickHintCount")
        Loop 4 {
            p := A_Index
            IniWrite(PieIsEnabled(p) ? 1 : 0, PIE_SETTINGS_FILE, "PieMenu", "Pie" p "Enabled")
            IniWrite(PieHotkeys.Length >= p ? PieNormalizeHotkey(PieHotkeys[p]) : "", PIE_SETTINGS_FILE, "PieMenu", "Pie" p "Hotkey")
            IniWrite(PieNames.Length >= p ? PieNames[p] : PieDefaultName(p), PIE_SETTINGS_FILE, "PieMenu", "Pie" p "Name")
            if PieConfigs.Length < p
                continue
            config := PieConfigs[p]
            for i, item in config {
                sec := "PieMenu_" p "_" i
                typeVal := item.Get("type", "disabled")
                actionVal := item.Get("action", "")
                if (typeVal = "shortcut" || typeVal = "action") && actionVal != ""
                    actionVal := PieQuickNormalizeShortcutAction(actionVal)
                IniWrite(item.Get("label", ""), PIE_SETTINGS_FILE, sec, "Label")
                IniWrite(typeVal, PIE_SETTINGS_FILE, sec, "Type")
                IniWrite(actionVal, PIE_SETTINGS_FILE, sec, "Action")
                IniWrite(HK_NormalizeRequirement(item.Get("requirement", "")), PIE_SETTINGS_FILE, sec, "Requirement")
                IniWrite(PieSafeColor(item.Get("color", "455A64")), PIE_SETTINGS_FILE, sec, "Color")
                IniWrite(item.Get("enabled", 1), PIE_SETTINGS_FILE, sec, "Enabled")
                if typeVal = "submenu"
                    IniWrite(item.Get("subPie", 1), PIE_SETTINGS_FILE, sec, "SubPie")
            }
        }
        IniWrite(SubPieConfigs.Length ? SubPieConfigs.Length : 1, PIE_SETTINGS_FILE, "SubPieMenu", "Count")
        Loop (SubPieConfigs.Length ? SubPieConfigs.Length : 1) {
            s := A_Index
            config := SubPieConfigs.Length >= s ? SubPieConfigs[s] : SubPieDefaultConfig(s)
            IniWrite(SubPieNames.Length >= s ? SubPieNames[s] : SubPieDefaultName(s), PIE_SETTINGS_FILE, "SubPieMenu", "Sub" s "Name")
            for i, item in config {
                sec := "SubPieMenu_" s "_" i
                typeVal := item.Get("type", "disabled")
                actionVal := item.Get("action", "")
                if (typeVal = "shortcut" || typeVal = "action") && actionVal != ""
                    actionVal := PieQuickNormalizeShortcutAction(actionVal)
                IniWrite(item.Get("label", ""), PIE_SETTINGS_FILE, sec, "Label")
                IniWrite(typeVal, PIE_SETTINGS_FILE, sec, "Type")
                IniWrite(actionVal, PIE_SETTINGS_FILE, sec, "Action")
                IniWrite(HK_NormalizeRequirement(item.Get("requirement", "")), PIE_SETTINGS_FILE, sec, "Requirement")
                IniWrite(PieSafeColor(item.Get("color", "455A64")), PIE_SETTINGS_FILE, sec, "Color")
                IniWrite(item.Get("enabled", 1), PIE_SETTINGS_FILE, sec, "Enabled")
                if typeVal = "submenu"
                    IniWrite(item.Get("subPie", 1), PIE_SETTINGS_FILE, sec, "SubPie")
            }
        }
        SettingsSyncIniWatcher()
    } catch as err {
        DebugLog("SavePieItems error: " err.Message)
        SettingsDiagPush("ERR", "Pie items save failed", err.Message)
    }
}

PieRepairDuplicateIniSections(path, targetSections) {
    if !FileExist(path)
        return
    try txt := FileRead(path)
    catch
        return
    target := Map()
    for _, sec in targetSections
        target[StrLower(sec)] := true
    seen := Map()
    skip := false
    changed := false
    out := ""
    for line in StrSplit(txt, "`n", "`r") {
        clean := Trim(line)
        if RegExMatch(clean, "^\[(.+)\]$", &m) {
            secName := StrLower(Trim(m[1]))
            if target.Has(secName) && seen.Has(secName) {
                skip := true
                changed := true
                continue
            }
            skip := false
            if target.Has(secName)
                seen[secName] := true
        }
        if !skip
            out .= line "`n"
    }
    if !changed
        return
    try {
        FileDelete(path)
        FileAppend(RTrim(out, "`n") "`r`n", path, "UTF-8")
        DebugLog("Repaired duplicate pie INI sections")
    }
}

LoadPieQuickHotkeys() {
    global PieQuickHotkeys, HOTKEY_SETTINGS_FILE, SETTINGS_FILE
    try {
        loaded := []
        ini := FileExist(HOTKEY_SETTINGS_FILE) ? HOTKEY_SETTINGS_FILE : SETTINGS_FILE
        if !FileExist(ini)
            return
        idsText := Trim(IniRead(ini, "PieQuickHotkeys", "Ids", ""))
        if idsText = "" {
            SettingsDiagPush("INFO", "No saved quick-pie hotkeys", ini)
            return
        }
        for _, rawId in StrSplit(idsText, "|") {
            id := Trim(rawId)
            if id = ""
                continue
            sec := "PieQuickHotkey_" id
            item := Map()
            item["id"] := id
            item["label"] := IniRead(ini, sec, "Label", "Quick Hotkey")
            item["key"] := PieQuickNormalizeKey(IniRead(ini, sec, "Hotkey", ""))
            item["scope"] := PieQuickNormalizeScope(IniRead(ini, sec, "Scope", "all"))
            item["type"] := StrLower(Trim(IniRead(ini, sec, "Type", "shortcut")))
            item["action"] := IniRead(ini, sec, "Action", "")
            item["requirement"] := HK_NormalizeRequirement(IniRead(ini, sec, "Requirement", ""))
            item["color"] := PieSafeColor(IniRead(ini, sec, "Color", "455A64"))
            item["description"] := IniRead(ini, sec, "Description", "")
            item["enabled"] := PieSafeInt(IniRead(ini, sec, "Enabled", 1), 1, 0, 1)
            item := PieQuickSanitizeItem(item)
            if !PieQuickIsMeaningfulItem(item)
                continue
            loaded.Push(item)
        }
        PieQuickHotkeys := loaded
        SettingsDiagPush("OK", "Loaded quick-pie hotkeys", PieQuickHotkeys.Length " item(s) from " ini)
    } catch as err {
        DebugLog("LoadPieQuickHotkeys error: " err.Message)
        SettingsDiagPush("ERR", "Quick-pie hotkeys load failed", err.Message)
    }
}

PieEditorRequirementStatus(req) {
    req := HK_NormalizeRequirement(req)
    if req = ""
        return "No requirement"
    return req " (" (PieRequirementEnabled(req) ? "enabled" : "disabled") ")"
}

PieEditorActionSummary(type, action, label := "", requirement := "", subPie := 1, enabled := true) {
    global SubPieNames
    type := StrLower(Trim(type))
    action := Trim(action)
    label := Trim(label)
    reqText := PieEditorRequirementStatus(requirement)
    txt := "Slot state: " (enabled ? "Enabled" : "Disabled") "`r`n"
        . "Requirement: " reqText "`r`n"
    if label != ""
        txt .= "Label: " label "`r`n"
    switch type {
        case "disabled":
            txt .= "Action type: Disabled`r`nThis slot stays hidden/inactive in the pie."
        case "submenu":
            subName := SubPieNames.Length >= subPie ? SubPieNames[subPie] : SubPieDefaultName(subPie)
            txt .= "Action type: Submenu`r`nOpens Sub Pie " subPie " - " subName "."
        case "nav":
            txt .= "Action type: Navigation`r`nRuns pie navigation action: " (action != "" ? action : "back") "."
        case "shortcut":
            txt .= "Action type: Shortcut`r`nSends: " (action != "" ? action : "(empty)") "`r`n"
                . "Risk: " HK_FunctionRiskBadges("PieShortcut", "Hotkey Action", action, requirement, type)
        case "function":
            fnName := PieExtractFunctionName(action)
            txt .= "Action type: Function`r`nFunction: " (fnName != "" ? fnName : "(invalid)") "`r`n"
            if fnName != "" {
                txt .= "Summary: " HK_FunctionSummary(fnName, PieBuiltinFunctionExists(fnName) ? "Built-in" : "Runtime", PieBuiltinFunctionExists(fnName) ? "Toolkit runtime" : "") "`r`n"
                    . "Available: " (PieFunctionAvailable(action) ? "Yes" : "No") "`r`n"
                    . "Risk: " HK_FunctionRiskBadges(fnName, PieBuiltinFunctionExists(fnName) ? "Built-in" : "Runtime", "", requirement, type)
            } else {
                txt .= "Summary: Function name is not valid yet."
            }
        case "script":
            txt .= "Action type: Script / App`r`nTarget: " (action != "" ? action : "(empty)") "`r`n"
                . "Exists: " (action != "" && FileExist(action) ? "Yes" : "No") "`r`n"
                . "Risk: " HK_FunctionRiskBadges("PieScript", "Built-in", action, requirement, type)
        case "url":
            txt .= "Action type: URL / Link`r`nTarget: " (action != "" ? action : "(empty)") "`r`n"
                . "Risk: " HK_FunctionRiskBadges("PieUrl", "Built-in", action, requirement, type)
        default:
            txt .= "Action type: " type "`r`nAction: " action
    }
    return txt
}

SavePieQuickHotkeysToFile(filePath) {
    global PieQuickHotkeys
    try
        oldIds := Trim(IniRead(filePath, "PieQuickHotkeys", "Ids", ""))
    catch
        oldIds := ""
    if oldIds != "" {
        for _, rawId in StrSplit(oldIds, "|") {
            id := Trim(rawId)
            if id != ""
                try IniDelete(filePath, "PieQuickHotkey_" id)
        }
    }
    ids := ""
    try {
        for _, item in PieQuickHotkeys {
            item := PieQuickSanitizeItem(item)
            if !PieQuickIsMeaningfulItem(item)
                continue
            id := item.Get("id", "")
            if id = ""
                continue
            ids .= (ids = "" ? "" : "|") id
            sec := "PieQuickHotkey_" id
            IniWrite(item.Get("label", "Quick Hotkey"), filePath, sec, "Label")
            IniWrite(PieQuickNormalizeKey(item.Get("key", "")), filePath, sec, "Hotkey")
            IniWrite(PieQuickNormalizeScope(item.Get("scope", "all")), filePath, sec, "Scope")
            IniWrite(StrLower(Trim(item.Get("type", "shortcut"))), filePath, sec, "Type")
            IniWrite(item.Get("action", ""), filePath, sec, "Action")
            IniWrite(HK_NormalizeRequirement(item.Get("requirement", "")), filePath, sec, "Requirement")
            IniWrite(PieSafeColor(item.Get("color", "455A64")), filePath, sec, "Color")
            IniWrite(item.Get("enabled", 1), filePath, sec, "Enabled")
            IniWrite(item.Get("description", ""), filePath, sec, "Description")
        }
        IniWrite(ids, filePath, "PieQuickHotkeys", "Ids")
    }
}

SavePieQuickHotkeys() {
    global HOTKEY_SETTINGS_FILE
    SavePieQuickHotkeysToFile(HOTKEY_SETTINGS_FILE)
    try SettingsSyncIniWatcher()
}

LoadPieQuickHotkeysFromFile(filePath) {
    global PieQuickHotkeys
    try {
        if !FileExist(filePath)
            return false
        idsText := Trim(IniRead(filePath, "PieQuickHotkeys", "Ids", ""))
        if idsText = ""
            return false
        loaded := []
        invalid := 0
        for _, rawId in StrSplit(idsText, "|") {
            id := Trim(rawId)
            if id = "" {
                invalid += 1
                continue
            }
            sec := "PieQuickHotkey_" id
            item := Map()
            item["id"] := id
            item["label"] := IniRead(filePath, sec, "Label", "Quick Hotkey")
            item["key"] := PieQuickNormalizeKey(IniRead(filePath, sec, "Hotkey", ""))
            item["scope"] := PieQuickNormalizeScope(IniRead(filePath, sec, "Scope", "all"))
            item["type"] := StrLower(Trim(IniRead(filePath, sec, "Type", "shortcut")))
            item["action"] := IniRead(filePath, sec, "Action", "")
            item["requirement"] := HK_NormalizeRequirement(IniRead(filePath, sec, "Requirement", ""))
            item["color"] := PieSafeColor(IniRead(filePath, sec, "Color", "455A64"))
            item["enabled"] := PieSafeInt(IniRead(filePath, sec, "Enabled", 1), 1, 0, 1)
            item["description"] := IniRead(filePath, sec, "Description", "")
            item := PieQuickSanitizeItem(item)
            if !PieQuickIsMeaningfulItem(item) {
                invalid += 1
                continue
            }
            loaded.Push(item)
        }
        if !loaded.Length
            return false
        return PieQuickMergeLoadedItems(loaded, invalid)
    } catch as err {
        DebugLog("LoadPieQuickHotkeysFromFile error: " err.Message)
        return false
    }
}

PieQuickMakeUniqueId(existingItems, baseId := "") {
    if Trim(baseId) = ""
        baseId := "q" A_TickCount
    id := baseId
    tries := 0
    while PieQuickHasId(existingItems, id) {
        tries += 1
        id := baseId "_" Random(1000, 9999) "_" tries
    }
    return id
}

PieQuickHasId(items, id) {
    if !IsObject(items)
        return false
    for _, item in items {
        item := PieQuickSanitizeItem(item)
        if Trim(item.Get("id", "")) = id
            return true
    }
    return false
}

PieQuickItemSignature(item) {
    item := PieQuickSanitizeItem(item)
    return (
        StrLower(Trim(item.Get("label", ""))) "|"
        PieQuickNormalizeKey(item.Get("key", "")) "|"
        PieQuickNormalizeScope(item.Get("scope", "all")) "|"
        StrLower(Trim(item.Get("type", "shortcut"))) "|"
        Trim(item.Get("action", "")) "|"
        HK_NormalizeRequirement(item.Get("requirement", "")) "|"
        Trim(item.Get("description", "")) "|"
        PieSafeInt(item.Get("enabled", 1), 1, 0, 1)
    )
}

PieQuickMergeLoadedItems(loaded, invalidCount := 0) {
    global PieQuickHotkeys
    if !IsObject(PieQuickHotkeys)
        PieQuickHotkeys := []
    existing := []
    existingSigs := Map()
    for _, item in PieQuickHotkeys {
        item := PieQuickSanitizeItem(item)
        if !PieQuickIsMeaningfulItem(item)
            continue
        existing.Push(item)
        existingSigs[PieQuickItemSignature(item)] := true
    }
    added := 0
    skipped := 0
    for _, item in loaded {
        item := PieQuickSanitizeItem(item)
        sig := PieQuickItemSignature(item)
        if existingSigs.Has(sig) {
            skipped += 1
            continue
        }
        if PieQuickHasId(existing, item.Get("id", "")) {
            item["id"] := PieQuickMakeUniqueId(existing, item.Get("id", "q" A_TickCount))
        }
        existing.Push(item)
        existingSigs[sig] := true
        added += 1
    }
    PieQuickHotkeys := existing
    return {added: added, skipped: skipped, invalid: invalidCount, loaded: loaded.Length, total: existing.Length}
}

PieQuickCompactItems() {
    global PieQuickHotkeys
    if !IsObject(PieQuickHotkeys)
        PieQuickHotkeys := []
    compacted := []
    seenIds := Map()
    changed := false
    for _, item in PieQuickHotkeys {
        item := PieQuickSanitizeItem(item)
        if !PieQuickIsMeaningfulItem(item) {
            changed := true
            continue
        }
        id := Trim(item.Get("id", ""))
        if id = "" || seenIds.Has(id) {
            item["id"] := PieQuickMakeUniqueId(compacted, id != "" ? id : "q" A_TickCount)
            changed := true
        }
        seenIds[item["id"]] := true
        compacted.Push(item)
    }
    if changed || compacted.Length != PieQuickHotkeys.Length
        PieQuickHotkeys := compacted
    return changed
}

PieQuickSanitizeItem(item) {
    src := item
    if !IsObject(src)
        src := Map()
    normalized := Map()
    normalized["id"] := Trim(PieQuickReadField(src, "id", ""))
    if normalized["id"] = ""
        normalized["id"] := "q" A_TickCount "_" Random(1000, 9999)
    normalized["label"] := Trim(PieQuickReadField(src, "label", ""))
    normalized["key"] := PieQuickNormalizeKey(PieQuickReadField(src, "key", ""))
    normalized["scope"] := PieQuickNormalizeScope(PieQuickReadField(src, "scope", "all"))
    normalized["type"] := ToolkitNormalizeActionType(PieQuickReadField(src, "type", "shortcut"))
    normalized["action"] := PieQuickNormalizeAction(PieQuickReadField(src, "action", ""))
    if normalized["type"] = "shortcut" && normalized["action"] != ""
        normalized["action"] := PieQuickNormalizeShortcutAction(normalized["action"])
    normalized["requirement"] := HK_NormalizeRequirement(PieQuickReadField(src, "requirement", ""))
    normalized["color"] := PieSafeColor(PieQuickReadField(src, "color", "455A64"))
    normalized["description"] := Trim(PieQuickReadField(src, "description", ""))
    normalized["enabled"] := PieSafeInt(PieQuickReadField(src, "enabled", 1), 1, 0, 1)
    return normalized
}

PieQuickNormalizeShortcutAction(action) {
    if action = ""
        return ""
    action := StrLower(action)
    if !RegExMatch(action, "^[!^+#]*[a-z0-9]$") {
        if RegExMatch(action, "^([!^+#]*)(.+)$", &m) {
            key := m[2]
            if RegExMatch(key, "^\{[^}]+\}$")
                return action
            if RegExMatch(key, "\}\{")
                return action
            action := m[1] "{" key "}"
        }
    }
    return action
}

PieQuickReadField(item, key, default := "") {
    if !IsObject(item)
        return default
    try {
        if item.Has(key)
            return item[key]
    }
    try {
        if item.HasProp(key)
            return item.%key%
    }
    try {
        return item.Get(key, default)
    }
    return default
}

ToolkitNormalizeActionType(type) {
    type := StrLower(Trim(type))
    if type = "showpie" || type = "show_pie" || type = "pie"
        return "show pie"
    if type = "action"
        return "shortcut"
    if type = ""
        return "disabled"
    return type
}

PieQuickNormalizeAction(action) {
    action := Trim(action)
    if action = ""
        return ""
    static oldPaintNames := Map(
        "HotkeyPaintTransparentNotify", "HotkeyPaintTransparent",
        "HotkeyPaintRedLineNotify", "HotkeyPaintRedLine",
        "HotkeyPaintGreenLineNotify", "HotkeyPaintGreenLine",
        "HotkeyPaintBlueLineNotify", "HotkeyPaintBlueLine",
        "HotkeyPaintPinkLineNotify", "HotkeyPaintPinkLine",
        "HotkeyPaintCyanLineNotify", "HotkeyPaintCyanLine",
        "HotkeyPaintOrangeLineNotify", "HotkeyPaintOrangeLine",
        "HotkeyPaintPurpleLineNotify", "HotkeyPaintPurpleLine")
    base := RegExReplace(action, "\s*\(.*$")
    if oldPaintNames.Has(base)
        return oldPaintNames[base]
    return action
}

PieQuickIsMeaningfulItem(item) {
    item := PieQuickSanitizeItem(item)
    label := Trim(item.Get("label", ""))
    if label = "Quick Hotkey"
        label := ""
    key := PieQuickNormalizeKey(item.Get("key", ""))
    action := Trim(item.Get("action", ""))
    req := HK_NormalizeRequirement(item.Get("requirement", ""))
    desc := Trim(item.Get("description", ""))
    type := StrLower(Trim(item.Get("type", "shortcut")))
    scope := PieQuickNormalizeScope(item.Get("scope", "all"))
    return !(label = "" && key = "" && action = "" && req = "" && desc = "" && (type = "" || type = "shortcut") && scope = "all")
}

PieQuickPresetDir() {
    global SETTINGS_DIR
    dir := SETTINGS_DIR "\pie_quick_presets"
    try {
        if !DirExist(dir)
            DirCreate(dir)
    }
    return dir
}

PieQuickCopyBundledPresets() {
    bundledDir := A_ScriptDir "\src\presets"
    if !DirExist(bundledDir)
        return
    targetDir := PieQuickPresetDir()
    copied := 0
    Loop Files bundledDir "\*.ini" {
        dest := targetDir "\" A_LoopFileName
        if !FileExist(dest) {
            try FileCopy(A_LoopFilePath, dest)
            copied++
        }
    }
    if copied
        SettingsDiagPush("OK", "Copied missing quick-pie presets", copied " preset file(s) added.")
}

PieQuickPresetPath(name) {
    clean := RegExReplace(Trim(name), "[^\w \-.]+", "_")
    clean := RegExReplace(clean, "^\.+|\.+$", "")
    if clean = ""
        clean := "pie_quick_preset"
    return PieQuickPresetDir() "\" clean ".ini"
}

global _PieQuickModeDefaults := Map(
    "default",  ["csp_shortcuts"],
    "setup",    ["nav_cel", "nav_layer"],
    "tracing",  ["uranuri"],
    "animate",  ["uranuri"],
    "painting", ["paint"]
)

PieQuickSeedModeDefaults(modeId) {
    global _PieQuickModeDefaults, HOTKEY_SETTINGS_FILE
    if !_PieQuickModeDefaults.Has(modeId)
        return
    ini := FileExist(HOTKEY_SETTINGS_FILE) ? HOTKEY_SETTINGS_FILE : ""
    if ini = "" || !FileExist(ini)
        return
    idsText := ""
    try idsText := Trim(IniRead(ini, "PieQuickHotkeys", "Ids", ""))
    if idsText != ""
        return
    presetNames := _PieQuickModeDefaults[modeId]
    loaded := 0
    for name in presetNames {
        path := PieQuickPresetPath(name)
        if !FileExist(path)
            continue
        stats := LoadPieQuickHotkeysFromFile(path)
        if IsObject(stats)
            loaded += stats.added
    }
    if loaded > 0 {
        SavePieQuickHotkeysToFile(ini)
        DebugLog("PieQuickSeedModeDefaults: seeded " loaded " item(s) for mode '" modeId "'")
    }
}

PieQuickNormalizeScope(scope) {
    scope := StrLower(Trim(scope))
    if scope = "" || scope = "all" || scope = "all pie"
        return "all"
    if scope = "disabled" || scope = "disable" || scope = "-"
        return "disabled"
    if RegExMatch(scope, "i)^pie\s*([1-4])$", &m)
        return m[1]
    if scope ~= "^[1-4]$"
        return scope
    return "all"
}

PieQuickScopeLabel(scope) {
    scope := PieQuickNormalizeScope(scope)
    if scope = "disabled"
        return "Disabled"
    if scope = "all"
        return "All Pie"
    return "Pie " scope
}

PieQuickScopeIndex(scope) {
    scope := PieQuickNormalizeScope(scope)
    return scope = "disabled" ? 1 : scope = "1" ? 2 : scope = "2" ? 3 : scope = "3" ? 4 : scope = "4" ? 5 : 6
}

PieQuickScopeFromIndex(idx) {
    return idx = 1 ? "disabled" : idx = 2 ? "1" : idx = 3 ? "2" : idx = 4 ? "3" : idx = 5 ? "4" : "all"
}

PieQuickNormalizeKey(key) {
    key := PieNormalizeHotkey(key)
    key := Trim(key)
    if key = "" || key = "-"
        return key
    return key
}

PieKeyUsesTab(key) {
    key := StrLower(RegExReplace(Trim(key), "^[~*$<>]+", ""))
    return key = "tab" || InStr(key, "tab &") || InStr(key, "& tab") || RegExMatch(key, "(^|[!^+#])tab$")
}

PieKeyIsPlainTab(key) {
    key := StrLower(RegExReplace(Trim(key), "^[~*$<>]+", ""))
    return key = "tab"
}

PieBlockTabPassthroughKey(key) {
    key := PieNormalizeHotkey(key)
    if PieKeyUsesTab(key)
        key := RegExReplace(key, "~")
    return key
}

PieQuickBaseKey(key) {
    key := PieQuickNormalizeKey(key)
    key := RegExReplace(key, "^[~*$]+")
    key := RegExReplace(key, "[\^\+!#]", "")
    return StrLower(key)
}

PieQuickIsReservedKey(key) {
    base := PieQuickBaseKey(key)
    return base ~= "^[0-9]$" || base ~= "^numpad[0-9]$"
}

PieQuickScopeMatches(scope) {
    global _pieActiveIndex
    scope := PieQuickNormalizeScope(scope)
    if scope = "disabled"
        return false
    if scope = "all"
        return true
    return _pieActiveIndex = ToolkitSafeInt(scope, -1)
}

PieQuickStatus(item) {
    item := PieQuickSanitizeItem(item)
    key := PieQuickNormalizeKey(item.Get("key", ""))
    scope := PieQuickNormalizeScope(item.Get("scope", "all"))
    req := HK_NormalizeRequirement(item.Get("requirement", ""))
    type := StrLower(Trim(item.Get("type", "shortcut")))
    action := Trim(item.Get("action", ""))
    if !item.Get("enabled", 1) || scope = "disabled"
        return "Disabled"
    if key = "" || key = "-"
        return "Error: missing key"
    if type != "disabled" && action = ""
        return "Error: missing action"
    if PieQuickIsReservedKey(key)
        return "Reserved: 1-0"
    if PieQuickConflictText(key, scope, item.Get("id", "")) != ""
        return "Conflict"
    if !PieRequirementEnabled(req)
        return "Disabled requirement"
    return PieQuickScopeLabel(scope)
}

PieQuickReapplyHotkeys() {
    global PieQuickHotkeys, PieQuickRegistered, TabCombosEnabled
    if !FeatureEnabled("quickpie") {
        PieQuickDisableAll()
        return
    }
    PieQuickDisableAll()
    PieQuickCompactItems()
    keySet := Map()
    for idx, item in PieQuickHotkeys {
        item := PieQuickSanitizeItem(item)
        PieQuickHotkeys[idx] := item
        key := PieQuickNormalizeKey(item.Get("key", ""))
        if key = "" || key = "-" || PieQuickIsReservedKey(key)
            continue
        if !TabCombosEnabled && PieKeyUsesTab(key)
            continue
        if !item.Get("enabled", 1) || PieQuickNormalizeScope(item.Get("scope", "all")) = "disabled"
            continue
        keySet[PieBlockTabPassthroughKey(key)] := true
    }
    for key, _ in keySet {
        try {
            HotIf(PieIsOpen)
            Hotkey(key, PieQuickRun.Bind(key), "On")
            PieQuickRegistered[key] := true
            DebugLog("Pie quick hotkey applied: " key)
        } catch as e {
            DebugLog("Pie quick hotkey failed: " key " - " e.Message)
            ShowNotify("Pie Quick Hotkey", "Failed: " key, "0xE53935")
        }
    }
    HotIf()
}

PieQuickDisableAll() {
    global PieQuickRegistered
    for key, _ in PieQuickRegistered
        PieQuickDisableHotkey(key)
    PieQuickRegistered := Map()
}

PieQuickDisableHotkey(key) {
    key := Trim(key)
    if key = "" || key = "-"
        return
    try {
        HotIf(PieIsOpen)
        Hotkey(key, "Off")
        noPassKey := PieBlockTabPassthroughKey(key)
        if noPassKey != key
            Hotkey(noPassKey, "Off")
    }
    HotIf()
}

PieQuickRun(key, *) {
    global PieQuickHotkeys, _pieActivated, NotifyEnabled, NotifyMonitor, NotifyPosition, _pieQuickRunning
    key := PieQuickNormalizeKey(key)
    errLabel := ""
    errType := ""
    errAction := ""
    try {
        for _, rawItem in PieQuickHotkeys {
            item := PieQuickSanitizeItem(rawItem)
            if PieBlockTabPassthroughKey(PieQuickNormalizeKey(item.Get("key", ""))) != key
                continue
            if PieQuickStatus(item) = "Reserved: 1-0" || !PieQuickScopeMatches(item.Get("scope", "all"))
                continue
            if !item.Get("enabled", 1)
                continue
            type := ToolkitNormalizeActionType(item.Get("type", "disabled"))
            if type = "disabled"
                continue
            item["type"] := type
            if Trim(item.Get("label", "")) = ""
                item["label"] := "Pie Quick"
            errLabel := item.Get("label", "")
            errType := item.Get("type", "")
            errAction := item.Get("action", "")
            _pieActivated := true
            PieClose()
            Sleep(30)
            slotColor := "0x" PieSafeColor(item.Get("color", "455A64"))
            qkTitle := item.Get("label", "Pie Quick")
            qkSub := item.Get("action", "")
            if (NotifyEnabled) {
                posOpt := " pos=" NotifyPosition
                monOpt := NotifyMonitor > 0 ? " mon=" NotifyMonitor : ""
                Notify.Show(qkTitle, qkSub,,,, 'dur=1 ts=10 ms=7 pad=8,4,6,6,6,6,2,3 mf=Segoe UI Black mfo=norm Bold mali=Center' posOpt monOpt " bc=" slotColor " tc=" ContrastColor(slotColor) " mc=" ContrastColor(slotColor))
            }
            _pieQuickRunning := true
            PieRunItem(item)
            _pieQuickRunning := false
            return
        }
    } catch as e {
        _pieQuickRunning := false
        DebugLog("Pie Quick Error: " e.Message " | key=" key " | label=" errLabel " | type=" errType " | action=" errAction)
        ShowNotify("Pie Quick Error", e.Message, "0xE53935")
    }
}

Pie_ReapplyHotkeys() {
    global PieHotkeys, PieRegistered, TabCombosEnabled
    if !FeatureEnabled("pie") {
        Loop 4 {
            idx := A_Index
            if PieRegistered.Has(idx)
                PieDisableHotkey(PieRegistered[idx])
            PieDisableHotkey(PieHotkeys.Length >= idx ? PieHotkeys[idx] : PieDefaultHotkey(idx))
            PieDisableHotkey(PieDefaultHotkey(idx))
        }
        PieRegistered := Map()
        return
    }
    desired := Map()
    Loop 4 {
        idx := A_Index
        if !PieIsEnabled(idx) {
            PieDisableHotkey(PieHotkeys.Length >= idx ? PieHotkeys[idx] : PieDefaultHotkey(idx))
            PieDisableHotkey(PieDefaultHotkey(idx))
            continue
        }
        key := PieHotkeys.Length >= idx ? PieNormalizeHotkey(PieHotkeys[idx]) : ""
        if key = "" || key = "-"
            continue
        if !TabCombosEnabled && PieKeyUsesTab(key) {
            PieDisableHotkey(key)
            PieDisableHotkey(PieDefaultHotkey(idx))
            continue
        }
        if TabCombosEnabled && PieKeyIsPlainTab(key) {
            ; Plain Tab is handled by TabKeyHandler so just disable in pie context.
            HotIf(HotIfConditionPieOpenKey)
            try Hotkey(key, "Off")
            HotIf()
            continue
        }
        desired[idx] := PieBlockTabPassthroughKey(key)
    }
    stale := []
    for idx, oldKey in PieRegistered {
        if !desired.Has(idx) || desired[idx] != oldKey {
            stale.Push([idx, oldKey])
        }
    }
    for pair in stale {
        PieDisableHotkey(pair[2])
        if PieRegistered.Has(pair[1])
            PieRegistered.Delete(pair[1])
    }
    for idx, key in desired {
        if PieRegistered.Has(idx) && PieRegistered[idx] = key
            continue
        try {
            HotIf(HotIfConditionPieOpenKey)
            Hotkey(key, ShowPieMenu.Bind(idx), "On")
            PieRegistered[idx] := key
            DebugLog("Pie " idx " hotkey applied: " key)
        } catch as e {
            DebugLog("Pie " idx " hotkey failed: " key " - " e.Message)
            ShowNotify("Pie Hotkey", "Failed Pie " idx ": " key, "0xE53935")
        }
    }
    HotIf()
}

PieDisableHotkey(key) {
    key := Trim(key)
    if key = "" || key = "-"
        return
    HK_DisableHotkeyAllContexts(key)
    noPassKey := PieBlockTabPassthroughKey(key)
    if noPassKey != key
        HK_DisableHotkeyAllContexts(noPassKey)
}

PieRequirementEnabled(req) {
    global ReqAnimationEnabled, ReqNastarEnabled
    req := HK_NormalizeRequirement(req)
    if req = ""
        return true
    if req = REQ_ANIM
        return !!ReqAnimationEnabled
    if req = REQ_NASTAR
        return !!ReqNastarEnabled
    return true
}

PieSafeColor(color) {
    return NormalizeHexColorText(color, "455A64")
}

ShowPieMenu(pieIndex := 1, *) {
    global PieItems, PieConfigs, PieNames, PieGUI, _pieActiveIndex, _pieControlMap, _pieCloseMap, _pieCtrlMeta, _pieHoverHwnd, _pieHoverStart, _pieCenterX, _pieCenterY, _pieActivated, _pieMouseWasDown, _pieStyle
    global _pieAllCtrls, _pieCenterCtrls, _pieItemCtrls, _pieMenuW, _pieMenuH, _pieSlotW, _pieSlotH, _pieCompactSideStyle
    global _pieNavStack, _pieCurrentName, _pieCenterNameCtrl, _pieCenterHintCtrl
    global _pieBackTarget, _pieIsSubPie
    if !FeatureEnabled("pie")
        return
    if IsTyping()
        return
    if PieConfigs.Length = 0
        PieItemsDefaults()
    pieIndex := PieSafeInt(pieIndex, 1, 1, 4)
    if !PieIsEnabled(pieIndex)
        return
    if IsObject(PieGUI) {
        if _pieActiveIndex = pieIndex {
            PieClose()
            return
        }
        PieClose()
    }
    PieItems := PieConfigs[pieIndex]
    pieName := PieNames.Length >= pieIndex ? PieNames[pieIndex] : PieDefaultName(pieIndex)
    _pieCurrentName := pieName
    _pieActiveIndex := pieIndex
    _pieActivated := false
    _pieControlMap := Map()
    _pieCloseMap := Map()
    _pieCtrlMeta := Map()
    _pieAllCtrls := []
    _pieCenterCtrls := []
    _pieItemCtrls := []
    _pieNavStack := []
    _pieBackTarget := 0
    _pieIsSubPie := false
    _pieHoverHwnd := 0
    _pieHoverStart := 0
    _pieMouseWasDown := GetKeyState("LButton", "P")

    MouseGetPos(&mx, &my)
    w := PieS(460), h := PieS(360), slotW := PieS(118), slotH := PieS(28)
    normalizedStyle := PieNormalizeStyle(_pieStyle)
    if normalizedStyle != "Normal" {
        slotW := PieS(96)
        slotH := PieS(24)
    }
    _pieMenuW := w
    _pieMenuH := h
    _pieSlotW := slotW
    _pieSlotH := slotH
    _pieCompactSideStyle := normalizedStyle != "Normal"
    cx := w // 2, cy := h // 2
    _pieCenterX := mx
    _pieCenterY := my
    transColor := "010101"
    PieGUI := Gui("+AlwaysOnTop -Caption +ToolWindow", "Pie Menu " pieIndex)
    PieGUI.BackColor := transColor
    PieGUI.MarginX := 0
    PieGUI.MarginY := 0
    bgClose := PieGUI.AddText("x0 y0 w" w " h" h " Background" transColor, "")
    bgClose.OnEvent("Click", PieClose)
    _pieCloseMap[bgClose.Hwnd] := true
    centerX := cx - PieS(56), centerY := cy - PieS(28)
    PieGUI.SetFont("s" PieS(10) " Bold cFFFFFF", "Segoe UI")
    centerName := PieGUI.AddText("x" centerX " y" centerY " w" PieS(112) " h" PieS(28) " Center +0x200 Background242424 cFFFFFF", pieName)
    centerName.OnEvent("Click", PieClose)
    _pieCenterNameCtrl := centerName
    _pieCloseMap[centerName.Hwnd] := true
    _pieCenterCtrls.Push(centerName)
    _pieAllCtrls.Push(centerName)
    PieGUI.SetFont("s" PieS(7) " cAAAAAA", "Segoe UI")
    centerHint := PieGUI.AddText("x" centerX " y+0 w" PieS(112) " h" PieS(20) " Center +0x200 Background242424 cAAAAAA", "Esc to close")
    centerHint.OnEvent("Click", PieClose)
    _pieCenterHintCtrl := centerHint
    _pieCloseMap[centerHint.Hwnd] := true
    _pieCenterCtrls.Push(centerHint)
    _pieAllCtrls.Push(centerHint)

    positions := PieLayoutPositions(w, h, slotW, slotH, _pieStyle)
    PieRenderItems(PieGUI, PieItems, positions, slotW, slotH, _pieCompactSideStyle)
    PieRenderQuickHints(PieGUI, w, h)

    PieGUI.Show("x" (mx - w // 2) " y" (my - h // 2) " w" w " h" h " NoActivate")
    WinSetTransColor(transColor, PieGUI)
    PieKeyboardHotkeys(true)
    SetTimer(PieHoverTick, 50)
}

ShowPieMenuAt(pieIndex := 1, mx := "", my := "") {
    global PieItems, PieConfigs, PieNames, PieGUI, _pieActiveIndex, _pieControlMap, _pieCloseMap, _pieCtrlMeta, _pieHoverHwnd, _pieHoverStart, _pieCenterX, _pieCenterY, _pieActivated, _pieMouseWasDown, _pieStyle
    global _pieAllCtrls, _pieCenterCtrls, _pieItemCtrls, _pieMenuW, _pieMenuH, _pieSlotW, _pieSlotH, _pieCompactSideStyle
    global _pieNavStack, _pieCurrentName, _pieCenterNameCtrl, _pieCenterHintCtrl
    global _pieBackTarget, _pieIsSubPie
    if !FeatureEnabled("pie")
        return
    if IsTyping()
        return
    if PieConfigs.Length = 0
        PieItemsDefaults()
    pieIndex := PieSafeInt(pieIndex, 1, 1, 4)
    if !PieIsEnabled(pieIndex)
        return
    if IsObject(PieGUI)
        PieClose()
    PieItems := PieConfigs[pieIndex]
    pieName := PieNames.Length >= pieIndex ? PieNames[pieIndex] : PieDefaultName(pieIndex)
    _pieCurrentName := pieName
    _pieActiveIndex := pieIndex
    _pieActivated := false
    _pieControlMap := Map()
    _pieCloseMap := Map()
    _pieCtrlMeta := Map()
    _pieAllCtrls := []
    _pieCenterCtrls := []
    _pieItemCtrls := []
    _pieNavStack := []
    _pieBackTarget := 0
    _pieIsSubPie := false
    _pieHoverHwnd := 0
    _pieHoverStart := 0
    _pieMouseWasDown := GetKeyState("LButton", "P")
    if mx = "" || my = ""
        MouseGetPos(&mx, &my)
    PieCreateContainer("Pie Menu " pieIndex, pieName, "Esc to close", PieItems, mx, my)
}

ShowSubPieMenu(subPieIndex := 1, *) {
    if !FeatureEnabled("pie")
        return
    if IsTyping()
        return
    MouseGetPos(&mx, &my)
    ShowSubPieMenuAt(subPieIndex, mx, my)
}

ShowSubPieMenuAt(subPieIndex := 1, mx := "", my := "", backTarget := 0) {
    global SubPieConfigs, SubPieNames, PieGUI, _pieActiveIndex, _pieControlMap, _pieCloseMap, _pieCtrlMeta, _pieHoverHwnd, _pieHoverStart, _pieCenterX, _pieCenterY, _pieActivated, _pieMouseWasDown, _pieStyle
    global _pieAllCtrls, _pieCenterCtrls, _pieItemCtrls, _pieMenuW, _pieMenuH, _pieSlotW, _pieSlotH, _pieCompactSideStyle
    global _pieNavStack, _pieCurrentName, _pieCenterNameCtrl, _pieCenterHintCtrl, PieItems
    global _pieBackTarget, _pieIsSubPie
    if !FeatureEnabled("pie")
        return
    subPieIndex := PieEnsureSubPie(subPieIndex)
    if IsObject(PieGUI)
        PieClose()
    PieItems := PieNormalizeConfigSlots(SubPieConfigs[subPieIndex], SubPieDefaultConfig(subPieIndex))
    SubPieConfigs[subPieIndex] := PieItems
    pieName := SubPieNames.Length >= subPieIndex ? SubPieNames[subPieIndex] : SubPieDefaultName(subPieIndex)
    _pieCurrentName := pieName
    _pieActiveIndex := IsObject(backTarget) && backTarget.Has("index") ? backTarget["index"] : 0
    _pieActivated := false
    _pieControlMap := Map()
    _pieCloseMap := Map()
    _pieCtrlMeta := Map()
    _pieAllCtrls := []
    _pieCenterCtrls := []
    _pieItemCtrls := []
    _pieNavStack := []
    _pieBackTarget := IsObject(backTarget) ? backTarget : 0
    _pieIsSubPie := true
    _pieHoverHwnd := 0
    _pieHoverStart := 0
    _pieMouseWasDown := GetKeyState("LButton", "P")

    if mx = "" || my = ""
        MouseGetPos(&mx, &my)
    w := PieS(460), h := PieS(360), slotW := PieS(118), slotH := PieS(34)
    if PieNormalizeStyle(_pieStyle) != "Normal" {
        slotW := PieS(96)
        slotH := PieS(24)
    }
    _pieMenuW := w
    _pieMenuH := h
    _pieSlotW := slotW
    _pieSlotH := slotH
    _pieCompactSideStyle := PieNormalizeStyle(_pieStyle) != "Normal"
    _pieCenterX := mx
    _pieCenterY := my
    transColor := "010101"
    PieGUI := Gui("+AlwaysOnTop -Caption +ToolWindow", "Sub Pie Menu " subPieIndex)
    PieGUI.BackColor := transColor
    PieGUI.MarginX := 0
    PieGUI.MarginY := 0
    bgClose := PieGUI.AddText("x0 y0 w" w " h" h " Background" transColor, "")
    bgClose.OnEvent("Click", PieClose)
    _pieCloseMap[bgClose.Hwnd] := true
    centerX := w // 2 - PieS(56), centerY := h // 2 - PieS(28)
    PieGUI.SetFont("s" PieS(10) " Bold cFFFFFF", "Segoe UI")
    centerName := PieGUI.AddText("x" centerX " y" centerY " w" PieS(112) " h" PieS(28) " Center +0x200 Background242424 cFFFFFF", pieName)
    centerName.OnEvent("Click", PieClose)
    _pieCenterNameCtrl := centerName
    _pieCloseMap[centerName.Hwnd] := true
    _pieCenterCtrls.Push(centerName)
    _pieAllCtrls.Push(centerName)
    PieGUI.SetFont("s" PieS(7) " cAAAAAA", "Segoe UI")
    centerHint := PieGUI.AddText("x" centerX " y+0 w" PieS(112) " h" PieS(20) " Center +0x200 Background242424 cAAAAAA", "Esc to close")
    centerHint.OnEvent("Click", PieClose)
    _pieCenterHintCtrl := centerHint
    _pieCloseMap[centerHint.Hwnd] := true
    _pieCenterCtrls.Push(centerHint)
    _pieAllCtrls.Push(centerHint)
    positions := PieLayoutPositions(w, h, slotW, slotH, _pieStyle)
    PieRenderItems(PieGUI, PieItems, positions, slotW, slotH, _pieCompactSideStyle)
    PieRenderQuickHints(PieGUI, w, h)
    PieGUI.Show("x" (mx - w // 2) " y" (my - h // 2) " w" w " h" h " NoActivate")
    WinSetTransColor(transColor, PieGUI)
    PieKeyboardHotkeys(true)
    SetTimer(PieHoverTick, 50)
}

PieCreateContainer(title, pieName, hint, items, mx, my) {
    global PieGUI, _pieCloseMap, _pieCenterCtrls, _pieAllCtrls, _pieCenterNameCtrl, _pieCenterHintCtrl, _pieStyle
    global _pieCenterX, _pieCenterY, _pieMenuW, _pieMenuH, _pieSlotW, _pieSlotH, _pieCompactSideStyle
    w := PieS(460), h := PieS(360), slotW := PieS(118), slotH := PieS(34)
    if PieNormalizeStyle(_pieStyle) != "Normal" {
        slotW := PieS(96)
        slotH := PieS(24)
    }
    _pieMenuW := w
    _pieMenuH := h
    _pieSlotW := slotW
    _pieSlotH := slotH
    _pieCompactSideStyle := PieNormalizeStyle(_pieStyle) != "Normal"
    _pieCenterX := mx
    _pieCenterY := my
    transColor := "010101"
    PieGUI := Gui("+AlwaysOnTop -Caption +ToolWindow", title)
    PieGUI.BackColor := transColor
    PieGUI.MarginX := 0
    PieGUI.MarginY := 0
    bgClose := PieGUI.AddText("x0 y0 w" w " h" h " Background" transColor, "")
    bgClose.OnEvent("Click", PieClose)
    _pieCloseMap[bgClose.Hwnd] := true
    centerX := w // 2 - PieS(56), centerY := h // 2 - PieS(28)
    PieGUI.SetFont("s" PieS(10) " Bold cFFFFFF", "Segoe UI")
    centerName := PieGUI.AddText("x" centerX " y" centerY " w" PieS(112) " h" PieS(28) " Center +0x200 Background242424 cFFFFFF", pieName)
    centerName.OnEvent("Click", PieClose)
    _pieCenterNameCtrl := centerName
    _pieCloseMap[centerName.Hwnd] := true
    _pieCenterCtrls.Push(centerName)
    _pieAllCtrls.Push(centerName)
    PieGUI.SetFont("s" PieS(7) " cAAAAAA", "Segoe UI")
    centerHint := PieGUI.AddText("x" centerX " y+0 w" PieS(112) " h" PieS(20) " Center +0x200 Background242424 cAAAAAA", hint)
    centerHint.OnEvent("Click", PieClose)
    _pieCenterHintCtrl := centerHint
    _pieCloseMap[centerHint.Hwnd] := true
    _pieCenterCtrls.Push(centerHint)
    _pieAllCtrls.Push(centerHint)
    positions := PieLayoutPositions(w, h, slotW, slotH, _pieStyle)
    PieRenderItems(PieGUI, items, positions, slotW, slotH, _pieCompactSideStyle)
    PieRenderQuickHints(PieGUI, w, h)
    PieGUI.Show("x" (mx - w // 2) " y" (my - h // 2) " w" w " h" h " NoActivate")
    WinSetTransColor(transColor, PieGUI)
    PieKeyboardHotkeys(true)
    SetTimer(PieHoverTick, 50)
}

PieKeyboardHotkeys(enable := true) {
    static keys := ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    Loop keys.Length {
        key := keys[A_Index]
        slot := key = "0" ? 10 : Integer(key)
        try {
            HotIf(PieIsOpen)
            if enable {
                Hotkey(key, PieActivateSlot.Bind(slot), "On")
                Hotkey("Numpad" key, PieActivateSlot.Bind(slot), "On")
            } else {
                Hotkey(key, "Off")
                Hotkey("Numpad" key, "Off")
            }
        } catch as e {
            DebugLog("PieKeyboardHotkeys failed for key " key ": " e.Message)
        }
    }
    HotIf()
    if enable {
        PieQuickReapplyHotkeys()
        PieRegisterTabCloseHotkeys(true)
    } else {
        PieRegisterTabCloseHotkeys(false)
        PieQuickDisableAll()
    }
}

PieRegisterTabCloseHotkeys(enable := true) {
    static tabCloseKeys := ["$Tab", "$+Tab", "$^Tab", "$!Tab", "$#Tab", "$^+Tab", "$^!Tab", "$+!Tab", "$^+!Tab", "$#+Tab", "$#^Tab", "$#!Tab", "$#^+Tab", "$#^!Tab", "$#+!Tab", "$#^+!Tab"]
    HotIf(PieIsOpen)
    for _, key in tabCloseKeys {
        try {
            if enable
                Hotkey(key, PieClose, "On")
            else
                Hotkey(key, "Off")
        } catch as e {
            DebugLog("Pie tab close hotkey failed for " key ": " e.Message)
        }
    }
    HotIf()
}

PieIsOpen(*) {
    global PieGUI
    return IsObject(PieGUI)
}

PieActivateSlot(slot, *) {
    global PieItems, _pieActivated
    if _pieActivated || !IsObject(PieItems) || slot < 1 || slot > PieItems.Length
        return
    item := PieItems[slot]
    if !IsObject(item) || !item.Get("enabled", 1)
        return
    if PieItemHasSubmenu(item) {
        PieOpenSubmenu(item)
        return
    }
    if item.Get("type", "") = "nav" {
        PieRunNavItem(item)
        return
    }
    _pieActivated := true
    PieClose()
    PieRunItem(item)
}

PieNormalizeConfigSlots(config, defaultConfig := "") {
    if !IsObject(defaultConfig)
        defaultConfig := PieDefaultConfig(99)
    if !IsObject(config)
        config := []
    Loop defaultConfig.Length {
        i := A_Index
        if config.Length < i || !IsObject(config[i])
            config.Push(defaultConfig[i])
    }
    return config
}

PieRenderItems(guiObj, items, positions, slotW, slotH, compactSideStyle) {
    global _pieControlMap, _pieCtrlMeta, _pieAllCtrls, _pieItemCtrls
    if !IsObject(guiObj) || !SafeGuiHwnd(guiObj)
        return
    items := PieNormalizeConfigSlots(items)
    for i, item in items {
        if !SafeGuiHwnd(guiObj)
            return
        if i > positions.Length
            break
        enabled := !!item.Get("enabled", 1) && (item.Get("type", "disabled") != "disabled" || PieItemHasSubmenu(item)) && PieRequirementEnabled(HK_NormalizeRequirement(item.Get("requirement","")))
        label := item.Get("label", PieSlotName(i))
        if label = ""
            label := PieSlotName(i)
        loc := PieSlotName(i)
        c := enabled ? PieSafeColor(item.Get("color", "455A64")) : "555555"
        fc := ContrastColor(c)
        x := positions[i][1], y := positions[i][2]
        if compactSideStyle {
            locCtl := 0
            guiObj.SetFont("s" PieS(6) (enabled ? " Bold" : "") " c" fc, "Segoe UI")
            labelCtl := guiObj.AddText("x" x " y" y " w" slotW " h" slotH " Center +0x200 Background" c " c" fc, label)
        } else {
            guiObj.SetFont("s" PieS(5) " c" fc, "Segoe UI")
            locCtl := guiObj.AddText("x" x " y" y " w" slotW " h" PieS(11) " Center +0x200 Background" c " c" fc, loc)
            guiObj.SetFont("s" PieS(7) (enabled ? " Bold" : "") " c" fc, "Segoe UI")
            labelCtl := guiObj.AddText("x" x " y+" PieS(0) " w" slotW " h" PieS(22) " Center +0x200 Background" c " c" fc, label)
        }
        ; number / disabled badge
        badgeW := PieS(16), badgeH := PieS(13)
        keyLabel := PieSlotBadge(i, enabled, PieItemHasSubmenu(item))
        badge := guiObj.AddText("x" x + slotW - badgeW + PieS(1) " y" y - PieS(1) " w" badgeW " h" badgeH " Center +0x200 BackgroundFFD54F c202020", keyLabel)
        badge.SetFont("s" PieS(7) " Bold", "Segoe UI")
        _pieAllCtrls.Push(badge)
        _pieAllCtrls.Push(labelCtl)
        _pieItemCtrls.Push(labelCtl)
        if IsObject(locCtl) {
            _pieAllCtrls.Push(locCtl)
            _pieItemCtrls.Push(locCtl)
        }
        ; per-slot quick key label
        PieRenderSlotQuickKey(guiObj, item, x, y, slotW, slotH, compactSideStyle)
        if enabled {
            if IsObject(locCtl)
                _pieControlMap[locCtl.Hwnd] := item
            _pieControlMap[labelCtl.Hwnd] := item
            if IsObject(locCtl)
                locCtl.OnEvent("Click", PieRunClicked.Bind(item, labelCtl.Hwnd))
            labelCtl.OnEvent("Click", PieRunClicked.Bind(item, labelCtl.Hwnd))
            meta := Map("loc", IsObject(locCtl) ? locCtl : labelCtl, "label", labelCtl, "color", c, "hover", "FDD835", "item", item)
            if IsObject(locCtl)
                _pieCtrlMeta[locCtl.Hwnd] := meta
            _pieCtrlMeta[labelCtl.Hwnd] := meta
        }
    }
}

PieQuickActiveHints() {
    global PieQuickHotkeys, _pieQuickHintCount
    scoped := []
    all := []
    if !IsObject(PieQuickHotkeys)
        return scoped
    maxHints := _pieQuickHintCount > 0 ? _pieQuickHintCount : 99
    for _, rawItem in PieQuickHotkeys {
        item := PieQuickSanitizeItem(rawItem)
        if !item.Get("enabled", 1)
            continue
        if ToolkitNormalizeActionType(item.Get("type", "disabled")) = "disabled"
            continue
        key := PieQuickNormalizeKey(item.Get("key", ""))
        if key = "" || key = "-" || PieQuickIsReservedKey(key)
            continue
        if !PieQuickScopeMatches(item.Get("scope", "all"))
            continue
        if !PieRequirementEnabled(item.Get("requirement", ""))
            continue
        label := Trim(item.Get("label", ""))
        if label = ""
            label := PieDisplayAction(item.Get("type", ""), item.Get("action", ""))
        if label = ""
            label := "Quick"
        col := PieSafeColor(item.Get("color", "455A64"))
        obj := {keyDisplay:HK_DisplayKey(key), label:label, color:col}
        if PieQuickNormalizeScope(item.Get("scope", "all")) = "all"
            all.Push(obj)
        else
            scoped.Push(obj)
    }
    hints := []
    for _, h in scoped {
        if hints.Length >= maxHints
            break
        hints.Push(h)
    }
    for _, h in all {
        if hints.Length >= maxHints
            break
        hints.Push(h)
    }
    return hints
}

PieRenderQuickHints(guiObj, w, h) {
    global _pieQuickHintsVisible, _pieQuickSlotHintsPos, _pieAllCtrls
    if !_pieQuickHintsVisible || !IsObject(guiObj) || !SafeGuiHwnd(guiObj)
        return
    hints := PieQuickActiveHints()
    if !hints.Length
        return
    isTop := SubStr(_pieQuickSlotHintsPos, 1, 4) = "top-"
    hAlign := SubStr(_pieQuickSlotHintsPos, isTop ? 5 : 8)

    gap := PieS(3)
    pad := PieS(4)
    boxH := PieS(14)

    if hAlign = "left" {
        availW := w - PieS(20)
        startX := PieS(10)
    } else if hAlign = "center" {
        availW := Min(w - PieS(40), PieS(500))
        startX := (w - availW) // 2
    } else {
        availW := Min(w - PieS(40), PieS(500))
        startX := w - availW - PieS(10)
    }

    rows := []
    curRow := []
    curW := 0
    keyFS := PieS(6)
    labelFS := PieS(6)

    for _, hint in hints {
        kLen := StrLen(hint.keyDisplay)
        lLen := StrLen(hint.label)
        kp := kLen * PieS(4) + pad
        lp := lLen * PieS(4) + pad
        itemW := kp + gap + lp

        if curRow.Length > 0 && curW + gap + itemW > availW {
            rows.Push(curRow)
            curRow := []
            curW := 0
        }
        hint._kw := kp
        hint._lw := lp
        hint._iw := itemW
        curRow.Push(hint)
        curW += itemW + (curRow.Length > 1 ? gap : 0)
    }
    if curRow.Length > 0
        rows.Push(curRow)

    totalH := rows.Length * boxH + Max(0, rows.Length - 1) * PieS(2)
    ; Keep quick hints on the absolute outer edge so they do not fight the pie slot boxes.
    y := isTop ? 0 : Max(0, h - totalH)

    for _, row in rows {
        rowW := 0
        for i, r in row
            rowW += r._iw + (i < row.Length ? gap : 0)

        if hAlign = "left"
            x := startX
        else if hAlign = "center"
            x := startX + (availW - rowW) // 2
        else
            x := startX + availW - rowW

        for _, r in row {
            guiObj.SetFont("s" keyFS " Bold", "Segoe UI")
            ctrl := guiObj.AddText("x" x " y" y " w" r._kw " h" boxH " Center +0x200 BackgroundFFD54F c202020", r.keyDisplay)
            _pieAllCtrls.Push(ctrl)
            x += r._kw + gap

            bg := r.color != "" ? r.color : "242424"
            guiObj.SetFont("s" labelFS " c" ContrastColor(bg), "Segoe UI")
            ctrl := guiObj.AddText("x" x " y" y " w" r._lw " h" boxH " Left +0x200 Background" bg, r.label)
            _pieAllCtrls.Push(ctrl)
            x += r._lw + gap
        }

        y += boxH + PieS(2)
    }
}

PieClearItemControls() {
    global _pieControlMap, _pieCtrlMeta, _pieHoverHwnd, _pieHoverStart, _pieItemCtrls
    for _, ctrl in _pieItemCtrls {
        try ctrl.Visible := false
    }
    _pieItemCtrls := []
    _pieControlMap := Map()
    _pieCtrlMeta := Map()
    _pieHoverHwnd := 0
    _pieHoverStart := 0
}

PieItemHasSubmenu(item) {
    global SubPieConfigs
    if !IsObject(item)
        return false
    if item.Get("type", "") != "submenu"
        return false
    idx := PieSafeInt(item.Get("subPie", 1), 1, 1, Max(1, SubPieConfigs.Length))
    return idx >= 1 && idx <= SubPieConfigs.Length
}

PieOpenSubmenu(item, parentHwnd := 0) {
    global PieGUI, SubPieConfigs, _pieActiveIndex, _pieCenterX, _pieCenterY
    if !IsObject(PieGUI) || !PieItemHasSubmenu(item)
        return false
    nextSubPie := PieSafeInt(item.Get("subPie", 1), 1, 1, Max(1, SubPieConfigs.Length))
    if nextSubPie < 1 || nextSubPie > SubPieConfigs.Length
        return false
    MouseGetPos(&branchX, &branchY)
    backTarget := Map("index", _pieActiveIndex, "x", _pieCenterX, "y", _pieCenterY)
    PieClose()
    ShowSubPieMenuAt(nextSubPie, branchX, branchY, backTarget)
    return true
}

PieMoveCenterTo(screenX, screenY) {
    global PieGUI, _pieMenuW, _pieMenuH, _pieCenterX, _pieCenterY
    if !IsObject(PieGUI)
        return
    _pieCenterX := screenX
    _pieCenterY := screenY
    try PieGUI.Move(screenX - _pieMenuW // 2, screenY - _pieMenuH // 2)
}

PieSetCenterText(name, hint := "Esc to close") {
    global _pieCenterNameCtrl, _pieCenterHintCtrl
    if IsObject(_pieCenterNameCtrl) {
        _pieCenterNameCtrl.Text := name
        _pieCenterNameCtrl.Visible := true
    }
    if IsObject(_pieCenterHintCtrl) {
        _pieCenterHintCtrl.Text := hint
        _pieCenterHintCtrl.Visible := true
    }
}

PieBack(*) {
    global PieGUI, PieItems, _pieActiveIndex, _pieControlMap, _pieCtrlMeta, _pieHoverHwnd, _pieHoverStart
    global _pieCenterCtrls, _pieMenuW, _pieMenuH, _pieSlotW, _pieSlotH, _pieCompactSideStyle, _pieStyle
    global _pieNavStack, _pieCurrentName
    if !IsObject(PieGUI) || _pieNavStack.Length = 0
        return false
    prev := _pieNavStack.Pop()
    PieClearItemControls()
    for _, ctrl in _pieCenterCtrls
        try ctrl.Visible := true
    _pieActiveIndex := prev["index"]
    PieItems := prev["items"]
    _pieCurrentName := prev["name"]
    PieMoveCenterTo(prev.Get("centerX", _pieCenterX), prev.Get("centerY", _pieCenterY))
    PieSetCenterText(_pieCurrentName, _pieNavStack.Length ? "Back item returns / Esc closes" : "Esc to close")
    positions := PieLayoutPositions(_pieMenuW, _pieMenuH, _pieSlotW, _pieSlotH, _pieStyle)
    PieRenderItems(PieGUI, PieItems, positions, _pieSlotW, _pieSlotH, _pieCompactSideStyle)
    return true
}

PieRunNavItem(item) {
    global _pieBackTarget, _pieIsSubPie
    action := StrLower(Trim(item.Get("action", "")))
    if action = "back" {
        if !PieBack() {
            if _pieIsSubPie && IsObject(_pieBackTarget) {
                target := _pieBackTarget
                PieClose()
                ShowPieMenuAt(target.Get("index", 1), target.Get("x", ""), target.Get("y", ""))
            } else {
                PieClose()
            }
        }
        return true
    }
    if action = "close" {
        PieClose()
        return true
    }
    return false
}

PieHoverTick(*) {
    global PieGUI, _pieControlMap, _pieCloseMap, _pieHoverHwnd, _pieHoverStart, _pieDelayMs, _pieDeadzone, _pieCenterX, _pieCenterY, _pieActivated, _pieMouseWasDown
    if !IsObject(PieGUI) {
        SetTimer(PieHoverTick, 0)
        return
    }
    if GetKeyState("Esc", "P") {
        PieClose()
        return
    }
    MouseGetPos(&mx, &my,, &ctrlHwnd, 2)
    lDown := GetKeyState("LButton", "P")
    if lDown && !_pieMouseWasDown {
        _pieMouseWasDown := true
        if ctrlHwnd && _pieControlMap.Has(ctrlHwnd) {
            if !_pieActivated {
                item := _pieControlMap[ctrlHwnd]
                if PieItemHasSubmenu(item) {
                    PieOpenSubmenu(item, ctrlHwnd)
                    return
                }
                if item.Get("type", "") = "nav" {
                    PieRunNavItem(item)
                    return
                }
                _pieActivated := true
                PieClose()
                PieRunItem(item)
            }
        } else {
            PieClose()
        }
        return
    } else if !lDown {
        _pieMouseWasDown := false
    }
    dx := mx - _pieCenterX, dy := my - _pieCenterY
    deadzoneSq := PieS(_pieDeadzone) ** 2
    if (dx * dx + dy * dy) < deadzoneSq {
        PieSetHover(0)
        return
    }
    if !_pieActivated && ctrlHwnd && _pieControlMap.Has(ctrlHwnd) {
        if ctrlHwnd != _pieHoverHwnd {
            PieSetHover(ctrlHwnd)
            return
        }
        item := _pieControlMap[ctrlHwnd]
        hoverDelay := PieItemHasSubmenu(item) ? Floor(_pieDelayMs * 0.8) : _pieDelayMs
        if A_TickCount - _pieHoverStart < hoverDelay
            return
        if PieItemHasSubmenu(item) {
            PieOpenSubmenu(item, ctrlHwnd)
            return
        }
        if item.Get("type", "") = "nav" {
            PieRunNavItem(item)
            return
        }
        _pieActivated := true
        PieClose()
        PieRunItem(item)
    } else {
        PieSetHover(0)
    }
}

PieSetHover(ctrlHwnd) {
    global _pieCtrlMeta, _pieHoverHwnd, _pieHoverStart
    if ctrlHwnd = _pieHoverHwnd
        return
    PiePaintHover(_pieHoverHwnd, false)
    _pieHoverHwnd := ctrlHwnd
    _pieHoverStart := ctrlHwnd ? A_TickCount : 0
    PiePaintHover(ctrlHwnd, true)
}

PiePaintHover(ctrlHwnd, isHover) {
    global _pieCtrlMeta
    if !ctrlHwnd || !_pieCtrlMeta.Has(ctrlHwnd)
        return
    meta := _pieCtrlMeta[ctrlHwnd]
    color := isHover ? meta["hover"] : meta["color"]
    try meta["loc"].Opt("Background" color " c" ContrastColor(color))
    try meta["label"].Opt("Background" color " c" ContrastColor(color))
}

PieClose(*) {
    global PieGUI, _pieActiveIndex, _pieControlMap, _pieCloseMap, _pieCtrlMeta, _pieHoverHwnd, _pieHoverStart, _pieMouseWasDown, _pieAllCtrls, _pieCenterCtrls, _pieItemCtrls
    global _pieNavStack, _pieCurrentName, _pieCenterNameCtrl, _pieCenterHintCtrl
    global _pieBackTarget, _pieIsSubPie
    SetTimer(PieHoverTick, 0)
    PieKeyboardHotkeys(false)
    _pieActiveIndex := 0
    _pieControlMap := Map()
    _pieCloseMap := Map()
    _pieCtrlMeta := Map()
    _pieAllCtrls := []
    _pieCenterCtrls := []
    _pieItemCtrls := []
    _pieNavStack := []
    _pieCurrentName := ""
    _pieBackTarget := 0
    _pieIsSubPie := false
    _pieCenterNameCtrl := 0
    _pieCenterHintCtrl := 0
    _pieHoverHwnd := 0
    _pieHoverStart := 0
    _pieMouseWasDown := false
    if IsObject(PieGUI) {
        try PieGUI.Destroy()
        PieGUI := 0
    }
}

PieRunClicked(item, labelHwnd := 0, *) {
    global _pieActivated
    if _pieActivated
        return
    if PieItemHasSubmenu(item) {
        PieOpenSubmenu(item, labelHwnd)
        return
    }
    if item.Get("type", "") = "nav" {
        PieRunNavItem(item)
        return
    }
    _pieActivated := true
    PieClose()
    PieRunItem(item)
}

PieRunItem(item) {
    global _pieQuickRunning
    item := PieQuickSanitizeItem(item)
    if !item.Get("enabled", 1)
        return
    type := ToolkitNormalizeActionType(item.Get("type", "disabled"))
    action := Trim(item.Get("action", ""))
    label := item.Get("label", "Pie")
    req := HK_NormalizeRequirement(item.Get("requirement", ""))
    slotColor := "0x" PieSafeColor(item.Get("color", "455A64"))
    if !PieRequirementEnabled(req)
        return PieError("Pie Menu", "Requirement disabled: " req, "label=" label " action=" action " type=" type)
    if action = "" || type = "disabled"
        return
    try {
        if type = "nav" {
            PieRunNavItem(item)
        } else if type = "shortcut" {
            HotkeySendCSP(action)
            if !_pieQuickRunning
                ShowNotify("Pie Menu", label, slotColor)
        } else if type = "function" {
            PieRunFunction(action, label)
        } else if type = "url" {
            Run(action)
            if !_pieQuickRunning
                ShowNotify("Pie Menu", label, slotColor)
        } else if type = "script" {
            Run(action)
            if !_pieQuickRunning
                ShowNotify("Pie Menu", label, slotColor)
        } else if type = "show pie" {
            PieRunShowPieAction(action)
        }
    } catch as e {
        PieError("Pie Error", e.Message, "label=" label " action=" action " type=" type)
    }
}

PieRunShowPieAction(action) {
    target := StrLower(Trim(action))
    if RegExMatch(target, "i)^(sub|subpie|sub pie)\s*[:= ]\s*(\d+)$", &m) {
        idx := Integer(m[2])
        if idx < 1
            idx := 1
        ShowSubPieMenu(idx)
        return true
    }
    target := RegExReplace(target, "i)^(main|pie)\s*[:= ]\s*")
    if !RegExMatch(target, "^-?\d+$")
        return false
    idx := Integer(target)
    if idx < 1
        idx := 1
    ShowPieMenu(idx)
    return true
}

PieTestEditorItem(type, action, label, requirement := "", subPie := 1) {
    type := StrLower(Trim(type))
    if type = "submenu" {
        ShowSubPiePreview(subPie)
        return
    }
    if type = "disabled" || Trim(action) = "" {
        _HK_ResultPopup("Pie Test", "Nothing to test.", "E53935")
        return
    }
    item := Map("type", type, "action", action, "label", label != "" ? label : "Pie Test", "requirement", requirement, "enabled", 1, "subPie", subPie)
    PieRunItem(item)
}

PieRunFunction(action, label := "Pie") {
    parsed := ToolkitParseFunctionAction(action)
    fnName := parsed.Get("name", "")
    if fnName = "" {
        PieError("Function Error", "Invalid function: " action, "label=" label)
        return
    }
    ToolkitCallFunction(fnName, parsed.Get("args", []), label, action)
}

ToolkitRunFunction(action, label := "Function") {
    parsed := ToolkitParseFunctionAction(action)
    fnName := parsed.Get("name", "")
    if fnName = "" {
        DebugLog(label ": invalid function: " action)
        ShowNotify(label, "Invalid function: " action, "0xE53935")
        return false
    }
    return ToolkitCallFunction(fnName, parsed.Get("args", []), label, action)
}

ToolkitParseFunctionAction(action) {
    action := Trim(action)
    action := RegExReplace(action, "i)^\s*return\s+")
    action := RegExReplace(action, "\s*;\s*$")
    args := []
    if RegExMatch(action, "i)^\s*([A-Z_][A-Z0-9_]*)\s*\((.*)\)\s*$", &m) {
        fnName := m[1]
        args := PieParseFunctionArgs(m[2])
    } else {
        fnName := RegExReplace(action, "\s+$")
        fnName := RegExReplace(fnName, "\(\s*\)$")
    }
    fnName := Trim(fnName)
    if !RegExMatch(fnName, "i)^[A-Z_][A-Z0-9_]*$")
        fnName := ""
    return Map("name", fnName, "args", args)
}

ToolkitCallFunction(fnName, args := "", label := "Function", action := "") {
    if !IsObject(args)
        args := []
    fnName := Trim(fnName)
    if fnName = "" {
        DebugLog(label ": empty function name")
        ShowNotify(label, "Function name is empty.", "0xE53935")
        return false
    }
    try {
        if PieRunBuiltinFunction(fnName, args)
            return true
        callable := HK_FnForName(fnName)
        if !IsObject(callable) {
            if ToolkitRunUserLibraryFunction(fnName, args, label)
                return true
            DebugLog(label ": function not found " fnName)
            ShowNotify(label, "Function not found: " fnName, "0xE53935")
            return false
        }
        callable.Call(args*)
        return true
    } catch as e {
        msg := e.Message
        if InStr(msg, "Invalid base")
            msg := "Function failed inside its script. Check object/map access in " fnName "."
        DebugLog(label ": function failed " fnName " - " e.Message (action != "" ? " | action=" action : ""))
        ShowNotify(label, fnName " - " msg, "0xE53935")
        return false
    }
}

ToolkitRunUserLibraryFunction(fnName, args := "", label := "Function") {
    if !FeatureEnabled("userscript") {
        DebugLog(label ": user-library function " fnName " blocked: User Scripts feature is off")
        return false
    }
    if !IsObject(args)
        args := []
    if args.Length > 0 {
        DebugLog(label ": user-library functions with arguments are not supported yet: " fnName)
        return false
    }
    try scanned := HK_ScanScriptFunctions()
    catch
        return false
    if !IsObject(scanned) || !scanned.Has(fnName)
        return false
    filePath := scanned[fnName]
    try {
        if !HK_IsUserLibraryFunctionPath(filePath)
            return false
    } catch {
        return false
    }
    filePath := HK_ResolveExistingPath(filePath)
    if filePath = "" || !FileExist(filePath) {
        DebugLog(label ": user-library script not found for " fnName)
        ShowNotify(label, "User script not found: " fnName, "0xE53935")
        return true
    }

    stamp := A_TickCount "_" A_NowUTC
    wrapperPath := A_Temp "\csp_user_fn_" stamp ".ahk"
    escHelper := StrReplace(A_ScriptDir "\src\includes\user_script_helpers.ahk", '"', '""')
    escPath := StrReplace(filePath, '"', '""')
    escFn := StrReplace(fnName, '"', '""')
    wrapperBody := "#Requires AutoHotkey v2.0`n"
        . "#SingleInstance Off`n"
        . "#NoTrayIcon`n"
        . '#Include "' escHelper '"`n'
        . '#Include "' escPath '"`n'
        . 'fn := "' escFn '"`n'
        . "try {`n"
        . "    %fn%()`n"
        . "    Sleep(1500)`n"
        . "} catch as e {`n"
        . '    ShowNotify("CSP User Function", "Failed: " e.Message, "0xE53935")`n'
        . "    Sleep(1500)`n"
        . "}`n"
    try {
        FileAppend(wrapperBody, wrapperPath, "UTF-8")
        Run('"' A_AhkPath '" "' wrapperPath '"')
        DebugLog(label ": launched user-library function " fnName)
        return true
    } catch as e {
        DebugLog(label ": failed to launch user-library function " fnName " - " e.Message)
        ShowNotify(label, "User function launch failed: " fnName, "0xE53935")
        return true
    }
}

ToolkitRunAction(type, action, label := "Action", slotColor := "") {
    type := StrLower(Trim(type))
    action := Trim(action)
    if type = "disabled" || action = ""
        return false
    try {
        if type = "shortcut" || type = "action" {
            HotkeySendCSP(PieQuickNormalizeShortcutAction(action))
            ShowNotify(label, HotkeyDisplayName(action), slotColor)
            DebugLog(label ": action shortcut " action)
            return true
        }
        if type = "function"
            return ToolkitRunFunction(action, label)
        if type = "url" || type = "script" {
            Run(action)
            ShowNotify(label, "Opened", slotColor)
            DebugLog(label ": opened " action)
            return true
        }
        if type = "show pie" || type = "show_pie" || type = "pie" {
            PieRunShowPieAction(action)
            DebugLog(label ": opened pie target " action)
            return true
        }
        DebugLog(label ": unknown action type " type)
        ShowNotify(label, "Unknown type: " type, "0xE53935")
    } catch as e {
        DebugLog(label ": " type " action failed - " e.Message " | action=" action)
        ShowNotify(label, e.Message, "0xE53935")
    }
    return false
}

PieError(title, message, detail := "") {
    DebugLog(title ": " message (detail != "" ? " | " detail : ""))
    ShowNotify(title, message, "0xE53935")
}

PieRunBuiltinFunction(fnName, args) {
    fnKey := StrLower(Trim(fnName))
    switch fnKey {
        case "showcspguide":
            ShowCSPGuide()
        case "showcsprecommended":
            ShowCSPRecommended()
        case "showltsettingshelp":
            ShowLTSettingsHelp()
        case "firstrunwizard":
            FirstRunWizard()
        case "showhotkeysettings":
            ShowHotkeySettings()
        case "showstatusdashboard":
            ShowStatusDashboard()
        case "showltsettings":
            ShowLTSettings()
        case "showdebuggui":
            ShowDebugGUI()
        case "showlinkmanager":
            ShowLinkManager()
        case "showpieoven":
            ShowPieOven()
        case "showsettingshealth":
            ShowSettingsHealth()
        case "showuserfunctionlibrary":
            ShowUserFunctionLibrary()
        case "safemode":
            SafeMode()
        case "togglemainwindow":
            ToggleMainWindow()
        case "showmaingui":
            ShowMainGUI()
        case "showguisetting":
            ShowGuiSetting()
        case "showopacityslider":
            ShowOpacitySlider(args.Length >= 1 ? args[1] : "Main")
        case "toggleinbetweenmode":
            ToggleInbetweenMode()
        case "toggleautosave":
            ToggleAutoSave()
        case "togglenav":
            ToggleNav()
        case "showpiesettings":
            ShowPieSettings(args.Length >= 1 ? args[1] : 1)
        case "guideibnotify":
            GuideIBNotify()
        case "guidecreatenotify":
            GuideCreateNotify()
        case "guideshortcutnotify":
            GuideShortcutNotify()
        case "guideautoactionnotify":
            GuideAutoActionNotify()
        case "guideanimationnotify":
            GuideAnimationNotify()
        case "hotkeydeletelayer":
            HotkeyDeleteLayer()
        case "hotkeydeletepaintchecker":
            HotkeyDeletePaintChecker()
        case "hotkeypaintcheckerlayer", "functionpaintcheckerlayer":
            HotkeyPaintCheckerLayer()
        case "hotkeypaintcheckerimage", "functionpaintcheckerimage":
            HotkeyPaintCheckerImage()
        case "hotkeypainttransparent":
            HotkeyPaintTransparent()
        case "hotkeypaintredline":
            HotkeyPaintRedLine()
        case "hotkeypaintgreenline":
            HotkeyPaintGreenLine()
        case "hotkeypaintblueline":
            HotkeyPaintBlueLine()
        case "hotkeypaintpinkline":
            HotkeyPaintPinkLine()
        case "hotkeypaintcyanline":
            HotkeyPaintCyanLine()
        case "hotkeypaintorangeline":
            HotkeyPaintOrangeLine()
        case "hotkeypaintpurpleline":
            HotkeyPaintPurpleLine()
        case "hotkeysettopaintanimation":
            HotkeySetToPaintAnimation()
        case "hotkeyvectorpaths":
            HotkeyVectorPaths()
        case "hotkeylayerblack":
            HotkeyLayerBlack()
        case "hotkeylayerred":
            HotkeyLayerRed()
        case "hotkeylayerblue":
            HotkeyLayerBlue()
        case "hotkeylayergreen":
            HotkeyLayerGreen()
        case "hotkeylayerpink":
            HotkeyLayerPink()
        case "hotkeylayercyan":
            HotkeyLayerCyan()
        case "hotkeylayerorange":
            HotkeyLayerOrange()
        case "hotkeylayeruranuri":
            HotkeyLayerUranuri()
        case "hotkeylayerpaint":
            HotkeyLayerPaint()
        case "hotkeylayerrough":
            HotkeyLayerRough()
        case "hotkeylayerselect2":
            HotkeyLayerSelect2()
        case "hotkeylayerselect3":
            HotkeyLayerSelect3()
        case "hotkeylayerselect4":
            HotkeyLayerSelect4()
        case "hotkeylayerselect5":
            HotkeyLayerSelect5()
        case "hotkeylayerselect6":
            HotkeyLayerSelect6()
        case "hotkeylayerselect7":
            HotkeyLayerSelect7()
        case "hotkeylayerselect8":
            HotkeyLayerSelect8()
        case "hotkeylayerselect9":
            HotkeyLayerSelect9()
        case "hotkeylayerselect10":
            HotkeyLayerSelect10()
        case "hotkeycreatepaperlayer":
            HotkeyCreatePaperLayer(args.Length >= 1 ? args[1] : false)
        case "hotkeycreaterasterlayer":
            HotkeyCreateRasterLayer(args.Length >= 1 ? args[1] : false)
        case "hotkeycreatevectorlayer":
            HotkeyCreateVectorLayer(args.Length >= 1 ? args[1] : false)
        case "hotkeycreatecoloredvectorlayer":
            HotkeyCreateColoredVectorLayer(args.Length >= 1 ? args[1] : false)
        case "hotkeycreatedummylayer":
            HotkeyCreateDummyLayer(args.Length >= 1 ? args[1] : false)
        case "hotkeyseparateblackline":
            HotkeySeparateBlackLine(args.Length >= 1 ? args[1] : false)
        case "hotkeyseparateredline":
            HotkeySeparateBlackLine(args.Length >= 1 ? args[1] : false)
        case "hotkeyseparategreenline":
            HotkeySeparateBlackLine(args.Length >= 1 ? args[1] : false)
        case "hotkeyseparatepurpleline":
            HotkeySeparateBlackLine(args.Length >= 1 ? args[1] : false)
        case "hotkeycreateoutlinelayer":
            HotkeySeparateBlackLine(args.Length >= 1 ? args[1] : false)
        case "hotkeycreatepinkvectorlayer":
            HotkeyCreatePinkVectorLayer(args.Length >= 1 ? args[1] : false)
        case "hotkeycreatecyanvectorlayer":
            HotkeyCreateCyanVectorLayer(args.Length >= 1 ? args[1] : false)
        case "hotkeycreateorangevectorlayer":
            HotkeyCreateOrangeVectorLayer(args.Length >= 1 ? args[1] : false)
        case "hotkeycreateanimationfolder":
            HotkeyCreateAnimationFolder(args.Length >= 1 ? args[1] : false)
        case "hotkeyfeaturekeyframecolor":
            HotkeyFeatureKeyframeColor(args.Length >= 1 ? args[1] : false)
        case "hotkeyfeaturereferencecolor":
            HotkeyFeatureReferenceColor(args.Length >= 1 ? args[1] : false)
        case "hotkeyfeatureremovelayercolor":
            HotkeyFeatureRemoveLayerColor(args.Length >= 1 ? args[1] : false)
        case "hotkeyfeaturehalfgreen":
            HotkeyFeatureHalfGreen(args.Length >= 1 ? args[1] : false)
        case "hotkeyfeaturehalfpurple":
            HotkeyFeatureHalfPurple(args.Length >= 1 ? args[1] : false)
        case "hotkeyfeaturenormalcolor":
            HotkeyFeatureNormalColor(args.Length >= 1 ? args[1] : false)
        case "hotkeyfeaturepaperpurple":
            HotkeyFeaturePaperPurple(args.Length >= 1 ? args[1] : false)
        case "hotkeyfeaturepapergreen":
            HotkeyFeaturePaperGreen(args.Length >= 1 ? args[1] : false)
        case "hotkeyfeaturepaperwhite":
            HotkeyFeaturePaperWhite(args.Length >= 1 ? args[1] : false)
        case "hotkeyfeaturelayercolorblack":
            HotkeyFeatureLayerColorBlack(args.Length >= 1 ? args[1] : false)
        case "hotkeylayerup":
            HotkeyLayerUp(args.Length >= 1 ? args[1] : false)
        case "hotkeylayerdown":
            HotkeyLayerDown(args.Length >= 1 ? args[1] : false)
        case "hotkeytoplayer":
            HotkeyTopLayer(args.Length >= 1 ? args[1] : false)
        case "hotkeybottomlayer":
            HotkeyBottomLayer(args.Length >= 1 ? args[1] : false)
        default:
            return false
    }
    return true
}

PieBuiltinFunctionExists(fnName) {
    fnKey := StrLower(Trim(fnName))
    switch fnKey {
        case "showcspguide", "showcsprecommended", "showltsettingshelp", "firstrunwizard", "showhotkeysettings", "showstatusdashboard", "showltsettings", "showdebuggui", "showlinkmanager", "showpieoven":
            return true
        case "showsettingshealth", "showuserfunctionlibrary", "safemode", "togglemainwindow", "showmaingui", "showguisetting", "showopacityslider", "toggleinbetweenmode", "toggleautosave", "togglenav", "showpiesettings", "hotkeydeletelayer", "hotkeypaintcheckerlayer", "functionpaintcheckerlayer", "hotkeypaintcheckerimage", "functionpaintcheckerimage":
            return true
        case "guideibnotify", "guidecreatenotify", "guideshortcutnotify", "guideautoactionnotify", "guideanimationnotify":
            return true
        case "hotkeypainttransparent", "hotkeypaintredline", "hotkeypaintgreenline", "hotkeypaintblueline", "hotkeypaintpinkline", "hotkeypaintcyanline", "hotkeypaintorangeline", "hotkeypaintpurpleline", "hotkeysettopaintanimation", "hotkeyvectorpaths":
            return true
        case "hotkeylayerblack", "hotkeylayerred", "hotkeylayerblue", "hotkeylayergreen", "hotkeylayerpink", "hotkeylayercyan", "hotkeylayerorange", "hotkeylayeruranuri", "hotkeylayerpaint", "hotkeylayerrough":
            return true
        case "hotkeylayerselect2", "hotkeylayerselect3", "hotkeylayerselect4", "hotkeylayerselect5", "hotkeylayerselect6", "hotkeylayerselect7", "hotkeylayerselect8", "hotkeylayerselect9", "hotkeylayerselect10":
            return true
        case "hotkeycreatepaperlayer", "hotkeycreaterasterlayer", "hotkeycreatevectorlayer", "hotkeycreatecoloredvectorlayer", "hotkeycreatedummylayer", "hotkeycreateoutlinelayer", "hotkeycreatepinkvectorlayer", "hotkeycreatecyanvectorlayer", "hotkeycreateorangevectorlayer", "hotkeycreateanimationfolder":
            return true
        case "hotkeyfeaturekeyframecolor", "hotkeyfeaturereferencecolor", "hotkeyfeatureremovelayercolor", "hotkeyfeaturehalfgreen", "hotkeyfeaturehalfpurple", "hotkeyfeaturenormalcolor", "hotkeyfeaturepaperpurple", "hotkeyfeaturepapergreen", "hotkeyfeaturepaperwhite", "hotkeyfeaturelayercolorblack":
            return true
        case "hotkeylayerup", "hotkeylayerdown", "hotkeytoplayer", "hotkeybottomlayer":
            return true
        default:
            return false
    }
}

PieExtractFunctionName(action) {
    action := Trim(action)
    action := RegExReplace(action, "i)^\s*return\s+")
    action := RegExReplace(action, "\s*;\s*$")
    if RegExMatch(action, "i)^\s*([A-Z_][A-Z0-9_]*)\s*\(.*\)\s*$", &m)
        return Trim(m[1])
    fnName := RegExReplace(action, "\s+$")
    fnName := RegExReplace(fnName, "\(\s*\)$")
    fnName := Trim(fnName)
    return RegExMatch(fnName, "i)^[A-Z_][A-Z0-9_]*$") ? fnName : ""
}

PieFunctionAvailable(action) {
    fnName := PieExtractFunctionName(action)
    if fnName = ""
        return false
    if PieBuiltinFunctionExists(fnName)
        return true
    return IsObject(HK_FnForName(fnName))
}

PieDisplayAction(type, action) {
    type := StrLower(Trim(type))
    action := Trim(action)
    if type = "function" && RegExMatch(action, "i)^\s*(Hotkey[A-Z0-9_]+)\s*\(\s*1\s*\)\s*$", &m)
        return m[1]
    return action
}

PieParseFunctionArgs(argText) {
    argText := Trim(argText)
    args := []
    if argText = ""
        return args
    for raw in StrSplit(argText, ",") {
        v := Trim(raw)
        if (SubStr(v, 1, 1) = '"' && SubStr(v, -1) = '"') || (SubStr(v, 1, 1) = "'" && SubStr(v, -1) = "'")
            v := SubStr(v, 2, StrLen(v) - 2)
        else if RegExMatch(v, "^-?\d+$")
            v := Integer(v)
        else if RegExMatch(v, "^-?\d+\.\d+$")
            v := Float(v)
        args.Push(v)
    }
    return args
}

PieSubPieChoices() {
    global SubPieConfigs, SubPieNames
    if SubPieConfigs.Length = 0 {
        SubPieNames := [SubPieDefaultName(1)]
        SubPieConfigs := [SubPieDefaultConfig(1)]
    }
    choices := []
    Loop SubPieConfigs.Length {
        s := A_Index
        choices.Push("Sub Pie " s " - " (SubPieNames.Length >= s ? SubPieNames[s] : SubPieDefaultName(s)))
    }
    return choices
}

PieEnsureSubPie(index := 1) {
    global SubPieConfigs, SubPieNames
    index := PieSafeInt(index, 1, 1, 30)
    if SubPieConfigs.Length = 0 {
        SubPieNames := [SubPieDefaultName(1)]
        SubPieConfigs := [SubPieDefaultConfig(1)]
    }
    while SubPieConfigs.Length < index {
        nextIdx := SubPieConfigs.Length + 1
        SubPieNames.Push(SubPieDefaultName(nextIdx))
        SubPieConfigs.Push(SubPieDefaultConfig(nextIdx))
    }
    return index
}

PieAddSubPie() {
    global SubPieConfigs, SubPieNames
    PieEnsureSubPie(1)
    if SubPieConfigs.Length >= 30 {
        ShowNotify("Sub Pie", "Maximum 30 sub pies.", "0xE53935")
        return SubPieConfigs.Length
    }
    newIdx := SubPieConfigs.Length + 1
    SubPieNames.Push(SubPieDefaultName(newIdx))
    SubPieConfigs.Push(SubPieDefaultConfig(newIdx))
    SavePieItems()
    ShowNotify("Sub Pie", "Added Sub Pie " newIdx)
    return newIdx
}

PieDeleteSubPie(index) {
    global SubPieConfigs, SubPieNames
    PieEnsureSubPie(1)
    if SubPieConfigs.Length <= 1 {
        ShowNotify("Sub Pie", "Keep at least one sub pie.", "0xE53935")
        return false
    }
    index := PieSafeInt(index, 1, 1, SubPieConfigs.Length)
    SubPieConfigs.RemoveAt(index)
    if SubPieNames.Length >= index
        SubPieNames.RemoveAt(index)
    PieRepairSubPieRefs(index)
    SavePieItems()
    ShowNotify("Sub Pie", "Deleted Sub Pie " index)
    return true
}

PieRepairSubPieRefs(removedIdx) {
    global PieConfigs, SubPieConfigs
    for p, config in PieConfigs
        PieRepairSubPieRefsInConfig(config, removedIdx)
    for s, config in SubPieConfigs
        PieRepairSubPieRefsInConfig(config, removedIdx)
}

PieRepairSubPieRefsInConfig(config, removedIdx) {
    global SubPieConfigs
    maxIdx := Max(1, SubPieConfigs.Length)
    for i, item in config {
        if !IsObject(item) || item.Get("type", "") != "submenu"
            continue
        subIdx := PieSafeInt(item.Get("subPie", 1), 1, 1, 99)
        if subIdx = removedIdx
            item["subPie"] := Max(1, Min(maxIdx, removedIdx - 1))
        else if subIdx > removedIdx
            item["subPie"] := Max(1, subIdx - 1)
        config[i] := item
    }
}

ShowPieSettings(pieIndex := 1, *) {
    global PieItems, PieConfigs, PieCount
    pieIndex := PieSafeInt(pieIndex, 1, 1, PieCount)
    PieItems := PieConfigs[pieIndex]
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Pie " pieIndex " Menu Settings")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(12)
    dlg.MarginY := S(12)
    dlg.AddText("xm cFFFFFF", "Hovering a pie slot runs its shortcut/function after the configured delay.")
    dlg.AddText("xm y+" S(6) " cAAAAAA", "Filter:")
    edFilter := dlg.AddEdit("x+6 yp w" S(200) " h+21 c000000 BackgroundFFFFFF")
    dlg.AddText("x+8 yp c666666", "matches label, type, action, requirement")
    lv := dlg.AddListView("xm y+" S(12) " w" S(629) " r10 Grid +Report +NoSortHdr", ["Slot", "Label", "Type", "Action", "Requirement", "Enabled"])
    lv.SetFont("s" S(9) " c000000", "Segoe UI")
    lv.ModifyCol(1, S(95))
    lv.ModifyCol(2, S(110))
    lv.ModifyCol(3, S(75))
    lv.ModifyCol(4, S(160))
    lv.ModifyCol(5, S(120))
    lv.ModifyCol(6, S(65))
    _filteredIndices := []
    RefreshPieList(*) {
        global PieItems
        lv.Delete()
        Loop _filteredIndices.Length
            _filteredIndices.Pop()
        filter := Trim(edFilter.Value)
        for i, item in PieItems {
            if filter != "" {
                haystack := PieSlotName(i) " " item.Get("label", "") " " item.Get("type", "disabled") " " (item.Get("type", "") = "submenu" ? "Sub Pie " item.Get("subPie", 1) : item.Get("action", "")) " " HK_NormalizeRequirement(item.Get("requirement", ""))
                if !InStr(haystack, filter)
                    continue
            }
            _filteredIndices.Push(i)
            lv.Add(, PieSlotName(i), item.Get("label", ""), item.Get("type", "disabled"), item.Get("type", "") = "submenu" ? "Sub Pie " item.Get("subPie", 1) : item.Get("action", ""), HK_NormalizeRequirement(item.Get("requirement", "")), item.Get("enabled", 1) ? "Yes" : "No")
        }
    }
    RefreshPieList()
    edFilter.OnEvent("Change", (*) => RefreshPieList())
    lv.OnEvent("DoubleClick", EditPieSlot)
    dlg.AddButton("xm y+" S(10) " w" S(80) " h" S(26), "Edit").OnEvent("Click", EditPieSlot)
    dlg.AddButton("x+" S(8) " yp w" S(80) " h" S(26), "Test").OnEvent("Click", ShowPieMenu.Bind(pieIndex))
    dlg.AddButton("x+" S(8) " yp w" S(80) " h" S(26), "Preview").OnEvent("Click", ShowPiePreview.Bind(pieIndex))
    dlg.AddButton("x+" S(8) " yp w" S(90) " h" S(26), "Reset").OnEvent("Click", ResetPieDefaults)
    dlg.AddButton("x+" S(8) " yp w" S(120) " h" S(26) " cFFFFFF", "Shortcut").OnEvent("Click", ShowCSPRecommended)
    dlg.AddButton("x+" S(8) " yp w" S(80) " h" S(26), "Close").OnEvent("Click", (*) => dlg.Destroy())

    EditPieSlot(*) {
        global PieItems, PieConfigs
        row := lv.GetNext()
        if !row
            return
        idx := _filteredIndices.Length >= row ? _filteredIndices[row] : row
        ApplyPieSlot(item) {
            PieItems[idx] := item
            PieConfigs[pieIndex] := PieItems
            SavePieItems()
            RefreshPieList()
        }
        result := PieSlotEditor(idx, PieItems[idx], ApplyPieSlot)
        if IsObject(result) {
            if !(HasProp(result, "_alreadyApplied") && result._alreadyApplied)
                ApplyPieSlot(result)
        }
    }
    ResetPieDefaults(*) {
        global PieItems, PieConfigs
        PieItems := PieDefaultConfig(pieIndex)
        PieConfigs[pieIndex] := PieItems
        SavePieItems()
        RefreshPieList()
    }
    dlg.Show("AutoSize")
}

ShowSubPieSettings(subPieIndex := 1, *) {
    global SubPieConfigs, SubPieNames
    subPieIndex := PieEnsureSubPie(subPieIndex)
    items := SubPieConfigs[subPieIndex]
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Sub Pie " subPieIndex " Settings")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(12)
    dlg.MarginY := S(12)
    dlg.AddText("xm cFFFFFF", "Hovering a sub-pie slot runs its shortcut/function after the configured delay.")
    dlg.AddText("xm y+" S(6) " cAAAAAA", "Filter:")
    edFilter := dlg.AddEdit("x+6 yp w" S(200) " h+21 c000000 BackgroundFFFFFF")
    dlg.AddText("x+8 yp c666666", "matches label, type, action, requirement")
    dlg.AddText("xm y+" S(10) " w" S(660) " h1 Background444444")
    dlg.AddText("xm y+" S(6) "", "Sub pie name:")
    nameEd := dlg.AddEdit("x+8 yp w" S(220) " c000000 BackgroundFFFFFF", SubPieNames.Length >= subPieIndex ? SubPieNames[subPieIndex] : SubPieDefaultName(subPieIndex))
    dlg.AddButton("x+" S(8) " yp w" S(70) " h" S(24), "Preview").OnEvent("Click", (*) => (ApplySubPieState(false), ShowSubPiePreview(subPieIndex)))
    dlg.AddButton("x+" S(6) " yp w" S(60) " h" S(24), "Test").OnEvent("Click", (*) => (ApplySubPieState(false), ShowSubPieMenu(subPieIndex)))
    lv := dlg.AddListView("xm y+" S(8) " w" S(660) " r10 Grid +Report +NoSortHdr", ["Slot", "Label", "Type", "Action", "Requirement", "Enabled"])
    lv.SetFont("s" S(9) " c000000", "Segoe UI")
    lv.ModifyCol(1, S(95))
    lv.ModifyCol(2, S(130))
    lv.ModifyCol(3, S(75))
    lv.ModifyCol(4, S(170))
    lv.ModifyCol(5, S(120))
    lv.ModifyCol(6, S(65))

    _filteredIndices := Array()
    RefreshSubPieList(*) {
        lv.Delete()
        Loop _filteredIndices.Length
            _filteredIndices.Pop()
        filter := Trim(edFilter.Value)
        for i, item in items {
            if filter != "" {
                haystack := PieSlotName(i) " " item.Get("label", "") " " item.Get("type", "disabled") " " (item.Get("type", "") = "submenu" ? "Sub Pie " item.Get("subPie", 1) : item.Get("type", "") = "nav" ? item.Get("action", "") : item.Get("action", "")) " " HK_NormalizeRequirement(item.Get("requirement", ""))
                if !InStr(haystack, filter)
                    continue
            }
            _filteredIndices.Push(i)
            lv.Add(, PieSlotName(i), item.Get("label", ""), item.Get("type", "disabled"), item.Get("type", "") = "submenu" ? "Sub Pie " item.Get("subPie", 1) : item.Get("type", "") = "nav" ? item.Get("action", "") : item.Get("action", ""), HK_NormalizeRequirement(item.Get("requirement", "")), item.Get("enabled", 1) ? "Yes" : "No")
        }
    }
    edFilter.OnEvent("Change", (*) => RefreshSubPieList())
    ApplySubPieState(save := true) {
        global SubPieNames, SubPieConfigs
        while SubPieNames.Length < subPieIndex
            SubPieNames.Push(SubPieDefaultName(SubPieNames.Length + 1))
        SubPieNames[subPieIndex] := Trim(nameEd.Value) != "" ? Trim(nameEd.Value) : SubPieDefaultName(subPieIndex)
        SubPieConfigs[subPieIndex] := items
        if save
            SavePieItems()
    }
    EditSubPieSlot(*) {
        row := lv.GetNext()
        if !row
            return
        idx := _filteredIndices.Length >= row ? _filteredIndices[row] : row
        ApplySubPieSlot(item) {
            items[idx] := item
            ApplySubPieState(true)
            RefreshSubPieList()
        }
        result := PieSlotEditor(idx, items[idx], ApplySubPieSlot)
        if IsObject(result) {
            if !(HasProp(result, "_alreadyApplied") && result._alreadyApplied)
                ApplySubPieSlot(result)
        }
    }
    ResetSubPie := (*) => (
        items := SubPieDefaultConfig(subPieIndex),
        ApplySubPieState(true),
        RefreshSubPieList()
    )
    NewSubPie(*) {
        ApplySubPieState(true)
        newIdx := PieAddSubPie()
        dlg.Destroy()
        ShowSubPieSettings(newIdx)
    }
    DeleteThisSubPie(*) {
        global SubPieConfigs, SubPieNames
        if SubPieConfigs.Length <= 1 {
            ShowNotify("Sub Pie", "Keep at least one sub pie.", "0xE53935")
            return
        }
        cDlg := Gui("+AlwaysOnTop +ToolWindow", "Delete Sub Pie")
        cDlg.BackColor := "1E1F22"
        cDlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
        cDlg.MarginX := S(14)
        cDlg.MarginY := S(14)
        cDlg.AddText("cFFD54F", "Delete Sub Pie " subPieIndex "?")
        cDlg.AddText("xm y+" S(4) " cAAAAAA", SubPieNames.Length >= subPieIndex ? SubPieNames[subPieIndex] : SubPieDefaultName(subPieIndex))
        cDlg.AddText("xm y+" S(4) " c888888", "Main pie slots that used it will be moved to the nearest remaining sub pie.")
        delResult := false
        cDlg.AddButton("xm y+10 w" S(80) " h" S(26) " cFFFFFF", "Yes").OnEvent("Click", (*) => (delResult := true, cDlg.Destroy()))
        cDlg.AddButton("x+8 yp w" S(80) " h" S(26), "No").OnEvent("Click", (*) => cDlg.Destroy())
        cDlg.Show("AutoSize")
        GuiWaitForCloseSafe(cDlg)
        if !delResult
            return
        if PieDeleteSubPie(subPieIndex) {
            nextIdx := Min(subPieIndex, SubPieConfigs.Length)
            dlg.Destroy()
            ShowSubPieSettings(nextIdx)
        }
    }
    RefreshSubPieList()
    lv.OnEvent("DoubleClick", EditSubPieSlot)
    dlg.AddButton("xm y+" S(10) " w" S(80) " h" S(26), "Edit").OnEvent("Click", EditSubPieSlot)
    dlg.AddButton("x+" S(8) " yp w" S(90) " h" S(26), "Reset").OnEvent("Click", ResetSubPie)
    dlg.AddButton("x+" S(8) " yp w" S(80) " h" S(26), "New").OnEvent("Click", NewSubPie)
    dlg.AddButton("x+" S(8) " yp w" S(80) " h" S(26), "Delete").OnEvent("Click", DeleteThisSubPie)
    dlg.AddButton("x+" S(8) " yp w" S(80) " h" S(26), "Save").OnEvent("Click", (*) => (ApplySubPieState(true), ShowNotify("Sub Pie", "Saved")))
    dlg.AddButton("x+" S(8) " yp w" S(80) " h" S(26), "Close").OnEvent("Click", (*) => (ApplySubPieState(true), dlg.Destroy()))
    dlg.Show("AutoSize")
}

ShowSubPiePreview(subPieIndex := 1, *) {
    global SubPieConfigs, SubPieNames
    subPieIndex := PieEnsureSubPie(subPieIndex)
    items := SubPieConfigs[subPieIndex]
    pieName := SubPieNames.Length >= subPieIndex ? SubPieNames[subPieIndex] : SubPieDefaultName(subPieIndex)
    PiePreviewWindow("Sub Pie " subPieIndex " Preview", pieName, items)
}

ShowPiePreview(pieIndex := 1, *) {
    global PieConfigs, PieNames, _pieStyle
    pieIndex := PieSafeInt(pieIndex, 1, 1, 4)
    if !PieIsEnabled(pieIndex)
        return
    items := PieConfigs[pieIndex]
    pieName := PieNames.Length >= pieIndex ? PieNames[pieIndex] : PieDefaultName(pieIndex)
    PiePreviewWindow("Pie " pieIndex " Preview", pieName, items)
}

PiePreviewWindow(title, pieName, items) {
    global _pieStyle
    dlg := Gui("+AlwaysOnTop +ToolWindow", title)
    dlg.BackColor := "1E1F22"
    dlg.MarginX := 0
    dlg.MarginY := 0
    w := PieS(460), h := PieS(360), slotW := PieS(118), slotH := PieS(34)
    if PieNormalizeStyle(_pieStyle) != "Normal" {
        slotW := PieS(96)
        slotH := PieS(24)
    }
    cx := w // 2, cy := h // 2
    dlg.SetFont("s" PieS(10) " Bold cFFFFFF", "Segoe UI")
    dlg.AddText("x" (cx - PieS(56)) " y" (cy - PieS(28)) " w" PieS(112) " h" PieS(28) " Center +0x200 Background242424 cFFFFFF", pieName)
    dlg.SetFont("s" PieS(7) " cAAAAAA", "Segoe UI")
    dlg.AddText("x" (cx - PieS(56)) " y+0 w" PieS(112) " h" PieS(20) " Center +0x200 Background242424 cAAAAAA", PieNormalizeStyle(_pieStyle) " preview")
    positions := PieLayoutPositions(w, h, slotW, slotH, _pieStyle)
    compactSideStyle := PieNormalizeStyle(_pieStyle) != "Normal"
    for i, item in items {
        if i > positions.Length
            break
        enabled := !!item.Get("enabled", 1) && item.Get("type", "disabled") != "disabled"
        c := enabled ? PieSafeColor(item.Get("color", "455A64")) : "555555"
        fc := ContrastColor(c)
        label := item.Get("label", PieSlotName(i))
        if label = ""
            label := PieSlotName(i)
        x := positions[i][1], y := positions[i][2]
        if compactSideStyle {
            dlg.SetFont("s" PieS(6) (enabled ? " Bold" : "") " c" fc, "Segoe UI")
            dlg.AddText("x" x " y" y " w" slotW " h" slotH " Center +0x200 Background" c " c" fc, label)
        } else {
            dlg.SetFont("s" PieS(5) " c" fc, "Segoe UI")
            dlg.AddText("x" x " y" y " w" slotW " h" PieS(11) " Center +0x200 Background" c " c" fc, PieSlotName(i))
            dlg.SetFont("s" PieS(7) (enabled ? " Bold" : "") " c" fc, "Segoe UI")
            dlg.AddText("x" x " y+" PieS(0) " w" slotW " h" PieS(22) " Center +0x200 Background" c " c" fc, label)
        }
        ; number / disabled badge
        badgeW := PieS(16), badgeH := PieS(13)
        keyLabel := PieSlotBadge(i, enabled, PieItemHasSubmenu(item))
        badge := dlg.AddText("x" x + slotW - badgeW + PieS(1) " y" y - PieS(1) " w" badgeW " h" badgeH " Center +0x200 BackgroundFFD54F c202020", keyLabel)
        badge.SetFont("s" PieS(7) " Bold", "Segoe UI")
    }
    dlg.SetFont("s" PieS(9) " cFFFFFF", "Segoe UI")
    dlg.AddButton("x" (cx - PieS(40)) " y" (h - PieS(32)) " w" PieS(80) " h" PieS(24), "Close").OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("w" w " h" h)
}

PieSlotEditor(idx, item, applyCallback := 0) {
    global SubPieConfigs, SubPieNames
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Edit Pie Slot - " PieSlotName(idx))
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(12)
    dlg.MarginY := S(12)
    px := S(105), ew := S(275)
    Header(title) {
        hdrText := dlg.AddText("xm y+" S(8) " cFFD54F", title)
        hdrLine := dlg.AddText("xm y+" S(2) " w" S(370) " h1 Background444444", "")
        return [hdrText, hdrLine]
    }

    commonHdr := Header("Common data")
    dlg.AddText("xm", "Label:")
    labelEd := dlg.AddEdit("x" px " yp w" ew " c000000 BackgroundFFFFFF", item.Get("label", ""))
    dlg.AddText("xm y+" S(8), "Type:")
    typeDd := dlg.AddDropDownList("x" px " yp w" ew, ["shortcut", "function", "script", "url", "submenu", "nav", "disabled"])
    t := item.Get("type", "disabled")
    typeDd.Value := t = "shortcut" ? 1 : t = "function" ? 2 : t = "script" ? 3 : t = "url" ? 4 : t = "submenu" ? 5 : t = "nav" ? 6 : 7
    dlg.AddText("xm y+" S(8), "Requirement:")
    reqEd := dlg.AddEdit("x" px " yp w" ew " c000000 BackgroundFFFFFF", HK_NormalizeRequirement(item.Get("requirement", "")))
    dlg.AddText("xm y+" S(4) " c888888 w" (px + ew), "Optional: Animation_autoaction.laf or Nastar.laf")
    dlg.AddText("xm y+" S(8), "Color:")
    colorEd := dlg.AddEdit("x" px " yp w" S(90) " c000000 BackgroundFFFFFF", PieSafeColor(item.Get("color", "455A64")))
    colorPreview := dlg.AddText("x+" S(6) " yp w" S(28) " h" S(22) " +0x200 Background" PieSafeColor(item.Get("color", "455A64")), "")
    dlg.AddText("x+" S(4) " yp w" S(18) " h" S(22) " +0x200 BackgroundE53935 cFFFFFF Center", "R").OnEvent("Click", (*) => PieSetEditorColor("E53935"))
    dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background0F9D58 cFFFFFF Center", "G").OnEvent("Click", (*) => PieSetEditorColor("0F9D58"))
    dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background4285F4 cFFFFFF Center", "B").OnEvent("Click", (*) => PieSetEditorColor("4285F4"))
    dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 BackgroundE39A2D cFFFFFF Center", "O").OnEvent("Click", (*) => PieSetEditorColor("E39A2D"))
    dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background9C27B0 cFFFFFF Center", "V").OnEvent("Click", (*) => PieSetEditorColor("9C27B0"))
    dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background00BCD4 cFFFFFF Center", "C").OnEvent("Click", (*) => PieSetEditorColor("00BCD4"))
    dlg.AddText("x+" S(2) " yp w" S(20) " h" S(22) " +0x200 Background607D8B cFFFFFF Center", "Gr").OnEvent("Click", (*) => PieSetEditorColor("607D8B"))
    enabledCb := dlg.AddCheckbox("xm y+" S(10) " cFFFFFF", "Enabled")
    enabledCb.Value := item.Get("enabled", 1)

    specialHdr := Header("Special data")
    subPieLbl := dlg.AddText("xm y+" S(8), "Sub pie:")
    subPieChoices := PieSubPieChoices()
    subPieDd := dlg.AddDropDownList("x" px " yp w" S(160), subPieChoices)
    subPieDd.Value := PieSafeInt(item.Get("subPie", 1), 1, 1, subPieChoices.Length)
    subPieSetBtn := dlg.AddButton("x+" S(8) " yp-1 w" S(107) " h" S(24), "Sub Pie Settings")
    navLbl := dlg.AddText("xm y+" S(8) " Hidden", "Nav action:")
    navDd := dlg.AddDropDownList("x" px " yp w" S(120) " Hidden", ["back", "close"])
    navAction := item.Get("type", "") = "nav" ? item.Get("action", "back") : "back"
    navDd.Value := navAction = "close" ? 2 : 1

    typeHdr := Header("Type data")
    actionLbl := dlg.AddText("xm y+" S(8), "Action:")
    actionEd := dlg.AddEdit("x" px " yp w" ew " c000000 BackgroundFFFFFF", item.Get("action", ""))
    actionRecBtn := dlg.AddButton("x" px " y+" S(4) " w" S(50) " h" S(24), "Rec")
    fnPickBtn := dlg.AddButton("x+" S(4) " yp w" S(50) " h" S(24), "Pick")
    browseBtn := dlg.AddButton("x+" S(4) " yp w" S(34) " h" S(24), "...")
    testBtn := dlg.AddButton("x+" S(4) " yp w" S(46) " h" S(24), "Test")
    actionDisplay := dlg.AddText("xm y+" S(1) " w" S(1) " h" S(1), "")
    actionHelp := dlg.AddText("xm y+" S(4) " c888888 w" S(365), "Shortcut: ^+!x. Function: ShowCSPGuide(). URL/script: target to open.")
    previewHdr := Header("Live preview")
    previewEd := dlg.AddEdit("xm y+" S(8) " w" S(365) " h" S(108) " ReadOnly -Wrap VScroll c000000 BackgroundFFFFFF", "")
    result := false

    typeDd.OnEvent("Change", (*) => ToggleSlotType())
    subPieSetBtn.OnEvent("Click", (*) => ShowSubPieSettings(subPieDd.Value))
    actionRecBtn.OnEvent("Click", (*) => HK_CaptureKey(dlg, actionEd, actionDisplay, actionRecBtn))
    fnPickBtn.OnEvent("Click", (*) => HK_FunctionPicker(actionEd))
    browseBtn.OnEvent("Click", BrowsePieScriptPath)
    testBtn.OnEvent("Click", (*) => PieTestEditorItem(typeDd.Text, typeDd.Text = "submenu" ? "" : typeDd.Text = "nav" ? navDd.Text : actionEd.Value, labelEd.Value, HK_NormalizeRequirement(reqEd.Value), subPieDd.Value))

    ToggleSlotType() {
        t := typeDd.Text
        isSub := t = "submenu"
        isScript := t = "script"
        isUrl := t = "url"
        isDisabled := t = "disabled"
        isNav := t = "nav"
        hasSpecial := isSub || isNav
        actionLbl.Text := isSub ? "Pie:" : t = "url" ? "URL / Link:" : isScript ? "Script path:" : "Action:"
        actionHelp.Text := isSub
            ? "Select a sub-pie from the dropdown below."
            : t = "url"
                ? "Paste a URL, for example https://example.com"
                : isScript
                    ? "Choose an .ahk/.exe/.bat/.cmd/.ps1 file, or type a path manually."
                : isNav
                    ? "Navigation actions for sub-pie control."
                    : "Shortcut: ^+!x. Function: ShowCSPGuide(). URL/script: target to open."
        for ctrl in specialHdr
            ctrl.Visible := hasSpecial
        subPieLbl.Visible := isSub
        subPieDd.Visible := isSub
        subPieSetBtn.Visible := isSub
        actionLbl.Visible := !isDisabled && !isNav
        actionEd.Visible := !isDisabled && !isNav
        actionRecBtn.Visible := !isDisabled && !isNav
        fnPickBtn.Visible := !isDisabled && !isNav
        browseBtn.Visible := !isDisabled && !isNav
        testBtn.Visible := !isDisabled && !isNav
        actionDisplay.Visible := !isDisabled && !isNav
        actionHelp.Visible := !isDisabled && !isNav
        navLbl.Visible := isNav
        navDd.Visible := isNav
        actionRecBtn.Enabled := t = "shortcut"
        fnPickBtn.Enabled := t = "function"
        browseBtn.Enabled := isScript || isUrl
        testBtn.Enabled := !isDisabled
        actionEd.Enabled := t = "shortcut" || t = "function" || t = "url" || t = "script"
        reqEd.Enabled := !isDisabled
        UpdatePieSlotPreview()
        dlg.Show("AutoSize")
    }

    UpdatePieSlotPreview(*) {
        actionVal := typeDd.Text = "submenu" ? "" : typeDd.Text = "nav" ? navDd.Text : actionEd.Value
        previewEd.Value := PieEditorActionSummary(typeDd.Text, actionVal, labelEd.Value, reqEd.Value, subPieDd.Value, enabledCb.Value)
    }

    BrowsePieScriptPath(*) {
        if typeDd.Text = "url" {
            urlDlg := Gui("+AlwaysOnTop +ToolWindow", "Pie Slot URL")
            urlDlg.BackColor := "1E1F22"
            urlDlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
            urlDlg.MarginX := S(12)
            urlDlg.MarginY := S(12)
            urlDlg.AddText("xm", "URL / Link:")
            urlEd := urlDlg.AddEdit("x" S(80) " yp w" S(340) " c000000 BackgroundFFFFFF", actionEd.Value)
            urlDlg.AddText("xm y+" S(4) " c888888", "Enter a URL, for example https://example.com")
            urlResult := ""
            urlDlg.AddButton("xm y+" S(12) " w" S(80) " h" S(26) " Default", "OK").OnEvent("Click", (*) => (urlResult := Trim(urlEd.Value), urlDlg.Destroy()))
            urlDlg.AddButton("x+" S(8) " yp w" S(80) " h" S(26), "Cancel").OnEvent("Click", (*) => urlDlg.Destroy())
            urlDlg.Show("AutoSize")
            GuiWaitForCloseSafe(urlDlg)
            if urlResult != ""
                actionEd.Value := urlResult
            return
        }
        startPath := Trim(actionEd.Value)
        if startPath = "" || !FileExist(startPath)
            startPath := A_ScriptDir
        picked := FileSelect("3", startPath, "Select Pie Script / App", "Scripts and Apps (*.ahk; *.exe; *.bat; *.cmd; *.ps1)")
        if picked != ""
            actionEd.Value := picked
    }

    BuildPieSlotResult() {
        t := typeDd.Text
        action := Trim(actionEd.Value)
        if (t = "shortcut" || t = "action") && action != ""
            action := PieQuickNormalizeShortcutAction(action)
        if t = "url" && action = "" {
            _HK_ResultPopup("Pie URL", "Please enter the link/URL for this pie slot.", "E53935")
            actionEd.Focus()
            return 0
        }
        if t = "script" && action = "" {
            _HK_ResultPopup("Pie Script Path", "Please enter or browse the script/app path for this pie slot.", "E53935")
            actionEd.Focus()
            return 0
        }
        navAction := t = "nav" ? navDd.Text : ""
        return Map("slot", idx, "label", labelEd.Value, "type", t, "action", t = "submenu" ? "" : t = "nav" ? navAction : action, "requirement", HK_NormalizeRequirement(reqEd.Value), "color", PieSafeColor(colorEd.Value), "enabled", enabledCb.Value, "subPie", subPieDd.Value)
    }

    SavePieSlot(*) {
        built := BuildPieSlotResult()
        if !IsObject(built)
            return
        built["_alreadyApplied"] := IsObject(applyCallback)
        if IsObject(applyCallback)
            applyCallback(built)
        result := built
        dlg.Destroy()
    }

    ApplyPieSlotNow(*) {
        built := BuildPieSlotResult()
        if !IsObject(built)
            return
        if IsObject(applyCallback) {
            applyCallback(built)
            ShowNotify("Pie Slot", "Applied")
        }
    }

    PieSetEditorColor(color) {
        colorEd.Value := color
        PieUpdateEditorColorPreview()
        colorEd.Focus()
    }

    PieUpdateEditorColorPreview(*) {
        c := RegExReplace(RegExReplace(Trim(colorEd.Value), "i)^(#|0x)", ""), "[^0-9A-Fa-f]", "")
        if RegExMatch(c, "i)^[0-9A-F]{1,6}$") {
            while StrLen(c) < 6
                c .= "0"
            c := StrUpper(c)
            colorPreview.Opt("Background" c)
            colorPreview.Redraw()
        }
    }

    colorEd.OnEvent("Change", PieUpdateEditorColorPreview)
    typeDd.OnEvent("Change", UpdatePieSlotPreview)
    labelEd.OnEvent("Change", UpdatePieSlotPreview)
    actionEd.OnEvent("Change", UpdatePieSlotPreview)
    reqEd.OnEvent("Change", UpdatePieSlotPreview)
    subPieDd.OnEvent("Change", UpdatePieSlotPreview)
    navDd.OnEvent("Change", UpdatePieSlotPreview)
    enabledCb.OnEvent("Click", UpdatePieSlotPreview)
    PieUpdateEditorColorPreview()
    UpdatePieSlotPreview()

    dlg.AddButton("xm y+" S(12) " w" S(80) " h" S(26) " Default", "Save").OnEvent("Click", SavePieSlot)
    if IsObject(applyCallback)
        dlg.AddButton("x+" S(8) " yp w" S(80) " h" S(26), "Apply").OnEvent("Click", ApplyPieSlotNow)
    dlg.AddButton("x+" S(8) " yp w" S(80) " h" S(26), "Cancel").OnEvent("Click", (*) => dlg.Destroy())
    dlg.AddButton("x+" S(12) " yp w" S(95) " h" S(26) " c9C27B0", "❓ Keys Guide").OnEvent("Click", (*) => ShowKeysGuide())
    ToggleSlotType()
    dlg.Show("AutoSize")
    GuiWaitForCloseSafe(dlg)
    return result
}

PositionLinkGUI() {
    global LinkGUI, LinkGUI_X, LinkGUI_Y, Link_Opacity
    if !FeatureEnabled("linkgui")
        return
    try if !LinkGUI.Hwnd
        return
    try if !LinkGUI._ready
        return
    LinkGUI.GetPos(,, &w, &h)
    LinkGUI.Show("x" LinkGUI_X " y" LinkGUI_Y " NoActivate")
    LinkRefreshLayout()
    try _ZFixGUI(LinkGUI)
    if Link_Opacity < 255
        WinSetTransparent(Link_Opacity, LinkGUI)
}

; ============================================================
