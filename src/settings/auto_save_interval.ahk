; AUTO SAVE INTERVAL CONFIG
; ============================================================

SetAutoSaveInterval(*) {
    global AutoSaveInterval
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Auto Save Interval")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)
    dlg.AddText("xm", "Interval in seconds (default 60):")
    ed := dlg.AddEdit("xm y+" S(6) " w" S(100) " c000000 BackgroundFFFFFF", AutoSaveInterval)
    dlg.AddButton("xm y+" S(8) " w" S(80) " h" S(26), "OK").OnEvent("Click", AutoSaveIntervalOK.Bind(ed, dlg))
    dlg.AddButton("x+" S(6) " yp w" S(80) " h" S(26), "Cancel").OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("AutoSize")
}

AutoSaveIntervalOK(ed, dlg, *) {
    global AutoSaveInterval
    n := ToolkitSafeInt(ed.Value, 60)
    n := n < 10 ? 10 : n > 3600 ? 3600 : n
    AutoSaveInterval := n
    SetTimer(DoAutoSave, n * 1000)
    try IniWrite(n, SETTINGS_FILE, "Settings", "AutoSaveInterval")
    try SettingsSyncIniWatcher()
    DebugLog("Auto save interval set to " n "s")
    dlg.Destroy()
}

; ============================================================
