; --- Cursor Color Info ---
global _ccActive := false
global _ccGUI := 0
global _ccTickFn := 0
global _ccLastHex := ""
global _ccOffsetX := -20
global _ccOffsetY := 50
global _ccTickMs := 60
global _ccFollowCursor := true
global _ccX := 120
global _ccY := 120
global _ccMiddlePickEnabled := false
global _ccClipboardFormat := "RGB"
global _ccHistory := []

HexToRGB(hex) {
    return {r: Integer("0x" SubStr(hex,1,2)), g: Integer("0x" SubStr(hex,3,2)), b: Integer("0x" SubStr(hex,5,2))}
}

GetCursorPosForCapture(&x, &y) {
    pt := Buffer(8, 0)
    DllCall("GetCursorPos", "Ptr", pt)
    x := NumGet(pt, 0, "Int")
    y := NumGet(pt, 4, "Int")
}

GetColorAtPhysical(x, y) {
    hDC := DllCall("GetDC", "Ptr", 0, "Ptr")
    if !hDC
        return -1
    bgr := DllCall("GetPixel", "Ptr", hDC, "Int", x, "Int", y, "UInt")
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hDC)
    if bgr = 0xFFFFFFFF
        return -1
    return ((bgr & 0xFF) << 16) | (bgr & 0x00FF00) | ((bgr >> 16) & 0xFF)
}

GetColorUnderCursor() {
    old := DllCall("User32\SetThreadDpiAwarenessContext", "Ptr", -4, "Ptr")
    GetCursorPosForCapture(&x, &y)
    c := GetColorAtPhysical(x, y)
    if old
        DllCall("User32\SetThreadDpiAwarenessContext", "Ptr", old, "Ptr")
    if c = -1
        return "000000"
    return Format("{:06X}", c)
}

ToggleColorInfo(*) {
    global _ccActive, _ccGUI, _ccTickFn, _ccLastHex, _ccBtnIB, _ccTickMs
    _ccActive := !_ccActive
    if _ccActive {
        _ccLastHex := ""
        if !IsObject(_ccGUI)
            CreateColorInfoGUI()
        ColorInfoApplyWindowMode()
        _ccTickFn := ColorInfoTick
        SetTimer(_ccTickFn, _ccTickMs)
        if _ccFollowCursor
            _ccGUI.Show("NoActivate")
        else
            _ccGUI.Show("NoActivate x" _ccX " y" _ccY)
        ColorInfoApplyMiddlePickHotkey()
        if IsObject(_ccBtnIB)
            _ccBtnIB.Opt("Background9C27B0 cFFFFFF")
        DebugLog("Color info ON")
    } else {
        SetTimer(_ccTickFn, 0)
        if IsObject(_ccGUI)
            _ccGUI.Hide()
        ColorInfoApplyMiddlePickHotkey()
        if IsObject(_ccBtnIB)
            _ccBtnIB.Opt("Background444444 cFFFFFF")
        DebugLog("Color info OFF")
    }
}

ColorInfoSetTickMs(ms, saveToIni := true) {
    global _ccTickMs, _ccActive, _ccTickFn, SETTINGS_FILE
    try clean := Integer(ms)
    catch
        clean := 60
    _ccTickMs := Max(15, Min(1000, clean))
    if _ccActive && IsObject(_ccTickFn)
        SetTimer(_ccTickFn, _ccTickMs)
    if saveToIni {
        try IniWrite(_ccTickMs, SETTINGS_FILE, "ColorInfo", "TickMs")
        try SettingsSyncIniWatcher()
    }
    DebugLog("Color info tick: " _ccTickMs "ms")
}

CreateColorInfoGUI() {
    global _ccGUI
    _ccGUI := Gui("+AlwaysOnTop -Caption +ToolWindow")
    _ccGUI.BackColor := "2D2D32"
    _ccGUI.SetFont("s9", "Consolas")
    _ccGUI.MarginX := 5
    _ccGUI.MarginY := 3
    _ccGUI.preview := _ccGUI.AddProgress("xm y+3 w34 h34", 100)
    _ccGUI.hexText := _ccGUI.AddText("xp+40 yp+1 w105 h15 cFFFFFF", "#000000")
    _ccGUI.pickToggle := _ccGUI.AddText("x+4 yp-1 w54 h14 +0x200 Center cFFFFFF Background455A64", "")
    _ccGUI.rgbText := _ccGUI.AddText("xp-109 yp+17 w105 h15 cAAAAAA", "RGB: 0,0,0")
    _ccGUI.fmtToggle := _ccGUI.AddText("x+4 yp+1 w54 h14 +0x200 Center cFFFFFF Background546E7A", "")
    _ccGUI.pickToggle.OnEvent("Click", ToggleColorInfoMiddlePick)
    _ccGUI.fmtToggle.OnEvent("Click", ToggleColorInfoClipboardFormat)
    _ccGUI.OnEvent("Close", (*) => (_ccGUI.Hide()))
    ColorInfoRefreshBoxControls()
    ColorInfoApplyWindowMode()
}

ColorInfoApplyWindowMode() {
    global _ccGUI, _ccFollowCursor
    hwnd := SafeGuiHwnd(_ccGUI)
    if !hwnd
        return
    exStyle := DllCall("GetWindowLongPtr", "Ptr", hwnd, "Int", -20, "Ptr")
    if _ccFollowCursor
        exStyle |= 0x20
    else
        exStyle &= ~0x20
    DllCall("SetWindowLongPtr", "Ptr", hwnd, "Int", -20, "Ptr", exStyle, "Ptr")
    DllCall("SetWindowPos", "Ptr", hwnd, "Ptr", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x0027)
}

ColorInfoModeText() {
    global _ccFollowCursor
    return _ccFollowCursor ? "Follow cursor" : "Draggable"
}

ColorInfoApplyMiddlePickHotkey() {
    global _ccMiddlePickEnabled, _ccActive
    enabled := _ccMiddlePickEnabled && _ccActive
    try Hotkey("~MButton", ColorInfoClipboardPickHotkey, enabled ? "On" : "Off")
}

ColorInfoClipboardPickHotkey(*) {
    global _ccMiddlePickEnabled, _ccActive, _ccHistory
    if !_ccMiddlePickEnabled || !_ccActive
        return
    if IsTyping()
        return
    hexRaw := GetColorUnderCursor()
    rgb := HexToRGB(hexRaw)
    clip := ColorInfoClipboardValue(hexRaw, rgb)
    if SetClipboardSafe(clip, "Color Picker") {
        _ccHistory.InsertAt(1, {hex: hexRaw, rgb: rgb, clip: clip, time: A_Now})
        if _ccHistory.Length > 20
            _ccHistory.Pop()
        _SaveColorHistory()
        ShowNotify("Color Picker", clip " copied")
    }
    DebugLog("Color picker copied " clip " via middle mouse")
}

ColorInfoMiddlePickText() {
    global _ccMiddlePickEnabled
    return _ccMiddlePickEnabled ? "PICK" : "OFF"
}

ColorInfoClipboardFormatText() {
    global _ccClipboardFormat
    return _ccClipboardFormat = "RGB" ? "RGB" : "HEX"
}

ColorInfoClipboardValue(hexRaw, rgb := 0) {
    global _ccClipboardFormat
    if !IsObject(rgb)
        rgb := HexToRGB(hexRaw)
    if _ccClipboardFormat = "RGB"
        return rgb.r "," rgb.g "," rgb.b
    return hexRaw
}

ColorInfoRefreshBoxControls() {
    global _ccGUI, _ccMiddlePickEnabled, _ccClipboardFormat
    if !IsObject(_ccGUI)
        return
    if _ccGUI.HasProp("pickToggle") {
        _ccGUI.pickToggle.Text := ColorInfoMiddlePickText()
        _ccGUI.pickToggle.Opt("Background" (_ccMiddlePickEnabled ? "2E7D32" : "455A64") " cFFFFFF")
    }
    if _ccGUI.HasProp("fmtToggle") {
        _ccGUI.fmtToggle.Text := ColorInfoClipboardFormatText()
        _ccGUI.fmtToggle.Opt("Background" (_ccClipboardFormat = "RGB" ? "8E24AA" : "1565C0") " cFFFFFF")
    }
}

ColorInfoRefreshTexts(hexRaw := "") {
    global _ccGUI, _ccLastHex, _ccClipboardFormat
    if !IsObject(_ccGUI)
        return
    if hexRaw = ""
        hexRaw := _ccLastHex != "" ? _ccLastHex : GetColorUnderCursor()
    rgb := HexToRGB(hexRaw)
    rgbText := "RGB: " rgb.r "," rgb.g "," rgb.b
    hexText := "#" hexRaw
    if _ccClipboardFormat = "RGB" {
        _ccGUI.hexText.Value := rgbText
        _ccGUI.rgbText.Value := hexText
    } else {
        _ccGUI.hexText.Value := hexText
        _ccGUI.rgbText.Value := rgbText
    }
}

ToggleColorInfoMiddlePick(*) {
    global _ccMiddlePickEnabled
    ColorInfoSetMiddlePick(!_ccMiddlePickEnabled)
}

ColorInfoSetMiddlePick(enabled, saveToIni := true) {
    global _ccMiddlePickEnabled, SETTINGS_FILE
    _ccMiddlePickEnabled := !!enabled
    ColorInfoApplyMiddlePickHotkey()
    ColorInfoRefreshBoxControls()
    if saveToIni {
        try IniWrite(_ccMiddlePickEnabled ? 1 : 0, SETTINGS_FILE, "ColorInfo", "MiddlePick")
        try SettingsSyncIniWatcher()
    }
    DebugLog("Color info middle pick: " ColorInfoMiddlePickText())
}

ToggleColorInfoClipboardFormat(*) {
    global _ccClipboardFormat
    ColorInfoSetClipboardFormat(_ccClipboardFormat = "RGB" ? "HEX" : "RGB")
}

ColorInfoSetClipboardFormat(format, saveToIni := true) {
    global _ccClipboardFormat, SETTINGS_FILE
    clean := StrUpper(Trim(format))
    if clean != "RGB"
        clean := "HEX"
    _ccClipboardFormat := clean
    ColorInfoRefreshBoxControls()
    ColorInfoRefreshTexts()
    if saveToIni {
        try IniWrite(_ccClipboardFormat, SETTINGS_FILE, "ColorInfo", "ClipboardFormat")
        try SettingsSyncIniWatcher()
    }
    DebugLog("Color info clipboard format: " _ccClipboardFormat)
}

ColorInfoSetFollowMode(follow, saveToIni := true) {
    global _ccFollowCursor, _ccGUI, _ccX, _ccY, SETTINGS_FILE
    _ccFollowCursor := !!follow
    if SafeGuiHwnd(_ccGUI) {
        try _ccGUI.GetPos(&_ccX, &_ccY)
        ColorInfoApplyWindowMode()
        if _ccFollowCursor
            _ccGUI.Show("NoActivate")
        else
            _ccGUI.Show("NoActivate x" _ccX " y" _ccY)
    }
    if saveToIni {
        try {
            IniWrite(_ccFollowCursor ? 1 : 0, SETTINGS_FILE, "ColorInfo", "FollowCursor")
            IniWrite(_ccX, SETTINGS_FILE, "ColorInfo", "X")
            IniWrite(_ccY, SETTINGS_FILE, "ColorInfo", "Y")
        }
        try SettingsSyncIniWatcher()
    }
    DebugLog("Color info mode: " ColorInfoModeText())
}

ToggleColorInfoFollowMode(*) {
    global _ccFollowCursor
    ColorInfoSetFollowMode(!_ccFollowCursor)
}

ColorInfoTick(*) {
    global _ccActive, _ccGUI, _ccLastHex, _ccX, _ccY, _ccClipboardFormat, _ccTickFn, _ccFollowCursor, _ccOffsetX, _ccOffsetY, _ccMiddlePickEnabled, SETTINGS_FILE
    if !_ccActive
        return
    if !IsObject(_ccGUI) {
        _ccActive := false
        SetTimer(_ccTickFn, 0)
        return
    }
    hex := GetColorUnderCursor()
    if hex != _ccLastHex {
        _ccLastHex := hex
        _ccGUI.preview.Opt("c" hex)
        ColorInfoRefreshTexts(hex)
    }
    if _ccFollowCursor {
        pt := Buffer(8, 0)
        DllCall("GetCursorPos", "Ptr", pt)
        mx := NumGet(pt, 0, "Int")
        my := NumGet(pt, 4, "Int")
        _ccGUI.GetPos(,, &w, &h)
        x := mx + _ccOffsetX
        y := my + _ccOffsetY
        mon := GetMonitorFromPoint(mx, my)
        MonitorGetWorkArea(mon, &mL, &mT, &mR, &mB)
        if x + w > mR
            x := mx - w - _ccOffsetX
        if y + h > mB
            y := my - h - _ccOffsetY
        _ccX := x
        _ccY := y
        _ccGUI.Show("NoActivate x" x " y" y)
    } else {
        try _ccGUI.GetPos(&_ccX, &_ccY)
    }
}

ShowColorInfoOffsetDialog(*) {
    global _ccOffsetX, _ccOffsetY, _ccTickMs, _ccFollowCursor, _ccMiddlePickEnabled, _ccClipboardFormat
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Color Info Offset")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)
    dlg.AddText("xm", "Mode:")
    modeDd := dlg.AddDropDownList("x+8 yp-2 w" S(140), ["Follow cursor", "Draggable"])
    modeDd.Value := _ccFollowCursor ? 1 : 2
    pickCb := dlg.AddCheckbox("xm y+" S(8) " cFFFFFF Background1E1F22", "Middle mouse copies color to clipboard")
    pickCb.Value := _ccMiddlePickEnabled ? 1 : 0
    pickCb.OnEvent("Click", _CCMiddlePickCheckboxSave)
    dlg.AddText("xm y+" S(8), "Clipboard:")
    fmtDd := dlg.AddDropDownList("x+8 yp-2 w" S(120), ["HEX", "RGB"])
    fmtDd.Value := _ccClipboardFormat = "RGB" ? 2 : 1
    dlg.AddText("xm y+" S(8), "X offset:")
    xEd := dlg.AddEdit("x+8 w60 c000000 BackgroundFFFFFF Number", _ccOffsetX)
    dlg.AddText("xm y+" S(4), "Y offset:")
    yEd := dlg.AddEdit("x+8 w60 c000000 BackgroundFFFFFF Number", _ccOffsetY)
    dlg.AddText("xm y+" S(4), "Tick:")
    tickEd := dlg.AddEdit("x+8 w60 c000000 BackgroundFFFFFF Number", _ccTickMs)
    dlg.AddText("x+6 yp+2 cAAAAAA", "ms")
    dlg.AddButton("xm y+" S(8) " w70 Default", "OK").OnEvent("Click", _CCSaveOffset.Bind(dlg, xEd, yEd, tickEd, modeDd, pickCb, fmtDd))
    dlg.AddButton("x+10 w70", "Cancel").OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("AutoSize Center")
}

GetMonitorFromPoint(x, y) {
    count := MonitorGetCount()
    Loop count {
        MonitorGetWorkArea(A_Index, &L, &T, &R, &B)
        if x >= L && x <= R && y >= T && y <= B
            return A_Index
    }
    return 1
}

_CCSaveOffset(dlg, xEd, yEd, tickEd, modeDd, pickCb, fmtDd, *) {
    global _ccOffsetX, _ccOffsetY, _ccTickMs, SETTINGS_FILE, _ccFollowCursor, _ccMiddlePickEnabled, _ccClipboardFormat, _ccX, _ccY
    try {
        _ccOffsetX := Integer(xEd.Value)
        _ccOffsetY := Integer(yEd.Value)
        _ccTickMs := Max(15, Min(1000, Integer(tickEd.Value)))
    } catch
        return
    ColorInfoSetFollowMode(modeDd.Value = 1, false)
    ColorInfoSetMiddlePick(pickCb.Value = 1, false)
    ColorInfoSetClipboardFormat(fmtDd.Text, false)
    ColorInfoSetTickMs(_ccTickMs, false)
    try {
        IniWrite(_ccOffsetX, SETTINGS_FILE, "ColorInfo", "OffsetX")
        IniWrite(_ccOffsetY, SETTINGS_FILE, "ColorInfo", "OffsetY")
        IniWrite(_ccTickMs, SETTINGS_FILE, "ColorInfo", "TickMs")
        IniWrite(_ccFollowCursor ? 1 : 0, SETTINGS_FILE, "ColorInfo", "FollowCursor")
        IniWrite(_ccMiddlePickEnabled ? 1 : 0, SETTINGS_FILE, "ColorInfo", "MiddlePick")
        IniWrite(_ccClipboardFormat, SETTINGS_FILE, "ColorInfo", "ClipboardFormat")
        IniWrite(_ccX, SETTINGS_FILE, "ColorInfo", "X")
        IniWrite(_ccY, SETTINGS_FILE, "ColorInfo", "Y")
    }
    try SettingsSyncIniWatcher()
    dlg.Destroy()
}

ShowColorHistory(*) {
    global _ccHistory
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Color History")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(10)
    dlg.MarginY := S(10)
    if _ccHistory.Length = 0 {
        dlg.AddText("cAAAAAA", "No colors picked yet.`nActivated the copies color to clipboard first.`nMiddle-click to pick a color.")
        dlg.chkCCMiddle := dlg.AddCheckbox("xm y+5 cFFFFFF Background1E1F22", "Middle click copies color to clipboard")
        dlg.chkCCMiddle.Value := _ccMiddlePickEnabled ? 1 : 0
        dlg.chkCCMiddle.OnEvent("Click", _CCMiddlePickCheckboxSave)
        dlg.Show("AutoSize")
        return
    }
    ; header
    dlg.AddText("xm+2 w" S(10) " cAAAAAA Center", "#")
    dlg.AddText("x+6 yp w" S(22) " cAAAAAA", " ")
    dlg.AddText("x+10 yp w" S(80) " cAAAAAA", "HEX")
    dlg.AddText("x+8 yp w" S(106) " cAAAAAA", "RGB")
    dlg.AddText("x+4 yp w" S(60) " cAAAAAA Right", "Time")
    ; rows
    _showSelIdx := 0
    _showRows := []
    _showRowH := S(22)
    _showRowGap := S(10)
    _showMaxRows := Min(15, _ccHistory.Length)
    ; helper to remove highlight and update indicator
    _showDeselect(*) {
        if _showSelIdx > 0 {
            _showPrev := _showRows[_showSelIdx]
            _showPrev.selInd.Opt("c555555")
            _showPrev.selInd.Text := "○"
        }
    }
    _showRowClick := (idx, *) => idx = _showSelIdx ? "" : (
        _showDeselect(),
        (_showCur := _showRows[idx]),
        _showCur.selInd.Opt("cFFFFFF"),
        _showCur.selInd.Text := "●",
        _showSelIdx := idx
    )
    _showDblHex(idx, *) {
        if SetClipboardSafe(_ccHistory[idx].hex, "Color History")
            ShowNotify("Color History", "Copied HEX: #" _ccHistory[idx].hex)
    }
    _showDblRgb(idx, *) {
        _rgb := _ccHistory[idx].rgb
        if SetClipboardSafe(_rgb.r "," _rgb.g "," _rgb.b, "Color History")
            ShowNotify("Color History", "Copied RGB: " _rgb.r "," _rgb.g "," _rgb.b)
    }
    dlg.AddText("xm y+" S(4) " w" S(310) " h" S(1) " +0x200 Background555555")
    Loop _showMaxRows {
        entry := _ccHistory[A_Index]
        h := entry.hex
        r := entry.rgb
        off := A_Index = 1 ? "xm y+" S(8) : "xm y+" _showRowGap
        si := dlg.AddText(off " w" S(12) " h" _showRowH " c555555 Center", "○")
        sw := dlg.AddText("x+6 yp w" S(22) " h" _showRowH " +0x200 Border Background" h, "")
        sw.ToolTip := "#" h
        ht := dlg.AddText("x+8 yp+2 w" S(80) " cFFFFFF", "#" h)
        rt := dlg.AddText("x+6 yp w" S(110) " cAAAAAA", r.r "," r.g "," r.b)
        tt := dlg.AddText("x+4 yp w" S(60) " c555555 Right", FormatTime(entry.time, "HH:mm:ss"))
        _showRows.Push({selInd: si, sw: sw, hexText: ht, rgbText: rt, timeText: tt, hex: h, rgb: r})
        ; row click fires for any sub-element
        si.OnEvent("Click", _showRowClick.Bind(A_Index))
        sw.OnEvent("Click", _showRowClick.Bind(A_Index))
        ht.OnEvent("Click", _showRowClick.Bind(A_Index))
        rt.OnEvent("Click", _showRowClick.Bind(A_Index))
        tt.OnEvent("Click", _showRowClick.Bind(A_Index))
        ; double-click HEX area copies HEX, RGB area copies RGB
        si.OnEvent("DoubleClick", _showDblHex.Bind(A_Index))
        sw.OnEvent("DoubleClick", _showDblHex.Bind(A_Index))
        ht.OnEvent("DoubleClick", _showDblHex.Bind(A_Index))
        rt.OnEvent("DoubleClick", _showDblRgb.Bind(A_Index))
        tt.OnEvent("DoubleClick", _showDblHex.Bind(A_Index))
    }
    ; buttons
    _showCopyHex(*) {
        if _showSelIdx = 0
            return ShowNotify("Color History", "No entry selected")
        _showCpyEntry := _showRows[_showSelIdx]
        if SetClipboardSafe(_showCpyEntry.hex, "Color History")
            ShowNotify("Color History", "Copied HEX: #" _showCpyEntry.hex)
    }
    _showCopyRgb(*) {
        if _showSelIdx = 0
            return ShowNotify("Color History", "No entry selected")
        _showCpyEntry := _showRows[_showSelIdx]
        _showRgbStr := _showCpyEntry.rgb.r "," _showCpyEntry.rgb.g "," _showCpyEntry.rgb.b
        if SetClipboardSafe(_showRgbStr, "Color History")
            ShowNotify("Color History", "Copied RGB: " _showRgbStr)
    }
    _showClearAll := (*) => (
        _ccHistory := [],
        _SaveColorHistory(),
        dlg.Destroy()
    )
    _showClose(*) => dlg.Destroy()
    dlg.AddText("xm y+" S(12) " w" S(310) " h" S(1) " +0x200 Background555555")
    dlg.chkCCMiddle := dlg.AddCheckbox("xm y+5 cFFFFFF Background1E1F22", "Middle click copies color to clipboard")
    dlg.chkCCMiddle.Value := _ccMiddlePickEnabled ? 1 : 0
    dlg.chkCCMiddle.OnEvent("Click", _CCMiddlePickCheckboxSave)
    dlg.AddButton("xm y+" S(8) " w" S(75) " h" S(24), "Copy HEX").OnEvent("Click", _showCopyHex)
    dlg.AddButton("x+6 yp w" S(75) " h" S(24), "Copy RGB").OnEvent("Click", _showCopyRgb)
    dlg.AddButton("x+6 yp w" S(75) " h" S(24), "Clear All").OnEvent("Click", _showClearAll)
    dlg.AddButton("x+6 yp w" S(65) " h" S(24) " Default", "Close").OnEvent("Click", _showClose)
    dlg.Show("AutoSize")
}

; ============================================================

_CCMiddlePickCheckboxSave(ctrl, *) {
    ColorInfoSetMiddlePick(ctrl.Value = 1, true)
}

_SaveColorHistory() {
    global SETTINGS_FILE, _ccHistory
    local maxEntries := 20
    if _ccHistory.Length > maxEntries
        Loop _ccHistory.Length - maxEntries
            _ccHistory.Pop()
    try {
        IniWrite(_ccHistory.Length, SETTINGS_FILE, "ColorHistory", "count")
        local i := 1
        for entry in _ccHistory {
            if i > maxEntries
                break
            IniWrite(entry.hex, SETTINGS_FILE, "ColorHistory", i "_hex")
            IniWrite(entry.rgb.r, SETTINGS_FILE, "ColorHistory", i "_r")
            IniWrite(entry.rgb.g, SETTINGS_FILE, "ColorHistory", i "_g")
            IniWrite(entry.rgb.b, SETTINGS_FILE, "ColorHistory", i "_b")
            IniWrite(entry.clip, SETTINGS_FILE, "ColorHistory", i "_clip")
            IniWrite(entry.time, SETTINGS_FILE, "ColorHistory", i "_time")
            i++
        }
    }
    try SettingsSyncIniWatcher()
}
_LoadColorHistory() {
    global SETTINGS_FILE, _ccHistory
    try {
        cnt := IniRead(SETTINGS_FILE, "ColorHistory", "count", 0)
        if cnt <= 0
            return
        _ccHistory := []
        Loop cnt {
            hex := IniRead(SETTINGS_FILE, "ColorHistory", A_Index "_hex", "")
            if hex = ""
                continue
            r := IniReadIntSafe(SETTINGS_FILE, "ColorHistory", A_Index "_r", 0)
            g := IniReadIntSafe(SETTINGS_FILE, "ColorHistory", A_Index "_g", 0)
            b := IniReadIntSafe(SETTINGS_FILE, "ColorHistory", A_Index "_b", 0)
            clip := IniRead(SETTINGS_FILE, "ColorHistory", A_Index "_clip", "#" hex)
            t := IniRead(SETTINGS_FILE, "ColorHistory", A_Index "_time", A_Now)
            _ccHistory.Push({hex: hex, rgb: {r: r, g: g, b: b}, clip: clip, time: t})
        }
    } catch as err {
        DebugLog("_LoadColorHistory error: " err.Message)
    }
}
