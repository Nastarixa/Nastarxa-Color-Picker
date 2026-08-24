; FEATURES — Feature Switcher
; ============================================================
; Master on/off switches that BLOCK each feature's activation
; (its shortcut / GUI show path) instead of just hiding the UI.
; Universal setting: persisted in the base settings folder,
; shared across all modes (not retargeted per-mode).

global _FeatureSwitcherGui := 0

; Single source of truth: all feature metadata in one place.
; Order of insertion defines the display order in the GUI.
global _FeatureDefs := Map(
    "colorgui",   {iniKey:"ColorGUI",   label:"Color GUI",              on:true,  desc:"Floating color palette window with your custom colors, quick paint actions, pickers and color history."},
    "linkgui",    {iniKey:"LinkGUI",    label:"Link GUI",               on:true,  desc:"Link launcher bar that opens your saved links, scripts and files from one row of buttons."},
    "ibgui",      {iniKey:"IBGUI",      label:"IB GUI",                 on:true,  desc:"In-between bar used for in-between frame work in the animation timeline."},
    "pie",        {iniKey:"Pie",        label:"Pie Menu",               on:true,  desc:"All pie menus (Pie 1-4), their sub-menus, slots and quick actions."},
    "capslock",   {iniKey:"Capslock",   label:"CapsLock",               on:true,  desc:"CapsLock modifier system: caps lock + key shortcuts for painting tools and actions."},
    "tab",        {iniKey:"Tab",        label:"Tab Combos",             on:true,  desc:"Tab hold combos: hold Tab and press a key to trigger tools and actions."},
    "userscript", {iniKey:"UserScript", label:"User Scripts",           on:true,  desc:"User Scripts library: callable custom AHK functions available from the Function Picker."},
    "quickpie",   {iniKey:"QuickPie",   label:"Pie Quick Hotkeys",      on:true,  desc:"Pie Quick Hotkeys: extra per-slot pie hotkeys bound directly to actions."},
    "cheatsheet", {iniKey:"CheatSheet", label:"Hotkey Cheat Sheet (Ctrl+Shift+F2)", on:true, desc:"Always-on-top overlay that lists the active mode's hotkeys and mode-switch keys."},
    "automode",   {iniKey:"AutoMode",   label:"Auto Mode Switch",       on:false, desc:"Automatically switches the active mode based on the foreground window or active target."},
    "guidenotify",{iniKey:"GuideNotify",label:"Guide Notifications",    on:true,  desc:"Guide notification popups that teach CSP features (InBetween, Create, Shortcuts, AutoAction, Animation)."},
    "applyblock", {iniKey:"ApplyBlock", label:"Apply Block",            on:true,  desc:"Intercepts certain keyboard shortcuts in CSP to block their default behavior, allowing toolkit actions to fire instead."},
    "selectlayer",{iniKey:"SelectLayer",label:"Select Layer Window",    on:true,  desc:"Temporary remaps Ctrl to Tab+Enter inside CSP's when Select Layer dialog window show up."}
)

; Runtime state: populated from _FeatureDefs at load time.
global FeatureSwitches := Map()
for _fn, _def in _FeatureDefs
    FeatureSwitches[_fn] := _def.on

FeatureEnabled(name) {
    global FeatureSwitches
    return FeatureSwitches.Get(name, true)
}

FeatureIniKey(name) {
    global _FeatureDefs
    return _FeatureDefs.Has(name) ? _FeatureDefs[name].iniKey : name
}

FeatureLabel(name) {
    global _FeatureDefs
    return _FeatureDefs.Has(name) ? _FeatureDefs[name].label : name
}

FeatureSwitchOrder() {
    global _FeatureDefs
    order := []
    for name, _ in _FeatureDefs
        order.Push(name)
    return order
}

FeatureDefaultOn(name) {
    global _FeatureDefs
    return _FeatureDefs.Has(name) ? _FeatureDefs[name].on : true
}

FeatureInfoDescriptions() {
    global _FeatureDefs
    desc := Map()
    for name, def in _FeatureDefs
        desc[name] := def.desc
    return desc
}

LoadFeatureSwitches() {
    global FeatureSwitches, _FeatureDefs, FEATURE_SETTINGS_FILE
    if !FileExist(FEATURE_SETTINGS_FILE)
        return
    for name, def in _FeatureDefs {
        try v := IniRead(FEATURE_SETTINGS_FILE, "Features", def.iniKey, def.on ? 1 : 0)
        catch
            continue
        FeatureSwitches[name] := v = "1" || StrLower(v) = "on"
    }
    parts := ""
    for name, _ in _FeatureDefs
        parts .= " " FeatureLabel(name) "=" (FeatureEnabled(name) ? 1 : 0)
    SettingsDiagPush("INFO", "Loaded feature switches", Trim(parts))
}

SaveFeatureSwitches() {
    global FeatureSwitches, FEATURE_SETTINGS_FILE
    try {
        for name, on in FeatureSwitches
            IniWrite(on ? 1 : 0, FEATURE_SETTINGS_FILE, "Features", FeatureIniKey(name))
    }
}

; Hides the Color / Link / IB GUIs and clears their state when their
; feature switch is off, so nothing can re-show them.
FeatureApplyGUIHides() {
    global IB_GUI, ColorGUI, LinkGUI
    global IBVisible, ColorGUIVisible, LinkGUIVisible
    global IBManualHide, LinkManualHide, ColorManualHide
    if !FeatureEnabled("ibgui") {
        if IsObject(IB_GUI)
            try IB_GUI.Hide()
        IBVisible := false
        IBManualHide := false
    }
    if !FeatureEnabled("colorgui") {
        if IsObject(ColorGUI)
            try ColorGUI.Hide()
        ColorGUIVisible := false
        ColorManualHide := false
    }
    if !FeatureEnabled("linkgui") {
        if IsObject(LinkGUI)
            try LinkGUI.Hide()
        LinkGUIVisible := false
        LinkManualHide := false
    }
}

; Applies all feature switches: re-registers the affected hotkeys and
; enforces GUI visibility. Called at startup and after a toggle changes.
FeatureApplyAll() {
    HK_ReapplyAll()
    FeatureApplyGUIHides()
    UpdateMainGuiStateButtons()
    if !FeatureEnabled("cheatsheet")
        HK_CheatSheetClose()
    if !FeatureEnabled("pie") && PieIsOpen()
        PieClose()
}

FeatureToggleFromGUI(name, ctrl, *) {
    global FeatureSwitches
    on := ctrl.Value
    FeatureSwitches[name] := !!on
    try SaveFeatureSwitches()
    FeatureApplyAll()
    DebugLog("Feature " FeatureLabel(name) " " (on ? "ON" : "OFF"))
    ShowNotify("Feature Switcher", FeatureLabel(name) " " (on ? "ON" : "OFF"), on ? "2E7D32" : "E53935")
}

FeatureSwitcherInfoText() {
    txt := "Feature Switcher Info`r`n"
        . "Toggling a feature OFF blocks its activation entirely (shortcut, GUI button and show path), not just hides the UI.`r`n"
        . "Changes apply immediately and are stored per mode in feature_switches.ini.`r`n`r`n"
    for name in FeatureSwitchOrder() {
        desc := FeatureInfoDescriptions().Get(name, "")
        txt .= FeatureLabel(name) "`r`n"
            . "  " desc "`r`n"
            . "  Default: " (FeatureDefaultOn(name) ? "ON" : "OFF")
            . "  |  Current: " (FeatureEnabled(name) ? "ON" : "OFF") "`r`n`r`n"
    }
    return txt
}

ShowFeatureSwitcherInfo(*) {
    ShowReportWindow("Feature Switcher Info", FeatureSwitcherInfoText(), [["Refresh", FeatureSwitcherInfoText, "refresh"]])
}

ShowFeatureSwitcher(*) {
    global FeatureSwitches, _FeatureSwitcherGui
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Feature Switcher")
    _FeatureSwitcherGui := dlg
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)

    dlg.modeLabel := dlg.AddText("xm y+10 cFFD54F", "Mode: " ModeSettingsActiveName())
    AddHoverPopup(dlg.modeLabel, "Editing mode: " ModeSettingsActiveName() "`nFeature switches are stored per mode; this panel edits the active mode's switches.")

    dlg.AddText("xm y+" S(6) " cAAAAAA", "Toggling a feature OFF blocks its activation entirely")
    dlg.AddText("xm y+0 c777777", "(shortcut, GUI button and show path), not just hides it.")

    for name in FeatureSwitchOrder() {
        on := FeatureSwitches.Get(name, true)
        cb := dlg.AddCheckbox("xm y+" S(8) " cFFFFFF Background1E1F22 Checked" (on ? 1 : 0), FeatureLabel(name))
        cb.OnEvent("Click", FeatureToggleFromGUI.Bind(name))
    }

    dlg.AddText("xm y+" S(12) " w" S(288) " h1 Background555555")

    dlg.AddButton("xm y+" S(10) " w" S(44) " h" S(26) " cFFFFFF", "Info").OnEvent("Click", ShowFeatureSwitcherInfo)
    dlg.AddButton("x+5 yp w" S(44) " h" S(26) " cFFFFFF Default", "Close").OnEvent("Click", (*) => (_FeatureSwitcherGui := 0, dlg.Destroy()))
    dlg.AddButton("x+5 yp w" S(68) " h" S(26), "Enable All").OnEvent("Click", FeatureEnableAllFromGUI.Bind(dlg))
    dlg.AddButton("x+5 yp w" S(68) " h" S(26), "Disable All").OnEvent("Click", FeatureDisableAllFromGUI.Bind(dlg))
    dlg.AddButton("x+5 yp w" S(44) " h" S(26), "Reset").OnEvent("Click", FeatureResetDefaultsFromGUI.Bind(dlg))
    dlg.Show("AutoSize")
}

FeatureEnableAllFromGUI(dlg, *) {
    global FeatureSwitches
    for name in FeatureSwitchOrder()
        FeatureSwitches[name] := true
    try SaveFeatureSwitches()
    FeatureApplyAll()
    dlg.Destroy()
    ShowFeatureSwitcher()
    ShowNotify("Feature Switcher", "All features ON", "2E7D32")
}

FeatureDisableAllFromGUI(dlg, *) {
    global FeatureSwitches
    for name in FeatureSwitchOrder()
        FeatureSwitches[name] := false
    try SaveFeatureSwitches()
    FeatureApplyAll()
    dlg.Destroy()
    ShowFeatureSwitcher()
    ShowNotify("Feature Switcher", "All features OFF", "E53935")
}

FeatureResetDefaultsFromGUI(dlg, *) {
    global FeatureSwitches
    for name in FeatureSwitchOrder()
        FeatureSwitches[name] := FeatureDefaultOn(name)
    try SaveFeatureSwitches()
    FeatureApplyAll()
    dlg.Destroy()
    ShowFeatureSwitcher()
    ShowNotify("Feature Switcher", "Features reset to defaults", "6D28D9")
}
