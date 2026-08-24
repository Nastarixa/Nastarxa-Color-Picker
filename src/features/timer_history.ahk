; Feature - Timer history
; ============================================================
; Every saved timer session is copied into Documents\draw_time so a browsable
; history builds up over time. TimerLoad now opens the history popup instead
; of a raw file picker; "Pick Other File..." keeps the old picker available.

TimerHistoryDir() {
    return A_MyDocuments "\draw_time"
}

TimerHistoryEnsureDir() {
    dir := TimerHistoryDir()
    try {
        if !DirExist(dir)
            DirCreate(dir)
    }
    return dir
}

; Records a completed save into the history folder. Returns the written path.
TimerHistoryRecord(text) {
    if text = ""
        return ""
    dir := TimerHistoryEnsureDir()
    base := "draw_" FormatTime(, "yyyy-MM-dd_HH-mm-ss")
    fn := dir "\" base ".txt"
    n := 2
    while FileExist(fn) {
        fn := dir "\" base "_" n ".txt"
        n++
    }
    try {
        FileAppend(text, fn, "UTF-8")
        DebugLog("Timer history recorded: " fn)
        return fn
    } catch as e {
        DebugLog("Timer history record failed: " e.Message)
        return ""
    }
}

TimerShowHistory(*) {
    dir := TimerHistoryEnsureDir()
    static hDlg := 0
    if IsObject(hDlg) {
        try if hDlg.Hwnd {
            hDlg.Show()
            return
        }
    }
    hDlg := Gui("+AlwaysOnTop +ToolWindow", "Timer History")
    hDlg.BackColor := "1E1F22"
    hDlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    hDlg.MarginX := S(12)
    hDlg.MarginY := S(12)

    hDlg.SetFont("s" S(28), "Segoe UI")
    hDlg.AddText("xm Center w" S(560), IconUse("⏱", "T"))
    hDlg.SetFont("s" S(10) " Bold", "Segoe UI")
    hDlg.AddText("xm y+" S(2) " Center cDDDDDD w" S(560), "Timer History")
    hDlg.SetFont("s" S(8), "Segoe UI")
    hDlg.AddText("xm y+" S(2) " Center c888888 w" S(560), dir)

    files := []
    Loop Files dir "\draw_*.txt", "F" {
        files.Push({
            path: A_LoopFileFullPath,
            name: A_LoopFileName,
            key: FormatTime(FileGetTime(A_LoopFileFullPath, "M"), "yyyyMMddHHmmss")
        })
    }
    ; newest first (keys are zero-padded timestamps)
    i := 2
    while i <= files.Length {
        v := files[i]
        j := i - 1
        while j >= 1 && files[j].key < v.key {
            files[j + 1] := files[j]
            j -= 1
        }
        files[j + 1] := v
        i += 1
    }

    lv := hDlg.AddListView("xm y+" S(8) " w" S(560) " r" Min(Max(files.Length, 2), 16) " -Multi Background2A2A2A cDDDDDD", ["Saved", "Work Time", "Laps", "File"])
    lv.OnEvent("DoubleClick", LoadSelected)

    for f in files {
        f.desc := {elapsed: "", laps: []}
        try {
            f.desc := TimerParseExportText(FileRead(f.path, "UTF-8"))
        }
        wt := (f.desc.elapsed = "") ? "--" : TimerFormatElapsed(f.desc.elapsed)
        saved := FormatTime(FileGetTime(f.path, "M"), "yyyy-MM-dd HH:mm:ss")
        lv.Add(, saved, wt, f.desc.laps.Length, f.name)
    }

    hDlg.AddButton("xm y+" S(10) " w" S(96) " h" S(28) " Background2E7D32 cFFFFFF Default", "Load Selected").OnEvent("Click", LoadSelected)
    hDlg.AddButton("x+" S(6) " yp w" S(64) " h" S(28), "Open").OnEvent("Click", OpenSelected)
    hDlg.AddButton("x+" S(6) " yp w" S(104) " h" S(28), "Open Folder").OnEvent("Click", OpenFolder)
    hDlg.AddButton("x+" S(6) " yp w" S(72) " h" S(28), "Delete").OnEvent("Click", DeleteSelected)
    hDlg.AddButton("x+" S(6) " yp w" S(120) " h" S(28), "Pick Other File...").OnEvent("Click", PickOther)
    hDlg.AddButton("x+" S(6) " yp w" S(70) " h" S(28), "Close").OnEvent("Click", (*) => hDlg.Destroy())
    hDlg.Show("AutoSize")

    LoadSelected(*) {
        row := lv.GetNext()
        if !row {
            _HK_ResultPopup("Timer History", "Select a history entry to load.", "FF9800")
            return
        }
        path := files[row].path
        hDlg.Destroy()
        TimerLoadFromPath(path)
    }

    OpenSelected(*) {
        row := lv.GetNext()
        if !row {
            _HK_ResultPopup("Timer History", "Select a history entry to open.", "FF9800")
            return
        }
        Run('"' files[row].path '"')
    }

    OpenFolder(*) {
        Run('explorer.exe "' TimerHistoryDir() '"')
    }

    DeleteSelected(*) {
        row := lv.GetNext()
        if !row {
            _HK_ResultPopup("Timer History", "Select a history entry to delete.", "FF9800")
            return
        }
        if MsgBox("Delete '" files[row].name "' from the history?", "Delete Timer History", "YesNo") != "Yes"
            return
        try FileDelete(files[row].path)
        lv.Delete(row)
        files.RemoveAt(row)
    }

    PickOther(*) {
        hDlg.Destroy()
        TimerLoadPickFile()
    }
}
