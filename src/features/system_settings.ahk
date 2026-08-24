;FEATURES - System Settings
; ============================================================

CreateSettingsCardHeader(gui, xOpt, yOpt, width, title, helperText := "", helperHeight := 0) {
    gui.SetFont("s9 cFFFFFF", "Segoe UI")
    gui.AddText(xOpt " " yOpt " cFFFFFF", title)
    gui.AddText(xOpt " y+2 w" width " h1 Background555555")
    if helperText != "" {
        gui.SetFont("s8 cAAAAAA", "Segoe UI")
        heightOpt := helperHeight > 0 ? " h" helperHeight : ""
        gui.AddText(xOpt " y+4 w" width heightOpt, helperText)
    }
    gui.SetFont("s8 cFFFFFF", "Segoe UI")
}

CreateSettingsSaveResetRow(gui, xOpt, yOpt, btnW, saveFn, resetFn, gap := 6, saveWidthExtra := 0, resetWidthExtra := 0) {
    gui.SetFont("s9 cFFFFFF", "Segoe UI")
    saveBtn := gui.AddButton(xOpt " " yOpt " w" (btnW + saveWidthExtra) " h23", "Save")
    saveBtn.OnEvent("Click", saveFn)
    resetBtn := gui.AddButton("x+" gap " yp w" (btnW + resetWidthExtra) " h23", "Reset")
    resetBtn.OnEvent("Click", resetFn)
    return [saveBtn, resetBtn]
}

RequirementPreviewMatches(req, targetReq) {
    return HK_NormalizeRequirement(req) = HK_NormalizeRequirement(targetReq)
}

RequirementPreviewStatus(req, baseEnabled := true) {
    req := HK_NormalizeRequirement(req)
    if !baseEnabled
        return "Disabled item"
    return PieRequirementEnabled(req) ? "Enabled now" : "Blocked now"
}

RequirementPreviewActionText(item) {
    if !IsObject(item)
        return ""
    t := item.Get("type", "")
    if t = "shortcut"
        return item.Get("keys", item.Get("action", ""))
    if t = "submenu"
        return "Sub Pie " item.Get("subPie", 1)
    if t = "disabled"
        return "Disabled"
    return item.Get("action", item.Get("target", item.Get("fn", "")))
}

RequirementPreviewSummary(label, action := "", fallback := "") {
    label := Trim(label)
    action := Trim(action)
    fallback := Trim(fallback)
    if action != "" {
        fn := RegExReplace(action, "\([^)]*\)$", "")
        try {
            summary := HK_FunctionSummary(fn)
            if summary != "" && !InStr(summary, "Callable built-in toolkit function")
                return summary
        }
    }
    if fallback != ""
        return fallback
    if label != ""
        return "Requires this CSP preset before the toolkit action can run: " label
    return "Requires this CSP preset before the toolkit action can run."
}

RequirementPreviewAdd(rows, source, name, keyOrType, req, status, summary) {
    row := Map()
    row["source"] := source
    row["name"] := name
    row["key"] := keyOrType
    row["requirement"] := HK_NormalizeRequirement(req)
    row["status"] := status
    row["summary"] := summary
    rows.Push(row)
}

RequirementPreviewRows(targetReq) {
    global HotkeyDefs, ColorItems, LinkItems, PieConfigs, PieNames, SubPieConfigs, SubPieNames, PieQuickHotkeys
    rows := []
    targetReq := HK_NormalizeRequirement(targetReq)

    for d in HotkeyDefs {
        try req := HK_GetRequirement(d)
        catch
            req := d.HasOwnProp("req") ? HK_NormalizeRequirement(d.req) : ""
        if !RequirementPreviewMatches(req, targetReq)
            continue
        try key := HK_Get(d.id, d.def)
        catch
            key := d.HasOwnProp("def") ? d.def : ""
        try fnName := HK_GetFnName(d)
        catch
            fnName := ""
        summary := RequirementPreviewSummary(d.desc, fnName, "Hotkey action: " d.desc)
        RequirementPreviewAdd(rows, "Hotkey", d.desc, HK_DisplayKey(key), req, RequirementPreviewStatus(req, key != "-"), summary)
    }

    for _, item in ColorItems {
        req := HK_NormalizeRequirement(item.Get("requirement", ""))
        if !RequirementPreviewMatches(req, targetReq)
            continue
        label := item.Get("hover", item.Get("label", "Color item"))
        action := RequirementPreviewActionText(item)
        summary := RequirementPreviewSummary(label, action, item.Get("note", label))
        RequirementPreviewAdd(rows, "Color GUI", label, item.Get("type", "") " / " action, req, RequirementPreviewStatus(req, item.Get("type", "") != "disabled"), summary)
    }

    for _, item in LinkItems {
        req := HK_NormalizeRequirement(item.Get("requirement", ""))
        if !RequirementPreviewMatches(req, targetReq)
            continue
        label := item.Get("label", item.Get("hover", "Link item"))
        action := RequirementPreviewActionText(item)
        summary := RequirementPreviewSummary(label, action, item.Get("note", item.Get("hover", label)))
        RequirementPreviewAdd(rows, "Link GUI", label, item.Get("type", "") " / " action, req, RequirementPreviewStatus(req, item.Get("enabled", 1)), summary)
    }

    for p, config in PieConfigs {
        pieName := PieNames.Length >= p ? PieNames[p] : "Pie " p
        for i, item in config {
            req := HK_NormalizeRequirement(item.Get("requirement", ""))
            if !RequirementPreviewMatches(req, targetReq)
                continue
            label := item.Get("label", "Slot " i)
            action := RequirementPreviewActionText(item)
            summary := RequirementPreviewSummary(label, action, "Pie slot in " pieName ".")
            RequirementPreviewAdd(rows, pieName, label, item.Get("type", "") " / " action, req, RequirementPreviewStatus(req, item.Get("enabled", 1)), summary)
        }
    }

    for s, config in SubPieConfigs {
        subName := SubPieNames.Length >= s ? SubPieNames[s] : "Sub Pie " s
        for i, item in config {
            req := HK_NormalizeRequirement(item.Get("requirement", ""))
            if !RequirementPreviewMatches(req, targetReq)
                continue
            label := item.Get("label", "Slot " i)
            action := RequirementPreviewActionText(item)
            summary := RequirementPreviewSummary(label, action, "Sub-pie slot in " subName ".")
            RequirementPreviewAdd(rows, subName, label, item.Get("type", "") " / " action, req, RequirementPreviewStatus(req, item.Get("enabled", 1)), summary)
        }
    }

    for _, item in PieQuickHotkeys {
        req := HK_NormalizeRequirement(item.Get("requirement", ""))
        if !RequirementPreviewMatches(req, targetReq)
            continue
        label := item.Get("label", "Quick Pie")
        action := RequirementPreviewActionText(item)
        summary := RequirementPreviewSummary(label, action, item.Get("description", "Quick Pie hotkey available while a pie menu is open."))
        RequirementPreviewAdd(rows, "Quick Pie", label, item.Get("key", "") " / " item.Get("scope", "all"), req, RequirementPreviewStatus(req, item.Get("enabled", 1)), summary)
    }

    return rows
}

ShowRequirementPreview(*) {
    reqTabs := [REQ_ANIM, REQ_NASTAR]
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Requirement Preview")
    dlg.BackColor := "F0F0F0"
    dlg.SetFont("s" S(9) " c202020", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)
    dlg.AddText("xm w" S(900) " c555555", "Preview which toolkit buttons, hotkeys, pie slots, and quick-pie actions depend on each CSP AutoAction preset.")

    tab := dlg.AddTab3("xm y+8 w" S(920) " h" S(440) " BackgroundFFFFFF c202020", reqTabs)
    for idx, req in reqTabs {
        tab.UseTab(idx)
        stateText := PieRequirementEnabled(req) ? "Current state: enabled" : "Current state: disabled / blocked"
        dlg.AddText("x" S(28) " y" S(70) " w" S(860) " c555555", stateText)
        lv := dlg.AddListView("x" S(28) " y" S(94) " w" S(892) " h" S(350) " Grid +Report", ["Source", "Button / Action", "Key / Type", "Status", "Summary"])
        rows := RequirementPreviewRows(req)
        if rows.Length = 0 {
            lv.Add("", "-", "No entries found", "-", "-", "No toolkit entries currently use this requirement.")
        } else {
            for _, row in rows
                lv.Add("", row["source"], row["name"], row["key"], row["status"], row["summary"])
        }
        lv.ModifyCol(1, S(110))
        lv.ModifyCol(2, S(185))
        lv.ModifyCol(3, S(140))
        lv.ModifyCol(4, S(95))
        lv.ModifyCol(5, S(720))
    }
    tab.UseTab(0)
    dlg.AddButton("xm y" S(485) " w" S(88) " h" S(26) " Default", "Close").OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("w" S(955) " h" S(520))
}
ShowLTSettings() {
    global LT_X, LT_Y, LT_Color, LT_ClickX, LT_ClickY, ColorClick1X, ColorClick1Y, ColorClick2X, ColorClick2Y, _ccOffsetX, _ccOffsetY, _ccTickMs, _ccFollowCursor, _ccMiddlePickEnabled, _ccClipboardFormat, AutoSaveInterval, SETTINGS_FILE
    global HOLD_THRESHOLD_MS, _tabBlockPassthrough, _useUltimateSaveAs, _selectCelMode, _capsBlockOutput
    global CapslockEnabled, TabCombosEnabled
    global ReqAnimationEnabled, ReqNastarEnabled
    static sGui := 0
    if IsObject(sGui) {
        try if sGui.Hwnd {
            sGui.Show()
            return
        }
    }
sGui := Gui("+AlwaysOnTop +ToolWindow", "System Settings")
sGui.BackColor := "1E1F22"
sGui.SetFont("s9 cFFFFFF", "Segoe UI")
sGui.OnEvent("Close", SystemSettingsClose)
sGui.OnEvent("Escape", SystemSettingsClose)

sGui.MarginX := S(14)
sGui.MarginY := S(12)

leftW  := S(305)
rightW := S(305)
rightX := S(345)
w      := S(700)

lblW   := S(65)
editW  := S(50)
btnW   := S(66)
pickW  := S(44)
cardTopY := 10
cardRowGap := S(16)

; ==========================================================
; DETECTION PIXEL
; ==========================================================

CreateSettingsCardHeader(sGui, "xm", "y" cardTopY, leftW, "Detection Pixel"
    , "Pick a pixel from the Enable/Disable Light Table button area in the Animation Cels window. Avoid the icon color and go for the edge. Expected should match the color shown there while LT is ON."
    , S(54))


sGui.ltDetectAlert := sGui.AddText("xp+23 yp+41 w" leftW " cFF9800 Hidden", "Pick required: Detection Pixel X/Y is 0.")

sGui.AddText("xm y+8 w16", "X:")
sGui.edX := sGui.AddEdit("x+4 yp w" editW " c000000 BackgroundFFFFFF", LT_X)

sGui.AddText("x+10 yp w16", "Y:")
sGui.edY := sGui.AddEdit("x+4 yp w" editW " c000000 BackgroundFFFFFF", LT_Y)
sGui.AddButton("x+8 yp-1 w" pickW " h22", "Pick")
    .OnEvent("Click", PickCoord.Bind("LT Detection", "edX", "edY", true))

sGui.SetFont("s9 cFFFFFF", "Segoe UI")
sGui.AddText("xm y+7 w" lblW, "Expected:")
sGui.edColor := sGui.AddEdit(
    "x+4 yp w70 h20 c000000 BackgroundFFFFFF",
    Format("#{:06X}", LT_Color)
)

sGui.expBox := sGui.AddEdit(
    "x+6 yp w28 h20 ReadOnly Background" Format("{:06X}", LT_Color),
    ""
)
DllCall("uxtheme\SetWindowTheme", "ptr", sGui.expBox.Hwnd, "wstr", "", "ptr", 0)

sGui.expMatch := sGui.AddText("x+6 yp w20 cAAAAAA")

sGui.AddText("xm y+8 w" lblW, "Found:")

sGui.fndHex := sGui.AddText(
    "x+4 yp w70 h20 +0x200 +Border Background2D2D32 cAAAAAA",
    ""
)

sGui.fndBox := sGui.AddEdit(
    "x+6 yp w28 h20 ReadOnly BackgroundFFFFFF",
    ""
)
DllCall("uxtheme\SetWindowTheme", "ptr", sGui.fndBox.Hwnd, "wstr", "", "ptr", 0)

btnLTTest := sGui.AddButton("xm y+7 w" btnW+73 " h23", "Test")
btnLTTest.OnEvent("Click", TestLTCoords)

btnLTSaveReset := CreateSettingsSaveResetRow(sGui, "xm", "y+8", btnW, SaveLTDetect, ResetLTDetect)
btnLTReset := btnLTSaveReset[2]

; ==========================================================
; CLICK COORDINATES
; ==========================================================

CreateSettingsCardHeader(sGui, "x" rightX, "y" cardTopY, rightW, "Click Coordinates"
    , "These are the screen positions used by CSP clicks. Recalibrate whenever the CSP window or the Animation Cels / Light Table palette moves."
    , S(44))

sGui.ltClickAlert := sGui.AddText("xm+" rightX+56 " yp+28 w" rightW " cFF9800 Hidden", "Pick required: one or more click coordinates is 0.")

sGui.AddText("x" rightX " y+8 w60", "Reset")
sGui.AddText("xp+45 yp", "X:")
sGui.edLTX := sGui.AddEdit("x+6 yp w44 c000000 BackgroundFFFFFF", LT_ClickX)
sGui.AddText("x+6 yp", "Y:")
sGui.edLTY := sGui.AddEdit("x+6 yp w44 c000000 BackgroundFFFFFF", LT_ClickY)
sGui.AddButton("x+6 yp-1 w" pickW " h22", "Pick")
    .OnEvent("Click", PickCoord.Bind("LT Reset", "edLTX", "edLTY", false))

sGui.AddText("x" rightX " y+7 w60", "Img 1")
sGui.AddText("xp+45 yp", "X:")
sGui.edC1X := sGui.AddEdit("x+6 yp w44 c000000 BackgroundFFFFFF", ColorClick1X)
sGui.AddText("x+6 yp", "Y:")
sGui.edC1Y := sGui.AddEdit("x+6 yp w44 c000000 BackgroundFFFFFF", ColorClick1Y)
sGui.AddButton("x+6 yp-1 w" pickW " h22", "Pick")
    .OnEvent("Click", PickCoord.Bind("LT Image 1", "edC1X", "edC1Y", false))

sGui.AddText("x" rightX " y+7 w60", "Img 2")
sGui.AddText("xp+45 yp", "X:")
sGui.edC2X := sGui.AddEdit("x+6 yp w44 c000000 BackgroundFFFFFF", ColorClick2X)
sGui.AddText("x+6 yp", "Y:")
sGui.edC2Y := sGui.AddEdit("x+6 yp w44 c000000 BackgroundFFFFFF", ColorClick2Y)
sGui.AddButton("x+6 yp-1 w" pickW " h22", "Pick")
    .OnEvent("Click", PickCoord.Bind("LT Image 2", "edC2X", "edC2Y", false))
sGui.SetFont("s9 cFFFFFF", "Segoe UI")
btnCoordSaveReset := CreateSettingsSaveResetRow(sGui, "x" rightX, "y+8", btnW, SaveClickCoords, ResetClickCoords)
btnCoordSave := btnCoordSaveReset[1]
btnCoordReset := btnCoordSaveReset[2]

btnLTReset.GetPos(, &leftTopBtnY, , &leftTopBtnH)
btnCoordReset.GetPos(, &rightTopBtnY, , &rightTopBtnH)
cardRow2Y := Max(leftTopBtnY + leftTopBtnH, rightTopBtnY + rightTopBtnH) + cardRowGap - 6

; ==========================================================
; COLOR OFFSET
; ==========================================================

CreateSettingsCardHeader(sGui, "xm", "y" cardRow2Y, leftW, "Color Info Offset"
    , "Choose whether the color info box follows the cursor or stays draggable in one place. Middle click copy and clipboard format can be configured here. Offset only applies while Follow cursor is active."
    , S(56))

sGui.AddText("xm y+6 w13", "X:")
sGui.edCCX := sGui.AddEdit("x+4 yp w" editW " h20  c000000 BackgroundFFFFFF", _ccOffsetX)

sGui.AddText("x+10 yp w13", "Y:")
sGui.edCCY := sGui.AddEdit("x+4 yp w" editW " h20 c000000 BackgroundFFFFFF", _ccOffsetY)
sGui.AddText("x+10 yp w18", "Tick:")
sGui.edCCTick := sGui.AddEdit("x+4 yp w" editW " h20 c000000 BackgroundFFFFFF", _ccTickMs)
sGui.AddText("x+4 yp+2 w22 cAAAAAA", "ms")
sGui.AddText("xm y+12 w36", "Mode:")
sGui.ddlCCMode := sGui.AddDropDownList("x+6 yp w" S(150), ["Follow cursor", "Draggable"])
sGui.ddlCCMode.Value := _ccFollowCursor ? 1 : 2
sGui.ccCurrent := sGui.AddText("x+8 yp+2 w" S(120) " cAAAAAA", "Current: " ColorInfoModeText())
sGui.ccModeStatus := sGui.AddText("xm y+10 w" leftW " h" S(30) " cAAAAAA", "")

sGui.chkCCMiddle := sGui.AddCheckbox("xm y+5 w" leftW " cFFFFFF Background1E1F22", "Middle click copies color to clipboard")
sGui.chkCCMiddle.Value := _ccMiddlePickEnabled ? 1 : 0
sGui.AddText("xm y+10 w20", "Clip:")
sGui.ddlCCClipFmt := sGui.AddDropDownList("x+6 yp-2 w" S(96), ["HEX", "RGB"])
sGui.ddlCCClipFmt.Value := _ccClipboardFormat = "RGB" ? 2 : 1
sGui.ccPickStatus := sGui.AddText("x+8 yp+2 w" S(120) " cAAAAAA", "")
sGui.ddlCCMode.OnEvent("Change", ColorInfoRefreshSettingsUI)
sGui.chkCCMiddle.OnEvent("Click", ColorInfoRefreshSettingsUI)
sGui.ddlCCClipFmt.OnEvent("Change", ColorInfoRefreshSettingsUI)
sGui.SetFont("s9 cFFFFFF", "Segoe UI")
btnCCSaveReset := CreateSettingsSaveResetRow(sGui, "xm", "y+12", btnW, SaveColorOffset, ResetColorOffset, 6, 2, 2)
btnCCReset := btnCCSaveReset[2]

; ==========================================================
; CSP AUTOACTION PRESETS
; ==========================================================
cardRow2Y := cardRow2Y - 30

CreateSettingsCardHeader(sGui, "x" rightX, "y" cardRow2Y, rightW, "CSP AutoAction Presets"
    , "Enable the AutoAction preset packs that are installed in your CSP setup.", S(32))
sGui.chkAnim := sGui.AddCheckbox("x" rightX " y+5 cFFFFFF Background1E1F22", "Animation_autoaction.laf")
sGui.chkAnim.Value := ReqAnimationEnabled
sGui.chkNastar := sGui.AddCheckbox("x" rightX "  y+2 cFFFFFF Background1E1F22", "Nastar.laf")
sGui.chkNastar.Value := ReqNastarEnabled
sGui.chkAnim.OnEvent("Click", ToggleReqAnimFromGUI)
sGui.chkNastar.OnEvent("Click", ToggleReqNastarFromGUI)
btnSettingSaveReset := CreateSettingsSaveResetRow(sGui, "x" rightX , "y+10", btnW, SaveReqPresetSettings, ResetReqPresetSettings)
btnSetting := btnSettingSaveReset[2]
sGui.AddButton("x+6 yp w" btnW " h23", "Preview").OnEvent("Click", ShowRequirementPreview)

btnCCReset.GetPos(, &leftMidBtnY, , &leftMidBtnH)
btnSetting.GetPos(, &rightMidBtnY, , &rightMidBtnH)
cardRow3Y := Max(leftMidBtnY + leftMidBtnH, rightMidBtnY + rightMidBtnH) + cardRowGap - 6

; ==========================================================
; AUTO SAVE
; ==========================================================

CreateSettingsCardHeader(sGui, "xm" , "y" cardRow3Y, leftW, "Auto Save"
    , "Automatically save the current CSP file every N seconds.", S(17))

sGui.AddText("xm y+5", "Interval:")
sGui.edAutoSave := sGui.AddEdit("x+6 yp w44 c000000 BackgroundFFFFFF",AutoSaveInterval)

sGui.AddText("x+6 yp+1 cAAAAAA", "s (10-3600)")
sGui.SetFont("s9 cFFFFFF", "Segoe UI")
sGui.AddText("xm y+" S(14), "Save as (Shift+Ctrl+S) mode:")
if !ReqNastarEnabled {
    sGui.SetFont("cFF9800", "Segoe UI")
    sGui.reqSaveAs := sGui.AddText("x+6 yp cFF9800", "Requires Nastar.laf")
}
else {
    sGui.reqSaveAs := sGui.AddText("x+6 yp cFF9800 Hidden", "Requires Nastar.laf")
}
sGui.SetFont("s9 cFFFFFF", "Segoe UI")
sizes_savetypes := ["Ultimate Save As - Close Folders, Paper White, then Save As dialog", "Normal Save As - Save As dialog only"]
sGui.ddlSaveType := sGui.AddDropDownList("xm y+5 w" leftW " Choose" (_useUltimateSaveAs ? 1 : 2), sizes_savetypes)
sGui.reqSaveAs.Visible := (!ReqNastarEnabled && sGui.ddlSaveType.Value = 1)
sGui.ddlSaveType.OnEvent("Change", SaveSaveAsType)
CreateSettingsSaveResetRow(sGui, "xm", "y+8", btnW, SaveAutoSaveInterval, ResetAutoSaveInterval)


; ==========================================================
; HOLD THRESHOLD
; ==========================================================

cardRow3Y := cardRow3Y - 150

CreateSettingsCardHeader(sGui, "x" rightX, "y" cardRow3Y, rightW, "Hold Threshold (Capslock and Tab)"
    , "Hold time before CapsLock or Tab hold behavior becomes active. Output blocking stops the real Tab key or the CapsLock toggle from reaching CSP; toolkit hotkeys still work.", S(45))
sGui.chkCapsHold := sGui.AddCheckbox("x" rightX " y+5 cFFFFFF Background1E1F22 Checked", "Enable CapsLock hold")
sGui.chkCapsHold.Value := CapslockEnabled ? 1 : 0
sGui.chkTabHold := sGui.AddCheckbox("x" rightX " y+2 cFFFFFF Background1E1F22 Checked", "Enable Tab hold")
sGui.chkTabHold.Value := TabCombosEnabled ? 1 : 0
sGui.chkTabBlockPassthrough := sGui.AddCheckbox("x" rightX " y+2 cFFFFFF Background1E1F22 Checked", "Block Tab output")
sGui.chkTabBlockPassthrough.Value := _tabBlockPassthrough ? 1 : 0
sGui.chkCapsBlockOutput := sGui.AddCheckbox("x" rightX " y+2 cFFFFFF Background1E1F22", "Block CapsLock output")
sGui.chkCapsBlockOutput.Value := _capsBlockOutput ? 1 : 0
sGui.AddText("x" rightX " y+6 w" lblW, "Hold Time:")
sGui.edHoldThresh := sGui.AddEdit("xp+34 yp w" editW " c000000 BackgroundFFFFFF", HOLD_THRESHOLD_MS)
sGui.AddText("x+6 yp+1 cAAAAAA", "ms (20-500)")
sGui.chkCapsHold.OnEvent("Click", ToggleCapsHoldFromSettings)
sGui.chkTabHold.OnEvent("Click", ToggleTabHoldFromSettings)
sGui.chkTabBlockPassthrough.OnEvent("Click", ToggleTabBlockPassthrough)
sGui.chkCapsBlockOutput.OnEvent("Click", ToggleCapsBlockOutput)

CreateSettingsSaveResetRow(sGui, "x" rightX, "y+13", btnW, SaveHoldThreshold, ResetHoldThreshold, 6, 2, 2)
sGui.AddButton("x+6 yp-1 w" S(58) " h22", "Stress").OnEvent("Click", ShowHotkeyStressTest)

; --- Select Light Table Cell ---
CreateSettingsCardHeader(sGui, "x" rightX, "y+9", rightW, "Select Light Table Cell"
    , "Sets behavior when selecting a lightable cell.`n`nMode 1 (Reset LT Then Select):`n  Alt+A / Alt+D -> reset LT first, then select.`n  Ctrl+Alt+A / Ctrl+Alt+D -> select without resetting LT.`n`nMode 2 (Normal):`n  Alt+A / Alt+D -> normal CSP behavior (no LT reset).", S(15))
sGui.SetFont("s9 cFFFFFF", "Segoe UI")
sGui.AddText("x" rightX " y+5 w" lblW-30, "Mode:")
if !ReqNastarEnabled {
    sGui.SetFont("cFF9800", "Segoe UI")
    sGui.reqSelectCel := sGui.AddText("x+2 yp cFF9800", "Requires Nastar.laf")
}
else {
    sGui.reqSelectCel := sGui.AddText("x+2 yp cFF9800 Hidden", "Requires Nastar.laf")
}
modes := ["Reset LT Then Select", "Select Only"]
sGui.ddlSelectCel := sGui.AddDropDownList("x" rightX " y+5 w" editW*2+40 " Choose" _selectCelMode, modes)
sGui.SetFont("s8 cFFFFFF", "Segoe UI")
sGui.txtSelectCelInfo := sGui.AddText("x+6 yp+2 w150 cAAAAAA", _selectCelMode = 1 ? "Ctrl+Alt+A/D bypasses reset" : "Normal Alt+A/D (no LT reset)")
sGui.SetFont("s9 cFFFFFF", "Segoe UI")
sGui.reqSelectCel.Visible := (!ReqNastarEnabled && sGui.ddlSelectCel.Value = 1)
sGui.ddlSelectCel.OnEvent("Change", (*) => UpdateSelectCelInfo(sGui))
CreateSettingsSaveResetRow(sGui, "x" rightX, "y+14", btnW, SaveSelectCelMode, ResetSelectCelMode, 6, 2, 2)


; ==========================================================
; BOTTOM
; ==========================================================

sGui.AddText("xm y+14 w" (w - S(26)) " h1 Background444444")



sGui.AddButton("xm y+7 w108 h24 cFF9800", "Import JSON").OnEvent("Click", (*) => ImportConfigJSON())
sGui.AddButton("x+6 yp w150 h24 c80CBC4", "Import Mode Bundle").OnEvent("Click", ShowImportConfigChoice)
sGui.AddButton("x+8 yp  w101 h24", "Restore").OnEvent("Click", RestoreConfig)

btnHowTo := sGui.AddButton("x+8 yp w74 h24 ", "How To")
btnHowTo.OnEvent("Click", (*) => ShowLTSettingsHelp())

sGui.AddButton("x+6 yp w214 h24 cFFFFFF", "Recommended Shortcut").OnEvent("Click", ShowCSPRecommended)

sGui.AddButton("xm y+7 w108 h24 c4CAF50", "Export JSON").OnEvent("Click", (*) => ExportConfigJSON())
sGui.AddButton("x+6 yp w150 h24 c80CBC4", "Export Mode Bundle").OnEvent("Click", ExportSettingsBundle)
sGui.AddButton("x+8 yp w101 h24", "Backup").OnEvent("Click", BackupConfig)

sGui.AddButton("x+8 yp w74 h24", "Save All")
    .OnEvent("Click", SaveAllSettings)

sGui.AddButton("x+6 yp w74 h24", "Reset All")
    .OnEvent("Click", ResetSystemSettings)
sGui.AddButton("x+6 yp w133 h24", "OK")
    .OnEvent("Click", SaveAllSettingsAndClose)

sGui.edX.OnEvent("Change", UpdateLTPreview)
sGui.edY.OnEvent("Change", UpdateLTPreview)
sGui.edColor.OnEvent("Change", UpdateLTPreview)
for ctrl in [sGui.edX, sGui.edY, sGui.edLTX, sGui.edLTY, sGui.edC1X, sGui.edC1Y, sGui.edC2X, sGui.edC2Y]
    ctrl.OnEvent("Change", SettingsUpdateCoordAlerts)
ColorInfoRefreshSettingsUI(sGui.ddlCCMode)

sGui.Show("w" w " AutoSize")
btnHowTo.Focus()
UpdateLTPreview(sGui.edX)
SettingsUpdateCoordAlerts(sGui)
}

SystemSettingsSetupConfirm(parentGui) {
    snap := StartupHealthSnapshot()
    if snap["state"] != "SETUP"
        return true

    confirmed := false
    dlg := Gui("+AlwaysOnTop +ToolWindow +Owner" parentGui.Hwnd, "Finish First Run Setup?")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)
    dlg.AddText("xm cFFD54F", "Finish setup and leave SETUP mode?")
    dlg.AddText("xm y+" S(8) " w" S(430) " cAAAAAA",
        "Please confirm that you already finished the required CSP setup: shortcuts, AutoAction presets, and System Settings calibration. If you are not done yet, keep this window open.")
    dlg.AddButton("xm y+" S(14) " w" S(120) " h" S(28) " cFFFFFF Default", "Yes, Done").OnEvent("Click", (*) => (confirmed := true, dlg.Destroy()))
    dlg.AddButton("x+" S(8) " yp w" S(120) " h" S(28), "No, Keep Open").OnEvent("Click", (*) => dlg.Destroy())
    dlg.OnEvent("Close", (*) => (confirmed := false))
    dlg.Show("AutoSize")
    GuiWaitForCloseSafe(dlg)
    return confirmed
}

SystemSettingsMarkSetupComplete() {
    global FirstRunSetup, SETTINGS_FILE
    FirstRunSetup := false
    IniWrite(1, SETTINGS_FILE, "Settings", "SetupComplete")
    try EnsureSplitSettingsFiles()
    try SettingsSyncIniWatcher()
    UpdateStartupHealthBadge()
    DebugLog("First run setup marked complete")
}

SystemSettingsClose(parentGui, *) {
    if StartupHealthSnapshot()["state"] = "SETUP" {
        if !SystemSettingsSetupConfirm(parentGui)
            return true
        SystemSettingsSave(parentGui, false)
        SystemSettingsMarkSetupComplete()
    }
    parentGui.Destroy()
    return true
}

TestLTCoords(ctrl, *) {
    parentGui := ctrl.Gui
    expected := NormalizeLTColor(parentGui.edColor.Value)
    if expected < 0
        expected := NormalizeLTColor(parentGui.edColor.Text)
    if expected < 0
        expected := 0
    try c := PixelGetColor(Trim(parentGui.edX.Value), Trim(parentGui.edY.Value))
    catch
        c := 0
    c := NormalizeLTColor(c)
    parentGui.fndBox.Opt("Background" Format("{:06X}", c))
    parentGui.fndHex.Text := Format("#{:06X}", c)
    parentGui.expBox.Opt("Background" Format("{:06X}", expected))
        parentGui.expMatch.Text := (NormalizeLTColor(c) = NormalizeLTColor(expected)) ? "OK" : "NO"
    match := NormalizeLTColor(c) = NormalizeLTColor(expected)
    DllCall("InvalidateRect", "ptr", parentGui.Hwnd, "ptr", 0, "int", 1)
    DllCall("UpdateWindow", "ptr", parentGui.Hwnd)
    popup := Gui("+AlwaysOnTop +ToolWindow", "LT Test")
    popup.BackColor := "1E1F22"
    popup.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    popup.MarginX := S(12)
    popup.MarginY := S(12)
    popup.AddText("xm", "Pixel at (" parentGui.edX.Value ", " parentGui.edY.Value "):")
    popup.SetFont("s" S(20) " Bold", "Segoe UI")
    clrHex := Format("#{:06X}", c)
    matchText := match ? "OK Match!" : "NO Match"
    popup.AddText("xm y+8 c" (match ? "4CAF50" : "E53935"), clrHex "  " matchText)
    popup.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    popup.AddText("xm y+8", "Expected: " Format("#{:06X}", expected))
    popup.AddButton("xm y+10 w" S(80) " h" S(26), "OK").OnEvent("Click", (*) => popup.Destroy())
    popup.Show("AutoSize")
}

ResetLTCoords(ctrl, *) {
    gui := ctrl.Gui
    gui.edX.Value := 0
    gui.edY.Value := 0
    gui.edColor.Value := "#677187"
    gui.edLTX.Value := 0
    gui.edLTY.Value := 0
    gui.edC1X.Value := 0
    gui.edC1Y.Value := 0
    gui.edC2X.Value := 0
    gui.edC2Y.Value := 0
    gui.edCCX.Value := -20
    gui.edCCY.Value := 50
    if gui.HasProp("edCCTick")
        gui.edCCTick.Value := 60
    UpdateLTPreview(gui.edX)
    SettingsUpdateCoordAlerts(gui)
}

ResetLTDetect(ctrl, *) {
    gui := ctrl.Gui
    gui.edX.Value := 0
    gui.edY.Value := 0
    gui.edColor.Value := "#677187"
    UpdateLTPreview(gui.edX)
    SettingsUpdateCoordAlerts(gui)
}

ResetClickCoords(ctrl, *) {
    gui := ctrl.Gui
    gui.edLTX.Value := 0
    gui.edLTY.Value := 0
    gui.edC1X.Value := 0
    gui.edC1Y.Value := 0
    gui.edC2X.Value := 0
    gui.edC2Y.Value := 0
    SettingsUpdateCoordAlerts(gui)
}

ResetColorOffset(ctrl, *) {
    global _ccFollowCursor, _ccMiddlePickEnabled, _ccClipboardFormat, _ccTickMs
    try gui := ctrl.Gui
    catch
        gui := ctrl
    gui.edCCX.Value := -20
    gui.edCCY.Value := 50
    if gui.HasProp("edCCTick")
        gui.edCCTick.Value := 60
    gui.ddlCCMode.Value := 1
    gui.chkCCMiddle.Value := 0
    gui.ddlCCClipFmt.Value := 2
    _ccTickMs := 60
    ColorInfoSetTickMs(_ccTickMs, false)
    _ccFollowCursor := true
    _ccMiddlePickEnabled := false
    _ccClipboardFormat := "RGB"
    ColorInfoRefreshSettingsUI(gui.ddlCCMode)
}

ToggleCapsHoldFromSettings(ctrl, *) {
    global CapslockEnabled, _TypingState, SETTINGS_FILE
    CapslockEnabled := ctrl.Value ? true : false
    _TypingState["caps"] := false
    try IniWrite(CapslockEnabled ? 1 : 0, SETTINGS_FILE, "Settings", "CapslockEnabled")
    try SettingsSyncIniWatcher()
    try UpdateModeButtons()
    try HK_ReapplyCaps()
    DebugLog("CapsLock hold " (CapslockEnabled ? "ON" : "OFF"))
}

ToggleTabHoldFromSettings(ctrl, *) {
    global TabCombosEnabled, _TypingState, SETTINGS_FILE
    TabCombosEnabled := ctrl.Value ? true : false
    _TypingState["tab"] := false
    try IniWrite(TabCombosEnabled ? 1 : 0, SETTINGS_FILE, "Settings", "TabCombosEnabled")
    try SettingsSyncIniWatcher()
    try UpdateModeButtons()
    try HK_ReapplyAll()
    DebugLog("Tab hold " (TabCombosEnabled ? "ON" : "OFF"))
}

ToggleTabBlockPassthrough(ctrl, *) {
    global _tabBlockPassthrough, SETTINGS_FILE
    _tabBlockPassthrough := ctrl.Value ? true : false
    try IniWrite(_tabBlockPassthrough ? 1 : 0, SETTINGS_FILE, "Settings", "TabBlockPassthrough")
    try SettingsSyncIniWatcher()
    DebugLog("Tab block passthrough " (_tabBlockPassthrough ? "ON" : "OFF"))
}

ToggleCapsBlockOutput(ctrl, *) {
    global _capsBlockOutput, SETTINGS_FILE
    _capsBlockOutput := ctrl.Value ? true : false
    try IniWrite(_capsBlockOutput ? 1 : 0, SETTINGS_FILE, "Settings", "CapsBlockOutput")
    try SettingsSyncIniWatcher()
    DebugLog("CapsLock block output " (_capsBlockOutput ? "ON" : "OFF"))
}

ResetHoldThreshold(ctrl, *) {
    global HOLD_THRESHOLD_MS, _tabBlockPassthrough, _capsBlockOutput, CapslockEnabled, TabCombosEnabled, SETTINGS_FILE
    gui := ctrl.Gui
    HOLD_THRESHOLD_MS := 80
    _tabBlockPassthrough := false
    _capsBlockOutput := false
    CapslockEnabled := true
    TabCombosEnabled := true
    gui.edHoldThresh.Value := HOLD_THRESHOLD_MS
    if gui.HasProp("chkCapsHold")
        gui.chkCapsHold.Value := 1
    if gui.HasProp("chkTabHold")
        gui.chkTabHold.Value := 1
    if gui.HasProp("chkTabBlockPassthrough")
        gui.chkTabBlockPassthrough.Value := 0
    if gui.HasProp("chkCapsBlockOutput")
        gui.chkCapsBlockOutput.Value := 0
    try {
        IniWrite(HOLD_THRESHOLD_MS, SETTINGS_FILE, "Settings", "HoldThresholdMs")
        IniWrite(CapslockEnabled ? 1 : 0, SETTINGS_FILE, "Settings", "CapslockEnabled")
        IniWrite(TabCombosEnabled ? 1 : 0, SETTINGS_FILE, "Settings", "TabCombosEnabled")
        IniWrite(_tabBlockPassthrough ? 1 : 0, SETTINGS_FILE, "Settings", "TabBlockPassthrough")
        IniWrite(_capsBlockOutput ? 1 : 0, SETTINGS_FILE, "Settings", "CapsBlockOutput")
    }
    try SettingsSyncIniWatcher()
    try UpdateModeButtons()
    try HK_ReapplyAll()
}

UpdateLTPreview(ctrl, *) {
    parentGui := ctrl.Gui
    expected := NormalizeLTColor(parentGui.edColor.Value)
    if expected >= 0
        parentGui.expBox.Opt("Background" Format("{:06X}", expected))
    else
        parentGui.expBox.Opt("BackgroundFFFFFF")
    DllCall("InvalidateRect", "ptr", parentGui.Hwnd, "ptr", 0, "int", 1)
    DllCall("UpdateWindow", "ptr", parentGui.Hwnd)
    SettingsUpdateCoordAlerts(parentGui)
}

SettingsCoordIsZero(gui, xProp, yProp) {
    try x := Integer(Trim(gui.%xProp%.Value))
    catch
        x := 0
    try y := Integer(Trim(gui.%yProp%.Value))
    catch
        y := 0
    return x = 0 || y = 0
}

SettingsUpdateCoordAlerts(ctrlOrGui, *) {
    try gui := ctrlOrGui.Gui
    catch
        gui := ctrlOrGui
    if !IsObject(gui)
        return
    detectZero := SettingsCoordIsZero(gui, "edX", "edY")
    clickZero := SettingsCoordIsZero(gui, "edLTX", "edLTY")
        || SettingsCoordIsZero(gui, "edC1X", "edC1Y")
        || SettingsCoordIsZero(gui, "edC2X", "edC2Y")
    if gui.HasProp("ltDetectAlert")
        gui.ltDetectAlert.Visible := detectZero
    if gui.HasProp("ltClickAlert")
        gui.ltClickAlert.Visible := clickZero
}

PickCoord(label, xProp, yProp, updatePreview, ctrl, *) {
    gui := ctrl.Gui
    ctrl.Enabled := false
    oldText := ctrl.Text
    ctrl.Text := "..."
    ShowNotify("Pick Coordinate", "Click target: " label)
    ; Change cursor to crosshair during pick
    hCross := DllCall("LoadCursor", "ptr", 0, "ptr", 32515, "ptr")
    DllCall("SetSystemCursor", "ptr", hCross, "uint", 32512)
    KeyWait("LButton", "D")
    ; Restore system cursors before getting coords
    DllCall("SystemParametersInfo", "uint", 0x0057, "uint", 0, "ptr", 0, "uint", 0)
    MouseGetPos(&mx, &my)
    gui.%xProp%.Value := mx
    gui.%yProp%.Value := my
    if updatePreview
        UpdateLTPreview(gui.%xProp%)
    SettingsUpdateCoordAlerts(gui)
    KeyWait("LButton")
    try ctrl.Text := oldText
    try ctrl.Enabled := true
    DebugLog("Picked " label " coordinate: " mx "," my)
}

SaveLTDetect(ctrl, *) {
    global LT_X, LT_Y, LT_Color, SETTINGS_FILE
    _oldX := LT_X, _oldY := LT_Y
    try gui := ctrl.Gui
    catch
        gui := ctrl
    try {
        LT_X := Integer(Trim(gui.edX.Value))
        LT_Y := Integer(Trim(gui.edY.Value))
        LT_Color := NormalizeLTColor(gui.edColor.Value)
        if LT_Color < 0
            LT_Color := 0
    } catch
        return ShowNotify("LT Detection", "Invalid input")
    DebugLog("LT detect (" _oldX "," _oldY ") -> (" LT_X "," LT_Y ")")
    try {
        IniWrite(LT_X, SETTINGS_FILE, "LT", "X")
        IniWrite(LT_Y, SETTINGS_FILE, "LT", "Y")
        IniWrite(LT_Color, SETTINGS_FILE, "LT", "Color")
    }
    try SettingsSyncIniWatcher()
    SettingsUpdateCoordAlerts(gui)
}

SaveClickCoords(ctrl, *) {
    global LT_ClickX, LT_ClickY, ColorClick1X, ColorClick1Y, ColorClick2X, ColorClick2Y, SETTINGS_FILE
    _old := Map("LTx", LT_ClickX, "LTy", LT_ClickY, "C1x", ColorClick1X, "C1y", ColorClick1Y, "C2x", ColorClick2X, "C2y", ColorClick2Y)
    try gui := ctrl.Gui
    catch
        gui := ctrl
    try {
        LT_ClickX := Integer(Trim(gui.edLTX.Value))
        LT_ClickY := Integer(Trim(gui.edLTY.Value))
        ColorClick1X := Integer(Trim(gui.edC1X.Value))
        ColorClick1Y := Integer(Trim(gui.edC1Y.Value))
        ColorClick2X := Integer(Trim(gui.edC2X.Value))
        ColorClick2Y := Integer(Trim(gui.edC2Y.Value))
    } catch
        return ShowNotify("Click Coords", "Invalid input")
    DebugLog("Click coords LT (" _old["LTx"] "," _old["LTy"] ") -> (" LT_ClickX "," LT_ClickY "), Color1 (" _old["C1x"] "," _old["C1y"] ") -> (" ColorClick1X "," ColorClick1Y "), Color2 (" _old["C2x"] "," _old["C2y"] ") -> (" ColorClick2X "," ColorClick2Y ")")
    try {
        IniWrite(LT_ClickX, SETTINGS_FILE, "Coords", "LT_ClickX")
        IniWrite(LT_ClickY, SETTINGS_FILE, "Coords", "LT_ClickY")
        IniWrite(ColorClick1X, SETTINGS_FILE, "Coords", "Color1X")
        IniWrite(ColorClick1Y, SETTINGS_FILE, "Coords", "Color1Y")
        IniWrite(ColorClick2X, SETTINGS_FILE, "Coords", "Color2X")
        IniWrite(ColorClick2Y, SETTINGS_FILE, "Coords", "Color2Y")
    }
    try SettingsSyncIniWatcher()
    SettingsUpdateCoordAlerts(gui)
}

SaveColorOffset(ctrl, *) {
    global _ccOffsetX, _ccOffsetY, _ccTickMs, _ccFollowCursor, _ccMiddlePickEnabled, _ccClipboardFormat, _ccX, _ccY, SETTINGS_FILE
    _oldX := _ccOffsetX, _oldY := _ccOffsetY, _oldTick := _ccTickMs
    try gui := ctrl.Gui
    catch
        gui := ctrl
    try {
        _ccOffsetX := Integer(Trim(gui.edCCX.Value))
        _ccOffsetY := Integer(Trim(gui.edCCY.Value))
        tickVal := gui.HasProp("edCCTick") ? Integer(Trim(gui.edCCTick.Value)) : _ccTickMs
    } catch
        return ShowNotify("Color Offset", "Invalid input")
    _ccTickMs := Max(15, Min(1000, tickVal))
    if gui.HasProp("edCCTick")
        gui.edCCTick.Value := _ccTickMs
    _ccFollowCursor := gui.ddlCCMode.Value = 1
    _ccMiddlePickEnabled := gui.chkCCMiddle.Value = 1
    ColorInfoSetFollowMode(_ccFollowCursor, false)
    ColorInfoSetMiddlePick(_ccMiddlePickEnabled, false)
    ColorInfoSetClipboardFormat(gui.ddlCCClipFmt.Text, false)
    ColorInfoSetTickMs(_ccTickMs, false)
    DebugLog("Color Info offset (" _oldX "," _oldY ") -> (" _ccOffsetX "," _ccOffsetY "), tick " _oldTick " -> " _ccTickMs)
    IniWrite(_ccOffsetX, SETTINGS_FILE, "ColorInfo", "OffsetX")
    IniWrite(_ccOffsetY, SETTINGS_FILE, "ColorInfo", "OffsetY")
    IniWrite(_ccTickMs, SETTINGS_FILE, "ColorInfo", "TickMs")
    IniWrite(_ccFollowCursor ? 1 : 0, SETTINGS_FILE, "ColorInfo", "FollowCursor")
    IniWrite(_ccMiddlePickEnabled ? 1 : 0, SETTINGS_FILE, "ColorInfo", "MiddlePick")
    IniWrite(_ccClipboardFormat, SETTINGS_FILE, "ColorInfo", "ClipboardFormat")
    IniWrite(_ccX, SETTINGS_FILE, "ColorInfo", "X")
    IniWrite(_ccY, SETTINGS_FILE, "ColorInfo", "Y")
    try SettingsSyncIniWatcher()
}

ColorInfoRefreshSettingsUI(ctrl, *) {
    gui := IsObject(ctrl) && ctrl.HasProp("Gui") ? ctrl.Gui : ctrl
    if !IsObject(gui)
        return
    follow := gui.ddlCCMode.Value = 1
    if gui.HasProp("ccCurrent")
        gui.ccCurrent.Text := "Current: " (follow ? "Follow cursor" : "Draggable")
    gui.edCCX.Enabled := follow
    gui.edCCY.Enabled := follow
    gui.ccModeStatus.Text := follow
        ? "Offset active while following cursor.`nDraggable mode ignores X/Y offset."
        : "Draggable mode keeps the box where you place it.`nOffset is ignored."
    if gui.HasProp("ccPickStatus")
        gui.ccPickStatus.Text := (gui.chkCCMiddle.Value ? "PICKER" : "OFF")
            . " | " (gui.HasProp("ddlCCClipFmt") ? gui.ddlCCClipFmt.Text : "HEX")
}

SaveHoldThreshold(ctrl, *) {
    global HOLD_THRESHOLD_MS, _tabBlockPassthrough, _capsBlockOutput, CapslockEnabled, TabCombosEnabled, SETTINGS_FILE
    try gui := ctrl.Gui
    catch
        gui := ctrl
    try {
        hasCapsHoldCtrl := IsObject(gui) && gui.HasProp("chkCapsHold")
        hasTabHoldCtrl := IsObject(gui) && gui.HasProp("chkTabHold")
        if gui.HasProp("chkTabBlockPassthrough")
            _tabBlockPassthrough := gui.chkTabBlockPassthrough.Value ? true : false
        if gui.HasProp("chkCapsBlockOutput")
            _capsBlockOutput := gui.chkCapsBlockOutput.Value ? true : false
        n := Integer(Trim(gui.edHoldThresh.Value))
        HOLD_THRESHOLD_MS := n < 20 ? 20 : n > 500 ? 500 : n
        gui.edHoldThresh.Value := HOLD_THRESHOLD_MS
        if hasCapsHoldCtrl
            CapslockEnabled := gui.chkCapsHold.Value ? true : false
        if hasTabHoldCtrl
            TabCombosEnabled := gui.chkTabHold.Value ? true : false
        IniWrite(HOLD_THRESHOLD_MS, SETTINGS_FILE, "Settings", "HoldThresholdMs")
        if hasCapsHoldCtrl
            IniWrite(CapslockEnabled ? 1 : 0, SETTINGS_FILE, "Settings", "CapslockEnabled")
        if hasTabHoldCtrl
            IniWrite(TabCombosEnabled ? 1 : 0, SETTINGS_FILE, "Settings", "TabCombosEnabled")
        IniWrite(_tabBlockPassthrough ? 1 : 0, SETTINGS_FILE, "Settings", "TabBlockPassthrough")
        IniWrite(_capsBlockOutput ? 1 : 0, SETTINGS_FILE, "Settings", "CapsBlockOutput")
        try SettingsSyncIniWatcher()
        try UpdateModeButtons()
        try HK_ReapplyAll()
        DebugLog("Hold threshold set to " HOLD_THRESHOLD_MS "ms, CapsLock hold: " (CapslockEnabled ? "ON" : "OFF") ", Tab hold: " (TabCombosEnabled ? "ON" : "OFF") ", Tab block passthrough: " (_tabBlockPassthrough ? "ON" : "OFF") ", CapsLock block output: " (_capsBlockOutput ? "ON" : "OFF"))
    } catch
        return ShowNotify("Hold Threshold", "Invalid input")
}

ShowHotkeyStressTest(*) {
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Hotkey Stress Test")
    dlg.closed := false
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(12)
    dlg.MarginY := S(10)
    dlg.AddText("xm w" S(520) " cAAAAAA", "Live key transition monitor. Use it to test Tab/CapsLock hold timing, stuck modifiers, and mouse-button leaks.")
    dlg.SetFont("s" S(9) " cFFFFFF", "Consolas")
    status := dlg.AddText("xm y+" S(6) " w" S(520) " cFFD54F", "Status: stopped")
    logEd := dlg.AddEdit("xm y+" S(6) " w" S(520) " h" S(260) " ReadOnly -Wrap cFFFFFF Background111216", "")
    keyNames := ["Tab", "CapsLock", "Space", "LControl", "RControl", "LShift", "RShift", "LAlt", "RAlt", "LWin", "RWin", "LButton", "RButton", "MButton", "``", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "="]
    states := Map()
    for _, k in keyNames
        states[k] := GetKeyState(k, "P") ? 1 : 0
    append(line) {
        if dlg.closed || !SafeGuiHwnd(dlg) {
            SetTimer(poll, 0)
            return false
        }
        try current := logEd.Value
        catch {
            dlg.closed := true
            SetTimer(poll, 0)
            return false
        }
        try logEd.Value := FormatTime(, "HH:mm:ss.") SubStr(A_MSec + 1000, 2) "  " line "`r`n" current
        catch {
            dlg.closed := true
            SetTimer(poll, 0)
            return false
        }
        return true
    }
    tick := 0
    firedShown := false
    firedCursor := 0
    poll(*) {
        for _, k in keyNames {
            cur := GetKeyState(k, "P") ? 1 : 0
            if cur != states[k] {
                states[k] := cur
                append(k " " (cur ? "DOWN" : "UP"))
            }
        }
        if firedShown {
            n := _FiredLog.Length
            if n > firedCursor {
                Loop n - firedCursor
                    append("[fired] " _FiredLog[firedCursor + A_Index])
                firedCursor := n
            }
        }
    }
    toggleFired(*) {
        firedShown := !firedShown
        firedBtn.Text := firedShown ? "Fired: ON" : "Fired: OFF"
        if firedShown
            firedCursor := _FiredLog.Length
        if dlg.closed || !SafeGuiHwnd(dlg)
            return
        append(firedShown ? "FIRED MONITOR ON" : "FIRED MONITOR OFF")
    }
    start(*) {
        if dlg.closed || !SafeGuiHwnd(dlg)
            return
        status.Text := "Status: running  | Hold Threshold: " HOLD_THRESHOLD_MS "ms"
        SetTimer(poll, 35)
        firedCursor := _FiredLog.Length
        append("START")
    }
    stop(*) {
        SetTimer(poll, 0)
        if dlg.closed || !SafeGuiHwnd(dlg)
            return
        status.Text := "Status: stopped"
        append("STOP")
    }
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.AddButton("xm y+" S(8) " w" S(72) " h" S(26), "Start").OnEvent("Click", start)
    dlg.AddButton("x+6 yp w" S(72) " h" S(26), "Stop").OnEvent("Click", stop)
    dlg.AddButton("x+6 yp w" S(72) " h" S(26), "Clear").OnEvent("Click", (*) => (dlg.closed || !SafeGuiHwnd(dlg) ? 0 : (logEd.Value := "")))
    firedBtn := dlg.AddButton("x+6 yp w" S(72) " h" S(26), "Fired: OFF")
    firedBtn.OnEvent("Click", toggleFired)
    btnClose := dlg.AddButton("x+6 yp w" S(72) " h" S(26), "Close")
    cleanup(*) {
        if dlg.closed
            return
        dlg.closed := true
        SetTimer(poll, 0)
        try dlg.Destroy()
    }
    btnClose.OnEvent("Click", cleanup)
    dlg.OnEvent("Close", cleanup)
    dlg.Show("AutoSize")
    btnClose.Focus()
    start()
}

SaveSelectCelMode(ctrl, *) {
    global _selectCelMode, SETTINGS_FILE
    gui := ctrl.Gui
    _selectCelMode := gui.ddlSelectCel.Value
    IniWrite(_selectCelMode, SETTINGS_FILE, "Settings", "SelectCelMode")
    try SettingsSyncIniWatcher()
    DebugLog("Select Light Table Cell mode set to " _selectCelMode)
}
ResetSelectCelMode(ctrl, *) {
    global _selectCelMode, SETTINGS_FILE
    gui := ctrl.Gui
    _selectCelMode := 1
    gui.ddlSelectCel.Choose(1)
    UpdateSelectCelInfo(gui)
    IniWrite(_selectCelMode, SETTINGS_FILE, "Settings", "SelectCelMode")
    try SettingsSyncIniWatcher()
}

UpdateSelectCelInfo(gui) {
    global ReqNastarEnabled
    if !IsObject(gui) || !gui.HasProp("ddlSelectCel") || !gui.HasProp("txtSelectCelInfo")
        return
    gui.txtSelectCelInfo.Text := gui.ddlSelectCel.Value = 1 ? "Ctrl+Alt+A/D bypasses reset" : "Normal Alt+A/D (no LT reset)"
    SystemSettingsRefreshRequirementHints(gui)
}

SystemSettingsRefreshRequirementHints(gui) {
    global ReqNastarEnabled
    if !IsObject(gui)
        return
    nastarOn := ReqNastarEnabled
    try {
        if gui.HasProp("chkNastar")
            nastarOn := !!gui.chkNastar.Value
    }
    if gui.HasProp("reqSaveAs") && gui.HasProp("ddlSaveType")
        gui.reqSaveAs.Visible := (!nastarOn && gui.ddlSaveType.Value = 1)
    if gui.HasProp("reqSelectCel") && gui.HasProp("ddlSelectCel")
        gui.reqSelectCel.Visible := (!nastarOn && gui.ddlSelectCel.Value = 1)
}

SaveAutoSaveInterval(ctrl, *) {
    global AutoSaveInterval, SETTINGS_FILE
    try gui := ctrl.Gui
    catch
        gui := ctrl
    try {
        n := Integer(gui.edAutoSave.Value)
        AutoSaveInterval := n < 10 ? 10 : n > 3600 ? 3600 : n
        SetTimer(DoAutoSave, AutoSaveInterval * 1000)
        IniWrite(AutoSaveInterval, SETTINGS_FILE, "Settings", "AutoSaveInterval")
        try SettingsSyncIniWatcher()
        DebugLog("Auto save interval set to " AutoSaveInterval "s")
    } catch
        return ShowNotify("Auto Save", "Invalid input")
}

ResetAutoSaveInterval(ctrl, *) {
    global AutoSaveInterval, _useUltimateSaveAs, SETTINGS_FILE
    gui := ctrl.Gui
    AutoSaveInterval := 60
    _useUltimateSaveAs := true
    gui.edAutoSave.Value := AutoSaveInterval
    if gui.HasProp("ddlSaveType")
        gui.ddlSaveType.Value := 1
    SystemSettingsRefreshRequirementHints(gui)
    IniWrite(AutoSaveInterval, SETTINGS_FILE, "Settings", "AutoSaveInterval")
    IniWrite(1, SETTINGS_FILE, "Settings", "UseUltimateSaveAs")
    try SettingsSyncIniWatcher()
}

SaveTooltipDelay(ctrl, *) {
    global _HoverState, SETTINGS_FILE
    try gui := ctrl.Gui
    catch
        gui := ctrl
    try {
        enabled := gui.HasProp("chkTooltip") ? gui.chkTooltip.Value : _HoverState.Get("enabled", true)
        delay := gui.HasProp("edTooltipDelay") ? Integer(gui.edTooltipDelay.Value) : _HoverState.Get("delay", 500)
        _HoverState["enabled"] := !!enabled
        _HoverState["delay"] := Max(0, Min(2000, delay))
        IniWrite(_HoverState["enabled"] ? 1 : 0, SETTINGS_FILE, "Settings", "TooltipEnabled")
        IniWrite(_HoverState["delay"], SETTINGS_FILE, "Settings", "TooltipDelay")
        try SettingsSyncIniWatcher()
        DebugLog("Tooltip settings saved: enabled=" _HoverState["enabled"] " delay=" _HoverState["delay"])
    } catch
        return ShowNotify("Tooltip", "Invalid input")
}

ResetTooltipDelay(ctrl, *) {
    global _HoverState, SETTINGS_FILE
    gui := ctrl.Gui
    _HoverState["enabled"] := true
    _HoverState["delay"] := 500
    if gui.HasProp("chkTooltip")
        gui.chkTooltip.Value := 1
    if gui.HasProp("edTooltipDelay")
        gui.edTooltipDelay.Value := 500
    IniWrite(1, SETTINGS_FILE, "Settings", "TooltipEnabled")
    IniWrite(500, SETTINGS_FILE, "Settings", "TooltipDelay")
    try SettingsSyncIniWatcher()
}

SaveSaveAsType(ctrl, *) {
    global _useUltimateSaveAs, ReqNastarEnabled, SETTINGS_FILE
    gui := ctrl.Gui
    SystemSettingsRefreshRequirementHints(gui)
    if ctrl.Value = 1 && !ReqNastarEnabled
        ShowNotify("Save As Mode", "Ultimate Save As requires Nastar.laf", "0xFF9800")
    _useUltimateSaveAs := ctrl.Value = 1
    IniWrite(_useUltimateSaveAs ? 1 : 0, SETTINGS_FILE, "Settings", "UseUltimateSaveAs")
    try SettingsSyncIniWatcher()
}

SaveAllSettings(ctrl, *) {
    SystemSettingsSave(ctrl, false)
}

SaveAllSettingsAndClose(ctrl, *) {
    gui := ctrl.Gui
    if !SystemSettingsSetupConfirm(gui)
        return
    SystemSettingsSave(gui, false)
    SystemSettingsMarkSetupComplete()
    gui.Destroy()
}
