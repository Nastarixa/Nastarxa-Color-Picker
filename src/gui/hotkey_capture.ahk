; GUI - Hotkey capture dialog
; ============================================================

global _HK_CaptureDlg := 0

HK_StartCaptureInput(cDlg) {
    ih := InputHook("B", "{Esc}")
    ih.KeyOpt("{All}", "E")
    ih.OnEnd := HK_IH_End
    cDlg.ih := ih
    ih.Start()
}

HK_NormalizeCapturedKey(key) {
    static keyMap := ""
    if !IsObject(keyMap) {
        keyMap := Map()
        keyMap["Control"] := "Ctrl"
        keyMap["LControl"] := "Ctrl"
        keyMap["RControl"] := "Ctrl"
        keyMap["Escape"] := "Esc"
        keyMap["Return"] := "Enter"
        keyMap["Prior"] := "PgUp"
        keyMap["Next"] := "PgDn"
        keyMap["LShift"] := "Shift"
        keyMap["RShift"] := "Shift"
        keyMap["LAlt"] := "Alt"
        keyMap["RAlt"] := "Alt"
        keyMap["LWin"] := "Win"
        keyMap["RWin"] := "Win"
    }
    if keyMap.Has(key)
        return keyMap[key]
    if StrLen(key) = 1
        return StrLower(key)
    return key
}

HK_ModTokenFromKey(key) {
    static modMap := ""
    if !IsObject(modMap) {
        modMap := Map()
        modMap["Control"] := "^"
        modMap["Ctrl"] := "^"
        modMap["LControl"] := "^"
        modMap["RControl"] := "^"
        modMap["Shift"] := "+"
        modMap["LShift"] := "+"
        modMap["RShift"] := "+"
        modMap["Alt"] := "!"
        modMap["LAlt"] := "!"
        modMap["RAlt"] := "!"
        modMap["LWin"] := "#"
        modMap["RWin"] := "#"
        modMap["Win"] := "#"
    }
    return modMap.Has(key) ? modMap[key] : ""
}

HK_BuildModifierPrefix(cDlg) {
    prefix := ""
    if cDlg.ctrlHeld
        prefix .= "^"
    if cDlg.shiftHeld
        prefix .= "+"
    if cDlg.altHeld
        prefix .= "!"
    if cDlg.winHeld
        prefix .= "#"
    return prefix
}

HK_CaptureKey(parentGui, ed, display, capBtn) {
    global _HK_CaptureDlg
    if IsObject(_HK_CaptureDlg)
        return
    _HK_CaptureDlg := 0

    capBtn.Enabled := false
    capBtn.Text := "Recording..."
    ed.Opt("+ReadOnly")

    cDlg := Gui("+AlwaysOnTop +ToolWindow", "Capture Hotkey")
    cDlg.BackColor := "1E1F22"
    cDlg.SetFont("s9 cFFFFFF", "Segoe UI")
    cDlg.MarginX := 20
    cDlg.MarginY := 20

    cDlg.AddText("xm Center w227 cAAAAAA", "Press a key combination:")
    cDlg.SetFont("s14 Bold", "Segoe UI")
    cDlg.capDisplay := cDlg.AddText("xm y+10 w227 h36 +0x200 Center cFFFFFF Background2D2D32", "...")
    cDlg.SetFont("s9 norm", "Segoe UI")

    ; Modifier chain display (shows held modifiers in real-time)
    cDlg.chainDisplay := cDlg.AddText("xm y+4 w227 h20 +0x200 Center c888888 Background1E1F22", "")
    cDlg.SetFont("s9 norm", "Segoe UI")

    cDlg.chord := ""
    cDlg.isRecording := false
    cDlg.ctrlHeld := false
    cDlg.shiftHeld := false
    cDlg.altHeld := false
    cDlg.winHeld := false
    cDlg.ih := 0
    _HK_CaptureDlg := cDlg

    ; Timer to poll modifier state for chain recording
    cDlg_ChainTimer(*) {
        if !IsObject(cDlg) || !cDlg.isRecording
            return
        cDlg.chainDisplay.Text := "Recording... press shortcut"
    }
    cDlg.chainTimerFn := cDlg_ChainTimer
    cDlg.closed := false

    cDlg_Cleanup(*) {
        global _HK_CaptureDlg
        if cDlg.closed
            return
        cDlg.closed := true
        cDlg.isRecording := false
        _HK_CaptureDlg := 0
        if cDlg.ih {
            cDlg.ih.Stop()
            cDlg.ih := 0
        }
        try SetTimer(cDlg.chainTimerFn, 0)
        capBtn.Enabled := true
        capBtn.Text := "Record"
        ed.Opt("-ReadOnly")
        try ed.Focus()
        try cDlg.Destroy()
    }

    cDlg_Apply(*) {
        if cDlg.chord != "" {
            ed.Value := cDlg.chord
            display.Text := cDlg.chord
        }
        cDlg_Cleanup()
    }

    cDlg_StartIH(*) {
        HK_StartCaptureInput(cDlg)
    }

    cDlg_ToggleRecord(*) {
        if cDlg.isRecording {
            ; Stop recording and capture current state
            cDlg.isRecording := false
            if cDlg.ih {
                cDlg.ih.Stop()
                cDlg.ih := 0
            }
            try SetTimer(cDlg.chainTimerFn, 0)
            cDlg.recBtn.Text := "Record"
        } else {
            cDlg.chord := ""
            cDlg.capDisplay.Text := "..."
            cDlg.chainDisplay.Text := "Recording... press shortcut"
            cDlg.ctrlHeld := false
            cDlg.shiftHeld := false
            cDlg.altHeld := false
            cDlg.winHeld := false
            cDlg.applyBtn.Enabled := false
            cDlg.isRecording := true
            cDlg.recBtn.Text := "Stop"
            SetTimer(cDlg.chainTimerFn, 0)
            cDlg_StartIH()
            SetTimer(cDlg.chainTimerFn, 80)
        }
    }

    cDlg.recBtn := cDlg.AddButton("xm y+4 w70 h28", "Record")
    cDlg.recBtn.Enabled := true
    cDlg.recBtn.OnEvent("Click", cDlg_ToggleRecord)

    cDlg.applyBtn := cDlg.AddButton("x+8 yp w70 h28 cFFFFFF", "OK")
    cDlg.applyBtn.Enabled := false
    cDlg.applyBtn.OnEvent("Click", cDlg_Apply)

    cDlg.AddButton("x+8 yp w70 h28", "Cancel").OnEvent("Click", cDlg_Cleanup)
    cDlg.OnEvent("Close", cDlg_Cleanup)

    cDlg.Show("w265")
    cDlg.recBtn.Text := "Record"
}

HK_IH_End(ih) {
    global _HK_CaptureDlg
    if !IsObject(_HK_CaptureDlg) || !_HK_CaptureDlg.isRecording
        return
    if ih.EndReason = "EndKey" && ih.EndKey = "Esc" {
        _HK_CaptureDlg.isRecording := false
        _HK_CaptureDlg.recBtn.Text := "Record"
        _HK_CaptureDlg.recBtn.Enabled := true
        if _HK_CaptureDlg.HasProp("chainTimerFn")
            SetTimer(_HK_CaptureDlg.chainTimerFn, 0)
        return
    }
    if ih.EndReason != "EndKey"
        return
    key := ih.EndKey
    if key = ""
        return
    modToken := HK_ModTokenFromKey(key)
    if modToken != "" {
        switch modToken {
            case "^":
                _HK_CaptureDlg.ctrlHeld := true
            case "+":
                _HK_CaptureDlg.shiftHeld := true
            case "!":
                _HK_CaptureDlg.altHeld := true
            case "#":
                _HK_CaptureDlg.winHeld := true
        }
        _HK_CaptureDlg.chord := HK_BuildModifierPrefix(_HK_CaptureDlg)
        _HK_CaptureDlg.capDisplay.Text := _HK_CaptureDlg.chord
        _HK_CaptureDlg.applyBtn.Enabled := (_HK_CaptureDlg.chord != "")
        _HK_CaptureDlg.chainDisplay.Text := "Modifier held; press final key"
        HK_StartCaptureInput(_HK_CaptureDlg)
        return
    }
    prefix := HK_BuildModifierPrefix(_HK_CaptureDlg)
    key := HK_NormalizeCapturedKey(key)
    _HK_CaptureDlg.chord := prefix key
    _HK_CaptureDlg.capDisplay.Text := _HK_CaptureDlg.chord
    _HK_CaptureDlg.applyBtn.Enabled := true
    _HK_CaptureDlg.isRecording := false
    _HK_CaptureDlg.recBtn.Text := "Record"
    _HK_CaptureDlg.recBtn.Enabled := true
    if _HK_CaptureDlg.HasProp("chainTimerFn")
        SetTimer(_HK_CaptureDlg.chainTimerFn, 0)
    try _HK_CaptureDlg.ih.Stop()
    _HK_CaptureDlg.ih := 0
}


