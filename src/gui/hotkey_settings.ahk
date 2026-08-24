; HOTKEY SETTINGS GUI
; ============================================================

global _PieQuickGui := 0
global _CapsNumGui := 0
global _SwapFirstDef := 0
global _SwapBtn := 0
global _HK_FixAllConflicts := []

ShowHotkeySettings() {
    global HotkeyDefs, _hkFilteredIndices, _HK_SettingsGui
    static sGui := 0
    if IsObject(sGui) {
        try if sGui.Hwnd {
            sGui.Show()
            return
        }
        sGui := 0
    }
    sGui := Gui("+AlwaysOnTop +Resize +ToolWindow", "Hotkey Settings - " ModeSettingsActiveName())
    _HK_SettingsGui := sGui
    sGui.BackColor := "1E1F22"
    sGui.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    sGui.OnEvent("Close", HK_SettingsClose)

    sGui.MarginY := S(12)
    sGui.SetFont("s" S(8), "Segoe UI")
    sGui.AddText("xm", "Find:")
    filterEd := sGui.AddEdit("x+8 yp w" S(207) " c000000 BackgroundFFFFFF", "")
    sGui.edFilter := filterEd
    sGui.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    sGui.AddButton("x+12 yp w" S(70) " h" S(22), "Export").OnEvent("Click", ExportHotkeys)
    sGui.AddButton("x+5 yp w" S(70) " h" S(22), "Import").OnEvent("Click", ImportHotkeys)
    sGui.AddButton("x+10 yp w" S(70) " h" S(22), "Quick").OnEvent("Click", ShowPieQuickHotkeys)
    sGui.AddButton("x+5 yp w" S(78) " h" S(22), "Caps 1-0").OnEvent("Click", ShowCapslockNumberSettings)
    sGui.AddButton("x+5 yp w" S(76) " h" S(22), "Browser").OnEvent("Click", ShowFunctionBrowser)
    sGui.AddButton("x+5 yp w" S(70) " h" S(22), "Targets").OnEvent("Click", ShowTargetWindowManager)
    sGui.AddButton("x+5 yp w" S(66) " h" S(22), "Modes").OnEvent("Click", ShowModeManager)
    sGui.AddButton("x+10 yp w" S(72) " h" S(22) " cFFFFFF", "How To").OnEvent("Click", HK_HowToUse)
    sGui.AddButton("x+5 yp w" S(70) " h" S(22), "Stress").OnEvent("Click", ShowHotkeyStressTest)

    sGui.modeLabel := sGui.AddText("xm y+" S(6) " cFFD54F", "Mode: " ModeSettingsActiveName())
    AddHoverPopup(sGui.modeLabel, "Editing mode: " ModeSettingsActiveName() "`nHotkeys and requirements are stored per mode.`nSwitch the active mode to edit another mode's hotkeys.")

    lv := sGui.AddListView("xm y+" S(6) " w" S(1113) " h" S(380) " Grid +Report", ["Action", "Shortcut", "Requirement", "AHK Function", "Status", "Outside", "Target", "#", "Effective"])
    lv.SetFont("s" S(9) " c000000", "Segoe UI")
    lv.OnEvent("DoubleClick", HK_EditItem)
    lv.ModifyCol(1, S(230))
    lv.ModifyCol(2, S(150))
    lv.ModifyCol(3, S(175))
    lv.ModifyCol(4, S(185))
    lv.ModifyCol(5, S(135))
    lv.ModifyCol(6, S(55))
    lv.ModifyCol(7, S(100))
    lv.ModifyCol(8, 0)
    lv.ModifyCol(9, S(200))

    _hkFilteredIndices := []
    for i, d in HotkeyDefs {
        key := HK_Get(d.id, d.def)
        status := HK_Status(key, d.id)
        outside := HK_OutsideText(d.id)
        lv.Add(, d.desc, HK_HotkeyCellText(d), HK_GetRequirement(d), HK_GetFnName(d), status, outside, HK_GetTarget(d.id), d.id, HK_EffectiveCellText(d))
        _hkFilteredIndices.Push(i)
    }

    _filterLv := lv
    _filterEdRef := filterEd
    _DebounceFilter(*) {
        SetTimer(_DoFilterRefresh, -150)
    }
    _DoFilterRefresh(*) {
        SetTimer(_DoFilterRefresh, 0)
        if IsObject(_filterEdRef) && IsObject(_filterLv) {
            global _SwapFirstDef, _SwapBtn
            _SwapFirstDef := 0
            if IsObject(_SwapBtn)
                _SwapBtn.Text := "Swap"
            FilterRefresh(_filterLv, _filterEdRef)
        }
    }
    filterEd.OnEvent("Change", _DebounceFilter)

    sGui.AddButton("xm y+10 w" S(91) " h" S(26), "Add").OnEvent("Click", HK_AddItem)
    sGui.AddButton("x+5 yp w" S(91) " h" S(26), "Edit").OnEvent("Click", HK_EditItem)
    sGui.AddButton("x+5 yp w" S(91) " h" S(26) "  cFFFFFF", "Delete").OnEvent("Click", HK_DeleteItem)
    sGui.AddButton("x+10 yp w" S(80) " h" S(26), "Toggle").OnEvent("Click", HK_ToggleItem)
    global _SwapBtn := sGui.AddButton("x+5 yp w" S(80) " h" S(26), "Swap")
    _SwapBtn.OnEvent("Click", HK_SwapKeys)
    sGui.AddButton("x+5 yp w" S(80) " h" S(26), "Resolve").OnEvent("Click", HK_ResolveConflict)
    sGui.AddButton("x+5 yp w" S(80) " h" S(26), "Fix All").OnEvent("Click", HK_FixAllConflicts)
    sGui.AddButton("x+5 yp w" S(80) " h" S(26), "Details").OnEvent("Click", HK_ShowDetails)
    sGui.AddButton("x+10 yp w" S(92) " h" S(26), "Reset Sel").OnEvent("Click", HK_ResetItem)
    sGui.AddButton("x+5 yp w" S(92) " h" S(26), "Reset All").OnEvent("Click", HK_ResetAll)
    sGui.AddButton("x+10 yp w" S(60) " h" S(26) " cFFFFFF", "Save").OnEvent("Click", HK_SaveAll)
    sGui.AddButton("x+5 yp w" S(60) " h" S(26), "Guide").OnEvent("Click", (*) => HK_CheatSheetGuideShow())
    sGui.AddButton("x+5 yp w" S(60) " h" S(26), "Close").OnEvent("Click", (*) => HK_SettingsClose(sGui))
    sGui.lv := lv
    sGui.Show("Autosize")
}

HK_OutsideText(id) {
    return HK_GetActivate(id) ? "Yes" : "-"
}

; Function Browser lives in src\gui\hotkey_function_browser.ahk


HK_SettingsClose(guiObj, *) {
    global _HK_SettingsGui
    _HK_SettingsGui := 0
    try guiObj.Destroy()
}

FilterRefresh(lv, filterEd, filterOverride := "", *) {
    global HotkeyDefs, _hkFilteredIndices
    f := StrLower(Trim(filterOverride != "" ? filterOverride : filterEd.Value))
    lv.Opt("-Redraw")
    lv.Delete()
    _hkFilteredIndices := []
    for i, d in HotkeyDefs {
        key := HK_Get(d.id, d.def)
        effTxt := HK_EffectiveCellText(d)
        if f != "" && !InStr(d.desc, f) && !InStr(key, f) && !InStr(effTxt, f) && !InStr(HK_HotkeyCellText(d), f) && !InStr(HK_GetRequirement(d), f) && !InStr(HK_GetFnName(d), f) && !InStr(HK_GetTarget(d.id), f)
            continue
        status := HK_Status(key, d.id)
        outside := HK_OutsideText(d.id)
        lv.Add(, d.desc, HK_HotkeyCellText(d), HK_GetRequirement(d), HK_GetFnName(d), status, outside, HK_GetTarget(d.id), d.id, effTxt)
        _hkFilteredIndices.Push(i)
    }
    lv.Opt("+Redraw")
}

; Effective hotkey under the active mode, shown only when it differs from the
; stored key (for example, a user script owns the same key and deactivates it).
HK_EffectiveCellText(d) {
    key := HK_Get(d.id, d.def)
    eff := HK_ModeEffectiveKey(d.id, key)
    return eff = key ? "" : HK_DisplayKey(eff)
}

; Hotkey cell text. Blocked hotkeys show the swallowed key (the default when the
; binding is disabled) with a [block] marker. Multi-shortcuts shown as "Key1 | Key2".
HK_HotkeyCellText(d) {
    key := HK_Get(d.id, d.def)
    if HK_IsBlockEnabled(d.id) {
        if key = "" || key = "-"
            key := HK_ModeDefaultKey(d.id, d.def)
        return HK_DisplayKey(key) " [block]"
    }
    return HK_DisplayKey(key)
}

HK_RefreshSettingsList(guiObj := 0, filterOverride := "") {
    global _HK_SettingsGui
    if !IsObject(guiObj)
        guiObj := _HK_SettingsGui
    if !IsObject(guiObj)
        return
    try guiObj.Hwnd
    catch {
        _HK_SettingsGui := 0
        return
    }
    try if guiObj.HasProp("modeLabel")
        guiObj.modeLabel.Text := "Mode: " ModeSettingsActiveName()
    FilterRefresh(guiObj.lv, guiObj.edFilter, filterOverride)
}

HK_ToggleItem(ctrl, *) {
    global HotkeyDefs, _hkFilteredIndices, HK_Custom, _SwapFirstDef, _SwapBtn
    _SwapFirstDef := 0
    if IsObject(_SwapBtn)
        _SwapBtn.Text := "Swap"
    parentGui := ctrl.Gui
    lv := parentGui.lv
    rows := []
    r := 0
    while r := lv.GetNext(r)
        rows.Push(r)
    if rows.Length = 0 {
        HK_SelectPrompt()
        return
    }
    for row in rows {
        d := HK_DefForRow(lv, row)
        cur := HK_Get(d.id, d.def)
        if cur = "-" {
            if HK_Custom.Has(d.id)
                try HK_Custom.Delete(d.id)
        } else
            HK_Custom[d.id] := "-"
        key := HK_Get(d.id, d.def)
        lv.Modify(row, "Col2", HK_HotkeyCellText(d))
        lv.Modify(row, "Col5", HK_Status(key, d.id))
        lv.Modify(row, "Col8", HK_EffectiveCellText(d))
    }
    HK_UpdateDuplicates(lv)
}

HK_ShowDetails(ctrl, *) {
    global HotkeyDefs, _hkFilteredIndices, _SwapFirstDef, _SwapBtn
    _SwapFirstDef := 0
    if IsObject(_SwapBtn)
        _SwapBtn.Text := "Swap"
    parentGui := ctrl.Gui
    lv := parentGui.lv
    row := lv.GetNext()
    if !row {
        HK_SelectPrompt()
        return
    }
    d := HK_DefForRow(lv, row)
    cur := HK_Get(d.id, d.def)
    modeDef := HK_ModeDefaultKey(d.id, d.def)
    fnName := HK_GetFnName(d)
    defFnName := "(inline)"
    try {
        if HasProp(d.fn, "Name") && d.fn.Name != ""
            defFnName := d.fn.Name
    }
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Hotkey Details: " d.id)
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)
    dlg.AddText("", "Action:  " d.desc)
    dlg.AddText("xm y+4 cAAAAAA", "Group:   " d.group)
    dlg.AddText("xm y+4 cAAAAAA", "Requirement: " HK_GetRequirement(d))
    dlg.AddText("xm y+4 cAAAAAA", "Context: " HK_ContextRequirement(d.group))
    dlg.AddText("xm y+4 cAAAAAA", "AHK Fn:  " fnName)
    dlg.AddText("xm y+4 cAAAAAA", "Default Fn: " defFnName)
    dlg.AddText("xm y+4 cAAAAAA", "Outside: " (HK_GetActivate(d.id) ? "Yes - activates CSP when triggered from background" : "No"))
    dlg.AddText("xm y+4 cAAAAAA", "Sends:   " (d.HasOwnProp("sends") ? d.sends : d.desc))
    dlg.AddText("xm y+4", "Default: " HK_DisplayKey(modeDef))
    dlg.AddText("xm y+4", "Current: " (cur = "-" ? "(disabled)" : HK_DisplayKey(cur)) (cur != modeDef && cur != "-" ? " (custom)" : cur = modeDef ? " (mode default)" : ""))
    dlg.AddText("xm y+4 c888888", "Key #:   " HK_IndexOfDef(d.id) " / " HotkeyDefs.Length)
    dlg.AddButton("xm y+10 w" S(80) " h" S(26), "OK").OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("AutoSize")
}

HK_Status(key, id) {
    global HK_CustomFn
    if key = "-"
        return "Disabled"
    if HK_CustomFn.Has(id) && HK_IsFnDisabledMarker(HK_CustomFn[id])
        return "Function Disabled"
    d := HK_FindDef(id)
    if IsObject(d) && !HK_GetFn(d)
        return "Invalid AHK function"
    s := HK_CheckDuplicate(id, key)
    if s = "" {
        if IsObject(d) && !HK_IsRequirementEnabled(d)
            return "Disabled"
        return "Enabled"
    }
    return s
}

HK_FindDef(id) {
    for d in HotkeyDefs
        if d.id = id
            return d
    return 0
}

HK_DefForRow(lv, row) {
    return HK_FindDef(lv.GetText(row, 7))
}

HK_IndexOfDef(id) {
    for i, d in HotkeyDefs
        if d.id = id
            return i
    return 0
}

; CapsLock slot assignment UI lives in src\gui\hotkey_capslock_slots.ahk


HK_CheckDuplicate(id, key) {
    if key = "" || key = "-"
        return ""
    dup := HK_FindDuplicateDef(id, key)
    if IsObject(dup)
        return "Conflict: " dup.desc
    return ""
}

HK_FindDuplicateDef(id, key) {
    if key = "" || key = "-"
        return 0
    myKeys := HK_SplitKeys(key)
    for d in HotkeyDefs {
        if d.id = id
            continue
        otherKey := HK_Get(d.id, d.def)
        if otherKey = "" || otherKey = "-"
            continue
        otherKeys := HK_SplitKeys(otherKey)
        for _, mk in myKeys {
            for _, ok in otherKeys {
                if Trim(mk) = Trim(ok)
                    return d
            }
        }
    }
    return 0
}

HK_ResolveConflict(ctrl, *) {
    global HotkeyDefs, _hkFilteredIndices, HK_Custom, _SwapFirstDef, _SwapBtn
    _SwapFirstDef := 0
    if IsObject(_SwapBtn)
        _SwapBtn.Text := "Swap"
    parentGui := ctrl.Gui
    lv := parentGui.lv
    row := lv.GetNext()
    if !row {
        HK_SelectPrompt()
        return
    }
    d := HK_DefForRow(lv, row)
    key := HK_Get(d.id, d.def)
    other := HK_FindDuplicateDef(d.id, key)
    if !IsObject(other) {
        _HK_ResultPopup("Resolve Conflict", "No duplicate conflict found for the selected hotkey.", "4CAF50")
        return
    }
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Resolve Hotkey Conflict")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)
    dlg.AddText("cFFD54F", "Duplicate hotkey: " key)
    dlg.AddText("xm y+" S(6), "Selected: " d.desc)
    dlg.AddText("xm y+" S(4), "Conflict: " other.desc)
    result := ""
    dlg.AddButton("xm y+" S(12) " w" S(120) " h" S(28) " cFFFFFF", "Disable Other").OnEvent("Click", (*) => (result := "disable_other", dlg.Destroy()))
    dlg.AddButton("x+" S(8) " yp w" S(90) " h" S(28), "Cancel").OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("AutoSize")
    GuiWaitForCloseSafe(dlg)
    if result = "disable_other" {
        HK_Custom[other.id] := "-"
        HK_UpdateDuplicates(lv)
        _HK_ResultPopup("Resolve Conflict", "Disabled:`n" other.desc "`n`nClick Save to persist this change.", "4CAF50")
    }
}

HK_SwapKeys(ctrl, *) {
    global HotkeyDefs, HK_Custom, _SwapFirstDef, _SwapBtn
    parentGui := ctrl.Gui
    lv := parentGui.lv
    row := lv.GetNext()
    if !row {
        HK_SelectPrompt()
        return
    }
    d := HK_DefForRow(lv, row)
    key := HK_Get(d.id, d.def)
    if IsObject(_SwapFirstDef) {
        d1 := _SwapFirstDef
        key1 := HK_Get(d1.id, d1.def)
        _SwapFirstDef := 0
        if IsObject(_SwapBtn)
            _SwapBtn.Text := "Swap"
        if key1 = "-" || key1 = "" {
            _HK_ResultPopup("Swap Hotkeys", "First hotkey was disabled — swap cancelled.", "FFA726")
            return
        }
        if d1.id = d.id {
            _HK_ResultPopup("Swap Hotkeys", "Selected the same hotkey — swap cancelled.", "FFA726")
            return
        }
        if key1 = key {
            _HK_ResultPopup("Swap Hotkeys", "Both hotkeys have the same key — nothing to swap.", "FFA726")
            return
        }
        HK_Custom[d1.id] := key
        HK_Custom[d.id] := key1
        Loop lv.GetCount() {
            rowId := lv.GetText(A_Index, 7)
            if rowId = d1.id {
                lv.Modify(A_Index, "Col2", HK_HotkeyCellText(d1))
                lv.Modify(A_Index, "Col5", HK_Status(HK_Get(d1.id, d1.def), d1.id))
                lv.Modify(A_Index, "Col8", HK_EffectiveCellText(d1))
            } else if rowId = d.id {
                lv.Modify(A_Index, "Col2", HK_HotkeyCellText(d))
                lv.Modify(A_Index, "Col5", HK_Status(HK_Get(d.id, d.def), d.id))
                lv.Modify(A_Index, "Col8", HK_EffectiveCellText(d))
            }
        }
        HK_UpdateDuplicates(lv)
        _HK_ResultPopup("Swap Hotkeys", d1.desc " [" HK_DisplayKey(key1) "]`n↔`n" d.desc " [" HK_DisplayKey(key) "]`n`nClick Save to persist.", "4CAF50")
    } else {
        _SwapFirstDef := d
        if IsObject(_SwapBtn)
            _SwapBtn.Text := "Swap to"
        _HK_ResultPopup("Swap Hotkeys", "First: " d.desc " [" HK_DisplayKey(key) "]`n`nSelect the second hotkey and click Swap to again.", "42A5F5")
    }
}

HK_FixAllConflicts(ctrl, *) {
    global HotkeyDefs, HK_Custom, _SwapFirstDef, _SwapBtn, _HK_FixAllConflicts
    _SwapFirstDef := 0
    if IsObject(_SwapBtn)
        _SwapBtn.Text := "Swap"
    parentGui := ctrl.Gui
    lv := parentGui.lv
    conflicts := []
    disabled := Map()
    for d in HotkeyDefs {
        key := HK_Get(d.id, d.def)
        if key = "" || key = "-"
            continue
        if disabled.Has(d.id)
            continue
        myKeys := HK_SplitKeys(key)
        for d2 in HotkeyDefs {
            if d2.id = d.id
                continue
            if disabled.Has(d2.id)
                continue
            key2 := HK_Get(d2.id, d2.def)
            otherKeys := HK_SplitKeys(key2)
            sharedKey := ""
            for _, mk in myKeys {
                for _, ok in otherKeys {
                    if Trim(mk) = Trim(ok) {
                        sharedKey := Trim(mk)
                        break
                    }
                }
                if sharedKey != ""
                    break
            }
            if sharedKey != "" {
                conflicts.Push({keep: d, drop: d2, key: sharedKey})
                disabled[d2.id] := true
            }
        }
        disabled[d.id] := true
    }
    if conflicts.Length = 0 {
        _HK_ResultPopup("Fix All Conflicts", "No conflicts found.", "4CAF50")
        return
    }
    _HK_FixAllConflicts := conflicts
    _HK_FixAllGui := Gui("+AlwaysOnTop +ToolWindow", "Fix All Conflicts")
    dlg := _HK_FixAllGui
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)
    dlg.AddText("cFFD166", conflicts.Length " conflict" (conflicts.Length > 1 ? "s" : "") " found:")
    for _, c in conflicts {
        dlg.AddText("cCCCCCC", "  " c.keep.desc " [" HK_DisplayKey(c.key) "] keeps the key")
        dlg.AddText("cAAAAAA", "  " c.drop.desc " [" HK_DisplayKey(c.key) "] will be disabled")
    }
    dlg.AddText("c888888", "`nApply fix will disable the losing hotkey in each pair.")
    btnApply := dlg.AddButton("xm y+10 w" S(90) " h" S(28) " Default", "Apply Fix")
    btnApply.OnEvent("Click", (*) => (HK_ApplyFixAll(), dlg.Destroy()))
    btnCancel := dlg.AddButton("x+" S(8) " yp w" S(70) " h" S(28), "Cancel")
    btnCancel.OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("AutoSize")
}

HK_ApplyFixAll() {
    global HotkeyDefs, HK_Custom, _HK_FixAllConflicts, _HK_SettingsGui
    conflicts := _HK_FixAllConflicts
    if !IsObject(conflicts) || conflicts.Length = 0
        return
    for _, c in conflicts
        HK_Custom[c.drop.id] := "-"
    lv := _HK_SettingsGui.lv
    Loop lv.GetCount() {
        rowId := lv.GetText(A_Index, 7)
        for _, c in conflicts {
            if rowId = c.drop.id {
                lv.Modify(A_Index, "Col2", HK_HotkeyCellText(c.drop))
                lv.Modify(A_Index, "Col5", HK_Status(HK_Get(c.drop.id, c.drop.def), c.drop.id))
                lv.Modify(A_Index, "Col8", HK_EffectiveCellText(c.drop))
                break
            }
        }
    }
    HK_UpdateDuplicates(lv)
    _HK_FixAllConflicts := []
    _HK_ResultPopup("Fix All Conflicts", "Disabled " conflicts.Length " conflicting hotkey" (conflicts.Length > 1 ? "s" : "") ".`n`nClick Save to persist.", "4CAF50")
}

HK_UpdateDuplicates(lv) {
    global HotkeyDefs
    Loop lv.GetCount() {
        lvRow := A_Index
        d := HK_DefForRow(lv, lvRow)
        key := HK_Get(d.id, d.def)
        lv.Modify(lvRow, "Col2", HK_HotkeyCellText(d))
        lv.Modify(lvRow, "Col3", HK_GetRequirement(d))
        lv.Modify(lvRow, "Col4", HK_GetFnName(d))
        lv.Modify(lvRow, "Col5", HK_Status(key, d.id))
        lv.Modify(lvRow, "Col6", HK_OutsideText(d.id))
        lv.Modify(lvRow, "Col8", HK_EffectiveCellText(d))
    }
}

HK_SelectPrompt() {
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Hotkey Settings")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)
    dlg.AddText("cAAAAAA", "Select a hotkey first.")
    dlg.AddButton("xm y+10 w" S(80) " h" S(26), "OK").OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("AutoSize")
}

; Pie Quick Hotkeys UI lives in src\gui\pie_quick_hotkeys.ahk


ShowUserFunctionLibrary(*) {
    global HK_UserScriptDir
    if !DirExist(HK_UserScriptDir)
        try DirCreate(HK_UserScriptDir)
    dlg := Gui("+AlwaysOnTop +ToolWindow +Resize", "User Scripts")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(12)
    dlg.MarginY := S(12)
    dlg.AddText("xm", "User script library. Use these files as Pie/Quick Pie script actions or user hotkey scripts.")
    dlg.AddText("xm y+4 w" S(674) " cAAAAAA", "To give a function a custom summary in Function Browser, add a line like '; Summary: what this function does' near the top of the user .ahk file.")
    lv := dlg.AddListView("xm y+8 w" S(674) " h" S(260) " Grid +Report", ["Function/File", "Path", "Callable Functions", "State"])
    lv.SetFont("s" S(9) " c000000", "Segoe UI")
    lv.ModifyCol(1, S(140))
    lv.ModifyCol(2, S(260))
    lv.ModifyCol(3, S(190))
    lv.ModifyCol(4, S(64))
    RefreshList() {
        global HK_UserScriptDir
        lv.Delete()
        Loop Files HK_UserScriptDir "\*.ahk" {
            funcs := ""
            body := FileRead(A_LoopFileFullPath, "UTF-8")
            if body != "" {
                parts := []
                fnPos := 1
                while (fnPos := RegExMatch(body, "m)^[\t ]*([A-Za-z_]\w*)\s*\(.*?\)\s*(\{|=>)", &m, fnPos)) {
                    if !(m[1] ~= "^(?:if|for|while|switch|try|catch|else|global|static|local|return|class|throw|break|continue|case|default|until|loop|and|or|not|new|super|this|true|false|each|in|is|has)$")
                        parts.Push(m[1])
                    fnPos := m.Pos + m.Len
                }
                funcs := ""
                for i, f in parts {
                    funcs .= (i > 1 ? ", " : "") f
                }
            }
            lv.Add(, RegExReplace(A_LoopFileName, "\.ahk$", ""), A_LoopFileFullPath, funcs != "" ? funcs : "(no functions)", HK_UserScriptDisabled(A_LoopFileFullPath) ? "Disabled" : "Enabled")
        }
    }
    SelectedPath() {
        row := lv.GetNext()
        if !row {
            HK_SelectPrompt()
            return ""
        }
        return lv.GetText(row, 2)
    }
    NewScript(*) {
        if HK_UserFunctionEditor()
            RefreshList()
    }
    EditScript(*) {
        path := SelectedPath()
        if path = ""
            return
        if HK_UserFunctionEditor(path)
            RefreshList()
    }
    OpenScriptGUI(*) {
        path := SelectedPath()
        if path = ""
            return
        fnName := ""
        for d in HotkeyDefs
            if d.HasOwnProp("scriptFile") && d.scriptFile = path {
                fnName := d.fnName
                break
            }
        HK_RunUserScriptGUI(path, fnName)
    }
    DeleteScript(*) {
        path := SelectedPath()
        if path = ""
            return
        cDlg := Gui("+AlwaysOnTop +ToolWindow", "Delete User Script")
        cDlg.BackColor := "1E1F22"
        cDlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
        cDlg.MarginX := S(14)
        cDlg.MarginY := S(14)
        cDlg.AddText("cFFD54F", "Delete this user script file?")
        cDlg.AddText("xm y+" S(4) " cAAAAAA", path)
        delResult := false
        cDlg.AddButton("xm y+10 w" S(80) " h" S(26) " cFFFFFF", "Yes").OnEvent("Click", (*) => (delResult := true, cDlg.Destroy()))
        cDlg.AddButton("x+8 yp w" S(80) " h" S(26), "No").OnEvent("Click", (*) => cDlg.Destroy())
        cDlg.Show("AutoSize")
        GuiWaitForCloseSafe(cDlg)
        if delResult {
            try FileDelete(path)
            HK_SetUserScriptDisabled(path, false)
            RefreshList()
        }
    }
    CopyPath(*) {
        path := SelectedPath()
        if path != "" {
            if SetClipboardSafe(path, "User Function")
                ShowNotify("User Function", "Path copied")
        }
    }
    ToggleScript(*) {
        row := lv.GetNext()
        if !row {
            HK_SelectPrompt()
            return
        }
        path := lv.GetText(row, 2)
        name := SplitPathName(path)
        disabled := HK_UserScriptDisabled(path)
        isBlockScript := HK_HasBlockManifest(path)
        HK_SetUserScriptDisabled(name, !disabled)
        if !disabled && isBlockScript
            try Run('"' A_AhkPath '" "' path '"')
        msg := name " " (disabled ? "enabled" : "disabled")
        if !disabled && isBlockScript
            msg .= " - reload toolkit to apply"
        ShowNotify("User Script", msg)
        RefreshList()
        UpdateStateButton()
    }
    UpdateStateButton(*) {
        row := lv.GetNext()
        if !row {
            btnState.Text := "Enable / Disable"
            btnState.Enabled := false
            return
        }
        path := lv.GetText(row, 2)
        btnState.Text := HK_UserScriptDisabled(path) ? "Enable" : "Disable"
        btnState.Enabled := true
    }
    RefreshList()
    lv.OnEvent("DoubleClick", EditScript)
    dlg.AddButton("xm y+10 w" S(55) " h" S(26), "New").OnEvent("Click", NewScript)
    dlg.AddButton("x+8 yp w" S(55) " h" S(26), "Edit").OnEvent("Click", EditScript)
    dlg.AddButton("x+8 yp w" S(55) " h" S(26), "Delete").OnEvent("Click", DeleteScript)
    dlg.AddButton("x+8 yp w" S(80) " h" S(26), "Copy Path").OnEvent("Click", CopyPath)
    dlg.AddButton("x+8 yp w" S(80) " h" S(26), "Open GUI").OnEvent("Click", OpenScriptGUI)
    btnState := dlg.AddButton("x+8 yp w" S(90) " h" S(26), "Enable / Disable")
    btnState.OnEvent("Click", ToggleScript)
    dlg.AddButton("x+8 yp w" S(90) " h" S(26), "Open Folder").OnEvent("Click", (*) => Run('"' HK_UserScriptDir '"'))
    dlg.AddButton("x+8 yp w" S(54) " h" S(26), "How To").OnEvent("Click", HK_UserFunctionHowTo)
    dlg.AddButton("x+8 yp w" S(50) " h" S(26), "Close").OnEvent("Click", (*) => dlg.Destroy())
    lv.OnEvent("ItemSelect", UpdateStateButton)
    UpdateStateButton()
    dlg.Show("AutoSize")
}

HK_UserFunctionEditor(path := "") {
    isEdit := path != "" && FileExist(path)
    fnName := isEdit ? RegExReplace(SplitPathName(path), "\.ahk$", "") : "UserFunction_" A_TickCount
    body := isEdit ? HK_ReadUserScriptBody(path, fnName)
        : ("; Summary:`n; Category:`n; Risk:`n`n"
          fnName "(){`n"
          "`tShowNotify(`"User Function`", `"Running`")`n"
          "}`n"
          "`n"
          "; ============ GUI container (customize below) ============`n"
          "; Open this window from the User Scripts manager with the 'Open GUI' button.`n"
          fnName "_GUI(){`n"
          "`tui := Gui(`"+AlwaysOnTop +ToolWindow`", `"User Function`")`n"
          "`tui.BackColor := `"1E1F22`"`n"
          "`tui.SetFont(`"s9 cFFFFFF`", `"Segoe UI`")`n"
          "`tui.MarginX := 12`n"
          "`tui.MarginY := 12`n"
          "`n"
          "`t; --- customize below ---`n"
          "`tui.AddText(`"xm`", `"Hello! Add your controls here.`")`n"
          "`tui.AddButton(`"xm y+10 w80 h26 Default`", `"Close`").OnEvent(`"Click`", (*) => ui.Destroy())`n"
          "`n"
          "`tui.Show()`n"
          "}")
    dlg := Gui("+AlwaysOnTop +ToolWindow", isEdit ? "Edit User Function" : "Add User Function")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(12)
    dlg.MarginY := S(12)
    dlg.AddText("xm w" S(95), "Function name:")
    nameEd := dlg.AddEdit("x+8 yp w" S(280) " c000000 BackgroundFFFFFF", fnName)
    dlg.AddText("xm y+10", "Script body:")
    dlg.AddText("xm y+4 w" S(520) " c888888", "Optional: add '; Summary:' '; Category:' '; Risk:' '; Requirement:' and '; Block:' near the top of the file so Function Browser and hotkey Requirements show metadata.")
    bodyEd := dlg.AddEdit("xm y+4 w" S(520) " h" S(260) " c000000 BackgroundFFFFFF -Wrap VScroll", body)
    result := false
    SaveScript(*) {
        cleanName := HK_SanitizeFnName(nameEd.Value)
        if cleanName = "" {
            _HK_ResultPopup("User Function", "Please enter a valid function/script name.", "E53935")
            return ""
        }
        newPath := HK_WriteUserScript(cleanName, bodyEd.Value)
        if isEdit && path != newPath && FileExist(path)
            try FileDelete(path)
        dlg.Destroy()
        return newPath
    }
    dlg.AddButton("xm y+10 w" S(60) " h" S(26) " Default", "Save").OnEvent("Click", (*) => (
        result := SaveScript()
    ))
    dlg.AddButton("x+8 yp w" S(60) " h" S(26), "Cancel").OnEvent("Click", (*) => dlg.Destroy())
    dlg.AddButton("x+" S(12) " yp w" S(86) " h" S(26) " c1565C0", "Recorder").OnEvent("Click", (*) => (
        recorded := HK_UserActionRecorder(nameEd.Value),
        recorded != "" ? (bodyEd.Value := recorded) : ""
    ))
    dlg.AddButton("x+8 yp w" S(86) " h" S(26) " c00897B", "Meta Guide").OnEvent("Click", HK_UserFunctionMetaGuide)
    dlg.AddButton("x+8 yp w" S(96) " h" S(26) " c9C27B0", "Script Guide").OnEvent("Click", HK_FunctionBrowserHowTo)
    dlg.AddButton("x+8 yp w" S(86) " h" S(26) " c795548", "? Keys Guide").OnEvent("Click", ShowKeysGuide)
    dlg.Show("AutoSize")
    GuiWaitForCloseSafe(dlg)
    return result
}

HK_UserActionRecorder(fnName := "") {
    fnName := HK_SanitizeFnName(fnName)
    if fnName = ""
        fnName := "RecordedAction_" A_TickCount
    actions := []
    dlg := Gui("+AlwaysOnTop +ToolWindow +Resize", "User Action Recorder")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(12)
    dlg.MarginY := S(12)
    dlg.AddText("xm w" S(590), "Build a user function from shortcut, function-call, and delay steps. Use Record/Add Fn one step at a time, then insert the generated script.")
    dlg.AddText("xm y+4 w" S(590) " cAAAAAA", "Safe mode: this does not record typed text automatically. It only adds the steps you choose.")

    lv := dlg.AddListView("xm y+10 w" S(590) " h" S(170) " Grid +Report", ["#", "Type", "Value"])
    lv.SetFont("s" S(9) " c000000", "Segoe UI")
    lv.ModifyCol(1, S(42))
    lv.ModifyCol(2, S(80))
    lv.ModifyCol(3, S(440))

    dlg.AddText("xm y+10", "Shortcut:")
    keyEd := dlg.AddEdit("x+8 yp-3 w" S(145) " c000000 BackgroundFFFFFF", "")
    keyDisplay := dlg.AddText("x+8 yp w" S(120) " h" S(24) " +0x200 Center cFFFFFF Background2D2D32", "")
    recBtn := dlg.AddButton("x+8 yp w" S(78) " h" S(24), "Record")
    recBtn.OnEvent("Click", (*) => HK_CaptureKey(dlg, keyEd, keyDisplay, recBtn))
    keyEd.OnEvent("Change", (*) => keyDisplay.Text := keyEd.Value)

    dlg.AddText("x+" S(16) " yp+4", "Delay:")
    delayEd := dlg.AddEdit("x+8 yp-4 w" S(60) " c000000 BackgroundFFFFFF", "80")
    dlg.AddText("x+5 yp+4 cAAAAAA", "ms")

    dlg.AddButton("xm y+12 w" S(88) " h" S(26), "Add Send").OnEvent("Click", AddShortcut)
    dlg.AddButton("x+8 yp w" S(88) " h" S(26), "Add Delay").OnEvent("Click", AddDelay)
    dlg.AddButton("x+8 yp w" S(88) " h" S(26), "Add Fn").OnEvent("Click", AddFunction)
    dlg.AddButton("x+8 yp w" S(88) " h" S(26), "Remove").OnEvent("Click", RemoveSelected)

    scriptEd := dlg.AddEdit("xm y+10 w" S(590) " h" S(180) " c000000 BackgroundFFFFFF -Wrap VScroll ReadOnly", "")
    result := ""

    RefreshList() {
        lv.Delete()
        for i, action in actions
            lv.Add(, i, action["type"], action["value"])
        scriptEd.Value := HK_BuildRecordedUserFunction(fnName, actions)
    }
    AddShortcut(*) {
        key := StrLower(Trim(keyEd.Value))
        if key = "" {
            _HK_ResultPopup("Action Recorder", "Record or type a shortcut first.", "E53935")
            return
        }
        actions.Push(Map("type", "send", "value", key))
        keyEd.Value := ""
        keyDisplay.Text := ""
        RefreshList()
    }
    AddDelay(*) {
        ms := 80
        try ms := Integer(delayEd.Value)
        ms := Max(0, Min(ms, 60000))
        actions.Push(Map("type", "sleep", "value", ms))
        RefreshList()
    }
    AddFunction(*) {
        HK_FunctionPicker(AddPickedFunction)
    }
    AddPickedFunction(fn) {
        fn := Trim(fn)
        if fn = ""
            return
        actions.Push(Map("type", "function", "value", fn))
        RefreshList()
    }
    RemoveSelected(*) {
        row := lv.GetNext()
        if !row {
            HK_SelectPrompt()
            return
        }
        actions.RemoveAt(row)
        RefreshList()
        if actions.Length
            lv.Modify(Min(row, actions.Length), "Select Focus Vis")
    }
    MoveSelected(delta) {
        row := lv.GetNext()
        if !row {
            HK_SelectPrompt()
            return
        }
        newRow := row + delta
        if newRow < 1 || newRow > actions.Length
            return
        tmp := actions[row]
        actions[row] := actions[newRow]
        actions[newRow] := tmp
        RefreshList()
        lv.Modify(newRow, "Select Focus Vis")
    }
    InsertScript(*) {
        if actions.Length = 0 {
            _HK_ResultPopup("Action Recorder", "Add at least one shortcut or delay first.", "E53935")
            return
        }
        result := HK_BuildRecordedUserFunction(fnName, actions)
        dlg.Destroy()
    }
    dlg.AddButton("xm y+10 w" S(88) " h" S(26), "▲ Up").OnEvent("Click", (*) => MoveSelected(-1))
    dlg.AddButton("x+8 yp w" S(88) " h" S(26), "▼ Down").OnEvent("Click", (*) => MoveSelected(1))
    dlg.AddButton("x+" S(108) " yp w" S(104) " h" S(26) " cFFFFFF Default", "Insert").OnEvent("Click", InsertScript)
    dlg.AddButton("x+8 yp w" S(104) " h" S(26), "Cancel").OnEvent("Click", (*) => dlg.Destroy())
    RefreshList()
    dlg.Show("AutoSize")
    GuiWaitForCloseSafe(dlg)
    return result
}

HK_BuildRecordedUserFunction(fnName, actions) {
    fnName := HK_SanitizeFnName(fnName)
    if fnName = ""
        fnName := "RecordedAction_" A_TickCount
    txt := "; Summary: Recorded user action`n"
        . "; Category: User`n"
        . "; Risk: Needs CSP`n`n"
        . fnName "(*) {`n"
    for action in actions {
        type := action.Get("type", "")
        value := action.Get("value", "")
        if type = "sleep" {
            try sleepMs := Integer(value)
            catch
                sleepMs := 80
            txt .= "`tSleep(" Max(0, sleepMs) ")`n"
        } else if type = "send" {
            token := HK_RecorderEscapeString(HK_RecorderSendToken(value))
            txt .= "`tSend(" Chr(34) token Chr(34) ")`n"
        } else if type = "function" {
            call := HK_RecorderFunctionCall(value)
            if call != ""
                txt .= "`t" call "`n"
        }
    }
    txt .= "}`n"
    return txt
}

HK_RecorderEscapeString(text) {
    return StrReplace(text, Chr(34), Chr(34) Chr(34))
}

HK_RecorderFunctionCall(fn) {
    fn := Trim(fn)
    if fn = ""
        return ""
    if RegExMatch(fn, "\)$")
        return fn
    return fn "()"
}

HK_RecorderSendToken(key) {
    key := Trim(key)
    if key = ""
        return ""
    if InStr(key, "{")
        return key
    prefix := ""
    while StrLen(key) > 0 {
        ch := SubStr(key, 1, 1)
        if ch = "~" || ch = "$" {
            key := SubStr(key, 2)
            continue
        }
        if ch = "^" || ch = "+" || ch = "!" || ch = "#" {
            prefix .= ch
            key := SubStr(key, 2)
            continue
        }
        break
    }
    static keyMap := 0
    if !IsObject(keyMap) {
        keyMap := Map(
            "Esc", "Esc", "Escape", "Esc", "Enter", "Enter", "Return", "Enter",
            "Space", "Space", "Tab", "Tab", "Backspace", "BS", "Bs", "BS",
            "Delete", "Delete", "Del", "Delete", "Insert", "Insert",
            "Home", "Home", "End", "End", "PgUp", "PgUp", "PgDn", "PgDn",
            "Up", "Up", "Down", "Down", "Left", "Left", "Right", "Right"
        )
    }
    if StrLen(key) = 1
        return prefix StrLower(key)
    if RegExMatch(key, "i)^F([1-9]|1[0-9]|2[0-4])$")
        return prefix "{" StrUpper(key) "}"
    key := keyMap.Has(key) ? keyMap[key] : key
    return prefix "{" key "}"
}

HK_UserFunctionMetaGuide(*) {
    popup := Gui("+AlwaysOnTop +ToolWindow", "Metadata Guide - User Function")
    popup.BackColor := "1E1F22"
    popup.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    popup.MarginX := S(14)
    popup.MarginY := S(14)

    txt := "
    (
Add these optional comments near the top of a user function script:

  ; Summary: One clear sentence about what the function does
  ; Category: User
  ; Risk: Needs CSP

SUMMARY
  Any short human-readable text is accepted.
  Keep it specific. Example:
    ; Summary: Selects the Rough, Sketch, or Dummy layer preset.

CATEGORY
  Accepted category labels:
    Guide
    Pie
    Color
    Timer
    Debug
    Link
    System
    Toggle
    User
    GUI
    Hotkey
    Built-in
    Runtime

RISK
  Accepted risk badges, separated by comma or pipe:
    Needs Animation_autoaction
    Needs Nastar
    Needs CSP
    Writes Files
    Settings I/O
    UI
    User Script
    Internal
    External Target
    Submenu
    Navigation
    Safe

REQUIREMENT
  Optional. Declares the dependency a hotkey needs when it uses this
  function. Two kinds of values are accepted:
    - A .laf dependency:  Nastar.laf  /  Animation_autoaction.laf
    - A user script name: e.g.  SelectLayer.ahk
  A hotkey that uses this user script auto-fills its Requirement
  field from this value (or from 'Needs Nastar' / 'Needs
  Animation_autoaction' in Risk). If nothing is declared, the script
  file name itself is used as the Requirement.
  When a Requirement is a script name and that script is missing or
  disabled, the hotkey is treated as blocked and does not fire.

BLOCK SHORTCUTS
  A user script can take over shortcuts from the main toolkit by
  declaring them in a Block manifest near the top of the file:
    ; Block: ^!+l, +1, +2, +3, +4, +5, +6, +7, +8, +9, +0, ^!+k
  How it works:
    - The script registers those keys to itself when it runs.
    - Matching toolkit shortcuts are disabled (set to '-') in the
      active mode's hotkey_settings.ini on the next toolkit reload.
    - If two user scripts claim the same shortcut, a conflict alert
      pops up and neither is registered.
    - Enable/disable the script from the User Scripts manager; a
      disabled block script has its block markers removed.
  Blocked keys are claimed per mode, so a shortcut can stay free in
  another mode.

EXAMPLES
  ; Summary: Opens my reference folder.
  ; Category: Link
  ; Risk: External Target

  ; Summary: Runs a CSP shortcut sequence for painting setup.
  ; Category: Color
  ; Risk: Needs CSP, Needs Nastar
  ; Requirement: SelectLayer.ahk
  ; Block: ^!+l, +1, +2
    )"
    popup.AddEdit("xm w" S(520) " h" S(440) " c000000 BackgroundFFFFFF -Wrap ReadOnly VScroll", txt)
    closeBtn := popup.AddButton(
    "xm y+10 w" S(120) " h" S(28) " Default",
    "Close"
    )
    closeBtn.OnEvent("Click", (*) => popup.Destroy())

    popup.Show("AutoSize")
    closeBtn.Focus()
}

SplitPathName(path) {
    SplitPath(path, &name)
    return name
}

HK_AddItem(ctrl, *) {
    global HotkeyDefs, HK_UserDefs, HK_CustomActivate, HK_CustomTarget, _hkFilteredIndices
    parentGui := ctrl.Gui
    result := HK_UserHotkeyEditor()
    if !IsObject(result)
        return
    idBase := "user_" HK_SanitizeId(result.action)
    id := idBase
    n := 2
    while IsObject(HK_FindDef(id)) {
        id := idBase "_" n
        n++
    }
    fnName := HK_SanitizeFnName(result.fn)
    scriptFile := result.scriptEnabled ? HK_WriteUserScript(fnName, result.script) : ""
    d := {id:id, group:"csp", def:result.key, desc:result.action, req:result.req, fnName:fnName, scriptFile:scriptFile, scriptEnabled:!!result.scriptEnabled, user:true, fn:HK_RunUserScript.Bind(id)}
    HK_UserDefs.Push(d)
    HotkeyDefs.Push(d)
    outside := result.activate ? "Yes" : "-"
    parentGui.lv.Add(, d.desc, HK_HotkeyCellText(d), HK_GetRequirement(d), HK_GetFnName(d), HK_Status(d.def, d.id), outside, HK_GetTarget(d.id), d.id)
    _hkFilteredIndices.Push(HotkeyDefs.Length)
    if result.activate
        HK_CustomActivate[id] := true
    newTarget := result.HasOwnProp("target") ? result.target : ""
    if newTarget != ""
        HK_CustomTarget[id] := newTarget
    HK_Save()
    HK_ReapplyAll()
    HK_UpdateDuplicates(parentGui.lv)
    HK_WarnCollisions()
    DebugLog("Added user hotkey " id " -> " (result.scriptEnabled ? scriptFile : "function mode"))
}

HK_DeleteItem(ctrl, *) {
    global HotkeyDefs, _hkFilteredIndices, HK_UserDefs, HK_Custom, HK_CustomFn, HK_CustomReq, HK_CustomActivate, HK_CustomTarget, HOTKEY_SETTINGS_FILE
    global HK_CustomBlock
    parentGui := ctrl.Gui
    lv := parentGui.lv
    rows := []
    r := 0
    while r := lv.GetNext(r)
        rows.Push(r)
    if rows.Length = 0 {
        HK_SelectPrompt()
        return
    }
    for row in rows {
        d := HK_DefForRow(lv, row)
        if !(d.HasOwnProp("user") && d.user) {
            ShowNotify("Delete", "Only user-added hotkeys can be deleted.")
            return
        }
    }
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Delete Hotkey")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)
    dlg.AddText("cFFD54F", "Delete selected user hotkeys?")
    dlg.AddText("xm y+" S(4) " cAAAAAA", "The .ahk script file will NOT be deleted.")
    result := false
    dlg.AddButton("xm y+10 w" S(80) " h" S(26) " cFFFFFF", "Yes").OnEvent("Click", (*) => (result := true, dlg.Destroy()))
    dlg.AddButton("x+8 yp w" S(80) " h" S(26), "No").OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("AutoSize")
    GuiWaitForCloseSafe(dlg)
    if !result
        return

    ; Collect user hotkeys to remove (iterate in reverse to avoid index issues)
    removeRows := []
    removeIndices := []
    for row in rows {
        d := HK_DefForRow(lv, row)
        idx := HK_IndexOfDef(d.id)
        if d.HasOwnProp("user") && d.user && idx > 0
            removeRows.Push({row:row, idx:idx, id:d.id})
    }
    ; Remove from listview in reverse row order
    i := removeRows.Length
    while i {
        lv.Delete(removeRows[i].row)
        i -= 1
    }
    ; Remove from HotkeyDefs, HK_UserDefs, and maps (reverse index order)
    removeIndices := []
    for item in removeRows
        removeIndices.Push(item.idx)
    ; removeIndices is already in ascending order from GetNext; iterate in reverse
    i := removeIndices.Length
    while i {
        idx := removeIndices[i]
        d := HotkeyDefs[idx]
        if d.HasOwnProp("user") && d.user {
            try HK_Custom.Delete(d.id)
            try HK_CustomFn.Delete(d.id)
            try HK_CustomReq.Delete(d.id)
            try HK_CustomActivate.Delete(d.id)
            try HK_CustomTarget.Delete(d.id)
            try HK_CustomBlock.Delete(d.id)
            try IniDelete(HOTKEY_SETTINGS_FILE, "UserHotkey_" d.id)
            for j, ud in HK_UserDefs {
                if ud.id = d.id {
                    HK_UserDefs.RemoveAt(j)
                    break
                }
            }
            HotkeyDefs.RemoveAt(idx)
        }
        i -= 1
    }
    HK_Save()
    HK_ReapplyAll()
    HK_RefreshSettingsList(parentGui)
}

HK_AddFillReqFromFn(reqEd, fnEd, *) {
    if Trim(reqEd.Value) = "" {
        scriptReq := HK_ScriptRequirementForFn(Trim(fnEd.Value))
        if scriptReq != ""
            reqEd.Value := HK_NormalizeRequirement(scriptReq)
    }
}

HK_UserHotkeyEditor() {
    dialogTitle := "Add Hotkey"
    primaryLabel := "Add"
    dlg := Gui("+AlwaysOnTop +ToolWindow", dialogTitle)
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s9 cFFFFFF", "Segoe UI")
    dlg.MarginX := 14
    dlg.MarginY := 14
    editW := 430
    displayW := 320
    btnW := 80
    footBtnW := 90

    dlg.AddText("xm", "Action Name:")
    actionEd := dlg.AddEdit("xm y+6 w" editW " c000000 BackgroundFFFFFF", "")
    dlg.AddText("xm y+10", "Hotkey:")
    keyEd := dlg.AddEdit("xm y+6 w" editW " c000000 BackgroundFFFFFF", "")
    dlg.AddText("xm y+4 w" editW " c888888", "Use | to separate multiple shortcuts for the same action, e.g. ^!F1|^F1. Advanced AHK prefixes are allowed, e.g. ~!D or $^1.")
    display := dlg.AddText("xm y+6 w" displayW+22 " h26 +0x200 Center cFFFFFF Background2D2D32", "")
    capBtn := dlg.AddButton("x+8 yp w" btnW " h26", "Record")
    conflictTxt := dlg.AddText("xm y+4 w" editW " cFFD166", "")
    capBtn.OnEvent("Click", (*) => HK_CaptureKey(dlg, keyEd, display, capBtn))
    keyEd.OnEvent("Change", (*) => (display.Text := keyEd.Value, conflictTxt.Text := HK_ConflictTextForKey(keyEd.Value)))

    dlg.AddText("xm y+10", "Requirement:")
    reqEd := dlg.AddEdit("xm y+6 w" editW " c000000 BackgroundFFFFFF", "")
    dlg.AddText("xm y+10", "AHK Function:")
    fnEd := dlg.AddEdit("xm y+6 w" editW " c000000 BackgroundFFFFFF", "")
    fnEd.OnEvent("Change", (*) => HK_AddFillReqFromFn(reqEd, fnEd))
    dlg.AddButton("xm y+6 w" footBtnW " h26", "Pick").OnEvent("Click", (*) => HK_FunctionPicker(fnEd))
    dlg.AddButton("x+8 yp w" footBtnW " h26", "Test Fn").OnEvent("Click", (*) => HK_TestFunctionAction(fnEd.Value, dialogTitle))
    dlg.AddButton("x+8 yp w" footBtnW " h26", "Fn Guide").OnEvent("Click", HK_ShowFunctionFieldGuide)
    dlg.AddText("xm y+4 w" editW " c888888", "Use Pick to browse callable functions, or type a function name that will be callable from the saved user script.")
    dlg.AddText("xm y+10", "Work outside CSP:")
    outsideCb := dlg.AddCheckbox("xm y+6 cAAAAAA", "Activate CSP when triggered from background")
    dlg.AddText("xm y+10", "Target window:")
    targetOpts := HK_TargetOptionList()
    targetLabels := []
    for o in targetOpts
        targetLabels.Push(o.label)
    targetDDL := dlg.AddDropDownList("xm y+6 w" editW " c000000 BackgroundFFFFFF", targetLabels)
    targetDDL.Choose(1)
    TargetVal() {
        for o in targetOpts
            if o.label = targetDDL.Value
                return o.val
        return ""
    }
    customScriptCb := dlg.AddCheckbox("xm y+10 cAAAAAA", "Use custom script (.ahk file)")
    dlg.AddText("xm y+4 w" editW " c888888", "OFF = call built-in/user function directly. ON = save and run the external .ahk script body.")
    dlg.AddText("xm y+10", "AHK Function Script:")
    scriptEd := dlg.AddEdit("xm y+6 w" editW " h160 c000000 BackgroundFFFFFF VScroll -Wrap", "")
    dlg.AddText("xm y+4 w" editW " c888888", "This script is saved outside the main file and runs as its own .ahk file.")
    ToggleCustomScriptControls(*) {
        scriptEd.Enabled := !!customScriptCb.Value
    }
    customScriptCb.OnEvent("Click", ToggleCustomScriptControls)
    ToggleCustomScriptControls()

    result := 0
    saved := false
    dlg.AddButton("xm y+12 w" footBtnW " h28 cFFFFFF Default", primaryLabel).OnEvent("Click", (*) => (
        saved := true,
        result := {action: Trim(actionEd.Value), key: Trim(keyEd.Value), req: Trim(reqEd.Value), fn: Trim(fnEd.Value), scriptEnabled: customScriptCb.Value, script: scriptEd.Value, activate: outsideCb.Value, target: TargetVal()},
        dlg.Destroy()
    ))
    dlg.AddButton("x+8 yp w" footBtnW " h28", "How To").OnEvent("Click", HK_AddHowTo)
    dlg.AddButton("x+8 yp w" footBtnW " h28", "Cancel").OnEvent("Click", (*) => dlg.Destroy())
    dlg.OnEvent("Close", (*) => saved ? "" : (result := 0))
    dlg.Show("w" S(520) " AutoSize")
    GuiWaitForCloseSafe(dlg)
    if !IsObject(result) || result.action = "" || result.key = "" || result.fn = "" {
        if IsObject(result)
            _HK_ResultPopup(dialogTitle, "Action name, hotkey, and AHK function are required.", "E53935")
        return 0
    }
    return result
}

HK_UserFunctionHowTo(*) {
    popup := Gui("+AlwaysOnTop +ToolWindow", "How To - User Script")
    popup.BackColor := "1E1F22"
    popup.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    popup.MarginX := S(14)
    popup.MarginY := S(14)
    txt := "
    (
User scripts are .ahk files saved in user_hotkey_scripts\.
They can be used as Pie/Quick Pie script actions and user hotkey functions.

EXAMPLE SCRIPT STRUCTURE:
  ; Summary: Short description shown in Function Browser
  ; Category: Guide | Pie | Color | Timer | Debug | Link | System | Toggle | User | GUI | Hotkey | Built-in | Runtime
  ; Risk: Needs Nastar | Needs CSP | Writes Files | Settings I/O | UI | User Script | Internal | External Target

  MyFunction(){
      ShowNotify("My Function", "Running")
  }
  ; CSP calls MyFunction() automatically via the wrapper.
  ; Add MyFunction() here only if you double-click the file to run standalone.

METADATA COMMENTS (optional but recommended):
  ; Summary:   One-line description. Appears in the Summary column.
  ; Category:  Groups your function in the Category filter.
  ; Risk:      Comma-separated badges warning about side effects.
              Needs Nastar     - requires Nastar.laf CSP AutoAction
              Needs CSP        - requires Clip Studio Paint to be running
              Writes Files     - creates or modifies files on disk
              Settings I/O     - reads or writes toolkit settings
              UI               - opens or manipulates GUI windows
              User Script      - calls custom user script code
              Internal         - for internal use, may change
              External Target  - opens a URL, file, or program

HELPER FUNCTIONS: ShowNotify(), DebugLog(), and the Notify class
are automatically available in standalone mode. No #Include needed.

SAVING: The script is saved as user_hotkey_scripts\FunctionName.ahk.
The function name in the file must match the function name you enter.
    )"
    popup.AddText("xm w" S(440) " cFFFFFF", txt)
    popup.AddButton("xm y+10 w" S(80) " h" S(26) " Default", "OK").OnEvent("Click", (*) => popup.Destroy())
    popup.Show("AutoSize")
}

HK_AddHowTo(*) {
    popup := Gui("+AlwaysOnTop +ToolWindow", "How To - Add Hotkey")
    popup.BackColor := "1E1F22"
    popup.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    popup.MarginX := S(14)
    popup.MarginY := S(14)

    txt := "
    (
HOTKEY MODIFIERS
  ^  = Ctrl
  +  = Shift
  !  = Alt
  #  = Win
  ~  = pass the key through to the active app
  $  = prevent this hotkey from triggering itself

Examples:
  ^!s     -> Ctrl+Alt+S
  +^!f   -> Shift+Ctrl+Alt+F
  !Space -> Alt+Space
  ^!+k   -> Ctrl+Alt+Shift+K
  ~!d    -> Alt+D and also let CSP receive Alt+D

Combine multiple keys:
  ^1     -> Ctrl+1
  ^+1    -> Ctrl+Shift+1

AHK FUNCTION
This is the name of the function that runs
when the hotkey is pressed.

Built-in functions you can call:
  ShowNotify("title", "subtitle", "color")
  Send("{key}")
  Run("path")

You can also write a custom script below.
The script runs as its own .ahk file when
the hotkey is pressed.

Function name examples:
  ExampleUserFunction
  ToggleSomething
  OpenMyTool

AHK FUNCTION SCRIPT
One or more lines of AutoHotkey v2 code.
The function you name above must exist here.

Example:
  ExampleUserFunction() {
      Send("^c")
      ShowNotify("User Function", "Copied")
  }

The script file is saved to:
  user_hotkey_scripts\YourFunctionName.ahk
    )"
    popup.AddText("xm w" S(380) " cFFFFFF", txt)
    popup.AddButton("xm y+10 w" S(80) " h" S(26) " Default", "OK").OnEvent("Click", (*) => popup.Destroy())
    popup.Show("AutoSize")
}

; Function Browser help popups live in src\gui\hotkey_function_browser.ahk


HK_EditItem(ctrl, *) {
    global HotkeyDefs, _hkFilteredIndices, HK_Custom, HK_CustomFn, HK_CustomReq, HK_CustomActivate, HK_CustomTarget, HK_CustomBlock, HK_UserDefs
    parentGui := ctrl.Gui
    lv := parentGui.lv
    row := lv.GetNext()
    if !row {
        HK_SelectPrompt()
        return
    }
    d := HK_DefForRow(lv, row)
    modeDefKey := HK_ModeDefaultKey(d.id, d.def)
    ApplyResult(result) {
        newKey := result.key
        newFn := Trim(result.fn)
        fnEnabled := result.HasOwnProp("fnEnabled") ? !!result.fnEnabled : true
        newReq := Trim(result.req)
        newActivate := result.activate
        if newKey = "" || newKey = modeDefKey {
            if HK_Custom.Has(d.id)
                try HK_Custom.Delete(d.id)
        } else
            HK_Custom[d.id] := newKey
        defFn := HK_GetDefaultFnName(d)
        defFnEnabled := HK_DefaultFnEnabled(d)
        if !fnEnabled {
            if defFnEnabled
                HK_CustomFn[d.id] := HK_FnDisabledMarker()
            else if HK_CustomFn.Has(d.id)
                try HK_CustomFn.Delete(d.id)
        } else if newFn = "" || newFn = defFn || newFn = "(inline)" {
            if defFnEnabled {
                if HK_CustomFn.Has(d.id)
                    try HK_CustomFn.Delete(d.id)
            } else
                HK_CustomFn[d.id] := defFn
        } else
            HK_CustomFn[d.id] := newFn
        if newReq = HK_DefaultRequirement(d) {
            if HK_CustomReq.Has(d.id)
                try HK_CustomReq.Delete(d.id)
        } else
            HK_CustomReq[d.id] := newReq
        defActivate := HK_DefaultActivate(d)
        if newActivate != defActivate {
            HK_CustomActivate[d.id] := !!newActivate
        } else {
            if HK_CustomActivate.Has(d.id)
                try HK_CustomActivate.Delete(d.id)
        }
        newTarget := result.HasOwnProp("target") ? result.target : ""
        if newTarget = "" {
            if HK_CustomTarget.Has(d.id)
                try HK_CustomTarget.Delete(d.id)
        } else
            HK_CustomTarget[d.id] := newTarget
        if result.HasOwnProp("block") && result.block {
            HK_CustomBlock[d.id] := true
        } else if HK_CustomBlock.Has(d.id) {
            try HK_CustomBlock.Delete(d.id)
        }
        if d.HasOwnProp("user") && d.user {
            d.desc := result.action
            d.def := newKey
            d.req := newReq
            if fnEnabled
                d.fnName := HK_SanitizeFnName(newFn)
            d.scriptEnabled := !!result.scriptEnabled
            d.scriptFile := result.scriptEnabled ? HK_WriteUserScript(d.fnName, result.script) : ""
            try HK_Custom.Delete(d.id)
            try HK_CustomReq.Delete(d.id)
        }
        lv.Modify(row, "Col1", d.desc)
        lv.Modify(row, "Col2", HK_HotkeyCellText(d))
        dup := HK_Status(HK_Get(d.id, d.def), d.id)
        lv.Modify(row, "Col3", HK_GetRequirement(d))
        lv.Modify(row, "Col4", HK_GetFnName(d))
        lv.Modify(row, "Col5", dup)
        lv.Modify(row, "Col6", HK_OutsideText(d.id))
        lv.Modify(row, "Col8", HK_EffectiveCellText(d))
        HK_UpdateDuplicates(lv)
        HK_Save()
        HK_ReapplyAll()
        HK_WarnCollisions()
    }
    result := HK_ChordEditor(d, ApplyResult, modeDefKey)
    if IsObject(result) && !(result.HasOwnProp("_alreadyApplied") && result._alreadyApplied) {
        ; Keep close-save behavior consistent with apply-in-place flow.
        ApplyResult(result)
    }
}

HK_ChordEditor(d, applyCallback := 0, modeDefKey := "") {
    dialogTitle := "Edit Hotkey"
    primaryLabel := "Save"
    dlg := Gui("+AlwaysOnTop +ToolWindow", dialogTitle)
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s9 cFFFFFF", "Segoe UI")
    dlg.MarginX := 14
    dlg.MarginY := 14
    editW := 430
    displayW := 320
    btnW := 80
    footBtnW := 90

    isUser := d.HasOwnProp("user") && d.user
    if modeDefKey = ""
        modeDefKey := d.def
    dlg.AddText("xm", "Action:")
    actionEd := dlg.AddEdit("xm y+6 w" editW " c000000 BackgroundFFFFFF" (isUser ? "" : " ReadOnly"), d.desc)
    actionEd.OnEvent("Change", (*) => applyBtn.Enabled := true)
    dlg.AddText("xm y+4 cAAAAAA", "Default: " HK_DisplayKey(modeDefKey))
    dlg.AddText("xm y+10", "Hotkey:")
    ed := dlg.AddEdit("xm y+6 w" editW " c000000 BackgroundFFFFFF", HK_Get(d.id, d.def))
    dlg.AddText("xm y+4 w" editW " c888888", "Use | to separate multiple shortcuts for the same action, e.g. ^!F1|^F1. Advanced AHK prefixes are allowed, e.g. ~!D or $^1.")
    UpdateChordConflict(*) {
        display.Text := ed.Value
        conflictTxt.Text := HK_ConflictTextForKey(ed.Value, d.id)
        applyBtn.Enabled := true
    }
    ed.OnEvent("Change", UpdateChordConflict)

    display := dlg.AddText("xm y+6 w" displayW+22 " h26 +0x200 Center cFFFFFF Background2D2D32", HK_Get(d.id, d.def))
    capBtn := dlg.AddButton("x+8 yp w" btnW " h26", "Record")
    conflictTxt := dlg.AddText("xm y+4 w" editW " cFFD166", "")
    capBtn.OnEvent("Click", (*) => HK_CaptureKey(dlg, ed, display, capBtn))

    currentFnName := HK_GetFnName(d)
    fnEnabledInitial := currentFnName != "(disabled)"
    dlg.AddText("xm y+10", "AHK Function:")
    fnEnabledCb := dlg.AddCheckbox("xm y+6 cAAAAAA Checked" (fnEnabledInitial ? 1 : 0), "Enable AHK Function")
    fnEnabledCb.OnEvent("Click", (*) => (
        fnEd.Enabled := !!fnEnabledCb.Value,
        fnPickBtn.Enabled := !!fnEnabledCb.Value,
        fnTestBtn.Enabled := !!fnEnabledCb.Value,
        fnGuideBtn.Enabled := !!fnEnabledCb.Value,
        applyBtn.Enabled := true
    ))
    fnEd := dlg.AddEdit("xm y+6 w" editW " c000000 BackgroundFFFFFF", fnEnabledInitial ? currentFnName : HK_GetDefaultFnName(d))
    fnEd.OnEvent("Change", (*) => applyBtn.Enabled := true)
    fnPickBtn := dlg.AddButton("xm y+6 w" footBtnW " h26", "Pick")
    fnPickBtn.OnEvent("Click", (*) => HK_FunctionPicker(fnEd))
    fnTestBtn := dlg.AddButton("x+8 yp w" footBtnW " h26", "Test Fn")
    fnTestBtn.OnEvent("Click", (*) => HK_TestFunctionAction(fnEd.Value, dialogTitle))
    fnGuideBtn := dlg.AddButton("x+8 yp w" footBtnW " h26", "Fn Guide")
    fnGuideBtn.OnEvent("Click", HK_ShowFunctionFieldGuide)
    fnEd.Enabled := fnEnabledInitial
    fnPickBtn.Enabled := fnEnabledInitial
    fnTestBtn.Enabled := fnEnabledInitial
    fnGuideBtn.Enabled := fnEnabledInitial
    dlg.AddText("xm y+4 w" editW " c888888", "Use Pick to browse existing callable functions, e.g. ToggleLTLock or HotkeyLayerBlack.")

    dlg.AddText("xm y+10", "Requirement:")
    reqEd := dlg.AddEdit("xm y+6 w" editW " c000000 BackgroundFFFFFF", HK_GetRequirement(d))
    reqEd.OnEvent("Change", (*) => applyBtn.Enabled := true)
    if isUser && d.HasOwnProp("scriptFile") && d.scriptFile != "" {
        scriptReq := HK_UserScriptRequirement(d.scriptFile)
        if scriptReq != "" && Trim(reqEd.Value) = ""
            reqEd.Value := HK_NormalizeRequirement(scriptReq)
    }

    dlg.AddText("xm y+10", "Work outside CSP:")
    outsideCb := dlg.AddCheckbox("xm y+6 cAAAAAA Checked" HK_GetActivate(d.id), "Activate CSP when triggered from background")
    outsideCb.OnEvent("Click", (*) => applyBtn.Enabled := true)

    dlg.AddText("xm y+10", "Block output to CSP:")
    blockCb := dlg.AddCheckbox("xm y+6 cAAAAAA Checked" (HK_IsBlockEnabled(d.id) ? 1 : 0), "Block this hotkey from reaching CSP (swallow key, do nothing)")
    blockCb.OnEvent("Click", (*) => applyBtn.Enabled := true)
    dlg.AddText("xm y+4 w" editW " c888888", "100% swallow: the key is consumed by the toolkit and CSP never sees it. Disabled (-) only passes the key through to CSP; Block fully eats it.")

    dlg.AddText("xm y+10", "Target window:")
    targetOpts := HK_TargetOptionList()
    targetLabels := []
    for o in targetOpts
        targetLabels.Push(o.label)
    targetDDL := dlg.AddDropDownList("xm y+6 w" editW " c000000 BackgroundFFFFFF", targetLabels)
    curTarget := HK_GetTarget(d.id)
    targetDDL.Choose(1)
    for i, o in targetOpts {
        if o.val = curTarget {
            targetDDL.Choose(i)
            break
        }
    }
    targetDDL.OnEvent("Change", (*) => applyBtn.Enabled := true)
    dlg.AddText("xm y+4 w" editW " c888888", "Hotkey fires when this window is active. Default = Clip Studio Paint. Manage targets with the Targets button.")
    TargetVal() {
        for o in targetOpts
            if o.label = targetDDL.Value
                return o.val
        return ""
    }

    scriptEd := 0
    customScriptCb := 0
    if isUser {
        body := HK_ReadUserScriptBody(d.scriptFile, d.fnName)
        customScriptCb := dlg.AddCheckbox("xm y+10 cAAAAAA Checked" ((d.HasOwnProp("scriptEnabled") ? d.scriptEnabled : (d.scriptFile != "")) ? 1 : 0), "Use custom script (.ahk file)")
        dlg.AddText("xm y+4 w" editW " c888888", "OFF = call built-in/user function directly. ON = save and run the external .ahk script body.")
        dlg.AddText("xm y+10", "AHK Function Script:")
        scriptEd := dlg.AddEdit("xm y+6 w" editW " h160 c000000 BackgroundFFFFFF VScroll -Wrap", body)
        scriptEd.OnEvent("Change", (*) => applyBtn.Enabled := true)
        ToggleUserScriptControls(*) {
            scriptEd.Enabled := !!customScriptCb.Value
            if IsSet(applyBtn)
                applyBtn.Enabled := true
        }
        customScriptCb.OnEvent("Click", ToggleUserScriptControls)
        ToggleUserScriptControls()
    }

    saved := false
    result := 0
    HKChordDlg_BuildResult() {
        return {action: actionEd.Value, key: ed.Value, req: reqEd.Value, fn: fnEd.Value, fnEnabled: fnEnabledCb.Value, scriptEnabled: IsObject(customScriptCb) ? customScriptCb.Value : false, script: IsObject(scriptEd) ? scriptEd.Value : "", activate: outsideCb.Value, block: blockCb.Value, target: TargetVal()}
    }
    DoApply(closeAfter := true) {
        localResult := HKChordDlg_BuildResult()
        if IsObject(applyCallback)
            applyCallback(localResult)
        if closeAfter {
            saved := true
            localResult._alreadyApplied := IsObject(applyCallback)
            result := localResult
            dlg.Destroy()
        } else {
            applyBtn.Enabled := false
            ShowNotify(dialogTitle, "Applied")
        }
    }
    applyBtn := dlg.AddButton("xm y+10 w" footBtnW " h26 cFFFFFF", primaryLabel)
    applyBtn.OnEvent("Click", (*) => DoApply(true))
    if IsObject(applyCallback)
        dlg.AddButton("x+8 yp w" footBtnW " h26", "Apply").OnEvent("Click", (*) => DoApply(false))
    dlg.AddButton("x+8 yp w" footBtnW " h26", "Cancel").OnEvent("Click", (*) => dlg.Destroy())
    dlg.AddButton("x+8 yp w" footBtnW " h26 cAAAAAA", "Reset").OnEvent("Click", (*) => (
        ed.Value := modeDefKey,
        display.Text := modeDefKey,
        fnEnabledCb.Value := HK_DefaultFnEnabled(d),
        fnEd.Enabled := HK_DefaultFnEnabled(d),
        fnPickBtn.Enabled := HK_DefaultFnEnabled(d),
        fnTestBtn.Enabled := HK_DefaultFnEnabled(d),
        fnGuideBtn.Enabled := HK_DefaultFnEnabled(d),
        fnEd.Value := HK_GetDefaultFnName(d),
        reqEd.Value := HK_DefaultRequirement(d),
        outsideCb.Value := HK_DefaultActivate(d),
        blockCb.Value := false,
        targetDDL.Choose(1),
        applyBtn.Enabled := true
    ))
    dlg.OnEvent("Close", (*) => (
        saved ? "" : (result := 0)
    ))
    UpdateChordConflict()
    dlg.Show("w" S(520) " AutoSize")
    GuiWaitForCloseSafe(dlg)
    return result
}

; Hotkey capture dialog lives in src\gui\hotkey_capture.ahk


HK_ResetItem(ctrl, *) {
    global HotkeyDefs, _hkFilteredIndices, HK_Custom, HK_CustomFn, HK_CustomReq, HK_CustomActivate, HK_CustomTarget, HK_CustomBlock, _SwapFirstDef, _SwapBtn
    _SwapFirstDef := 0
    if IsObject(_SwapBtn)
        _SwapBtn.Text := "Swap"
    parentGui := ctrl.Gui
    lv := parentGui.lv
    rows := []
    r := 0
    while r := lv.GetNext(r)
        rows.Push(r)
    if rows.Length = 0 {
        HK_SelectPrompt()
        return
    }
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Reset Selected Hotkeys")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)
    dlg.AddText("cFFD54F", "Reset selected hotkeys to defaults?")
    result := false
    dlg.AddButton("xm y+10 w" S(80) " h" S(26) " cFFFFFF", "Yes").OnEvent("Click", (*) => (result := true, dlg.Destroy()))
    dlg.AddButton("x+8 yp w" S(80) " h" S(26), "No").OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("AutoSize")
    GuiWaitForCloseSafe(dlg)
    if !result
        return
    modeDefaults := HK_LoadModeDefaults()
    for row in rows {
        d := HK_DefForRow(lv, row)
        if d.HasOwnProp("user") && d.user
            continue
        if modeDefaults.Has(d.id) && modeDefaults[d.id] != ""
            HK_Custom[d.id] := modeDefaults[d.id]
        else
            try HK_Custom.Delete(d.id)
        try HK_CustomFn.Delete(d.id)
        try HK_CustomReq.Delete(d.id)
        try HK_CustomActivate.Delete(d.id)
        try HK_CustomTarget.Delete(d.id)
        try HK_CustomBlock.Delete(d.id)
        lv.Modify(row, "Col2", HK_HotkeyCellText(d))
        lv.Modify(row, "Col3", HK_GetRequirement(d))
        lv.Modify(row, "Col4", HK_GetFnName(d))
        lv.Modify(row, "Col5", HK_Status(d.def, d.id))
        lv.Modify(row, "Col6", HK_OutsideText(d.id))
        lv.Modify(row, "Col8", HK_EffectiveCellText(d))
    }
    HK_UpdateDuplicates(lv)
    HK_Save()
    HK_ReapplyAll()
}

HK_ResetAll(ctrl, *) {
    global HotkeyDefs, _hkFilteredIndices, HK_Custom, HK_CustomFn, HK_CustomReq, HK_CustomActivate, HK_CustomTarget, HK_CustomBlock, _SwapFirstDef, _SwapBtn
    _SwapFirstDef := 0
    if IsObject(_SwapBtn)
        _SwapBtn.Text := "Swap"
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Reset All Hotkeys")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)
    dlg.AddText("cFFD54F", "Reset all hotkeys to mode defaults?")
    dlg.AddText("xm y+" S(4) " cAAAAAA", "Restores all hotkeys to this mode's original default settings.")
    result := false
    dlg.AddButton("xm y+10 w" S(80) " h" S(26) " cFFFFFF", "Yes").OnEvent("Click", (*) => (result := true, dlg.Destroy()))
    dlg.AddButton("x+8 yp w" S(80) " h" S(26), "No").OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("AutoSize")
    GuiWaitForCloseSafe(dlg)
    if !result
        return
    parentGui := ctrl.Gui
    lv := parentGui.lv
    modeDefaults := HK_LoadModeDefaults()
    HK_CustomFn := Map()
    HK_CustomReq := Map()
    HK_CustomActivate := Map()
    HK_CustomTarget := Map()
    HK_CustomBlock := Map()
    HK_Custom := Map()
    for id, val in modeDefaults
        HK_Custom[id] := val
    Loop lv.GetCount() {
        lvRow := A_Index
        d := HK_DefForRow(lv, lvRow)
        lv.Modify(lvRow, "Col2", HK_HotkeyCellText(d))
        lv.Modify(lvRow, "Col3", HK_GetRequirement(d))
        lv.Modify(lvRow, "Col4", HK_GetFnName(d))
        lv.Modify(lvRow, "Col5", HK_Status(d.def, d.id))
        lv.Modify(lvRow, "Col6", HK_OutsideText(d.id))
        lv.Modify(lvRow, "Col8", HK_EffectiveCellText(d))
    }
    HK_Save()
    HK_ReapplyAll()
}

HK_SaveAll(ctrl, *) {
    HK_Save()
    HK_ReapplyAll()
    HK_WarnCollisions()
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Hotkey Settings")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)
    dlg.AddText("c4CAF50", "Hotkey settings saved and applied.")
    dlg.AddButton("xm y+10 w" S(80) " h" S(26) " Default", "OK").OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("AutoSize")
}

ShowTargetWindowManager(ctrl := 0, *) {
    global HK_TargetWindows
    HK_EnsureTargetDefaults()
    dlg := Gui("+AlwaysOnTop +ToolWindow +Resize", "Target Windows")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(12)
    dlg.MarginY := S(12)
    dlg.AddText("xm", "Hotkeys can be assigned to fire in any of these target windows.")
    dlg.AddText("xm y+4 w" S(440) " cAAAAAA", "The default target is Clip Studio Paint and cannot be removed. Uncheck a window to deactivate its assignments. Separate multiple processes with | to make a target group.")
    lv := dlg.AddListView("xm y+8 w" S(440) " h" S(200) " Grid +Report", ["Window", "Process", "Enabled"])
    lv.SetFont("s" S(9) " c000000", "Segoe UI")
    lv.ModifyCol(1, S(190))
    lv.ModifyCol(2, S(180))
    lv.ModifyCol(3, S(70))
    RefreshList() {
        global HK_TargetWindows
        HK_EnsureTargetDefaults()
        lv.Delete()
        for wid, t in HK_TargetWindows {
            exe := t.Get("exe", "")
            name := t.Get("name", "")
            if name = ""
                name := exe != "" ? exe : wid
            lv.Add(, name, exe, t.Get("enabled", 0) ? "Enabled" : "Disabled")
        }
    }
    SelectedWid() {
        row := lv.GetNext()
        if !row {
            HK_SelectPrompt()
            return ""
        }
        i := 1
        for wid in HK_TargetWindows {
            if i = row
                return wid
            i++
        }
        return ""
    }
    ; Shared add/edit dialog. When picking a process, the cursor becomes a
    ; crosshair and clicking a window fills in its process name.
    TargetWindowDialog(exe := "", name := "", title := "Add Target Window") {
        global HK_TargetWindows
        mDlg := Gui("+AlwaysOnTop +ToolWindow", title)
        mDlg.BackColor := "1E1F22"
        mDlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
        mDlg.MarginX := S(12)
        mDlg.MarginY := S(12)
        mDlg.AddText("xm", "Process (exe):")
        exeEd := mDlg.AddEdit("xm y+6 w" S(300) " c000000 BackgroundFFFFFF", exe)
        mDlg.AddText("xm y+4 c888888", "e.g. Photoshop.exe  -  without the ahk_exe prefix.")
        mDlg.AddText("xm y+4 c888888", "Use | to group multiple processes.")
        mDlg.AddText("xm y+10", "Display name:")
        nameEd := mDlg.AddEdit("xm y+6 w" S(300) " c000000 BackgroundFFFFFF", name)
        mDlg.AddText("xm y+4 c888888", "Optional friendly name shown in the hotkey editor.")
        mAdded := false
        mExe := ""
        mName := ""
        PickProcess(ctrl, *) {
            exeEd.Enabled := false
            ctrl.Enabled := false
            oldText := ctrl.Text
            ctrl.Text := "..."
            ShowNotify("Pick Target Window", "Click a window to detect its process")
            hCross := DllCall("LoadCursor", "ptr", 0, "ptr", 32515, "ptr")
            DllCall("SetSystemCursor", "ptr", hCross, "uint", 32512)
            KeyWait("LButton", "D")
            DllCall("SystemParametersInfo", "uint", 0x0057, "uint", 0, "ptr", 0, "uint", 0)
            MouseGetPos(,, &pWin, , 2)
            exe := ""
            try exe := WinGetProcessName(pWin)
            catch
                exe := ""
            KeyWait("LButton")
            try ctrl.Text := oldText
            try ctrl.Enabled := true
            try exeEd.Enabled := true
            if exe = "" {
                ShowNotify("Pick Target Window", "Could not detect a process for that window")
                return
            }
            cur := Trim(exeEd.Value)
            if cur = "" {
                exeEd.Value := exe
            } else {
                for part in StrSplit(cur, "|") {
                    if StrLower(Trim(part)) = StrLower(exe) {
                        ShowNotify("Pick Target Window", "Process already in the group")
                        return
                    }
                }
                exeEd.Value := cur "|" exe
            }
            ShowNotify("Pick Target Window", "Picked: " exe)
        }
        mDlg.AddButton("xm y+12 w" S(95) " h" S(26), "Pick Process").OnEvent("Click", PickProcess)
        mDlg.AddButton("x+8 yp w" S(80) " h" S(26) " cFFFFFF Default", "OK").OnEvent("Click", (*) => (mAdded := true, mExe := exeEd.Value, mName := nameEd.Value, mDlg.Destroy()))
        mDlg.AddButton("x+8 yp w" S(80) " h" S(26), "Cancel").OnEvent("Click", (*) => mDlg.Destroy())
        mDlg.Show("AutoSize")
        GuiWaitForCloseSafe(mDlg)
        return {ok: mAdded, exe: mExe, name: mName}
    }
    AddManual(*) {
        r := TargetWindowDialog()
        if !r.ok
            return
        wid := HK_AddTargetWindow(r.exe, r.name)
        if wid = "" {
            ShowNotify("Target Windows", "Enter a valid process name (e.g. Photoshop.exe)")
            return
        }
        ShowNotify("Target Windows", "Added target: " (Trim(r.name) != "" ? Trim(r.name) : r.exe))
        RefreshList()
    }
    EditSel(*) {
        wid := SelectedWid()
        if wid = ""
            return
        t := HK_TargetWindows[wid]
        r := TargetWindowDialog(t.Get("exe", ""), t.Get("name", ""), "Edit Target Window")
        if !r.ok
            return
        norm := HK_NormalizeTargetExe(r.exe, wid)
        if norm = "" {
            ShowNotify("Target Windows", "Enter a valid process name not already used by another target")
            return
        }
        t["exe"] := norm
        t["name"] := Trim(r.name)
        RefreshList()
    }
    RemoveSel(*) {
        wid := SelectedWid()
        if wid = "" || wid = "win1" {
            if wid = "win1"
                ShowNotify("Target Windows", "The Clip Studio Paint target cannot be removed")
            return
        }
        HK_RemoveTargetWindow(wid)
        RefreshList()
    }
    ToggleSel(*) {
        wid := SelectedWid()
        if wid = ""
            return
        HK_SetTargetEnabled(wid, !HK_TargetWindows[wid].Get("enabled", 0))
        RefreshList()
    }
    ApplyAll(*) {
        HK_Save()
        HK_ReapplyAll()
    }
    RefreshList()
    lv.OnEvent("DoubleClick", ToggleSel)
    dlg.AddButton("xm y+10 w" S(75) " h" S(26), "Add Manual").OnEvent("Click", AddManual)
    dlg.AddButton("x+8 yp w" S(45) " h" S(26), "Edit").OnEvent("Click", EditSel)
    dlg.AddButton("x+8 yp w" S(100) " h" S(26), "Enable/Disable").OnEvent("Click", ToggleSel)
    dlg.AddButton("x+8 yp w" S(60) " h" S(26), "Remove").OnEvent("Click", RemoveSel)
    dlg.AddButton("x+8 yp w" S(60) " h" S(26) " cFFFFFF", "Apply").OnEvent("Click", ApplyAll)
    dlg.AddButton("x+8 yp w" S(60) " h" S(26), "Close").OnEvent("Click", (*) => (ApplyAll(), dlg.Destroy()))
    dlg.Show("AutoSize")
    GuiWaitForCloseSafe(dlg)
}

; Physically removes a single control from its GUI window. AHK v2 provides no
; method to delete individual controls (GuiControl.Destroy does not exist), so
; the control's own window is destroyed directly. The parent GUI still tracks
; the control, but its own later Destroy() tolerates the already-gone control
; and scripts must drop references to it (as RefreshPanel does).
_GuiDestroyControl(ctrl) {
    DllCall("DestroyWindow", "Ptr", ctrl.Hwnd)
}

; ---- Modes manager ----
ShowModeManager(ctrl := 0, *) {
    global HK_Modes, HK_ModeOrder, HK_Mode, HOTKEY_SETTINGS_FILE
    HK_LoadModes(ModeSettingsBaseFile("hotkey_settings.ini"))

    cellW := S(118)
    cellH := S(26)
    gap := S(6)
    gridW := cellW * 2 + gap

    dlg := Gui("+AlwaysOnTop", "Manage Modes")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(8) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(8)
    dlg.MarginY := S(6)

    sel := ""
    btns := Map()
    global _ShowAdvancedModes
    showAdvanced := !!_ShowAdvancedModes
    winW := gridW + S(16)
    winH := 0
    dNCW := 0
    dNCH := 0

    CloseNow(*) {
        dlg.Destroy()
    }
    SwitchNow(*) {
        global HK_Mode, HK_Modes
        id := sel
        if id = "" {
            ShowNotify("Modes", "Select a mode first")
            return
        }
        if HK_Mode = id {
            ShowNotify("Modes", HK_Modes[id].Get("name", id) " is already active")
            return
        }
        HK_SwitchMode(id)
        RefreshPanel()
    }
    EditSel(*) {
        id := sel
        if id = "" {
            ShowNotify("Modes", "Select a mode first")
            return
        }
        if id = "default" {
            ShowNotify("Modes", "Switch to another mode to edit its settings")
            return
        }
        HK_ModeEditor(id)
        RefreshPanel()
    }
    DeleteSel(*) {
        id := sel
        if id = "" {
            ShowNotify("Modes", "Select a mode first")
            return
        }
        if HK_IsSystemMode(id) {
            ShowNotify("Modes", HK_Modes[id].Get("name", id) " is a built-in mode and cannot be deleted")
            return
        }
        HK_DeleteMode(id)
        RefreshPanel()
    }
    CloneSel(*) {
        global HK_Modes, HK_ModeOrder, HOTKEY_SETTINGS_FILE
        id := sel
        if id = "" {
            ShowNotify("Modes", "Select a mode first")
            return
        }
        HK_CloneMode(id)
        RefreshPanel()
    }
    DiffSel(*) {
        id := sel
        if id = "" {
            ShowNotify("Modes", "Select a mode first")
            return
        }
        ShowModeDiff(id)
    }
    DiffAll(*) {
        ShowModeDiffOverview()
    }
    GuideSel(*) {
        GuideModeNotify()
    }
    BackupSel(*) {
        id := sel
        if id = "" || id = "default" {
            ShowNotify("Modes", "Select a custom mode first")
            return
        }
        try {
            CreateModeBackup(id)
        } catch as e {
            _HK_ResultPopup("Mode Backup Error", "Backup failed: " e.Message, "E53935")
        }
    }
    RestoreSel(*) {
        id := sel
        if id = "" || id = "default" {
            ShowNotify("Modes", "Select a custom mode first")
            return
        }
        ShowModeRestoreDialog(id)
    }
    ModeCellMenu(id, *) {
        ctx := Menu()
        ctx.Add("Edit", (*) => (sel := id, EditSel()))
        ctx.Add("Clone", (*) => (sel := id, CloneSel()))
        ctx.Add("Delete", (*) => (sel := id, DeleteSel()))
        ctx.Add()
        ctx.Add("Backup", (*) => (sel := id, BackupSel()))
        ctx.Add("Restore", (*) => (sel := id, RestoreSel()))
        ctx.Add()
        ctx.Add("Diff vs Default", (*) => (sel := id, DiffSel()))
        ctx.Show()
    }
    AddMode(*) {
        global HK_Modes, HK_ModeOrder
        aDlg := Gui("+AlwaysOnTop +ToolWindow", "Add Mode")
        aDlg.BackColor := "1E1F22"
        aDlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
        aDlg.MarginX := S(12)
        aDlg.MarginY := S(12)
        aDlg.AddText("xm", "Mode name:")
        nameEd := aDlg.AddEdit("xm y+6 w" S(300) " c000000 BackgroundFFFFFF", "")
        aDlg.AddText("xm y+4 c888888", "e.g. Inking, Cleaning, Backgrounds")
        aDlg.AddText("xm y+10", "Switch hotkey:")
        swEd := aDlg.AddEdit("xm y+6 w" S(180) " c000000 BackgroundFFFFFF", "")
        swDisplay := aDlg.AddText("xm y+6 w" S(96) " h26 +0x200 Center cFFFFFF Background2D2D32", "")
        swCapBtn := aDlg.AddButton("x+8 yp w" S(80) " h26", "Record")
        swCapBtn.OnEvent("Click", (*) => HK_CaptureKey(aDlg, swEd, swDisplay, swCapBtn))
        aDlg.AddText("xm y+4 w" S(300) " c888888", "Record captures the key. Leave blank for no switch hotkey.")
        aAdded := false
        aName := ""
        aSwitch := ""
        aDlg.AddButton("xm y+12 w" S(80) " h" S(26) " cFFFFFF Default", "Add").OnEvent("Click", (*) => (aAdded := true, aName := Trim(nameEd.Value), aSwitch := Trim(swEd.Value), aDlg.Destroy()))
        aDlg.AddButton("x+8 yp w" S(80) " h" S(26), "Cancel").OnEvent("Click", (*) => aDlg.Destroy())
        aDlg.Show("AutoSize")
        GuiWaitForCloseSafe(aDlg)
        if !aAdded
            return
        name := aName
        if name = "" {
            ShowNotify("Modes", "Enter a mode name")
            return
        }
        id := HK_NextModeId()
        HK_Modes[id] := Map("name", name, "switch", aSwitch, "overrides", Map(), "color", "")
        HK_ModeOrder.Push(id)
        HK_SaveModes()
        HK_ReapplyAll()
        sel := id
        RefreshPanel()
        ShowNotify("Modes", "Added mode: " name)
    }
    RefreshPanel() {
        global HK_Modes, HK_ModeOrder, HK_Mode
        for _, b in btns
            _GuiDestroyControl(b)
        btns := Map()
        y := S(6) + gap
        col := 0
        row := 0
        for id in HK_ModeOrder {
            if !HK_Modes.Has(id)
                continue
            if !HK_ShowModeInPicker(id, showAdvanced, HK_Mode)
                continue
            m := HK_Modes[id]
            name := m.Get("name", id)
            isActive := id = HK_Mode
            isSel := id = sel
            modeColor := m.Get("color", "")
            bg := isActive ? (modeColor != "" ? PieSafeColor(modeColor) : "3949AB") : (isSel ? "555555" : "2D2D32")
            b := dlg.AddText("xm w" cellW " h" cellH " Center +0x200 Background" bg " cFFFFFF", name)
            b.SetFont("s" S(7) " Bold", "Segoe UI")
            b.Move(S(8) + col * (cellW + gap), y + row * (cellH + gap), cellW, cellH)
            sw := m.Get("switch", "")
            hover := name "`nClick to select"
            if sw != ""
                hover .= "`nSwitch: " HK_DisplayKey(sw)
            hover .= "`nHotkeys: edit normally while this mode is active"
            if isActive
                hover .= "`n(active mode)"
            hover .= "`nRight-click: actions"
            AddHoverPopup(b, hover)
            b.OnEvent("Click", SelectMode.Bind(id))
            b.OnEvent("ContextMenu", ModeCellMenu.Bind(id))
            btns[id] := b
            col++
            if col = 2 {
                col := 0
                row++
            }
        }
        if col != 0
            row++
        yGrid := y + row * (cellH + gap)

        btnAdd := dlg.AddText("xm w" gridW " h" cellH " Center +0x200 Background455A64 cFFFFFF", "+ New Mode")
        btnAdd.SetFont("s" S(7) " Bold", "Segoe UI")
        btnAdd.Move(S(8), yGrid, gridW, cellH)
        AddHoverPopup(btnAdd, "Create a new custom mode")
        btnAdd.OnEvent("Click", AddMode)
        btns["__add"] := btnAdd

        fw := (gridW - 5 * gap) // 6
        fx := S(8)
        fy := yGrid + cellH + gap
        for spec in [["Switch", SwitchNow, "Switch to the selected mode"], ["Edit", EditSel, "Edit the selected mode"], ["Clone", CloneSel, "Duplicate the selected mode"], ["Diff", DiffSel, "Compare the selected mode to Default"], ["Delete", DeleteSel, "Delete the selected mode"], ["Close", CloseNow, "Close"]]
        {
            isSwitch := spec[1] = "Switch"
            bg := isSwitch ? "4CAF50" : "2D2D32"
            b := dlg.AddText("xm w" fw " h" cellH " Center +0x200 Background" bg " cFFFFFF", spec[1])
            b.SetFont("s" S(7) " Bold", "Segoe UI")
            b.Move(fx, fy, fw, cellH)
            AddHoverPopup(b, spec[3])
            b.OnEvent("Click", spec[2])
            btns["__foot" fx] := b
            fx += fw + gap
        }

        fw2 := (gridW - gap) // 2
        fx2 := S(8)
        fy2 := fy + cellH + gap
        for spec in [["Guide", GuideSel, "Open the Modes guide"], ["Diff All", DiffAll, "List differences of every mode vs Default"]]
        {
            b := dlg.AddText("xm w" fw2 " h" cellH " Center +0x200 Background2D2D32 cFFFFFF", spec[1])
            b.SetFont("s" S(7) " Bold", "Segoe UI")
            b.Move(fx2, fy2, fw2, cellH)
            AddHoverPopup(b, spec[3])
            b.OnEvent("Click", spec[2])
            btns["__foot2" fx2] := b
            fx2 += fw2 + gap
        }

        ; built-in system modes are hidden behind the advanced filter. Relative
        ; y+ positioning chains off the GUI's layout anchor (which still holds
        ; destroyed controls), so every control here is placed with an explicit
        ; Move and the window is resized from the checkbox's live position.
        chkAdvOpts := "+Background1E1F22 cAAAAAA" (showAdvanced ? " Checked" : "")
        chkAdv := dlg.AddCheckbox(chkAdvOpts, "Show advanced (built-in) modes")
        chkAdv.SetFont("s" S(6) " cAAAAAA", "Segoe UI")
        chkAdv.Move(S(8), fy2 + cellH + gap, gridW, S(18))
        chkAdv.OnEvent("Click", (*) => (showAdvanced := !showAdvanced, _ShowAdvancedModes := showAdvanced, HK_SaveShowAdvancedModesState(), RefreshPanel()))
        btns["__adv"] := chkAdv
        chkAdv.GetPos(&chx, &chy, &chw, &chh)
        winW := gridW + S(16)
        winH := chy + chh + S(6)
        dlg.Move(, , winW + dNCW, winH + dNCH)
    }
    SelectMode(id, *) {
        sel := id
        RefreshPanel()
    }

    RefreshPanel()
    dlg.Show("Center w" winW " h" winH)
    dlg.GetPos(, , &ow, &oh)
    dNCW := ow - winW
    dNCH := oh - winH
    GuiWaitForCloseSafe(dlg)
}

; Mode selection GUI: quick switch between modes. Compact borderless panel.
ShowModeSelector(ctrl := 0, *) {
    global HK_Modes, HK_ModeOrder, HK_Mode, HOTKEY_SETTINGS_FILE, ModeDragHandles, _ShowAdvancedModes
    HK_LoadModes(ModeSettingsBaseFile("hotkey_settings.ini"))

    cellW := S(118)
    cellH := S(26)
    gap := S(6)
    gridW := cellW * 2 + gap

    dlg := Gui("+AlwaysOnTop -Caption +ToolWindow", "Select Mode")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(8) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(8)
    dlg.MarginY := S(6)

    showAdvanced := !!_ShowAdvancedModes
    firstRender := true
    winW := gridW + S(16)
    winH := 0
    cells := []
    sel := ""

    CloseNow(*) {
        global ModeDragHandles
        try ModeDragHandles.Delete(hdr.Hwnd)
        dlg.Destroy()
    }
    SwitchNow(*) {
        global HK_Mode, HK_Modes
        id := sel
        if id = "" {
            ShowNotify("Select Mode", "Select a mode first")
            return
        }
        if HK_Mode = id {
            ShowNotify("Select Mode", HK_Modes[id].Get("name", id) " is already active")
            return
        }
        HK_SwitchMode(id)
        CloseNow()
    }
    SelectModeCell(id, *) {
        sel := id
        RefreshPanel()
    }

    hdr := dlg.AddText("xm w" (gridW - S(26)) " h" S(18) " Center c888888 +0x200 Background2A2A2A", "SELECT MODE")
    hdr.SetFont("s" S(7) " Bold", "Segoe UI")
    ModeDragHandles[hdr.Hwnd] := dlg.Hwnd
    btnX := dlg.AddText("x+" S(4) " yp w" S(22) " h" S(18) " Center +0x200 BackgroundE53935 cFFFFFF", "✕")
    btnX.SetFont("s" S(7) " Bold", "Segoe UI")
    AddHoverPopup(btnX, "Close")
    btnX.OnEvent("Click", CloseNow)

    RefreshPanel() {
        global HK_Modes, HK_ModeOrder, HK_Mode
        for _, c in cells
            _GuiDestroyControl(c)
        cells := []
        y := S(6) + S(18) + gap
        col := 0
        row := 0
        for id in HK_ModeOrder {
            if !HK_Modes.Has(id)
                continue
            if !HK_ShowModeInPicker(id, showAdvanced, HK_Mode)
                continue
            m := HK_Modes[id]
            name := m.Get("name", id)
            isActive := id = HK_Mode
            isSel := id = sel
            modeColor := m.Get("color", "")
            bg := isActive ? (modeColor != "" ? PieSafeColor(modeColor) : "3949AB") : (isSel ? "555555" : "2D2D32")
            b := dlg.AddText("xm w" cellW " h" cellH " Center +0x200 Background" bg " cFFFFFF", name)
            b.SetFont("s" S(7) " Bold", "Segoe UI")
            b.Move(S(8) + col * (cellW + gap), y + row * (cellH + gap), cellW, cellH)
            sw := m.Get("switch", "")
            hover := name "`nClick to select"
            if sw != ""
                hover .= "`nSwitch: " HK_DisplayKey(sw)
            hover .= "`nHotkeys: edit normally while this mode is active"
            if isActive
                hover .= "`n(active mode)"
            AddHoverPopup(b, hover)
            b.OnEvent("Click", SelectModeCell.Bind(id))
            cells.Push(b)
            col := 1 - col
            if col = 0
                row++
        }
        if col != 0
            row++
        yGrid := y + row * (cellH + gap)

        btnSwitch := dlg.AddText("xm w" cellW " h" cellH " Center +0x200 Background3949AB cFFFFFF", "Switch")
        btnSwitch.SetFont("s" S(7) " Bold", "Segoe UI")
        btnSwitch.Move(S(8), yGrid, cellW, cellH)
        AddHoverPopup(btnSwitch, "Switch to selected mode")
        btnSwitch.OnEvent("Click", SwitchNow)
        cells.Push(btnSwitch)

        btnManage := dlg.AddText("xm w" cellW " h" cellH " Center +0x200 Background455A64 cFFFFFF", "Manage")
        btnManage.SetFont("s" S(7) " Bold", "Segoe UI")
        btnManage.Move(S(8) + cellW + gap, yGrid, cellW, cellH)
        AddHoverPopup(btnManage, "Add, edit or delete modes")
        btnManage.OnEvent("Click", (*) => (CloseNow(), ShowModeManager()))
        cells.Push(btnManage)

        yBtn2 := yGrid + cellH + gap

        btnClose := dlg.AddText("xm w" (cellW * 2 + gap) " h" cellH " Center +0x200 Background2D2D32 cFFFFFF", "Close")
        btnClose.SetFont("s" S(7) " Bold", "Segoe UI")
        btnClose.Move(S(8), yBtn2, cellW * 2 + gap, cellH)
        AddHoverPopup(btnClose, "Close without switching")
        btnClose.OnEvent("Click", CloseNow)
        cells.Push(btnClose)

        btnCheat := dlg.AddText("xm w" (cellW * 2 + gap) " h" cellH " Center +0x200 Background455A64 cFFFFFF", "Hotkey Cheat Sheet")
        btnCheat.SetFont("s" S(7) " Bold", "Segoe UI")
        btnCheat.Move(S(8), yBtn2 + cellH + gap, cellW * 2 + gap, cellH)
        AddHoverPopup(btnCheat, "Toggle the per-mode hotkey cheat sheet overlay")
        btnCheat.OnEvent("Click", HK_CheatSheetToggle)
        cells.Push(btnCheat)

        chkAdvOpts := "+Background1E1F22 cAAAAAA" (showAdvanced ? " Checked" : "")
        chkAdv := dlg.AddCheckbox(chkAdvOpts, "Show advanced (built-in) modes")
        chkAdv.SetFont("s" S(6) " cAAAAAA", "Segoe UI")
        chkAdv.Move(S(8), yBtn2 + cellH * 2 + gap * 2, cellW * 2, S(18))
        chkAdv.OnEvent("Click", (*) => (showAdvanced := !showAdvanced, _ShowAdvancedModes := showAdvanced, HK_SaveShowAdvancedModesState(), RefreshPanel()))
        cells.Push(chkAdv)

        chkAdv.GetPos(&chx, &chy, &chw, &chh)
        winW := gridW + S(16)
        winH := chy + chh + S(6)
        if !firstRender
            dlg.Move(, , winW, winH)
        else
            firstRender := false
    }

    RefreshPanel()
    CoordMode("Mouse", "Screen")
    MouseGetPos(&mx, &my)
    monCount := MonitorGet()
    centerX := 0
    centerY := 0
    Loop monCount {
        MonitorGet(A_Index, &mLeft, &mTop, &mRight, &mBottom)
        if mx >= mLeft && mx < mRight && my >= mTop && my < mBottom {
            centerX := mLeft + (mRight - mLeft) // 2 - winW // 2
            centerY := mTop + (mBottom - mTop) // 2 - winH // 2
            break
        }
    }
    if centerX = 0 && centerY = 0 {
        MonitorGet(1, &mLeft, &mTop, &mRight, &mBottom)
        centerX := mLeft + (mRight - mLeft) // 2 - winW // 2
        centerY := mTop + (mBottom - mTop) // 2 - winH // 2
    }
    dlg.Show("x" centerX " y" centerY " w" winW " h" winH " NoActivate")
    GuiWaitForCloseSafe(dlg)
}

HK_NextModeId() {
    global HK_Modes
    i := 1
    loop {
        id := "mode" i
        if !HK_Modes.Has(id)
            return id
        i++
    }
}

HK_DeleteMode(id) {
    global HK_Modes, HK_ModeOrder, HK_Mode, HOTKEY_SETTINGS_FILE
    if HK_IsSystemMode(id) || !HK_Modes.Has(id)
        return false
    try HK_Modes.Delete(id)
    for i, mid in HK_ModeOrder {
        if mid = id {
            HK_ModeOrder.RemoveAt(i)
            break
        }
    }
    if HK_Mode = id {
        HK_Mode := "default"
        ModeSettingsSwitchTo("default")
    }
    try IniDelete(HOTKEY_SETTINGS_FILE, "Mode_" id)
    try IniDelete(ModeSettingsBaseFile("hotkey_settings.ini"), "Mode_" id)
    ModeSettingsDelete(id)
    HK_SaveModes()
    HK_Load()
    HK_ReapplyAll()
    try UpdateMainModeButton()
    try UpdateIBModeIndicator()
    return true
}

; Duplicates a mode: fresh id, copied override map, own settings folder seeded
; from the source mode's snapshot. The clone gets no switch hotkey so it can
; never collide with the source's. Returns the new id ("" on failure).
HK_CloneMode(id) {
    global HK_Modes, HK_ModeOrder
    if !HK_Modes.Has(id)
        return ""
    newId := HK_NextModeId()
    src := HK_Modes[id]
    newName := src.Get("name", id)
    if newName = id || newName = ""
        newName := id
    newName .= " Copy"
    HK_Modes[newId] := Map("name", newName, "switch", "", "overrides", Map(), "color", "")
    HK_ModeOrder.Push(newId)
    HK_SaveModes()
    ; Seed the clone's settings folder from the source's snapshot (or from the
    ; base settings when the source never got its own folder).
    dir := ModeSettingsModeDir(newId)
    try {
        if !DirExist(dir)
            DirCreate(dir)
    }
    srcDir := ModeSettingsModeDir(id)
    if id = "default" || !DirExist(srcDir)
        ModeSettingsCopyBaseTo(newId)
    else {
        for name in ["pie_settings.ini", "hotkey_settings.ini", "link_settings.ini", "mode_flags.ini"] {
            if FileExist(srcDir "\" name)
                try FileCopy(srcDir "\" name, dir "\" name, 1)
        }
    }
    HK_Load()
    HK_ReapplyAll()
    try UpdateMainModeButton()
    try UpdateIBModeIndicator()
    ShowNotify("Modes", "Cloned '" src.Get("name", id) "' as '" newName "'")
    return newId
}

; ---- Mode diff ----
; Parses an INI section body into a key/value map (raw text, so array/object
; syntax survives as text — good enough for comparing snapshots).
HK_DiffParseSection(raw) {
    m := Map()
    for line in StrSplit(raw, "`n", "`r") {
        eq := InStr(line, "=")
        if !eq
            continue
        k := Trim(SubStr(line, 1, eq - 1))
        v := Trim(SubStr(line, eq + 1))
        if k != ""
            m[k] := v
    }
    return m
}

; Diffs one section across two INI files. Returns rows of
; [key, baseVal, modeVal, changed]; changed is true when the key differs or
; exists only in the mode file (base keys removed by the mode are still shown).
HK_IniSectionDiff(basePath, modePath, section) {
    try bRaw := IniRead(basePath, section)
    catch
        bRaw := ""
    try mRaw := IniRead(modePath, section)
    catch
        mRaw := ""
    bMap := HK_DiffParseSection(bRaw)
    mMap := HK_DiffParseSection(mRaw)
    keys := []
    seen := Map()
    for k in bMap {
        if !seen.Has(k) {
            keys.Push(k)
            seen[k] := true
        }
    }
    for k in mMap {
        if !seen.Has(k) {
            keys.Push(k)
            seen[k] := true
        }
    }
    rows := []
    for k in keys {
        bv := bMap.Get(k, "")
        mv := mMap.Get(k, "")
        rows.Push([k, bv, mv, !bMap.Has(k) || bv != mv])
    }
    return rows
}

; Parses an INI file body into Map(section -> Map(key -> value)).
HK_DiffParseFile(raw) {
    result := Map()
    current := ""
    for line in StrSplit(raw, "`n", "`r") {
        if RegExMatch(line, "^\[(.+)\]\s*$", &m) {
            current := m[1]
            if !result.Has(current)
                result[current] := Map()
            continue
        }
        eq := InStr(line, "=")
        if !eq || current = ""
            continue
        k := Trim(SubStr(line, 1, eq - 1))
        v := Trim(SubStr(line, eq + 1))
        if k != ""
            result[current][k] := v
    }
    return result
}

; Reads a hotkey_settings.ini [Hotkeys] section into a Map of def-id -> key using
; the same id/value normalization HK_Load applies, so a mode-vs-default diff
; matches the runtime effective keys.
HK_DiffHotkeysFile(path) {
    m := Map()
    try {
        raw := FileRead(path)
    } catch {
        return m
    }
    section := ""
    for line in StrSplit(raw, "`n", "`r") {
        if RegExMatch(line, "^\[(.+)\]\s*$", &sec) {
            section := sec[1]
            continue
        }
        eq := InStr(line, "=")
        if !eq || section != "Hotkeys"
            continue
        id := HK_NormalizeSavedHotkeyId(Trim(SubStr(line, 1, eq - 1)))
        val := HK_NormalizeSavedHotkeyValue(id, Trim(SubStr(line, eq + 1)))
        m[id] := val
    }
    if m.Get("reset_mods", "") = "^!+Space"
        m["reset_mods"] := "^!+Backspace"
    return m
}

; Diffs two INI files across every section. Returns only changed rows of
; [category, section/key, baseVal, modeVal].
HK_IniFileDiff(basePath, modePath, cat) {
    bMap := Map()
    mMap := Map()
    try {
        bMap := HK_DiffParseFile(FileRead(basePath))
    } catch {
    }
    try {
        mMap := HK_DiffParseFile(FileRead(modePath))
    } catch {
    }
    sections := []
    seen := Map()
    for sec in bMap {
        if !seen.Has(sec) {
            sections.Push(sec)
            seen[sec] := true
        }
    }
    for sec in mMap {
        if !seen.Has(sec) {
            sections.Push(sec)
            seen[sec] := true
        }
    }
    rows := []
    for sec in sections {
        bk := bMap.Get(sec, Map())
        mk := mMap.Get(sec, Map())
        keys := []
        keySeen := Map()
        for k in bk {
            if !keySeen.Has(k) {
                keys.Push(k)
                keySeen[k] := true
            }
        }
        for k in mk {
            if !keySeen.Has(k) {
                keys.Push(k)
                keySeen[k] := true
            }
        }
        for k in keys {
            bv := bk.Get(k, "")
            mv := mk.Get(k, "")
            if !bk.Has(k) || bv != mv
                rows.Push([cat, sec "/" k, bv, mv])
        }
    }
    return rows
}

; Builds the diff rows for a custom mode vs the Default (base) configuration.
; Groups: "Hotkeys", "Pie", "Links" and "Color".
; Each mode keeps its own keys in <mode>\hotkey_settings.ini, so the hotkey
; comparison must read the files directly - HK_Custom only holds the currently
; active mode's keys and cannot represent another mode. The Default mode owns
; the base files (settings\hotkey_settings.ini etc.), so its "mode copy" is the
; base file itself and there is nothing to compare for the folder categories.
HK_ModeDiffRows(id, &catCounts) {
    global HotkeyDefs
    rows := []
    catCounts := Map("Hotkeys", 0, "Pie", 0, "Links", 0, "Color", 0)
    m := HK_Modes.Get(id, 0)
    if !IsObject(m)
        return rows
    baseHot := ModeSettingsBaseFile("hotkey_settings.ini")
    modeHot := id = "default" ? baseHot : ModeSettingsModeDir(id) "\hotkey_settings.ini"
    bKeys := HK_DiffHotkeysFile(baseHot)
    mKeys := HK_DiffHotkeysFile(modeHot)
    for d in HotkeyDefs {
        base := bKeys.Get(d.id, "")
        eff := mKeys.Get(d.id, "")
        if base = ""
            base := d.def
        if eff = ""
            eff := d.def
        if base != eff
            rows.Push(["Hotkeys", d.desc, HK_DisplayKey(base), HK_DisplayKey(eff)])
    }
    for cat, name in Map("Pie", "pie_settings.ini", "Links", "link_settings.ini", "Color", "color_settings.ini") {
        baseFile := ModeSettingsBaseFile(name)
        modeFile := id = "default" ? baseFile : ModeSettingsModeDir(id) "\" name
        for r in HK_IniFileDiff(baseFile, modeFile, cat)
            rows.Push(r)
    }
    for r in rows
        catCounts[r[1]] := catCounts.Get(r[1], 0) + 1
    return rows
}

; Diff dialog: shows what a mode changes vs the Default configuration.
ShowModeDiff(id) {
    global HK_Modes
    m := HK_Modes.Get(id, 0)
    if !IsObject(m) {
        ShowNotify("Modes", "Mode not found")
        return
    }
    rows := HK_ModeDiffRows(id, &catCounts)
    if rows.Length = 0 {
        ShowNotify("Modes", "No differences vs Default for '" m.Get("name", id) "'")
        return
    }
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Mode Diff: " m.Get("name", id))
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(12)
    dlg.MarginY := S(12)
    dlg.AddText("cFFD54F", "Changes applied by mode '" m.Get("name", id) "' vs Default")
    dlg.AddText("xm y+4 cAAAAAA", "Hotkeys: " catCounts["Hotkeys"] "   Pie: " catCounts["Pie"] "   Links: " catCounts["Links"] "   Color: " catCounts["Color"])
    lv := dlg.AddListView("xm y+8 w" S(760) " h" S(330) " Grid +Report", ["Category", "Item", "Base", "Mode"])
    lv.SetFont("s" S(9) " c000000", "Segoe UI")
    lv.ModifyCol(1, S(90))
    lv.ModifyCol(2, S(280))
    lv.ModifyCol(3, S(150))
    lv.ModifyCol(4, S(150))
    for r in rows
        lv.Add(, r[1], r[2], r[3], r[4])
    dlg.AddButton("xm y+10 w" S(80) " h" S(26) " cFFFFFF", "Close").OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("AutoSize")
    GuiWaitForCloseSafe(dlg)
}

; Overview popup: lists every mode with its difference count vs Default and
; opens the detailed diff for a chosen mode.
ShowModeDiffOverview(*) {
    global HK_Modes, HK_ModeOrder, HK_Mode, _ShowAdvancedModes
    HK_LoadModes(ModeSettingsBaseFile("hotkey_settings.ini"))
    showAdvanced := !!_ShowAdvancedModes
    modeIds := []
    for id in HK_ModeOrder {
        if !HK_Modes.Has(id)
            continue
        if !HK_ShowModeInPicker(id, showAdvanced, HK_Mode)
            continue
        modeIds.Push(id)
    }
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Mode Differences")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(12)
    dlg.MarginY := S(12)
    dlg.AddText("cFFD54F", "Mode differences vs Default")
    dlg.AddText("xm y+4 cAAAAAA", "Select a mode and click 'Open Diff' (or double-click) for the full change list.")
    lv := dlg.AddListView("xm y+8 w" S(620) " h" S(250) " Grid +Report +ReadOnly NoSortHdr", ["Mode", "Status", "Hotkeys", "Pie", "Links", "Color", "Total"])
    lv.SetFont("s" S(9) " c000000", "Segoe UI")
    lv.ModifyCol(1, S(180))
    lv.ModifyCol(2, S(70))
    lv.ModifyCol(3, S(70))
    lv.ModifyCol(4, S(60))
    lv.ModifyCol(5, S(60))
    lv.ModifyCol(6, S(60))
    lv.ModifyCol(7, S(60))
    for id in modeIds {
        m := HK_Modes[id]
        HK_ModeDiffRows(id, &cc)
        total := cc.Get("Hotkeys", 0) + cc.Get("Pie", 0) + cc.Get("Links", 0) + cc.Get("Color", 0)
        status := id = HK_Mode ? "Active" : ""
        lv.Add(, m.Get("name", id), status, cc.Get("Hotkeys", 0), cc.Get("Pie", 0), cc.Get("Links", 0), cc.Get("Color", 0), total)
    }
    if modeIds.Length = 0
        lv.Add(, "(no modes)", "", 0, 0, 0, 0, 0)
    OpenDiff(*) {
        idx := lv.GetNext()
        if idx < 1 || idx > modeIds.Length {
            ShowNotify("Modes", "Select a mode first")
            return
        }
        ShowModeDiff(modeIds[idx])
    }
    lv.OnEvent("DoubleClick", OpenDiff)
    dlg.AddButton("xm y+10 w" S(100) " h" S(26) " cFFFFFF", "Open Diff").OnEvent("Click", OpenDiff)
    dlg.AddButton("x+8 yp w" S(80) " h" S(26), "Close").OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("AutoSize")
    GuiWaitForCloseSafe(dlg)
}

ShowApplyBlockEditor(modeId) {
    global HK_ApplyBlock, HK_CaptureMode, HOTKEY_SETTINGS_FILE
    HK_CaptureMode := 0
    ; Ensure HOTKEY_SETTINGS_FILE points to the target mode's settings
    ModeSettingsRetarget(modeId)
    ; Reload HK_ApplyBlock from the mode-specific INI
    HK_ApplyBlock := Map()
    try {
        abSection := IniRead(HOTKEY_SETTINGS_FILE, "ApplyBlock")
    } catch
        abSection := ""
    if abSection != "" {
        for line in StrSplit(abSection, "`n") {
            if !InStr(line, "=")
                continue
            keyName := Trim(SubStr(line, 1, InStr(line, "=") - 1))
            scope := Trim(SubStr(line, InStr(line, "=") + 1))
            if scope != "target" && scope != "global"
                scope := "target"
            HK_ApplyBlock[keyName] := scope
        }
    }
    ; Build display→raw key map for reverse lookup
    dispToRaw := Map()
    for keyName, _ in HK_ApplyBlock
        dispToRaw[HK_DisplayKey(keyName)] := keyName
    ; Snapshot the INI path so SaveAndClose always writes to the correct file
    abIni := HOTKEY_SETTINGS_FILE

    dlg := Gui("+AlwaysOnTop +ToolWindow", "Apply Block — " modeId)
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(12)
    dlg.MarginY := S(12)
    dlg.AddText("xm cFFD54F", "Blocked keys (" modeId " mode):")
    lv := dlg.AddListView("xm y+6 w" S(380) " h" S(260) " Background1E1F22 cFFFFFF -Multi", ["Key", "Scope"])
    for keyName, scope in HK_ApplyBlock
        lv.Add("", HK_DisplayKey(keyName), scope)
    lv.ModifyCol(1, S(200))
    lv.ModifyCol(2, S(80))
    AddHoverPopup(lv, "Keys listed here are intercepted by the toolkit and blocked from reaching CSP in this mode.`nScope: 'target' = only when CSP window is active, 'global' = always.")
    dlg.AddText("xm y+6 c888888", "Presets:")
    btnPresetTracing := dlg.AddButton("x+" S(4) " yp w" S(70) " h" S(22), "Tracing")
    btnPresetAnimate := dlg.AddButton("x+4 yp w" S(70) " h" S(22), "Animate")
    btnPresetDraw := dlg.AddButton("x+4 yp w" S(70) " h" S(22), "Painting")
    btnPresetClear := dlg.AddButton("x+4 yp w" S(55) " h" S(22), "Clear")
    AddHoverPopup(btnPresetTracing, "Tracing defaults: Ctrl+`/2-9/0, Ctrl+Shift+1-3, and Alt+W")
    AddHoverPopup(btnPresetAnimate, "Animate defaults: Ctrl+`/2-9/0, Ctrl+Shift+1-3")
    AddHoverPopup(btnPresetDraw, "Painting defaults: Ctrl+`/2-9/0, Ctrl+Shift+1-3, and Alt+Shift+W")
    AddHoverPopup(btnPresetClear, "Remove all blocked keys")
    btnAdd := dlg.AddButton("xm y+6 w" S(90) " h" S(26) " cFFFFFF", "Add")
    btnDel := dlg.AddButton("x+6 yp w" S(90) " h" S(26), "Delete")
    btnScope := dlg.AddButton("x+6 yp w" S(100) " h" S(26), "Toggle Scope")
    btnClose := dlg.AddButton("x+6 yp w" S(76) " h" S(26) " cFFFFFF Default", "Close")

    ; Single hidden edit/text reused for key capture
    _capEd := dlg.AddEdit("Hidden x0 y0 w0 h0", "")
    _capDisp := dlg.AddText("Hidden x0 y0 w0 h0", "")

    _loadPreset(presetKeys) {
        global HK_ApplyBlock
        HK_ApplyBlock := Map()
        dispToRaw.Clear()
        lv.Delete()
        for keyName, scope in presetKeys {
            HK_ApplyBlock[keyName] := scope
            lv.Add("", HK_DisplayKey(keyName), scope)
            dispToRaw[HK_DisplayKey(keyName)] := keyName
        }
    }

    _presetTracing(*) {
        _loadPreset(ModeSettingsApplyBlockForMode("tracing"))
    }

    _presetAnimate(*) {
        _loadPreset(ModeSettingsApplyBlockForMode("animate"))
    }

    _presetPainting(*) {
        _loadPreset(ModeSettingsApplyBlockForMode("painting"))
    }

    _presetClear(*) {
        global HK_ApplyBlock
        HK_ApplyBlock := Map()
        dispToRaw.Clear()
        lv.Delete()
    }

    btnPresetTracing.OnEvent("Click", _presetTracing)
    btnPresetAnimate.OnEvent("Click", _presetAnimate)
    btnPresetDraw.OnEvent("Click", _presetPainting)
    btnPresetClear.OnEvent("Click", _presetClear)

    _commitPendingCapture() {
        global HK_ApplyBlock
        if _capEd.Value = ""
            return
        keyVal := Trim(_capEd.Value)
        if keyVal = "" || HK_ApplyBlock.Has(keyVal)
            return
        scope := "target"
        HK_ApplyBlock[keyVal] := scope
        dispToRaw[HK_DisplayKey(keyVal)] := keyVal
        lv.Add("", HK_DisplayKey(keyVal), scope)
        _capEd.Value := ""
    }

    OnEventAdd(ctrl, *) {
        global HK_CaptureMode, _HK_CaptureDlg
        ; If a previous capture dialog is still open, clean it up first
        if IsObject(_HK_CaptureDlg) && _HK_CaptureDlg != 0 {
            HK_CaptureMode := false
            try _HK_CaptureDlg.Destroy()
            _HK_CaptureDlg := 0
        }
        if HK_CaptureMode
            return
        HK_CaptureMode := true
        _capEd.Value := ""
        try {
            HK_CaptureKey(dlg, _capEd, _capDisp, ctrl)
            SetTimer(_PollCapture, 100)
        } catch {
            HK_CaptureMode := false
        }
    }

    _PollCapture(*) {
        global _HK_CaptureDlg, HK_CaptureMode
        if IsObject(_HK_CaptureDlg) && _HK_CaptureDlg != 0
            return
        SetTimer(_PollCapture, 0)
        btnAdd.Text := "Add"
        btnAdd.Enabled := true
        HK_CaptureMode := false
        _commitPendingCapture()
    }

    OnEventDel(ctrl, *) {
        idx := lv.GetNext(0)
        if !idx
            return
        keyDisplay := lv.GetText(idx, 1)
        if dispToRaw.Has(keyDisplay) {
            HK_ApplyBlock.Delete(dispToRaw[keyDisplay])
            dispToRaw.Delete(keyDisplay)
        }
        lv.Delete(idx)
    }

    OnEventScope(ctrl, *) {
        idx := lv.GetNext(0)
        if !idx
            return
        keyDisplay := lv.GetText(idx, 1)
        if dispToRaw.Has(keyDisplay) {
            raw := dispToRaw[keyDisplay]
            newScope := HK_ApplyBlock[raw] = "target" ? "global" : "target"
            HK_ApplyBlock[raw] := newScope
            lv.Modify(idx, "", keyDisplay, newScope)
        }
    }

    SaveAndClose() {
        global HK_ApplyBlock, _HK_CaptureDlg
        SetTimer(_PollCapture, 0)
        HK_CaptureMode := false
        if IsObject(_HK_CaptureDlg) && _HK_CaptureDlg != 0 {
            try _HK_CaptureDlg.Destroy()
            _HK_CaptureDlg := 0
        }
        _commitPendingCapture()
        HK_ApplyBlock := Map()
        IniDelete(abIni, "ApplyBlock")
        row := 0
        loop lv.GetCount() {
            row := A_Index
            keyDisplay := lv.GetText(row, 1)
            scope := lv.GetText(row, 2)
            if dispToRaw.Has(keyDisplay) {
                raw := dispToRaw[keyDisplay]
                HK_ApplyBlock[raw] := scope
                IniWrite(scope, abIni, "ApplyBlock", raw)
            }
        }
        HK_ReapplyAll()
        dlg.Destroy()
    }

    btnAdd.OnEvent("Click", OnEventAdd)
    btnDel.OnEvent("Click", OnEventDel)
    btnScope.OnEvent("Click", OnEventScope)
    btnClose.OnEvent("Click", (*) => SaveAndClose())
    dlg.OnEvent("Close", (*) => SaveAndClose())
    dlg.Show("AutoSize")
    GuiWaitForCloseSafe(dlg)
}

HK_ModeEditor(id) {
    global HK_Modes
    m := HK_Modes[id]
    wm := Map("name", m.Get("name", id), "switch", m.Get("switch", ""), "overrides", m.Get("overrides", Map()).Clone(), "autoTarget", m.Get("autoTarget", ""), "color", m.Get("color", ""))
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Edit Mode")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(12)
    dlg.MarginY := S(12)
    dlg.AddText("xm", "Mode name:")
    nameEd := dlg.AddEdit("xm y+6 w" S(380) " c000000 BackgroundFFFFFF", wm.Get("name", id))
    dlg.AddText("xm y+10", "Mode color (hex):")
    modeColorEd := dlg.AddEdit("xm y+6 w" S(86) " c000000 BackgroundFFFFFF", wm.Get("color", "3949AB"))
    modeColorSwatch := dlg.AddText("x+" S(4) " yp w" S(22) " h" S(22) " +0x200 Background" PieSafeColor(wm.Get("color", "3949AB")), "")
    UpdateModeColorSwatch(*) {
        try modeColorSwatch.Opt("Background" PieSafeColor(Trim(modeColorEd.Value) != "" ? Trim(modeColorEd.Value) : "3949AB"))
    }
    modeColorEd.OnEvent("Change", UpdateModeColorSwatch)
    dlg.AddText("x+" S(4) " yp w" S(18) " h" S(22) " +0x200 BackgroundE53935 cFFFFFF Center", "R").OnEvent("Click", (*) => (modeColorEd.Value := "E53935", UpdateModeColorSwatch(), modeColorEd.Focus()))
    dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background0F9D58 cFFFFFF Center", "G").OnEvent("Click", (*) => (modeColorEd.Value := "0F9D58", UpdateModeColorSwatch(), modeColorEd.Focus()))
    dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background4285F4 cFFFFFF Center", "B").OnEvent("Click", (*) => (modeColorEd.Value := "4285F4", UpdateModeColorSwatch(), modeColorEd.Focus()))
    dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 BackgroundFF9800 cFFFFFF Center", "O").OnEvent("Click", (*) => (modeColorEd.Value := "FF9800", UpdateModeColorSwatch(), modeColorEd.Focus()))
    dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background9C27B0 cFFFFFF Center", "V").OnEvent("Click", (*) => (modeColorEd.Value := "9C27B0", UpdateModeColorSwatch(), modeColorEd.Focus()))
    dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background00BCD4 cFFFFFF Center", "C").OnEvent("Click", (*) => (modeColorEd.Value := "00BCD4", UpdateModeColorSwatch(), modeColorEd.Focus()))
    dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background9E9E9E cFFFFFF Center", "Gr").OnEvent("Click", (*) => (modeColorEd.Value := "9E9E9E", UpdateModeColorSwatch(), modeColorEd.Focus()))
    dlg.AddText("xm y+4 w" S(380) " c888888", "Color shown on the IB drag separator and Main GUI. Default: 3949AB.")
    dlg.AddText("xm y+10", "Switch hotkey:")
    swEd := dlg.AddEdit("xm y+6 w" S(200) " c000000 BackgroundFFFFFF", wm.Get("switch", ""))
    swDisplay := dlg.AddText("xm y+6 w" S(96) " h26 +0x200 Center cFFFFFF Background2D2D32", HK_DisplayKey(wm.Get("switch", "")))
    swCapBtn := dlg.AddButton("x+8 yp w" S(80) " h26", "Record")
    swCapBtn.OnEvent("Click", (*) => HK_CaptureKey(dlg, swEd, swDisplay, swCapBtn))
    dlg.AddText("xm y+4 w" S(380) " c888888", "Record captures the switch key. Leave blank for none.")
    dlg.AddText("xm y+10", "Auto-switch when this window is active:")
    autoOpts := [{val:"", label:"(Off)"}]
    for o in HK_TargetOptionList() {
        if o.val = ""
            autoOpts.Push({val:"win1", label:o.label})
        else
            autoOpts.Push(o)
    }
    autoLabels := []
    for o in autoOpts
        autoLabels.Push(o.label)
    autoDDL := dlg.AddDropDownList("xm y+6 w" S(380) " c000000 BackgroundFFFFFF", autoLabels)
    curAuto := wm.Get("autoTarget", "")
    for i, o in autoOpts
        if o.val = curAuto {
            autoDDL.Choose(i)
            break
        }
    dlg.AddText("xm y+4 w" S(380) " c888888", "With the Auto Mode Switch feature on, the toolkit switches to this mode when the listed window is active.")
    dlg.AddText("xm y+10 cFFD54F", "Mode hotkeys:")
    dlg.AddText("xm y+4 w" S(380) " cAAAAAA", "Switch to this mode, then edit keys in the normal Hotkey Settings list. This keeps each mode's keys in its own settings file and leaves Default unchanged.")
    OpenHotkeysForMode(*) {
        if HK_ModeActive() != id
            HK_SwitchMode(id)
        dlg.Destroy()
        ShowHotkeySettings()
    }
    SaveMode(*) {
        wm["name"] := Trim(nameEd.Value)
        if Trim(nameEd.Value) = ""
            wm["name"] := id
        wm["switch"] := Trim(swEd.Value)
        wm["color"] := Trim(modeColorEd.Value) != "" ? Trim(modeColorEd.Value) : "3949AB"
        wm["autoTarget"] := ""
        for o in autoOpts
            if o.label = autoDDL.Value {
                wm["autoTarget"] := o.val
                break
            }
        HK_Modes[id] := wm
        HK_SaveModes()
        prevFlagMap := HK_ModeFlags(id)
        f := Map()
        for name, chk in flagChk
            if chk.Value
                f[name] := true
        HK_SaveModeFlags(id, f)
        HK_ReapplyAll()
        ; re-apply immediately when the mode being edited is the active one
        if id = HK_ModeActive()
            HK_ApplyFlagMaps(f, prevFlagMap)
        dlg.Destroy()
        ShowNotify("Modes", "Mode saved")
    }
    dlg.AddButton("xm y+8 w" S(150) " h" S(26) " cFFFFFF", "Switch + Edit Hotkeys").OnEvent("Click", OpenHotkeysForMode)
    ApplyBlockForMode(*) {
        curMode := ModeSettingsActive()
        if curMode != id
            HK_SwitchMode(id)
        dlg.Destroy()
        ShowApplyBlockEditor(id)
    }
    dlg.AddButton("x+8 yp w" S(110) " h" S(26), "Apply Block").OnEvent("Click", ApplyBlockForMode)
    dlg.AddText("xm y+10", "Forced toggles (applied while this mode is active):")
    flagChk := Map()
    curFlags := HK_ModeFlags(id)
    col := 0
    for pair in HK_ModeFlagDefs() {
        opts := col = 0 ? "xm y+5" : "x+12 yp"
        col := !col
        chk := dlg.AddCheckbox(opts, pair[2])
        chk.Value := curFlags.Has(pair[1]) && curFlags[pair[1]] ? 1 : 0
        flagChk[pair[1]] := chk
    }
    dlg.AddText("xm y+4 w" S(380) " c888888", "Checked toggles are forced ON whenever this mode is active (e.g. LT Lock in Tracing mode).")
    dlg.AddButton("xm y+10 w" S(95) " h" S(26) " cFFFFFF", "Save").OnEvent("Click", SaveMode)
    dlg.AddButton("x+8 yp w" S(95) " h" S(26), "Cancel").OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("AutoSize")
    GuiWaitForCloseSafe(dlg)
}

DoAutoSave() {
    global AutoSaveOn
    if AutoSaveOn && WinActive("ahk_exe CLIPStudioPaint.exe") {
        DebugLog("Auto save triggered")
        HotkeySendCSP("^s")
    }
}

ToggleToolGUIs() {
    global ColorGUI, ColorGUIVisible, ColorGUI_X, ColorGUI_Y
    global LinkGUI, LinkGUIVisible, LinkGUI_X, LinkGUI_Y
    global IB_GUI, IBVisible, IB_X, IB_Y
    global GUIEnabled, GUIVisible

    if !GUIEnabled {
        SaveGUIPositions()
        if IsObject(ColorGUI) ColorGUI.GetPos(&ColorGUI_X, &ColorGUI_Y)
        if IsObject(IB_GUI)   IB_GUI.GetPos(&IB_X, &IB_Y)
        if IsObject(LinkGUI)  LinkGUI.GetPos(&LinkGUI_X, &LinkGUI_Y)
        if IsObject(ColorGUI) ColorGUI.Hide()
        if IsObject(IB_GUI)   IB_GUI.Hide()
        if IsObject(LinkGUI)  LinkGUI.Hide()
        DebugLog("All GUIs hidden")
        ColorGUIVisible := false
        LinkGUIVisible := false
        IBVisible := false
        GUIVisible := false
        GUIEnabled := true
    } else {
        if FeatureEnabled("colorgui") && IsObject(ColorGUI) {
            ColorGUI.Show("x" ColorGUI_X " y" ColorGUI_Y " NoActivate")
            ColorRefreshLayout()
        }
        if FeatureEnabled("ibgui") && IsObject(IB_GUI)   IB_GUI.Show("x" IB_X " y" IB_Y " NoActivate")
        if FeatureEnabled("linkgui") && IsObject(LinkGUI) {
            LinkGUI.Show("x" LinkGUI_X " y" LinkGUI_Y " NoActivate")
            LinkRefreshLayout()
        }
        DebugLog("All GUIs shown")
        ColorGUIVisible := FeatureEnabled("colorgui")
        LinkGUIVisible := FeatureEnabled("linkgui")
        IBVisible := FeatureEnabled("ibgui")
        GUIVisible := true
        GUIEnabled := false
    }
}
