; Feature - Timer / Worklog
; ============================================================

TimerSetButtons() {
    global _timerRunning, _tmrPlay, _tmrPause, _rBtn
    if !IsObject(_tmrPlay) || !IsObject(_tmrPause) || !IsObject(_rBtn)
        return
    if _timerRunning {
        _tmrPlay.Visible := false
        _tmrPause.Visible := true
        _rBtn.Text := "Lap"
        _rBtn.Opt("Background00897B cFFFFFF")
    } else {
        _tmrPlay.Visible := true
        _tmrPause.Visible := false
        _rBtn.Text := IconUse("■", "X")
        _rBtn.Opt("BackgroundC62828 cFFFFFF")
    }
}

TimerFormatElapsed(elapsed) {
    secs := Floor(elapsed / 1000)
    hrs := Floor(secs / 3600)
    mins := Floor(Mod(secs, 3600) / 60)
    secs := Mod(secs, 60)
    return Format("{:02i}:{:02i}:{:02i}", hrs, mins, secs)
}

TimerCurrentElapsed() {
    global _timerRunning, _timerStart, _timerElapsed
    return _timerRunning ? _timerElapsed + (A_TickCount - _timerStart) : _timerElapsed
}

TimerApplyLapNames(dlg) {
    global _timerLaps
    if !IsObject(dlg) || !dlg.HasProp("lapNameEdits")
        return
    for i, ed in dlg.lapNameEdits {
        if i <= _timerLaps.Length {
            name := Trim(ed.Value)
            _timerLaps[i].name := name != "" ? name : "Lap " i
        }
    }
}

TimerLapSaveText() {
    global _timerLaps
    txt := ""
    for i, lap in _timerLaps {
        name := lap.HasProp("name") && Trim(lap.name) != "" ? Trim(lap.name) : "Lap " i
        diffText := (i = 1) ? "--" : "+" TimerFormatElapsed(Max(lap.ms - _timerLaps[i - 1].ms, 0))
        txt .= "  " name "  " lap.time "  d " diffText "`n"
    }
    return txt
}

TimerGetLapSummary() {
    global _timerLaps
    summary := {
        count: _timerLaps.Length,
        totalMs: 0,
        averageMs: "",
        fastestIndex: 0,
        fastestMs: "",
        slowestIndex: 0,
        slowestMs: "",
        deltas: []
    }
    if !summary.count
        return summary

    summary.totalMs := _timerLaps[summary.count].ms
    totalDeltaMs := 0
    diffCount := 0

    for i, lap in _timerLaps {
        deltaMs := (i = 1) ? "" : Max(lap.ms - _timerLaps[i - 1].ms, 0)
        summary.deltas.Push(deltaMs)
        if (deltaMs = "")
            continue
        totalDeltaMs += deltaMs
        diffCount += 1
        if !summary.fastestIndex || deltaMs < summary.fastestMs {
            summary.fastestIndex := i
            summary.fastestMs := deltaMs
        }
        if !summary.slowestIndex || deltaMs > summary.slowestMs {
            summary.slowestIndex := i
            summary.slowestMs := deltaMs
        }
    }
    if diffCount > 0
        summary.averageMs := Round(totalDeltaMs / diffCount)
    return summary
}

TimerBuildExportText(cspName, timerVal, now, date, day) {
    global _timerLaps
    lapSummary := TimerGetLapSummary()
    lines := ""
    if cspName != ""
        lines .= "File: " cspName "`n"
    lines .= "Work Time: " timerVal "`n"
    if lapSummary.count {
        fastestText := "--"
        slowestText := "--"
        avgText := (lapSummary.averageMs = "") ? "--" : TimerFormatElapsed(lapSummary.averageMs)
        if lapSummary.fastestIndex {
            fastestLap := _timerLaps[lapSummary.fastestIndex]
            fastestName := fastestLap.HasProp("name") && Trim(fastestLap.name) != "" ? Trim(fastestLap.name) : "Lap " lapSummary.fastestIndex
            fastestText := fastestName " d +" TimerFormatElapsed(lapSummary.fastestMs)
        }
        if lapSummary.slowestIndex {
            slowestLap := _timerLaps[lapSummary.slowestIndex]
            slowestName := slowestLap.HasProp("name") && Trim(slowestLap.name) != "" ? Trim(slowestLap.name) : "Lap " lapSummary.slowestIndex
            slowestText := slowestName " d +" TimerFormatElapsed(lapSummary.slowestMs)
        }
        lines .= "Total Laps: " lapSummary.count "`n"
        lines .= "Fastest: " fastestText "`n"
        lines .= "Slowest: " slowestText "`n"
        lines .= "Average: " avgText "`n"
        lines .= "Laps:`n"
        lines .= TimerLapSaveText()
    }
    lines .= "------------------`n"
    lines .= "Day: " day "`n"
    lines .= "Save Time: " now "`n"
    lines .= "Date: " date "`n"
    return lines
}

TimerQuoteArg(value) {
    return '"' StrReplace(value, '"', '\"') '"'
}

TimerParseElapsed(text) {
    text := Trim(text)
    if !RegExMatch(text, "^(\d{1,2}):(\d{2}):(\d{2})$", &m)
        return ""
    return ((Integer(m[1]) * 3600) + (Integer(m[2]) * 60) + Integer(m[3])) * 1000
}

TimerTextSidecarPath(path) {
    return RegExReplace(path, "i)\.[^.\\/:]+$", ".txt")
}

TimerParseExportText(text) {
    laps := []
    totalMs := ""
    inLaps := false
    for rawLine in StrSplit(text, "`n", "`r") {
        line := Trim(rawLine)
        if line = ""
            continue
        if RegExMatch(line, "^Work Time:\s*(\d{1,2}:\d{2}:\d{2})", &m) {
            totalMs := TimerParseElapsed(m[1])
            continue
        }
        if RegExMatch(line, "^Laps:") {
            inLaps := true
            continue
        }
        if inLaps && RegExMatch(line, "^-+") {
            inLaps := false
            continue
        }
        if inLaps {
            if RegExMatch(line, "^(.*?)\s+(\d{1,2}:\d{2}:\d{2})(?:\s+d\s+(?:\+?\d{1,2}:\d{2}:\d{2}|--))?$", &lapMatch) {
                name := Trim(lapMatch[1])
                time := lapMatch[2]
                ms := TimerParseElapsed(time)
                if ms != ""
                    laps.Push({name: name != "" ? name : "Lap " (laps.Length + 1), time: TimerFormatElapsed(ms), ms: ms})
            }
        }
    }
    if totalMs = "" {
        if laps.Length
            totalMs := laps[laps.Length].ms
        else
            throw Error("No Work Time found in timer file.")
    }
    return {elapsed: totalMs, laps: laps}
}

TimerLoad(*) {
    TimerShowHistory()
}

TimerLoadPickFile(*) {
    fn := FileSelect("3", A_MyDocuments, "Load Timer Log", "Timer (*.txt; *.png)")
    if fn = ""
        return
    loadPath := fn
    if RegExMatch(fn, "i)\.png$") {
        sidecar := TimerTextSidecarPath(fn)
        if !FileExist(sidecar) {
            _HK_ResultPopup("Load Timer", "This PNG has no matching TXT sidecar to load.`n`nExpected:`n" sidecar "`n`nNew PNG saves will create this sidecar automatically.", "E53935")
            return
        }
        loadPath := sidecar
    }
    TimerLoadFromPath(loadPath)
}

TimerLoadFromPath(loadPath) {
    global _timerRunning, _timerStart, _timerElapsed, _timerFocusPaused, _timerLaps, _timerDisplay, _timerLastLapText
    try {
        parsed := TimerParseExportText(FileRead(loadPath, "UTF-8"))
        _timerRunning := false
        _timerFocusPaused := false
        _timerStart := 0
        _timerElapsed := parsed.elapsed
        _timerLaps := parsed.laps
        _timerLastLapText := _timerLaps.Length ? (_timerLaps[_timerLaps.Length].name ": " _timerLaps[_timerLaps.Length].time) : ""
        if IsObject(_timerDisplay)
            _timerDisplay.Value := TimerFormatElapsed(_timerElapsed)
        SetTimer(TimerTick, 0)
        TimerSetButtons()
        TimerUpdateLapIndicator()
        ShowNotify("Timer", "Loaded " TimerFormatElapsed(_timerElapsed) " (" _timerLaps.Length " lap(s))", "6D28D9")
        DebugLog("Timer loaded from " loadPath " (" TimerFormatElapsed(_timerElapsed) ", laps: " _timerLaps.Length ")")
    } catch as e {
        _HK_ResultPopup("Load Timer", "Failed to load timer: " e.Message, "E53935")
    }
}

TimerUpdateLapIndicator() {
    global IB_GUI, _timerLastLapText
    if IsObject(IB_GUI) && IB_GUI.HasProp("dragBottom") {
        if _timerLastLapText = "" {
            UpdateIBModeIndicator()
            return
        }
        IB_GUI.dragBottom.Text := _timerLastLapText
        IB_GUI.dragBottom.Opt("Background" (_timerLastLapText != "" ? "455A64" : "555555") " cDDDDDD")
    }
}

TimerStart(*) {
    global _timerRunning, _timerStart, _timerFocusPaused, _timerCountdownTarget, _timerCountdownStart, _timerPausedAt
    if _timerRunning
        return
    _timerRunning := true
    _timerFocusPaused := false
    _timerStart := A_TickCount
    if (_timerCountdownTarget > 0 && _timerPausedAt > 0) {
        _timerCountdownStart += A_TickCount - _timerPausedAt
        _timerPausedAt := 0
    }
    SetTimer(TimerTick, 1000)
    TimerTick()
    TimerSetButtons()
    DebugLog("Timer started")
}

TimerPause(*) {
    global _timerRunning, _timerStart, _timerElapsed, _timerFocusPaused, _timerPausedAt
    if !_timerRunning
        return
    SetTimer(TimerTick, 0)
    _timerPausedAt := A_TickCount
    _timerElapsed += A_TickCount - _timerStart
    _timerRunning := false
    _timerFocusPaused := false
    TimerSetButtons()
    DebugLog("Timer paused at " TimerFormatElapsed(_timerElapsed))
}

TimerToggle(*) {
    global _timerRunning
    if _timerRunning
        TimerPause()
    else
        TimerStart()
}

TimerStop(*) {
    if !TimerCurrentElapsed() {
        TimerClear()
        return
    }
    TimerPause()
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Stop Timer")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(12)
    dlg.AddText("xm w" S(260), "Stop timer and reset the time?")
    dlg.AddText("xm y+" S(6) " cAAAAAA w" S(260), "Current time: " TimerFormatElapsed(TimerCurrentElapsed()))
    dlg.AddButton("xm y+" S(12) " w" S(80) " h" S(26) " cFFFFFF Default", "Save").OnEvent("Click", (*) => (
        dlg.Destroy(),
        TimerShowSaveDialog(true)
    ))
    dlg.AddButton("x+" S(8) " yp w" S(90) " h" S(26), "Don't Save").OnEvent("Click", (*) => (
        dlg.Destroy(),
        TimerClear()
    ))
    dlg.AddButton("x+" S(8) " yp w" S(70) " h" S(26), "Cancel").OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("AutoSize")
}

TimerClear(*) {
    global _timerRunning, _timerStart, _timerElapsed, _timerDisplay, _timerFocusPaused, _timerLaps, _timerLastLapText
    global _timerCountdownTarget, _timerCountdownOrigTotal
    global _pomoActive, _pomoPhase, _pomoCycle, _timerPausedAt
    _timerRunning := false
    _timerFocusPaused := false
    _timerStart := 0
    _timerElapsed := 0
    _timerLaps := []
    _timerLastLapText := ""
    _timerCountdownTarget := 0
    _timerCountdownOrigTotal := 0
    _pomoActive := false
    _pomoPhase := ""
    _pomoCycle := 0
    _timerPausedAt := 0
    try _timerDisplay.Value := "00:00:00"
    SetTimer(TimerTick, 0)
    TimerSetButtons()
    TimerUpdateLapIndicator()
    DebugLog("Timer stopped/reset")
}



TimerLap(*) {
    global _timerLaps, _timerRunning, _timerLastLapText
    if !_timerRunning
        return
    elapsed := TimerCurrentElapsed()
    lapText := TimerFormatElapsed(elapsed)
    lapNum := _timerLaps.Length + 1
    lapName := "Lap " lapNum
    _timerLaps.Push({name:lapName, time:lapText, ms:elapsed})
    _timerLastLapText := lapName ": " lapText
    TimerUpdateLapIndicator()
    ShowNotify("Timer Lap " _timerLaps.Length, lapText, "00897B")
    DebugLog("Timer lap " _timerLaps.Length ": " lapText " (total laps: " _timerLaps.Length ")")
}

TimerStopOrLap(*) {
    global _timerRunning
    if _timerRunning
        TimerLap()
    else
        TimerStop()
}

TimerTick(*) {
    global _timerRunning, _timerStart, _timerElapsed, _timerDisplay
    global _timerCountdownTarget, _timerCountdownStart, _timerCountdownOrigTotal
    if !_timerRunning
        return
    if _timerCountdownTarget > 0 {
        elapsed := A_TickCount - _timerCountdownStart
        remaining := _timerCountdownTarget - elapsed
        if remaining <= 0 {
            try _timerDisplay.Value := "00:00:00"
            TimerCountdownAlarm()
            return
        }
        try _timerDisplay.Value := TimerFormatElapsed(remaining)
    } else {
        try _timerDisplay.Value := TimerFormatElapsed(TimerCurrentElapsed())
    }
}

TimerCountdownAlarm() {
    global _timerCountdownOrigTotal, _pomoActive
    total := _timerCountdownOrigTotal
    if _pomoActive {
        TimerPomodoroNext(total)
        return
    }
    TimerClear()
    SetTimer(TimerCountdownAlarmDlg.Bind(total), -10)
}

TimerCountdownAlarmDlg(total := 0, *) {
    CoordMode("Mouse", "Screen")
    MouseGetPos(&mx, &my)
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Countdown Complete")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(12)
    dlg.AddText("xm cE53935 w" S(200), "Time's up!")
    dlg.AddText("xm cAAAAAA", "Duration: " TimerFormatElapsed(total))
    okBtn := dlg.AddButton("xm y+" S(12) " w" S(80) " h" S(26) " cFFFFFF Default", "OK")
    okBtn.OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("Hide AutoSize")
    dlg.GetPos(,, &gw, &gh)
    x := mx - gw // 2
    y := my - gh // 2
    m := _MonitorFromCursor()
    if x < m["l"]
        x := m["l"]
    if y < m["t"]
        y := m["t"]
    if x + gw > m["r"]
        x := m["r"] - gw
    if y + gh > m["b"]
        y := m["b"] - gh
    dlg.Show("NoActivate x" x " y" y)
    GuiWaitForCloseSafe(dlg)
    DebugLog("Timer countdown alarm (" TimerFormatElapsed(total) ")")
}

TimerCountdownShow() {
    global _pomoActive, _pomoPhase, _pomoCycle
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Countdown Timer")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(12)

    dlg.SetFont("s" S(9) " Bold cFFD54F", "Segoe UI")
    dlg.AddText("xm", "Countdown")
    dlg.SetFont("s" S(9) " Norm cFFFFFF", "Segoe UI")
    dlg.AddText("xm y+" S(8), "Hours:")
    edHr := dlg.AddEdit("x+4 w" S(40) " cFFFFFF Background333333", "0")
    dlg.AddText("x+8", "Minutes:")
    edMin := dlg.AddEdit("x+4 w" S(40) " cFFFFFF Background333333", "5")
    dlg.AddText("x+8", "Seconds:")
    edSec := dlg.AddEdit("x+4 w" S(40) " cFFFFFF Background333333", "0")
    startBtn := dlg.AddButton("xm y+" S(10) " w" S(80) " h" S(26) " cFFFFFF Default", "Start")
    startBtn.OnEvent("Click", (*) => TimerCountdownStartFromDlg(dlg, edHr, edMin, edSec))
    dlg.AddButton("x+5 yp w" S(60) " h" S(26), "Cancel").OnEvent("Click", (*) => dlg.Destroy())

    dlg.SetFont("s" S(9) " Bold cFFD54F", "Segoe UI")
    dlg.AddText("xm y+" S(16), "Pomodoro")
    dlg.SetFont("s" S(9) " Norm cFFFFFF", "Segoe UI")
    dlg.AddText("xm y+" S(8), "Work:")
    edPW := dlg.AddEdit("x+4 w" S(36) " cFFFFFF Background333333", "25")
    dlg.AddText("x+8", "Break:")
    edPB := dlg.AddEdit("x+4 w" S(36) " cFFFFFF Background333333", "5")
    dlg.AddText("x+8", "Long break every")
    edPN := dlg.AddEdit("x+4 w" S(28) " cFFFFFF Background333333", "4")
    dlg.AddText("x+4", "cycles, for")
    edPL := dlg.AddEdit("x+4 w" S(36) " cFFFFFF Background333333", "15")
    dlg.AddText("x+4", "min")
    pomoBtn := dlg.AddButton("xm y+" S(18) " w" S(110) " h" S(26), "Start Pomodoro")
    pomoBtn.OnEvent("Click", (*) => TimerPomodoroStartFromDlg(dlg, edPW, edPB, edPN, edPL))
    if _pomoActive {
        pomoBtn.Text := "Restart Pomodoro"
        phaseTxt := (_pomoPhase = "work") ? "Running: work session " _pomoCycle : "Running: break (after work " _pomoCycle ")"
        dlg.AddText("x+" S(8) " yp+" S(6) " cAAAAAA", phaseTxt)
    }

    dlg.SetFont("s" S(8) " Norm cAAAAAA", "Segoe UI")
    dlg.AddText("xm y+" S(16) " w" S(330) " cAAAAAA",
        "How to use:`n"
        . "- Countdown: runs once. An alarm popup appears at the cursor when time ends, then the timer resets.`n"
        . "`n"
        . "- Pomodoro: Work and Break alternate until stopped. Each finished work session records a lap"
        . " (Pomo W1, Pomo W2 ...). After every N cycles the break becomes a LONG break.`n"
        . "`n"
        . "- Pause / Resume works in both modes, and the timer auto-pauses when CSP loses focus."
        . " Stop or Reset cancels the Pomodoro cycle.")

    dlg.Show("AutoSize")
    startBtn.Focus()
}

TimerCountdownStartFromDlg(dlg, edHr, edMin, edSec) {
    hrs := 0
    mins := 0
    secs := 0
    try hrs := Max(0, Integer(Trim(edHr.Value)))
    catch
        hrs := 0
    try mins := Max(0, Min(59, Integer(Trim(edMin.Value))))
    catch
        mins := 0
    try secs := Max(0, Min(59, Integer(Trim(edSec.Value))))
    catch
        secs := 0
    total := (hrs * 3600 + mins * 60 + secs) * 1000
    if total <= 0 {
        ShowNotify("Countdown", "Enter a duration greater than 0", "E53935")
        return
    }
    dlg.Destroy()
    TimerCountdownStart(total)
}

TimerCountdownStart(durationMs, silent := false) {
    global _timerRunning, _timerStart, _timerElapsed
    global _timerCountdownTarget, _timerCountdownStart, _timerCountdownOrigTotal
    global _pomoActive, _pomoPhase, _pomoCycle
    if _timerRunning
        TimerPause()
    if !silent {
        _pomoActive := false
        _pomoPhase := ""
        _pomoCycle := 0
    }
    _timerCountdownTarget := durationMs
    _timerCountdownStart := A_TickCount
    _timerCountdownOrigTotal := durationMs
    _timerPausedAt := 0
    _timerElapsed := 0
    _timerRunning := true
    _timerStart := A_TickCount
    SetTimer(TimerTick, 1000)
    TimerTick()
    TimerSetButtons()
    if !silent {
        ShowNotify("Countdown", "Countdown started: " TimerFormatElapsed(durationMs), "00897B")
        DebugLog("Timer countdown started: " TimerFormatElapsed(durationMs))
    }
}

; --- Pomodoro ---

_PomoMinToMs(ed, defVal) {
    v := defVal
    try v := Integer(Trim(ed.Value))
    catch
        v := defVal
    return Max(0, Min(180, v)) * 60000
}

_PomoIntVal(ed, defVal, lo, hi) {
    v := defVal
    try v := Integer(Trim(ed.Value))
    catch
        v := defVal
    return Max(lo, Min(hi, v))
}

TimerPomodoroStartFromDlg(dlg, edW, edB, edN, edL) {
    workMs := _PomoMinToMs(edW, 25)
    breakMs := _PomoMinToMs(edB, 5)
    longMs := _PomoMinToMs(edL, 15)
    everyN := _PomoIntVal(edN, 4, 1, 10)
    if (workMs <= 0 || breakMs <= 0 || longMs <= 0) {
        ShowNotify("Pomodoro", "Work, break and long break must be over 0 min", "E53935")
        return
    }
    dlg.Destroy()
    TimerPomodoroStart(workMs, breakMs, everyN, longMs)
}

TimerPomodoroStart(workMs, breakMs, everyN, longMs) {
    global _pomoActive, _pomoPhase, _pomoCycle, _pomoWorkMs, _pomoBreakMs, _pomoLongMs, _pomoEveryN
    _pomoWorkMs := workMs
    _pomoBreakMs := breakMs
    _pomoLongMs := longMs
    _pomoEveryN := everyN
    _pomoActive := true
    _pomoPhase := "work"
    _pomoCycle := 1
    TimerCountdownStart(workMs, true)
    ShowNotify("Pomodoro", "Work session 1 started (" workMs // 60000 " min)", "E53935")
    DebugLog("Pomodoro started: work " workMs // 60000 "m, break " breakMs // 60000 "m, long every " everyN ", long " longMs // 60000 "m")
}

TimerPomodoroNext(completedMs) {
    global _pomoActive, _pomoPhase, _pomoCycle, _pomoWorkMs, _pomoBreakMs, _pomoLongMs, _pomoEveryN
    global _timerLaps, _timerLastLapText
    if !_pomoActive {
        TimerClear()
        return
    }
    if (_pomoPhase = "work") {
        lapName := "Pomo W" _pomoCycle
        lapText := TimerFormatElapsed(completedMs)
        _timerLaps.Push({name: lapName, time: lapText, ms: completedMs})
        _timerLastLapText := lapName ": " lapText
        TimerUpdateLapIndicator()
        isLong := (Mod(_pomoCycle, _pomoEveryN) = 0)
        nextMs := isLong ? _pomoLongMs : _pomoBreakMs
        _pomoPhase := "break"
        TimerCountdownStart(nextMs, true)
        ShowNotify("Pomodoro", "Work " _pomoCycle " done - " (isLong ? "LONG break" : "break") " " nextMs // 60000 " min", "00897B")
        DebugLog("Pomodoro: work session " _pomoCycle " complete (" lapText "), " (isLong ? "long" : "short") " break started")
    } else {
        _pomoCycle += 1
        _pomoPhase := "work"
        TimerCountdownStart(_pomoWorkMs, true)
        ShowNotify("Pomodoro", "Work session " _pomoCycle " started (" _pomoWorkMs // 60000 " min)", "E53935")
        DebugLog("Pomodoro: break complete, work session " _pomoCycle " started")
    }
}

CheckCSPFocus(*) {
    global _timerRunning, _timerFocusPaused, _timerStart, _timerElapsed, _timerCountdownTarget, _timerCountdownStart, _timerPausedAt
    static ourPID := DllCall("GetCurrentProcessId", "uint")
    try {
        activeHwnd := WinExist("A")
        activeExe := WinGetProcessName(activeHwnd)
        isCSP := activeExe = "CLIPStudioPaint.exe"
        if !isCSP {
            DllCall("GetWindowThreadProcessId", "ptr", activeHwnd, "uint*", &pid := 0)
            if pid = ourPID
                isCSP := true
        }
    } catch {
        isCSP := false
    }
    if !isCSP && _timerRunning && !_timerFocusPaused {
        _timerFocusPaused := true
        _timerRunning := false
        SetTimer(TimerTick, 0)
        _timerPausedAt := A_TickCount
        _timerElapsed += A_TickCount - _timerStart
        TimerSetButtons()
        DebugLog("Timer auto-paused at " TimerFormatElapsed(_timerElapsed) " (CSP focus lost)")
    } else if isCSP && _timerFocusPaused {
        _timerFocusPaused := false
        _timerRunning := true
        _timerStart := A_TickCount
        if (_timerCountdownTarget > 0 && _timerPausedAt > 0) {
            _timerCountdownStart += A_TickCount - _timerPausedAt
            _timerPausedAt := 0
        }
        SetTimer(TimerTick, 1000)
        TimerTick()
        TimerSetButtons()
        DebugLog("Timer auto-resumed (CSP focus regained)")
    }
}

TimerSave(*) {
    TimerShowSaveDialog(false)
}

TimerShowSaveDialog(resetAfterSave := false) {
    global _timerDisplay, IB_GUI, _timerAskFileName, _timerLaps
    if !TimerCurrentElapsed()
        return
    static sDlg := 0
    if IsObject(sDlg) {
        try if sDlg.Hwnd {
            sDlg.Show()
            return
        }
    }
    sDlg := Gui("+AlwaysOnTop +ToolWindow", "Save Timer")
    sDlg.BackColor := "1E1F22"
    sDlg.resetAfterSave := resetAfterSave
    sDlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    sDlg.MarginX := S(16)
    sDlg.MarginY := S(16)

    sDlg.SetFont("s" S(28), "Segoe UI")
    sDlg.AddText("xm Center w" S(240), IconUse("⏱", "T"))
    sDlg.SetFont("s" S(10) " Bold", "Segoe UI")
    sDlg.AddText("xm y+" S(4) " Center cAAAAAA w" S(240), TimerFormatElapsed(TimerCurrentElapsed()))
    sDlg.SetFont("s" S(9), "Segoe UI")
    sDlg.AddText("xm y+" S(8) " Center c888888 w" S(240), "Save timer log as...")
    sDlg.lapNameEdits := []
    if _timerLaps.Length {
        sDlg.SetFont("s" S(8) " cDDDDDD", "Segoe UI")
        sDlg.AddText("xm y+" S(8), "Lap names:")
        lapBaseX := S(16)
        lapBaseY := 0
        for i, lap in _timerLaps {
            col := Floor((i - 1) / 5)
            row := Mod(i - 1, 5)
            x := lapBaseX + (col * S(128))
            if i = 1 {
                probe := sDlg.AddText("xm y+4 w1 h1", "")
                probe.GetPos(, &lapBaseY)
                probe.Visible := false
            }
            y := lapBaseY + (row * S(24))
            name := lap.HasProp("name") && Trim(lap.name) != "" ? lap.name : "Lap " i
            ed := sDlg.AddEdit("x" x " y" y " w" S(74) " h" S(21) " c000000 BackgroundFFFFFF", name)
            sDlg.AddText("x+4 yp+2 w" S(42) " cAAAAAA", lap.time)
            sDlg.lapNameEdits.Push(ed)
        }
        lastRows := Min(_timerLaps.Length, 5)
        sDlg.AddText("xm y" (lapBaseY + (lastRows * S(24)) + S(2)) " w1 h1", "")
    } else {
        sDlg.SetFont("s" S(8), "Consolas")
        sDlg.AddText("xm y+" S(8) " w" S(240) " h" S(28) " cDDDDDD Background2D2D32 +0x200", "No laps recorded.")
    }

    sDlg.SetFont("s" S(9), "Segoe UI")
    sDlg.AddButton("xm y+" S(12) " w" S(72) " h" S(28) " Background1565C0 cFFFFFF", "PNG").OnEvent("Click", TimerSavePNG.Bind(sDlg))
    sDlg.AddButton("x+" S(6) " yp w" S(72) " h" S(28) " Background2E7D32 cFFFFFF", "TXT").OnEvent("Click", TimerSaveTXT.Bind(sDlg))
    sDlg.AddButton("x+" S(6) " yp w" S(72) " h" S(28), "Cancel").OnEvent("Click", (*) => sDlg.Destroy())
    sDlg.SetFont("s" S(8), "Segoe UI")
    sDlg.cbAsk := sDlg.AddCheckbox("xm y+" S(8) " Background1E1F22 cCCCCCC", "Input CSP file name")
    sDlg.cbAsk.Value := _timerAskFileName
    sDlg.cbAsk.OnEvent("Click", (*) => _timerAskFileName := sDlg.cbAsk.Value)
    sDlg.Show("AutoSize")
}

_TimerAskNameFolder() {
    global _timerNameResult
    _timerNameResult := ""
    timestamp := FormatTime(, "yyyy-MM-dd_HH-mm-ss")
    
    nameGui := Gui("+AlwaysOnTop +ToolWindow", "Timer File Name")
    nameGui.BackColor := "1E1F22"
    nameGui.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    nameGui.MarginX := S(16)
    nameGui.MarginY := S(16)
    
    nameGui.SetFont("s" S(28), "Segoe UI")
    nameGui.AddText("xm Center w" S(240), IconUse("⏱", "T"))
    nameGui.SetFont("s" S(10), "Segoe UI")
    nameGui.AddText("xm y+" S(4) " Center cAAAAAA w" S(240), "Enter a name for the timer files:")
    nameGui.SetFont("s" S(9), "Segoe UI")
    ne := nameGui.AddEdit("xm y+" S(8) " w" S(240) " h" S(24) " Background2A2A2A cFFFFFF -E0x200", timestamp)
    ne.SetFont("s" S(10), "Segoe UI")
    nameGui.AddButton("xm y+" S(10) " w" S(115) " h" S(30) " Background2E7D32 cFFFFFF Default", "OK").OnEvent("Click", (*) => (_timerNameResult := ne.Value, nameGui.Destroy()))
    nameGui.AddButton("x+" S(10) " yp w" S(115) " h" S(30), "Cancel").OnEvent("Click", (*) => nameGui.Destroy())
    nameGui.Show("w" S(272))
    nameGui.OnEvent("Close", (*) => nameGui.Destroy())
    GuiWaitForCloseSafe(nameGui)
    
    if _timerNameResult = ""
        return ""
    folder := FileSelect("D", A_MyDocuments, "Select folder to save timer files")
    if folder = ""
        return ""
    return folder "\" _timerNameResult
}

CaptureTimerToPNG(filepath, timerVal, now, date, day, cspName := "", laps := 0) {
    global _timerLastPngRenderer
    _timerLastPngRenderer := ""
    exportText := TimerBuildExportText(cspName, timerVal, now, date, day)
    renderScript := A_ScriptDir "\src\tools\render_timer_export_png.ps1"
    tempText := A_Temp "\csp_timer_export_" A_TickCount ".txt"
    errText := A_Temp "\csp_timer_export_" A_TickCount ".err.txt"
    try {
        if FileExist(tempText)
            FileDelete(tempText)
        if FileExist(errText)
            FileDelete(errText)
        FileAppend(exportText, tempText, "UTF-8")
        if FileExist(renderScript) {
            if FileExist(filepath)
                FileDelete(filepath)
            cmd := "powershell -NoProfile -ExecutionPolicy Bypass -File " TimerQuoteArg(renderScript) " " TimerQuoteArg(tempText) " " TimerQuoteArg(filepath) " 2> " TimerQuoteArg(errText)
            exitCode := RunWait(A_ComSpec " /c " cmd, , "Hide")
            if (exitCode = 0 && FileExist(filepath)) {
                _timerLastPngRenderer := "PowerShell"
                DebugLog("Timer PNG saved via PowerShell renderer")
                return true
            }
            err := FileExist(errText) ? Trim(FileRead(errText, "UTF-8")) : ""
            DebugLog("Timer PNG PowerShell renderer failed (exit code: " exitCode ")" (err != "" ? ": " err : ""))
            return false
        }
        DebugLog("Timer PNG PowerShell renderer unavailable")
        return false
    } catch as e {
        DebugLog("Timer PNG save exception in PowerShell renderer: " e.Message)
        return false
    } finally {
        try FileDelete(tempText)
        try FileDelete(errText)
    }
}

TimerSavePNG(dlg, *) {
    global IB_GUI, _timerAskFileName, _timerNameResult, _timerLaps, _timerLastPngRenderer
    TimerApplyLapNames(dlg)
    timestamp := FormatTime(, "yyyy-MM-dd_HH-mm-ss")
    docsDir := A_MyDocuments
    timerVal := TimerFormatElapsed(TimerCurrentElapsed())
    now := FormatTime(, "HH:mm:ss")
    date := FormatTime(, "yyyy-MM-dd")
    day := FormatTime(, "dddd")
    if _timerAskFileName {
        basePath := _TimerAskNameFolder()
        if basePath = ""
            return
        filepath := basePath ".png"
        cspName := _timerNameResult
    } else {
        filepath := FileSelect("S", docsDir "\Timer_" timestamp ".png", "Save PNG", "PNG (*.png)")
        if filepath = ""
            return
        cspName := ""
    }
    if CaptureTimerToPNG(filepath, timerVal, now, date, day, cspName, _timerLaps) {
        try {
            sidecar := TimerTextSidecarPath(filepath)
            if FileExist(sidecar)
                FileDelete(sidecar)
            FileAppend(TimerBuildExportText(cspName, timerVal, now, date, day), sidecar, "UTF-8")
        } catch as e {
            DebugLog("Timer PNG sidecar TXT failed: " e.Message)
        }
        try TimerHistoryRecord(TimerBuildExportText(cspName, timerVal, now, date, day))
        resetAfterSave := dlg.HasProp("resetAfterSave") && dlg.resetAfterSave
        dlg.Destroy()
        lapInfo := _timerLaps.Length ? " with " _timerLaps.Length " lap(s)" : ""
        rendererLabel := _timerLastPngRenderer != "" ? " via " _timerLastPngRenderer : ""
        ShowNotify("Timer", "PNG saved" lapInfo rendererLabel, "1565C0")
        DebugLog("Timer saved as PNG (" timerVal ", laps: " _timerLaps.Length ", renderer: " (_timerLastPngRenderer != "" ? _timerLastPngRenderer : "unknown") ")")
        if resetAfterSave
            TimerClear()
    } else {
        _HK_ResultPopup("Error", "Failed to save PNG.", "E53935")
    }
}

TimerSaveTXT(dlg, *) {
    global _timerAskFileName, _timerNameResult, _timerLaps
    TimerApplyLapNames(dlg)
    timestamp := FormatTime(, "yyyy-MM-dd_HH-mm-ss")
    docsDir := A_MyDocuments
    if _timerAskFileName {
        basePath := _TimerAskNameFolder()
        if basePath = ""
            return
        filepath := basePath ".txt"
        cspName := _timerNameResult
    } else {
        filepath := FileSelect("S", docsDir "\Timer_" timestamp ".txt", "Save TXT", "Text (*.txt)")
        if filepath = ""
            return
        cspName := ""
    }
    try {
        t := TimerFormatElapsed(TimerCurrentElapsed())
        now := FormatTime(, "HH:mm:ss")
        date := FormatTime(, "yyyy-MM-dd")
        day := FormatTime(, "dddd")
        lines := TimerBuildExportText(cspName, t, now, date, day)
        try FileDelete(filepath)
        FileAppend(lines, filepath, "UTF-8")
        try TimerHistoryRecord(lines)
        resetAfterSave := dlg.HasProp("resetAfterSave") && dlg.resetAfterSave
        dlg.Destroy()
        lapInfo := _timerLaps.Length ? " with " _timerLaps.Length " lap(s)" : ""
        ShowNotify("Timer", "TXT saved" lapInfo, "2E7D32")
        DebugLog("Timer saved as TXT (" t ", laps: " _timerLaps.Length ")")
        if resetAfterSave
            TimerClear()
    } catch as e {
        _HK_ResultPopup("Error", "Failed to save TXT: " e.Message, "E53935")
    }
}


; --- Pomodoro / pause-resume state (initialized at load) ---
global _pomoActive := false
global _pomoPhase := ""
global _pomoCycle := 0
global _pomoWorkMs := 1500000
global _pomoBreakMs := 300000
global _pomoLongMs := 900000
global _pomoEveryN := 4
global _timerPausedAt := 0
