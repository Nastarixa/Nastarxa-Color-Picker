; ============================================================
; Nastarxa CSP Animator Toolkit
; ============================================================
; AI EDITOR RULE: Before editing any .ahk file in this project,
; read src/docs/script_rules.md first. It contains constraints
; (disabled sentinel "-" not "", lowercase keys, mode seeding)
; that cause silent bugs if violated.
#Requires AutoHotkey v2.0
#SingleInstance
CoordMode "Pixel", "Screen"
CoordMode "Mouse", "Screen"

#Include src\vendor\Notify.ahk
iconPath := A_ScriptDir "\CSPToolkit.ico"
if A_IsCompiled
    TraySetIcon(A_ScriptFullPath)
else if FileExist(iconPath)
    TraySetIcon(iconPath)
else
    TrayTip("Nastarxa CSP Animator Toolkit", "Icon not found:`n" iconPath, 2)
; ============================================================
; GLOBALS
; ============================================================
; --- Inbetween ---
; --- IB Color ---
global _IBTheme := "Default"
global _IBColors := Map(
    "25", "5D4037", "33", "795548", "40", "FFB300",
    "60", "2E7D32", "66", "81C784", "75", "43A047",
    "empty", "555555",
    "25_se", "5D4037", "33_se", "795548", "40_se", "FFB300",
    "60_se", "2E7D32", "66_se", "81C784", "75_se", "43A047",
    "empty_se", "555555",
    "25_es", "8D6E63", "33_es", "A1887F", "40_es", "FFD54F",
    "60_es", "66BB6A", "66_es", "A5D6A7", "75_es", "81C784",
    "empty_es", "AAAAAA",
    "s2e", "4CAF50",
    "e2s", "E53935"
)
global InbetweenIndex := 1
global InbetweenMode := "Start > End"
global InbetweenData := BuildInbetweenData(InbetweenMode)
; --- IB GUI ---
global IB_GUI := 0, IB_Text := 0, IB_LTInd := 0, IB_LockBtn := 0
global IB_Buttons := []
global IB_ModeBtn := 0
global AutoSaveBtn := 0
global IBShortcutsEnabled := true
global IB_X := 760, IB_Y := 10

; --- Color GUI ---
global ColorGUI := 0
global ColorGUI_X := 78, ColorGUI_Y := 810
global ColorLayout := "V"
global ColorGUIVisible := false

; --- Link GUI ---
global LinkGUI := 0
global LinkGUI_X := 78, LinkGUI_Y := 1090
global LinkLayout := "V"
global LinkGUIVisible := false

; --- State ---
global CSPActive := false
global CSP_PID := 0
global _selfPID := DllCall("GetCurrentProcessId", "uint")
global IBVisible := true
global GUIEnabled := true
global GUIVisible := false

; --- Lock ---
global LTLock := false

; --- Main GUI ---
global MainGUI := 0
global MainGUI_X := 0, MainGUI_Y := 0
global MainGUIVisible := false
global IBManualHide := false
global LinkManualHide := false
global ColorManualHide := false

; --- Auto Save ---
global AutoSaveOn := false

; --- Navigation ---
global NavEnabled := true
global CapslockEnabled := true
global TabCombosEnabled := true
global ResetEnabled := true
global LWinEnabled := true
global ReqAnimationEnabled := false
global ReqNastarEnabled := false
global _settingsNeedUpgrade := false
global _HK_SettingsGui := 0
global _selectCelMode := 1  ; 1=save guard (reset LT), 2=no reset

; --- Notifications ---
global NotifyEnabled := true
global NotifyMonitor := 0  ; 0 = primary, 1+ = specific monitor
global NotifyPosition := "TC"

; --- Configurable paths & URLs ---
global PickerPath := A_ScriptDir "\..\Nastarxa-Color-Picker\Nastarxa Color Picker.ahk"
global FishbonePath := A_ScriptDir "\..\Nastarxa-Fishbone-Inbetween-Generator\Nastarxa Fishbone Inbetween-Generator.ahk"
global ResizerPath := A_ScriptDir "\..\Nastarxa-Batch-Image-Resizer\Nastarxa Batch Image Resizer.ahk"
global SheetsURL := "https://docs.google.com/spreadsheets/d/1RO_WUyMEOLPDR-S9uM_qseg9T1IFu08vGWCOzAWfNaQ/edit?gid=0#gid=0"
global DriveURL := "https://drive.google.com/drive/u/0/folders/12DcDx1Oq0amOOhm1G42oHF6HbibovhAB"

; --- Configurable click coordinates ---
global LT_ClickX := 0, LT_ClickY := 0
global ColorClick1X := 0, ColorClick1Y := 0
global ColorClick2X := 0, ColorClick2Y := 0

; --- Link Button Manager ---
global LinkItems := []

; --- Pie Menu ---
global PieItems := []
global PieEnabled := []
global PieConfigs := []
global SubPieConfigs := []
global SubPieNames := []
global PieCount := 4
global PieHotkeys := []
global PieNames := []
global PieRegistered := Map()
global PieQuickHotkeys := []
global PieQuickRegistered := Map()
global PieGUI := 0
global _pieActiveIndex := 0
global _pieControlMap := Map()
global _pieCloseMap := Map()
global _pieCtrlMeta := Map()
global _pieHoverHwnd := 0
global _pieHoverStart := 0
global _pieDelayMs := 65
global _pieDeadzone := 42
global _pieStyle := "Normal"
global _pieQuickHintsVisible := 1
global _pieQuickSlotHintsPos := "bottom-center"
global _pieQuickHintCount := 20
global PieScale := 1.0
global _pieCenterX := 0
global _pieCenterY := 0
global _pieActivated := false
global _pieMouseWasDown := false
global _pieLastIndex := 1
global _pieItemCtrls := []
global _pieNavStack := []
global _pieCurrentName := ""
global _pieCenterNameCtrl := 0
global _pieCenterHintCtrl := 0

; --- DPI scaling ---
global Scale := 1.0
global _ToolScaleActive := false
S(n) => Floor(n * (_ToolScaleActive ? Scale : 1))
ToolScaleCall(fn) {
    global _ToolScaleActive
    oldState := _ToolScaleActive
    _ToolScaleActive := true
    try fn.Call()
    catch as e {
        _ToolScaleActive := oldState
        throw e
    }
    _ToolScaleActive := oldState
}
PieS(n) => Floor(n * PieScale)

; --- Named color constants ---
global CLR_BG := "1E1F22"
global CLR_SLOT_DEFAULT := "455A64"
global CLR_SEP := "2A2A2A"
global CLR_RED_ACCENT := "E53935"
global CLR_TEXT := "FFFFFF"
global CLR_TEXT_DIM := "AAAAAA"
global CLR_TEXT_MUTED := "777777"
global CLR_CONTROL := "000000"
global CLR_CONTROL_BG := "FFFFFF"

; --- Theme font helper ---
GuiThemeFont(guiObj, size, color := "FFFFFF", opts := "") {
    guiObj.SetFont("s" S(size) " c" color (opts ? " " opts : ""), "Segoe UI")
}

; --- Typing auto-disable state ---
global _TypingState := Map("nav", false, "caps", false, "tab", false, "lwin", false, "hk", false)

global TabCombosBtn := 0
global NavBtn := 0
global CapslockBtn := 0
global LWinBtn := 0
global ResetBtn := 0
global _ccBtnIB := 0
global IB_EmptyBtn := 0

; --- Collapsible Link Sections ---
global _linkCollapsed := Map()
; --- Collapsible Color Sections ---
global _colorCollapsed := Map()

; --- Debug Log ---
global _debugLog := []
global _debugGUI := 0
global _debugDateShown := false
global _debugSaveOnExit := false
global _debugFilters := 0

; --- Consolidated state Maps ---
global _HoverState := Map("map", Map(), "popup", 0, "last", 0, "pending", 0, "pendingX", 0, "pendingY", 0, "delay", 500, "enabled", true)

; --- Auto Save Interval ---
global AutoSaveInterval := 60

; --- IB Timer / Stopwatch ---
global _timerRunning := false
global _timerStart := 0
global _timerElapsed := 0
global _timerLaps := []
global _timerLastLapText := ""
global _timerDisplay := 0
global _tmrPlay := 0
global _tmrPause := 0
global _timerCountdownTarget := 0
global _timerCountdownStart := 0
global _timerCountdownOrigTotal := 0
global _rBtn := 0
global _saveBtn := 0
global _loadBtn := 0
global _timerLastPngRenderer := ""
global _timerAskFileName := true
global _timerNameResult := ""
global _timerFocusPaused := false

; --- GUI Opacity ---
global IB_Opacity := 255
global Color_Opacity := 255
global Link_Opacity := 255

; --- CSP Auto-Restart ---
global CSP_RestartMonitor := false

; --- Settings ---
global Speed := 15
global HotkeysPaused := false
global SafeModeActive := false
global SafeModeState := Map()
global LT_X := 0, LT_Y := 0, LT_Color := 0x677187
global SCRIPT_VERSION := "2.2.2"
global CONFIG_VERSION := 2
global _DevToolsIncluded := false
global _DevToolsHandler := 0
global SETTINGS_DIR := A_ScriptDir "\settings"
if !DirExist(SETTINGS_DIR)
    DirCreate(SETTINGS_DIR)
global SETTINGS_FILE := SETTINGS_DIR "\gui_settings.ini"
global PIE_SETTINGS_FILE := SETTINGS_DIR "\pie_settings.ini"
global HOTKEY_SETTINGS_FILE := SETTINGS_DIR "\hotkey_settings.ini"
global LINK_SETTINGS_FILE := SETTINGS_DIR "\link_settings.ini"
global COLOR_SETTINGS_FILE := SETTINGS_DIR "\color_settings.ini"
global FEATURE_SETTINGS_FILE := SETTINGS_DIR "\feature_switches.ini"
global REQ_NASTAR := "Nastar.laf"
global REQ_ANIM := "Animation_autoaction.laf"
global _useUltimateSaveAs := true
global _resetWatchdogFn := 0
global _tabModActive := false
global _tabBlockPassthrough := false
global _capsBlockOutput := false
global _typingCacheTick := 0
global _typingCacheHwnd := 0
global _typingCacheSig := ""
global _typingCacheResult := false
global _typingPreservedTitle := ""
global _settingsLoadDiag := []
global _settingsLoadDiagRevision := 0

CompactSplitSettingsFiles()

_EnsureGUIs() {
    CreateIBGui()
    CreateColorGui()
    CreateLinkGUI()
}
global FirstRunSetup := true
if FileExist(SETTINGS_FILE) {
    try FirstRunSetup := !Integer(IniRead(SETTINGS_FILE, "Settings", "SetupComplete", 0))
    catch
        FirstRunSetup := true
}
global _LoadingGUI := ""
if FirstRunSetup {
    HotkeysPaused := true
    _LoadingGUI := Gui("+AlwaysOnTop -Caption +ToolWindow", "Loading")
    _LoadingGUI.BackColor := "1E1F22"
    _LoadingGUI.SetFont("s" S(10) " cFFFFFF", "Segoe UI")
    _LoadingGUI.MarginX := S(30)
    _LoadingGUI.MarginY := S(20)
    _LoadingGUI.AddText("Center", "Loading...")
    _LoadingGUI.Show("NoActivate Center AutoSize")
}

CompactSplitSettingsFiles() {
    global PIE_SETTINGS_FILE, HOTKEY_SETTINGS_FILE, LINK_SETTINGS_FILE, COLOR_SETTINGS_FILE
    for fn in [PIE_SETTINGS_FILE, HOTKEY_SETTINGS_FILE, LINK_SETTINGS_FILE, COLOR_SETTINGS_FILE]
        CompactIniFile(fn)
}

CompactIniFile(fn) {
    if !FileExist(fn)
        return
    try text := FileRead(fn)
    catch
        return
    seenSections := Map()
    seenKeys := Map()
    currentSection := ""
    skipSection := false
    output := ""
    for rawLine in StrSplit(text, "`n", "`r") {
        line := rawLine
        if RegExMatch(line, "^\[(.+)\]\s*$", &m) {
            currentSection := m[1]
            if seenSections.Has(currentSection) {
                skipSection := true
                continue
            }
            seenSections[currentSection] := true
            seenKeys[currentSection] := Map()
            skipSection := false
            output .= (output = "" ? "" : "`n") line
            continue
        }
        if skipSection
            continue
        if currentSection != "" && InStr(line, "=") {
            eq := InStr(line, "=")
            key := Trim(SubStr(line, 1, eq - 1))
            if key != "" {
                if !seenKeys.Has(currentSection)
                    seenKeys[currentSection] := Map()
                if seenKeys[currentSection].Has(key)
                    continue
                seenKeys[currentSection][key] := true
            }
        }
        output .= (output = "" ? "" : "`n") line
    }
    try {
        FileDelete(fn)
        FileAppend(output, fn)
        SettingsDiagPush("INFO", "Compacted INI file", fn)
    }
}

SettingsDiagPush(level, label, detail := "") {
    global _settingsLoadDiag, _settingsLoadDiagRevision
    if !IsObject(_settingsLoadDiag)
        _settingsLoadDiag := []
    stamp := FormatTime(, "HH:mm:ss")
    entry := "[" StrUpper(level) "] " stamp " " label
    if detail != ""
        entry .= " - " detail
    _settingsLoadDiag.Push(entry)
    if _settingsLoadDiag.Length > 250
        _settingsLoadDiag.RemoveAt(1)
    _settingsLoadDiagRevision++
}

SettingsDiagText() {
    global _settingsLoadDiag
    if !IsObject(_settingsLoadDiag) || _settingsLoadDiag.Length = 0
        return "Settings Load Diagnostics`r`n`r`nNo diagnostics recorded yet."
    txt := "Settings Load Diagnostics`r`n"
        . "Tracks fallback, reload, rebuild, and settings load/save decisions.`r`n`r`n"
    for line in _settingsLoadDiag
        txt .= line "`r`n"
    return RTrim(txt, "`r`n")
}

ClearSettingsDiagnostics(*) {
    global _settingsLoadDiag, _settingsLoadDiagRevision
    _settingsLoadDiag := []
    _settingsLoadDiagRevision++
    SettingsDiagPush("INFO", "Diagnostics cleared")
}

; ============================================================
; Module: src\hotkeys\hotkey_core.ahk
; ============================================================
#Include src\hotkeys\hotkey_core.ahk
; ============================================================
; Module: src\hotkeys\hotkey_actions.ahk
; ============================================================
#Include src\hotkeys\hotkey_actions.ahk
; ============================================================
; Module: src\hotkeys\hotkey_guide_notify.ahk
; ============================================================
#Include src\hotkeys\hotkey_guide_notify.ahk
; ============================================================
; Module: src\hotkeys\hotkey_capslock_engine.ahk
; ============================================================
#Include src\hotkeys\hotkey_capslock_engine.ahk
; ============================================================
; Module: src\hotkeys\hotkey_diagnostics.ahk
; ============================================================
#Include src\hotkeys\hotkey_diagnostics.ahk
; ============================================================
; Module: src\hotkeys\hotkey_user_scripts.ahk
; ============================================================
#Include src\hotkeys\hotkey_user_scripts.ahk
; ============================================================
; Module: src\hotkeys\hotkey_reapply.ahk
; ============================================================
#Include src\hotkeys\hotkey_reapply.ahk
; ============================================================
; Module: src\hotkeys\mode_system.ahk
; ============================================================
#Include src\hotkeys\mode_system.ahk
; ============================================================
; Module: src\gui\color_info.ahk (included early so defaults don't overwrite loaded INI values)
; ============================================================
#Include src\gui\color_info.ahk

; ============================================================
; Module: src\core\csp_runtime.ahk
; ============================================================
#Include src\core\csp_runtime.ahk

; ============================================================
; Module: src\gui\hover_popup.ahk
; ============================================================
#Include src\gui\hover_popup.ahk

; ============================================================
; Module: src\gui\window_dragging.ahk
; ============================================================
#Include src\gui\window_dragging.ahk

; ============================================================
; Module: src\gui\inbetween_bar.ahk
; ============================================================
#Include src\gui\inbetween_bar.ahk

; ============================================================
; Module: src\features\timer_worklog.ahk
; ============================================================
#Include src\features\timer_worklog.ahk

; ============================================================
; Module: src\features\timer_history.ahk
; ============================================================
#Include src\features\timer_history.ahk

; ============================================================
; Module: src\features\feature_switcher.ahk
; ============================================================
#Include src\features\feature_switcher.ahk

; ============================================================
; Module: src\gui\color_palette.ahk
; ============================================================
#Include src\gui\color_palette.ahk

; ============================================================
; Module: src\gui\preset_wizard.ahk
; ============================================================
#Include src\gui\preset_wizard.ahk

; ============================================================
; Module: src\gui\collapsible_button_list.ahk
; ============================================================
#Include src\gui\collapsible_button_list.ahk

; ============================================================
; Module: src\gui\link_launcher.ahk
; ============================================================
#Include src\gui\link_launcher.ahk

; ============================================================
; Module: src\gui\pie_menu.ahk
; ============================================================
#Include src\gui\pie_menu.ahk

; ============================================================
; Module: src\settings\persistence.ahk
; ============================================================
#Include src\settings\persistence.ahk

; ============================================================
; Module: src\settings\mode_settings.ahk
; ============================================================
#Include src\settings\mode_settings.ahk

; ============================================================
; Module: src\gui\link_button_manager.ahk
; ============================================================
#Include src\gui\link_button_manager.ahk

; ============================================================
; Module: src\features\toolkit_commands_and_guides.ahk
; ============================================================
#Include src\features\toolkit_commands_and_guides.ahk

; ============================================================
; Module: src\gui\hotkey_settings.ahk
; ============================================================
#Include src\gui\hotkey_settings.ahk

; ============================================================
; Module: src\gui\hotkey_function_browser.ahk
; ============================================================
#Include src\gui\hotkey_function_browser.ahk

; ============================================================
; Module: src\gui\hotkey_capture.ahk
; ============================================================
#Include src\gui\hotkey_capture.ahk

; ============================================================
; Module: src\gui\hotkey_capslock_slots.ahk
; ============================================================
#Include src\gui\hotkey_capslock_slots.ahk

; ============================================================
; Module: src\gui\hotkey_cheatsheet.ahk
; ============================================================
#Include src\gui\hotkey_cheatsheet.ahk

; ============================================================
; Module: src\gui\pie_quick_hotkeys.ahk
; ============================================================
#Include src\gui\pie_quick_hotkeys.ahk

; ============================================================
; Module: src\gui\main_gui.ahk
; ============================================================
#Include src\gui\main_gui.ahk

; ============================================================
; Module: src\gui\opacity_and_scale.ahk
; ============================================================
#Include src\gui\opacity_and_scale.ahk

; ============================================================
; Module: src\settings\auto_save_interval.ahk
; ============================================================
#Include src\settings\auto_save_interval.ahk

; ============================================================
; Module: src\settings\hotkey_profiles.ahk
; ============================================================
#Include src\settings\hotkey_profiles.ahk

; ============================================================
; Module: src\settings\backup_restore.ahk
; ============================================================
#Include src\settings\backup_restore.ahk

; ============================================================
; Module: src\tools\csp_monitor.ahk
; ============================================================
#Include src\tools\csp_monitor.ahk

; ============================================================
; Optional Module: src\dev\dev.ahk
; Comment/remove this optional include to exclude developer/release tools.
; ============================================================
#Include src\dev\dev.ahk

; AUTO-EXECUTE (runs at startup)
; ============================================================

OnMessage(0x201, WM_LBUTTONDOWN)
OnMessage(0x201, WM_ModeDrag)
OnMessage(0x200, WM_MOUSEMOVE)
OnMessage(0x200, WM_ModeDragMove)
OnMessage(0x202, WM_ModeDragUp)
OnMessage(0x0232, WM_EXITSIZEMOVE)

InitHotkeyDefs()
HK_Load()
ModeSettingsApplyStartup()
; Load the active mode's feature switches AFTER retargeting so they come from
; the mode's own feature_switches.ini (default mode uses the base file).
LoadFeatureSwitches()
DebugLog("Startup: loaded feature switches for mode '" HK_ModeActive() "'")

LoadConfigurablePaths()  ; loads paths, URLs, click coords from INI
DebugLog("Startup: loaded configurable paths")
InitHoverPopup()
LoadLinkItems()
DebugLog("Startup: loaded link items (" LinkItems.Length " total)")
LoadColorItems()
DebugLog("Startup: loaded color items")
SettingsDiagPush("TRACE", "Pre-LoadPieItems check", PIE_SETTINGS_FILE " exists=" FileExist(PIE_SETTINGS_FILE) " size=" (FileExist(PIE_SETTINGS_FILE) ? FileGetSize(PIE_SETTINGS_FILE) : "N/A") " time=" (FileExist(PIE_SETTINGS_FILE) ? FileGetTime(PIE_SETTINGS_FILE, "M") : "N/A"))
LoadPieItems()
DebugLog("Startup: loaded pie settings (" PieCount " pies, " PieQuickHotkeys.Length " quick)")
LoadGUIPositions()
DebugLog("Startup: loaded GUI positions")
_LoadIBThemeFromIni()
_LoadColorHistory()
ColorInfoApplyMiddlePickHotkey()
ApplyAutoScale()
EnsureConfigVersion()
PieQuickCopyBundledPresets()
DebugLog("Startup: init complete for mode '" HK_ModeActive() "'")

; Check for old config without new settings
if _settingsNeedUpgrade && !FirstRunSetup {
    ReqAnimationEnabled := 0
    ReqNastarEnabled := 0
    IniWrite(ReqAnimationEnabled, SETTINGS_FILE, "Settings", "ReqAnimation")
    IniWrite(ReqNastarEnabled, SETTINGS_FILE, "Settings", "ReqNastar")
    FirstRunSetup := true
    HotkeysPaused := true
}

CreateMainGui()
; Apply the active mode's forced toggles (e.g. LT Lock always-on in Tracing
; mode) now that the toolbar buttons exist; the CheckCSP poll re-enforces later.
HK_ApplyModeFlags(HK_ModeActive())

; Show all GUIs at startup — created lazily on first show
if WinExist("ahk_exe CLIPStudioPaint.exe") {
    _EnsureGUIs()
    IB_PositionGui()
    PositionColorGui()
    PositionLinkGUI()
    try {
        if MainGUI_X || MainGUI_Y
            MainGUI.Show("x" MainGUI_X " y" MainGUI_Y " NoActivate")
        else
            MainGUI.Show("NoActivate")
    }
    MainGUIVisible := true
    ColorGUIVisible := FeatureEnabled("colorgui")
    LinkGUIVisible := FeatureEnabled("linkgui")
    IBVisible := FeatureEnabled("ibgui")
} else {
    MainGUIVisible := false
    ColorGUIVisible := false
    LinkGUIVisible := false
    IBVisible := false
}
if IsObject(MainGUI) {
    if GuiHasCtrl(MainGUI, "btnIB")
        MainGUI.btnIB.Opt("Background4CAF50 cFFFFFF")
    if GuiHasCtrl(MainGUI, "btnLink")
        MainGUI.btnLink.Opt("Background4CAF50 cFFFFFF")
    if GuiHasCtrl(MainGUI, "btnColor")
        MainGUI.btnColor.Opt("Background4CAF50 cFFFFFF")
}
FeatureApplyGUIHides()
UpdateMainGuiStateButtons()

if IsObject(_LoadingGUI)
    _LoadingGUI.Destroy()

; Start CSP focus monitor for timer auto-pause/resume
SetTimer(CheckCSPFocus, 1000)
CheckCSPFocus()

; First run: center all GUIs and keep custom hotkeys paused until setup is done.
if FirstRunSetup
    ResetGUIPositions()

; Apply custom hotkey overrides on top of :: defaults
HK_ReapplyAll()
UpdateResetWatchdog()

RestoreSafeMode()
UpdateStartupHealthBadge()
SetTimer(DoAutoSave, AutoSaveInterval * 1000)

_OnExitSave(*) {
    global _debugSaveOnExit
    SetTimer(CheckIniChanges, 0)
    try SaveGUIPositions()
    try SaveConfigurablePaths()
    try HK_Save()
    try SaveLinkItems()
    try SavePieItems()
    try SaveColorItems()
    try SaveFeatureSwitches()
    try _SaveColorHistory()
    try if _debugSaveOnExit
        SaveDebugLog()
}
OnExit(_OnExitSave)

SetTimer(CheckCSP, 200)
SetTimer(CheckIniChanges, 3000)
; First-run wizard
if FirstRunSetup
    SetTimer(FirstRunWizard, -100)


