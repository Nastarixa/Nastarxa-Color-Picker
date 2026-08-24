;FEATURES - Guide, Wizard, Help
; ============================================================

_DocsPath(name) {
    return A_ScriptDir "\src\docs\" name
}

_LoadGuideMd(fileName, missingTitle) {
    path := _DocsPath(fileName)
    if !FileExist(path) {
        ShowNotify("Guide", fileName " not found", "0xE53935")
        return ""
    }
    try raw := FileRead(path, "UTF-8")
    if !IsSet(raw) || !raw {
        ShowNotify("Guide", fileName " not found", "0xE53935")
        return ""
    }
    return _RenderMdPlain(raw)
}

_RenderMdPlain(raw) {
    txt := StrReplace(raw, "`r`n", "`n")                          ; normalize CRLF
    txt := RegExReplace(txt, "s)``````.*?``````", "[code block]")  ; code blocks (before emphasis)
    txt := RegExReplace(txt, "m)^ {0,3}#{1,6}\s*", "")             ; headings
    txt := RegExReplace(txt, "\*\*(.+?)\*\*", "$1")                ; bold
    txt := RegExReplace(txt, "(?<!\*)\*(?!\*)(.+?)\*(?!\*)", "$1") ; italic
    txt := StrReplace(txt, "``", "")                               ; inline code ticks
    txt := _MdTablesAlign(txt)                                     ; aligned table columns
    txt := RegExReplace(txt, "m)^ {0,3}(-{3,}|_{3,})\s*$", SubStr("————————————————————————————————————", 1, 40))
    txt := RegExReplace(txt, "m)^\s*[-*]\s+", "  · ")              ; bullet lists
    txt := RegExReplace(txt, "m)^\s*\d+\.\s+", "  ")               ; numbered lists
    txt := RegExReplace(txt, "`n{3,}", "`n`n")                     ; collapse blank lines
    return txt
}

_MdSectionList(fileName) {
    ; Splits a markdown file into sections on '## ' headings (### stays inside).
    path := _DocsPath(fileName)
    if !FileExist(path)
        return []
    try raw := FileRead(path, "UTF-8")
    catch
        return []
    raw := StrReplace(raw, "`r`n", "`n")
    secs := []
    cur := ""
    started := false
    for _, line in StrSplit(raw, "`n") {
        if RegExMatch(line, "^ {0,3}## ") {
            if started
                secs.Push(_RenderMdPlain(cur))
            cur := ""
            started := true
            continue
        }
        cur .= line "`n"
    }
    if started
        secs.Push(_RenderMdPlain(cur))
    return secs
}

_MdTabContent(fileName, n) {
    global _MdTabCache, _MdTabWarned
    if !_MdTabCache.Has(fileName)
        _MdTabCache[fileName] := _MdSectionList(fileName)
    secs := _MdTabCache[fileName]
    if !secs.Length {
        if !_MdTabWarned.Has(fileName) {
            _MdTabWarned[fileName] := true
            ShowNotify("Guide", fileName " not found", "0xE53935")
        }
        return ""
    }
    return (n >= 1 && n <= secs.Length) ? secs[n] : ""
}

_MdGuidesReload(*) {
    global _MdTabCache, _MdTabWarned
    _MdTabCache := Map()
    _MdTabWarned := Map()
    ShowNotify("Guides", "Guide cache cleared - MD files reload on next open", "00897B")
}

global _MdTabCache := Map()
global _MdTabWarned := Map()

_MdHelpDialog(titleText, subText, fileName) {
    txt := _LoadGuideMd(fileName, titleText)
    if (txt = "")
        return
    dlg := Gui("+AlwaysOnTop +ToolWindow", titleText)
    dlg.BackColor := TC("bgDark")
    dlg.SetFont("s10", "Segoe UI")
    dlg.MarginX := 14
    dlg.MarginY := 14

    dlg.SetFont("s13 Bold c" TC("textHi") "", "Segoe UI")
    dlg.AddText("xm w" S(640), titleText)
    dlg.SetFont("s9 norm c" TC("textDim") "", "Segoe UI")
    dlg.AddText("xm y+2 w" S(640), subText)

    dlg.SetFont("s9 c" TC("textMain") "", "Consolas")
    dlg.AddEdit("xm y+10 w" S(640) " h" S(560) " +ReadOnly +VScroll +Wrap Background" TC("bgPanel") " c" TC("textMain") "", txt)

    closeBtn := dlg.AddButton("xm y+10 w" S(100) " h" S(28) " Default", "Close")
    closeBtn.OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("AutoSize")
    closeBtn.Focus()
}

FirstRunSetupText() {
    return _LoadGuideMd("first_run_setup.md", "First Run")
}

FirstRunWizard(*) {
    global HotkeysPaused, SCRIPT_VERSION
    HotkeysPaused := true
    UpdateHotkeysPauseButton()

    dlg := Gui("+AlwaysOnTop +ToolWindow", "Nastarxa CSP Animator Toolkit - First Run")
    dlg.BackColor := TC("bgDark")
    dlg.SetFont("s" S(9) " c" TC("textHi") "", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)
    dlg.SetFont("s" S(11) " Bold", "Segoe UI")
    dlg.AddText("xm c" TC("textHi") "", "Welcome to Nastarxa CSP Animator Toolkit!")
    dlg.SetFont("s" S(8) " norm", "Segoe UI")
    dlg.AddText("x+8 yp+" S(3) " c" TC("accentTeal") "", "Version " SCRIPT_VERSION)
    dlg.SetFont("s" S(9) " norm", "Segoe UI")
    dlg.AddText("xm y+" S(6) " c" TC("accentGoldAlt") "", "Custom shortcuts are paused: HK is OFF.")
    dlg.AddText("xm y+" S(4) " c" TC("textMuted") "", "Finish CSP shortcut and System Settings setup first, then click HK to turn shortcuts ON.")
    dlg.AddEdit("xm y+" S(10) " w" S(692) " h" S(360) " ReadOnly +Wrap VScroll c" TC("black") " Background" TC("lightBg") "", FirstRunSetupText())
    ConfirmRequirementChoice(*) {
        confirm := Gui("+AlwaysOnTop +ToolWindow +Owner" dlg.Hwnd, "Confirm First Run Requirements")
        confirm.BackColor := TC("bgDark")
        confirm.SetFont("s" S(9) " c" TC("textHi") "", "Segoe UI")
        confirm.MarginX := S(14)
        confirm.MarginY := S(14)
        confirm.AddText("xm c" TC("accentGoldAlt") "", "Before continuing, please confirm:")
        confirm.AddText("xm y+" S(8) " w" S(440) " c" TC("textHi") "",
            "You understand that:")
        confirm.AddText("xm y+" S(4) " w" S(440) " c" TC("textMuted") "",
            "1. This script relies on CSP's shortcut keys being set to the toolkit recommended shortcuts manually by you. The System Settings step below applies the needed CSP-side shortcuts so the toolkit can communicate with CSP - skipping or changing them will break hotkeys.")
        confirm.AddText("xm y+" S(4) " w" S(440) " c" TC("textMuted") "",
            "2. This script makes heavy use of CSP Auto Actions. The following AutoAction presets must exist in CSP and be assigned to the shortcuts set in System Settings:")
        confirm.AddText("xm y+" S(4) " c" TC("accentGoldAlt") "", "   - Animation_autoaction.laf")
        confirm.AddText("xm y+" S(2) " c" TC("accentGoldAlt") "", "   - Nastar.laf")
        confirm.AddText("xm y+" S(8) " w" S(440) " c" TC("accentGoldAlt") "",
            "If either requirement is not met, many hotkeys will be disabled or fail silently.")
        understood := false
        confirm.AddButton("xm y+" S(12) " w" S(150) " h" S(28) " c" TC("textHi") " Default", "I Understand").OnEvent("Click", (*) => (understood := true, confirm.Destroy()))
        confirm.AddButton("x+" S(8) " yp w" S(110) " h" S(28), "Go Back").OnEvent("Click", (*) => confirm.Destroy())
        confirm.Show("AutoSize")
        GuiWaitForCloseSafe(confirm)
        return understood
    }
    FirstRunClose(thisGui, *) {
        if ConfirmRequirementChoice()
            dlg.Destroy()
    }
    dlg.OnEvent("Close", FirstRunClose)
    dlg.AddText("xm y+" S(10) " c" TC("textHi") "", "Open System Settings now?")
    result := false
    btnYes := dlg.AddButton("xm y+" S(10) " w" S(80) " h" S(26) " c" TC("textHi") " Default", "Yes")
    btnYes.OnEvent("Click", (*) => (
        ConfirmRequirementChoice() ? (result := true, dlg.Destroy()) : ""
    ))
    dlg.AddButton("x+" S(8) " yp w" S(80) " h" S(26), "No").OnEvent("Click", (*) => (
        ConfirmRequirementChoice() ? (result := false, dlg.Destroy()) : ""
    ))
    dlg.AddButton("x+" S(8) " yp w" S(100) " h" S(26) " c" TC("textHi") "", "Guide").OnEvent("Click", (*) => ShowCSPGuide())
    dlg.AddButton("x+" S(8) " yp w" S(170) " h" S(26) " c" TC("textHi") "", "Recommended Shortcut").OnEvent("Click", ShowCSPRecommended)
    dlg.AddButton("x+" S(8) " yp w" S(230) " h" S(26) " c" TC("textHi") "", "Import Config / Mode Bundle").OnEvent("Click", ShowImportConfigChoice)
    dlg.Show("AutoSize")
    btnYes.Focus()
    GuiWaitForCloseSafe(dlg)
    if result {
        ShowLTSettings()
        ShowNotify("First Run", "HK is OFF. Configure LT settings, then turn HK ON.")
    }
}
ShowCSPGuide() {
    global SCRIPT_VERSION
    content := _LoadGuideMd("toolkit_guide.md", "Toolkit Guide")
    if (content = "")
        return
    guide := Gui("+AlwaysOnTop +ToolWindow", "Nastarxa CSP Animator Toolkit")
    guide.BackColor := TC("bgDark")
    guide.SetFont("s10", "Segoe UI")
    guide.MarginX := 14
    guide.MarginY := 14

    guide.SetFont("s13 Bold", "Segoe UI")
    guide.AddText("c" TC("textHi") "", "Nastarxa CSP Animator Toolkit - Guide")
    guide.SetFont("s9 norm", "Segoe UI")
    guide.AddText("x+8 yp+4 c" TC("accentTeal") "", "Version " SCRIPT_VERSION)
    guide.SetFont("s9 norm", "Segoe UI")
    guide.AddText("xm y+4 c" TC("textSoft") " w620",
        "Productivity hotkeys and automation for Clip Studio Paint.")

    guide.SetFont("s9 c" TC("textMain") "", "Consolas")
    guide.AddEdit("xm y+10 w640 h500 +ReadOnly +VScroll +Wrap Background" TC("bgPanel") " c" TC("textMain") "", content)

    guide.AddButton("xm y+10 w" S(170) " h" S(28) " c" TC("textHi") "", "First Run Setup").OnEvent("Click", FirstRunWizard)
    guide.AddButton("x+8 yp w" S(200) " h" S(28) " c" TC("textHi") "", "Recommended Shortcut").OnEvent("Click", ShowCSPRecommended)
    btnClose := guide.AddButton("x+8 yp w100 h28 Default", "Close")
    btnClose.Focus()
    btnClose.OnEvent("Click", (*) => guide.Destroy())

    guide.Show("Autosize")
}

HK_HowToUse(*) {
    dlg := Gui("+AlwaysOnTop +ToolWindow", "How to Use - Hotkey Settings")
    dlg.BackColor := TC("bgDark")

   dlg.SetFont("s10 Bold c" TC("textHi") "", "Segoe UI")
    dlg.AddText("xm", "Hotkey Settings Help")

    dlg.SetFont("s8 norm c" TC("textMuted") "")
    dlg.AddText("xm y+2", "Manage and customize your shortcuts.")

    dlg.AddText("xm y+8 w430 h1 Background" TC("bgDivider") "")

    ; LEFT COLUMN
    dlg.SetFont("s9 Bold c" TC("textHi") "")
    dlg.AddText("xm y+10", "EDITING")

    dlg.SetFont("s9 norm c" TC("textHi") "")
    dlg.AddText(
        "xm y+4 w180",
        "- Edit`n Opens the Edit Hotkey window to change the selected hotkey.`n `n "
        "- ON / OFF`n Disables or re-enables the selected hotkey(s). Disabled hotkeys show Disabled status.`n `n "
        "- Reset Selected`n Restores selected hotkey(s) to default.`n `n "
        "- Reset All`n Restores ALL hotkeys to defaults."
    )

    dlg.SetFont("s9 Bold c" TC("textHi") "")
    dlg.AddText("xm y+10", "IMPORT / EXPORT")

    dlg.SetFont("s9 norm c" TC("textHi") "")
    dlg.AddText(
        "xm y+4 w180",
        "- Export`nSaves your custom hotkeys to a file.`n`n"
        "- Import`nLoads custom hotkeys from a file.`n`n"
        "- Details`nShows info about the selected action."
    )

    ; RIGHT COLUMN
    x2 := S(220)

    dlg.SetFont("s9 Bold c" TC("textHi") "")
    dlg.AddText("x" x2 " y63", "HOTKEY SETTINGS LIST")

    dlg.SetFont("s9 norm c" TC("textHi") "")
    dlg.AddText(
        "x" x2 " y83 w210",
        "Action: toolkit action name`n"
        "Hotkey: current key combo`n"
        "Requirement: needed CSP preset`n"
        "AHK Function: callable function`n"
        "Status: enabled/conflict/disabled`n"
        "Outside: can run while CSP is not active"
    )

    dlg.SetFont("s9 Bold c" TC("textHi") "")
    dlg.AddText("x" x2 " y190", "RECORDING / FORMAT")

    dlg.SetFont("s9 norm c" TC("textHi") "")
    dlg.AddText(
        "x" x2 " y210 w210",
        "Record: click Record, press shortcut, Apply.`n`n"
        "Single Keys`n"
        "A, 1, Space, Tab, F1-F24`n`n"
        "Modifiers`n"
        "^ = Ctrl`n"
        "+ = Shift`n"
        "! = Alt`n"
        "# = Win`n`n"
        "Examples`n"
        "^c`n"
        "^+s`n"
        "^!+#t"
    )

    dlg.AddText("xm w430 h1 Background" TC("bgDivider") "")

    dlg.SetFont("s9 norm c" TC("warnYellow") "")
    dlg.AddText("xm y+8", "Disable a hotkey with ON/OFF. Disable only its function with Enable AHK Function in Edit Hotkey.")
    dlg.AddText("xm y+6 w430 c" TC("warnYellow") "", "Requirement shows when a hotkey can run. Outside means the hotkey may run while CSP is not active.")

    dlg.AddButton(
        "xm y+12 w240 h28",
        "Recommended CSP Shortcuts"
    ).OnEvent("Click", ShowCSPRecommended)
    
    dlg.btnClose := dlg.AddButton("x+8 yp w90 h28 Default","Close")

    dlg.btnClose.OnEvent("Click", (*) => dlg.Destroy())

    dlg.Show("AutoSize")
    dlg.btnClose.Focus()
}

ShowCSPRecommended(*) {
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Recommended CSP Shortcuts")
    dlg.BackColor := TC("lightBg")
    dlg.SetFont("s" S(9) " c" TC("lightText") "", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)

    dlg.SetFont("s8", "Segoe UI")
    dlg.AddText("xm c" TC("lightSub") "", "Recommended CSP shortcut settings for using this script at its maximum potential.")
    dlg.SetFont("s" S(9), "Segoe UI")

    tabs := ["File/Edit", "Animation", "Layer", "Select/View", "Options", "Tools", "Auto/Nastar"]
    tab := dlg.AddTab3("xm y+6 w" S(580) " h" S(420) " Background" TC("lightBg") " c" TC("lightText") " ", tabs)
    dlg.SetFont("s9", "Consolas")

    loop 7 {
        tab.UseTab(A_Index)
        ed := dlg.AddEdit("xm y+1 w" S(580) " h" S(420) " +ReadOnly +VScroll +Wrap Background" TC("lightBg") " c" TC("lightText") "", "")
        ed.Value := RecContent(A_Index)
    }

    tab.UseTab(0)
    dlg.SetFont("s" S(9), "Segoe UI")

    dlg.btnGuidePopups := dlg.AddButton("xm yp+402 w" S(130) " h" S(26), "Guide Popups")
    dlg.btnGuidePopups.OnEvent("Click", ShowGuideNotifyMenu)

    dlg.btnClose := dlg.AddButton("x+8 yp w" S(80) " h" S(26) " Default","Close")

    dlg.btnClose.OnEvent("Click", (*) => dlg.Destroy())

    dlg.Show("w" S(620) " h" S(495))
    dlg.btnClose.Focus()
}

GuideModeNotify(*) {
    popup := Gui("+AlwaysOnTop +ToolWindow", "Modes Guide")
    popup.BackColor := TC("bgDark")
    popup.SetFont("s" S(9) " c" TC("textHi") "", "Segoe UI")
    popup.MarginX := S(14)
    popup.MarginY := S(14)
    txt := "
    (LTrim
  Double-click the IB bottom bar:   open the mode selector
  Alt+click the IB bottom bar:          next mode
  IB context menu > Select Mode:    switch mode
  Main GUI Modes button:                manage modes

  Each mode can set its own switch hotkey
  Mode hotkeys: switch mode, then edit keys in Hotkey Settings
  Use 'Show advanced (built-in) modes' to list built-ins
    )"
    popup.SetFont("s" S(9) " c" TC("textHi") " Bold", "Segoe UI")
    popup.AddText("xm w" S(380) " c" TC("textHi") "", "MODES")
    popup.SetFont("s" S(9) " c" TC("textHi") " Norm", "Segoe UI")
    popup.AddText("xm w" S(380) " c" TC("textHi") "", txt)
    popup.AddButton("xm y+10 w" S(80) " h" S(26) " Default", "OK").OnEvent("Click", (*) => popup.Destroy())
    popup.Show("AutoSize")
}

ShowGuideNotifyMenu(*) {
    popup := Gui("+AlwaysOnTop +ToolWindow", "Guide Popup Buttons")
    popup.BackColor := TC("lightBg")
    popup.SetFont("s" S(9) " c" TC("lightText") "", "Segoe UI")
    popup.MarginX := S(14)
    popup.MarginY := S(14)

    popup.SetFont("s" S(10) " Bold c" TC("lightText") "", "Segoe UI")
    popup.AddText("xm w" S(320), "Quick Guide Notifications")
    popup.SetFont("s" S(8) " norm c" TC("lightDim") "", "Segoe UI")
    popup.AddText("xm y+4 w" S(320), "These are the same callable functions used by guide.ini / Guide Pie.")
    popup.SetFont("s" S(9) " c" TC("lightText") "", "Segoe UI")

    bw := S(180), bh := S(28)
    popup.AddButton("xm y+12 w" bw " h" bh, "InBetween").OnEvent("Click", GuideIBNotify)
    popup.AddButton("x+8 yp w" bw " h" bh, "Create New").OnEvent("Click", GuideCreateNotify)
    popup.AddButton("xm y+8 w" bw " h" bh, "Shortcuts").OnEvent("Click", GuideShortcutNotify)
    popup.AddButton("x+8 yp w" bw " h" bh, "AutoAction / Utility").OnEvent("Click", GuideAutoActionNotify)
    popup.AddButton("xm y+8 w" bw " h" bh, "Animation").OnEvent("Click", GuideAnimationNotify)
    popup.AddButton("x+8 yp w" bw " h" bh, "Modes").OnEvent("Click", GuideModeNotify)
    popup.AddButton("xm y+8 w" bw " h" bh " Default", "Close").OnEvent("Click", (*) => popup.Destroy())

    popup.Show("AutoSize")
}

ShowTutorial(*) {
    tutorialPath := A_ScriptDir "\src\docs\tutorial.md"
    if !FileExist(tutorialPath) {
        ShowNotify("Tutorial", "tutorial.md not found", "0xE53935")
        return
    }
    try raw := FileRead(tutorialPath, "UTF-8")
    if !IsSet(raw) || !raw {
        ShowNotify("Tutorial", "tutorial.md not found", "0xE53935")
        return
    }
    txt := _RenderMdPlain(raw)

    dlg := Gui("+AlwaysOnTop +ToolWindow", "Tutorial — CSP Animator Toolkit")
    dlg.BackColor := TC("bgDark")
    dlg.SetFont("s10", "Segoe UI")
    dlg.MarginX := 14
    dlg.MarginY := 14

    dlg.SetFont("s13 Bold c" TC("textHi") "", "Segoe UI")
    dlg.AddText("xm w" S(640), "CSP Animator Toolkit — Tutorial")
    dlg.SetFont("s9 norm c" TC("textDim") "", "Segoe UI")
    dlg.AddText("xm y+2 w" S(640), "Step-by-step guide to every feature.")

    dlg.SetFont("s9 c" TC("textMain") "", "Consolas")
    dlg.AddEdit("xm y+10 w" S(640) " h" S(560) " +ReadOnly +VScroll +Wrap Background" TC("bgPanel") " c" TC("textMain") "", txt)

    closeBtn := dlg.AddButton("xm y+10 w" S(100) " h" S(28) " Default", "Close")
    closeBtn.OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("AutoSize")
    closeBtn.Focus()
}

_MdTablesAlign(txt) {
    out := ""
    tbl := []
    for _, line in StrSplit(txt, "`n") {
        if RegExMatch(line, "^\s*\|") {
            probe := Trim(line)
            probe := RegExReplace(probe, "^\|+|\|+$")
            cells := []
            isSep := true
            for _, p in StrSplit(probe, "|") {
                t := Trim(p)
                if !(t = "" || RegExMatch(t, "^:?-+:?$"))
                    isSep := false
                cells.Push(t)
            }
            if !isSep
                tbl.Push(cells)
            continue
        }
        out .= _MdFlushTable(tbl)
        tbl := []
        out .= RTrim(line) "`n"
    }
    out .= _MdFlushTable(tbl)
    return out
}

_MdFlushTable(tbl) {
    if !tbl.Length
        return ""
    cols := 0
    for _, cs in tbl
        cols := Max(cols, cs.Length)
    widths := []
    Loop cols
        widths.Push(0)
    for _, cs in tbl
        Loop cs.Length
            if StrLen(cs[A_Index]) > widths[A_Index]
                widths[A_Index] := StrLen(cs[A_Index])
    s := ""
    for _, cs in tbl {
        row := "   "
        Loop cols {
            idx := A_Index
            cell := idx <= cs.Length ? cs[idx] : ""
            row .= cell
            if idx < cols
                row .= SubStr("                                                                                                                ", 1, Max(widths[idx] - StrLen(cell), 0)) "   "
        }
        s .= RTrim(row) "`n"
        if (A_Index = 1 && tbl.Length > 1)
            s .= _MdRuleRow(widths, cols) "`n"
    }
    return s "`n"
}

_MdRuleRow(widths, cols) {
    u := "   "
    Loop cols {
        idx := A_Index
        u .= _MdRepeat("─", widths[idx])
        if idx < cols
            u .= "   "
    }
    return RTrim(u)
}

_MdRepeat(ch, n) {
    out := ""
    Loop n
        out .= ch
    return out
}

ShowIBBarHelp(*) {
    _MdHelpDialog("IB GUI Feature — IB Bar", "Indicator, diagram and slot buttons.", "ib_bar_guide.md")
}

ShowTimerHelp(*) {
    _MdHelpDialog("IB GUI Feature — Timer", "Timer / stopwatch row of the IB GUI.", "timer_guide.md")
}

ShowTogglesHelp(*) {
    _MdHelpDialog("IB GUI Feature — Toggles", "Toggle buttons and status bar on the IB GUI.", "toggles_guide.md")
}

ShowGuideCentre(*) {
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Guide Centre")
    dlg.BackColor := TC("bgDark")
    dlg.SetFont("s" S(9) " c" TC("textHi") "", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)

    dlg.SetFont("s" S(10) " Bold c" TC("textHi") "", "Segoe UI")
    dlg.AddText("xm w" S(368), "Guide Centre")
    dlg.SetFont("s" S(8) " norm c" TC("textDim") "", "Segoe UI")
    dlg.AddText("xm y+2 w" S(368), "Open any guide or help page.")

    bw := S(180), bh := S(28)

    dlg.SetFont("s" S(9) " c" TC("textHi") "", "Segoe UI")
    dlg.AddText("xm y+12 w" S(368) " c" TC("accentGold") "", "Guides & Wizards")
    dlg.AddButton("xm y+4 w" bw " h" bh, "Full Toolkit Guide").OnEvent("Click", (*) => ShowCSPGuide())
    dlg.AddButton("x+8 yp w" bw " h" bh, "Recommended Shortcuts").OnEvent("Click", ShowCSPRecommended)
    dlg.AddButton("xm y+8 w" bw " h" bh, "First Run Wizard").OnEvent("Click", FirstRunWizard)
    dlg.AddButton("x+8 yp w" bw " h" bh, "Modes Guide").OnEvent("Click", GuideModeNotify)

    dlg.AddText("xm y+12 w" S(368) " c" TC("accentGold") "", "Guide Notifications (Popups)")
    dlg.AddButton("xm y+4 w" bw " h" bh, "InBetween").OnEvent("Click", GuideIBNotify)
    dlg.AddButton("x+8 yp w" bw " h" bh, "Create New Layers").OnEvent("Click", GuideCreateNotify)
    dlg.AddButton("xm y+8 w" bw " h" bh, "Keyboard Shortcuts").OnEvent("Click", GuideShortcutNotify)
    dlg.AddButton("x+8 yp w" bw " h" bh, "AutoAction / Utility").OnEvent("Click", GuideAutoActionNotify)
    dlg.AddButton("xm y+8 w" bw " h" bh, "Animation").OnEvent("Click", GuideAnimationNotify)
    dlg.AddButton("x+8 yp w" bw " h" bh, "Timer / Worklog").OnEvent("Click", GuideTimerNotify)

    dlg.AddText("xm y+12 w" S(368) " c" TC("accentGold") "", "IB GUI Features")
    bw3 := S(117)
    dlg.AddButton("xm y+4 w" bw3 " h" bh, "IB").OnEvent("Click", ShowIBBarHelp)
    dlg.AddButton("x+8 yp w" bw3 " h" bh, "Toggles").OnEvent("Click", ShowTogglesHelp)
    dlg.AddButton("x+8 yp w" bw3 " h" bh, "Timer").OnEvent("Click", ShowTimerHelp)

    dlg.AddText("xm y+12 w" S(368) " c" TC("accentGold") "", "Help Pages")
    dlg.AddButton("xm y+4 w" bw " h" bh, "System Settings Help").OnEvent("Click", ShowLTSettingsHelp)
    dlg.AddButton("x+8 yp w" bw " h" bh, "Hotkey Settings Help").OnEvent("Click", HK_HowToUse)
    dlg.AddButton("xm y+8 w" bw " h" bh, "User Function (Metadata) Guide").OnEvent("Click", HK_UserFunctionMetaGuide)
    dlg.AddButton("x+8 yp w" bw " h" bh, "AHK Function (Script) Guide").OnEvent("Click", HK_ShowFunctionFieldGuide)
    dlg.AddButton("xm y+8 w" bw " h" bh, "Keys Guide").OnEvent("Click", ShowKeysGuide)
    dlg.AddButton("x+8 yp w" bw " h" bh, "Hotkey Guide").OnEvent("Click", (*) => HK_CheatSheetGuideShow())
    dlg.AddButton("xm y+8 w" bw " h" bh, "Tutorial (Full Walkthrough)").OnEvent("Click", ShowTutorial)
    dlg.AddButton("x+8 yp w" bw " h" bh, "Notification Center").OnEvent("Click", ShowNotifyCenter)
    dlg.AddButton("xm y+8 w" bw " h" bh, "Reload Guides").OnEvent("Click", _MdGuidesReload)

    dlg.AddButton("xm y+12 w" S(368) " h" bh " Default", "Close").OnEvent("Click", (*) => dlg.Destroy())

    dlg.Show("AutoSize")
}

RecContent(n) {
    return _MdTabContent("recommended_shortcuts.md", n)
}


ShowLTSettingsHelp(*) {
    popup := Gui("+AlwaysOnTop +ToolWindow", "How To - System Settings")
    popup.BackColor := TC("lightBg")
    popup.SetFont("s" S(9) " c" TC("lightText") "", "Segoe UI")
    popup.MarginX := S(14)
    popup.MarginY := S(14)

    popup.SetFont("s8 c" TC("lightDim") "", "Segoe UI")
    popup.AddText("xm w" S(620), "System Settings controls calibration, requirements, timing, Color Info, autosave, and backup/import tools.")
    popup.SetFont("s" S(9) " c" TC("lightText") "", "Segoe UI")

    tabs := ["Overview", "Detection", "Color Info", "Presets", "Timing", "Backup"]
    tab := popup.AddTab3("xm y+8 w" S(640) " h" S(360) " Background" TC("lightBg") " c" TC("lightText") "", tabs)
    popup.SetFont("s9 c" TC("lightText") "", "Consolas")

    loop tabs.Length {
        tab.UseTab(A_Index)
        ed := popup.AddEdit("xm y+1 w" S(640) " h" S(360) " +ReadOnly +VScroll +Wrap Background" TC("lightBg") " c" TC("lightText") "", "")
        ed.Value := LTSettingsHelpContent(A_Index)
    }

    tab.UseTab(0)
    popup.SetFont("s" S(9) " c" TC("lightText") "", "Segoe UI")
    popup.AddButton("xm y" S(403) " w" S(200) " h" S(26), "Recommended Shortcut").OnEvent("Click", ShowCSPRecommended)
    popup.AddButton("x+8 yp w" S(80) " h" S(26) " Default", "OK").OnEvent("Click", (*) => popup.Destroy())
    popup.Show("AutoSize")
}

LTSettingsHelpContent(n) {
    return _MdTabContent("system_settings_help.md", n)
}


; --- Hotkey Guide Window ---
global _HK_GuideGui := 0

HK_CheatSheetGuideShow(*) {
    global _HK_GuideGui
    if IsObject(_HK_GuideGui) {
        try {
            if _HK_GuideGui.HasProp("Hwnd") && _HK_GuideGui.Hwnd {
                _HK_GuideGui.Destroy()
            }
        }
        _HK_GuideGui := 0
        return
    }
    g := Gui("+AlwaysOnTop +ToolWindow", "Hotkey Guide")
    g.BackColor := TC("bgDark")
    g.MarginX := S(10)
    g.MarginY := S(10)
    g.SetFont("s" S(9) " c" TC("textHi") "", "Segoe UI")
    g.AddText("c" TC("textSub") "", "What each field in the Hotkey Settings window means.")
    ed := g.AddEdit("xm w" S(780) " h" S(520) " ReadOnly VScroll c" TC("textSub") " Background" TC("bgDark") " +Wrap", HK_CheatSheetGuideText())
    ed.SetFont("s" S(8), "Consolas")
    g.ed := ed
    closeBtn := g.AddButton("xm y+6 w" S(80) " h" S(24) " c" TC("textHi") " Default", "Close")
    closeBtn.OnEvent("Click", (*) => HK_CheatSheetGuideClose())
    g.OnEvent("Close", (*) => HK_CheatSheetGuideClose())
    g.Show("x" (A_ScreenWidth - S(810)) " y" S(50) " NoActivate")
    _HK_GuideGui := g
    closeBtn.Focus()
}

HK_CheatSheetGuideClose() {
    global _HK_GuideGui
    try _HK_GuideGui.Destroy()
    _HK_GuideGui := 0
}

HK_CheatSheetGuideText() {
    return _LoadGuideMd("hotkey_field_guide.md", "Hotkey Guide")
}
