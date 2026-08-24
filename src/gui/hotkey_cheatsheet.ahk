; CHEAT SHEET — Per-mode hotkey overlay
; ============================================================
; An always-on-top dark tool window listing the effective hotkeys for the
; currently active mode, grouped by context, plus every mode's switch hotkey.
; Refreshes every 1.5s while open so mode switches / edits are reflected
; live. Position is persisted in gui_settings.ini. Gated by the "Hotkey
; Cheat Sheet" feature switch and bound to the toggle_cheat_sheet hotkey
; (default ^+F2, global group, exempt from the typing safeguard so it
; always toggles).
;
; Toggle between "All" hotkeys and "Changes only" (diffs against Default
; mode) using the button at the bottom of the window.

global _CheatSheetGui := 0
global _CheatSheetPosX := ""
global _CheatSheetPosY := ""
global _CheatSheetDiff := false

HK_CheatSheetToggle(*) {
    global _CheatSheetGui
    if !FeatureEnabled("cheatsheet") {
        ShowNotify("Hotkey Cheat Sheet", "Disabled in the Feature Switcher", "0xE53935")
        return
    }
    if IsObject(_CheatSheetGui) && _CheatSheetGui.HasProp("Hwnd") && _CheatSheetGui.Hwnd
        HK_CheatSheetClose()
    else
        HK_CheatSheetShow()
}

HK_CheatSheetShow() {
    global _CheatSheetGui, _CheatSheetPosX, _CheatSheetPosY, _CheatSheetDiff, SETTINGS_FILE
    if IsObject(_CheatSheetGui) && _CheatSheetGui.HasProp("Hwnd") && _CheatSheetGui.Hwnd
        return
    _CheatSheetDiff := false
    if _CheatSheetPosX = ""
        try _CheatSheetPosX := IniRead(SETTINGS_FILE, "Settings", "CheatSheetX", "")
    if _CheatSheetPosY = ""
        try _CheatSheetPosY := IniRead(SETTINGS_FILE, "Settings", "CheatSheetY", "")
    g := Gui("+AlwaysOnTop +ToolWindow", "Hotkey Cheat Sheet")
    g.BackColor := "1E1F22"
    g.MarginX := S(10)
    g.MarginY := S(10)
    ed := g.AddEdit("w" S(400) " h" S(430) " ReadOnly VScroll cD7D7D7 Background1E1F22 -Wrap", HK_CheatSheetText())
    ed.SetFont("s" S(9), "Consolas")
    g.ed := ed
    diffBtn := g.AddButton("xm w" S(90) " h" S(24) " cFFFFFF", "Changes")
    diffBtn.OnEvent("Click", HK_CheatSheetToggleDiff.Bind(diffBtn))
    AddHoverPopup(diffBtn, "Toggle: show all hotkeys or only changes from Default mode")
    closeBtn := g.AddButton("x+4 yp w" S(90) " h" S(24) " cFFFFFF", "Close")
    closeBtn.OnEvent("Click", (*) => HK_CheatSheetClose())
    g.diffBtn := diffBtn
    opt := ""
    if _CheatSheetPosX = "" || _CheatSheetPosY = ""
        opt := "x" (A_ScreenWidth - S(430)) " y" S(50)
    else
        opt := "x" _CheatSheetPosX " y" _CheatSheetPosY
    g.Show(opt " NoActivate")
    _CheatSheetGui := g
    SetTimer(HK_CheatSheetRefresh, 1500)
    closeBtn.Focus()
}

HK_CheatSheetToggleDiff(btn, *) {
    global _CheatSheetDiff
    _CheatSheetDiff := !_CheatSheetDiff
    btn.Text := _CheatSheetDiff ? "All" : "Changes"
    HK_CheatSheetRefresh()
}

HK_CheatSheetClose() {
    global _CheatSheetGui, _CheatSheetPosX, _CheatSheetPosY, SETTINGS_FILE
    SetTimer(HK_CheatSheetRefresh, 0)
    if IsObject(_CheatSheetGui) && _CheatSheetGui.HasProp("Hwnd") && _CheatSheetGui.Hwnd {
        hwnd := _CheatSheetGui.Hwnd
        try {
            _CheatSheetGui.GetPos(&_CheatSheetPosX, &_CheatSheetPosY)
            try IniWrite(Round(_CheatSheetPosX), SETTINGS_FILE, "Settings", "CheatSheetX")
            try IniWrite(Round(_CheatSheetPosY), SETTINGS_FILE, "Settings", "CheatSheetY")
        } catch
        try _CheatSheetGui.Destroy()
        catch
        ; In the full toolkit context Destroy() can silently leave the native
        ; window alive while still returning OK, so force it down if it survived.
        if WinExist("ahk_id " hwnd)
            try DllCall("DestroyWindow", "Ptr", hwnd)
    }
    _CheatSheetGui := 0
}

HK_CheatSheetRefresh() {
    global _CheatSheetGui
    if !IsObject(_CheatSheetGui) || !_CheatSheetGui.HasProp("ed") {
        SetTimer(HK_CheatSheetRefresh, 0)
        return
    }
    newText := HK_CheatSheetText()
    if _CheatSheetGui.ed.Value != newText
        _CheatSheetGui.ed.Value := newText
}

; Builds a Map of hotkey-id -> effective-key for a given mode by reading
; its INI file directly (does not touch the live HK_Custom state).
HK_CheatSheetModeKeys(modeId) {
    global SETTINGS_DIR
    result := Map()
    if modeId = "default" {
        ini := ModeSettingsBaseFile("hotkey_settings.ini")
    } else {
        dir := ModeSettingsModeDir(modeId)
        ini := dir "\hotkey_settings.ini"
    }
    if !FileExist(ini)
        return result
    try {
        section := IniRead(ini, "Hotkeys")
    } catch {
        return result
    }
    if section = ""
        return result
    for line in StrSplit(section, "`n") {
        if !InStr(line, "=")
            continue
        id := HK_NormalizeSavedHotkeyId(Trim(SubStr(line, 1, InStr(line, "=") - 1)))
        val := HK_NormalizeSavedHotkeyValue(id, Trim(SubStr(line, InStr(line, "=") + 1)))
        result[id] := val
    }
    return result
}

; Returns the effective key for a hotkey in a given mode context.
; Falls back to the def if the mode INI has no override.
HK_CheatSheetEffectiveKey(d, modeKeys) {
    if modeKeys.Has(d.id) && modeKeys[d.id] != "" && modeKeys[d.id] != "-"
        return modeKeys[d.id]
    return d.def
}

; Reads the [ApplyBlock] section from a mode's INI and returns a Map of
; ahk-key → scope ("target" or "global").
HK_CheatSheetBlockedKeys(modeId) {
    global SETTINGS_DIR
    result := Map()
    if modeId = "default"
        ini := ModeSettingsBaseFile("hotkey_settings.ini")
    else {
        dir := ModeSettingsModeDir(modeId)
        ini := dir "\hotkey_settings.ini"
    }
    if !FileExist(ini)
        return result
    try section := IniRead(ini, "ApplyBlock")
    catch
        return result
    if section = ""
        return result
    for line in StrSplit(section, "`n") {
        if !InStr(line, "=")
            continue
        key := Trim(SubStr(line, 1, InStr(line, "=") - 1))
        val := Trim(SubStr(line, InStr(line, "=") + 1))
        if key != ""
            result[key] := val
    }
    return result
}

HK_CheatSheetText() {
    global HK_Modes, HK_ModeOrder, _CheatSheetDiff, HK_ApplyBlock
    active := HK_ModeActive()
    m := 0
    if IsObject(HK_Modes.Get(active, 0))
        m := HK_Modes[active]
    modeName := IsObject(m) ? m.Get("name", active) : active
    if _CheatSheetDiff
        lines := ["Changes vs Default - " modeName]
    else
        lines := ["Hotkeys - " modeName]
    groupLabel := Map("csp", "CSP", "csp_nav", "Navigation", "csp_caps", "CapsLock slots", "csp_reset", "Reset", "csp_lwin", "LWin hold", "global", "Global", "bg", "Background")
    ; In diff mode, pre-load default mode keys for comparison
    defKeys := _CheatSheetDiff ? HK_CheatSheetModeKeys("default") : 0
    cur := ""
    count := 0
    for d in HotkeyDefs {
        if !HK_IsRequirementEnabled(d)
            continue
        base := HK_Get(d.id, d.def)
        if _CheatSheetDiff {
            eff := HK_CheatSheetEffectiveKey(d, defKeys)
            if base = eff
                continue
        }
        if base = "" || base = "-"
            continue
        eff := HK_ModeEffectiveKey(d.id, base, m)
        if eff = "" || eff = "-"
            continue
        if d.group != cur {
            cur := d.group
            lines.Push("  [" groupLabel.Get(cur, cur) "]")
        }
        lines.Push("    " HK_DisplayKey(eff) "  " d.desc)
        count++
    }
    if count = 0
        lines.Push(_CheatSheetDiff ? "  (no changes from Default)" : "  (no enabled hotkeys)")
    ; --- Blocked Keys (Apply Block) ---
    blockedNow := HK_CheatSheetBlockedKeys(active)
    if _CheatSheetDiff {
        blockedDef := HK_CheatSheetBlockedKeys("default")
        bLines := []
        for k, v in blockedNow {
            if !blockedDef.Has(k) || blockedDef[k] != v
                bLines.Push("    " HK_DisplayKey(k) "  (" v ")")
        }
        for k, v in blockedDef {
            if !blockedNow.Has(k)
                bLines.Push("    " HK_DisplayKey(k) "  (removed)")
        }
        if bLines.Length > 0 {
            lines.Push("  [Blocked Keys]")
            for bl in bLines
                lines.Push(bl)
        }
    } else {
        if blockedNow.Count > 0 {
            lines.Push("  [Blocked Keys]")
            for k, v in blockedNow
                lines.Push("    " HK_DisplayKey(k) "  (" v ")")
        }
    }
    lines.Push("  [Mode switch]")
    for id in HK_ModeOrder {
        mm := HK_Modes.Get(id, 0)
        if !IsObject(mm)
            continue
        sw := mm.Get("switch", "")
        if sw = ""
            continue
        lines.Push("    " HK_DisplayKey(sw) "  " mm.Get("name", id) (id = active ? "  (active)" : ""))
    }
    text := ""
    for line in lines
        text .= line "`n"
    return RTrim(text, "`n")
}
