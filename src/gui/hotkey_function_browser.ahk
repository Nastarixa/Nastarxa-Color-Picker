; GUI - Hotkey Function Browser
; ============================================================

; The full-tree function scan is cached because the user-script execution path
; calls it before every launch. The signature covers every input that changes
; the result: the main script, the hotkey settings INI (user-script disabled
; state), and the user_hotkey_scripts files. src/ includes are static for a
; process run, so they are not part of the signature.
global _HK_ScanCache := 0
global _HK_ScanCacheSig := ""

HK_ScanScriptSig() {
    global HK_UserScriptDir
    sig := A_ScriptFullPath ":" (FileExist(A_ScriptFullPath) ? FileGetTime(A_ScriptFullPath, "M") : "0")
    ini := HK_UserScriptsIni()
    sig .= "|" ini ":" (FileExist(ini) ? FileGetTime(ini, "M") : "0")
    if DirExist(HK_UserScriptDir)
        Loop Files HK_UserScriptDir "\*.ahk", "F"
            sig .= "|" A_LoopFileFullPath ":" FileGetTime(A_LoopFileFullPath, "M")
    return sig
}

HK_ScanScriptFunctions() {
    global HK_UserScriptDir, _HK_ScanCache, _HK_ScanCacheSig
    sig := HK_ScanScriptSig()
    if IsObject(_HK_ScanCache) && _HK_ScanCacheSig = sig
        return _HK_ScanCache
    result := Map()
    seenFiles := Map()
    keywordBlocklist := "if|for|while|switch|try|catch|else|global|static|local|return|class|throw|break|continue|case|default|until|loop|and|or|not|new|super|this|true|false|each|in|is|has|method|property|get|set"
    scanFiles := [A_ScriptFullPath]
    mainScript := FileRead(A_ScriptFullPath, "UTF-8")
    for line in StrSplit(mainScript, "`n", "`r") {
        if RegExMatch(line, "i)^\s*#Include\s+(.+?)(?:\s|$)", &m) {
            incPath := m[1]
            incPath := RegExReplace(incPath, "^\x22|\x22$")
            incPath := RegExReplace(incPath, "^<|>$")
            if !(SubStr(incPath, 2, 1) = ":")
                incPath := A_ScriptDir "\" incPath
            scanFiles.Push(incPath)
        }
    }
    if DirExist(HK_UserScriptDir) {
        Loop Files HK_UserScriptDir "\*.ahk", "F" {
            if HK_UserScriptDisabled(A_LoopFileFullPath)
                continue
            scanFiles.Push(A_LoopFileFullPath)
        }
    }
    for filePath in scanFiles {
        fullPath := HK_ResolveExistingPath(filePath)
        if fullPath = "" || !FileExist(fullPath)
            continue
        keyPath := StrLower(fullPath)
        if seenFiles.Has(keyPath)
            continue
        seenFiles[keyPath] := true
        content := FileRead(fullPath, "UTF-8")
        if content = ""
            continue
        pos := 1
        contentLen := StrLen(content)
        while pos <= contentLen {
            startMatch := RegExMatch(content, "m)^[\t ]*([A-Za-z_]\w*)\s*\(", &m, pos)
            if !startMatch
                break
            fnName := m[1]
            openPos := m.Pos + m.Len - 1
            pos := openPos + 1
            if fnName ~= "^(?:" . keywordBlocklist . ")$"
                continue
            depth := 1
            closePos := 0
            scan := openPos + 1
            while scan <= contentLen && depth > 0 {
                char := SubStr(content, scan, 1)
                if char = "("
                    depth++
                else if char = ")"
                    depth--
                if depth = 0
                    closePos := scan
                scan++
            }
            if !closePos
                continue
            afterParen := Trim(SubStr(content, closePos + 1, 10))
            if afterParen = "" {
                restLines := StrSplit(SubStr(content, closePos + 1), "`n", "`r")
                afterParen := ""
                for rl in restLines {
                    trimmed := Trim(rl)
                    if trimmed != "" {
                        afterParen := trimmed
                        break
                    }
                }
            }
            if RegExMatch(afterParen, "^\s*(\{|=>)") {
                if !result.Has(fnName)
                    result[fnName] := fullPath
            }
            pos := closePos + 1
        }
    }
    _HK_ScanCache := result
    _HK_ScanCacheSig := sig
    return result
}

HK_ResolveExistingPath(path) {
    path := Trim(path)
    if path = ""
        return ""
    Loop Files path, "F"
        return A_LoopFileFullPath
    return path
}

HK_IsUserLibraryFunctionPath(path) {
    global HK_UserScriptDir
    path := Trim(path)
    if path = ""
        return false
    libDir := HK_ResolveExistingPath(HK_UserScriptDir)
    libDir := RTrim(StrLower(libDir), "\/")
    fullPath := RTrim(StrLower(HK_ResolveExistingPath(path)), "\/")
    return libDir != "" && InStr(fullPath, libDir "\") = 1
}

HK_FunctionChoices() {
    global HotkeyDefs
    choices := []
    seen := Map()
    AddChoice(name) {
        name := Trim(name)
        if name = ""
            return
        key := StrLower(name)
        if seen.Has(key)
            return
        seen[key] := true
        choices.Push(name)
    }
    for name in [
        "ShowCSPGuide", "ShowCSPRecommended", "FirstRunWizard",
        "ShowHotkeySettings", "ShowLTSettings", "ShowGuiSetting",
        "ShowStatusDashboard", "ShowSettingsHealth", "ShowCSPSetupValidator",
        "ShowBrokenActionScanner", "ShowConfigDoctor", "ShowTypingSafeguardInspector",
        "ShowTypingTitleEditor",
        "ShowLinkManager", "ShowDebugGUI",
        "ShowPieOven", "ShowUserFunctionLibrary", "ShowMainGUI",
        "ShowFeatureSwitcher", "ShowFeatureSwitcherInfo",
        "SafeMode", "ToggleMainWindow", "ToggleInbetweenMode",
        "ToggleAutoSave", "ToggleNav", "ShowPieSettings(1)",
        "ShowPieSettings(2)", "ShowPieSettings(3)", "ShowPieSettings(4)"
    ]
        AddChoice(name)
    for d in HotkeyDefs {
        try {
            fnName := HK_GetFnName(d)
            if fnName != "(inline)"
                AddChoice(fnName)
        }
    }
    scanned := HK_ScanScriptFunctions()
    for fnName in scanned
        AddChoice(fnName)
    sorted := ""
    for c in choices
        sorted .= c "`n"
    sorted := Sort(sorted)
    choices := StrSplit(Trim(sorted, "`n"), "`n")
    return choices
}

HK_FunctionCatalog() {
    global HotkeyDefs
    builtins := Map()
    for name in [
        "ShowCSPGuide", "ShowCSPRecommended", "FirstRunWizard",
        "ShowHotkeySettings", "ShowLTSettings", "ShowGuiSetting",
        "ShowStatusDashboard", "ShowSettingsHealth", "ShowCSPSetupValidator",
        "ShowBrokenActionScanner", "ShowConfigDoctor", "ShowTypingSafeguardInspector",
        "ShowTypingTitleEditor",
        "ShowLinkManager", "ShowDebugGUI",
        "ShowPieOven", "ShowUserFunctionLibrary", "ShowMainGUI",
        "ShowFeatureSwitcher", "ShowFeatureSwitcherInfo",
        "SafeMode", "ToggleMainWindow", "ToggleInbetweenMode",
        "ToggleAutoSave", "ToggleNav", "ShowPieSettings(1)",
        "ShowPieSettings(2)", "ShowPieSettings(3)", "ShowPieSettings(4)"
    ]
        builtins[name] := true

    defs := Map()
    for d in HotkeyDefs {
        try {
            fnName := HK_GetFnName(d)
            if fnName != "" && fnName != "(inline)" && !defs.Has(fnName)
                defs[fnName] := d.desc
        }
    }

    scanned := HK_ScanScriptFunctions()
    names := HK_FunctionChoices()
    catalog := []
    for _, name in names {
        row := Map("name", name, "source", "Runtime", "detail", "")
        if builtins.Has(name) {
            row["source"] := "Built-in"
            row["detail"] := "Toolkit runtime"
        } else if scanned.Has(name) {
            row["source"] := HK_IsUserLibraryFunctionPath(scanned[name]) ? "User Script" : "Built-in"
            row["detail"] := scanned[name]
        } else if defs.Has(name) {
            row["source"] := "Hotkey Action"
            row["detail"] := defs[name]
        }
        row["category"] := HK_FunctionCategory(row["name"], row["source"], row["detail"])
        row["summary"] := HK_FunctionSummary(row["name"], row["source"], row["detail"])
        row["risk"] := HK_FunctionRiskBadges(row["name"], row["source"], row["detail"])
        row["usedBy"] := HK_FunctionUsedBy(row["name"])
        if row["source"] = "User Script" {
            usrMeta := HK_UserScriptMetadata(row["detail"])
            if usrMeta.Has("summary")
                row["summary"] := usrMeta["summary"]
            if usrMeta.Has("category")
                row["category"] := usrMeta["category"]
            if usrMeta.Has("risk") {
                items := []
                for part in StrSplit(usrMeta["risk"], ["|", ","]) {
                    item := Trim(part)
                    if item != ""
                        items.Push(item)
                }
                row["risk"] := HK_BadgeJoin(items)
            }
        }
        catalog.Push(row)
    }
    return catalog
}

HK_FunctionIsInternal(row) {
    if !IsObject(row)
        return false
    name := row.Get("name", "")
    source := row.Get("source", "")
    detail := row.Get("detail", "")
    summary := row.Get("summary", "")
    if SubStr(name, 1, 1) = "_"
        return true
    if source = "Built-in" && (
        InStr(summary, "Internal ")
        || InStr(summary, "Core runtime helper")
        || InStr(summary, "Settings persistence helper")
        || InStr(summary, "Hotkey engine helper")
        || InStr(summary, "Guide-content helper")
        || InStr(summary, "normalize or safeguards toolkit data")
    )
        return true
    if source = "Built-in" && detail != "" && detail != "Toolkit runtime" {
        lname := StrLower(name)
        if RegExMatch(lname, "i)^(ini|normalize|ensure|compact|migrate|cleanup|check|savegui|loadgui|saveconfigurable|loadconfigurable)")
            return true
    }
    return false
}

HK_FunctionDefDescription(name) {
    global HotkeyDefs
    clean := RegExReplace(Trim(name), "\(\)$", "")
    for d in HotkeyDefs {
        try fnName := HK_GetFnName(d)
        catch
            continue
        if fnName = clean || fnName = clean "()"
            return d.desc
    }
    return ""
}

HK_FunctionDefRequirement(name) {
    global HotkeyDefs
    clean := RegExReplace(Trim(name), "\(\)$", "")
    for d in HotkeyDefs {
        try fnName := HK_GetFnName(d)
        catch
            continue
        if fnName = clean || fnName = clean "()"
            return HK_GetRequirement(d)
    }
    return ""
}

HK_BadgeJoin(items) {
    txt := ""
    seen := Map()
    for item in items {
        item := Trim(item)
        if item = ""
            continue
        key := StrLower(item)
        if seen.Has(key)
            continue
        seen[key] := true
        txt .= (txt = "" ? "" : " | ") item
    }
    return txt = "" ? "Safe" : txt
}

HK_FunctionRiskBadges(name, source := "", detail := "", requirement := "", actionType := "") {
    clean := RegExReplace(Trim(name), "\(\)$", "")
    req := HK_NormalizeRequirement(requirement != "" ? requirement : HK_FunctionDefRequirement(clean))
    badges := []
    if req = REQ_ANIM
        badges.Push("Needs Animation_autoaction")
    else if req = REQ_NASTAR
        badges.Push("Needs Nastar")
    else if req != ""
        badges.Push("Needs " req)

    if actionType = "script" || actionType = "url"
        badges.Push("External Target")
    else if actionType = "submenu"
        badges.Push("Submenu")
    else if actionType = "nav"
        badges.Push("Navigation")

    if source = "User Script"
        badges.Push("User Script")
    if SubStr(clean, 1, 1) = "_"
        badges.Push("Internal")

    lname := StrLower(clean)
    ldetail := StrLower(detail)
    if actionType = "shortcut"
        badges.Push("Needs CSP")
    if RegExMatch(lname, "i)(hotkey|sendcolor|dolayer|resetlt|isltactive|selectib|togglelt|toggleonion|spacenav|capslock)")
        badges.Push("Needs CSP")
    if RegExMatch(lname, "i)(save|export|backup|restore|capture|savetxt|savepng|savedebuglog|timerload)")
        badges.Push("Writes Files")
    if RegExMatch(lname, "i)(load|import|parse|checkini|migrate|compact|ensure|config|backup|restore)")
        badges.Push("Settings I/O")
    if RegExMatch(lname, "i)(show|toggle|update|refresh|rebuild|render|redraw|position|creategui|create|hover|picker|browser)")
        badges.Push("UI")
    if InStr(ldetail, "\gui\")
        badges.Push("UI")
    return HK_BadgeJoin(badges)
}

HK_HotkeyFunctionSummary(name) {
    clean := RegExReplace(Trim(name), "\(\)$", "")
    desc := HK_FunctionDefDescription(clean)
    static info := 0
    if !IsObject(info) {
        info := Map()
        info["HotkeyIB1"] := "Apply the currently selected inbetween preset from the IB bar."
        info["HotkeyIB2"] := "Activate inbetween preset 50."
        info["HotkeyIB3"] := "Activate inbetween preset 33 End > Start / 66 Start > End."
        info["HotkeyIB4"] := "Activate inbetween preset 66 End > Start / 33 Start > End."
        info["HotkeyIB5"] := "Activate inbetween preset 25 End > Start / 75 Start > End."
        info["HotkeyIB6"] := "Activate inbetween preset 75 End > Start / 25 Start > End."
        info["HotkeyIB7"] := "Activate inbetween preset 40 End > Start / 60 Start > End."
        info["HotkeyIB8"] := "Activate inbetween preset 60 End > Start / 40 Start > End."
        info["HotkeyIBEmpty"] := "Toggle Light Table without using inbetween preset."
        info["HotkeyChangeColor"] := "Change LT Image 1 and LT Image 3 layer colors to the saved half-color green and purple setup."
        info["HotkeyToggleOnion"] := "Toggle onion-skin state and show toolkit feedback."
        info["HotkeyToggleLT"] := "Toggle light table state and show toolkit feedback."
        info["HotkeySwapBrush"] := "Toggle between primary and secondary brush color states."
        info["HotkeyToggleTransparent"] := "Toggle the brush between transparent and solid drawing mode."
        info["HotkeySelectNextCel"] := "If LT is active, reset LT, wait briefly, then send Alt+D to move to the next cel."
        info["HotkeySelectPrevCel"] := "If LT is active, reset LT, wait briefly, then send Alt+A to move to the previous cel."
        info["HotkeySelectNextLTCel"] := "Only when LT is active, send Alt+D to move to the next light-table cel."
        info["HotkeySelectPrevLTCel"] := "Only when LT is active, send Alt+A to move to the previous light-table cel."
        info["SendCleanAltKey"] := "Release Ctrl/Shift/Alt, then send a clean Alt+key press to avoid stuck modifiers."
        info["HotkeySendShortcut"] := "Internal helper that sends the requested shortcut through the CSP-focused send path when sendKeys is enabled."
        info["HotkeyFeatureRemoveLayerColor"] := "Remove or change palette color to transparent."
        info["HotkeyFeatureReferenceColor"] := "Change palette color to orange Reference."
        info["HotkeyFeatureKeyframeColor"] := "Change palette color to red Keyframe."
        info["HotkeyFeatureNormalColor"] := "Change lighttable layer color to normal color."
        info["HotkeyTransferRasterize"] := "Transfer solid color from selected layer to layer below while preserve layer setting but change vector layer to raster layer."
        info["HotkeyTransferVector"] := "Transfer solid color from selected layer to layer below while preserve layer setting."
        info["HotkeyInsertOnionToLTCell"] := "Insert cell to lighttable cell using onion as reference."
        info["HotkeyVectorPaths"] := "Activate CSP, send Ctrl+Shift+Alt+[ and Ctrl+Shift+Alt+], then show the Vector Paths notification."
        info["HotkeyCreatePaperLayer"] := "Create Paper Layer."
        info["HotkeyCreateRasterLayer"] := "Create New Raster Layer."
        info["HotkeyCreateVectorLayer"] := "Create New Vector Layer."
        info["HotkeyCreateColoredVectorLayer"] := "Create New Vector Layer for each Pink, Cyan, Orange, and Purple layer color."
        info["HotkeyCreateDummyLayer"] := "Create New Vector Layer as Draft Layer."
        info["HotkeyCreatePinkVectorLayer"] := "Create New Vector Layer with Pink layer color."
        info["HotkeyCreateCyanVectorLayer"] := "Create New Vector Layer with Cyan layer color."
        info["HotkeyCreateOrangeVectorLayer"] := "Create New Vector Layer with Orange layer color."
        info["HotkeyCreateAnimationFolder"] := "Create Animation Folder."
        info["HotkeyFeatureHalfGreen"] := "Change the Lighttable cel layer color to Half Green."
        info["HotkeyFeatureHalfPurple"] := "Change the Lighttable cel layer color to Half Purple."
        info["HotkeyFeaturePaperPurple"] := "Change layer color of Paper or çº¸å¼  to purple."
        info["HotkeyFeaturePaperGreen"] := "Change layer color of Paper or çº¸å¼  to green."
        info["HotkeyFeaturePaperWhite"] := "Change layer color of Paper or çº¸å¼  to white."
        info["HotkeyFeatureLayerColorBlack"] := "Change the layer color to black."
        info["HotkeyLayerBlack"] := "Select layer with name Black."
        info["HotkeyLayerRed"] := "Select layer with name Red."
        info["HotkeyLayerBlue"] := "Select layer with name Blue."
        info["HotkeyLayerGreen"] := "Select layer with name Green."
        info["HotkeyLayerPink"] := "Select layer with name Pink."
        info["HotkeyLayerCyan"] := "Select layer with name Cyan."
        info["HotkeyLayerOrange"] := "Select layer with name Orange."
        info["HotkeyLayerUranuri"] := "Select layer with name Uranuri or Shadow."
        info["HotkeyLayerPaint"] := "Select layer with name Paint."
        info["HotkeyLayerRough"] := "Select layer with name Rough, Sketch, or Dummy."
        info["HotkeyLayerSelect2"] := "Select second layer (Shift+2). Same key as Layer: Red but with numbered notification."
        info["HotkeyLayerSelect3"] := "Select third layer (Shift+3). Same key as Layer: Blue but with numbered notification."
        info["HotkeyLayerSelect4"] := "Select fourth layer (Shift+4). Same key as Layer: Green but with numbered notification."
        info["HotkeyLayerSelect5"] := "Select fifth layer (Shift+5). Same key as Layer: Pink but with numbered notification."
        info["HotkeyLayerSelect6"] := "Select sixth layer (Shift+6). Same key as Layer: Cyan but with numbered notification."
        info["HotkeyLayerSelect7"] := "Select seventh layer (Shift+7). Same key as Layer: Orange but with numbered notification."
        info["HotkeyLayerSelect8"] := "Select eighth layer (Shift+8). Same key as Layer: Uranuri but with numbered notification."
        info["HotkeyLayerSelect9"] := "Select ninth layer (Shift+9). Same key as Layer: Paint but with numbered notification."
        info["HotkeyLayerSelect10"] := "Select tenth layer (Shift+0). Same key as Layer: Rough but with numbered notification."
        info["HotkeySeparateBlackLine"] := "Isolate black line colors (RGB 0,0,0 and 1,1,1) from the image and create a mask for coloring."
        info["HotkeyLayerUp"] := "Move layer to Up."
        info["HotkeyLayerDown"] := "Move layer to Down."
        info["HotkeyTopLayer"] := "Select layer above of current layer."
        info["HotkeyBottomLayer"] := "Select layer below of current layer."
        info["HotkeyMergeDownLayer"] := "Merge down selected layer to layer below and destroy the layer setting."
        info["HotkeyColorExpressionGray"] := "Change color expression to gray with no sub layer color."
        info["HotkeyDeleteLayer"] := "Delete selected layer."
        info["HotkeyDeletePaintChecker"] := "Delete Paint Checker. Used as B action on Paint Check: Layer and Paint Checker: Image."
        info["HotkeyDeleteCelTimeline"] := "Delete selected cel from timeline without delete main layer."
        info["HotkeyDeleteCelLighttable"] := "Delete selected cel in light table."
        info["HotkeyDuplicateLayer"] := "Make perfect duplicate of selected layer."
        info["HotkeyCreateFolderInsertLayer"] := "Make folder and group selected layer as pack."
        info["HotkeyUngroupLayerFolder"] := "Unpack the group and delete group folder."
        info["HotkeyOpacity100"] := "Set Layer Opacity to 100."
        info["HotkeyOpacity50"] := "Set Layer Opacity to 50."
        info["HotkeyOpacity25"] := "Set Layer Opacity to 25."
        info["HotkeyToggleLayerColor"] := "Toggle layer from normal color to layer color."
        info["HotkeyOpenFolder"] := "Open current selected Folder."
        info["HotkeyCloseAllFolder"] := "Close All Opened Folder in file."
        info["HotkeyUltimateSaveAs"] := "Close all folders, change paper color to white, then open Save As."
        info["HotkeyToggleDraft"] := "Toggle the visibility of all Draft Layer."
        info["HotkeyDraftLayer"] := "Toggle layer to draft layer mode."
        info["HotkeyIsolateLayer"] := "Toggle Layer view isolation."
        info["HotkeyColorPicker"] := "Pick Screen Color with Activate CSP first."
        info["HotkeyResetColor"] := "Reset primary color to Black 0.0.0 and secondary color to White 255.255.255."
        info["HotkeyLockAnimationCel"] := "Lock Animation Cel target from changing."
        info["HotkeyLockTransparent"] := "Lock Layer Transparent to draw within solid draw."
        info["HotkeyLockLayer"] := "Lock Layer from editing."
        info["HotkeyClipToLayerBelow"] := "Clip layer to affect solid draw on layer below."
        info["HotkeyReferenceLayer"] := "Toggle layer to reference layer mode."
        info["HotkeyPaintTransparent"] := "Fill transparent and white 255.255.255 with primary color."
        info["HotkeyPaintRedLine"] := "Fill red line 255.0.0 with primary color."
        info["HotkeyPaintGreenLine"] := "Fill green line 0.255.0 with primary color."
        info["HotkeyPaintBlueLine"] := "Fill Blue line 0.0.255 with primary color."
        info["HotkeyPaintPinkLine"] := "Fill Pink line 255.0.255 with primary color."
        info["HotkeyPaintCyanLine"] := "Fill Cyan line 0.255.255 with primary color."
        info["HotkeyPaintOrangeLine"] := "Fill Orange line 255.128.0 with primary color."
        info["HotkeyPaintPurpleLine"] := "Fill Purple line 128.0.255 with primary color."
        info["HotkeySetToPaintAnimation"] := "Setup the layer folder for ready to paint."
        info["HotkeySetCelsToTrack"] := "Insert the layers to cels track in the timeline. Sends Ctrl+Shift+Alt+PageUp."
        info["HotkeyPaintCheckerLayer"] := "Paint Check: Layer. Sends Ctrl+Shift+Alt+End."
        info["HotkeyPaintCheckerImage"] := "Run the image paint-check helper with Ctrl+Shift+Alt+Home."
        info["HotkeyOpenPie1"] := "Open Pie Menu 1 while holding CapsLock."
        info["HotkeyOpenPie2"] := "Open Pie Menu 2 while holding CapsLock."
        info["HotkeyOpenPie3"] := "Open Pie Menu 3 while holding CapsLock."
    }
    if info.Has(clean)
        return info[clean]
    if clean ~= "i)Notify$" && desc != ""
        return "Show the toolkit notification for " . desc . " without running a longer action flow."
    if clean ~= "i)^HotkeySelect.*Line" && desc != ""
        return "Send the CSP selection shortcut for " . desc . "."
    if clean ~= "i)^HotkeySelectTransparent" && desc != ""
        return "Send the CSP selection shortcut for transparent pixels."
    if clean ~= "i)^HotkeyDeselect"
        return "Clear the current selection and show toolkit feedback."
    if clean ~= "i)^HotkeyLayer" && desc != ""
        return "Select the saved " . desc . " layer target through the toolkit layer-color workflow."
    if clean ~= "i)^HotkeyCreate" && desc != ""
        return "Send the shortcut for " . desc . " and show the matching toolkit notification."
    if clean ~= "i)^HotkeyOpacity" && desc != ""
        return "Set the current layer opacity using the toolkit shortcut for " . desc . "."
    if clean ~= "i)^HotkeyFeature" && desc != ""
        return "Send the built-in feature shortcut for " . desc . " and show toolkit feedback."
    if clean ~= "i)^HotkeyPaintChecker" && desc != ""
        return "Show the paint-checker indicator for " . desc . "."
    if clean ~= "i)^HotkeyPaintCheckerImage$"
        return "Run the image paint-check helper with Ctrl+Shift+Alt+Home."
    if clean ~= "i)^HotkeyPaintCheckerLayer$"
        return "Run the layer paint-check helper with Ctrl+Shift+Alt+End."
    if clean ~= "i)^HotkeyPaint" && desc != ""
        return "Run the paint-target action for " . desc . " and show toolkit feedback."
    if clean ~= "i)^HotkeySeparate" && desc != ""
        return "Run the separate-and-paint workflow for " . desc . "."
    if clean ~= "i)^HotkeySelect" && desc != ""
        return "Run the toolkit selection action for " . desc . "."
    if clean ~= "i)^Hotkey(Open|Close).*Folder" && desc != ""
        return "Run the folder visibility action for " . desc . "."
    if clean ~= "i)^Hotkey(Merge|Transfer|Rasterize)" && desc != ""
        return "Run the layer-transfer workflow for " . desc . "."
    if clean ~= "i)^HotkeyIB" && desc != ""
        return "Run the inbetween-bar action for " . desc . "."
    if desc != ""
        return "Run the built-in hotkey action for " . desc . "."
    return ""
}

HK_BuiltInHelperSummary(name, detail := "") {
    clean := RegExReplace(Trim(name), "\(\)$", "")
    ldetail := StrLower(detail)
    static info := 0
    if !IsObject(info) {
        info := Map()
        info["_DebugToggleFilter"] := "Toggle one debug severity filter in the Debug Log window."
        info["_DebugRefresh"] := "Refresh the Debug Log window without reopening it."
        info["_DebugAutoRefresh"] := "Auto-refresh the Debug Log while the window stays open."
        info["_DebugSave"] := "Save the current Debug Log contents to disk."
        info["_DebugSaveOnExitToggle"] := "Toggle whether the Debug Log is saved automatically when the toolkit exits."
        info["_ColorSendClick"] := "Run a Color GUI button that sends a shortcut and shows its label/description."
        info["_ColorFuncClickRef"] := "Run a Color GUI button that calls an AHK function target."
        info["_ColorRunClick"] := "Dispatch the clicked Color GUI item to its assigned action type."
        info["_LinkFuncClick"] := "Run a Link GUI button that calls an AHK function target."
        info["_HoverShowPending"] := "Show the hover popup after its pending delay completes."
        info["_HoverCheck"] := "Track the mouse and decide when a hover popup should appear or close."
        info["_CCSaveOffset"] := "Save Color Info offset and mode settings from the Color Info settings dialog."
        info["_CleanupStaleIniKeys"] := "Remove stale INI keys that should no longer stay in the main settings file."
        info["_HK_ResultPopup"] := "Show the small success/error popup used by import/export and profile actions."
        info["_InitRecData"] := "Build the recommended-shortcut guide pages shown in the guide popup."

        info["_TimerAskNameFolder"] := "Ask where timer TXT/PNG output should be saved before exporting."
        info["CL"] := "Short Notify helper used internally by the bundled notification library."
        info["CO"] := "Short Notify helper used internally by the bundled notification library."
        info["ES"] := "Short Notify helper used internally by the bundled notification library."
    }
    if info.Has(clean)
        return info[clean]
    if InStr(ldetail, "\gui\color_palette.ahk")
        return "Internal Color Palette helper for button clicks, layout updates, or item management."
    if InStr(ldetail, "\gui\link_launcher.ahk") || InStr(ldetail, "\gui\link_button_manager.ahk")
        return "Internal Link GUI helper for button clicks, layout updates, or link item management."
    if InStr(ldetail, "\gui\pie_menu.ahk")
        return "Internal Pie Menu helper for slot layout, hover behavior, navigation, or slot execution."
    if InStr(ldetail, "\gui\hotkey_settings.ahk")
        return "Internal Hotkey Settings helper for browsing, editing, testing, or assigning functions."
    if InStr(ldetail, "\gui\color_info.ahk")
        return "Internal Color Info helper for mode changes, offset saving, or clipboard picker behavior."
    if InStr(ldetail, "\gui\hover_popup.ahk")
        return "Internal hover-tooltip helper for delayed show, follow, and close behavior."
    if InStr(ldetail, "\features\timer_worklog.ahk")
        return "Internal Timer/Worklog helper for start, pause, lap, save, load, and export actions."
    if InStr(ldetail, "\gui\inbetween_bar.ahk")
        return "Internal Inbetween Bar helper for button state, IB direction, or toolbar actions."
    if InStr(ldetail, "\core\csp_runtime.ahk")
        return "Core runtime helper for CSP state checks, notifications, debug logging, or global toggles."
    if InStr(ldetail, "\settings\")
        return "Settings persistence helper for loading, saving, backing up, or repairing toolkit data."
    if InStr(ldetail, "\hotkeys\hotkey_core.ahk")
        return "Hotkey engine helper for modifier handling, guard logic, and CSP shortcut workflows."
    if InStr(ldetail, "\features\toolkit_commands_and_guides.ahk") || InStr(ldetail, "\docs\guide_wizard.ahk")
        return "Guide-content helper for building toolkit help, first-run text, or recommended shortcut pages."
    return ""
}

HK_UserScriptSummary(path) {
    path := HK_ResolveExistingPath(path)
    if path = "" || !FileExist(path)
        return ""
    try txt := FileRead(path, "UTF-8")
    catch
        return ""
    for line in StrSplit(txt, "`n", "`r") {
        if RegExMatch(line, "i)^\s*;\s*(?:@?summary)\s*:\s*(.+)$", &m)
            return Trim(m[1])
    }
    return ""
}

HK_UserScriptMetadata(path) {
    path := HK_ResolveExistingPath(path)
    if path = "" || !FileExist(path)
        return Map()
    try txt := FileRead(path, "UTF-8")
    catch
        return Map()
    meta := Map()
    for line in StrSplit(txt, "`n", "`r") {
        if RegExMatch(line, "i)^\s*;\s*(?:@?summary)\s*:\s*(.+)$", &m)
            meta["summary"] := Trim(m[1])
        else if RegExMatch(line, "i)^\s*;\s*(?:@?category)\s*:\s*(.+)$", &m)
            meta["category"] := Trim(m[1])
        else if RegExMatch(line, "i)^\s*;\s*(?:@?risk)\s*:\s*(.+)$", &m)
            meta["risk"] := Trim(m[1])
        else if RegExMatch(line, "i)^\s*;\s*(?:@?requirement)\s*:\s*(.+)$", &m)
            meta["requirement"] := Trim(m[1])
    }
    return meta
}

HK_FunctionSummary(name, source := "", detail := "") {
    static info := 0
    if !IsObject(info) {
        info := Map()
        info["ShowCSPGuide"] := "Open the main toolkit guide popup."
        info["ShowCSPRecommended"] := "Open the recommended CSP shortcut list."
        info["FirstRunWizard"] := "Open the first-run setup and requirement wizard."
        info["ShowHotkeySettings"] := "Open the Hotkey Settings manager."
        info["ShowLTSettings"] := "Open System Settings / LT calibration."
        info["ShowGuiSetting"] := "Open GUI opacity, scale, scroll, and notification settings."
        info["ShowStatusDashboard"] := "Open the live runtime status dashboard."
        info["ShowSettingsHealth"] := "Scan split settings files and data health."
        info["ShowCSPSetupValidator"] := "Validate CSP setup, LT coordinates, presets, and pie settings."
        info["ShowBrokenActionScanner"] := "Scan for missing actions, functions, paths, and broken entries."
        info["ShowConfigDoctor"] := "Diagnose settings drift, missing split files, duplicate INI data, stale config versions, and malformed pie/color data."
        info["ShowTypingSafeguardInspector"] := "Inspect the active window title, preserved title, focused control, and IsTyping() decision."
        info["ShowTypingTitleEditor"] := "View and edit the typing title lists. Each named list matches like one of the three built-in behaviors (CSP dialogs, toolkit dialogs, CSP non-typing exceptions); New Cat/Del Cat manage custom lists. Add new titles, disable/enable them, delete, or reset to defaults."
        info["ShowActionConflictTester"] := "Scan for duplicate hotkeys and pie conflicts."
        info["ShowLinkManager"] := "Open the Link Button manager."
        info["ShowDebugGUI"] := "Open the live debug log window."
        info["ShowPieOven"] := "Open Pie Oven / pie system settings."
        info["ShowUserFunctionLibrary"] := "Open the User Scripts manager to add / edit / delete custom function scripts."
        info["ShowMainGUI"] := "Show the main toolkit GUI."
        info["ShowFeatureSwitcher"] := "Open the Feature Switcher panel that turns toolkit features on or off."
        info["ShowFeatureSwitcherInfo"] := "Open the Feature Switcher info window describing every switchable feature and its default/current state."
        info["ShowFunctionBrowser"] := "Open the callable function browser with category, source, and risk filters."
        info["ShowFunctionAuditReport"] := "Audit real top-level callable functions and report duplicate names if any exist."
        info["ShowFunctionTestRunner"] := "Open the small function test runner for quick built-in or user-library calls."
        info["HK_FunctionPicker"] := "Open Function Browser and insert the selected function into the current field."
        info["HK_TestFunctionAction"] := "Run one function by name and report success or failure."
        info["ShowPieQuickHotkeys"] := "Open the Quick Pie hotkey manager."
        info["PieQuickPersistChanges"] := "Save Quick Pie entries and reapply their hotkeys immediately."
        info["SystemSettingsSave"] := "Save all System Settings cards, create a backup, and reapply affected hotkeys."
        info["SaveLTDetect"] := "Save the Detection Pixel X/Y/Expected color used for light-table detection."
        info["SaveClickCoords"] := "Save LT Reset and LT Image click coordinates used by CSP actions."
        info["SaveColorOffset"] := "Save Color Info mode, clipboard picker options, and cursor offset values."
        info["SaveHoldThreshold"] := "Save the shared CapsLock / Tab hold threshold."
        info["SaveAutoSaveInterval"] := "Save the CSP auto-save interval and rearm the timer."
        info["SaveReqPresetSettings"] := "Save which CSP AutoAction preset packs are enabled for requirement checks."
        info["LoadColorItems"] := "Load Color GUI items from settings."
        info["SaveColorItems"] := "Save editable Color GUI items back to settings."
        info["LoadPieQuickHotkeys"] := "Load Quick Pie hotkeys from the hotkey settings file."
        info["SavePieQuickHotkeys"] := "Save Quick Pie hotkeys to the hotkey settings file."
        info["SavePieQuickHotkeysToFile"] := "Export the current Quick Pie hotkeys to a chosen INI file."
        info["LoadPieQuickHotkeysFromFile"] := "Import Quick Pie hotkeys from a chosen INI file."
        info["ShowLTSettingsHelp"] := "Open the System Settings help popup with calibration guidance."
        info["SafeMode"] := "Toggle Safe Mode for shortcut suppression."
        info["ToggleMainWindow"] := "Toggle the main toolkit window."
        info["ToggleInbetweenMode"] := "Swap inbetween direction mode."
        info["ToggleAutoSave"] := "Toggle CSP auto-save."
        info["ToggleNav"] := "Toggle navigation shortcuts."
        info["ShowPieSettings(1)"] := "Open Pie 1 slot settings."
        info["ShowPieSettings(2)"] := "Open Pie 2 slot settings."
        info["ShowPieSettings(3)"] := "Open Pie 3 slot settings."
        info["ShowPieSettings(4)"] := "Open Pie 4 slot settings."
        info["ShowNotify"] := "Show a toolkit popup notification."
        info["SelfHealSettings"] := "Repair split setting files, reload data, and resave clean copies."
        info["SaveDebugLog"] := "Save the current debug log contents to a text file."
        info["EnsureMainSettingsFile"] := "Create a minimal gui_settings.ini skeleton when the primary settings file is missing, without overwriting GUI positions with startup defaults."
        info["EnsureConfigVersion"] := "Upgrade the stored config version number when older settings are detected."
        info["LoadGUIPositions"] := "Load saved GUI positions, opacity, scale, color info mode, requirements, and toolkit runtime settings."
        info["SaveGUIPositions"] := "Save current GUI positions and runtime display settings back to the settings file."
        info["LoadConfigurablePaths"] := "Load saved external paths, URLs, and click coordinates used by toolkit actions."
        info["SaveConfigurablePaths"] := "Save external paths, URLs, and click coordinates used by toolkit actions."
        info["CheckIniChanges"] := "Watch split settings files for external edits, reload them, and reapply runtime state when they change."
        info["LoadIBSettingsFromIni"] := "Load the saved IB mode and selected inbetween preset index from settings."
        info["CompactSplitSettingsFiles"] := "Clean duplicate or stale data from split settings files."
        info["CreateConfigBackup"] := "Create a timestamped backup copy of the toolkit settings files."
        info["BackupConfig"] := "Open the settings backup flow and save a restore point."
        info["RestoreConfig"] := "Restore toolkit settings from a saved backup set."
        info["LoadPieItems"] := "Load pie menu slots, names, hotkeys, quick-pie data, and sub-pie data from settings."
        info["SavePieItems"] := "Save all pie menu, sub-pie, and quick-pie configuration back to settings."
        info["LoadLinkItems"] := "Load Link GUI items from split settings and merge them with required system items."
        info["SaveLinkItems"] := "Save editable Link GUI items to the split link settings file."
        info["HK_Load"] := "Load saved hotkeys, requirements, activation flags, and custom function bindings."
        info["HK_Save"] := "Save hotkey assignments, requirements, activation flags, and custom function bindings."
        info["TimerSetButtons"] := "Refresh the timer buttons so Start/Pause/Lap/Stop reflect the current timer state."
        info["TimerFormatElapsed"] := "Format elapsed milliseconds into the timer display text."
        info["TimerCurrentElapsed"] := "Return the current timer value, including active running time."
        info["TimerApplyLapNames"] := "Apply edited lap names from the save dialog back into the timer lap list."
        info["TimerLapSaveText"] := "Build the lap text block used in TXT and PNG timer exports."
        info["TimerGetLapSummary"] := "Calculate lap count, fastest lap, slowest lap, average, and split differences for export."
        info["TimerBuildExportText"] := "Build the full TXT/PNG export data block for timer saves."
        info["TimerQuoteArg"] := "Escape a file path or string so the PowerShell timer renderer can receive it safely."
        info["TimerParseElapsed"] := "Parse a saved elapsed-time string back into milliseconds."
        info["TimerTextSidecarPath"] := "Return the TXT sidecar path that matches a saved timer PNG."
        info["TimerParseExportText"] := "Read a saved timer TXT/sidecar export and reconstruct timer/lap data from it."
        info["TimerLoad"] := "Load timer state and laps back from a saved TXT or PNG export."
        info["TimerUpdateLapIndicator"] := "Update the IB timer area to show the latest lap summary."
        info["TimerStart"] := "Start the work timer and begin live ticking."
        info["TimerPause"] := "Pause the work timer and keep the current elapsed time."
        info["TimerToggle"] := "Toggle the timer between running and paused."
        info["TimerStop"] := "Stop the timer and open the save flow when needed."
        info["TimerClear"] := "Clear the timer and remove recorded laps."
        info["TimerLap"] := "Record a new lap using the current timer value."
        info["TimerStopOrLap"] := "While running, record a lap; otherwise run the normal stop behavior."
        info["TimerTick"] := "Update the visible timer display on each tick while the timer runs."
        info["TimerSave"] := "Open the timer save dialog without resetting the timer."
        info["TimerShowSaveDialog"] := "Open the timer export dialog for TXT/PNG save, lap naming, and file-name options."
        info["CaptureTimerToPNG"] := "Render the timer export card to PNG through the bundled PowerShell renderer."
        info["TimerSavePNG"] := "Save the current timer and laps as a PNG export plus TXT sidecar."
        info["TimerSaveTXT"] := "Save the current timer and laps as a TXT export."
    }
    clean := RegExReplace(Trim(name), "\(\)$", "")
    if info.Has(clean)
        return info[clean]
    hotkeySummary := HK_HotkeyFunctionSummary(clean)
    if hotkeySummary != ""
        return hotkeySummary
    if source = "Built-in" && detail != "" {
        SplitPath(detail, &fileName)
        category := HK_FunctionCategory(clean, source, detail)
        helperSummary := HK_BuiltInHelperSummary(clean, detail)
        if helperSummary != ""
            return helperSummary
        if detail = "Toolkit runtime"
            return "Core toolkit command available to other features, hotkeys, pie slots, and managers."
        if InStr(fileName, "persistence.ahk")
            return "Built-in settings persistence helper from " fileName " for loading, saving, reloading, or repairing toolkit state."
        if InStr(fileName, "toolkit_commands_and_guides.ahk") || InStr(fileName, "guide_wizard.ahk") || InStr(fileName, "system_settings.ahk") || InStr(fileName, "toggle_commands.ahk") || InStr(fileName, "pie_oven.ahk") || InStr(fileName, "quick_pie_oven.ahk")
            return "Built-in guide/settings helper from " fileName "."
        if RegExMatch(clean, "i)^_?show")
            return "Open or show a built-in " StrLower(category) " function from " fileName "."
        if RegExMatch(clean, "i)^_?toggle")
            return "Toggle built-in toolkit state from " fileName "."
        if RegExMatch(clean, "i)^_?(update|refresh|rebuild|render|redraw)")
            return "Refresh or redraw built-in toolkit UI/runtime state from " fileName "."
        if RegExMatch(clean, "i)^_?(save|load|import|export)")
            return "Load or save built-in toolkit data from " fileName "."
        if RegExMatch(clean, "i)^_?(create|build|add)")
            return "Create or build a built-in toolkit UI/data action from " fileName "."
        if RegExMatch(clean, "i)^_?(delete|remove|clear|cleanup)")
            return "Remove, clear, or cleanup built-in toolkit state from " fileName "."
        if RegExMatch(clean, "i)^_?(pick|browse|choose|capture|record)")
            return "Picker or capture helper built into the toolkit from " fileName "."
        if RegExMatch(clean, "i)^_?(test|scan|validate|health)")
            return "Diagnostic or validation helper built into the toolkit from " fileName "."
        if RegExMatch(clean, "i)^_?(normalize|ensure)")
            return "Internal built-in helper that normalizes or safeguards toolkit data."
        return "Callable built-in toolkit function loaded from " fileName "."
    }
    if source = "User Script" {
        userSummary := HK_UserScriptSummary(detail)
        if userSummary != ""
            return userSummary
        return "Callable user-library function loaded from an external user .ahk script."
    }
    if source = "Hotkey Action"
        return "Function currently assigned to one or more hotkeys."
    if source = "Built-in"
        return "Callable built-in toolkit function."
    return "Callable runtime function."
}

HK_FunctionUsedBy(name) {
    global HotkeyDefs, PieQuickHotkeys, PieConfigs, SubPieConfigs, PieCount, LinkItems, ColorItems
    clean := RegExReplace(Trim(name), "\(\)$", "")
    uses := []
    for d in HotkeyDefs {
        try fnName := HK_GetFnName(d)
        catch
            continue
        if fnName = clean || fnName = clean "()" {
            uses.Push("Hotkey: " d.desc)
        }
    }
    for idx, item in PieQuickHotkeys {
        sanitized := PieQuickSanitizeItem(item)
        if StrLower(sanitized.Get("type", "")) = "function" {
            action := RegExReplace(Trim(sanitized.Get("action", "")), "\(\)$", "")
            if action = clean
                uses.Push("Quick Pie: " sanitized.Get("label", "Quick Hotkey"))
        }
    }
    Loop PieCount {
        if PieConfigs.Length < A_Index
            continue
        for _, item in PieConfigs[A_Index] {
            if StrLower(item.Get("type", "")) = "function" {
                action := RegExReplace(Trim(item.Get("action", "")), "\(\)$", "")
                if action = clean
                    uses.Push("Pie " A_Index ": " item.Get("label", "Unnamed"))
            }
        }
    }
    for subIdx, config in SubPieConfigs {
        for _, item in config {
            if StrLower(item.Get("type", "")) = "function" {
                action := RegExReplace(Trim(item.Get("action", "")), "\(\)$", "")
                if action = clean
                    uses.Push("Sub Pie " subIdx ": " item.Get("label", "Unnamed"))
            }
        }
    }
    for _, item in LinkItems {
        if StrLower(item.Get("type", "")) = "function" {
            action := RegExReplace(Trim(item.Get("action", "")), "\(\)$", "")
            if action = clean
                uses.Push("Link: " item.Get("label", item.Get("hover", "Unnamed")))
        }
    }
    for _, item in ColorItems {
        if StrLower(item.Get("type", "")) = "function" {
            action := RegExReplace(Trim(item.Get("action", "")), "\(\)$", "")
            if action = clean
                uses.Push("Color: " item.Get("label", item.Get("hover", "Unnamed")))
        }
    }
    if uses.Length = 0
        return "(not currently assigned)"
    shown := ""
    limit := Min(uses.Length, 8)
    Loop limit
        shown .= (A_Index > 1 ? "`r`n" : "") "- " uses[A_Index]
    if uses.Length > limit
        shown .= "`r`n- +" (uses.Length - limit) " more"
    return shown
}

HK_FunctionUsageTargets(name) {
    global HotkeyDefs, PieQuickHotkeys, PieConfigs, SubPieConfigs, PieCount, LinkItems, ColorItems
    clean := RegExReplace(Trim(name), "\(\)$", "")
    targets := []
    for d in HotkeyDefs {
        try fnName := HK_GetFnName(d)
        catch
            continue
        if fnName = clean || fnName = clean "()" {
            targets.Push(Map("label", "Hotkey: " d.desc, "type", "hotkey", "filter", d.desc))
        }
    }
    for idx, item in PieQuickHotkeys {
        sanitized := PieQuickSanitizeItem(item)
        if StrLower(sanitized.Get("type", "")) = "function" {
            action := RegExReplace(Trim(sanitized.Get("action", "")), "\(\)$", "")
            if action = clean
                targets.Push(Map("label", "Quick Pie: " sanitized.Get("label", "Quick Hotkey"), "type", "quickpie"))
        }
    }
    Loop PieCount {
        if PieConfigs.Length < A_Index
            continue
        for _, item in PieConfigs[A_Index] {
            if StrLower(item.Get("type", "")) = "function" {
                action := RegExReplace(Trim(item.Get("action", "")), "\(\)$", "")
                if action = clean
                    targets.Push(Map("label", "Pie " A_Index ": " item.Get("label", "Unnamed"), "type", "pie", "index", A_Index))
            }
        }
    }
    for subIdx, config in SubPieConfigs {
        for _, item in config {
            if StrLower(item.Get("type", "")) = "function" {
                action := RegExReplace(Trim(item.Get("action", "")), "\(\)$", "")
                if action = clean
                    targets.Push(Map("label", "Sub Pie " subIdx ": " item.Get("label", "Unnamed"), "type", "subpie", "index", subIdx))
            }
        }
    }
    for _, item in LinkItems {
        if StrLower(item.Get("type", "")) = "function" {
            action := RegExReplace(Trim(item.Get("action", "")), "\(\)$", "")
            if action = clean
                targets.Push(Map("label", "Link: " item.Get("label", item.Get("hover", "Unnamed")), "type", "link"))
        }
    }
    for _, item in ColorItems {
        if StrLower(item.Get("type", "")) = "function" {
            action := RegExReplace(Trim(item.Get("action", "")), "\(\)$", "")
            if action = clean
                targets.Push(Map("label", "Color: " item.Get("label", item.Get("hover", "Unnamed")), "type", "color"))
        }
    }
    return targets
}

HK_JumpToUsageTarget(target) {
    if !IsObject(target)
        return
    type := target.Get("type", "")
    switch type {
        case "hotkey":
            ShowHotkeySettings()
            if target.Has("filter")
                SetTimer((*) => HK_RefreshSettingsList(0, target["filter"]), -50)
        case "quickpie":
            ShowPieQuickHotkeys()
        case "pie":
            ShowPieSettings(target.Get("index", 1))
        case "subpie":
            ShowSubPieSettings(target.Get("index", 1))
        case "link":
            ShowLinkManager()
        case "color":
            ShowColorManager()
    }
}

HK_JumpToFunctionUsage(name) {
    targets := HK_FunctionUsageTargets(name)
    if targets.Length = 0 {
        ShowNotify("Function Browser", "No assigned usage found")
        return
    }
    if targets.Length = 1 {
        HK_JumpToUsageTarget(targets[1])
        return
    }
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Jump To Usage")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(12)
    dlg.MarginY := S(12)
    dlg.AddText("xm", "Used by:")
    lv := dlg.AddListView("xm y+8 w" S(420) " h" S(180) " Grid +Report", ["#", "Target"])
    lv.SetFont("s" S(9) " c000000", "Segoe UI")
    lv.ModifyCol(1, 0)
    lv.ModifyCol(2, S(390))
    for i, target in targets
        lv.Add(, i, target["label"])
    OpenSelected(*) {
        row := lv.GetNext()
        if !row {
            HK_SelectPrompt()
            return
        }
        dlg.Destroy()
        HK_JumpToUsageTarget(targets[Integer(lv.GetText(row, 1))])
    }
    lv.OnEvent("DoubleClick", OpenSelected)
    dlg.AddButton("xm y+10 w" S(80) " h" S(26) " Default", "Open").OnEvent("Click", OpenSelected)
    dlg.AddButton("x+8 yp w" S(80) " h" S(26), "Cancel").OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("AutoSize")
}

HK_FunctionCategory(name, source := "", detail := "") {
    lname := StrLower(Trim(name))
    ldetail := StrLower(detail)
    if InStr(lname, "guide") || InStr(lname, "recommended") || InStr(lname, "firstrun")
        return "Guide"
    if InStr(lname, "pie")
        return "Pie"
    if InStr(lname, "color")
        return "Color"
    if InStr(lname, "timer") || InStr(lname, "lap")
        return "Timer"
    if InStr(lname, "debug") || InStr(lname, "validator") || InStr(lname, "scanner") || InStr(lname, "health")
        return "Debug"
    if InStr(lname, "link")
        return "Link"
    if InStr(lname, "status") || InStr(lname, "setting") || InStr(lname, "maingui") || InStr(lname, "mainwindow")
        return "System"
    if InStr(lname, "safe") || InStr(lname, "toggle") || InStr(lname, "nav")
        return "Toggle"
    if source = "User Script"
        return "User"
    if InStr(ldetail, "\gui\")
        return "GUI"
    if InStr(ldetail, "\hotkeys\")
        return "Hotkey"
    return source = "Built-in" ? "Built-in" : "Runtime"
}

HK_FunctionCategoryColor(category) {
    static colors := 0
    if !IsObject(colors) {
        colors := Map()
        colors["Guide"] := "8E24AA"
        colors["Pie"] := "1565C0"
        colors["Color"] := "00897B"
        colors["Timer"] := "EF6C00"
        colors["Debug"] := "C62828"
        colors["Link"] := "2E7D32"
        colors["System"] := "455A64"
        colors["Toggle"] := "6D4C41"
        colors["User"] := "5E35B1"
        colors["GUI"] := "546E7A"
        colors["Hotkey"] := "3949AB"
        colors["Built-in"] := "37474F"
        colors["Runtime"] := "616161"
    }
    return colors.Has(category) ? colors[category] : "616161"
}

HK_FunctionUsage(name) {
    name := Trim(name)
    if name = ""
        return ""
    return "Use in action/function fields: " name " or " name "()"
}

HK_FunctionPreviewText(row) {
    name := row["name"]
    source := row["source"]
    detail := row["detail"]
    category := row.Has("category") ? row["category"] : HK_FunctionCategory(name, source, detail)
    summary := row.Has("summary") ? row["summary"] : HK_FunctionSummary(name, source, detail)
    usedBy := row.Has("usedBy") ? row["usedBy"] : HK_FunctionUsedBy(name)
    risk := row.Has("risk") ? row["risk"] : HK_FunctionRiskBadges(name, source, detail)
    txt := "Function: " name "`r`n"
        . "Category: " category "`r`n"
        . "Source: " source "`r`n"
        . "Risk: " risk "`r`n"
        . "Usage: " HK_FunctionUsage(name) "`r`n"
        . "Summary: " summary
    if detail != ""
        txt .= "`r`nDetail: " detail
    txt .= "`r`nUsed by:`r`n" usedBy
    if source = "Built-in"
        txt .= "`r`nNotes: Toolkit built-in. Safe to call directly from hotkeys, pie slots, quick pie, or item actions."
    else if source = "User Script"
        txt .= "`r`nNotes: Loaded from the user function library. Keep the script file available in user_hotkey_scripts."
    else if source = "Hotkey Action"
        txt .= "`r`nNotes: Currently referenced by at least one hotkey definition."
    return txt
}

HK_TestFunctionAction(action, label := "Function Test") {
    action := RegExReplace(Trim(action), "\(\)$", "")
    if action = "" {
        _HK_ResultPopup(label, "Function name is empty.", "E53935")
        return false
    }
    try {
        scanned := HK_ScanScriptFunctions()
        if scanned.Has(action) && HK_IsUserLibraryFunctionPath(scanned[action])
            HK_TestUserLibraryFunction(action, scanned[action], label)
        else
            ToolkitRunFunction(action, label)
        DebugLog(label ": tested function " action)
        return true
    } catch as e {
        DebugLog(label ": function test failed for " action " - " e.Message)
        _HK_ResultPopup(label, "Function test failed: " e.Message, "E53935")
        return false
    }
}

HK_TestUserLibraryFunction(fnName, filePath, label := "Function Test") {
    filePath := HK_ResolveExistingPath(filePath)
    if filePath = "" || !FileExist(filePath)
        throw Error("User library script not found: " filePath)

    stamp := A_TickCount "_" A_NowUTC
    tmpScript := A_Temp "\csp_fn_test_" stamp ".ahk"
    tmpResult := A_Temp "\csp_fn_test_" stamp ".txt"
    escHelper := StrReplace(A_ScriptDir "\src\includes\user_script_helpers.ahk", '"', '""')
    escPath := StrReplace(filePath, '"', '""')
    escFn := StrReplace(fnName, '"', '""')
    escResult := StrReplace(tmpResult, '"', '""')
    wrapper := "#Requires AutoHotkey v2.0`n"
        . "#SingleInstance Off`n"
        . "#NoTrayIcon`n"
        . '#Include "' escHelper '"`n'
        . '#Include "' escPath '"`n'
        . 'resultFile := "' escResult '"`n'
        . 'fn := "' escFn '"`n'
        . "try {`n"
        . "    f2 := 0`n"
        . "    try f2 := %fn%`n"
        . "    if Type(f2) != `"Func`"`n"
        . "        throw Error(`"function not found: `" fn)`n"
        . "    f2.Call()`n"
        . "    Sleep(1500)`n"
        . '    FileAppend("OK", resultFile, "UTF-8")`n'
        . "    ExitApp(0)`n"
        . "} catch as e {`n"
        . '    FileAppend("ERROR: " e.Message, resultFile, "UTF-8")`n'
        . "    ExitApp(1)`n"
        . "}`n"

    try {
        if FileExist(tmpScript)
            FileDelete(tmpScript)
        if FileExist(tmpResult)
            FileDelete(tmpResult)
        FileAppend(wrapper, tmpScript, "UTF-8")
        RunWait('"' A_AhkPath '" "' tmpScript '"',, "Hide")
        if !FileExist(tmpResult)
            throw Error("Test wrapper did not return a result.")
        result := Trim(FileRead(tmpResult, "UTF-8"))
        if SubStr(result, 1, 6) = "ERROR:"
            throw Error(Trim(SubStr(result, 7)))
        if result != "OK"
            throw Error("Unexpected wrapper result: " result)
    } finally {
        try FileDelete(tmpScript)
        try FileDelete(tmpResult)
    }
}

ShowFunctionTestRunner(*) {
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Function Test Runner")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(12)
    dlg.MarginY := S(12)
    dlg.AddText("xm", "Pick a callable function, test it, or insert it into the field.")
    dlg.AddText("xm y+8", "Function:")
    fnEd := dlg.AddEdit("xm y+6 w" S(320) " c000000 BackgroundFFFFFF", "")
    dlg.AddText("xm y+6 w" S(320) " c888888", "Use a built-in or user-library function name. Example: ShowCSPGuide or HotkeyLayerBlack")
    dlg.AddButton("xm y+10 w" S(80) " h" S(26), "Pick").OnEvent("Click", (*) => HK_FunctionPicker(fnEd))
    dlg.AddButton("x+8 yp w" S(80) " h" S(26), "Test").OnEvent("Click", (*) => HK_TestFunctionAction(fnEd.Value, "Function Runner"))
    dlg.AddButton("x+8 yp w" S(80) " h" S(26), "Guide").OnEvent("Click", HK_ShowFunctionFieldGuide)
    dlg.AddButton("x+8 yp w" S(80) " h" S(26) " Default", "Close").OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("AutoSize")
}

HK_SourceFiles() {
    global HK_UserScriptDir
    files := []
    seen := Map()
    AddFile(path) {
        path := HK_ResolveExistingPath(path)
        if path = "" || !FileExist(path)
            return
        key := StrLower(path)
        if seen.Has(key)
            return
        seen[key] := true
        files.Push(path)
    }
    AddFile(A_ScriptFullPath)
    try mainScript := FileRead(A_ScriptFullPath, "UTF-8")
    catch
        mainScript := ""
    for line in StrSplit(mainScript, "`n", "`r") {
        if RegExMatch(line, "i)^\s*#Include\s+(.+?)(?:\s|$)", &m) {
            incPath := Trim(m[1])
            incPath := RegExReplace(incPath, "^\x22|\x22$")
            incPath := RegExReplace(incPath, "^<|>$")
            if !(SubStr(incPath, 2, 1) = ":")
                incPath := A_ScriptDir "\" incPath
            AddFile(incPath)
        }
    }
    if DirExist(HK_UserScriptDir) {
        Loop Files HK_UserScriptDir "\*.ahk", "F" {
            if HK_UserScriptDisabled(A_LoopFileFullPath)
                continue
            AddFile(A_LoopFileFullPath)
        }
    }
    return files
}

HK_AdjustBraceDepth(line, &depth) {
    inQuote := false
    escaped := false
    Loop Parse, line {
        ch := A_LoopField
        if escaped {
            escaped := false
            continue
        }
        if ch = "\" {
            escaped := true
            continue
        }
        if ch = '"' {
            inQuote := !inQuote
            continue
        }
        if inQuote
            continue
        if ch = "{"
            depth++
        else if ch = "}"
            depth := Max(0, depth - 1)
    }
}

HK_AuditTopLevelFunctions() {
    keywordBlocklist := Map()
    for k in ["if","for","while","switch","try","catch","else","return","class","throw","break","continue","case","default","until","loop"] {
        keywordBlocklist[k] := true
    }
    defs := Map()
    total := 0
    files := HK_SourceFiles()
    for filePath in files {
        try txt := FileRead(filePath, "UTF-8")
        catch
            continue
        lines := StrSplit(txt, "`n", "`r")
        depth := 0
        pendingName := ""
        pendingLine := 0
        for idx, rawLine in lines {
            line := RegExReplace(rawLine, ";\s.*$", "")
            trimmed := Trim(line)
            if pendingName != "" && depth = 0 && trimmed != "" {
                if trimmed = "{" {
                    total++
                    if !defs.Has(pendingName)
                        defs[pendingName] := []
                    defs[pendingName].Push({path:filePath, line:pendingLine})
                }
                pendingName := ""
                pendingLine := 0
            }
            if depth = 0 && trimmed != "" {
                if RegExMatch(trimmed, "^([A-Za-z_]\w*)\s*\([^)]*\)\s*(\{)?\s*$", &m) {
                    name := m[1]
                    lower := StrLower(name)
                    if !keywordBlocklist.Has(lower) {
                        if m[2] = "{" {
                            total++
                            if !defs.Has(name)
                                defs[name] := []
                            defs[name].Push({path:filePath, line:idx})
                        } else {
                            pendingName := name
                            pendingLine := idx
                        }
                    }
                }
            }
            HK_AdjustBraceDepth(line, &depth)
        }
    }
    duplicates := []
    for name, items in defs {
        if items.Length > 1
            duplicates.Push({name:name, items:items})
    }
    return {total:total, unique:defs.Count, duplicates:duplicates, fileCount:files.Length}
}

ShowFunctionAuditReport(*) {
    audit := HK_AuditTopLevelFunctions()
    txt := "Top-Level Function Audit`r`n"
        . "Reports only real top-level callable function definitions gathered from the main script, included src files, and user library scripts.`r`n"
        . "Nested dialog helpers, local closures, and example text should not be counted here.`r`n`r`n"
        . "[OK] Files scanned: " audit.fileCount "`r`n"
        . "[OK] Top-level definitions: " audit.total "`r`n"
        . "[OK] Unique function names: " audit.unique "`r`n"
        . (audit.duplicates.Length = 0
            ? "[OK] Duplicate top-level function names: 0`r`n"
            : "[FIX] Duplicate top-level function names: " audit.duplicates.Length "`r`n")
    if audit.duplicates.Length > 0 {
        txt .= "`r`nDuplicates`r`n"
        for dup in audit.duplicates {
            txt .= "- " dup.name "`r`n"
            for item in dup.items
                txt .= "    " item.path ":" item.line "`r`n"
        }
    } else {
        txt .= "`r`nNo duplicate top-level function definitions were found."
    }
    ShowReportWindow("Top-Level Function Audit", txt)
}

ShowFunctionBrowser(targetEd := 0, *) {
    insertMode := IsObject(targetEd)
    dlg := Gui("+AlwaysOnTop +ToolWindow +Resize", insertMode ? "Function Browser - Insert Function" : "Function Browser")
    dlg._catalog := HK_FunctionCatalog()
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(12)
    dlg.MarginY := S(12)
    dlg.AddText("xm", insertMode
        ? "Browse callable functions and insert one into the current function field."
        : "Browse callable built-in toolkit functions, assigned hotkey actions, and user-library functions.")
    contentW := S(1080)
    dlg.AddText("xm y+6", "Search:")
    edFilter := dlg.AddEdit("x+8 yp w" S(220) " c000000 BackgroundFFFFFF", "")
    dlg.AddText("x+" S(12) " yp", "Source:")
    srcDd := dlg.AddDropDownList("x+8 yp w" S(132), ["All Sources", "Built-in", "Hotkey Action", "User Script", "Runtime"])
    srcDd.Value := 1
    dlg.AddText("x+" S(12) " yp", "Category:")
    catDd := dlg.AddDropDownList("x+8 yp w" S(160), ["All Categories", "Guide", "Pie", "Color", "Timer", "Debug", "Link", "System", "Toggle", "User", "GUI", "Hotkey", "Built-in", "Runtime"])
    catDd.Value := 1
    showInternalCb := dlg.AddCheckbox("x+" S(12) " yp+2 cCCCCCC Background1E1F22", "Show internal helpers")
    showInternalCb.Value := 0
    assignedOnlyCb := dlg.AddCheckbox("x+" S(14) " yp cCCCCCC Background1E1F22", "Show only assigned")
    assignedOnlyCb.Value := 0
    resultTxt := dlg.AddText("xm y+13 w" S(150) " cAAAAAA", "")
    filterStateTxt := dlg.AddText("x+" S(10) " yp w" S(313) " c888888", "")
    AddLegendChip(label, color, first := false) {
        local opt := (first ? "x+8" : "x+6") " yp w" S(64) " h" S(18) " +0x200 Center Background" color " cFFFFFF"
        return dlg.AddText(opt, label)
    }
    dlg.AddText("x+3 yp", "Legend:")
    AddLegendChip("Guide", HK_FunctionCategoryColor("Guide"), true)
    AddLegendChip("Pie", HK_FunctionCategoryColor("Pie"))
    AddLegendChip("Color", HK_FunctionCategoryColor("Color"))
    AddLegendChip("Timer", HK_FunctionCategoryColor("Timer"))
    AddLegendChip("Debug", HK_FunctionCategoryColor("Debug"))
    AddLegendChip("System", HK_FunctionCategoryColor("System"))
    lv := dlg.AddListView("xm y+8 w" contentW " h" S(300) " Grid +Report", ["Function", "Category", "Source", "Risk", "Summary"])
    lv.SetFont("s" S(9) " c000000", "Segoe UI")
    lv.ModifyCol(1, S(235))
    lv.ModifyCol(2, S(95))
    lv.ModifyCol(3, S(100))
    lv.ModifyCol(4, S(195))
    lv.ModifyCol(5, S(434))
    previewEd := dlg.AddEdit("xm y+8 w" contentW " h" S(120) " ReadOnly -Wrap VScroll c000000 BackgroundFFFFFF", "")
    previewMeta := dlg.AddText("xm y+6 w" contentW " h" S(20) " +0x200 Background2D2D32 cFFFFFF", "")
    ApplySelection(closeAfter := true) {
        row := lv.GetNext()
        if !row {
            HK_SelectPrompt()
            return
        }
        fn := lv.GetText(row, 1)
        if IsObject(targetEd) {
            if HasMethod(targetEd, "Call") {
                targetEd.Call(fn)
                ShowNotify("Function Browser", "Inserted: " fn)
            } else {
                targetEd.Value := fn
                try targetEd.Focus()
                ShowNotify("Function Browser", "Inserted: " fn)
            }
        } else {
            if SetClipboardSafe(fn, "Function Browser")
                ShowNotify("Function Browser", "Function copied")
        }
        if closeAfter
            dlg.Destroy()
    }
    RefreshList(*) {
        filter := StrLower(Trim(edFilter.Value))
        sourceFilter := srcDd.Text
        categoryFilter := catDd.Text
        showInternal := !!showInternalCb.Value
        assignedOnly := !!assignedOnlyCb.Value
        lv.Delete()
        shown := 0
        for _, row in dlg._catalog {
            row["category"] := HK_FunctionCategory(row["name"], row["source"], row["detail"])
            row["summary"] := HK_FunctionSummary(row["name"], row["source"], row["detail"])
            row["risk"] := HK_FunctionRiskBadges(row["name"], row["source"], row["detail"])
            if row["source"] = "User Script" {
                usrMeta := HK_UserScriptMetadata(row["detail"])
                if usrMeta.Has("summary")
                    row["summary"] := usrMeta["summary"]
                if usrMeta.Has("category")
                    row["category"] := usrMeta["category"]
                if usrMeta.Has("risk") {
                    items := []
                    for part in StrSplit(usrMeta["risk"], ["|", ","]) {
                        item := Trim(part)
                        if item != ""
                            items.Push(item)
                    }
                    row["risk"] := HK_BadgeJoin(items)
                }
            }
            if !showInternal && HK_FunctionIsInternal(row)
                continue
            if assignedOnly && row["usedBy"] = "(not currently assigned)"
                continue
            hay := StrLower(row["name"] " " row["source"] " " row["detail"])
            if filter != "" && !InStr(hay, filter)
                continue
            if sourceFilter != "All Sources" && row["source"] != sourceFilter
                continue
            if categoryFilter != "All Categories" && row["category"] != categoryFilter
                continue
            lv.Add(, row["name"], row["category"], row["source"], row["risk"], row["summary"])
            shown++
        }
        resultTxt.Text := shown " shown / " dlg._catalog.Length " total"
        states := []
        states.Push(assignedOnly ? "assigned only" : "all assignments")
        states.Push(showInternal ? "including internal helpers" : "hiding internal helpers")
        if sourceFilter != "All Sources"
            states.Push("source: " sourceFilter)
        if categoryFilter != "All Categories"
            states.Push("category: " categoryFilter)
        if filter != ""
            states.Push("search: " Trim(edFilter.Value))
        filterStateTxt.Text := "Showing " . states[1]
        Loop states.Length - 1
            filterStateTxt.Text .= " | " . states[A_Index + 1]
        if shown > 0 {
            lv.Modify(1, "Select Focus")
            UpdatePreview()
        } else {
            previewEd.Value := ""
            previewMeta.Text := ""
        }
    }
    SelectedFunction() {
        row := lv.GetNext()
        if !row {
            HK_SelectPrompt()
            return ""
        }
        return lv.GetText(row, 1)
    }
    UpdatePreview(*) {
        rowNum := lv.GetNext()
        if !rowNum {
            previewEd.Value := ""
            return
        }
        fn := lv.GetText(rowNum, 1)
        for _, row in dlg._catalog {
            if row["name"] = fn {
                previewMeta.Opt("Background" HK_FunctionCategoryColor(row["category"]) " cFFFFFF")
                previewMeta.Text := " " row["category"] "  |  " row["source"] "  |  " row["name"]
                previewEd.Value := HK_FunctionPreviewText(row)
                return
            }
        }
        previewMeta.Opt("Background2D2D32 cFFFFFF")
        previewMeta.Text := " " fn
        previewEd.Value := "Function: " fn
    }
    CopyName(*) {
        fn := SelectedFunction()
        if fn = ""
            return
        if SetClipboardSafe(fn, "Function Browser")
            ShowNotify("Function Browser", "Function copied")
    }
    TestSelected(*) {
        fn := SelectedFunction()
        if fn = ""
            return
        HK_TestFunctionAction(fn, "Function Browser")
    }
    ResetFilters(*) {
        edFilter.Value := ""
        srcDd.Value := 1
        catDd.Value := 1
        showInternalCb.Value := 0
        assignedOnlyCb.Value := 0
        RefreshList()
        try edFilter.Focus()
    }
    JumpSelected(*) {
        fn := SelectedFunction()
        if fn = ""
            return
        HK_JumpToFunctionUsage(fn)
    }
    RefreshList()
    edFilter.OnEvent("Change", RefreshList)
    srcDd.OnEvent("Change", RefreshList)
    catDd.OnEvent("Change", RefreshList)
    showInternalCb.OnEvent("Click", RefreshList)
    assignedOnlyCb.OnEvent("Click", RefreshList)
    lv.OnEvent("DoubleClick", (*) => ApplySelection(true))
    lv.OnEvent("ItemSelect", UpdatePreview)
    dlg.AddButton("xm y+10 w" S(72) " h" S(26) " Default", insertMode ? "Use" : "Copy").OnEvent("Click", (*) => ApplySelection(true))
    dlg.AddButton("x+6 yp w" S(64) " h" S(26), "Test").OnEvent("Click", TestSelected)
    dlg.AddButton("x+6 yp w" S(68) " h" S(26), "Jump...").OnEvent("Click", JumpSelected)
    dlg.AddButton("x+6 yp w" S(64) " h" S(26), "Copy").OnEvent("Click", CopyName)
    dlg.AddButton("x+6 yp w" S(92) " h" S(26), "Reset Filters").OnEvent("Click", ResetFilters)
    dlg.AddButton("x+6 yp w" S(68) " h" S(26), "Runner").OnEvent("Click", ShowFunctionTestRunner)
    dlg.AddButton("x+6 yp w" S(64) " h" S(26), "Audit").OnEvent("Click", ShowFunctionAuditReport)
    RebuildCatalog(*) {
        dlg._catalog := HK_FunctionCatalog()
        RefreshList()
    }
    dlg.AddButton("x+6 yp w" S(68) " h" S(26), "Refresh").OnEvent("Click", RebuildCatalog)
    dlg.AddButton("x+6 yp w" S(96) " h" S(26), "Script Guide").OnEvent("Click", HK_FunctionBrowserHowTo)
    dlg.AddButton("x+6 yp w" S(64) " h" S(26), "Close").OnEvent("Click", (*) => dlg.Destroy())
    dlg.AddButton("xm+" contentW - S(120) " yp w" S(120) " h" S(26), "User Scripts").OnEvent("Click", ShowUserFunctionLibrary)
    dlg.AddText("xm y-2 h1", "")
    dlg.Show("w" S(1110) " AutoSize")
}

HK_ConflictTextForKey(key, currentId := "") {
    key := Trim(key)
    if key = "" || key = "-"
        return ""
    dup := HK_FindDuplicateDef(currentId, key)
    return IsObject(dup) ? "Conflict with: " dup.desc : ""
}

PieQuickConflictText(key, scope, currentId := "") {
    global PieQuickHotkeys
    key := PieQuickNormalizeKey(key)
    scope := PieQuickNormalizeScope(scope)
    if key = "" || key = "-" || scope = "disabled"
        return ""
    for idx, item in PieQuickHotkeys {
        sanitized := PieQuickSanitizeItem(item)
        if sanitized.Get("id", "") = currentId
            continue
        if !sanitized.Get("enabled", 1)
            continue
        if PieQuickNormalizeKey(sanitized.Get("key", "")) != key
            continue
        otherScope := PieQuickNormalizeScope(sanitized.Get("scope", "all"))
        if otherScope = "disabled"
            continue
        if scope = "all" || otherScope = "all" || scope = otherScope
            return "Conflict with quick key: " sanitized.Get("label", "Quick Hotkey")
    }
    return ""
}

HK_FunctionPicker(targetEd := 0, *) {
    ShowFunctionBrowser(targetEd)
}

HK_FunctionBrowserHowTo(*) {
    popup := Gui("+AlwaysOnTop +ToolWindow", "Script Guide - Function Browser")
    popup.BackColor := "1E1F22"
    popup.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    popup.MarginX := S(14)
    popup.MarginY := S(14)
    txt := "
    (
HOW TO ADD / EDIT A USER FUNCTION
  Click the "? User Scripts" button right of the row to open the
  User Function Library. There you can:
    - New   - Create a new .ahk file
    - Edit  - Modify an existing user script
    - Delete- Remove a user script
    - Copy Path - Copy the full file path to clipboard

  A user script is just a .ahk file in user_hotkey_scripts\ with one
  or more callable functions. Use the "? User Scripts" dialog to
  write your function body directly.

  After creating, the function appears in Function Browser under
  Source: "User Script". Double-click or Copy to use it.

CATEGORY (filter)
  Guide, Pie, Color, Timer, Debug, Link, System, Toggle,
  User, GUI, Hotkey, Built-in, Runtime

SOURCE (filter)
  Built-in, Hotkey Action, User Script, Runtime

RISK badges
  Needs Nastar / Needs Animation_aa / Needs CSP
  Writes Files / Settings I/O / UI / User Script
  Internal / External Target / Submenu / Navigation

SUMMARY metadata (for user scripts)
  Add comments near the top of your .ahk file:
    ; Summary: what this function does
    ; Category: User
    ; Risk: Settings I/O, Writes Files
    ; Requirement: Nastar.laf
    MyFunction() { ... }
  Requirement (optional): Nastar.laf, Animation_autoaction.laf, or a
  user script file name. A hotkey that uses this script auto-fills its
  Requirement field; without it the script name is used as the
  Requirement. User scripts run standalone - no manual #Include needed.

BLOCK manifest
  Claim shortcuts from the main toolkit with a Block header:
    ; Block: ^!+l, +1, +2, +3, +4, +5, +6, +7, +8, +9, +0, ^!+k
  The script registers those keys to itself and matching toolkit
  shortcuts are disabled on the next toolkit reload. Conflicting
  claims between user scripts show an alert and are skipped.
    )"
    popup.AddText("xm w" S(430) " cFFFFFF", txt)
    popup.AddButton("xm y+10 w" S(80) " h" S(26) " Default", "OK").OnEvent("Click", (*) => popup.Destroy())
    popup.Show("AutoSize")
}

HK_ShowFunctionFieldGuide(*) {
    popup := Gui("+AlwaysOnTop +ToolWindow", "AHK Function Guide")
    popup.BackColor := "1E1F22"
    popup.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    popup.MarginX := S(14)
    popup.MarginY := S(14)
    txt := "
    (
WHAT THIS FIELD DOES
  The AHK Function field tells the toolkit what function name to call.

VALID INPUT
  FunctionName
  FunctionName()

GOOD EXAMPLES
  TimerToggle
  ShowCSPGuide
  HotkeyLayerBlack
  MyUserFunction

WHERE THE FUNCTION CAN COME FROM
  - Built-in toolkit functions
  - Included toolkit source files
  - Your user function library scripts

HOW TO FIND ONE
  - Use Pick to open Function Browser
  - Test Fn runs the function immediately
  - Jump... in Function Browser shows where a function is already used

FOR USER HOTKEYS
  If you write a custom script below, the function name here must match
  a callable function inside that script.

EXAMPLE
  AHK Function:
    SampleActionFunction

  Script:
    SampleActionFunction() {
        Send('^c')
        ShowNotify('User Function', 'Copied')
    }
    )"
    popup.AddText("xm w" S(410) " cFFFFFF", txt)
    popup.AddButton("xm y+10 w" S(84) " h" S(26) " Default", "OK").OnEvent("Click", (*) => popup.Destroy())
    popup.Show("AutoSize")
}
