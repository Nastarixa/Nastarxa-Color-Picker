; FEATURES — Link Button Manager
; ============================================================

ShowLinkManager() {
    global LinkItems
    if !FeatureEnabled("linkgui") {
        ShowNotify("Link GUI", "Link GUI feature is OFF", "0xE53935")
        return
    }
    dlg := Gui("+AlwaysOnTop +ToolWindow +Owner", "Link GUI Button Manager - " ModeSettingsActiveName())
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")

    dlg.AddText("xm cFFD54F", "Mode: " ModeSettingsActiveName())
    dlg.AddText("xm y+2 w" S(688) " h1 Background555555")

    lv := dlg.AddListView("xm y+" S(6) " w" S(688) " r" S(14) " +Multi +ReadOnly NoSortHdr", ["#","Type","Icon","Label","Hover","Note","Enabled"])
    lv.SetFont("c000000", "Segoe UI")
    lv.OnEvent("DoubleClick", (*) => EditItem())
    lv.ModifyCol(1, S(28))
    lv.ModifyCol(2, S(58))
    lv.ModifyCol(3, S(42))
    lv.ModifyCol(4, S(95))
    lv.ModifyCol(5, S(145))
    lv.ModifyCol(6, S(244))
    lv.ModifyCol(7, S(55))

    RefreshList()

    ; Deep clone for Reset Selected
    _savedDefaults := []
    for item in LinkItems {
        m := Map()
        for k, v in item
            m[k] := v
        _savedDefaults.Push(m)
    }

    btnW := S(93), gap := S(6), btnH := S(28), enableW := (btnW * 2) + gap
    dlg.AddButton("xm y+" gap " w" btnW " h" btnH, "▲ Up").OnEvent("Click", (*) => MoveItem(-1))
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "▼ Down").OnEvent("Click", (*) => MoveItem(1))
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Add").OnEvent("Click", (*) => AddItem())
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Edit").OnEvent("Click", (*) => EditItem())
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Remove").OnEvent("Click", (*) => RemoveItem())
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Reset Sel").OnEvent("Click", (*) => ResetSelected())
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Reset All").OnEvent("Click", (*) => ResetAll())
    dlg.AddButton("xm y+" gap " w" enableW " h" btnH, "Enable/Disable").OnEvent("Click", (*) => ToggleItem())
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH " c4CAF50", "Export").OnEvent("Click", (*) => ExportLinkItems())
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH " cFF9800", "Import").OnEvent("Click", (*) => ImportLinkItems())
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH " Default", "Save").OnEvent("Click", (*) => DoSave())
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Close").OnEvent("Click", (*) => dlg.Destroy())
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH " Background4CAF50 cFFFFFF", "Done").OnEvent("Click", (*) => DoApply())
    dlg.Show("AutoSize")

    AddItem() {
        global LinkItems
        item := LinkItemDialog(Map())
        if item {
            LinkItems.Push(item)
            SaveLinkItems()
            RebuildLinkGUI()
            RefreshList()
        }
    }

    EditItem() {
        global LinkItems
        r := lv.GetNext()
        if !r
            return
        idx := Integer(lv.GetText(r, 1))
        item := LinkItems[idx]
        if item.Get("system", false)
            return
        newItem := LinkItemDialog(item.Clone(), (applied) => (
            LinkItems[idx] := applied,
            SaveLinkItems(),
            RebuildLinkGUI(),
            RefreshList()
        ))
        if newItem {
            LinkItems[idx] := newItem
            SaveLinkItems()
            RebuildLinkGUI()
            RefreshList()
        }
    }

    RemoveItem() {
        global LinkItems
        rows := []
        r := 0
        while r := lv.GetNext(r)
            rows.Push(Integer(lv.GetText(r, 1)))
        if rows.Length = 0
            return
        if !RemovePrompt()
            return
        for i in rows {
            idx := rows[rows.Length - A_Index + 1]
            item := LinkItems[idx]
            if item.Get("system", false)
                continue
            LinkItems.RemoveAt(idx)
        }
        SaveLinkItems()
        RebuildLinkGUI()
        RefreshList()
    }

    RemovePrompt() {
        popup := Gui("+AlwaysOnTop +ToolWindow", "Remove Link Buttons")
        popup.BackColor := "1E1F22"
        popup.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
        popup.MarginX := S(14)
        popup.MarginY := S(14)
        popup.AddText("cFFD54F", "Remove selected link buttons?")
        result := false
        popup.AddButton("xm y+10 w" S(80) " h" S(26) " BackgroundE53935 cFFFFFF", "Yes").OnEvent("Click", (*) => (result := true, popup.Destroy()))
        popup.AddButton("x+8 yp w" S(80) " h" S(26), "No").OnEvent("Click", (*) => popup.Destroy())
        popup.Show("AutoSize")
        GuiWaitForCloseSafe(popup)
        return result
    }

    ToggleItem() {
        global LinkItems
        r := lv.GetNext()
        if !r
            return
        idx := Integer(lv.GetText(r, 1))
        item := LinkItems[idx]
        if item.Get("system", false)
            return
        if item.Get("type","") = "disabled" {
            item["type"] := item.Get("_origType", "shortcut")
            if item.Has("_origType")
                item.Delete("_origType")
        } else {
            item["_origType"] := item.Get("type","shortcut")
            item["type"] := "disabled"
        }
        SaveLinkItems()
        RebuildLinkGUI()
        RefreshList()
    }

    MoveItem(dir) {
        global LinkItems
        r := lv.GetNext()
        if !r
            return
        idx := Integer(lv.GetText(r, 1))
        ni := idx + dir
        if ni < 1 || ni > LinkItems.Length
            return
        tmp := LinkItems[idx]
        LinkItems[idx] := LinkItems[ni]
        LinkItems[ni] := tmp
        SaveLinkItems()
        RebuildLinkGUI()
        RefreshList()
        lv.Modify(r + dir, "Select Focus")
    }

    ResetSelected() {
        global LinkItems
        rows := []
        r := 0
        while r := lv.GetNext(r)
            rows.Push(Integer(lv.GetText(r, 1)))
        if rows.Length = 0
            return
        if !ResetPrompt()
            return
        for i in rows {
            idx := rows[rows.Length - A_Index + 1]
            item := LinkItems[idx]
            if item.Get("system", false)
                continue
            if idx <= _savedDefaults.Length {
                def := _savedDefaults[idx]
                newItem := Map()
                for k, v in def
                    newItem[k] := v
                LinkItems[idx] := newItem
            } else {
                LinkItems.RemoveAt(idx)
            }
        }
        SaveLinkItems()
        RebuildLinkGUI()
        RefreshList()
    }

    ResetAll() {
        global LinkItems
        if !ResetPrompt()
            return
        LinkItemsDefaults()
        SaveLinkItems()
        RebuildLinkGUI()
        RefreshList()
    }

    DoSave() {
        SaveLinkItems()
        RebuildLinkGUI()
    }

    DoApply() {
        SaveLinkItems()
        RebuildLinkGUI()
        dlg.Destroy()
    }

    ResetPrompt() {
        popup := Gui("+AlwaysOnTop +ToolWindow", "Reset Link Buttons")
        popup.BackColor := "1E1F22"
        popup.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
        popup.MarginX := S(14)
        popup.MarginY := S(14)
        popup.AddText("cFFD54F", "Restore default link buttons?")
        popup.AddText("xm y+" S(4) " cAAAAAA", "This will remove all custom items.")
        result := false
        popup.AddButton("xm y+10 w" S(80) " h" S(26) " BackgroundE53935 cFFFFFF", "Yes").OnEvent("Click", (*) => (result := true, popup.Destroy()))
        popup.AddButton("x+8 yp w" S(80) " h" S(26), "No").OnEvent("Click", (*) => popup.Destroy())
        popup.Show("AutoSize")
        GuiWaitForCloseSafe(popup)
        return result
    }

    RefreshList() {
        lv.Delete()
        for idx, item in LinkItems {
            t := item.Get("type","")
            system := item.Get("system", false)
            icon := item.Get("icon","")
            note := item.Get("note","")
            if t = "disabled" && !system {
                note := note != "" ? "DISABLED - " note : "DISABLED"
                icon := "⬤"
            }
            if t = "disabled" && !system
                icon := "X"
            row := lv.Add("", idx, t, icon, item.Get("label",""), item.Get("hover",""), note, t = "disabled" ? "No" : "Yes")
        }
    }

    ExportLinkItems() {
        global LinkItems
        dest := FileSelect("S", A_MyDocuments "\LinkItems.json", "Save", "*.json")
        if dest = ""
            return
        try {
            data := _MapToJSON(LinkItems)
            try FileDelete(dest)
            FileAppend(data, dest, "UTF-8")
            ShowNotify("Link Export", "Exported " LinkItems.Length " items", "0x4CAF50")
        } catch as e {
            ShowNotify("Link Export Error", e.Message, "0xE53935")
        }
    }

    ImportLinkItems() {
        global LinkItems
        src := FileSelect(1, A_MyDocuments, "Open", "*.json")
        if src = ""
            return
        try {
            raw := FileRead(src, "UTF-8")
            if !raw
                throw Error("File is empty")
            parsed := _JSONToMap(raw)
            if !(parsed is Array) || parsed.Length = 0
                throw Error("Invalid link item data in file")
            LinkItems := parsed
            _savedDefaults := []
            for item in LinkItems {
                m := Map()
                for k, v in item
                    m[k] := v
                _savedDefaults.Push(m)
            }
            SaveLinkItems()
            RebuildLinkGUI()
            RefreshList()
            ShowNotify("Link Import", "Imported " LinkItems.Length " items", "0x4CAF50")
        } catch as e {
            ShowNotify("Link Import Error", e.Message, "0xE53935")
        }
    }
}

ShowKeysGuide(*) {
    guide := Gui("+AlwaysOnTop +ToolWindow", "Keys Guide")
    guide.BackColor := "1E1F22"
    guide.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    guide.MarginX := S(14)
    guide.MarginY := S(14)
    guide.SetFont("s" S(10) " Bold", "Segoe UI")
    guide.AddText("xm", "Key Syntax Reference")
    guide.SetFont("s" S(9) " norm", "Segoe UI")
    guide.AddText("xm y+" S(6) " cAAAAAA", "Use AHK key notation inside {...}:")
    guide.AddText("xm y+" S(4), '  {LButton}        — Left mouse click')
    guide.AddText("xm y+" S(2), '  {RButton}        — Right mouse click')
    guide.AddText("xm y+" S(4) " cAAAAAA", "Modifier keys hold down until released:")
    guide.AddText("xm y+" S(2), '  {Shift Down}     — Press and hold Shift')
    guide.AddText("xm y+" S(2), '  {Shift Up}       — Release Shift')
    guide.AddText("xm y+" S(2), '  {Ctrl Down}      — Press and hold Ctrl')
    guide.AddText("xm y+" S(2), '  {Ctrl Up}        — Release Ctrl')
    guide.AddText("xm y+" S(4) " cAAAAAA", "Key combinations (held together):")
    guide.AddText("xm y+" S(2), '  {Ctrl Down}{a}{Ctrl Up}  — Ctrl+A')
    guide.AddText("xm y+" S(2), '  ^+!x              — Shift+Ctrl+Alt+X (shorthand)')
    guide.AddText("xm y+" S(4) " cAAAAAA", "Special keys:")
    guide.AddText("xm y+" S(2), "  {Enter}, {Tab}, {Esc}, {Space}")
    guide.AddText("xm y+" S(2), "  {F1}-{F12}, {1}-{0}, {a}-{z}")
    guide.AddText("xm y+" S(4) " cAAAAAA", "Extra keys (after): sent after main keys")
    guide.AddText("xm y+" S(2), '  e.g. {Enter} to confirm after shortcut')
    guide.AddText("xm y+" S(4) " cAAAAAA", "Pie / Tab features:")
    guide.AddText("xm y+" S(2), '  Tab               — Sends {Tab} normally')
    guide.AddText("xm y+" S(2), '  CapsLock          — Opens Pie 1 menu (when held with Tab)')
    guide.AddText("xm y+" S(2), '  Hold Tab          — Enters Tab Hold mode')
    guide.AddText("xm y+" S(8) " cFFD54F", "Available Functions:")
    guide.AddText("xm y+" S(2), "  ShowCSPGuide()        — Toolkit Guide")
    guide.AddText("xm y+" S(2), "  ToggleMainWindow()    — Show/hide main panel")
    guide.AddText("xm y+" S(2), "  ShowColorHistory()    — Open color history")
    guide.AddText("xm y+" S(2), "  ShowNotify(Title, Text) — Show toast notification")
    guide.AddText("xm y+" S(2), "  HotkeyVectorPaths()   — Vector path tools")
    guide.AddText("xm y+" S(2), "  ToggleColorLayout()   — Flip palette layout")
    guide.AddText("xm y+" S(2), "  ShowPieMenu(n)        — Open pie menu n (1-8)")
    guide.AddText("xm y+" S(4) " c888888", "Type function names in Action field, then pick from list.")
    guide.AddButton("xm y+" S(10) " w" S(80) " h" S(26), "OK").OnEvent("Click", (*) => guide.Destroy())
    guide.Show("AutoSize")
}

LinkItemDialog(existing, applyCallback := 0) {
    if !IsObject(existing) || !existing.Has("type")
        existing := Map("type","shortcut","icon","","icon2","","label","","hover","","note","","color","455A64","color2","","keys","","extra","","target","","action","","toggle",0,"keys2","","extra2","","target2","","action2","")
    isNew := existing.Get("type","") = ""
    rawType := existing.Get("type","shortcut")
    if rawType = "action"
        rawType := "shortcut"

    dlg := Gui("+AlwaysOnTop +ToolWindow", isNew ? "Add Link Item" : "Edit Link Item")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(12)
    dlg.MarginY := S(12)

    px := S(105)
    ew := S(260)
    displayW := S(190)
    smallBtnW := S(60)
    Header(title) {
        hdrText := dlg.AddText("xm y+" S(8) " cFFD54F", title)
        hdrLine := dlg.AddText("xm y+" S(2) " w" S(355) " h1 Background444444", "")
        return [hdrText, hdrLine]
    }

    commonHdr := Header("Common data")
    dlg.AddText("xm", "Type:")
    ddl := dlg.AddDropDownList("x" px " yp w" ew " vType", ["shortcut","function","url","script","sep","disabled"])
    t := rawType
    ddl.Value := t = "shortcut" ? 1 : t = "function" ? 2 : t = "url" ? 3 : t = "script" ? 4 : t = "sep" ? 5 : 6
    ddl.OnEvent("Change", (*) => LinkDlg_ToggleType())

    dlg.AddText("xm y+" S(4), "Color (hex):")
    colorEd := dlg.AddEdit("x" px " yp w" S(86) " c000000 vColor", PieSafeColor(existing.Get("color","")))
    c0 := dlg.AddText("x+" S(4) " yp w" S(22) " h" S(22) " +0x200 Background" PieSafeColor(existing.Get("color","455A64")), "")
    dlg.AddText("x+" S(4) " yp w" S(18) " h" S(22) " +0x200 BackgroundE53935 cFFFFFF Center", "R").OnEvent("Click", (*) => (colorEd.Value := "E53935", LinkDlg_UpdateSwatch(), colorEd.Focus()))
    dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background0F9D58 cFFFFFF Center", "G").OnEvent("Click", (*) => (colorEd.Value := "0F9D58", LinkDlg_UpdateSwatch(), colorEd.Focus()))
    dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background4285F4 cFFFFFF Center", "B").OnEvent("Click", (*) => (colorEd.Value := "4285F4", LinkDlg_UpdateSwatch(), colorEd.Focus()))
    dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 BackgroundE39A2D cFFFFFF Center", "O").OnEvent("Click", (*) => (colorEd.Value := "E39A2D", LinkDlg_UpdateSwatch(), colorEd.Focus()))
    dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background9C27B0 cFFFFFF Center", "V").OnEvent("Click", (*) => (colorEd.Value := "9C27B0", LinkDlg_UpdateSwatch(), colorEd.Focus()))
    dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background00BCD4 cFFFFFF Center", "C").OnEvent("Click", (*) => (colorEd.Value := "00BCD4", LinkDlg_UpdateSwatch(), colorEd.Focus()))
    dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background607D8B cFFFFFF Center", "Gr").OnEvent("Click", (*) => (colorEd.Value := "607D8B", LinkDlg_UpdateSwatch(), colorEd.Focus()))

    lblLbl := dlg.AddText("xm y+" S(4), "Label:")
    lblEd := dlg.AddEdit("x" px " yp w" ew " c000000 vLabel", existing.Get("label",""))

    hovLbl := dlg.AddText("xm y+" S(4), "Hover text:")
    hovEd := dlg.AddEdit("x" px " yp w" ew " c000000 vHover", existing.Get("hover",""))

    noteLbl := dlg.AddText("xm y+" S(4), "Note:")
    noteEd := dlg.AddEdit("x" px " yp w" ew " c000000 vNote", existing.Get("note",""))

    toggleCb := dlg.AddCheckbox("x" px " y+" S(6) " cFFFFFF", "Toggle button: alternate Action A / B")
    toggleCb.Value := ToolkitSafeInt(existing.Get("toggle", 0), 0, 0, 1) ? 1 : 0

    specialHdr := Header("Special data")
    iconLbl := dlg.AddText("xm y+" S(4), "Icon:")
    iconPresets := LinkIconPresetList()
    iconCustomCb := dlg.AddCheckbox("x" px " yp cFFFFFF", "Custom text")
    iconCustomCb.Value := !LinkIconPresetIndex(existing.Get("icon",""), iconPresets)
    iconBoldCb := dlg.AddCheckbox("x+" S(16) " yp cFFFFFF", "Bold icon")
    iconBoldCb.Value := existing.Get("iconBold", true)
    iconDd := dlg.AddDropDownList("x" px " y+" S(4) " w" ew, iconPresets)
    presetIdx := LinkIconPresetIndex(existing.Get("icon",""), iconPresets)
    iconDd.Value := presetIdx ? presetIdx : 1
    iconEd := dlg.AddEdit("x" px " y+4 w" ew " c000000 vIcon", existing.Get("icon",""))
    typeHdr := Header("Type data")
    typeHelp := dlg.AddText("xm y+" S(2) " w" S(355) " cFFFFFF -Border", "Shortcut: keystrokes to send")
    actionLbl := dlg.AddText("xm y+" S(6), "Action:")
    actionValue := rawType = "function" ? existing.Get("action","")
        : (rawType = "url" || rawType = "script") ? existing.Get("target","")
        : existing.Get("keys","")
    actionEd := dlg.AddEdit("x" px " yp w" ew " c000000 BackgroundFFFFFF", actionValue)
    actionDisplay := dlg.AddText("x" px " y+" S(4) " w" (displayW+5) " h" S(24) " +0x200 Center cFFFFFF Background2D2D32", actionValue != "" ? actionValue : "...")
    actionRecBtn := dlg.AddButton("x+4 yp w" smallBtnW " h" S(24), "Rec")
    fnPickBtn := dlg.AddButton("x" px " y+" S(4) " w" smallBtnW " h" S(24), "Pick")
    browseBtn := dlg.AddButton("x+4 yp w" smallBtnW " h" S(24), "...")
    actExtraL := dlg.AddText("xm y+" S(4), "Extra keys (after):")
    actExtra := dlg.AddEdit("x" px " yp w" ew " c000000", existing.Get("extra",""))

    actionBHdr := Header("Action B data")
    icon2Lbl := dlg.AddText("xm y+" S(4), "B icon:")
    icon2CustomCb := dlg.AddCheckbox("x" px " yp cFFFFFF", "Custom text")
    icon2CustomCb.Value := !LinkIconPresetIndex(existing.Get("icon2",""), iconPresets)
    icon2Dd := dlg.AddDropDownList("x" px " y+" S(4) " w" ew, iconPresets)
    preset2Idx := LinkIconPresetIndex(existing.Get("icon2",""), iconPresets)
    icon2Dd.Value := preset2Idx ? preset2Idx : 1
    icon2Ed := dlg.AddEdit("x" px " y+4 w" ew " c000000", existing.Get("icon2",""))
    iconCustomCb.OnEvent("Click", (*) => LinkDlg_ToggleIconMode())
    icon2CustomCb.OnEvent("Click", (*) => LinkDlg_ToggleIconMode())
    iconDd.OnEvent("Change", (*) => (
        !iconCustomCb.Value ? iconEd.Value := LinkIconFromPreset(iconDd.Text) : ""
    ))
    icon2Dd.OnEvent("Change", (*) => (
        !icon2CustomCb.Value ? icon2Ed.Value := LinkIconFromPreset(icon2Dd.Text) : ""
    ))
    color2Lbl := dlg.AddText("xm y+" S(4), "B color (hex):")
    color2Default := existing.Get("color2","") != "" ? existing.Get("color2","") : existing.Get("color","455A64")
    color2Ed := dlg.AddEdit("x" px " yp w" S(86) " c000000", PieSafeColor(color2Default))
    c2 := dlg.AddText("x+" S(4) " yp w" S(22) " h" S(22) " +0x200 Background" PieSafeColor(color2Default), "")
    bColorBtns := []
    bColorBtns.Push(dlg.AddText("x+" S(4) " yp w" S(18) " h" S(22) " +0x200 BackgroundE53935 cFFFFFF Center", "R"))
    bColorBtns[1].OnEvent("Click", (*) => (color2Ed.Value := "E53935", LinkDlg_UpdateSwatch2(), color2Ed.Focus()))
    bColorBtns.Push(dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background0F9D58 cFFFFFF Center", "G"))
    bColorBtns[2].OnEvent("Click", (*) => (color2Ed.Value := "0F9D58", LinkDlg_UpdateSwatch2(), color2Ed.Focus()))
    bColorBtns.Push(dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background4285F4 cFFFFFF Center", "B"))
    bColorBtns[3].OnEvent("Click", (*) => (color2Ed.Value := "4285F4", LinkDlg_UpdateSwatch2(), color2Ed.Focus()))
    bColorBtns.Push(dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 BackgroundE39A2D cFFFFFF Center", "O"))
    bColorBtns[4].OnEvent("Click", (*) => (color2Ed.Value := "E39A2D", LinkDlg_UpdateSwatch2(), color2Ed.Focus()))
    bColorBtns.Push(dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background9C27B0 cFFFFFF Center", "V"))
    bColorBtns[5].OnEvent("Click", (*) => (color2Ed.Value := "9C27B0", LinkDlg_UpdateSwatch2(), color2Ed.Focus()))
    bColorBtns.Push(dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background00BCD4 cFFFFFF Center", "C"))
    bColorBtns[6].OnEvent("Click", (*) => (color2Ed.Value := "00BCD4", LinkDlg_UpdateSwatch2(), color2Ed.Focus()))
    bColorBtns.Push(dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background607D8B cFFFFFF Center", "Gr"))
    bColorBtns[7].OnEvent("Click", (*) => (color2Ed.Value := "607D8B", LinkDlg_UpdateSwatch2(), color2Ed.Focus()))

    action2Lbl := dlg.AddText("xm y+" S(6), "Action B:")
    action2Value := rawType = "function" ? existing.Get("action2","")
        : (rawType = "url" || rawType = "script") ? existing.Get("target2","")
        : existing.Get("keys2","")
    action2Ed := dlg.AddEdit("x" px " yp w" ew " c000000 BackgroundFFFFFF", action2Value)
    action2Display := dlg.AddText("x" px " y+" S(4) " w" (displayW+5) " h" S(24) " +0x200 Center cFFFFFF Background2D2D32", action2Value != "" ? action2Value : "...")
    action2RecBtn := dlg.AddButton("x+4 yp w" smallBtnW " h" S(24), "Rec")
    fnPickBtn2 := dlg.AddButton("x" px " y+" S(4) " w" smallBtnW " h" S(24), "Pick")
    browseBtn2 := dlg.AddButton("x+4 yp w" smallBtnW " h" S(24), "...")
    actExtra2L := dlg.AddText("xm y+" S(4), "Extra B:")
    actExtra2 := dlg.AddEdit("x" px " yp w" ew " c000000", existing.Get("extra2",""))

    dlg.AddText("xm y-2", "")
    okBtn := dlg.AddButton("xm w" S(80) " h" S(26) " Default", "OK")
    if IsObject(applyCallback)
        dlg.AddButton("x+" S(8) " yp w" S(80) " h" S(26), "Apply").OnEvent("Click", (*) => (
            _result := LinkDlg_BuildResult(),
            result := _result,
            applyCallback(_result),
            ShowNotify("Link Item", "Applied")
        ))
    caBtn := dlg.AddButton("x+" S(10) " yp w" S(80) " h" S(26), "Cancel")
    dlg.AddButton("x+" S(12) " yp w" S(80) " h" S(26) " c9C27B0", "Keys Guide").OnEvent("Click", (*) => ShowKeysGuide())

    result := false

    LinkDlg_ToggleIconMode() {
        useCustom := !!iconCustomCb.Value
        iconDd.Enabled := !useCustom
        iconEd.Enabled := useCustom
        if !useCustom
            iconEd.Value := LinkIconFromPreset(iconDd.Text)
        useCustom2 := !!icon2CustomCb.Value
        icon2Dd.Enabled := !useCustom2
        icon2Ed.Enabled := useCustom2
        if !useCustom2
            icon2Ed.Value := LinkIconFromPreset(icon2Dd.Text)
    }

    LinkDlg_ToggleType() {
        t := ddl.Text
        isShortcut := t = "shortcut"
        isFunction := t = "function"
        isUrl := t = "url"
        isScript := t = "script"
        isSep := t = "sep"
        activeType := !(isSep || t = "disabled")
        hasLabel := t != "disabled"
        hasMetaText := activeType
        lblLbl.Visible := hasLabel
        lblEd.Visible := hasLabel
        hovLbl.Visible := hasMetaText
        hovEd.Visible := hasMetaText
        noteLbl.Visible := hasMetaText
        noteEd.Visible := hasMetaText
        hasIconData := activeType
        for ctrl in specialHdr
            ctrl.Visible := hasIconData
        iconLbl.Visible := hasIconData
        iconCustomCb.Visible := hasIconData
        iconBoldCb.Visible := hasIconData
        iconDd.Visible := hasIconData
        iconEd.Visible := hasIconData
        showToggle := activeType && toggleCb.Value
        for ctrl in actionBHdr
            ctrl.Visible := showToggle
        icon2Lbl.Visible := hasIconData && showToggle
        icon2CustomCb.Visible := hasIconData && showToggle
        icon2Dd.Visible := hasIconData && showToggle
        icon2Ed.Visible := hasIconData && showToggle
        color2Lbl.Visible := showToggle
        color2Ed.Visible := showToggle
        c2.Visible := showToggle
        for ctrl in bColorBtns
            ctrl.Visible := showToggle
        actionLbl.Visible := activeType
        actionEd.Visible := activeType
        actionRecBtn.Visible := activeType
        fnPickBtn.Visible := activeType
        browseBtn.Visible := activeType
        actionDisplay.Visible := activeType
        actExtraL.Visible := isShortcut
        actExtra.Visible := isShortcut
        toggleCb.Visible := activeType
        action2Lbl.Visible := showToggle
        action2Ed.Visible := showToggle
        action2Display.Visible := showToggle
        action2RecBtn.Visible := showToggle
        fnPickBtn2.Visible := showToggle
        browseBtn2.Visible := showToggle
        actExtra2L.Visible := showToggle && isShortcut
        actExtra2.Visible := showToggle && isShortcut
        actionLbl.Text := isUrl ? "URL / Link:" : isScript ? "Script path:" : "Action:"
        actionRecBtn.Enabled := isShortcut
        fnPickBtn.Enabled := isFunction
        browseBtn.Enabled := isUrl || isScript
        action2RecBtn.Enabled := isShortcut
        fnPickBtn2.Enabled := isFunction
        browseBtn2.Enabled := isUrl || isScript
        actionEd.Enabled := activeType
        action2Ed.Enabled := showToggle
        if isShortcut
            typeHelp.Text := "Shortcut: keystrokes to send in CSP"
        else if isFunction
            typeHelp.Text := "Function: AHK function name to call"
        else if isUrl
            typeHelp.Text := "URL: web address to open"
        else if isScript
            typeHelp.Text := "Script: .ahk / .exe path to run"
        else if isSep
            typeHelp.Text := "Separator: section header, no extra settings"
        else
            typeHelp.Text := "Disabled: placeholder slot"
        dlg.Show("AutoSize")
    }

    LinkDlg_UpdateSwatch(*) {
        c := RegExReplace(RegExReplace(Trim(colorEd.Value), "i)^(#|0x)", ""), "[^0-9A-Fa-f]", "")
        if RegExMatch(c, "i)^[0-9A-F]{1,6}$") {
            padded := c
            Loop 6 - StrLen(c)
                padded .= "0"
            padded := StrUpper(padded)
            c0.Opt("Background" padded)
            c0.Redraw()
        }
    }
    LinkDlg_UpdateSwatch2(*) {
        c := RegExReplace(RegExReplace(Trim(color2Ed.Value), "i)^(#|0x)", ""), "[^0-9A-Fa-f]", "")
        if RegExMatch(c, "i)^[0-9A-F]{1,6}$") {
            padded := c
            Loop 6 - StrLen(c)
                padded .= "0"
            padded := StrUpper(padded)
            c2.Opt("Background" padded)
            c2.Redraw()
        }
    }
    colorEd.OnEvent("Change", LinkDlg_UpdateSwatch)
    color2Ed.OnEvent("Change", LinkDlg_UpdateSwatch2)
    LinkDlg_UpdateSwatch()
    LinkDlg_UpdateSwatch2()
    actionEd.OnEvent("Change", (*) => actionDisplay.Text := actionEd.Value != "" ? actionEd.Value : "...")
    action2Ed.OnEvent("Change", (*) => action2Display.Text := action2Ed.Value != "" ? action2Ed.Value : "...")
    toggleCb.OnEvent("Click", (*) => LinkDlg_ToggleType())

    actionRecBtn.OnEvent("Click", (*) => HK_CaptureKey(dlg, actionEd, actionDisplay, actionRecBtn))
    action2RecBtn.OnEvent("Click", (*) => HK_CaptureKey(dlg, action2Ed, action2Display, action2RecBtn))
    fnPickBtn.OnEvent("Click", (*) => HK_FunctionPicker(actionEd))
    fnPickBtn2.OnEvent("Click", (*) => HK_FunctionPicker(action2Ed))
    okBtn.OnEvent("Click", (*) => (result := LinkDlg_BuildResult(), dlg.Destroy()))
    browseBtn.OnEvent("Click", (*) => LinkDlg_Browse(actionEd))
    browseBtn2.OnEvent("Click", (*) => LinkDlg_Browse(action2Ed))

    LinkDlg_BuildResult() {
        iconValue := iconCustomCb.Value ? iconEd.Value : LinkIconFromPreset(iconDd.Text)
        icon2Value := icon2CustomCb.Value ? icon2Ed.Value : LinkIconFromPreset(icon2Dd.Text)
        built := Map(
            "type", ddl.Text,
            "icon", iconValue,
            "iconBold", iconBoldCb.Value,
            "label", lblEd.Value,
            "hover", hovEd.Value,
            "note", noteEd.Value,
            "color", PieSafeColor(colorEd.Value)
        )
        if toggleCb.Value {
            if Trim(icon2Value) != ""
                built["icon2"] := icon2Value
            built["color2"] := PieSafeColor(color2Ed.Value)
        }
        t := ddl.Text
        if t = "shortcut" || t = "action" {
            built["keys"] := PieQuickNormalizeShortcutAction(actionEd.Value)
            if actExtra.Value != ""
                built["extra"] := PieQuickNormalizeShortcutAction(actExtra.Value)
            if toggleCb.Value {
                built["toggle"] := 1
                built["keys2"] := PieQuickNormalizeShortcutAction(action2Ed.Value)
                if actExtra2.Value != ""
                    built["extra2"] := PieQuickNormalizeShortcutAction(actExtra2.Value)
            }
        } else if t = "function" {
            built["action"] := actionEd.Value
            if toggleCb.Value {
                built["toggle"] := 1
                built["action2"] := action2Ed.Value
            }
        } else if t = "url" || t = "script" {
            built["target"] := actionEd.Value
            if toggleCb.Value {
                built["toggle"] := 1
                built["target2"] := action2Ed.Value
            }
        }
        return built
    }

    caBtn.OnEvent("Click", (*) => dlg.Destroy())

    LinkDlg_Browse(targetEd := 0, *) {
        if !IsObject(targetEd)
            targetEd := actionEd
        if ddl.Text = "url" {
            urlDlg := Gui("+AlwaysOnTop +ToolWindow", "Item URL")
            urlDlg.BackColor := "1E1F22"
            urlDlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
            urlDlg.MarginX := S(12)
            urlDlg.MarginY := S(12)
            urlDlg.AddText("xm", "URL / Link:")
            urlEd := urlDlg.AddEdit("x" S(80) " yp w" S(340) " c000000 BackgroundFFFFFF", targetEd.Value)
            urlDlg.AddText("xm y+" S(4) " c888888", "Enter a URL, for example https://example.com")
            urlResult := ""
            urlDlg.AddButton("xm y+" S(12) " w" S(80) " h" S(26) " Default", "OK").OnEvent("Click", (*) => (urlResult := Trim(urlEd.Value), urlDlg.Destroy()))
            urlDlg.AddButton("x+" S(8) " yp w" S(80) " h" S(26), "Cancel").OnEvent("Click", (*) => urlDlg.Destroy())
            urlDlg.Show("AutoSize")
            GuiWaitForCloseSafe(urlDlg)
            if urlResult != ""
                targetEd.Value := urlResult
            return
        }
        f := FileSelect(1,, "Select script", "Scripts (*.ahk; *.exe)")
        if f != ""
            targetEd.Value := f
    }

    LinkDlg_ToggleType()
    LinkDlg_ToggleIconMode()
    actionDisplay.Text := actionEd.Value != "" ? actionEd.Value : "..."
    dlg.Show("w" S(410) " AutoSize")
    GuiWaitForCloseSafe(dlg)
    return result
}

LinkIconPresetList() {
    return [
        "◆ Main",
        "Guide",
        "⚙ Settings",
        "⌨ Hotkeys",
        "∞ Link",
        "▤ Sheets",
        "⊞ Drive",
        "◎ Search",
        "☉ Web",
        "⏏ File",
        "⊞ Folder",
        "▶ Run",
        "◈ Color",
        "◆ Image",
        "▶ Timeline",
        "⏱ Timer",
        "⤵ Save",
        "⚒ Tools",
        "★ Star",
        "● Dot",
        "＋ Add",
        "－ Remove",
        "「」 Canvas Size",
        "⚑ Pin",
        "◎ Target",
        "⚡ Zap",
        "△ Fire",
        "⊠ Lock",
        "⊡ Unlock",
        "✓ Check",
        "✕ Close",
        "↻ Refresh",
        "⌂ Home",
        "▣ Box",
        "⌫ Trash",
        "◉ View",
        "▷ Film",
        "✒ Pen",
        "✏ Pencil",
        "☀ Idea",
        "⭐ Star2",
        "♛ Trophy",
        "◇ Key",
        "△ Rocket",
        "◆ Gem",
        "≡ Board",
        "◐ Bell",
        "☰ Chat",
        "✉ Mail",
        "▣ Screen",
        "☏ Phone",
        "♫ Music",
        "☀ Sun",
        "☽ Moon",
        "⚙ Wrench",
        "∟ Ruler",
        "✎ Brush",
        "▷ Reel",
        "⚙ Gear",
        "⊘ Block",
        "⌷ Tag",
        "≡ Note"
    ]
}

LinkIconPresetIndex(icon, presets) {
    icon := Trim(icon)
    if icon = ""
        return 0
    for i, entry in presets {
        if LinkIconFromPreset(entry) = icon
            return i
    }
    return 0
}

LinkIconFromPreset(entry) {
    entry := Trim(entry)
    if entry = ""
        return ""
    parts := StrSplit(entry, " ")
    return parts.Length ? parts[1] : entry
}

RebuildLinkGUI() {
    global LinkGUI, LinkGUI_X, LinkGUI_Y
    if IsObject(LinkGUI)
        LinkGUI.Destroy()
    CreateLinkGUI()
    PositionLinkGUI()
}

; ============================================================
