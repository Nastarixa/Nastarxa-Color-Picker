CreateMainGui() => ToolScaleCall(CreateMainGui_Impl)

CreateMainGui_Impl() {
    global MainGUI, IB_GUI, ColorGUI, LinkGUI
    global IBVisible, ColorGUIVisible, LinkGUIVisible
    global GUIEnabled
    global MainGUIVisible
    MainGUI := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000", "Main Control")
    MainGUI.BackColor := "1E1F22"
    MainGUI.SetFont("s" S(8) " cFFFFFF", "Segoe UI")
    MainGUI.MarginX := S(4)
    MainGUI.MarginY := S(6)
    MainGUI.OnEvent("ContextMenu", MainGUI_ContextMenu)

    dragLabel := MainGUI.AddText("xm w" S(135) " Center c777777 +0x200", "————— Main —————")
    dragLabel.OnEvent("Click", MainGuiBeginDrag)
    btnIB := MainGUI.AddText("xm w" S(30) " h" S(24) " Center +0x200 Background2A2A2A cFFFFFF", "IB")
    btnIB.SetFont("s" S(7) " Bold", "Segoe UI")
    btnIB.OnEvent("Click", (*) => ToggleMainGUI(1))

    btnLink := MainGUI.AddText("x+" S(4) " yp w" S(30) " h" S(24) " Center +0x200 Background2A2A2A cFFFFFF", "Link")
    btnLink.SetFont("s" S(7) " Bold", "Segoe UI")
    btnLink.OnEvent("Click", (*) => ToggleMainGUI(2))

    btnColor := MainGUI.AddText("x+" S(4) " yp w" S(32) " h" S(24) " Center +0x200 Background2A2A2A cFFFFFF", "Color")
    btnColor.SetFont("s" S(7) " Bold", "Segoe UI")
    btnColor.OnEvent("Click", (*) => ToggleMainGUI(3))

    btnClose := MainGUI.AddText("x+" S(4) " yp w" S(30) " h" S(24) " Center +0x200 BackgroundE53935 cFFFFFF", "✕")
    btnClose.SetFont("s" S(7) " Bold", "Segoe UI")
    AddHoverPopup(btnClose, "Close Main GUI")
    btnClose.OnEvent("Click", (*) => (MainGUI.Hide(), MainGUIVisible := false))

    MainGUI.AddText("xm+2 y+" S(6) " w" S(130) " h" S(1) " +0x200 Background555555")

    ; second row
    btnResetPos := MainGUI.AddText("xm y+" S(6) " w" S(24) " h" S(24) " Center +0x200 BackgroundE53935 cFFFFFF", "⟲")
    btnResetPos.SetFont("s" S(8) " Bold", "Segoe UI")
    AddHoverPopup(btnResetPos, "Reset GUI Positions")
    btnResetPos.OnEvent("Click", (*) => ResetGUIPositions())

    btnColorMgr := MainGUI.AddText("x+" S(4) " yp w" S(24) " h" S(24) " Center +0x200 Background607D8B cFFFFFF", "🎨")
    btnColorMgr.SetFont("s" S(7) " Bold", "Segoe UI")
    AddHoverPopup(btnColorMgr, "Color GUI Manager")
    btnColorMgr.OnEvent("Click", (*) => ShowColorManager())

    btnLinkMgr := MainGUI.AddText("x+" S(4) " yp w" S(24) " h" S(24) " Center +0x200 Background607D8B cFFFFFF", "🔗")
    btnLinkMgr.SetFont("s" S(7) " Bold", "Segoe UI")
    AddHoverPopup(btnLinkMgr, "Link Button Manager")
    btnLinkMgr.OnEvent("Click", (*) => ShowLinkManager())

    btnSettings := MainGUI.AddText("x+" S(4) " yp w" S(24) " h" S(24) " Center +0x200 Background455A64 cFFFFFF", "⚙")
    btnSettings.SetFont("s" S(7) " Bold", "Segoe UI")
    AddHoverPopup(btnSettings, "System Settings")
    btnSettings.OnEvent("Click", (*) => ShowLTSettings())

    btnHotkey := MainGUI.AddText("x+" S(4) " yp w" S(24) " h" S(24) " Center +0x200 Background455A64 cFFFFFF", "⌨")
    btnHotkey.SetFont("s" S(8) " Bold", "Segoe UI")
    AddHoverPopup(btnHotkey, "Hotkey Settings")
    btnHotkey.OnEvent("Click", (*) => ShowHotkeySettings())

    ; third row
    btnOpacity := MainGUI.AddText("xm y+" S(6) " w" S(42) " h" S(22) " Center +0x200 Background546E7A cFFFFFF", "GUI")
    btnOpacity.SetFont("s" S(7) " Bold", "Segoe UI")
    AddHoverPopup(btnOpacity, "GUI Opacity Settings")
    btnOpacity.OnEvent("Click", (*) => ShowOpacitySlider("Main"))

    btnDebug := MainGUI.AddText("x+" S(5) " yp w" S(42) " h" S(22) " Center +0x200 Background546E7A cFFFFFF", "Debug")
    btnDebug.SetFont("s" S(7) " Bold", "Segoe UI")
    AddHoverPopup(btnDebug, "Debug Log")
    btnDebug.OnEvent("Click", (*) => ShowDebugGUI())

    btnHotkeys := MainGUI.AddText("x+" S(5) " yp w" S(42) " h" S(22) " Center +0x200 Background4CAF50 cFFFFFF", "HK")
    btnHotkeys.SetFont("s" S(7) " Bold", "Segoe UI")
    AddHoverPopup(btnHotkeys, "Pause / Resume all custom hotkeys")
    btnHotkeys.OnEvent("Click", (*) => ToggleHotkeysPause())

    btnStatus := MainGUI.AddText("xm y+" S(6) " w" S(66) " h" S(22) " Center +0x200 Background455A64 cFFFFFF", "Status")
    btnStatus.SetFont("s" S(7) " Bold", "Segoe UI")
    AddHoverPopup(btnStatus, "Status Dashboard")
    btnStatus.OnEvent("Click", (*) => ShowStatusDashboard())

    btnSafe := MainGUI.AddText("x+" S(5) " yp w" S(65) " h" S(22) " Center +0x200 BackgroundB71C1C cFFFFFF", "Safe")
    btnSafe.SetFont("s" S(7) " Bold", "Segoe UI")
    AddHoverPopup(btnSafe, "Safe Mode: pause hotkeys, turn modes off, release held keys")
    btnSafe.OnEvent("Click", (*) => SafeMode())

    btnHealthBadge := MainGUI.AddText("xm y+" S(6) " w" S(136) " h" S(18) " Center +0x200 Background2E7D32 cFFFFFF", "Health: OK")
    btnHealthBadge.SetFont("s" S(7) " Bold", "Segoe UI")
    AddHoverPopup(btnHealthBadge, "Startup Health Badge: click to open Settings Health")
    btnHealthBadge.OnEvent("Click", ShowSettingsHealth)

    ; version row below the health badge
    MainGUI.Version := MainGUI.AddText("xm y+" S(6) " w" S(136) " c555555 Center 0x200", "——— Version " SCRIPT_VERSION " ———")
    MainGUI.Version.OnEvent("Click", MainGuiBeginDrag)

    ; mode selector row
    bgColor := "3949AB"
    btnMode := MainGUI.AddText("xm y+" S(6) " w" S(136) " h" S(22) " Center +0x200 Background" bgColor " c" ContrastColor(bgColor), "Mode: Default")
    btnMode.SetFont("s" S(7) " Bold", "Segoe UI")
    AddHoverPopup(btnMode, "Select active mode")
    btnMode.OnEvent("Click", ShowModeSelector)
    MainGUI.btnMode := btnMode

    ; feature switcher row
    btnFeatures := MainGUI.AddText("xm y+" S(6) " w" S(136) " h" S(22) " Center +0x200 Background37474F cFFFFFF", "◉ Feature Switcher")
    btnFeatures.SetFont("s" S(7) " Bold", "Segoe UI")
    AddHoverPopup(btnFeatures, "Turn features on/off (blocks each feature's activation shortcut)")
    btnFeatures.OnEvent("Click", (*) => ShowFeatureSwitcher())
    MainGUI.btnFeatures := btnFeatures

    ; pie oven + countdown timer row
    btnPieOven := MainGUI.AddText("xm y+" S(6) " w" S(66) " h" S(22) " Center +0x200 Background8D6E63 cFFFFFF", "◷ Pie Oven")
    btnPieOven.SetFont("s" S(7) " Bold", "Segoe UI")
    AddHoverPopup(btnPieOven, "Pie Menu and Sub Pie Manager")
    btnPieOven.OnEvent("Click", (*) => ShowPieOven())
    btnCountdown := MainGUI.AddText("x+4 yp w" S(66) " h" S(22) " Center +0x200 Background78909C cFFFFFF", "⏱ Countdown")
    btnCountdown.SetFont("s" S(7) " Bold", "Segoe UI")
    AddHoverPopup(btnCountdown, "Open Countdown Timer")
    btnCountdown.OnEvent("Click", (*) => TimerCountdownShow())

    ; share presets + guide centre row
    btnSharePresets := MainGUI.AddText("xm y+" S(6) " w" S(66) " h" S(22) " Center +0x200 Background555555 cFFFFFF", "↗ Share")
    btnSharePresets.SetFont("s" S(7) " Bold", "Segoe UI")
    AddHoverPopup(btnSharePresets, "Import/Export preset bundles (hotkeys, pies, colors, links)")
    btnSharePresets.OnEvent("Click", (*) => ShowPresetWizardExport())
    btnGuideCentre := MainGUI.AddText("x+4 yp w" S(66) " h" S(22) " Center +0x200 Background26A69A cFFFFFF", "📖 Guide")
    btnGuideCentre.SetFont("s" S(7) " Bold", "Segoe UI")
    AddHoverPopup(btnGuideCentre, "Open all guides and help pages")
    btnGuideCentre.OnEvent("Click", (*) => ShowGuideCentre())

    MainGUI.dragTop := MainGUI.AddText("xm y+" S(6) " w" S(136) " h" S(8) " +0x200 Background555555", "")
    MainGUI.dragTop.OnEvent("Click", MainGuiBeginDrag)

    MainGUI.btnIB := btnIB
    MainGUI.btnLink := btnLink
    MainGUI.btnColor := btnColor
    MainGUI.btnHotkeys := btnHotkeys
    MainGUI.btnStatus := btnStatus
    MainGUI.btnSafe := btnSafe
    MainGUI.btnHealthBadge := btnHealthBadge
    MainGUI.btnPieOven := btnPieOven
    MainGUI.btnCountdown := btnCountdown
    UpdateMainGuiStateButtons()
}

MainGuiBeginDrag(*) {
    global MainGUI
    hwnd := SafeGuiHwnd(MainGUI)
    if !hwnd
        return
    try PostMessage(0x00A1, 2, 0, , "ahk_id " hwnd)
}

UpdateMainGuiStateButtons() {
    global MainGUI, IBManualHide, LinkManualHide, ColorManualHide
    if GuiHasCtrl(MainGUI, "btnIB")
        MainGUI.btnIB.Opt("Background" (FeatureEnabled("ibgui") ? (IBManualHide ? "E53935" : "4CAF50") : "2A2A2A") " c" (FeatureEnabled("ibgui") ? "FFFFFF" : "777777"))
    if GuiHasCtrl(MainGUI, "btnLink")
        MainGUI.btnLink.Opt("Background" (FeatureEnabled("linkgui") ? (LinkManualHide ? "E53935" : "4CAF50") : "2A2A2A") " c" (FeatureEnabled("linkgui") ? "FFFFFF" : "777777"))
    if GuiHasCtrl(MainGUI, "btnColor")
        MainGUI.btnColor.Opt("Background" (FeatureEnabled("colorgui") ? (ColorManualHide ? "E53935" : "4CAF50") : "2A2A2A") " c" (FeatureEnabled("colorgui") ? "FFFFFF" : "777777"))
    UpdateHotkeysPauseButton()
    UpdateSafeModeButton()
    UpdateStartupHealthBadge()
    UpdateMainModeButton()
}

MainGUI_ContextMenu(guiObj, ctrl, item, isRightClick, x, y) {
    global MainGUIVisible
    if IsObject(ctrl) && MainGUI_ControlSkipsContext(guiObj, ctrl)
        return
    m := Menu()
    m.Add("Hide Main GUI", (*) => (MainGUI.Hide(), MainGUIVisible := false))
    m.Add()
    m.Add("Opacity...", (*) => ShowOpacitySlider("Main"))
    m.Add("Pause / Resume Custom Hotkeys", ToggleHotkeysPause)
    m.Add("Status Dashboard", ShowStatusDashboard)
    m.Add("CSP Setup Validator", ShowCSPSetupValidator)
    m.Add("Broken Action Scanner", ShowBrokenActionScanner)
    m.Add("Safe Mode", SafeMode)
    m.Add("Pie Oven", ShowPieOven)
    m.Add("Countdown Timer", TimerCountdownShow)
    m.Add("Select Mode...", ShowModeSelector)
    m.Add("Debug Log", ShowDebugGUI)
    m.Add()
    m.Add("Backup Config...", BackupConfig)
    m.Add("Restore Config...", RestoreConfig)
    m.Show()
}

MainGUI_ControlSkipsContext(guiObj, ctrl) {
    if ctrl = guiObj.btnSafe || ctrl = guiObj.btnStatus || (guiObj.HasProp("btnPieOven") && ctrl = guiObj.btnPieOven) || (guiObj.HasProp("btnCountdown") && ctrl = guiObj.btnCountdown)
        return true
    return false
}

ToggleMainGUI(n) {
    global MainGUI, IB_GUI, ColorGUI, LinkGUI
    global IBVisible, ColorGUIVisible, LinkGUIVisible
    global IBManualHide, LinkManualHide, ColorManualHide
    global IB_Opacity, Color_Opacity, Link_Opacity
    if n = 1 && !FeatureEnabled("ibgui")
        return
    if n = 2 && !FeatureEnabled("linkgui")
        return
    if n = 3 && !FeatureEnabled("colorgui")
        return
    if n = 1 {
        if IsObject(IB_GUI) {
            if IBVisible && !IBManualHide {
                IB_GUI.Hide()
                IBManualHide := true
            } else {
                IB_PositionGui()
                IBManualHide := false
            }
            IBVisible := !(IBVisible && !IBManualHide)
            DebugLog("IB toggled " (IBManualHide ? "OFF" : "ON") " (opacity " IB_Opacity ")")
        }
        if GuiHasCtrl(MainGUI, "btnIB")
            MainGUI.btnIB.Opt("Background" (IBManualHide ? "E53935" : "4CAF50") " cFFFFFF")
    } else if n = 2 {
        if IsObject(LinkGUI) {
            if LinkGUIVisible && !LinkManualHide {
                LinkGUI.Hide()
                LinkManualHide := true
            } else {
                PositionLinkGUI()
                LinkManualHide := false
            }
            LinkGUIVisible := !(LinkGUIVisible && !LinkManualHide)
            DebugLog("Link toggled " (LinkManualHide ? "OFF" : "ON") " (opacity " Link_Opacity ")")
        }
        if GuiHasCtrl(MainGUI, "btnLink")
            MainGUI.btnLink.Opt("Background" (LinkManualHide ? "E53935" : "4CAF50") " cFFFFFF")
    } else if n = 3 {
        if IsObject(ColorGUI) {
            if ColorGUIVisible && !ColorManualHide {
                ColorGUI.Hide()
                ColorManualHide := true
            } else {
                PositionColorGui()
                ColorManualHide := false
            }
            ColorGUIVisible := !(ColorGUIVisible && !ColorManualHide)
            DebugLog("Color toggled " (ColorManualHide ? "OFF" : "ON") " (opacity " Color_Opacity ")")
        }
        if GuiHasCtrl(MainGUI, "btnColor")
            MainGUI.btnColor.Opt("Background" (ColorManualHide ? "E53935" : "4CAF50") " cFFFFFF")
    }
}

_CSP_DialogDefaults() {
    static titles := [
    "Preferences", "Change settings",
    "Canvas Properties", "Manage Workspace",
    "Register Workspace", "Manage fonts",
    "Command Bar Settings", "Modifier Key Settings",
    "Shortcut Settings",
    "New", "Open", "Save as",
    "Change Canvas Size", "Change Image Resolution",
    "Change page settings",
    "Change Layer Name", "Change color name", "Onion skin settings",
    "Exposure sheet", "Export animation cels",
    "Export webtoon", "Export settings for EPUB data",
    "Batch export", "Image sequence export settings",
    "Export (Single Layer)",
    "Print", "Print Settings",
    "Install path settings for OpenToonz",
    "Layer Property", "Tool Property",
    "Text Settings", "Story Editor",
    "Search Layer", "Material Properties",
    "Material properties",
    "Color settings", "Advanced color settings",
    "Advanced Tool Settings", "Add tool",
    "Tool", "Tool Group", "Tool Settings", "Tool Sliders", "Brush Size",
    "Sub Tool Detail", "Tool property", "Sub Tool",
    "Add from default", "Rename tool group", "Duplicate tool",
    "Create custom tool", "Import tool", "Export tool",
    "Reset to original defaults", "Migrate tool preference",
    "Color Wheel", "Color Slider", "Color Set",
    "Intermediate Color", "Approximate Color",
    "Color History", "Color Mixing",
    "Layer", "Layer Comps", "LayerComps",
    "Vector layer conversion", "New vector layer", "New Raster Layer",
    "New foil layer", "Select layer",
    "Timeline", "Manage timeline", "New timeline",
    "Animation cels", "Export layer comp",
    "All sides view",
    "Navigator", "Sub View",
    "History", "Auto Action",
    "Information", "Item bank", "Align/Distribute",
    "Material",
    "Gaussian blur", "Convert to Panorama", "Remove dust",
    "Adjust line width", "Spin blur", "Radial blur", "Motion blur",
    "Lens Blur", "Curved surface", "ZigZag", "Wave", "Twirl",
    "Ripple", "Polar coordinates", "Pinch", "Geometric distortion",
    "Fish-eye lens", "Brightness/Contrast",
    "Create Perspective Ruler", "Convert layer to file object",
    "Convert Layer", "Select Color Gamut", "Color profile preview",
    "Unsharp mask", "Perlin noise", "Retro film", "Pencil drawing",
    "Normal map", "Noise", "Mosaic", "Crystallize",
    "Chromatic aberration", "Artistic",
    "Hue/Saturation/Luminosity", "Edit gradient",
    "Gradient map", "Binarization", "Color balance",
    "Tone Curve", "Level Correction", "Posterization",
    "Simple tone settings",
    "New frame folder", "Choose body shape for 3D drawing figure",
    "Expand selected area", "Shrink selected area", "Blur border",
    "Workspace import settings", "Change frame rate",
    "Insert frame", "Delete frame",
    "Toei Animation Digital Exposure Sheet settings",
    "Go to specified frame", "Create track label",
    "Create timeline label", "Assign multiple cels",
    "Specific Page", "Add Page", "Import Page", "Replace page",
    "Combine Pages", "Split Pages",
    "Create story folder", "Print file name settings",
    "Prepare group work data", "Obtain group work data",
    "Group working", "Assign member",
    "Reflect change on group work data",
    "Discard change to work folder", "Unassign member",
    "Open conflicting file", "Resolve conflict",
    "Log", "Member's comment", "Group work settings",
    "Migrate", "Migrate tool preference",
    "Smart Smoothing", "Advanced Fill", "Shading Assist",
    "Outline Selection", "Change project settings",
    "Add to presets", "Export timelapse",
    "psd export settings", "Batch import",
    "WebP export settings", "Edit preset",
    "Watermark settings", "Export preview",
    "Print preview", "Quick Access",
    "Command Bar",
    "Add sub tool", "Adjust pen pressure", "Check adjusted settings",
    "Grid/Ruler bar settings", "Selection Launcher Settings",
    "Icon settings", "Color Match", "Colorize",
    "Font list settings", "Create mixing font",
    "Divide frame border equally", "On-screen area settings",
    "Add Page (Advanced)", "Find and Replace",
    "Export PDF format", "3D Preview for Binding",
    "Export fanzine printing data", "Export EPUB data",
    "EPUB advanced settings", "Go to timeline label",
    "2D camera folder",
    "Animated GIF export settings", "Animated sticker (APNG) export settings",
    "Animated WebP Export Settings", "Movie export settings",
    "Export settings for PaintMan:", "OpenToonz scene file export settings",
    "Audio export settings", "Check cel motion by key input",
    "Material:", "Import file",
    "Quick Access Setting", "Settings for",
    "Create new set", "Batch process",
    "Webtoon Story editor"
]
    return titles
}

FocusedControlHwnd(activeHwnd) {
    ctrlHwnd := 0
    if !activeHwnd
        return 0
    try ctrlHwnd := ControlGetFocus("ahk_id " activeHwnd)
    if ctrlHwnd
        return ctrlHwnd
    try {
        pid := 0
        threadId := DllCall("GetWindowThreadProcessId", "Ptr", activeHwnd, "UInt*", &pid, "UInt")
        cbSize := 8 + (A_PtrSize * 6) + 16
        info := Buffer(cbSize, 0)
        NumPut("UInt", cbSize, info, 0)
        if DllCall("GetGUIThreadInfo", "UInt", threadId, "Ptr", info) {
            ctrlHwnd := NumGet(info, 8 + A_PtrSize, "Ptr")
            if ctrlHwnd
                return ctrlHwnd
        }
    }
    return 0
}

TypingSelfTitles() {
    static titles := [
        "Add Hotkey",
        "Capture Hotkey",
        "Hotkey Settings",
        "Edit Hotkey",
        "Edit Link Button",
        "Add Link Button",
        "Edit Pie Slot",
        "Pie Quick Hotkeys",
        "Edit Pie Quick Hotkey",
        "Pie Quick Presets",
        "Function Picker",
        "User Function Library",
        "Add User Function",
        "Edit User Function",
        "Settings Health",
        "Load Timer Log",
        "Load Timer",
        "Save Timer",
        "Stop Timer",
        "Timer File Name",
        "System Settings"
    ]
    return titles
}

TypingCspNonTypingTitles() {
    static titles := [
        "Check cel motion by key input",
        "Timeline",
        "Manage timeline",
        "New timeline",
        "Go to timeline label",
        "Create timeline label"
    ]
    return titles
}

global _TypingCats := []
global _TypingNextCat := 1
global _TypingAdd := Map()
global _TypingDel := Map()
global _TypingDis := Map()
global _TypingLoaded := false
global _TypingEdGui := 0

_TypingSec(id, op) {
    if SubStr(id, 1, 5) = "cust_"
        return "TypingCust_" id "_" op
    pre := id = "csp" ? "TypingDialog" : id = "self" ? "TypingSelf" : "TypingNon"
    return pre op
}

_IniSectionValues(path, sec) {
    vals := []
    try raw := IniRead(path, sec)
    catch
        return vals
    for line in StrSplit(raw, "`n", "`r") {
        clean := Trim(line)
        if clean = ""
            continue
        if RegExMatch(clean, "^[^=]+=(.*)$", &m)
            vals.Push(Trim(m[1]))
    }
    return vals
}

_ArrContains(arr, item) {
    lc := StrLower(item)
    for v in arr
        if StrLower(v) = lc
            return true
    return false
}

_ArrRemove(arr, item) {
    out := []
    lc := StrLower(item)
    removed := false
    for v in arr {
        if !removed && StrLower(v) = lc {
            removed := true
            continue
        }
        out.Push(v)
    }
    return out
}

_TypingListsEnsureLoaded() {
    global _TypingCats, _TypingNextCat, _TypingAdd, _TypingDel, _TypingDis, _TypingLoaded, SETTINGS_FILE
    if _TypingLoaded
        return
    _TypingCats := [
        {id: "csp", label: "CSP dialog titles", behavior: "csp", builtin: true},
        {id: "self", label: "Toolkit dialog titles", behavior: "self", builtin: true},
        {id: "non", label: "CSP non-typing exceptions", behavior: "non", builtin: true}
    ]
    _TypingAdd := Map()
    _TypingDel := Map()
    _TypingDis := Map()
    for cat in _TypingCats {
        _TypingAdd[cat.id] := []
        _TypingDel[cat.id] := []
        _TypingDis[cat.id] := []
    }
    _TypingNextCat := 1
    try _TypingNextCat := Integer(IniRead(SETTINGS_FILE, "TypingCategories", "Next"))
    catch
        _TypingNextCat := 1
    try ord := IniRead(SETTINGS_FILE, "TypingCategories", "Order")
    catch
        ord := ""
    for id in StrSplit(ord, ";") {
        id := Trim(id)
        if id = ""
            continue
        try lbl := IniRead(SETTINGS_FILE, "TypingCategories", "Label_" id)
        catch
            continue
        beh := "csp"
        try beh := IniRead(SETTINGS_FILE, "TypingCategories", "Type_" id)
        catch
            beh := "csp"
        if beh != "csp" && beh != "self" && beh != "non"
            beh := "csp"
        _TypingCats.Push({id: id, label: lbl, behavior: beh, builtin: false})
        _TypingAdd[id] := []
        _TypingDel[id] := []
        _TypingDis[id] := []
    }
    for cat in _TypingCats {
        for entry in _IniSectionValues(SETTINGS_FILE, _TypingSec(cat.id, "Add"))
            _TypingAdd[cat.id].Push(entry)
        for entry in _IniSectionValues(SETTINGS_FILE, _TypingSec(cat.id, "Del"))
            _TypingDel[cat.id].Push(entry)
        for entry in _IniSectionValues(SETTINGS_FILE, _TypingSec(cat.id, "Dis"))
            _TypingDis[cat.id].Push(entry)
    }
    _TypingLoaded := true
}

_TypingListsReload() {
    global _TypingLoaded
    _TypingLoaded := false
    _TypingListsEnsureLoaded()
}

_TypingKinds() {
    _TypingListsEnsureLoaded()
    return _TypingCats
}

_TypingCatBase(id) {
    if id = "csp"
        return _CSP_DialogDefaults()
    if id = "self"
        return TypingSelfTitles()
    if id = "non"
        return TypingCspNonTypingTitles()
    return []
}

_TypingBehaviorLabel(beh) {
    return beh = "csp" ? "CSP dialog title" : beh = "self" ? "Toolkit dialog title" : "CSP non-typing exception"
}

_TypingBehaviorDesc(beh) {
    static descs := Map(
        "csp", "When a CSP window title matches, typing mode activates and toolkit hotkeys are paused.",
        "self", "When a toolkit dialog title matches exactly, typing mode activates and toolkit hotkeys are paused.",
        "non", "CSP windows listed here are allowed to keep toolkit hotkeys active (overrides CSP dialog title matches).")
    return descs.Has(beh) ? descs[beh] : ""
}

_TypingCatsSave() {
    global _TypingCats, _TypingNextCat, SETTINGS_FILE
    try IniDelete(SETTINGS_FILE, "TypingCategories")
    order := ""
    for cat in _TypingCats
        if !cat.builtin
            order .= cat.id ";"
    try {
        IniWrite(Trim(order, ";"), SETTINGS_FILE, "TypingCategories", "Order")
        IniWrite(_TypingNextCat, SETTINGS_FILE, "TypingCategories", "Next")
        for cat in _TypingCats {
            if cat.builtin
                continue
            IniWrite(cat.label, SETTINGS_FILE, "TypingCategories", "Label_" cat.id)
            IniWrite(cat.behavior, SETTINGS_FILE, "TypingCategories", "Type_" cat.id)
        }
    }
}

_TypingEffective(id) {
    global _TypingAdd, _TypingDel, _TypingDis
    _TypingListsEnsureLoaded()
    base := _TypingCatBase(id)
    del := Map()
    for d in _TypingDel[id]
        del[d] := true
    dis := Map()
    for d in _TypingDis[id]
        dis[d] := true
    out := []
    for t in base {
        if !del.Has(t) && !dis.Has(t)
            out.Push(t)
    }
    for a in _TypingAdd[id] {
        if !del.Has(a) && !dis.Has(a) && !_ArrContains(out, a)
            out.Push(a)
    }
    return out
}

_TypingBehaviorEffective(behavior) {
    out := []
    for cat in _TypingKinds() {
        if cat.behavior != behavior
            continue
        for t in _TypingEffective(cat.id)
            if !_ArrContains(out, t)
                out.Push(t)
    }
    return out
}

_TypingListsSave(kind) {
    global _TypingAdd, _TypingDel, _TypingDis, SETTINGS_FILE
    secAdd := _TypingSec(kind, "Add")
    secDel := _TypingSec(kind, "Del")
    secDis := _TypingSec(kind, "Dis")
    try IniDelete(SETTINGS_FILE, secAdd)
    try IniDelete(SETTINGS_FILE, secDel)
    try IniDelete(SETTINGS_FILE, secDis)
    try {
        for i, v in _TypingAdd[kind]
            IniWrite(v, SETTINGS_FILE, secAdd, i)
        for i, v in _TypingDel[kind]
            IniWrite(v, SETTINGS_FILE, secDel, i)
        for i, v in _TypingDis[kind]
            IniWrite(v, SETTINGS_FILE, secDis, i)
    }
}

_TypingEdRefresh(g, kindIdx) {
    global _TypingAdd, _TypingDel, _TypingDis
    _TypingListsEnsureLoaded()
    cat := _TypingKinds()[kindIdx]
    id := cat.id
    base := _TypingCatBase(id)
    del := Map()
    for d in _TypingDel[id]
        del[d] := true
    dis := Map()
    for d in _TypingDis[id]
        dis[d] := true
    titles := []
    disabled := []
    seen := Map()
    for t in base {
        if del.Has(t) || dis.Has(t)
            continue
        seen[t] := true
        titles.Push(t)
        disabled.Push(false)
    }
    for a in _TypingAdd[id] {
        if del.Has(a) || seen.Has(a) || dis.Has(a)
            continue
        seen[a] := true
        titles.Push(a)
        disabled.Push(false)
    }
    for d in _TypingDis[id] {
        if del.Has(d) || seen.Has(d)
            continue
        seen[d] := true
        titles.Push(d)
        disabled.Push(true)
    }
    g.kindIdx := kindIdx
    g.items := titles
    g.itemDisabled := disabled
    g.lb.Delete()
    for i, t in titles
        g.lb.Add("", t, disabled[i] ? "Disabled" : "Enabled")
    g.lb.ModifyCol()
    enabled := 0
    for _, isOff in disabled
        if !isOff
            enabled++
    g.st.Text := titles.Length " item(s) - " enabled " enabled, " (disabled.Length - enabled) " disabled, " _TypingAdd[id].Length " custom, " _TypingDel[id].Length " removed - " cat.label " [" _TypingBehaviorLabel(cat.behavior) "]"
    try g.desc.Text := _TypingBehaviorDesc(cat.behavior)
    g.ed.Value := ""
    g.ed.Focus()
}

_TypingEdAdd(g, kindIdx) {
    global _TypingAdd, _TypingDel, _TypingDis
    _TypingListsEnsureLoaded()
    cat := _TypingKinds()[kindIdx]
    kind := cat.id
    val := Trim(g.ed.Value)
    if val = "" {
        _HK_ResultPopup("Typing Title Lists", "Type a window title to add.", "E53935")
        return
    }
    idx := 0
    for i, t in g.items {
        if StrLower(t) = StrLower(val) {
            idx := i
            break
        }
    }
    if idx {
        if g.itemDisabled[idx] {
            _TypingDis[kind] := _ArrRemove(_TypingDis[kind], val)
            _TypingListsSave(kind)
            _TypingEdRefresh(g, kindIdx)
            _HK_ResultPopup("Typing Title Lists", "Enabled: " val, "4CAF50")
            return
        }
        _HK_ResultPopup("Typing Title Lists", "Already in the list:`n" val, "FF9800")
        return
    }
    _TypingAdd[kind].Push(val)
    _TypingDel[kind] := _ArrRemove(_TypingDel[kind], val)
    _TypingDis[kind] := _ArrRemove(_TypingDis[kind], val)
    _TypingListsSave(kind)
    _TypingEdRefresh(g, kindIdx)
    DebugLog("Typing lists: added '" val "' to " kind)
}

_TypingEdDisable(g, kindIdx) {
    global _TypingDis
    _TypingListsEnsureLoaded()
    idx := g.lb.GetNext()
    if !idx || idx < 1 || idx > g.items.Length {
        _HK_ResultPopup("Typing Title Lists", "Select an item first.", "FF9800")
        return
    }
    if g.itemDisabled[idx] {
        _HK_ResultPopup("Typing Title Lists", "Already disabled:`n" g.items[idx], "FF9800")
        return
    }
    cat := _TypingKinds()[kindIdx]
    kind := cat.id
    val := g.items[idx]
    _TypingDis[kind].Push(val)
    _TypingListsSave(kind)
    _TypingEdRefresh(g, kindIdx)
    DebugLog("Typing lists: disabled '" val "' in " kind)
}

_TypingEdEnable(g, kindIdx) {
    global _TypingDis
    _TypingListsEnsureLoaded()
    idx := g.lb.GetNext()
    if !idx || idx < 1 || idx > g.items.Length {
        _HK_ResultPopup("Typing Title Lists", "Select an item first.", "FF9800")
        return
    }
    if !g.itemDisabled[idx] {
        _HK_ResultPopup("Typing Title Lists", "Not disabled:`n" g.items[idx], "FF9800")
        return
    }
    cat := _TypingKinds()[kindIdx]
    kind := cat.id
    val := g.items[idx]
    _TypingDis[kind] := _ArrRemove(_TypingDis[kind], val)
    _TypingListsSave(kind)
    _TypingEdRefresh(g, kindIdx)
    DebugLog("Typing lists: enabled '" val "' in " kind)
}

_TypingEdDelete(g, kindIdx) {
    global _TypingAdd, _TypingDel, _TypingDis
    _TypingListsEnsureLoaded()
    idx := g.lb.GetNext()
    if !idx || idx < 1 || idx > g.items.Length {
        _HK_ResultPopup("Typing Title Lists", "Select an item to delete first.", "FF9800")
        return
    }
    cat := _TypingKinds()[kindIdx]
    kind := cat.id
    val := g.items[idx]
    base := _TypingCatBase(kind)
    isBuiltin := _ArrContains(base, val)
    _TypingAdd[kind] := _ArrRemove(_TypingAdd[kind], val)
    _TypingDis[kind] := _ArrRemove(_TypingDis[kind], val)
    if isBuiltin
        _TypingDel[kind].Push(val)
    _TypingListsSave(kind)
    _TypingEdRefresh(g, kindIdx)
    DebugLog("Typing lists: deleted '" val "' from " kind)
}

_TypingEdReset(g, kindIdx) {
    global _TypingAdd, _TypingDel, _TypingDis
    _TypingListsEnsureLoaded()
    cat := _TypingKinds()[kindIdx]
    kind := cat.id
    if !_HK_Confirm("Reset the " cat.label " list to the built-in defaults?`nYour custom additions, removals, and disabled items for this list will be cleared.", "Typing Title Lists")
        return
    _TypingAdd[kind] := []
    _TypingDel[kind] := []
    _TypingDis[kind] := []
    _TypingListsSave(kind)
    _TypingEdRefresh(g, kindIdx)
    DebugLog("Typing lists: reset " kind " to defaults")
}

_TypingEdClose(g) {
    global _TypingEdGui
    _TypingEdGui := 0
    g.Destroy()
}

_TypingEdRebuildDd(g, chooseIdx := 1) {
    g.dd.Delete()
    labels := []
    for cat in _TypingKinds()
        labels.Push(cat.label)
    g.dd.Add(labels)
    g.dd.Choose(chooseIdx)
}

_TypingEdNewCat(g) {
    if IsObject(g.modal)
        return
    ng := Gui("+AlwaysOnTop", "New Typing List Category")
    ng.BackColor := "1E1F22"
    ng.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    ng.MarginX := S(14)
    ng.MarginY := S(14)
    ng.AddText("xm cAAAAAA", "Category name:")
    ng.edName := ng.AddEdit("x+" S(8) " yp w" S(250) " c000000")
    ng.AddText("xm y+" S(12) " cAAAAAA", "Matching behavior:")
    behaviors := ["CSP dialog title (blocks typing)", "Toolkit dialog title (blocks typing)", "CSP non-typing exception (allows typing)"]
    ng.ddBeh := ng.AddDropDownList("x+" S(8) " yp w" S(340) " c000000 Choose1", behaviors)
    ok := ng.AddButton("xm y+" S(16) " w" S(90) " h" S(28) " Default", "Create")
    cx := ng.AddButton("x+" S(8) " yp w" S(90) " h" S(28), "Cancel")
    ng.AddText("xm y+" S(8) " w" S(450) " c888888", "The list then behaves exactly like the matching built-in: CSP dialog titles block typing via title-contains match, toolkit titles via exact title match, and non-typing exceptions allow typing.")
    ng.OnEvent("Close", (*) => (g.modal := 0, ng.Destroy()))
    ok.OnEvent("Click", (*) => _TypingEdNewCatSubmit(g, ng))
    cx.OnEvent("Click", (*) => (g.modal := 0, ng.Destroy()))
    g.modal := ng
    ng.Show("AutoSize")
    ng.edName.Focus()
}

_TypingEdNewCatSubmit(g, ng) {
    global _TypingCats, _TypingNextCat, _TypingAdd, _TypingDel, _TypingDis
    name := Trim(ng.edName.Value)
    if name = "" {
        _HK_ResultPopup("New Typing List Category", "Enter a category name.", "E53935")
        return
    }
    for cat in _TypingKinds()
        if StrLower(cat.label) = StrLower(name) {
            _HK_ResultPopup("New Typing List Category", "A category with that name already exists.", "E53935")
            return
        }
    beh := ["csp", "self", "non"][ng.ddBeh.Value]
    id := "cust_" _TypingNextCat
    _TypingNextCat += 1
    cat := {id: id, label: name, behavior: beh, builtin: false}
    _TypingCats.Push(cat)
    _TypingAdd[id] := []
    _TypingDel[id] := []
    _TypingDis[id] := []
    _TypingCatsSave()
    _TypingListsSave(id)
    g.modal := 0
    ng.Destroy()
    _TypingEdRebuildDd(g, _TypingCats.Length)
    _TypingEdRefresh(g, _TypingCats.Length)
    DebugLog("Typing lists: created category '" name "' (" id ", " beh ")")
}

_TypingEdDelCat(g, kindIdx) {
    global _TypingCats, _TypingAdd, _TypingDel, _TypingDis, SETTINGS_FILE
    cat := _TypingKinds()[kindIdx]
    if cat.builtin {
        _HK_ResultPopup("Typing Title Lists", "Built-in lists cannot be deleted.", "FF9800")
        return
    }
    if !_HK_Confirm("Delete the list category " cat.label " and all its titles?`nThis cannot be undone.", "Typing Title Lists")
        return
    _TypingCats.RemoveAt(kindIdx)
    _TypingAdd.Delete(cat.id)
    _TypingDel.Delete(cat.id)
    _TypingDis.Delete(cat.id)
    _TypingCatsSave()
    for op in ["Add", "Del", "Dis"]
        try IniDelete(SETTINGS_FILE, _TypingSec(cat.id, op))
    _TypingEdRebuildDd(g, 1)
    _TypingEdRefresh(g, 1)
    DebugLog("Typing lists: deleted category '" cat.label "'")
}

ShowTypingTitleEditor(*) {
    global _TypingEdGui
    _TypingListsEnsureLoaded()
    if IsObject(_TypingEdGui) {
        try _TypingEdGui.Show()
        return
    }
    g := Gui("+AlwaysOnTop", "Typing Title Lists")
    g.BackColor := "1E1F22"
    g.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    g.MarginX := S(12)
    g.MarginY := S(12)
    g.modal := 0

    kindNames := []
    for cat in _TypingKinds()
        kindNames.Push(cat.label)
    g.AddText("xm cAAAAAA", "List:")
    dd := g.AddDropDownList("x+" S(8) " yp w" S(412) " c000000 Choose1", kindNames)
    g.dd := dd
    g.desc := g.AddText("xm y+" S(2) " w" S(440) " c777777", _TypingBehaviorDesc("csp"))

    g.lb := g.AddListView("xm y+" S(6) " w" S(440) " h" S(290) " r14 c000000 -Multi", ["Title", "Status"])
    g.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    g.st := g.AddText("xm y+" S(4) " w" S(440) " cAAAAAA", "")

    g.AddText("xm y+" S(10) " cAAAAAA", "New title:")
    g.ed := g.AddEdit("x+" S(8) " yp w" S(310) " c000000")
    btnAdd := g.AddButton("x+" S(8) " yp w" S(60) " h" S(26), "Add")

    btnDisable := g.AddButton("xm y+" S(10) " w" S(103) " h" S(26), "Disable")
    btnEnable := g.AddButton("x+" S(8) " yp w" S(103) " h" S(26), "Enable")
    btnDelete := g.AddButton("x+" S(8) " yp w" S(103) " h" S(26), "Delete")
    btnReset := g.AddButton("x+" S(8) " yp w" S(103) " h" S(26), "Reset")
    btnReload := g.AddButton("xm y+" S(8) " w" S(103) " h" S(26), "Reload")
    btnNewCat := g.AddButton("x+" S(8) " yp w" S(103) " h" S(26), "New Category")
    btnDelCat := g.AddButton("x+" S(8) " yp w" S(103) " h" S(26), "Del Category")
    btnClose := g.AddButton("x+" S(8) " yp w" S(103) " h" S(26) " Default", "Close")
    g.AddText("xm y+" S(4) " w" S(440) " c888888", "Select an item, then Disable / Enable / Delete. The Status column shows Enabled or Disabled.")

    dd.OnEvent("Change", (*) => _TypingEdRefresh(g, dd.Value))
    btnAdd.OnEvent("Click", (*) => _TypingEdAdd(g, dd.Value))
    btnDisable.OnEvent("Click", (*) => _TypingEdDisable(g, dd.Value))
    btnEnable.OnEvent("Click", (*) => _TypingEdEnable(g, dd.Value))
    btnDelete.OnEvent("Click", (*) => _TypingEdDelete(g, dd.Value))
    btnReset.OnEvent("Click", (*) => _TypingEdReset(g, dd.Value))
    btnReload.OnEvent("Click", (*) => (_TypingListsReload(), _TypingEdRefresh(g, dd.Value)))
    btnNewCat.OnEvent("Click", (*) => _TypingEdNewCat(g))
    btnDelCat.OnEvent("Click", (*) => _TypingEdDelCat(g, dd.Value))
    btnClose.OnEvent("Click", (*) => _TypingEdClose(g))
    g.OnEvent("Close", (*) => _TypingEdClose(g))

    _TypingEdGui := g
    g.Show("AutoSize")
    _TypingEdRefresh(g, 1)
}

TypingSafeguardSnapshot() {
    global _typingPreservedTitle
    activeHwnd := 0
    try activeHwnd := WinExist("A")
    activeTitle := "", activeClass := "", activePid := 0
    ctrlHwnd := 0, ctrlClass := "", rawTitle := ""
    isCsp := false, isSelf := false, reason := "No active window"
    if activeHwnd {
        try rawTitle := WinGetTitle("ahk_id " activeHwnd)
        try activeClass := WinGetClass("ahk_id " activeHwnd)
        try activePid := WinGetPID("ahk_id " activeHwnd)
        ctrlHwnd := FocusedControlHwnd(activeHwnd)
        if ctrlHwnd {
            try ctrlClass := WinGetClass("ahk_id " ctrlHwnd)
        }
        activeTitle := Trim(rawTitle)
        if activeTitle = "" && _typingPreservedTitle != ""
            activeTitle := _typingPreservedTitle
        isCsp := activePid && WinExist("ahk_exe CLIPStudioPaint.exe") && activePid = WinGetPID("ahk_exe CLIPStudioPaint.exe")
        isSelf := activePid = _selfPID
        reason := "No typing rule matched"
        if activeClass = "Auto-Suggest Dropdown"
            reason := "Auto-Suggest Dropdown class"
        else if isCsp {
            for dlgName in _TypingBehaviorEffective("non") {
                if InStr(activeTitle, dlgName, false) {
                    reason := "CSP non-typing exception: " dlgName
                    break
                }
            }
            if reason = "No typing rule matched" {
                for dlgName in _TypingBehaviorEffective("csp") {
                    if InStr(activeTitle, dlgName, false) {
                        reason := "CSP dialog title: " dlgName
                        break
                    }
                }
            }
            if reason = "No typing rule matched" && ctrlClass ~= "i)^(Edit|RichEdit)"
                reason := "CSP focused edit control: " ctrlClass
        } else if isSelf {
            for dlgTitle in _TypingBehaviorEffective("self") {
                if activeTitle = dlgTitle {
                    reason := "Toolkit dialog title: " dlgTitle
                    break
                }
            }
            if reason = "No typing rule matched" && ctrlClass ~= "i)^(Edit|RichEdit|ComboBox)"
                reason := "Toolkit focused input control: " ctrlClass
        }
    }
    typing := IsTyping()
    return Map(
        "typing", typing,
        "reason", reason,
        "hwnd", activeHwnd,
        "rawTitle", rawTitle,
        "effectiveTitle", activeTitle,
        "preservedTitle", _typingPreservedTitle,
        "class", activeClass,
        "pid", activePid,
        "isCsp", isCsp,
        "isSelf", isSelf,
        "ctrlHwnd", ctrlHwnd,
        "ctrlClass", ctrlClass
    )
}

TypingSafeguardReport() {
    snap := TypingSafeguardSnapshot()
    txt := "Typing Safeguard Inspector`r`n"
        . "Shows the active window data used by IsTyping(). Use this when a CSP input box still lets toolkit hotkeys through.`r`n`r`n"
    txt .= StatusLine(snap["typing"], "IsTyping result", snap["typing"] ? "Typing safeguard ACTIVE" : "Hotkeys allowed")
    txt .= StatusLine(true, "Reason", snap["reason"])
    txt .= "`r`nWindow`r`n"
    txt .= StatusLine(snap["hwnd"] != 0, "Active HWND", snap["hwnd"])
    txt .= StatusLine(Trim(snap["rawTitle"]) != "", "Raw title", snap["rawTitle"] = "" ? "(empty)" : snap["rawTitle"])
    txt .= StatusLine(snap["effectiveTitle"] != "", "Effective title", snap["effectiveTitle"] = "" ? "(empty)" : snap["effectiveTitle"])
    txt .= StatusLine(snap["preservedTitle"] != "", "Preserved title", snap["preservedTitle"] = "" ? "(empty)" : snap["preservedTitle"])
    txt .= StatusLine(snap["class"] != "", "Window class", snap["class"])
    txt .= StatusLine(snap["pid"] != 0, "PID", snap["pid"])
    txt .= StatusLine(true, "CSP window", snap["isCsp"] ? "Yes" : "No")
    txt .= StatusLine(true, "Toolkit window", snap["isSelf"] ? "Yes" : "No")
    txt .= "`r`nFocused Control`r`n"
    txt .= StatusLine(snap["ctrlHwnd"] != 0, "Control HWND", snap["ctrlHwnd"] ? snap["ctrlHwnd"] : "(none)")
    txt .= StatusLine(snap["ctrlClass"] != "", "Control class", snap["ctrlClass"] = "" ? "(none)" : snap["ctrlClass"])
    txt .= "`r`nQuick Checks`r`n"
    txt .= StatusLine(InStr(snap["effectiveTitle"], "Change color name", false), "Change color name detected", snap["effectiveTitle"])
    txt .= StatusLine(snap["ctrlClass"] ~= "i)^(Edit|RichEdit|ComboBox)", "Focused input-like control", snap["ctrlClass"] = "" ? "(none)" : snap["ctrlClass"])
    return txt
}

ShowTypingSafeguardInspector(*) {
    ShowReportWindow("Typing Safeguard Inspector", TypingSafeguardReport(), [["Refresh", TypingSafeguardReport, "refresh"], ["Edit Lists", ShowTypingTitleEditor]])
}

IsTyping() {
    global _typingPreservedTitle
    global _typingCacheTick, _typingCacheHwnd, _typingCacheSig, _typingCacheResult

    activeHwnd := 0
    try activeHwnd := WinExist("A")

    if activeHwnd {
        try activeTitle := WinGetTitle("ahk_id " activeHwnd)
        try activeClass := WinGetClass("ahk_id " activeHwnd)
        try activePid := WinGetPID("ahk_id " activeHwnd)
        ctrlHwnd := FocusedControlHwnd(activeHwnd)
        ctrlClass := ""
        if ctrlHwnd {
            try ctrlClass := WinGetClass("ahk_id " ctrlHwnd)
        }
        activeTitleTrim := Trim(activeTitle)
        if activeTitleTrim != "" {
            _typingPreservedTitle := activeTitleTrim
            activeTitle := activeTitleTrim
        } else if _typingPreservedTitle != "" {
            activeTitle := _typingPreservedTitle
        }
        sig := activeTitle "|" activeClass "|" activePid "|" ctrlHwnd "|" ctrlClass
        if _typingCacheHwnd = activeHwnd && _typingCacheSig = sig && (A_TickCount - _typingCacheTick) < 75
            return _typingCacheResult
    } else {
        sig := ""
        activeTitle := "", activeClass := "", activePid := 0
        ctrlHwnd := 0, ctrlClass := ""
    }

    selfTypingTitles := _TypingBehaviorEffective("self")
    cspNonTypingTitles := _TypingBehaviorEffective("non")
    result := false

    if activeClass = "Auto-Suggest Dropdown" {
        result := true
    } else {
        try {
            if WinActive("ahk_exe CLIPStudioPaint.exe") {
                for dlgName in cspNonTypingTitles {
                    if InStr(activeTitle, dlgName) {
                        result := false
                        goto DoneTypingCheck
                    }
                }
                for dlgName in _TypingBehaviorEffective("csp") {
                    if InStr(activeTitle, dlgName, false) {
                        result := true
                        break
                    }
                }
                if !result {
                    if ctrlHwnd {
                        clsl := StrLower(ctrlClass)
                        if SubStr(clsl, 1, 4) = "edit" || SubStr(clsl, 1, 8) = "richedit"
                            result := true
                    }
                }
            }
        }

        if !result && activePid = _selfPID {
            for dlgTitle in selfTypingTitles {
                if activeTitle = dlgTitle {
                    result := true
                    break
                }
            }
            if !result {
                if ctrlHwnd {
                    clsl := StrLower(ctrlClass)
                    if SubStr(clsl, 1, 4) = "edit" || SubStr(clsl, 1, 8) = "richedit" || SubStr(clsl, 1, 8) = "combobox"
                        result := true
                }
            }
        }

        if !result {
            for dlgTitle in ["Add Link Button", "System Settings"] {
                if activeTitle = dlgTitle {
                    result := true
                    break
                }
            }
        }
    }

DoneTypingCheck:
    _typingCacheHwnd := activeHwnd
    _typingCacheSig := sig
    _typingCacheTick := A_TickCount
    _typingCacheResult := result
    return result
}

; ============================================================
; MAIN HOTKEYS (only fire when CSP window is active)
_MonitorList() {
    monList := []
    Loop MonitorGetCount() {
        MonitorGet(A_Index, &mL, &mT, &mR, &mB)
        isPri := A_Index = MonitorGetPrimary()
        label := "Monitor " A_Index (isPri ? " (Primary)" : "") " — " mR-mL "×" mB-mT
        monList.Push(Map("idx", A_Index, "label", label, "l", mL, "t", mT, "r", mR, "b", mB))
    }
    return monList
}

_GUIPositionSnapshot() {
    global IB_X, IB_Y, ColorGUI_X, ColorGUI_Y, LinkGUI_X, LinkGUI_Y
    global MainGUI_X, MainGUI_Y
    return Map(
        "IB", [IB_X, IB_Y],
        "Color", [ColorGUI_X, ColorGUI_Y],
        "Link", [LinkGUI_X, LinkGUI_Y],
        "Main", [MainGUI_X, MainGUI_Y]
    )
}

_RestoreGUIPositionSnapshot(snap) {
    global IB_GUI, ColorGUI, LinkGUI, MainGUI
    global IB_X, IB_Y, ColorGUI_X, ColorGUI_Y, LinkGUI_X, LinkGUI_Y
    global MainGUI_X, MainGUI_Y

    if !IsObject(snap)
        return
    IB_X := snap["IB"][1], IB_Y := snap["IB"][2]
    ColorGUI_X := snap["Color"][1], ColorGUI_Y := snap["Color"][2]
    LinkGUI_X := snap["Link"][1], LinkGUI_Y := snap["Link"][2]
    MainGUI_X := snap["Main"][1], MainGUI_Y := snap["Main"][2]

    if IsObject(IB_GUI) {
        try IB_GUI.Show("x" IB_X " y" IB_Y " NoActivate")
        try _ZFixGUI(IB_GUI)
    }
    if IsObject(ColorGUI) {
        try ColorGUI.Show("x" ColorGUI_X " y" ColorGUI_Y " NoActivate")
        try ColorRefreshLayout()
        try _ZFixGUI(ColorGUI)
    }
    if IsObject(LinkGUI) {
        try LinkGUI.Show("x" LinkGUI_X " y" LinkGUI_Y " NoActivate")
        try LinkRefreshLayout()
        try _ZFixGUI(LinkGUI)
    }
    if IsObject(MainGUI) {
        try MainGUI.Show("x" MainGUI_X " y" MainGUI_Y " NoActivate")
        try _ZFixGUI(MainGUI)
    }
}

_ApplyGUIPositionsForMonitor(mon, topOffset := 0) {
    global IB_GUI, ColorGUI, LinkGUI, MainGUI
    global IB_X, IB_Y, ColorGUI_X, ColorGUI_Y, LinkGUI_X, LinkGUI_Y
    global MainGUI_X, MainGUI_Y

    if !IsObject(mon)
        return

    ; Monitor work area bounds (exclude taskbar).
    mLeft := mon["l"], mTop := mon["t"], mRight := mon["r"], mBottom := mon["b"]
    mW := mRight - mLeft
    mCX := mLeft + mW // 2

    gap := S(8)
    curY := mTop + topOffset + gap

    ; 1) IB bar — wide, thin, centered.
    if IsObject(IB_GUI) {
        ibW := 0, ibH := 0
        try IB_GUI.GetPos(,, &ibW, &ibH)
        IB_X := mCX - ibW // 2
        IB_Y := curY
        IB_GUI.Show("x" IB_X " y" IB_Y " NoActivate")
        try _ZFixGUI(IB_GUI)
        curY += ibH + gap
    }

    ; 2) LinkGUI, ColorGUI, MainGUI side by side (if all fit), else fallback stacked.
    linkW := 0, linkH := 0, colorW := 0, colorH := 0, mainW := 0, mainH := 0
    if IsObject(LinkGUI)
        try LinkGUI.GetPos(,, &linkW, &linkH)
    if IsObject(ColorGUI)
        try ColorGUI.GetPos(,, &colorW, &colorH)
    if IsObject(MainGUI)
        try MainGUI.GetPos(,, &mainW, &mainH)

    totalW := linkW + colorW + mainW + gap * 4
    if IsObject(LinkGUI) && IsObject(ColorGUI) && IsObject(MainGUI) && totalW <= mW {
        ; All three side by side.
        rowW := linkW + gap + colorW + gap + mainW
        rowX := mCX - rowW // 2
        if IsObject(LinkGUI) {
            LinkGUI_X := rowX
            LinkGUI_Y := curY
            LinkGUI.Show("x" LinkGUI_X " y" LinkGUI_Y " NoActivate")
            try LinkRefreshLayout()
            try _ZFixGUI(LinkGUI)
            rowX += linkW + gap
        }
        if IsObject(ColorGUI) {
            ColorGUI_X := rowX
            ColorGUI_Y := curY
            ColorGUI.Show("x" ColorGUI_X " y" ColorGUI_Y " NoActivate")
            try ColorRefreshLayout()
            try _ZFixGUI(ColorGUI)
            rowX += colorW + gap
        }
        if IsObject(MainGUI) {
            MainGUI_X := rowX
            MainGUI_Y := curY
            MainGUI.Show("x" MainGUI_X " y" MainGUI_Y " NoActivate")
            try _ZFixGUI(MainGUI)
        }
    } else {
        ; Fallback: stacked.
        if IsObject(LinkGUI) {
            LinkGUI_X := mCX - linkW // 2
            LinkGUI_Y := curY
            LinkGUI.Show("x" LinkGUI_X " y" LinkGUI_Y " NoActivate")
            try LinkRefreshLayout()
            try _ZFixGUI(LinkGUI)
            curY += linkH + gap
        }
        if IsObject(ColorGUI) {
            ColorGUI_X := mCX - colorW // 2
            ColorGUI_Y := curY
            ColorGUI.Show("x" ColorGUI_X " y" ColorGUI_Y " NoActivate")
            try ColorRefreshLayout()
            try _ZFixGUI(ColorGUI)
            curY += colorH + gap
        }
        if IsObject(MainGUI) {
            MainGUI_X := mCX - mainW // 2
            MainGUI_Y := curY
            MainGUI.Show("x" MainGUI_X " y" MainGUI_Y " NoActivate")
            try _ZFixGUI(MainGUI)
            curY += mainH + gap
        }
    }
}

_MonitorFromCursor() {
    MouseGetPos(&mx, &my)
    for _, m in _MonitorList() {
        if mx >= m["l"] && mx < m["r"] && my >= m["t"] && my < m["b"]
            return m
    }
    return _MonitorList()[1]
}

MonitorSelectDialog(&scaleOut := 0) {
    global Scale
    mons := _MonitorList()
    if mons.Length = 1
        return mons[1]

    ; Determine which monitor the cursor is on for default selection.
    cursorMon := _MonitorFromCursor()
    defaultIdx := cursorMon["idx"]

    dlg := Gui("+AlwaysOnTop +ToolWindow", "Select Monitor")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)
    dlg.AddText("xm cAAAAAA", "Reset GUI positions to which monitor?")
    monLabels := []
    for _, m in mons
        monLabels.Push(m["label"])
    dd := dlg.AddDropDownList("xm y+" S(6) " w" S(205) " Choose" defaultIdx, monLabels)
    result := 0
    origScale := Scale
    origPos := _GUIPositionSnapshot()
    scalePct := Max(50, Min(150, Round(Scale * 100)))
    scaleOut := 0
    dlg.AddText("xm y+" S(12), "UI Scale:")
    dlg.AddText("xm y+" S(4) " w" S(5) " cAAAAAA", "50%")
    sScale := dlg.AddSlider("x+" S(1) " yp w" S(150) " Range50-150 Tooltip", scalePct)
    dlg.AddText("x+" S(2) " yp w" S(5) " Right cAAAAAA", "150%")
    _PreviewMonitorSelection(*) {
        PreviewGuiScale(sScale.Value / 100.0)
        if dd.Value >= 1 && dd.Value <= mons.Length
            _ApplyGUIPositionsForMonitor(mons[dd.Value])
        try dlg.Opt("+AlwaysOnTop")
    }
    dd.OnEvent("Change", _PreviewMonitorSelection)
    sScale.OnEvent("Change", _PreviewMonitorSelection)
    dlg.AddButton("xm y+" S(20) " w" S(98) " h" S(26) " cFFFFFF", "OK").OnEvent("Click", (*) => (result := dd.Value, scaleOut := sScale.Value / 100.0, dlg.Destroy()))
    _RestoreMonitorDialogScale(*) {
        PreviewGuiScale(origScale)
        _RestoreGUIPositionSnapshot(origPos)
        dlg.Destroy()
    }
    dlg.AddButton("x+8 yp w" S(98) " h" S(26), "Cancel").OnEvent("Click", _RestoreMonitorDialogScale)
    dlg.OnEvent("Close", _RestoreMonitorDialogScale)
    ; Position dialog centered on the monitor where the mouse cursor is.
    dlg.Show("Hide AutoSize")
    dlg.GetPos(,, &dlgW, &dlgH)
    dlgX := cursorMon["l"] + ((cursorMon["r"] - cursorMon["l"]) - dlgW) // 2
    dlgY := cursorMon["t"] + ((cursorMon["b"] - cursorMon["t"]) - dlgH) // 2
    dlg.Show("x" dlgX " y" dlgY)
    ; Arrange GUIs on the selected monitor.
    _PreviewMonitorSelection()
    GuiWaitForCloseSafe(dlg)
    if result < 1
        return 0
    return mons[result]
}

ResetGUIPositions(*) {
    global IB_GUI, ColorGUI, LinkGUI, MainGUI
    global IB_X, IB_Y, ColorGUI_X, ColorGUI_Y, LinkGUI_X, LinkGUI_Y
    global MainGUI_X, MainGUI_Y

    newScale := Scale
    origScale := Scale
    mon := MonitorSelectDialog(&newScale)
    if !IsObject(mon)
        return
    if Abs(newScale - origScale) > 0.001
        ApplyGuiScale(newScale)

    _ApplyGUIPositionsForMonitor(mon)
}

ToggleMainWindow() {
    global MainGUI, MainGUIVisible, MainGUI_X, MainGUI_Y
    MainGUIVisible := !MainGUIVisible
    if MainGUIVisible {
        if MainGUI_X || MainGUI_Y
            MainGUI.Show("x" MainGUI_X " y" MainGUI_Y " NoActivate")
        else
            MainGUI.Show("NoActivate")
        try _ZFixGUI(MainGUI)
    } else
        MainGUI.Hide()
    DebugLog("Main GUI " (MainGUIVisible ? "shown" : "hidden"))
}

ShowMainGUI(*) {
    global MainGUI, MainGUIVisible, MainGUI_X, MainGUI_Y
    MainGUIVisible := true
    if IsObject(MainGUI) {
        if MainGUI_X || MainGUI_Y
            MainGUI.Show("x" MainGUI_X " y" MainGUI_Y " NoActivate")
        else
            MainGUI.Show("NoActivate")
        try _ZFixGUI(MainGUI)
    }
    DebugLog("Main GUI shown")
}

ShowGuiSetting(*) {
    ShowOpacitySlider("Main")
}

RebuildMainGui() {
    global MainGUI, MainGUIVisible, MainGUI_X, MainGUI_Y
    SetTimer(CheckCSP, 0)
    havePos := false
    if IsObject(MainGUI) {
        try {
            MainGUI.GetPos(&x, &y)
            MainGUI_X := x, MainGUI_Y := y
            havePos := true
            MainGUI.Destroy()
        }
    }
    CreateMainGui()
    if MainGUIVisible {
        if havePos
            MainGUI.Show("x" x " y" y " NoActivate")
        else
            MainGUI.Show("NoActivate")
        try _ZFixGUI(MainGUI)
    } else
        MainGUI.Hide()
    SetTimer(CheckCSP, 200)
}

ToggleHotkeysPause(*) {
    global HotkeysPaused
    HotkeysPaused := !HotkeysPaused
    HK_ReapplyAll()
    UpdateResetWatchdog()
    UpdateHotkeysPauseButton()
    UpdateIBModeIndicator()
    DebugLog("Custom hotkeys " (HotkeysPaused ? "paused" : "resumed"))
}

UpdateHotkeysPauseButton() {
    global MainGUI, HotkeysPaused
    if !GuiHasCtrl(MainGUI, "btnHotkeys")
        return
    MainGUI.btnHotkeys.Opt("Background" (HotkeysPaused ? "E53935" : "4CAF50") " cFFFFFF")
    MainGUI.btnHotkeys.Text := HotkeysPaused ? "OFF" : "HK"
}

UpdateMainModeButton() {
    global MainGUI, HK_Mode, HK_Modes
    if !GuiHasCtrl(MainGUI, "btnMode")
        return
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
    MainGUI.btnMode.Text := "Mode: " name
    bgColor := modeColor != "" ? PieSafeColor(modeColor) : "3949AB"
    MainGUI.btnMode.Opt("Background" bgColor " c" ContrastColor(bgColor))
}

ApplyAutoScale() {
    global Scale, PieScale, SETTINGS_FILE
    ; Only auto-scale if no saved Scale/PieScale (first run or reset)
    try {
        savedScale := IniRead(SETTINGS_FILE, "Settings", "Scale", "")
        savedPie := IniRead(SETTINGS_FILE, "Settings", "PieScale", "")
        if savedScale != "" && savedPie != ""
            return
    }
    MonitorGet(MonitorGetPrimary(), &mL, &mT, &mR, &mB)
    monW := mR - mL
    targetW := 2560
    autoScale := Max(0.5, Min(1.5, Round(monW / targetW, 2)))
    Scale := autoScale
    PieScale := autoScale
    DebugLog("AutoScale: monitor " monW "px, target " targetW "px => Scale=" Scale)
}

; ============================================================
