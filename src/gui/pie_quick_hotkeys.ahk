; GUI - Pie Quick Hotkeys
; ============================================================

ShowPieQuickHotkeys(*) {
    global PieQuickHotkeys, _PieQuickGui
    if IsObject(_PieQuickGui) {
        hwnd := SafeGuiHwnd(_PieQuickGui)
        if hwnd {
            PieQuickRefreshList(_PieQuickGui)
            _PieQuickGui.Show()
            return
        }
    }
    dlg := Gui("+AlwaysOnTop +ToolWindow +Resize", "Pie Quick Hotkeys")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(12)
    dlg.MarginY := S(12)

    dlg.AddText("xm", "Quick hotkeys only work while a pie menu is open. Number keys 1-0 stay reserved for pie slots.")
    dlg.edQuickSearch := dlg.AddEdit("xm y+6 w" S(795) " c000000 BackgroundFFFFFF", "")
    dlg.edQuickSearch.OnEvent("Change", (*) => PieQuickRefreshList(dlg))
    dlg.AddText("xm y+4 w" S(795) " c888888", "Filter by label, key, scope, type, action, or color.")
    lv := dlg.AddListView("xm y+6 w" S(795) " h" S(300) " Grid +Report +LV0x04000", ["#", "Label", "Hotkey", "Scope", "Type", "Action", "Requirement", "Description", "Color"])
    lv.SetFont("s" S(9) " c000000", "Segoe UI")
    lv.ModifyCol(1, 0)
    lv.ModifyCol(2, S(120))
    lv.ModifyCol(3, S(62))
    lv.ModifyCol(4, S(72))
    lv.ModifyCol(5, S(66))
    lv.ModifyCol(6, S(155))
    lv.ModifyCol(7, S(110))
    lv.ModifyCol(8, S(120))
    lv.ModifyCol(9, S(85))
    dlg.lv := lv
    _PieQuickGui := dlg
    PieQuickRefreshList(dlg)

    lv.OnEvent("DoubleClick", PieQuickEdit)
    lv.OnEvent("ItemSelect", (*) => PieQuickUpdateToggleBtn(dlg))
    lv.OnEvent("ColClick", (*) => 0)
    dlg.AddButton("xm y+9 w" S(66) " h" S(26), "▲ Up").OnEvent("Click", PieQuickMoveUp)
    dlg.AddButton("x+6 yp w" S(66) " h" S(26), "▼ Down").OnEvent("Click", PieQuickMoveDown)
    dlg.AddButton("x+6 yp w" S(66) " h" S(26), "Add").OnEvent("Click", PieQuickAdd)
    dlg.AddButton("x+6 yp w" S(66) " h" S(26), "Edit").OnEvent("Click", PieQuickEdit)
    dlg.AddButton("x+6 yp w" S(66) " h" S(26), "Delete").OnEvent("Click", PieQuickDelete)
    dlg.btnToggle := dlg.AddButton("x+6 yp w" S(74) " h" S(26), "Disable")
    dlg.btnToggle.OnEvent("Click", PieQuickToggle)
    dlg.AddButton("x+6 yp w" S(74) " h" S(26), "Presets").OnEvent("Click", ShowPieQuickPresets)
    dlg.AddButton("x+6 yp w" S(112) " h" S(26), "Save as Preset").OnEvent("Click", PieQuickSaveAsPreset)
    dlg.AddButton("x+6 yp w" S(66) " h" S(26) " cFFFFFF", "Save").OnEvent("Click", PieQuickSaveFromGui)
    dlg.OnEvent("Close", PieQuickGuiClosed)
    dlg.AddButton("x+6 yp w" S(66) " h" S(26), "Close").OnEvent("Click", PieQuickGuiClose)
    dlg.Show("w" S(990) " AutoSize")
}

PieQuickGuiClose(ctrlOrGui := 0, *) {
    global _PieQuickGui
    guiObj := IsObject(ctrlOrGui) && ctrlOrGui.HasProp("Gui") ? ctrlOrGui.Gui : ctrlOrGui
    if IsObject(guiObj) {
        try guiObj.Destroy()
    }
    _PieQuickGui := 0
}

PieQuickGuiClosed(*) {
    global _PieQuickGui
    _PieQuickGui := 0
}

PieQuickRefreshList(guiObj) {
    global PieQuickHotkeys
    if !IsObject(guiObj) || !guiObj.HasProp("lv")
        return
    PieQuickCompactItems()
    lv := guiObj.lv
    filter := Trim(StrLower(guiObj.HasProp("edQuickSearch") ? guiObj.edQuickSearch.Value : ""))
    lv.Delete()
    for idx, item in PieQuickHotkeys {
        item := PieQuickSanitizeItem(item)
        PieQuickHotkeys[idx] := item
        rowText := StrLower(
            item.Get("label", "") " "
            HK_DisplayKey(PieQuickNormalizeKey(item.Get("key", ""))) " "
            PieQuickScopeLabel(item.Get("scope", "all")) " "
            item.Get("type", "") " "
            PieDisplayAction(item.Get("type", "shortcut"), item.Get("action", "")) " "
            HK_NormalizeRequirement(item.Get("requirement", "")) " "
            item.Get("description", "") " "
            "#" PieSafeColor(item.Get("color", "455A64")))
        if filter != "" && !InStr(rowText, filter)
            continue
        status := PieQuickStatus(item)
        scopeLabel := PieQuickScopeLabel(item.Get("scope", "all"))
        lv.Add(,
            idx,
            item.Get("label", "Quick Hotkey"),
            HK_DisplayKey(PieQuickNormalizeKey(item.Get("key", ""))),
            status = scopeLabel || InStr(status, "Pie") ? status : scopeLabel " - " status,
            item.Get("type", "shortcut"),
            PieDisplayAction(item.Get("type", "shortcut"), item.Get("action", "")),
            HK_NormalizeRequirement(item.Get("requirement", "")),
            item.Get("description", ""),
            "#" PieSafeColor(item.Get("color", "455A64")))
    }
}

PieQuickSelectedRow(ctrl) {
    guiObj := ctrl.Gui
    row := guiObj.lv.GetNext()
    if !row {
        HK_SelectPrompt()
        return 0
    }
    return Integer(guiObj.lv.GetText(row, 1))
}

PieQuickSelectedRows(guiObj) {
    rows := []
    if !IsObject(guiObj) || !guiObj.HasProp("lv")
        return rows
    row := 0
    while row := guiObj.lv.GetNext(row)
        rows.Push(Integer(guiObj.lv.GetText(row, 1)))
    return rows
}

PieQuickAdd(ctrl, *) {
    global PieQuickHotkeys
    result := PieQuickEditor()
    if !IsObject(result)
        return
    PieQuickHotkeys.Push(result)
    PieQuickPersistChanges()
    PieQuickRefreshList(ctrl.Gui)
}

PieQuickEdit(ctrl, *) {
    global PieQuickHotkeys
    row := PieQuickSelectedRow(ctrl)
    if !row
        return
    PieQuickHotkeys[row] := PieQuickSanitizeItem(PieQuickHotkeys[row])
    ApplyQuick(item) {
        PieQuickHotkeys[row] := PieQuickSanitizeItem(item)
        PieQuickPersistChanges()
        PieQuickRefreshList(ctrl.Gui)
        selRow := PieQuickSelectVisualRow(ctrl.Gui.lv, row)
        if selRow
            ctrl.Gui.lv.Modify(selRow, "Select Vis")
    }
    result := PieQuickEditor(PieQuickHotkeys[row], ApplyQuick)
    if !IsObject(result)
        return
    if !(HasProp(result, "_alreadyApplied") && result._alreadyApplied)
        ApplyQuick(result)
}

PieQuickDelete(ctrl, *) {
    global PieQuickHotkeys
    rows := PieQuickSelectedRows(ctrl.Gui)
    if !rows.Length {
        HK_SelectPrompt()
        return
    }
    Loop rows.Length {
        row := rows[rows.Length - A_Index + 1]
        if row >= 1 && row <= PieQuickHotkeys.Length
            PieQuickHotkeys.RemoveAt(row)
    }
    PieQuickPersistChanges()
    PieQuickRefreshList(ctrl.Gui)
}

PieQuickToggle(ctrl, *) {
    global PieQuickHotkeys
    row := PieQuickSelectedRow(ctrl)
    if !row
        return
    item := PieQuickSanitizeItem(PieQuickHotkeys[row])
    item["enabled"] := !item.Get("enabled", 1)
    PieQuickHotkeys[row] := item
    PieQuickPersistChanges()
    PieQuickRefreshList(ctrl.Gui)
    PieQuickUpdateToggleBtn(ctrl.Gui)
}

PieQuickUpdateToggleBtn(guiObj) {
    if !IsObject(guiObj) || !guiObj.HasProp("btnToggle")
        return
    visRow := guiObj.lv.GetNext()
    if !visRow {
        guiObj.btnToggle.Text := "Disable"
        return
    }
    idx := Integer(guiObj.lv.GetText(visRow, 1))
    guiObj.btnToggle.Text := PieQuickHotkeys[idx].Get("enabled", 1) ? "Disable" : "Enable"
}

PieQuickSelectVisualRow(lv, targetIdx) {
    Loop lv.GetCount() {
        if Integer(lv.GetText(A_Index, 1)) = targetIdx
            return A_Index
    }
    return 0
}

PieQuickMoveUp(ctrl, *) {
    global PieQuickHotkeys
    guiObj := ctrl.Gui
    visRow := guiObj.lv.GetNext()
    if !visRow
        return
    idx := Integer(guiObj.lv.GetText(visRow, 1))
    if idx <= 1
        return
    temp := PieQuickHotkeys[idx]
    PieQuickHotkeys[idx] := PieQuickHotkeys[idx - 1]
    PieQuickHotkeys[idx - 1] := temp
    PieQuickPersistChanges()
    PieQuickRefreshList(guiObj)
    selRow := PieQuickSelectVisualRow(guiObj.lv, idx - 1)
    if selRow
        guiObj.lv.Modify(selRow, "Select Vis")
}

PieQuickMoveDown(ctrl, *) {
    global PieQuickHotkeys
    guiObj := ctrl.Gui
    visRow := guiObj.lv.GetNext()
    if !visRow
        return
    idx := Integer(guiObj.lv.GetText(visRow, 1))
    if idx >= PieQuickHotkeys.Length
        return
    temp := PieQuickHotkeys[idx]
    PieQuickHotkeys[idx] := PieQuickHotkeys[idx + 1]
    PieQuickHotkeys[idx + 1] := temp
    PieQuickPersistChanges()
    PieQuickRefreshList(guiObj)
    selRow := PieQuickSelectVisualRow(guiObj.lv, idx + 1)
    if selRow
        guiObj.lv.Modify(selRow, "Select Vis")
}

PieQuickSaveFromGui(ctrl, *) {
    PieQuickPersistChanges()
    PieQuickRefreshList(ctrl.Gui)
    ShowNotify("Pie Quick Hotkeys", "Saved")
}

PieQuickSaveAsPreset(*) {
    result := PieQuickPresetSaveDialog()
    if !IsObject(result)
        return
    path := PieQuickPresetPath(result["name"])
    SavePieQuickHotkeysToFile(path)
    if Trim(result["description"]) != ""
        try IniWrite(Trim(result["description"]), path, "Meta", "Description")
    ShowNotify("Pie Quick Preset", "Saved")
}

PieQuickPresetSaveDialog() {
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Save Pie Quick Preset")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)
    dlg.AddText("xm cFFD54F", "Save current Pie Quick list as preset")
    dlg.AddText("xm y+" S(6) " w" S(380) " cAAAAAA", "This saves every current Pie Quick Hotkey entry as a reusable preset file.")
    dlg.AddText("xm y+" S(12), "Preset name:")
    nameEd := dlg.AddEdit("xm y+" S(5) " w" S(380) " c000000 BackgroundFFFFFF", "default")
    dlg.AddText("xm y+" S(8), "Description:")
    descEd := dlg.AddEdit("xm y+" S(5) " w" S(380) " h" S(64) " c000000 BackgroundFFFFFF", "")
    result := 0
    dlg.AddButton("xm y+" S(12) " w" S(90) " h" S(28) " cFFFFFF Default", "Save").OnEvent("Click", (*) => (
        (name := Trim(nameEd.Value)) != "" ? (
            result := Map("name", name, "description", Trim(descEd.Value)),
            dlg.Destroy()
        ) : (
            _HK_ResultPopup("Save Pie Quick Preset", "Preset name is required.", "E53935"),
            nameEd.Focus()
        )
    ))
    dlg.AddButton("x+" S(8) " yp w" S(90) " h" S(28), "Cancel").OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("AutoSize")
    GuiWaitForCloseSafe(dlg)
    return result
}

PieQuickPersistChanges() {
    SavePieQuickHotkeys()
    PieQuickReapplyHotkeys()
}

PieQuickEditor(existing := 0, applyCallback := 0) {
    isEdit := IsObject(existing)
    item := isEdit ? PieQuickSanitizeItem(existing) : Map("id", "q" A_TickCount "_" Random(1000, 9999), "label", "", "key", "", "scope", "all", "type", "shortcut", "action", "", "requirement", "", "color", "455A64", "enabled", 1, "description", "")
    dlg := Gui("+AlwaysOnTop +ToolWindow", isEdit ? "Edit Pie Quick Hotkey" : "Add Pie Quick Hotkey")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s9 cFFFFFF", "Segoe UI")
    dlg.MarginX := 14
    dlg.MarginY := 14

    editW := 430
    displayW := 320
    btnW := 80
    dlg.AddText("xm", "Label:")
    labelEd := dlg.AddEdit("xm y+6 w" editW " c000000 BackgroundFFFFFF", item.Get("label", ""))

    dlg.AddText("xm y+10", "Hotkey:")
    keyEd := dlg.AddEdit("xm y+6 w" editW " c000000 BackgroundFFFFFF", PieQuickNormalizeKey(item.Get("key", "")))
    dlg.AddText("xm y+4 w" editW " c888888", "Advanced AHK prefixes are allowed here, e.g. ~!D or $^1.")
    display := dlg.AddText("xm y+6 w" displayW+22 " h26 +0x200 Center cFFFFFF Background2D2D32", HK_DisplayKey(keyEd.Value))
    recBtn := dlg.AddButton("x+8 yp w" btnW " h26", "Record")
    recBtn.OnEvent("Click", (*) => HK_CaptureKey(dlg, keyEd, display, recBtn))
    conflictTxt := dlg.AddText("xm y+4 w" editW " cFFD166", "")
    PieQuickDlg_UpdateConflict(*) {
        display.Text := HK_DisplayKey(PieQuickNormalizeKey(keyEd.Value))
        conflictTxt.Text := PieQuickConflictText(keyEd.Value, PieQuickScopeFromIndex(scopeDd.Value), item.Get("id", ""))
    }
    keyEd.OnEvent("Change", PieQuickDlg_UpdateConflict)

    dlg.AddText("xm y+10", "Active in:")
    scopeDd := dlg.AddDropDownList("xm y+6 w" editW, ["Disabled", "Pie 1", "Pie 2", "Pie 3", "Pie 4", "All Pie"])
    scopeDd.Value := PieQuickScopeIndex(item.Get("scope", "all"))
    scopeDd.OnEvent("Change", PieQuickDlg_UpdateConflict)

    dlg.AddText("xm y+10", "Type:")
    typeDd := dlg.AddDropDownList("xm y+6 w" editW, ["shortcut", "function", "script", "url", "show pie", "disabled"])
    type := ToolkitNormalizeActionType(item.Get("type", "shortcut"))
    typeDd.Value := type = "shortcut" ? 1 : type = "function" ? 2 : type = "script" ? 3 : type = "url" ? 4 : type = "show pie" ? 5 : 6

    dlg.AddText("xm y+10", "Action:")
    actionEd := dlg.AddEdit("xm y+6 w" editW " c000000 BackgroundFFFFFF", item.Get("action", ""))
    actionDisplay := dlg.AddText("xm y+6 w" displayW+22 " h26 +0x200 Center cFFFFFF Background2D2D32", item.Get("action", ""))
    actionToolBtn := dlg.AddButton("x+8 yp w" btnW " h26", "Record")
    testBtn := dlg.AddButton("xm y+6 w" btnW " h26", "Test")
    fnGuideBtn := dlg.AddButton("x+8 yp w" btnW " h26", "Fn Guide")
    actionToolBtn.OnEvent("Click", (*) => PieQuickPrimaryAction(typeDd, dlg, actionEd, actionDisplay, actionToolBtn))
    fnGuideBtn.OnEvent("Click", HK_ShowFunctionFieldGuide)
    testBtn.OnEvent("Click", (*) => PieQuickTestEditorAction(typeDd.Text, actionEd.Value, labelEd.Value != "" ? labelEd.Value : "Pie Quick Test"))
    actionHelp := dlg.AddText("xm y+6 w" editW " c888888", "Shortcut: !d. Function: ShowCSPGuide. Script: .ahk/.exe path. URL: https://...")
    typeDd.OnEvent("Change", (*) => PieQuickToggleActionTools(typeDd, actionToolBtn, fnGuideBtn, testBtn, actionHelp))
    PieQuickToggleActionTools(typeDd, actionToolBtn, fnGuideBtn, testBtn, actionHelp)

    dlg.AddText("xm y+10", "Requirement:")
    reqEd := dlg.AddEdit("xm y+6 w" editW " c000000 BackgroundFFFFFF", HK_NormalizeRequirement(item.Get("requirement", "")))

    enabledCb := dlg.AddCheckbox("xm y+10 Checked" item.Get("enabled", 1), "Enabled")

    dlg.AddText("xm y+10", "Description:")
    descEd := dlg.AddEdit("xm y+6 w" editW " c000000 BackgroundFFFFFF", item.Get("description", ""))

    dlg.AddText("xm y+10", "Color:")
    colorEd := dlg.AddEdit("xm y+6 w" S(90) " c000000 BackgroundFFFFFF", PieSafeColor(item.Get("color", "455A64")))
    colorPreview := dlg.AddText("x+" S(6) " yp w" S(28) " h" S(22) " +0x200 Background" PieSafeColor(item.Get("color", "455A64")), "")
    PieQuickUpdatePreview(c) {
        colorPreview.Opt("Background" c)
        colorPreview.Redraw()
    }
    colorEd.OnEvent("Change", (*) => PieQuickUpdatePreview(PieSafeColor(colorEd.Value)))
    dlg.AddText("x+" S(4) " yp w" S(18) " h" S(22) " +0x200 BackgroundE53935 cFFFFFF Center", "R").OnEvent("Click", (*) => (colorEd.Value := "E53935", PieQuickUpdatePreview("E53935"), colorEd.Focus()))
    dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background0F9D58 cFFFFFF Center", "G").OnEvent("Click", (*) => (colorEd.Value := "0F9D58", PieQuickUpdatePreview("0F9D58"), colorEd.Focus()))
    dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background4285F4 cFFFFFF Center", "B").OnEvent("Click", (*) => (colorEd.Value := "4285F4", PieQuickUpdatePreview("4285F4"), colorEd.Focus()))
    dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 BackgroundE39A2D cFFFFFF Center", "O").OnEvent("Click", (*) => (colorEd.Value := "E39A2D", PieQuickUpdatePreview("E39A2D"), colorEd.Focus()))
    dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background9C27B0 cFFFFFF Center", "V").OnEvent("Click", (*) => (colorEd.Value := "9C27B0", PieQuickUpdatePreview("9C27B0"), colorEd.Focus()))
    dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background00BCD4 cFFFFFF Center", "C").OnEvent("Click", (*) => (colorEd.Value := "00BCD4", PieQuickUpdatePreview("00BCD4"), colorEd.Focus()))
    dlg.AddText("x+" S(2) " yp w" S(20) " h" S(22) " +0x200 Background607D8B cFFFFFF Center", "Gr").OnEvent("Click", (*) => (colorEd.Value := "607D8B", PieQuickUpdatePreview("607D8B"), colorEd.Focus()))

    result := 0
    dlg.AddButton("xm y+10 w80 h26 cFFFFFF Default", isEdit ? "Done" : "Add").OnEvent("Click", (*) => PieQuickEditorSave(dlg, item, labelEd, keyEd, scopeDd, typeDd, actionEd, reqEd, enabledCb, descEd, colorEd, &result, applyCallback))
    if IsObject(applyCallback)
        dlg.AddButton("x+8 yp w80 h26", "Apply").OnEvent("Click", (*) => PieQuickEditorApply(item, labelEd, keyEd, scopeDd, typeDd, actionEd, reqEd, enabledCb, descEd, colorEd, applyCallback))
    dlg.AddButton("x+8 yp w80 h26", "Cancel").OnEvent("Click", (*) => dlg.Destroy())
    actionEd.OnEvent("Change", (*) => actionDisplay.Text := actionEd.Value != "" ? actionEd.Value : "...")
    PieQuickDlg_UpdateConflict()
    actionDisplay.Text := actionEd.Value != "" ? actionEd.Value : "..."
    dlg.Show("w" S(520) " AutoSize")
    GuiWaitForCloseSafe(dlg)
    return result
}

PieQuickEditorApply(item, labelEd, keyEd, scopeDd, typeDd, actionEd, reqEd, enabledCb, descEd, colorEd, applyCallback) {
    item := PieQuickSanitizeItem(item)
    key := PieQuickNormalizeKey(keyEd.Value)
    scope := PieQuickScopeFromIndex(scopeDd.Value)
    type := ToolkitNormalizeActionType(typeDd.Text)
    action := Trim(actionEd.Value)
    if key = "" && scope != "disabled" && type != "disabled" {
        _HK_ResultPopup("Pie Quick Hotkey", "Hotkey is required unless this item is disabled.", "E53935")
        return false
    }
    if PieQuickIsReservedKey(key) {
        _HK_ResultPopup("Pie Quick Hotkey", "Keys 1-0 and Numpad 1-0 are reserved for pie slots.", "E53935")
        return false
    }
    conflict := PieQuickConflictText(key, scope, item.Get("id", ""))
    if conflict != "" {
        _HK_ResultPopup("Pie Quick Hotkey", conflict, "E53935")
        return false
    }
    if action = "" && scope != "disabled" && type != "disabled" {
        _HK_ResultPopup("Pie Quick Hotkey", "Action is required unless this item is disabled.", "E53935")
        return false
    }
    if type = "url" && action != "" && !RegExMatch(action, "i)^(https?://|file://)") {
        _HK_ResultPopup("Pie Quick Hotkey", "URL actions should start with http:// or https://.", "E53935")
        return false
    }
    item["label"] := Trim(labelEd.Value) != "" ? Trim(labelEd.Value) : "Quick Hotkey"
    item["key"] := key
    item["scope"] := scope
    item["type"] := type
    if type = "shortcut" && action != ""
        action := PieQuickNormalizeShortcutAction(action)
    item["action"] := action
    item["requirement"] := HK_NormalizeRequirement(reqEd.Value)
    item["enabled"] := enabledCb.Value
    item["description"] := Trim(descEd.Value)
    item["color"] := PieSafeColor(colorEd.Value)
    applyCallback(item)
    ShowNotify("Pie Quick Hotkey", "Applied")
    return true
}

PieQuickBrowseAction(typeDd, actionEd, *) {
    type := ToolkitNormalizeActionType(typeDd.Text)
    if type = "script" {
        fn := FileSelect("3", A_ScriptDir, "Select Script or App", "Scripts or Apps (*.ahk;*.exe)")
        if fn != ""
            actionEd.Value := fn
    } else if type = "function" {
        HK_FunctionPicker(actionEd)
    } else if type = "url" {
        ib := InputBox("URL to open:", "Pie Quick URL", "w420 h120", actionEd.Value)
        if ib.Result = "OK"
            actionEd.Value := Trim(ib.Value)
    } else if type = "show pie" {
        ib := InputBox("Pie number to open (1-4):", "Pie Quick Show Pie", "w360 h120", actionEd.Value != "" ? actionEd.Value : "1")
        if ib.Result = "OK"
            actionEd.Value := Trim(ib.Value)
    }
}

PieQuickPrimaryAction(typeDd, dlg, actionEd, actionDisplay, toolBtn, *) {
    type := StrLower(Trim(typeDd.Text))
    if type = "shortcut" {
        HK_CaptureKey(dlg, actionEd, actionDisplay, toolBtn)
    } else if type = "function" {
        HK_FunctionPicker(actionEd)
    } else if type = "script" || type = "url" || type = "show pie" {
        PieQuickBrowseAction(typeDd, actionEd)
    }
}

PieQuickToggleActionTools(typeDd, toolBtn, fnGuideBtn, testBtn, helpCtrl) {
    type := ToolkitNormalizeActionType(typeDd.Text)
    toolBtn.Text := type = "shortcut" ? "Record"
        : type = "function" ? "Pick"
        : (type = "script" || type = "url" || type = "show pie") ? "Browse"
        : "Locked"
    toolBtn.Enabled := type != "disabled"
    fnGuideBtn.Enabled := type = "function"
    testBtn.Enabled := type != "disabled"
    helpCtrl.Text := type = "shortcut"
        ? "Shortcut action can be typed or recorded. Example: !d or ^+1."
        : type = "function"
            ? "Function action: use Pick to browse callable functions, or type ShowCSPGuide / ShowCSPGuide()."
            : type = "script"
                ? "Script action: choose an .ahk/.exe path."
                : type = "url"
                    ? "URL action: paste or enter http:// / https:// link."
                    : type = "show pie"
                        ? "Show Pie action: enter pie number 1-4."
                    : "Disabled quick hotkey will not run."
}

PieQuickTestEditorAction(type, action, label := "Pie Quick Test") {
    type := ToolkitNormalizeActionType(type)
    action := Trim(action)
    if type = "disabled" || action = "" {
        _HK_ResultPopup(label, "Nothing to test.", "E53935")
        return
    }
    try {
        ToolkitRunAction(type, action, label)
    } catch as e {
        DebugLog(label ": test failed for " type " - " e.Message)
        _HK_ResultPopup(label, "Test failed: " e.Message, "E53935")
    }
}

PieQuickEditorSave(dlg, item, labelEd, keyEd, scopeDd, typeDd, actionEd, reqEd, enabledCb, descEd, colorEd, &result, applyCallback := 0) {
    item := PieQuickSanitizeItem(item)
    key := PieQuickNormalizeKey(keyEd.Value)
    scope := PieQuickScopeFromIndex(scopeDd.Value)
    type := ToolkitNormalizeActionType(typeDd.Text)
    action := Trim(actionEd.Value)
    if key = "" && scope != "disabled" && type != "disabled" {
        _HK_ResultPopup("Pie Quick Hotkey", "Hotkey is required unless this item is disabled.", "E53935")
        return
    }
    if PieQuickIsReservedKey(key) {
        _HK_ResultPopup("Pie Quick Hotkey", "Keys 1-0 and Numpad 1-0 are reserved for pie slots.", "E53935")
        return
    }
    conflict := PieQuickConflictText(key, scope, item.Get("id", ""))
    if conflict != "" {
        _HK_ResultPopup("Pie Quick Hotkey", conflict, "E53935")
        return
    }
    if action = "" && scope != "disabled" && type != "disabled" {
        _HK_ResultPopup("Pie Quick Hotkey", "Action is required unless this item is disabled.", "E53935")
        return
    }
    if type = "url" && action != "" && !RegExMatch(action, "i)^(https?://|file://)") {
        _HK_ResultPopup("Pie Quick Hotkey", "URL actions should start with http:// or https://.", "E53935")
        return
    }
    item["label"] := Trim(labelEd.Value) != "" ? Trim(labelEd.Value) : "Quick Hotkey"
    item["key"] := key
    item["scope"] := scope
    item["type"] := type
    if type = "shortcut" && action != ""
        action := PieQuickNormalizeShortcutAction(action)
    item["action"] := action
    item["requirement"] := HK_NormalizeRequirement(reqEd.Value)
    item["enabled"] := enabledCb.Value
    item["description"] := Trim(descEd.Value)
    item["color"] := PieSafeColor(colorEd.Value)
    item["_alreadyApplied"] := IsObject(applyCallback)
    if IsObject(applyCallback)
        applyCallback(item)
    result := item
    dlg.Destroy()
}

ShowPieQuickPresets(*) {
    global _PieQuickGui
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Pie Quick Presets")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(12)
    dlg.MarginY := S(12)
    dlg.AddText("xm", "Load Pie Quick Hotkey presets. Loading adds to the current list and keeps existing quick hotkeys.")
    dlg.AddText("xm y+6 cAAAAAA", "Search:")
    dlg.edSearch := dlg.AddEdit("x+6 yp w" S(200) " h20 c000000 BackgroundFFFFFF", "")
    dlg.edSearch.OnEvent("Change", (*) => RefreshPresets())
    lv := dlg.AddListView("xm y+8 w" S(640) " h" S(260) " Grid +Report", ["Preset File", "Description", "Source"])
    lv.SetFont("s" S(9) " c000000", "Segoe UI")
    lv.ModifyCol(1, S(160))
    lv.ModifyCol(2, S(400))
    lv.ModifyCol(3, S(60))
    PresetDescription(path) {
        try desc := Trim(IniRead(path, "Meta", "Description", ""))
        catch
            desc := ""
        if desc = ""
            try desc := Trim(IniRead(path, "Meta", "description", ""))
        return desc
    }
    IsBuiltInPreset(filename) {
        bundledDir := A_ScriptDir "\src\presets"
        return DirExist(bundledDir) && FileExist(bundledDir "\" filename)
    }
    RefreshPresets() {
        lv.Delete()
        filter := ""
        try filter := Trim(dlg.edSearch.Value)
        catch
            filter := ""
        if filter != ""
            filter := StrLower(filter)
        dir := PieQuickPresetDir()
        Loop Files dir "\*.ini" {
            name := A_LoopFileName
            if filter != "" && !InStr(name, filter)
                continue
            desc := PresetDescription(A_LoopFileFullPath)
            if desc = "" {
                try idsText := Trim(IniRead(A_LoopFileFullPath, "PieQuickHotkeys", "Ids", ""))
                catch
                    idsText := ""
                count := 0
                if idsText != "" {
                    for _, rawId in StrSplit(idsText, "|") {
                        if Trim(rawId) != ""
                            count += 1
                    }
                }
                desc := Format("{} hotkeys", count)
            }
            source := IsBuiltInPreset(A_LoopFileName) ? "Built-in" : "User"
            lv.Add(, name, desc, source)
        }
    }
    SelectedPresetPath() {
        row := lv.GetNext()
        if !row {
            HK_SelectPrompt()
            return ""
        }
        return PieQuickPresetDir() "\" lv.GetText(row, 1)
    }
    LoadSelected(*) {
        path := SelectedPresetPath()
        if path = ""
            return
        stats := LoadPieQuickHotkeysFromFile(path)
        if IsObject(stats) {
            SavePieQuickHotkeys()
            PieQuickReapplyHotkeys()
            if IsObject(_PieQuickGui) && SafeGuiHwnd(_PieQuickGui)
                PieQuickRefreshList(_PieQuickGui)
            if stats.added > 0
                ShowNotify("Pie Quick Preset", "Added: " stats.added " | Skipped: " stats.skipped " | Invalid: " stats.invalid)
            else
                _HK_ResultPopup("Pie Quick Preset", "Added: 0`nSkipped duplicates: " stats.skipped "`nIgnored invalid: " stats.invalid "`n`nCurrent quick hotkeys were kept.", "E53935")
        } else {
            _HK_ResultPopup("Pie Quick Preset", "Preset file is empty, invalid, or already fully merged. Current quick hotkeys were kept.", "E53935")
        }
    }
    DeleteSelected(*) {
        path := SelectedPresetPath()
        if path = ""
            return
        SplitPath(path, &filename)
        if IsBuiltInPreset(filename) {
            _HK_ResultPopup("Pie Quick Presets", "Built-in presets cannot be deleted. Only user-saved presets can be removed.", "FFD54F")
            return
        }
        if _HK_Confirm("Delete this preset only?`n" path, "Pie Quick Presets") {
            try FileDelete(path)
            RefreshPresets()
        }
    }
    RefreshPresets()
    lv.OnEvent("DoubleClick", LoadSelected)
    dlg.AddButton("xm y+10 w" S(60) " h" S(26), "Load").OnEvent("Click", LoadSelected)
    dlg.AddButton("x+8 yp w" S(60) " h" S(26), "Delete").OnEvent("Click", DeleteSelected)
    dlg.AddButton("x+8 yp w" S(87) " h" S(26), "Open Folder").OnEvent("Click", (*) => Run('"' PieQuickPresetDir() '"'))
    dlg.AddButton("x+8 yp w" S(60) " h" S(26), "Close").OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("AutoSize")
}
