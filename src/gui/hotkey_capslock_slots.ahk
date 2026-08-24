; GUI - CapsLock slot assignment
; ============================================================

HK_CapsSlotIds() {
    slots := []
    for slot in ["``","1","2","3","4","5","6","7","8","9","0"]
        slots.Push({slot:CapslockSlotStorageId(slot), label:CapslockSlotDisplay(slot), id:"caps_num_" CapslockSlotStorageId(slot)})
    return slots
}

CapslockSlotStorageId(slot) {
    slot := Trim(slot)
    return slot = "~" || slot = "``" || slot = "tilde" ? "backtick" : slot
}

CapslockSlotDisplay(slot) {
    slot := Trim(slot)
    return slot = "backtick" || slot = "tilde" || slot = "``" ? "``" : slot
}

CapslockSlotTitle(slot) {
    return "CapsLock + " CapslockSlotDisplay(slot)
}

CapslockSlotHotkey(slot) {
    slot := CapslockSlotStorageId(slot)
    return slot = "backtick" ? "CapsLock & SC029" : "CapsLock & " slot
}

ShowCapslockNumberSettings(*) {
    global _CapsNumGui
    if IsObject(_CapsNumGui) {
        hwnd := SafeGuiHwnd(_CapsNumGui)
        if hwnd {
            _CapsNumGui.Show()
            return
        }
        _CapsNumGui := 0
    }

    dlg := Gui("+AlwaysOnTop +ToolWindow", "CapsLock 1-0")
    _CapsNumGui := dlg
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)
    dlg.OnEvent("Close", (*) => (_CapsNumGui := 0, dlg.Destroy()))

    dlg.AddText("xm w" S(548) " cCCCCCC", "Assign optional actions to CapsLock+1-0. Leave a slot disabled so CapsLock hold can pass through as Ctrl+Shift+Alt+number.")
    lv := dlg.AddListView("xm y+10 w" S(548) " h" S(230) " Grid +Report", ["Slot", "Hotkey", "Type", "Action", "Status"])
    lv.SetFont("s" S(9) " c000000", "Segoe UI")
    lv.ModifyCol(1, S(45))
    lv.ModifyCol(2, S(125))
    lv.ModifyCol(3, S(85))
    lv.ModifyCol(4, S(189))
    lv.ModifyCol(5, S(85))
    dlg.lv := lv

    CapsRefresh(*) {
        CapslockNumberRefresh(lv)
    }
    CapsAssign(*) {
        CapslockNumberAssign(lv)
    }
    CapsClear(*) {
        CapslockNumberClear(lv)
    }

    lv.OnEvent("DoubleClick", CapsAssign)
    CapsRefresh()
    dlg.AddButton("xm y+10 w" S(76) " h" S(26), "Assign").OnEvent("Click", CapsAssign)
    dlg.AddButton("x+8 yp w" S(76) " h" S(26), "Clear").OnEvent("Click", CapsClear)
    dlg.AddButton("x+8 yp w" S(76) " h" S(26), "Refresh").OnEvent("Click", CapsRefresh)
    dlg.AddButton("x+8 yp w" S(76) " h" S(26), "Close").OnEvent("Click", (*) => (_CapsNumGui := 0, dlg.Destroy()))
    dlg.Show("w" S(590) " AutoSize")
}

CapslockNumberRefresh(lv) {
    global CapslockSlotActions
    lv.Delete()
    for item in HK_CapsSlotIds() {
        d := HK_FindDef(item.id)
        if !IsObject(d)
            continue
        key := HK_Get(d.id, d.def)
        slotData := CapslockSlotActions.Has(item.slot) ? CapslockSlotActions[item.slot] : Map("type", "disabled", "action", "", "requirement", "", "enabled", 0)
        type := ToolkitNormalizeActionType(slotData.Get("type", "disabled"))
        action := slotData.Get("action", "")
        req := HK_NormalizeRequirement(slotData.Get("requirement", ""))
        status := CapslockSlotStatus(key, d.id, slotData)
        lv.Add(, item.label, key = "-" ? "(pass-through)" : HK_DisplayKey(key), type, action, status)
    }
}

CapslockSlotStatus(key, id, slotData) {
    if key = "-"
        return "Disabled"
    if !IsObject(slotData) || !slotData.Get("enabled", 0)
        return "Disabled"
    type := ToolkitNormalizeActionType(slotData.Get("type", "disabled"))
    if type = "disabled"
        return "Disabled"
    req := HK_NormalizeRequirement(slotData.Get("requirement", ""))
    if req != "" && !PieRequirementEnabled(req)
        return "Req Off"
    action := Trim(slotData.Get("action", ""))
    if action = ""
        return "Missing Action"
    dup := HK_CheckDuplicate(id, key)
    if dup != ""
        return dup
    if type = "shortcut" || type = "function" || type = "url" || type = "script" || type = "show pie"
        return "Enabled"
    return "Invalid Type"
}

CapslockNumberSelectedSlot(lv) {
    row := lv.GetNext()
    if !row {
        HK_SelectPrompt()
        return ""
    }
    return lv.GetText(row, 1)
}

CapslockNumberAssign(lv, *) {
    global HK_Custom, CapslockSlotActions
    slot := CapslockSlotStorageId(CapslockNumberSelectedSlot(lv))
    if slot = ""
        return
    id := "caps_num_" slot
    d := HK_FindDef(id)
    if !IsObject(d)
        return

    curKey := HK_Get(d.id, d.def)
    curData := CapslockSlotActions.Has(slot) ? CapslockSlotActions[slot] : Map("label", CapslockSlotTitle(slot), "type", "disabled", "action", "", "requirement", "", "enabled", 0)

    dlg := Gui("+AlwaysOnTop +ToolWindow", "Assign " CapslockSlotTitle(slot))
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(12)
    dlg.MarginY := S(12)
    px := S(105), ew := S(275), displayW := S(196), smallBtnW := S(58)

    Header(title) {
        hdrText := dlg.AddText("xm y+" S(8) " cFFD54F", title)
        hdrLine := dlg.AddText("xm y+" S(2) " w" S(370) " h1 Background444444", "")
        return [hdrText, hdrLine]
    }

    Header("Common data")
    dlg.AddText("xm", "Label:")
    labelEd := dlg.AddEdit("x" px " yp w" ew " c000000 BackgroundFFFFFF", curData.Get("label", CapslockSlotTitle(slot)))
    dlg.AddText("xm y+" S(8), "Hotkey:")
    hotkeyDisplay := dlg.AddText("x" px " yp w" ew " h" S(24) " +0x200 Center cFFFFFF Background2D2D32", "CapsLock & " CapslockSlotDisplay(slot))
    dlg.AddText("xm y+" S(8), "Type:")
    typeDd := dlg.AddDropDownList("x" px " yp w" ew, ["function", "shortcut", "url", "script", "disable", "show pie"])
    curType := ToolkitNormalizeActionType(curData.Get("type", "disabled"))
    typeDd.Value := curType = "function" ? 1 : curType = "shortcut" ? 2 : curType = "url" ? 3 : curType = "script" ? 4 : curType = "show pie" ? 6 : 5
    dlg.AddText("xm y+" S(8), "Requirement:")
    reqEd := dlg.AddEdit("x" px " yp w" ew " c000000 BackgroundFFFFFF", HK_NormalizeRequirement(curData.Get("requirement", "")))
    dlg.AddText("xm y+" S(4) " c888888 w" S(370), "Optional: Animation_autoaction.laf or Nastar.laf")
    enabledCb := dlg.AddCheckbox("xm y+" S(8) " cFFFFFF", "Enabled")
    enabledCb.Value := curData.Get("enabled", 0) ? 1 : 0

    specialHdr := Header("Special data")
    pieKindLbl := dlg.AddText("xm y+" S(8), "Pie type:")
    pieKindDd := dlg.AddDropDownList("x" px " yp w" S(100), ["Main pie", "Sub pie"])
    pieLbl := dlg.AddText("xm y+" S(8), "Pie:")
    pieDd := dlg.AddDropDownList("x" px " yp w" ew, ["Pie 1", "Pie 2", "Pie 3", "Pie 4"])
    curPieAction := StrLower(Trim(curData.Get("action", "main:1")))
    curIsSubPie := RegExMatch(curPieAction, "i)^(sub|subpie|sub pie)\s*[:= ]")
    pieKindDd.Value := curIsSubPie ? 2 : 1
    if curIsSubPie {
        subChoices := PieSubPieChoices()
        pieDd.Delete()
        for _, choice in subChoices
            pieDd.Add([choice])
        if RegExMatch(curPieAction, "i)(\d+)", &pm)
            pieDd.Value := PieSafeInt(pm[1], 1, 1, Max(1, subChoices.Length))
        else
            pieDd.Value := 1
    } else {
        if RegExMatch(curPieAction, "i)(\d+)", &pm)
            pieDd.Value := PieSafeInt(pm[1], 1, 1, 4)
        else
            pieDd.Value := 1
    }

    Header("Type data")
    actionLbl := dlg.AddText("xm y+" S(8), "Action:")
    actionEd := dlg.AddEdit("x" px " yp w" ew " c000000 BackgroundFFFFFF", curType = "show pie" ? "" : curData.Get("action", ""))
    actionDisplay := dlg.AddText("x" px " y+" S(4) " w" displayW+17 " h" S(24) " +0x200 Center cFFFFFF Background2D2D32", actionEd.Value != "" ? actionEd.Value : "...")
    recBtn := dlg.AddButton("x+" S(4) " yp w" smallBtnW " h" S(24), "Rec")
    fnPickBtn := dlg.AddButton("x" px " y+" S(4) " w" smallBtnW+10 " h" S(24), "Pick")
    browseBtn := dlg.AddButton("x+" S(4) " yp w" smallBtnW+10 " h" S(24), "...")
    testBtn := dlg.AddButton("x+" S(4) " yp w" smallBtnW+11 " h" S(24), "Test")
    guideBtn := dlg.AddButton("x+" S(4) " yp w" smallBtnW " h" S(24), "Fn Guide")
    helpTxt := dlg.AddText("xm y+" S(6) " w" S(370) " c888888", "")

    CapsSlotBrowseScriptOrUrl(*) {
        type := ToolkitNormalizeActionType(typeDd.Text)
        if type = "script" {
            fn := FileSelect("3", A_ScriptDir, "Select Script or App", "Scripts or Apps (*.ahk;*.exe)")
            if fn != ""
                actionEd.Value := fn
        } else if type = "url" {
            ib := InputBox("URL to open:", "CapsLock URL", "w420 h120", actionEd.Value)
            if ib.Result = "OK"
                actionEd.Value := Trim(ib.Value)
        }
        actionDisplay.Text := actionEd.Value != "" ? actionEd.Value : "..."
    }

    CapsSlotSelectedType() {
        type := ToolkitNormalizeActionType(typeDd.Text)
        return typeDd.Text = "disable" ? "disabled" : type
    }

    CapsSlotActionValue() {
        type := CapsSlotSelectedType()
        return type = "show pie" ? (pieKindDd.Value = 2 ? "sub:" pieDd.Value : "main:" pieDd.Value) : Trim(actionEd.Value)
    }

    CapsSlotRefreshPieChoices(*) {
        current := pieDd.Value
        pieDd.Delete()
        if pieKindDd.Value = 2 {
            choices := PieSubPieChoices()
            for _, choice in choices
                pieDd.Add([choice])
            pieDd.Value := Min(Max(1, current), Max(1, choices.Length))
        } else {
            for _, choice in ["Pie 1", "Pie 2", "Pie 3", "Pie 4"]
                pieDd.Add([choice])
            pieDd.Value := Min(Max(1, current), 4)
        }
    }

    CapsSlotToggleTools(*) {
        type := CapsSlotSelectedType()
        isShortcut := type = "shortcut"
        isFunction := type = "function"
        isScript := type = "script"
        isUrl := type = "url"
        isShowPie := type = "show pie"
        isDisabled := type = "disabled"
        hasAction := !(isShowPie || isDisabled)
        for ctrl in specialHdr
            ctrl.Visible := isShowPie
        pieKindLbl.Visible := isShowPie
        pieKindDd.Visible := isShowPie
        pieLbl.Visible := isShowPie
        pieDd.Visible := isShowPie
        actionLbl.Visible := hasAction
        actionEd.Visible := hasAction
        actionDisplay.Visible := hasAction
        recBtn.Visible := hasAction
        fnPickBtn.Visible := hasAction
        browseBtn.Visible := hasAction
        testBtn.Visible := !isDisabled
        guideBtn.Visible := hasAction
        actionLbl.Text := isUrl ? "URL / Link:" : isScript ? "Script path:" : isFunction ? "Function:" : "Action:"
        actionEd.Enabled := hasAction
        recBtn.Enabled := isShortcut
        fnPickBtn.Enabled := isFunction
        browseBtn.Enabled := isScript || isUrl
        guideBtn.Enabled := isFunction
        reqEd.Enabled := !isDisabled
        helpTxt.Text := type = "function" ? "Function: choose a callable function, e.g. HotkeyLayerBlack."
            : type = "shortcut" ? "Shortcut: record or type AHK keys, e.g. ^+!1."
            : type = "url" ? "URL: open an http:// or https:// link."
            : type = "script" ? "Script: run an .ahk or .exe path."
            : type = "show pie" ? "Show Pie: choose a main pie or sub pie to open from " CapslockSlotTitle(slot) "."
            : "Disabled slot will pass through."
        dlg.Show("AutoSize")
    }
    actionEd.OnEvent("Change", (*) => actionDisplay.Text := actionEd.Value != "" ? actionEd.Value : "...")
    typeDd.OnEvent("Change", CapsSlotToggleTools)
    pieKindDd.OnEvent("Change", CapsSlotRefreshPieChoices)
    recBtn.OnEvent("Click", (*) => HK_CaptureKey(dlg, actionEd, actionDisplay, recBtn))
    fnPickBtn.OnEvent("Click", (*) => HK_FunctionPicker(actionEd))
    browseBtn.OnEvent("Click", CapsSlotBrowseScriptOrUrl)
    testBtn.OnEvent("Click", (*) => ToolkitRunAction(CapsSlotSelectedType(), CapsSlotActionValue(), labelEd.Value != "" ? labelEd.Value : CapslockSlotTitle(slot)))
    guideBtn.OnEvent("Click", HK_ShowFunctionFieldGuide)
    CapsSlotToggleTools()

    SaveSlot(*) {
        type := CapsSlotSelectedType()
        action := CapsSlotActionValue()
        if (type = "shortcut" || type = "action") && action != ""
            action := PieQuickNormalizeShortcutAction(action)
        label := Trim(labelEd.Value)
        if label = ""
            label := CapslockSlotTitle(slot)
        req := HK_NormalizeRequirement(reqEd.Value)
        canRun := type != "disabled" && action != ""
        if enabledCb.Value && canRun {
            HK_Custom[d.id] := CapslockSlotHotkey(slot)
        } else {
            try HK_Custom.Delete(d.id)
        }
        CapslockSlotActions[slot] := Map("label", label, "type", type, "action", action, "requirement", req, "enabled", enabledCb.Value && canRun ? 1 : 0)
        HK_Save()
        HK_ReapplyAll()
        CapslockNumberRefresh(lv)
        dlg.Destroy()
    }

    dlg.AddButton("xm y+12 w" S(82) " h" S(28), "Save").OnEvent("Click", SaveSlot)
    dlg.AddButton("x+8 yp w" S(82) " h" S(28), "Cancel").OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("w" S(430) " AutoSize")
}

CapslockNumberClear(lv, *) {
    global HK_Custom, CapslockSlotActions
    row := 0
    did := false
    while row := lv.GetNext(row) {
        slot := CapslockSlotStorageId(lv.GetText(row, 1))
        id := "caps_num_" slot
        try HK_Custom.Delete(id)
        CapslockSlotActions[slot] := Map("label", CapslockSlotTitle(slot), "type", "disabled", "action", "", "requirement", "", "enabled", 0)
        did := true
    }
    if !did {
        HK_SelectPrompt()
        return
    }
    HK_Save()
    HK_ReapplyAll()
    CapslockNumberRefresh(lv)
}
