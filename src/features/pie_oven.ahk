;FEATURES - Pie Oven
; ============================================================

ShowPieOven(*) {
    global PieCount, PieHotkeys, PieNames, PieEnabled, _pieDelayMs, _pieDeadzone, _pieStyle, _pieQuickHintsVisible, _pieQuickSlotHintsPos, _pieQuickHintCount, SubPieConfigs, SubPieNames, _PieOvenGui
    static pGui := 0
    if IsObject(pGui) {
        try if pGui.Hwnd {
            RefreshPieSystemControls(pGui)
            pGui.Show()
            return
        }
    }
    PieEnsureSubPie(1)
    pGui := Gui("+AlwaysOnTop +ToolWindow", "Pie Oven - " ModeSettingsActiveName())
    _PieOvenGui := pGui
    pGui.BackColor := "1E1F22"
    pGui.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    pGui.MarginX := S(14)
    pGui.MarginY := S(12)

    pGui.AddText("xm cFFFFFF", "Pie Oven")
    pGui.AddText("xm y+2 w" S(410) " h1 Background555555")
    pGui.SetFont("s" S(8) " cAAAAAA", "Segoe UI")
    pGui.AddText("xm y+5 w" S(410), "Pie menus, open hotkeys, hover behavior, and sub-pies in one place.")
    pGui.modeLabel := pGui.AddText("xm y+4 w" S(410) " cFFD54F", "Mode: " ModeSettingsActiveName())
    AddHoverPopup(pGui.modeLabel, "Editing mode: " ModeSettingsActiveName() "`nPie menus are stored per mode; this oven edits the active mode's pie settings.")

    pGui.SetFont("s" S(8) " cFFFFFF", "Segoe UI")
    pGui.AddText("xm y+10 w" S(34), "Delay:")
    pGui.edPieDelay := pGui.AddEdit("x+4 yp w" S(44) " h20 c000000 BackgroundFFFFFF", _pieDelayMs)
    pGui.AddText("x+12 yp w" S(34), "Dead:")
    pGui.edPieDeadzone := pGui.AddEdit("x+4 yp w" S(44) " h20 c000000 BackgroundFFFFFF", _pieDeadzone)
    pGui.AddText("x+12 yp w" S(34), "Style:")
    pGui.ddlPieStyle := pGui.AddDropDownList("x+4 yp w" S(70), ["Normal", "Left", "Right"])
    pGui.ddlPieStyle.Value := PieStyleValue(_pieStyle)
    pGui.AddText("x+12", "Show:")
    pGui.edQuickHintCount := pGui.AddEdit("x+6 yp-1 w" S(42) " h20 c000000 BackgroundFFFFFF", _pieQuickHintCount)
    pGui.AddText("x+5 yp+1 cAAAAAA", "hints")
    pGui.AddText("xm y+" S(15) " cAAAAAA", "Quick key hints position:")
    pGui.ddlQuickSlotPos := pGui.AddDropDownList("x+21 yp-1 w" S(278), ["Top-Left", "Top-Center", "Top-Right", "Bottom-Left", "Bottom-Center", "Bottom-Right"])
    pGui.ddlQuickSlotPos.Value := PieQuickSlotPosIndex(_pieQuickSlotHintsPos)
    pGui.ddlQuickSlotPos.OnEvent("Change", PieQuickSlotPosChanged)
    pGui.chkQuickHints := pGui.AddCheckbox("xm y+9 cFFFFFF Background1E1F22", "Show Pie Quick hints when pie opens")
    pGui.chkQuickHints.Value := _pieQuickHintsVisible ? 1 : 0
    pGui.AddButton("x+10 yp-1 w" S(90) " h20", "Pie Quick").OnEvent("Click", ShowPieQuickHotkeys)
    pGui.btnGlobalSave := pGui.AddButton("x+10 yp w" S(50) " h20", "Save")
    pGui.btnGlobalReset := pGui.AddButton("x+5 yp w" S(50) " h20", "Reset")
    pGui.AddText("xm y+6 w" S(410) " c888888", "Delay = hover wait time in ms before a slot runs. Dead = center deadzone in px before hover tracking starts.")
    pGui.AddText("xm y+3 w" S(410) " c888888", "Pie Quick hints show active quick keys at the bottom of the open pie.")
    pGui.AddText("xm y+5 w" S(410) " h1 Background555555")

    pGui.pieEnabledDds := []
    pGui.pieNameEdits := []
    pGui.pieHotkeyEdits := []
    pGui.pieHotkeyDisplays := []
    pGui.pieHotkeyButtons := []
    pGui.pieEditButtons := []
    pGui.pieTestButtons := []
    pGui.pieSaveButtons := []
    pGui.pieResetButtons := []
    pGui.pieHotkeyValues := []
    Loop 4 {
        p := A_Index
        pGui.AddText("xm y+10 w" S(34), "Pie " p ":")
        enabledDd := pGui.AddDropDownList("x+4 yp w" S(76), ["Enabled", "Disabled"])
        enabledDd.Value := PieIsEnabled(p) ? 1 : 2
        nameVal := PieNames.Length >= p ? PieNames[p] : PieDefaultName(p)
        pGui.pieEnabledDds.Push(enabledDd)
        val := PieHotkeys.Length >= p ? PieNormalizeHotkey(PieHotkeys[p]) : ""
        ed := pGui.AddEdit("x+0 yp w1 h1 Hidden", val)
        pGui.AddText("x+10 yp w" S(40), "Hotkey:")
        hkBtn := pGui.AddButton("x+7 yp-1 w" S(88) " h22", PieHotkeyButtonText(val))
        setBtn := pGui.AddButton("x+7 yp-1 w" S(69) " h22", "Edit")
        testBtn := pGui.AddButton("x+5 yp w" S(69) " h22", "Test")
        pGui.pieNameEdits.Push(pGui.AddEdit("xm+38 y+6 w" S(222) " c000000 BackgroundFFFFFF", nameVal))
        saveBtn := pGui.AddButton("x+7 yp-1 w" S(69) " h22", "Save")
        resetBtn := pGui.AddButton("x+5 yp w" S(69) " h22", "Reset")
        enabledDd.OnEvent("Change", PieOvenRowEnabledChanged.Bind(pGui, p))
        ed.OnEvent("Change", PieHotkeyEditChanged.Bind(hkBtn))
        hkBtn.OnEvent("Click", PieHotkeyPopup.Bind(ed, hkBtn, p))
        setBtn.OnEvent("Click", ShowPieSettings.Bind(p))
        testBtn.OnEvent("Click", PieOvenTestSingle.Bind(pGui, p))
        saveBtn.OnEvent("Click", PieOvenSaveSingle.Bind(pGui, p))
        resetBtn.OnEvent("Click", PieOvenResetSingle.Bind(pGui, p))
        pGui.pieHotkeyEdits.Push(ed)
        pGui.pieHotkeyDisplays.Push(hkBtn)
        pGui.pieHotkeyButtons.Push(hkBtn)
        pGui.pieEditButtons.Push(setBtn)
        pGui.pieTestButtons.Push(testBtn)
        pGui.pieSaveButtons.Push(saveBtn)
        pGui.pieResetButtons.Push(resetBtn)
        pGui.pieHotkeyValues.Push(val)
    }
    pGui.btnGlobalSave.OnEvent("Click", (*) => PieOvenSaveGlobal(pGui))
    pGui.btnGlobalReset.OnEvent("Click", (*) => PieOvenResetGlobal(pGui))

    pGui.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    pGui.AddText("xm y+10 cFFFFFF", "Sub Pie")
    pGui.AddText("xm y+2 w" S(410) " h1 Background555555")
    pGui.SetFont("s" S(8) " cAAAAAA", "Segoe UI")
    pGui.AddText("xm y+5 w" S(410), "Create nested pie menus and assign them to slots with Type = submenu.")
    pGui.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    pGui._subCurIdx := 1
    pGui._subNavBusy := false
    pGui.subPrev := pGui.AddButton("xm y+10 w" S(28) " h" S(24) " Center", Chr(0x25C0))
    pGui.subDd := pGui.AddDropDownList("x+4 yp w" S(346), PieSubPieChoices())
    pGui.subDd.Value := 1
    pGui.subNext := pGui.AddButton("x+4 yp w" S(28) " h" S(24) " Center", Chr(0x25B6))
    pGui.AddButton("xm y+8 w" S(70) " h" S(24), "Add").OnEvent("Click", PieOvenAddSubPie.Bind(pGui))
    pGui.AddButton("x+6 yp w" S(70) " h" S(24), "Delete").OnEvent("Click", PieOvenDeleteSubPie.Bind(pGui))
    pGui.AddButton("x+6 yp w" S(103) " h" S(24), "Edit Sub").OnEvent("Click", (*) => ShowSubPieSettings(pGui._subCurIdx))
    pGui.subPreview := pGui.AddButton("x+6 yp w" S(70) " h" S(24), "Preview")
    pGui.subTest := pGui.AddButton("x+6 yp w" S(70) " h" S(24), "Test")
    pGui.subExport := pGui.AddButton("xm y+7 w" S(70) " h" S(24) " c4CAF50", "Export Sub")
    pGui.subImport := pGui.AddButton("x+6 yp w" S(70) " h" S(24) " cFF9800", "Import Sub")
    OvenNavTo(idx) {
        global SubPieConfigs
        idx := Max(1, Min(idx, SubPieConfigs.Length))
        if idx = pGui._subCurIdx
            return
        pGui._subCurIdx := idx
        pGui._subNavBusy := true
        pGui.subDd.Value := idx
        pGui._subNavBusy := false
    }
    pGui.subPrev.OnEvent("Click", (*) => OvenNavTo(pGui._subCurIdx - 1))
    pGui.subNext.OnEvent("Click", (*) => OvenNavTo(pGui._subCurIdx + 1))
    pGui.subDd.OnEvent("Change", (*) => (pGui._subNavBusy ? 0 : OvenNavTo(pGui.subDd.Value)))
    pGui.subPreview.OnEvent("Click", (*) => PieOvenPreviewSub(pGui, pGui._subCurIdx))
    pGui.subTest.OnEvent("Click", (*) => PieOvenTestSub(pGui, pGui._subCurIdx))
    pGui.subExport.OnEvent("Click", (*) => ExportSubPie(pGui._subCurIdx))
    pGui.subImport.OnEvent("Click", (*) => ImportSubPie(pGui._subCurIdx))

    pGui.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    pGui.AddText("xm y+12 cFFFFFF", "Action Preview")
    pGui.SetFont("s" S(8) " cAAAAAA", "Segoe UI")
    pGui.AddText("xm y+3 w" S(410), "Inspect a pie slot without opening the editor.")
    pGui.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    previewData := PieOvenPreviewChoices()
    pGui.previewTargets := previewData.targets
    pGui.previewPieDd := pGui.AddDropDownList("xm y+6 w" S(160), previewData.choices)
    pGui.previewPieDd.Value := 1
    slotChoices := []
    Loop 10
        slotChoices.Push(A_Index = 10 ? "0 | " PieSlotName(10) : A_Index " | " PieSlotName(A_Index))
    pGui.previewSlotDd := pGui.AddDropDownList("x+6 yp w" S(116), slotChoices)
    pGui.previewSlotDd.Value := 1
    pGui.AddButton("x+6 yp-1 w" S(58) " h22", "Refresh").OnEvent("Click", (*) => PieOvenRefreshActionPreview(pGui))
    pGui.previewText := pGui.AddEdit("xm y+6 w" S(410) " h" S(76) " ReadOnly -Wrap HScroll c000000 BackgroundFFFFFF", "")
    pGui.previewPieDd.OnEvent("Change", (*) => PieOvenRefreshActionPreview(pGui))
    pGui.previewSlotDd.OnEvent("Change", (*) => PieOvenRefreshActionPreview(pGui))

    pGui.AddText("xm y+13 w" S(414) " h1 Background444444")
    pGui.AddButton("xm y+8 w" S(58) " h24", "Save").OnEvent("Click", SavePieSettingsOnly)
    pGui.AddButton("x+6 yp w" S(58) " h24", "Reset").OnEvent("Click", ResetPieSettingsOnly)
    pGui.AddButton("x+6 yp w" S(58) " h24", "Export").OnEvent("Click", ExportPieSettings)
    pGui.AddButton("x+6 yp w" S(58) " h24", "Import").OnEvent("Click", ImportPieSettings)
    pGui.AddButton("x+6 yp w" S(88) " h24", "Recommend").OnEvent("Click", ShowCSPRecommended)
    btnClose := pGui.AddButton("x+6 yp w" S(56) " h24", "Close")
    btnClose.OnEvent("Click", (*) => pGui.Destroy())
    PieOvenRefreshRowStates(pGui)
    PieOvenRefreshActionPreview(pGui)
    pGui.Show("AutoSize")
    btnClose.Focus()
}

PieOvenAddSubPie(guiObj, *) {
    newIdx := PieAddSubPie()
    if IsObject(guiObj) {
        guiObj._subCurIdx := newIdx
        guiObj._subNavBusy := true
        ch := PieSubPieChoices()
        guiObj.subDd.Delete()
        for c in ch
            guiObj.subDd.Add([c])
        guiObj.subDd.Value := Min(guiObj._subCurIdx, ch.Length > 0 ? ch.Length : 1)
        guiObj._subNavBusy := false
        PieOvenRefreshPreviewTargets(guiObj)
    }
}

PieOvenDeleteSubPie(guiObj, *) {
    global SubPieConfigs, SubPieNames
    if SubPieConfigs.Length <= 1 {
        ShowNotify("Sub Pie", "Keep at least one sub pie.", "0xE53935")
        return
    }
    idx := IsObject(guiObj) ? guiObj._subCurIdx : 1
    idx := Max(1, Min(idx, SubPieConfigs.Length))
    cDlg := Gui("+AlwaysOnTop +ToolWindow", "Delete Sub Pie")
    cDlg.BackColor := "1E1F22"
    cDlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    cDlg.MarginX := S(14)
    cDlg.MarginY := S(14)
    cDlg.AddText("cFFD54F", "Delete Sub Pie " idx "?")
    cDlg.AddText("xm y+" S(4) " cAAAAAA", SubPieNames.Length >= idx ? SubPieNames[idx] : SubPieDefaultName(idx))
    cDlg.AddText("xm y+" S(4) " c888888", "Main pie slots that used it will be moved to the nearest remaining sub pie.")
    delResult := false
    cDlg.AddButton("xm y+10 w" S(80) " h" S(26) " cFFFFFF", "Yes").OnEvent("Click", (*) => (delResult := true, cDlg.Destroy()))
    cDlg.AddButton("x+8 yp w" S(80) " h" S(26), "No").OnEvent("Click", (*) => cDlg.Destroy())
    cDlg.Show("AutoSize")
    GuiWaitForCloseSafe(cDlg)
    if !delResult
        return
    ShowNotify("Sub Pie", "Deleting Sub Pie " idx, "0x4CAF50")
    if PieDeleteSubPie(idx) {
        if IsObject(guiObj) {
            guiObj._subCurIdx := Min(idx, SubPieConfigs.Length)
            guiObj._subNavBusy := true
            ch := PieSubPieChoices()
            guiObj.subDd.Delete()
            for c in ch
                guiObj.subDd.Add([c])
            guiObj.subDd.Value := Min(guiObj._subCurIdx, ch.Length > 0 ? ch.Length : 1)
            guiObj._subNavBusy := false
            PieOvenRefreshPreviewTargets(guiObj)
            ShowNotify("Sub Pie", "Deleted Sub Pie " idx)
        }
    }
}

PieOvenPreviewChoices() {
    global PieNames, SubPieConfigs, SubPieNames
    PieEnsureSubPie(1)
    choices := []
    targets := []
    Loop 4 {
        p := A_Index
        name := PieNames.Length >= p ? PieNames[p] : PieDefaultName(p)
        choices.Push("Pie " p " - " name)
        targets.Push({kind:"pie", index:p})
    }
    Loop SubPieConfigs.Length {
        s := A_Index
        name := SubPieNames.Length >= s ? SubPieNames[s] : SubPieDefaultName(s)
        choices.Push("Sub " s " - " name)
        targets.Push({kind:"sub", index:s})
    }
    return {choices:choices, targets:targets}
}

PieOvenRefreshPreviewTargets(guiObj) {
    if !IsObject(guiObj) || !guiObj.HasProp("previewPieDd")
        return
    oldValue := guiObj.previewPieDd.Value
    previewData := PieOvenPreviewChoices()
    guiObj.previewTargets := previewData.targets
    guiObj.previewPieDd.Delete()
    for choice in previewData.choices
        guiObj.previewPieDd.Add([choice])
    guiObj.previewPieDd.Value := Max(1, Min(oldValue, previewData.choices.Length))
    PieOvenRefreshActionPreview(guiObj)
}

PieOvenRefreshActionPreview(guiObj, *) {
    global PieConfigs, PieNames, SubPieConfigs, SubPieNames
    if !IsObject(guiObj) || !guiObj.HasProp("previewText")
        return
    targetIdx := guiObj.HasProp("previewPieDd") ? guiObj.previewPieDd.Value : 1
    slotIdx := guiObj.HasProp("previewSlotDd") ? guiObj.previewSlotDd.Value : 1
    slotIdx := Max(1, Min(10, slotIdx))
    target := ""
    if guiObj.HasProp("previewTargets") && IsObject(guiObj.previewTargets) && guiObj.previewTargets.Length >= targetIdx
        target := guiObj.previewTargets[targetIdx]
    if !IsObject(target)
        target := {kind:"pie", index:1}
    if target.kind = "sub" {
        subIdx := PieEnsureSubPie(target.index)
        cfg := SubPieConfigs[subIdx]
        pieName := SubPieNames.Length >= subIdx ? SubPieNames[subIdx] : SubPieDefaultName(subIdx)
        sourceLabel := "Sub " subIdx
    } else {
        pieIdx := Max(1, Min(4, target.index))
        while PieConfigs.Length < pieIdx
            PieConfigs.Push(PieDefaultConfig(PieConfigs.Length + 1))
        cfg := PieConfigs[pieIdx]
        pieName := PieNames.Length >= pieIdx ? PieNames[pieIdx] : PieDefaultName(pieIdx)
        sourceLabel := "Pie " pieIdx
    }
    if !IsObject(cfg) || cfg.Length < slotIdx {
        guiObj.previewText.Value := sourceLabel " / Slot " slotIdx "`r`nNo slot data found."
        return
    }
    item := cfg[slotIdx]
    if !IsObject(item) {
        guiObj.previewText.Value := sourceLabel " / Slot " slotIdx "`r`nInvalid slot data."
        return
    }
    label := item.Get("label", "Slot " slotIdx)
    guiObj.previewText.Value := sourceLabel " - " pieName " / " (slotIdx = 10 ? "0" : slotIdx) " | " label "`r`n"
        . PieEditorActionSummary(
            item.Get("type", "disabled"),
            item.Get("action", ""),
            label,
            item.Get("requirement", ""),
            item.Get("subPie", 1),
            item.Get("enabled", 1)
        )
}

SettingsProgressStart(title, message := "Working...", value := 0) {
    dlg := Gui("+AlwaysOnTop +ToolWindow -MinimizeBox", title)
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(12)
    dlg.msg := dlg.AddText("xm w" S(280) " cFFFFFF", message)
    dlg.bar := dlg.AddProgress("xm y+" S(8) " w" S(280) " h" S(16) " Range0-100 Background2D2D32 c4CAF50", value)
    dlg.Show("AutoSize NoActivate")
    Sleep(20)
    return dlg
}

SettingsProgressStep(dlg, message, value := "") {
    if !IsObject(dlg)
        return
    try {
        dlg.msg.Text := message
        if value != ""
            dlg.bar.Value := value
        dlg.Show("NoActivate")
        Sleep(20)
    }
}

SettingsProgressClose(dlg) {
    if IsObject(dlg) {
        try dlg.Destroy()
    }
}

SystemSettingsSave(ctrl, closeAfter := false) {
    global SETTINGS_FILE, ReqAnimationEnabled, ReqNastarEnabled
    try gui := ctrl.Gui
    catch
        gui := ctrl
    reqAnimValue := gui.chkAnim.Value
    reqNastarValue := gui.chkNastar.Value
    progress := SettingsProgressStart("System Settings", "Preparing save...", 5)
    try {
        if FileExist(SETTINGS_FILE) {
            SettingsProgressStep(progress, "Creating backup...", 15)
            CreateSettingsSnapshotBeforeSave("system")
        }
        SettingsProgressStep(progress, "Saving calibration settings...", 35)
        SaveLTDetect(gui)
        SaveClickCoords(gui)
        SaveColorOffset(gui)
        SaveHoldThreshold(gui)
        SaveAutoSaveInterval(gui)
        SaveTooltipDelay(gui)
        ReqAnimationEnabled := reqAnimValue
        ReqNastarEnabled := reqNastarValue
        if gui.HasProp("ddlSaveType")
            SaveSaveAsType(gui.ddlSaveType)
        if gui.HasProp("ddlSelectCel")
            SaveSelectCelMode(gui.ddlSelectCel)
        SettingsProgressStep(progress, "Saving preset requirements...", 60)
        IniWrite(ReqAnimationEnabled, SETTINGS_FILE, "Settings", "ReqAnimation")
        IniWrite(ReqNastarEnabled, SETTINGS_FILE, "Settings", "ReqNastar")
        try SettingsSyncIniWatcher()
        SettingsProgressStep(progress, "Reapplying hotkeys...", 82)
        HK_ReapplyAll()
        HK_RefreshSettingsList()
        try RefreshIBRequirementState()
        _RebuildColorGui()
        _RebuildLinkGui()
        try EnsureSplitSettingsFiles()
        try SettingsSyncIniWatcher()
        try UpdateStartupHealthBadge()
        SettingsProgressStep(progress, "Done.", 100)
    } finally {
        SettingsProgressClose(progress)
    }
    ShowNotify("System Settings", "Saved")
    if closeAfter
        gui.Destroy()
}

SavePieSystemSettings(ctrl, *) {
    global PieCount, PieHotkeys, PieConfigs, PieNames, PieEnabled, _pieDelayMs, _pieDeadzone, _pieStyle, _pieQuickHintsVisible, _pieQuickSlotHintsPos, _pieQuickHintCount
    try {
    gui := ctrl.Gui
    oldCount := PieCount
    oldNames := PieNames.Clone()
    oldEnabled := IsObject(PieEnabled) ? PieEnabled.Clone() : []
    _pieDelayMs := PieSafeInt(gui.edPieDelay.Value, 65, 0, 1000)
    _pieDeadzone := PieSafeInt(gui.edPieDeadzone.Value, 42, 0, 200)
    if gui.HasProp("ddlPieStyle")
        _pieStyle := PieNormalizeStyle(gui.ddlPieStyle.Text)
    if gui.HasProp("chkQuickHints")
        _pieQuickHintsVisible := gui.chkQuickHints.Value ? 1 : 0
    if gui.HasProp("ddlQuickSlotPos")
        _pieQuickSlotHintsPos := PieQuickSlotPosNorm(gui.ddlQuickSlotPos.Text)
    if gui.HasProp("edQuickHintCount")
        _pieQuickHintCount := PieSafeInt(gui.edQuickHintCount.Value, 20, 1, 99)
    newEnabled := []
    newHotkeys := []
    newNames := []
    Loop 4 {
        p := A_Index
        enabledVal := gui.HasProp("pieEnabledDds") && gui.pieEnabledDds.Length >= p ? (gui.pieEnabledDds[p].Value = 1) : PieIsEnabled(p)
        newEnabled.Push(enabledVal ? 1 : 0)
        ed := gui.pieHotkeyEdits[p]
        rawHotkey := gui.HasProp("pieHotkeyValues") && gui.pieHotkeyValues.Length >= p ? gui.pieHotkeyValues[p] : ed.Value
        normHotkey := PieNormalizeHotkey(rawHotkey)
        newHotkeys.Push(normHotkey)
        ed.Value := normHotkey
        if gui.HasProp("pieHotkeyValues")
            gui.pieHotkeyValues[p] := normHotkey
        if gui.HasProp("pieHotkeyDisplays") && gui.pieHotkeyDisplays.Length >= p
            gui.pieHotkeyDisplays[p].Text := PieHotkeyButtonText(normHotkey)
        nameEd := gui.pieNameEdits[p]
        newNames.Push(Trim(nameEd.Value) != "" ? Trim(nameEd.Value) : PieDefaultName(p))
    }
    PieEnabled := newEnabled
    PieCount := PieEnabledCount()
    while PieConfigs.Length < 4
        PieConfigs.Push(PieDefaultConfig(PieConfigs.Length + 1))
    while PieHotkeys.Length < 4
        PieHotkeys.Push("")
    while PieNames.Length < 4
        PieNames.Push("")
    Loop 4 {
        p := A_Index
        PieHotkeys[p] := newHotkeys[p]
        PieNames[p] := newNames[p]
    }
    SavePieItems()
    Pie_ReapplyHotkeys()
    HK_ReapplyCoreHoldKeys()
    namesChanged := oldNames.Length != PieNames.Length
    if !namesChanged {
        Loop PieNames.Length {
            if oldNames[A_Index] != PieNames[A_Index] {
                namesChanged := true
                break
            }
        }
    }
    enabledChanged := oldEnabled.Length != PieEnabled.Length
    if !enabledChanged {
        Loop PieEnabled.Length {
            if oldEnabled[A_Index] != PieEnabled[A_Index] {
                enabledChanged := true
                break
            }
        }
    }
    if oldCount != PieCount || namesChanged || enabledChanged
        RebuildMainGui()
    RefreshPieSystemControls(gui)
    } catch as err {
        DebugLog("SavePieSystemSettings error: " err.Message)
        ShowNotify("Pie Settings", "Save failed: " err.Message, "0xE53935")
    }
}

PieOvenRowEnabledChanged(guiObj, pieIndex, ctrl, *) {
    if !IsObject(guiObj)
        return
    PieOvenRefreshRowStates(guiObj)
}

PieOvenRefreshRowStates(guiObj) {
    if !IsObject(guiObj) || !guiObj.HasProp("pieEnabledDds")
        return
    Loop guiObj.pieEnabledDds.Length {
        isEnabled := guiObj.pieEnabledDds[A_Index].Value = 1
        if guiObj.HasProp("pieNameEdits") && guiObj.pieNameEdits.Length >= A_Index
            guiObj.pieNameEdits[A_Index].Enabled := isEnabled
        if guiObj.HasProp("pieTestButtons") && guiObj.pieTestButtons.Length >= A_Index
            guiObj.pieTestButtons[A_Index].Enabled := isEnabled
        if guiObj.HasProp("pieEditButtons") && guiObj.pieEditButtons.Length >= A_Index
            guiObj.pieEditButtons[A_Index].Enabled := isEnabled
        if guiObj.HasProp("pieHotkeyDisplays") && guiObj.pieHotkeyDisplays.Length >= A_Index
            guiObj.pieHotkeyDisplays[A_Index].Enabled := isEnabled
        if guiObj.HasProp("pieSaveButtons") && guiObj.pieSaveButtons.Length >= A_Index
            guiObj.pieSaveButtons[A_Index].Enabled := true
        if guiObj.HasProp("pieResetButtons") && guiObj.pieResetButtons.Length >= A_Index
            guiObj.pieResetButtons[A_Index].Enabled := true
    }
}

PieOvenSyncGlobalFields(guiObj) {
    global _pieDelayMs, _pieDeadzone, _pieStyle, _pieQuickHintsVisible, _pieQuickSlotHintsPos, _pieQuickHintCount
    if !IsObject(guiObj)
        return
    if guiObj.HasProp("edPieDelay")
        _pieDelayMs := PieSafeInt(guiObj.edPieDelay.Value, 65, 0, 1000)
    if guiObj.HasProp("edPieDeadzone")
        _pieDeadzone := PieSafeInt(guiObj.edPieDeadzone.Value, 42, 0, 200)
    if guiObj.HasProp("ddlPieStyle")
        _pieStyle := PieNormalizeStyle(guiObj.ddlPieStyle.Text)
    if guiObj.HasProp("chkQuickHints")
        _pieQuickHintsVisible := guiObj.chkQuickHints.Value ? 1 : 0
    if guiObj.HasProp("ddlQuickSlotPos")
        _pieQuickSlotHintsPos := PieQuickSlotPosNorm(guiObj.ddlQuickSlotPos.Text)
    if guiObj.HasProp("edQuickHintCount")
        _pieQuickHintCount := PieSafeInt(guiObj.edQuickHintCount.Value, 20, 1, 99)
}

PieOvenApplySingleRow(guiObj, pieIndex, save := true) {
    global PieEnabled, PieCount, PieHotkeys, PieNames, PieConfigs
    if !IsObject(guiObj)
        return
    PieOvenSyncGlobalFields(guiObj)
    while PieConfigs.Length < 4
        PieConfigs.Push(PieDefaultConfig(PieConfigs.Length + 1))
    while PieHotkeys.Length < 4
        PieHotkeys.Push("")
    while PieNames.Length < 4
        PieNames.Push("")
    while PieEnabled.Length < 4
        PieEnabled.Push(1)
    PieEnabled[pieIndex] := guiObj.pieEnabledDds[pieIndex].Value = 1 ? 1 : 0
    PieCount := PieEnabledCount()
    rawHotkey := guiObj.HasProp("pieHotkeyValues") && guiObj.pieHotkeyValues.Length >= pieIndex ? guiObj.pieHotkeyValues[pieIndex] : guiObj.pieHotkeyEdits[pieIndex].Value
    normHotkey := PieNormalizeHotkey(rawHotkey)
    PieHotkeys[pieIndex] := normHotkey
    PieNames[pieIndex] := Trim(guiObj.pieNameEdits[pieIndex].Value) != "" ? Trim(guiObj.pieNameEdits[pieIndex].Value) : PieDefaultName(pieIndex)
    guiObj.pieHotkeyEdits[pieIndex].Value := normHotkey
    if guiObj.HasProp("pieHotkeyValues") && guiObj.pieHotkeyValues.Length >= pieIndex
        guiObj.pieHotkeyValues[pieIndex] := normHotkey
    if guiObj.HasProp("pieHotkeyDisplays") && guiObj.pieHotkeyDisplays.Length >= pieIndex
        guiObj.pieHotkeyDisplays[pieIndex].Text := PieHotkeyButtonText(normHotkey)
    if save {
        SavePieItems()
        Pie_ReapplyHotkeys()
        HK_ReapplyCoreHoldKeys()
        RebuildMainGui()
    }
    PieOvenRefreshRowStates(guiObj)
}

PieOvenTestSingle(guiObj, pieIndex, *) {
    if !IsObject(guiObj)
        return
    PieOvenSyncGlobalFields(guiObj)
    ShowPieMenu(pieIndex)
}

PieOvenPreviewSub(guiObj, subIndex, *) {
    if !IsObject(guiObj)
        return
    PieOvenSyncGlobalFields(guiObj)
    ShowSubPiePreview(subIndex)
}

PieOvenTestSub(guiObj, subIndex, *) {
    if !IsObject(guiObj)
        return
    PieOvenSyncGlobalFields(guiObj)
    ShowSubPieMenu(subIndex)
}

PieOvenSaveSingle(guiObj, pieIndex, *) {
    CreateSettingsSnapshotBeforeSave("pie")
    PieOvenApplySingleRow(guiObj, pieIndex, true)
    ShowNotify("Pie Menu", "Pie " pieIndex " saved")
}

PieOvenResetSingle(guiObj, pieIndex, *) {
    global PieHotkeys, PieNames, PieEnabled
    guiObj.pieEnabledDds[pieIndex].Value := 1
    guiObj.pieNameEdits[pieIndex].Value := PieDefaultName(pieIndex)
    defaultHotkey := PieDefaultHotkey(pieIndex)
    guiObj.pieHotkeyEdits[pieIndex].Value := defaultHotkey
    if guiObj.HasProp("pieHotkeyValues") && guiObj.pieHotkeyValues.Length >= pieIndex
        guiObj.pieHotkeyValues[pieIndex] := defaultHotkey
    if guiObj.HasProp("pieHotkeyDisplays") && guiObj.pieHotkeyDisplays.Length >= pieIndex
        guiObj.pieHotkeyDisplays[pieIndex].Text := PieHotkeyButtonText(defaultHotkey)
    PieOvenApplySingleRow(guiObj, pieIndex, true)
    ShowNotify("Pie Menu", "Pie " pieIndex " reset")
}

PieOvenSaveGlobal(guiObj) {
    PieOvenSyncGlobalFields(guiObj)
    CreateSettingsSnapshotBeforeSave("pie_global")
    SavePieItems()
    Pie_ReapplyHotkeys()
    HK_ReapplyCoreHoldKeys()
    ShowNotify("Pie Menu", "Global settings saved")
}

PieOvenResetGlobal(guiObj) {
    global _pieDelayMs, _pieDeadzone, _pieStyle, _pieQuickHintsVisible, _pieQuickSlotHintsPos, _pieQuickHintCount
    _pieDelayMs := 65
    _pieDeadzone := 42
    _pieStyle := "Normal"
    _pieQuickHintsVisible := 1
    _pieQuickSlotHintsPos := "bottom-center"
    _pieQuickHintCount := 20
    if IsObject(guiObj) {
        if guiObj.HasProp("edPieDelay")
            guiObj.edPieDelay.Value := _pieDelayMs
        if guiObj.HasProp("edPieDeadzone")
            guiObj.edPieDeadzone.Value := _pieDeadzone
        if guiObj.HasProp("ddlPieStyle")
            guiObj.ddlPieStyle.Value := PieStyleValue(_pieStyle)
        if guiObj.HasProp("chkQuickHints")
            guiObj.chkQuickHints.Value := _pieQuickHintsVisible
        if guiObj.HasProp("ddlQuickSlotPos")
            guiObj.ddlQuickSlotPos.Value := PieQuickSlotPosIndex(_pieQuickSlotHintsPos)
        if guiObj.HasProp("edQuickHintCount")
            guiObj.edQuickHintCount.Value := _pieQuickHintCount
    }
    SavePieItems()
    Pie_ReapplyHotkeys()
    HK_ReapplyCoreHoldKeys()
    ShowNotify("Pie Menu", "Global settings reset")
}

PieOvenHotkeyApply(targetEd, targetBtn, pieIndex, ed, dlg, *) {
    global PieHotkeys
    targetEd.Value := PieNormalizeHotkey(ed.Value)
    PieHotkeys[pieIndex] := targetEd.Value
    targetEd.Gui.pieHotkeyValues[pieIndex] := targetEd.Value
    targetBtn.Text := PieHotkeyButtonText(targetEd.Value)
    SavePieItems()
    Pie_ReapplyHotkeys()
    HK_ReapplyCoreHoldKeys()
    dlg.Destroy()
}

PieHotkeyButtonText(value) {
    value := Trim(value)
    return value != "" ? value : "(none)"
}

PieNormalizeHotkey(value) {
    value := Trim(value)
    if value = "" || value = "-"
        return value
    value := RegExReplace(value, "\s+", "")
    value := RegExReplace(value, "i)Control\+", "^")
    value := RegExReplace(value, "i)Ctrl\+", "^")
    value := RegExReplace(value, "i)Shift\+", "+")
    value := RegExReplace(value, "i)Alt\+", "!")
    value := RegExReplace(value, "i)Win\+", "#")
    return value
}

PieHotkeyEditChanged(display, ctrl, *) {
    display.Text := PieHotkeyButtonText(PieNormalizeHotkey(ctrl.Value))
}

PieHotkeyPopup(targetEd, targetBtn, pieIndex, *) {
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Pie " pieIndex " Hotkey")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(12)
    dlg.AddText("xm", "Open hotkey:")
    ed := dlg.AddEdit("xm y+" S(6) " w" S(210) " c000000 BackgroundFFFFFF", targetEd.Value)
    display := dlg.AddText("x+8 yp w" S(90) " h22 +0x200 Center cFFFFFF Background2D2D32", PieHotkeyButtonText(ed.Value))
    ed.OnEvent("Change", PieHotkeyEditChanged.Bind(display))
    capBtn := dlg.AddButton("xm y+" S(10) " w" S(70) " h" S(26), "Record")
    capBtn.OnEvent("Click", (*) => HK_CaptureKey(dlg, ed, display, capBtn))
    dlg.AddButton("x+" S(8) " yp w" S(70) " h" S(26) " cFFFFFF Default", "OK").OnEvent("Click", PieOvenHotkeyApply.Bind(targetEd, targetBtn, pieIndex, ed, dlg))
    dlg.AddButton("x+" S(8) " yp w" S(70) " h" S(26), "Clear").OnEvent("Click", (*) => (
        ed.Value := "",
        display.Text := PieHotkeyButtonText("")
    ))
    dlg.AddButton("x+" S(8) " yp w" S(70) " h" S(26), "Cancel").OnEvent("Click", (*) => dlg.Destroy())
    dlg.AddText("xm y+" S(8) " w" S(250) " c888888", "Tip: blank disables this pie open hotkey.")
    dlg.Show("AutoSize")
    capBtn.Focus()
}

ResetSystemSettings(ctrl, *) {
    progress := SettingsProgressStart("System Settings", "Resetting settings...", 10)
    try {
        SettingsProgressStep(progress, "Resetting LT coordinates...", 25)
        ResetLTCoords(ctrl)
        SettingsProgressStep(progress, "Resetting color info settings...", 40)
        ResetColorOffset(ctrl)
        SettingsProgressStep(progress, "Resetting auto save...", 55)
        ResetAutoSaveInterval(ctrl)
        SettingsProgressStep(progress, "Resetting preset requirements...", 70)
        ResetReqPresetSettings(ctrl)
        SettingsProgressStep(progress, "Resetting hold threshold...", 85)
        ResetHoldThreshold(ctrl)
        SettingsProgressStep(progress, "Resetting select cell mode...", 90)
        ResetSelectCelMode(ctrl)
        SettingsProgressStep(progress, "Resetting tooltip settings...", 92)
        ResetTooltipDelay(ctrl)
        SettingsProgressStep(progress, "Saving reset defaults...", 96)
        SaveLTDetect(ctrl)
        SaveClickCoords(ctrl)
        SaveColorOffset(ctrl)
        SettingsProgressStep(progress, "Done.", 100)
    } finally {
        SettingsProgressClose(progress)
    }
    ShowNotify("System Settings", "Reset to defaults")
}

SaveReqPresetSettings(ctrl, *) {
    global SETTINGS_FILE, ReqAnimationEnabled, ReqNastarEnabled, _useUltimateSaveAs, InbetweenIndex
    gui := ctrl.Gui
    ReqAnimationEnabled := gui.chkAnim.Value
    ReqNastarEnabled := gui.chkNastar.Value
    try SystemSettingsRefreshRequirementHints(gui)
    IniWrite(ReqAnimationEnabled, SETTINGS_FILE, "Settings", "ReqAnimation")
    IniWrite(ReqNastarEnabled, SETTINGS_FILE, "Settings", "ReqNastar")
    try SettingsSyncIniWatcher()
    HK_ReapplyAll()
    HK_RefreshSettingsList()
    try RefreshIBRequirementState()
    _RebuildColorGui()
    _RebuildLinkGui()
    ShowNotify("CSP Presets", "Saved")
}

ResetReqPresetSettings(ctrl, *) {
    gui := ctrl.Gui
    gui.chkAnim.Value := 0
    gui.chkNastar.Value := 0
    SaveReqPresetSettings(ctrl)
    ShowNotify("CSP Presets", "Reset to OFF")
}

SavePieSettingsOnly(ctrl, *) {
    progress := SettingsProgressStart("Pie Oven", "Saving pie settings...", 10)
    try {
        SettingsProgressStep(progress, "Creating snapshot...", 20)
        CreateSettingsSnapshotBeforeSave("pie")
        SettingsProgressStep(progress, "Writing pie settings...", 35)
        SavePieSystemSettings(ctrl)
        SettingsProgressStep(progress, "Reapplying pie hotkeys...", 85)
        SettingsProgressStep(progress, "Done.", 100)
    } finally {
        SettingsProgressClose(progress)
    }
    ShowNotify("Pie Menu", "Saved")
}

ResetPieSettingsOnly(ctrl, *) {
    global PieCount, PieHotkeys, PieConfigs, PieNames, _pieDelayMs, _pieDeadzone, _pieStyle
    gui := ctrl.Gui
    progress := SettingsProgressStart("Pie Oven", "Resetting pie settings...", 10)
    try {
        SettingsProgressStep(progress, "Restoring defaults...", 30)
        PieResetDefaults(true)
        SettingsProgressStep(progress, "Refreshing controls...", 50)
        RefreshPieSystemControls(gui)
        SettingsProgressStep(progress, "Reapplying pie hotkeys...", 70)
        Pie_ReapplyHotkeys()
        HK_ReapplyCoreHoldKeys()
        SettingsProgressStep(progress, "Rebuilding Main GUI...", 90)
        RebuildMainGui()
        SettingsProgressStep(progress, "Done.", 100)
    } finally {
        SettingsProgressClose(progress)
    }
    ShowNotify("Pie Menu", "Reset to defaults")
}

RefreshPieSystemControls(gui) {
    global PieCount, PieHotkeys, PieNames, _pieDelayMs, _pieDeadzone, _pieStyle, _pieQuickHintsVisible, _pieQuickSlotHintsPos, _pieQuickHintCount
    if !IsObject(gui)
        return
    if gui.HasProp("modeLabel") {
        gui.modeLabel.Text := "Mode: " ModeSettingsActiveName()
        gui.Title := "Pie Oven - " ModeSettingsActiveName()
    }
    if gui.HasProp("edPieDelay")
        gui.edPieDelay.Value := _pieDelayMs
    if gui.HasProp("edPieDeadzone")
        gui.edPieDeadzone.Value := _pieDeadzone
    if gui.HasProp("ddlPieStyle")
        gui.ddlPieStyle.Value := PieStyleValue(_pieStyle)
    if gui.HasProp("chkQuickHints")
        gui.chkQuickHints.Value := _pieQuickHintsVisible ? 1 : 0
    if gui.HasProp("ddlQuickSlotPos")
        gui.ddlQuickSlotPos.Value := PieQuickSlotPosIndex(_pieQuickSlotHintsPos)
    if gui.HasProp("edQuickHintCount")
        gui.edQuickHintCount.Value := _pieQuickHintCount
    if !gui.HasProp("pieHotkeyEdits")
        return
    Loop gui.pieHotkeyEdits.Length {
        p := A_Index
        if gui.HasProp("pieEnabledDds") && gui.pieEnabledDds.Length >= p
            gui.pieEnabledDds[p].Value := PieIsEnabled(p) ? 1 : 2
        resetKey := PieHotkeys.Length >= p ? PieHotkeys[p] : PieDefaultHotkey(p)
        gui.pieHotkeyEdits[p].Value := resetKey
        if gui.HasProp("pieHotkeyValues")
            gui.pieHotkeyValues[p] := resetKey
        if gui.HasProp("pieNameEdits")
            gui.pieNameEdits[p].Value := PieNames.Length >= p ? PieNames[p] : PieDefaultName(p)
        if gui.HasProp("pieHotkeyDisplays")
            gui.pieHotkeyDisplays[p].Text := PieHotkeyButtonText(resetKey)
    }
    PieOvenRefreshRowStates(gui)
}

ExportSubPie(idx, *) {
    global SubPieConfigs, SubPieNames
    if SubPieConfigs.Length < idx || !IsObject(SubPieConfigs[idx]) {
        _HK_ResultPopup("Export Sub Pie", "No data for sub pie " idx, "E53935")
        return
    }
    name := SubPieNames.Length >= idx ? SubPieNames[idx] : SubPieDefaultName(idx)
    ts := FormatTime(, "yyyyMMdd_HHmmss")
    safeName := RegExReplace(name, "[^\w-]", "_")
    fn := FileSelect("S16", A_MyDocuments "\subpie_" safeName "_" ts ".json", "Export Sub Pie", "JSON (*.json)")
    if fn = ""
        return
    slots := []
    for i, item in SubPieConfigs[idx] {
        slots.Push(Map(
            "slot", i,
            "label", item.Get("label", ""),
            "type", item.Get("type", "disabled"),
            "action", item.Get("action", ""),
            "requirement", HK_NormalizeRequirement(item.Get("requirement", "")),
            "color", PieSafeColor(item.Get("color", "455A64")),
            "enabled", item.Get("enabled", 1),
            "subPie", item.Get("subPie", 1)
        ))
    }
    data := Map(
        "version", 1,
        "name", name,
        "slots", slots
    )
    try {
        json := _MapToJSON(data, 1)
        try FileDelete(fn)
        FileAppend(json, fn, "UTF-8")
        _HK_ResultPopup("Export Sub Pie", "Sub pie exported:`n" fn, "4CAF50")
    } catch as e {
        _HK_ResultPopup("Export Sub Pie Error", "Export failed: " e.Message, "E53935")
    }
}

ImportSubPie(idx, *) {
    global SubPieConfigs, SubPieNames, PIE_SETTINGS_FILE
    fn := FileSelect(1, A_MyDocuments "\subpie_*.json", "Import Sub Pie", "JSON (*.json)")
    if fn = ""
        return
    if !FileExist(fn) {
        _HK_ResultPopup("Import Sub Pie Error", "File not found: " fn, "E53935")
        return
    }
    try raw := FileRead(fn, "UTF-8")
    catch as e {
        _HK_ResultPopup("Import Sub Pie Error", "Failed to read file: " e.Message, "E53935")
        return
    }
    try data := _JSONToMap(raw)
    catch as e {
        _HK_ResultPopup("Import Sub Pie Error", "Failed to parse JSON: " e.Message, "E53935")
        return
    }
    if !(data is Map) {
        _HK_ResultPopup("Import Sub Pie Error", "Invalid JSON structure — expected an object.", "E53935")
        return
    }
    cDlg := Gui("+AlwaysOnTop +ToolWindow", "Import Sub Pie")
    cDlg.BackColor := "1E1F22"
    cDlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    cDlg.MarginX := S(14)
    cDlg.MarginY := S(14)
    importName := data.Get("name", "Unnamed")
    cDlg.AddText("cFFD54F", "Import sub pie to slot " idx "?")
    cDlg.AddText("xm y+" S(4) " cAAAAAA", "Name: " importName)
    cDlg.AddText("xm y+" S(4) " c888888", "This will overwrite the current sub pie at this slot.")
    result := 0
    cDlg.AddButton("xm y+10 w" S(80) " h" S(26) " cFFFFFF", "Import").OnEvent("Click", (*) => (result := 1, cDlg.Destroy()))
    cDlg.AddButton("x+8 yp w" S(80) " h" S(26), "Cancel").OnEvent("Click", (*) => cDlg.Destroy())
    cDlg.Show("AutoSize")
    GuiWaitForCloseSafe(cDlg)
    if !result
        return
    incomingSlots := data.Get("slots", [])
    SlotImportDefaults(slot, idx) {
        return Map(
            "slot", slot.Get("slot", idx),
            "label", slot.Get("label", PieSlotName(idx)),
            "type", slot.Get("type", "disabled"),
            "action", slot.Get("action", ""),
            "requirement", HK_NormalizeRequirement(slot.Get("requirement", "")),
            "color", PieSafeColor(slot.Get("color", "455A64")),
            "enabled", slot.Get("enabled", 1),
            "subPie", slot.Get("subPie", 1)
        )
    }
    newSlots := []
    Loop 10 {
        i := A_Index
        if incomingSlots.Length >= i && IsObject(incomingSlots[i])
            newSlots.Push(SlotImportDefaults(incomingSlots[i], i))
        else
            newSlots.Push(SlotImportDefaults(Map(), i))
    }
    SubPieConfigs[idx] := newSlots
    importName := data.Get("name", SubPieNames.Length >= idx ? SubPieNames[idx] : SubPieDefaultName(idx))
    if SubPieNames.Length >= idx
        SubPieNames[idx] := importName
    SavePieItems()
    Pie_ReapplyHotkeys()
    HK_ReapplyCoreHoldKeys()
    _HK_ResultPopup("Import Sub Pie", "Sub pie imported to slot " idx ".`nReopen Pie Oven to refresh.", "4CAF50")
}

ExportPieSettings(*) {
    global PieConfigs, SubPieConfigs, SubPieNames, PieCount, PieHotkeys, PieNames, PieEnabled, _pieDelayMs, _pieDeadzone, _pieStyle, _pieQuickHintsVisible, _pieQuickSlotHintsPos, _pieQuickHintCount
    ts := FormatTime(, "yyyyMMdd_HHmmss")
    fn := FileSelect("S16", A_MyDocuments "\pie_menu_profile_" ts ".ini", "Export Pie Menu Profile", "INI (*.ini)")
    if fn = ""
        return
    progress := SettingsProgressStart("Pie Export", "Preparing export...", 10)
    try {
        SettingsProgressStep(progress, "Saving current pie state...", 20)
        SavePieItems()
        if FileExist(fn)
            FileDelete(fn)
        SettingsProgressStep(progress, "Writing main pie profiles...", 40)
        IniWrite(PieCount, fn, "PieMenu", "PieCount")
        IniWrite(_pieDelayMs, fn, "PieMenu", "DelayMs")
        IniWrite(_pieDeadzone, fn, "PieMenu", "Deadzone")
        IniWrite(PieNormalizeStyle(_pieStyle), fn, "PieMenu", "Style")
        IniWrite(_pieQuickHintsVisible ? 1 : 0, fn, "PieMenu", "QuickHints")
        IniWrite(_pieQuickSlotHintsPos, fn, "PieMenu", "SlotQuickHintsPos")
        IniWrite(_pieQuickHintCount, fn, "PieMenu", "QuickHintCount")
        Loop 4 {
            p := A_Index
            IniWrite(PieIsEnabled(p) ? 1 : 0, fn, "PieMenu", "Pie" p "Enabled")
            IniWrite(PieHotkeys.Length >= p ? PieNormalizeHotkey(PieHotkeys[p]) : "", fn, "PieMenu", "Pie" p "Hotkey")
            IniWrite(PieNames.Length >= p ? PieNames[p] : PieDefaultName(p), fn, "PieMenu", "Pie" p "Name")
            config := PieConfigs[p]
            for i, item in config {
                sec := "PieMenu_" p "_" i
                typeVal := item.Get("type", "disabled")
                actionVal := item.Get("action", "")
                if (typeVal = "shortcut" || typeVal = "action") && actionVal != ""
                    actionVal := PieQuickNormalizeShortcutAction(actionVal)
                IniWrite(item.Get("label", ""), fn, sec, "Label")
                IniWrite(typeVal, fn, sec, "Type")
                IniWrite(actionVal, fn, sec, "Action")
                IniWrite(HK_NormalizeRequirement(item.Get("requirement", "")), fn, sec, "Requirement")
                IniWrite(PieSafeColor(item.Get("color", "455A64")), fn, sec, "Color")
                IniWrite(item.Get("enabled", 1), fn, sec, "Enabled")
                IniWrite(item.Get("subPie", 1), fn, sec, "SubPie")
            }
        }
        SettingsProgressStep(progress, "Writing sub-pie profiles...", 75)
        IniWrite(SubPieConfigs.Length ? SubPieConfigs.Length : 1, fn, "SubPieMenu", "Count")
        Loop (SubPieConfigs.Length ? SubPieConfigs.Length : 1) {
            s := A_Index
            config := SubPieConfigs.Length >= s ? SubPieConfigs[s] : SubPieDefaultConfig(s)
            IniWrite(SubPieNames.Length >= s ? SubPieNames[s] : SubPieDefaultName(s), fn, "SubPieMenu", "Sub" s "Name")
            for i, item in config {
                sec := "SubPieMenu_" s "_" i
                typeVal := item.Get("type", "disabled")
                actionVal := item.Get("action", "")
                if (typeVal = "shortcut" || typeVal = "action") && actionVal != ""
                    actionVal := PieQuickNormalizeShortcutAction(actionVal)
                IniWrite(item.Get("label", ""), fn, sec, "Label")
                IniWrite(typeVal, fn, sec, "Type")
                IniWrite(actionVal, fn, sec, "Action")
                IniWrite(HK_NormalizeRequirement(item.Get("requirement", "")), fn, sec, "Requirement")
                IniWrite(PieSafeColor(item.Get("color", "455A64")), fn, sec, "Color")
                IniWrite(item.Get("enabled", 1), fn, sec, "Enabled")
                IniWrite(item.Get("subPie", 1), fn, sec, "SubPie")
            }
        }
        SettingsProgressStep(progress, "Done.", 100)
        SettingsProgressClose(progress)
        progress := 0
        _HK_ResultPopup("Pie Export", "Pie menu profile exported:`n" fn, "4CAF50")
    } catch as e {
        SettingsProgressClose(progress)
        _HK_ResultPopup("Pie Export Error", "Export failed: " e.Message, "E53935")
    }
}

ImportPieSettings(*) {
    global PIE_SETTINGS_FILE, PieCount
    fn := FileSelect("3", A_MyDocuments "\pie_menu_profile_*.ini", "Import Pie Menu Profile", "INI (*.ini)")
    if fn = ""
        return
    progress := SettingsProgressStart("Pie Import", "Preparing import...", 10)
    try {
        SettingsProgressStep(progress, "Reading main pie profiles...", 25)
        newCount := PieSafeInt(IniRead(fn, "PieMenu", "PieCount", 4), 1, 1, 4)
        IniWrite(newCount, PIE_SETTINGS_FILE, "PieMenu", "PieCount")
        IniWrite(PieSafeInt(IniRead(fn, "PieMenu", "DelayMs", 65), 65, 0, 1000), PIE_SETTINGS_FILE, "PieMenu", "DelayMs")
        IniWrite(PieSafeInt(IniRead(fn, "PieMenu", "Deadzone", 42), 42, 0, 200), PIE_SETTINGS_FILE, "PieMenu", "Deadzone")
        IniWrite(PieNormalizeStyle(IniRead(fn, "PieMenu", "Style", "Normal")), PIE_SETTINGS_FILE, "PieMenu", "Style")
        IniWrite(PieSafeInt(IniRead(fn, "PieMenu", "QuickHints", 1), 1, 0, 1), PIE_SETTINGS_FILE, "PieMenu", "QuickHints")
        IniWrite(IniRead(fn, "PieMenu", "SlotQuickHintsPos", "bottom-center"), PIE_SETTINGS_FILE, "PieMenu", "SlotQuickHintsPos")
        IniWrite(PieSafeInt(IniRead(fn, "PieMenu", "QuickHintCount", 10), 10, 1, 99), PIE_SETTINGS_FILE, "PieMenu", "QuickHintCount")
        Loop 4 {
            p := A_Index
            IniWrite(PieSafeInt(IniRead(fn, "PieMenu", "Pie" p "Enabled", p <= newCount ? 1 : 0), p <= newCount ? 1 : 0, 0, 1), PIE_SETTINGS_FILE, "PieMenu", "Pie" p "Enabled")
            IniWrite(PieNormalizeHotkey(IniRead(fn, "PieMenu", "Pie" p "Hotkey", PieDefaultHotkey(p))), PIE_SETTINGS_FILE, "PieMenu", "Pie" p "Hotkey")
            IniWrite(IniRead(fn, "PieMenu", "Pie" p "Name", PieDefaultName(p)), PIE_SETTINGS_FILE, "PieMenu", "Pie" p "Name")
            config := PieDefaultConfig(p)
            Loop config.Length {
                i := A_Index
                sec := "PieMenu_" p "_" i
                item := config[i]
                importType := IniRead(fn, sec, "Type", item.Get("type", "disabled"))
                importAction := IniRead(fn, sec, "Action", item.Get("action", ""))
                if (importType = "shortcut" || importType = "action") && importAction != ""
                    importAction := PieQuickNormalizeShortcutAction(importAction)
                IniWrite(IniRead(fn, sec, "Label", item.Get("label", PieSlotName(i))), PIE_SETTINGS_FILE, sec, "Label")
                IniWrite(importType, PIE_SETTINGS_FILE, sec, "Type")
                IniWrite(importAction, PIE_SETTINGS_FILE, sec, "Action")
                IniWrite(HK_NormalizeRequirement(IniRead(fn, sec, "Requirement", item.Get("requirement", ""))), PIE_SETTINGS_FILE, sec, "Requirement")
                IniWrite(PieSafeColor(IniRead(fn, sec, "Color", item.Get("color", "455A64"))), PIE_SETTINGS_FILE, sec, "Color")
                IniWrite(PieSafeInt(IniRead(fn, sec, "Enabled", item.Get("enabled", 1)), 1, 0, 1), PIE_SETTINGS_FILE, sec, "Enabled")
                IniWrite(PieSafeInt(IniRead(fn, sec, "SubPie", item.Get("subPie", 1)), 1, 1, 99), PIE_SETTINGS_FILE, sec, "SubPie")
            }
        }
        SettingsProgressStep(progress, "Reading sub-pie profiles...", 55)
        subCount := PieSafeInt(IniRead(fn, "SubPieMenu", "Count", 1), 1, 1, 30)
        IniWrite(subCount, PIE_SETTINGS_FILE, "SubPieMenu", "Count")
        Loop subCount {
            s := A_Index
            IniWrite(IniRead(fn, "SubPieMenu", "Sub" s "Name", SubPieDefaultName(s)), PIE_SETTINGS_FILE, "SubPieMenu", "Sub" s "Name")
            config := SubPieDefaultConfig(s)
            Loop config.Length {
                i := A_Index
                sec := "SubPieMenu_" s "_" i
                item := config[i]
                importType := IniRead(fn, sec, "Type", item.Get("type", "disabled"))
                importAction := IniRead(fn, sec, "Action", item.Get("action", ""))
                if (importType = "shortcut" || importType = "action") && importAction != ""
                    importAction := PieQuickNormalizeShortcutAction(importAction)
                IniWrite(IniRead(fn, sec, "Label", item.Get("label", PieSlotName(i))), PIE_SETTINGS_FILE, sec, "Label")
                IniWrite(importType, PIE_SETTINGS_FILE, sec, "Type")
                IniWrite(importAction, PIE_SETTINGS_FILE, sec, "Action")
                IniWrite(HK_NormalizeRequirement(IniRead(fn, sec, "Requirement", item.Get("requirement", ""))), PIE_SETTINGS_FILE, sec, "Requirement")
                IniWrite(PieSafeColor(IniRead(fn, sec, "Color", item.Get("color", "455A64"))), PIE_SETTINGS_FILE, sec, "Color")
                IniWrite(PieSafeInt(IniRead(fn, sec, "Enabled", item.Get("enabled", 1)), 1, 0, 1), PIE_SETTINGS_FILE, sec, "Enabled")
                IniWrite(PieSafeInt(IniRead(fn, sec, "SubPie", item.Get("subPie", 1)), 1, 1, 99), PIE_SETTINGS_FILE, sec, "SubPie")
            }
        }
        SettingsProgressStep(progress, "Applying pie settings...", 75)
        SettingsSyncIniWatcher()
        LoadPieItems()
        SettingsProgressStep(progress, "Reapplying hotkeys...", 86)
        Pie_ReapplyHotkeys()
        HK_ReapplyCoreHoldKeys()
        SettingsProgressStep(progress, "Rebuilding Main GUI...", 94)
        RebuildMainGui()
        SettingsProgressStep(progress, "Done.", 100)
        SettingsProgressClose(progress)
        progress := 0
        _HK_ResultPopup("Pie Import", "Pie menu profile imported and applied.`nReopen Pie Oven to refresh visible fields.", "4CAF50")
    } catch as e {
        SettingsProgressClose(progress)
        _HK_ResultPopup("Pie Import Error", "Import failed: " e.Message, "E53935")
    }
}
