; HOTKEY PROFILE EXPORT/IMPORT
; ============================================================

ExportHotkeys(*) {
    global HK_Custom, HK_CustomFn, HK_CustomReq, HK_CustomActivate
    fn := FileSelect("S16", A_MyDocuments "\hotkey_profile.ini", "Export Hotkey Profile", "INI (*.ini)")
    if fn = ""
        return
    try {
        try IniDelete(fn, "Hotkeys")
        try IniDelete(fn, "HotkeyFns")
        try IniDelete(fn, "HotkeyRequirements")
        try IniDelete(fn, "HotkeyActivate")
        cnt := 0
        for id, val in HK_Custom {
            cnt++
            IniWrite(val, fn, "Hotkeys", id)
        }
        fnCnt := 0
        for id, val in HK_CustomFn {
            fnCnt++
            IniWrite(val, fn, "HotkeyFns", id)
        }
        actCnt := 0
        for id, val in HK_CustomActivate {
            if val {
                actCnt++
                IniWrite("1", fn, "HotkeyActivate", id)
            }
        }
        reqCnt := 0
        for id, val in HK_CustomReq {
            req := HK_NormalizeRequirement(val)
            if req != "" {
                reqCnt++
                IniWrite(req, fn, "HotkeyRequirements", id)
            }
        }
        IniWrite(cnt, fn, "Hotkeys", "count")
        IniWrite(fnCnt, fn, "HotkeyFns", "count")
        IniWrite(reqCnt, fn, "HotkeyRequirements", "count")
        IniWrite(actCnt, fn, "HotkeyActivate", "count")
        DebugLog("Exported " cnt " hotkeys to " fn)
        _HK_ResultPopup("Export", "Exported " cnt " custom hotkeys, " fnCnt " function assignments, " reqCnt " requirements, " actCnt " activate flags.", "4CAF50")
    } catch as e {
        _HK_ResultPopup("Export Error", "Export failed: " e.Message, "E53935")
    }
}

ImportHotkeys(*) {
    global HK_Custom, HK_CustomFn, HK_CustomReq, HK_CustomActivate
    fn := FileSelect("3", A_MyDocuments "\hotkey_profile.ini", "Import Hotkey Profile", "INI (*.ini)")
    if fn = ""
        return
    try {
        section := IniRead(fn, "Hotkeys")
        imported := 0
        for line in StrSplit(section, "`n") {
            if !InStr(line, "=")
                continue
            id := Trim(SubStr(line, 1, InStr(line, "=") - 1))
            val := Trim(SubStr(line, InStr(line, "=") + 1))
            if id = "count"
                continue
            HK_Custom[id] := HK_NormalizeSavedHotkeyValue(id, val)
            imported++
        }
        try {
            fnSection := IniRead(fn, "HotkeyFns")
        } catch {
            fnSection := ""
        }
        importedFns := 0
        if fnSection != "" {
            for line in StrSplit(fnSection, "`n") {
                if !InStr(line, "=")
                    continue
                id := Trim(SubStr(line, 1, InStr(line, "=") - 1))
                val := Trim(SubStr(line, InStr(line, "=") + 1))
                if id = "count"
                    continue
                HK_CustomFn[id] := val
                importedFns++
            }
        }
        try {
            reqSection := IniRead(fn, "HotkeyRequirements")
        } catch {
            reqSection := ""
        }
        importedReq := 0
        if reqSection != "" {
            for line in StrSplit(reqSection, "`n") {
                if !InStr(line, "=")
                    continue
                id := Trim(SubStr(line, 1, InStr(line, "=") - 1))
                val := HK_NormalizeRequirement(SubStr(line, InStr(line, "=") + 1))
                if id = "count"
                    continue
                if val = "" {
                    if HK_CustomReq.Has(id)
                        HK_CustomReq.Delete(id)
                } else {
                    HK_CustomReq[id] := val
                }
                importedReq++
            }
        }
        try {
            actSection := IniRead(fn, "HotkeyActivate")
        } catch {
            actSection := ""
        }
        importedAct := 0
        if actSection != "" {
            for line in StrSplit(actSection, "`n") {
                if !InStr(line, "=")
                    continue
                id := Trim(SubStr(line, 1, InStr(line, "=") - 1))
                val := Trim(SubStr(line, InStr(line, "=") + 1))
                if id = "count"
                    continue
                HK_CustomActivate[id] := val = "1"
                importedAct++
            }
        }
        HK_ReapplyAll()
        try HK_Save()
        DebugLog("Imported " imported " hotkeys from " fn)
        _HK_ResultPopup("Import", "Imported and saved " imported " hotkeys, " importedFns " function assignments, " importedReq " requirements, " importedAct " activate flags.`nClose and reopen Hotkey Settings to refresh.", "4CAF50")
    } catch as e {
        _HK_ResultPopup("Import Error", "Import failed: " e.Message, "E53935")
    }
}

_HK_ResultPopup(title, msg, color) {
    dlg := Gui("+AlwaysOnTop +ToolWindow", title)
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)
    dlg.AddText("c" color, msg)
    isFail := InStr(title, "error") || InStr(title, "failed") || color = "E53935" || color = "0XE53935"
    dlg.AddButton("xm y+10 w" S(80) " h" S(26) " Default", "OK").OnEvent("Click", (*) => dlg.Destroy())
    if isFail && !InStr(title, "backup") {
        dlg.AddButton("x+" S(8) " yp w" S(86) " h" S(26), "Backup").OnEvent("Click", (*) => BackupConfig())
    }
    dlg.Show("AutoSize")
}

_HK_Confirm(msg, title := "Confirm") {
    popup := Gui("+AlwaysOnTop +ToolWindow", title)
    popup.BackColor := "1E1F22"
    popup.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    popup.MarginX := S(14)
    popup.MarginY := S(14)
    popup.AddText("cFFD54F", msg)
    result := false
    popup.AddButton("xm y+10 w" S(80) " h" S(26) " BackgroundE53935 cFFFFFF", "Yes").OnEvent("Click", (*) => (result := true, popup.Destroy()))
    popup.AddButton("x+8 yp w" S(80) " h" S(26), "No").OnEvent("Click", (*) => popup.Destroy())
    popup.Show("AutoSize")
    GuiWaitForCloseSafe(popup)
    return result
}

; ============================================================
