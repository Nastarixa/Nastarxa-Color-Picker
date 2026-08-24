; HOTKEY ACTION LIBRARY
; ============================================================
; CSP macro actions (Hotkey* + Function*) used as HotkeyDefs targets and by pie/color GUIs.
; Extracted from hotkey_core.ahk for modularity. Each action sends CSP shortcuts via
; HotkeySendCSP/HotkeySendShortcut.


HotkeyIB1(*) {
    global InbetweenIndex
    SelectIB(InbetweenIndex)
}
HotkeyChangeColor(*) {
    global ColorClick1X, ColorClick1Y, ColorClick2X, ColorClick2Y
    if !IsLTActive()
        ResetLT()
    Click "Up Left"
    Sleep 50
    MouseClick "left", ColorClick1X, ColorClick1Y
    Sleep 100
    HotkeySendCSP("^+=")
    Click "Up Left"
    Sleep 125
    MouseClick "left", ColorClick2X, ColorClick2Y
    Sleep 100
    HotkeySendCSP("^+-")
    Click "Up Left"
    ShowNotify("Change LT Image 1/3 Half Color")
    ResetLT()
}
HotkeyToggleOnion(*) {
    static t := false
    HotkeySendCSP("!w")
    k := HK_GetCurrentKey("HotkeyToggleOnion", "Alt+W")
    ShowNotify("Toggle Onion Skin: " k, (t := !t) ? "On" : "Off")
}
HotkeyToggleLT(*) {
    static t := false
    HotkeySendCSP("^!w")
    ShowNotify("Toggle Light Table", (t := !t) ? "On" : "Off")
}
HotkeySwapBrush(*) {
    static t := false
    HotkeySendCSP("x")
    ShowNotify("Brush Color", (t := !t) ? "Secondary" : "Primary")
}
HotkeyToggleTransparent(*) {
    static t := false
    HotkeySendCSP("!c")
    ShowNotify("Brush Transparent", (t := !t) ? "Transparent" : "Solid")
}
HotkeySelectNextCel(*) {
    global _selectCelMode
    ltWasActive := IsLTActive()
    if ltWasActive && _selectCelMode = 1 {
        ResetLT()
        Sleep 100
    }
    SendCleanAltKey("d")
    DebugLog("Select Next Cel: Alt+D" (ltWasActive && _selectCelMode = 1 ? " after LT reset" : ""))
    ShowNotify("Select Next Cel", HK_GetCurrentKey("HotkeySelectNextCel"))
}
HotkeySelectPrevCel(*) {
    global _selectCelMode
    ltWasActive := IsLTActive()
    if ltWasActive && _selectCelMode = 1 {
        ResetLT()
        Sleep 100
    }
    SendCleanAltKey("a")
    DebugLog("Select Previous Cel: Alt+A" (ltWasActive && _selectCelMode = 1 ? " after LT reset" : ""))
    ShowNotify("Select Previous Cel", HK_GetCurrentKey("HotkeySelectPrevCel"))
}
HotkeySelectNextLTCel(*) {
    if IsLTActive() {
        SendCleanAltKey("d")
        DebugLog("Select Next LT Cel: Ctrl+Alt+D -> Alt+D")
        ShowNotify("Select Next LT Cel", HK_GetCurrentKey("HotkeySelectNextLTCel"))
    } else {
        DebugLog("Select Next LT Cel ignored: LT inactive")
    }
}
HotkeySelectPrevLTCel(*) {
    if IsLTActive() {
        SendCleanAltKey("a")
        DebugLog("Select Previous LT Cel: Ctrl+Alt+A -> Alt+A")
        ShowNotify("Select Previous LT Cel", HK_GetCurrentKey("HotkeySelectPrevLTCel"))
    } else {
        DebugLog("Select Previous LT Cel ignored: LT inactive")
    }
}

SendCleanAltKey(key) {
    HotkeySendCSP("!" key)
}

HotkeyPrevFrame(*) {
    HotkeySendCSP("a")
    DebugLog("Prev Frame: a")
    ShowNotify("Previous Frame", HK_GetCurrentKey("HotkeyPrevFrame"))
}
HotkeyNextFrame(*) {
    HotkeySendCSP("d")
    DebugLog("Next Frame: d")
    ShowNotify("Next Frame", HK_GetCurrentKey("HotkeyNextFrame"))
}

HotkeyLWinRightClick(*) => Send("{RButton}")
HotkeyScrollDown(*) {
    global Speed
    Send("{WheelDown " Speed "}")
}
HotkeyScrollUp(*) {
    global Speed
    Send("{WheelUp " Speed "}")
}
HotkeyIB2(*) => SelectIB(1)
HotkeyIB3(*) => SelectIB(2)
HotkeyIB4(*) => SelectIB(3)
HotkeyIB5(*) => SelectIB(4)
HotkeyIB6(*) => SelectIB(5)
HotkeyIB7(*) => SelectIB(6)
HotkeyIB8(*) => SelectIB(7)
HotkeyIBEmpty(*) => SelectIB(8)
CapsLockNumberGuard() {
    global HOLD_THRESHOLD_MS
    if !GetKeyState("CapsLock", "P")
        return true
    Sleep(Min(35, Max(10, HOLD_THRESHOLD_MS // 2)))
    return !GetKeyState("CapsLock", "P")
}

HotkeyLayerBlack(*) {
    if CapsLockNumberGuard()
        DoLayer("1", "Black")
}
HotkeyLayerRed(*) {
    if CapsLockNumberGuard()
        DoLayer("2", "Red", "0xBF0000")
}
HotkeyLayerBlue(*) {
    if CapsLockNumberGuard()
        DoLayer("3", "Blue", "0x487AE3")
}
HotkeyLayerGreen(*) {
    if CapsLockNumberGuard()
        DoLayer("4", "Green", "0x5CD377")
}
HotkeyLayerPink(*) {
    if CapsLockNumberGuard()
        DoLayer("5", "Pink", "0xC11C84")
}
HotkeyLayerCyan(*) {
    if CapsLockNumberGuard()
        DoLayer("6", "Cyan", "0x00BCD4")
}
HotkeyLayerOrange(*) {
    if CapsLockNumberGuard()
        DoLayer("7", "Orange", "0xFF9800")
}
HotkeyLayerUranuri(*) {
    if CapsLockNumberGuard()
        DoLayer("8", "Uranuri / Shadow", "", "{g}")
}
HotkeyLayerPaint(*) {
    if CapsLockNumberGuard()
        DoLayer("9", "Paint")
}
HotkeyLayerRough(*) {
    if CapsLockNumberGuard()
        DoLayer("0", "Rough")
}
HotkeyLayerSelect2(*) {
    if CapsLockNumberGuard()
        DoLayer("2", "Second Layer", "0x7FDBFF")
}
HotkeyLayerSelect3(*) {
    if CapsLockNumberGuard()
        DoLayer("3", "Third Layer", "0x5DADE2")
}
HotkeyLayerSelect4(*) {
    if CapsLockNumberGuard()
        DoLayer("4", "Fourth Layer", "0x3498DB")
}
HotkeyLayerSelect5(*) {
    if CapsLockNumberGuard()
        DoLayer("5", "Fifth Layer", "0x2E86C1")
}
HotkeyLayerSelect6(*) {
    if CapsLockNumberGuard()
        DoLayer("6", "Sixth Layer", "0x1F618D")
}
HotkeyLayerSelect7(*) {
    if CapsLockNumberGuard()
        DoLayer("7", "Seventh Layer", "0x154360")
}
HotkeyLayerSelect8(*) {
    if CapsLockNumberGuard()
        DoLayer("8", "Eighth Layer", "0x0E3A53")
}
HotkeyLayerSelect9(*) {
    if CapsLockNumberGuard()
        DoLayer("9", "Ninth Layer", "0x092C46")
}
HotkeyLayerSelect10(*) {
    if CapsLockNumberGuard()
        DoLayer("0", "Tenth Layer", "0x041E32")
}
HotkeySendShortcut(_, keys) {
    HotkeySendCSP(keys)
}
HotkeySendCSP(keys) {
    if !WinExist("ahk_exe CLIPStudioPaint.exe") {
        ShowNotify("CSP not found", "Open Clip Studio Paint first", "0xE53935")
        return false
    }
    if !WinActive("ahk_exe CLIPStudioPaint.exe") {
        WinActivate("ahk_exe CLIPStudioPaint.exe")
        WinWaitActive("ahk_exe CLIPStudioPaint.exe",, 0.5)
    }
    Send("{Ctrl Up}{Shift Up}{Alt Up}" keys)
    ; Reassert GUI topmost Z-order in case CSP activation buried them
    try _FixGUIZ()
    return true
}

HotkeyCreatePaperLayer(sendKeys := false, *) {
    HotkeySendShortcut(sendKeys, "!1")
    ShowNotify("New Paper Layer", HK_GetCurrentKey("HotkeyCreatePaperLayer", "Alt+1"))
}
HotkeyCreateRasterLayer(sendKeys := false, *) {
    HotkeySendShortcut(sendKeys, "!2")
    ShowNotify("New Raster Layer", HK_GetCurrentKey("HotkeyCreateRasterLayer", "Alt+2"))
}
HotkeyCreateVectorLayer(sendKeys := false, *) {
    HotkeySendShortcut(sendKeys, "!3")
    ShowNotify("New Vector Layer", HK_GetCurrentKey("HotkeyCreateVectorLayer", "Alt+3"))
}
HotkeyCreateColoredVectorLayer(sendKeys := false, *) {
    HotkeySendShortcut(sendKeys, "!4")
    ShowNotify("New Colored Vector Layer", HK_GetCurrentKey("HotkeyCreateColoredVectorLayer", "Alt+4"))
}
HotkeyCreateDummyLayer(sendKeys := false, *) {
    HotkeySendShortcut(sendKeys, "!5")
    ShowNotify("New Dummy Layer", HK_GetCurrentKey("HotkeyCreateDummyLayer", "Alt+5"))
}
HotkeySeparateBlackLine(sendKeys := false, *) {
    HotkeySendShortcut(sendKeys, "!6")
    ShowNotify("Separate Black Line + Paint", HK_GetCurrentKey("HotkeySeparateBlackLine", "Alt+6"))
}
HotkeyCreatePinkVectorLayer(sendKeys := false, *) {
    HotkeySendShortcut(sendKeys, "!7")
    ShowNotify("New Pink Vector Layer", HK_GetCurrentKey("HotkeyCreatePinkVectorLayer", "Alt+7"))
}
HotkeyCreateCyanVectorLayer(sendKeys := false, *) {
    HotkeySendShortcut(sendKeys, "!8")
    ShowNotify("New Cyan Vector Layer", HK_GetCurrentKey("HotkeyCreateCyanVectorLayer", "Alt+8"))
}
HotkeyCreateOrangeVectorLayer(sendKeys := false, *) {
    HotkeySendShortcut(sendKeys, "!9")
    ShowNotify("New Orange Vector Layer", HK_GetCurrentKey("HotkeyCreateOrangeVectorLayer", "Alt+9"))
}
HotkeyCreateAnimationFolder(sendKeys := false, *) {
    HotkeySendShortcut(sendKeys, "!0")
    ShowNotify("New Animation Folder", HK_GetCurrentKey("HotkeyCreateAnimationFolder", "Alt+0"))
}
HotkeyFeatureKeyframeColor(sendKeys := false, *) {
    HotkeySendShortcut(sendKeys, "^+1")
    ShowNotify("Set Layer Keyframe Color", HK_GetCurrentKey("HotkeyFeatureKeyframeColor", "CTRL+Shift+1"))
}
HotkeyFeatureReferenceColor(sendKeys := false, *) {
    HotkeySendShortcut(sendKeys, "^+2")
    ShowNotify("Set Layer Reference Color", HK_GetCurrentKey("HotkeyFeatureReferenceColor", "CTRL+Shift+2"))
}
HotkeyFeatureRemoveLayerColor(sendKeys := false, *) {
    HotkeySendShortcut(sendKeys, "^+3")
    ShowNotify("Remove Layer Keyframe Color", HK_GetCurrentKey("HotkeyFeatureRemoveLayerColor", "CTRL+Shift+3"))
}
HotkeyFeatureHalfGreen(sendKeys := false, *) {
    HotkeySendShortcut(sendKeys, "^+=")
    ShowNotify("LT Half Color Green", HK_GetCurrentKey("HotkeyFeatureHalfGreen", "CTRL+Shift+="))
}
HotkeyFeatureHalfPurple(sendKeys := false, *) {
    HotkeySendShortcut(sendKeys, "^+-")
    ShowNotify("LT Half Color Purple", HK_GetCurrentKey("HotkeyFeatureHalfPurple", "CTRL+Shift+-"))
}
HotkeyFeatureNormalColor(sendKeys := false, *) {
    HotkeySendShortcut(sendKeys, "^+5")
    ShowNotify("Normal Color", HK_GetCurrentKey("HotkeyFeatureNormalColor", "CTRL+Shift+5"))
    ResetLT()
}
HotkeyFeaturePaperPurple(sendKeys := false, *) {
    HotkeySendShortcut(sendKeys, "^+7")
    PaperColorShiftCtrlClick()
    ShowNotify("Paper Purple", HK_GetCurrentKey("HotkeyFeaturePaperPurple", "CTRL+Shift+7"))
}
HotkeyFeaturePaperGreen(sendKeys := false, *) {
    HotkeySendShortcut(sendKeys, "^+8")
    PaperColorShiftCtrlClick()
    ShowNotify("Paper Green", HK_GetCurrentKey("HotkeyFeaturePaperGreen", "CTRL+Shift+8"))
}
HotkeyFeaturePaperWhite(sendKeys := false, *) {
    HotkeySendShortcut(sendKeys, "^+9")
    PaperColorShiftCtrlClick()
    ShowNotify("Paper White", HK_GetCurrentKey("HotkeyFeaturePaperWhite", "CTRL+Shift+9"))
}
HotkeyFeatureLayerColorBlack(sendKeys := false, *) {
    HotkeySendShortcut(sendKeys, "^+6")
    ShowNotify("Layer Color Black", HK_GetCurrentKey("HotkeyFeatureLayerColorBlack", "CTRL+Shift+6"))
}
HotkeyUltimateSaveAs(*) {
    global _useUltimateSaveAs, ReqNastarEnabled
    if _useUltimateSaveAs && ReqNastarEnabled {
        HotkeySendCSP("+^!-")
        Sleep(125)
        HotkeySendCSP("^+9")
        Sleep(125)
    }
    HotkeySendCSP("+^s")
}
HotkeyTransferRasterize(*) {
    HotkeySendCSP("{;}")
    HotkeySendCSP("{Home}")
    HotkeySendCSP("^{;}")
    ShowNotify("Transfer Down Vector and Rasterize")
}
HotkeyTransferVector(*) {
    HotkeySendCSP("{;}{Home}")
    ShowNotify("Transfer Down Vector")
}
HotkeyMergeDownLayer(*) {
    HotkeySendCSP("+^!e")
    ShowNotify("Merge Down Layer")
}
HotkeyColorExpressionGray(*) {
    HotkeySendCSP("+^!t")
    ShowNotify("Change Color Expression: Gray")
}
HotkeyDeleteLayer(*) {
    HotkeySendCSP("{Del}")
    ShowNotify("Delete Layer")
}
HotkeyDeletePaintChecker(*) {
    HotkeySendCSP("+^!{Del}")
    ShowNotify("Delete Paint Checker")
}
HotkeyDeleteCelTimeline(*) {
    HotkeySendCSP("^+X")
    ShowNotify("Delete Cel from Timeline")
}
HotkeyEditTrackCopy(*) {
    HotkeySendCSP("^+c")
    ShowNotify("Edit Track: Copy")
}
HotkeyEditTrackPaste(*) {
    HotkeySendCSP("^+v")
    ShowNotify("Edit Track: Paste")
}
HotkeyDeleteCelLighttable(*) {
    HotkeySendCSP("+X")
    ShowNotify("Delete Cel from Lighttable")
}
HotkeySlashCommand(*) => HotkeySendCSP("{/}")
HotkeyOpacity100(*) {
    HotkeySendCSP("+b")
    ShowNotify("Opacity 100", HK_GetCurrentKey("HotkeyOpacity100", "Shift+B"))
}
HotkeyOpacity50(*) {
    HotkeySendCSP("!b")
    ShowNotify("Opacity 50", HK_GetCurrentKey("HotkeyOpacity50", "Alt+B"))
}
HotkeyOpacity25(*) {
    HotkeySendCSP("!^b")
    ShowNotify("Opacity 25", HK_GetCurrentKey("HotkeyOpacity25", "Ctrl+Alt+B"))
}
HotkeyToggleLayerColor(*) {
    HotkeySendCSP("^b")
    ShowNotify("Toggle Layer Color", HK_GetCurrentKey("HotkeyToggleLayerColor", "Ctrl+B"))
}
HotkeyDuplicateLayer(*) {
    HotkeySendCSP("+^!d")
    ShowNotify("Duplicate Layer", HK_GetCurrentKey("HotkeyDuplicateLayer", "Ctrl+Shift+Alt+D"))
}
HotkeyCreateFolderInsertLayer(*) {
    HotkeySendCSP("+^!g")
    ShowNotify("Create Folder and Insert Layer", HK_GetCurrentKey("HotkeyCreateFolderInsertLayer", "Ctrl+Shift+Alt+G"))
}
HotkeyUngroupLayerFolder(*) {
    HotkeySendCSP("!^g")
    ShowNotify("Ungroup Layer Folder", HK_GetCurrentKey("HotkeyUngroupLayerFolder", "Ctrl+Alt+G"))
}
HotkeyToggleLayerVisibility(*) {
    HotkeySendCSP("!v")
    ShowNotify("Toggle Layer Visibility", HK_GetCurrentKey("HotkeyToggleLayerVisibility", "Alt+V"))
}
HotkeyInsertOnionToLTCell(*) {
    HotkeySendCSP("!w")
    Sleep 80
    HotkeySendCSP("+!w")
    Sleep 80
    HotkeySendCSP("!w")
}
HotkeyPaintTransparent(*) {
    HotkeySendCSP("+^!f")
    ShowNotify("Paint Alpha/Transparent", "", "0x333333")
}
HotkeyPaintRedLine(*) {
    HotkeySendCSP("+^!c")
    ShowNotify("Paint Red Line", "", "0xBF0000")
}
HotkeyPaintGreenLine(*) {
    HotkeySendCSP("+^!v")
    ShowNotify("Paint Green Line", "", "0x5CD377")
}
HotkeyPaintBlueLine(*) {
    HotkeySendCSP("+^!b")
    ShowNotify("Paint Blue Line", "", "0x487AE3")
}
HotkeyPaintPinkLine(*) {
    HotkeySendCSP("+^!n")
    ShowNotify("Paint Pink Line", "", "0xFF00FF")
}
HotkeyPaintCyanLine(*) {
    HotkeySendCSP("+^!m")
    ShowNotify("Paint Cyan Line", "", "0x00FFF0")
}
HotkeyPaintOrangeLine(*) {
    HotkeySendCSP("+^!,")
    ShowNotify("Paint Orange Line", "", "0xFA9600")
}
HotkeyPaintPurpleLine(*) {
    HotkeySendCSP("+^!.")
    ShowNotify("Paint Purple Line", "", "0x9C27B0")
}
HotkeySetToPaintAnimation(*) {
    HotkeySendCSP("+^!{Insert}")
    ShowNotify("Set to Paint: Animation", HK_GetCurrentKey("HotkeySetToPaintAnimation", "Ctrl+Shift+Alt+Insert"), "0x689F38")
}
HotkeySetCelsToTrack(*) {
    try {
        if !HotkeySendCSP("+^!{PgUp}")
            return
        Sleep(200)
        Send("{Tab}")
        Send("{Tab}")
        Send("{Tab}")
        Send("{Down}")
        Send("{Enter}")
    } 
    catch as e
        DebugLog("HotkeySetCelsToTrack: send failed - " e.Message)
    try ShowNotify("Set Cels to Track", HK_GetCurrentKey("HotkeySetCelsToTrack", "Ctrl+Shift+Alt+PageUp"), "0x689F38")
    catch as e
        DebugLog("HotkeySetCelsToTrack: ShowNotify failed - " e.Message)
}
HotkeyPaintCheckerLayer(*) {
    try HotkeySendCSP("+^!{End}")
    catch as e
        DebugLog("HotkeyPaintCheckerLayer: HotkeySendCSP failed - " e.Message)
    try keyText := HK_GetCurrentKey("HotkeyPaintCheckerLayer", "Ctrl+Shift+Alt+End")
    catch
        keyText := "Ctrl+Shift+Alt+End"
    try ShowNotify("Paint Check: Layer", keyText, "0x8BC34A")
    catch as e
        DebugLog("HotkeyPaintCheckerLayer: ShowNotify failed - " e.Message)
}
FunctionPaintCheckerLayer(*) {
    HotkeyPaintCheckerLayer()
}

HotkeyPaintCheckerImage(*) {
    try HotkeySendCSP("+^!{Home}")
    catch as e
        DebugLog("HotkeyPaintCheckerImage: HotkeySendCSP failed - " e.Message)
    try keyText := HK_GetCurrentKey("HotkeyPaintCheckerImage", "Ctrl+Shift+Alt+Home")
    catch
        keyText := "Ctrl+Shift+Alt+Home"
    try ShowNotify("Paint Checker: Image", keyText, "0x8BC34A")
    catch as e
        DebugLog("HotkeyPaintCheckerImage: ShowNotify failed - " e.Message)
}
FunctionPaintCheckerImage(*) {
    HotkeyPaintCheckerImage()
}
HotkeyVectorPaths(*) {
    if WinExist("ahk_exe CLIPStudioPaint.exe") {
        WinActivate("ahk_exe CLIPStudioPaint.exe")
        WinWaitActive("ahk_exe CLIPStudioPaint.exe",, 0.5)
        HotkeySendCSP("^+![")
        Sleep(20)
        HotkeySendCSP("^+!]")
        ShowNotify("Vector Paths")
    } else
        ShowNotify("CSP not found", "Open Clip Studio Paint first", "0xE53935")
}
HotkeyToggleDraft(*) {
    HotkeySendCSP("+^!'")
    ShowNotify("Toggle Draft Layers Visibility", HK_GetCurrentKey("HotkeyToggleDraft", "Ctrl+Shift+Alt+'"))
}
HotkeyCloseAllFolder(*) {
    HotkeySendCSP("+^!-")
    ShowNotify("Close All Folder", HK_GetCurrentKey("HotkeyCloseAllFolder", "Ctrl+Shift+Alt+-"))
}
HotkeyOpenFolder(*) {
    HotkeySendCSP("+^!=")
    ShowNotify("Open Folder", HK_GetCurrentKey("HotkeyOpenFolder", "Ctrl+Shift+Alt+="))
}
HotkeyColorPicker(*) {
    HotkeySendCSP("+^b")
    ShowNotify("Color Picker", HK_GetCurrentKey("HotkeyColorPicker", "CTRL+Shift+B"))
}
HotkeyReferenceLayer(*) {
    HotkeySendCSP("+^q")
    ShowNotify("Set as Reference Layer")
}
HotkeyIsolateLayer(*) {
    HotkeySendCSP("+^!q")
    ShowNotify("Isolate Layer", HK_GetCurrentKey("HotkeyIsolateLayer", "Ctrl+Shift+Alt+Q"))
}
HotkeyDraftLayer(*) {
    HotkeySendCSP("+^f")
    ShowNotify("Set as Draft Layer")
}
HotkeyClipToLayerBelow(*) {
    HotkeySendCSP("+^g")
    ShowNotify("Clip to Layer Below")
}
HotkeyLockLayer(*) {
    HotkeySendCSP("+^r")
    ShowNotify("Lock Layer")
}
HotkeyLockTransparent(*) {
    HotkeySendCSP("+^e")
    ShowNotify("Lock Layer Transparent")
}
HotkeyLockAnimationCel(*) {
    HotkeySendCSP("+^w")
    ShowNotify("Lock Animation Cel")
}
HotkeyResetColor(*) {
    HotkeySendCSP("+c")
    ShowNotify("Reset Color", HK_GetCurrentKey("HotkeyResetColor", "Shift+C"))
}
HotkeyLayerUp(sendKeys := true, *) {
    HotkeySendShortcut(sendKeys, "+!z")
    ShowNotify("Layer Up", HK_GetCurrentKey("HotkeyLayerUp", "Shift+Alt+Z"), "0x4CAF50")
}
HotkeyLayerDown(sendKeys := true, *) {
    HotkeySendShortcut(sendKeys, "+!x")
    ShowNotify("Layer Down", HK_GetCurrentKey("HotkeyLayerDown", "Shift+Alt+X"), "0xE53935")
}
HotkeyTopLayer(sendKeys := true, *) {
    HotkeySendShortcut(sendKeys, "[")
    ShowNotify("Top Layer", HK_GetCurrentKey("HotkeyTopLayer", "["), "0x2196F3")
}
HotkeyBottomLayer(sendKeys := true, *) {
    HotkeySendShortcut(sendKeys, "]")
    ShowNotify("Bottom Layer", HK_GetCurrentKey("HotkeyBottomLayer", "]"), "0xFB8C00")
}

HotkeyOpenPie1(*) {
    ShowPieMenu(1)
}
HotkeyOpenPie2(*) {
    ShowPieMenu(2)
}
HotkeyOpenPie3(*) {
    ShowPieMenu(3)
}

UranColor1(*) => ShowNotify("Beige Skin", "Shadow: Skin", "0x9A7B58")
UranColor2(*) => ShowNotify("Pale Yellow", "Highlight", "0x9A9A58")
UranColor3(*) => ShowNotify("Light Cyan", "Shadow: Clothes", "0x5C8E92")
UranColor4(*) => ShowNotify("Pale Green", "Shadow: Clothes", "0x6E9868")
UranColor5(*) => ShowNotify("Light Pink", "Shadow: Hair", "0x967886")
UranColor6(*) => ShowNotify("Lavender Blue", "2 Shadow: Hair", "0x7A7A96")
UranColor7(*) => ShowNotify("Coral Pink", "2 Shadow: Skin", "0x966458")
UranColor8(*) => ShowNotify("Green Mint", "2 Shadow / Black", "0x4E7873")
UranColor9(*) => ShowNotify("Sky Blue", "2 Shadow", "0x448090")
UranColor10(*) => ShowNotify("Red-Orange", "2 Shadow", "0x942C20")
UranColor11(*) => ShowNotify("Magenta", "Ground Shadow", "0x960096")
