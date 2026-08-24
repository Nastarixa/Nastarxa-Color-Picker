; GUI — Link Launcher
; ============================================================

CreateLinkGUI() => ToolScaleCall(CreateLinkGUI_Impl)

CreateLinkGUI_Impl() {
    global LinkGUI, LinkItems, _linkCollapsed, LinkLayout
    if IsObject(LinkGUI) {
        try if LinkGUI.Hwnd
            return
    }
    LinkGUI := Gui("+AlwaysOnTop -Caption +ToolWindow")
    LinkGUI.BackColor := "1E1E1E"
    LinkGUI.SetFont("s" S(7) " cFFFFFF", "Segoe UI")

    hMode := LinkLayout = "H"
    bw := S(25)
    bh := S(30)
    gap := S(4)
    secH := S(14)

    LinkGUI.dragBottom := LinkGUI.AddText("xm w" bw " h" S(6) " +0x200 Background555555", "")

    LinkGUI._allCtrls := []
    LinkGUI._buttonItems := Map()
    _allC := LinkGUI._allCtrls
    _ctlIdx := 0
    _pushCtl(ctl) {
        _ctlIdx++
        _allC.Push(ctl)
        return ctl
    }

    curSection := 0
    sectionOrder := []
    sectionHeaders := Map()
    sectionControls := Map()
    sectionHasEnabled := Map()
    inHdr := false

    LinkGUI.SetFont("s" S(9) " Bold cFFFFFF", "Segoe UI")
    for idx, item in LinkItems {
        t := item.Get("type","")
        if t = "disabled" && !item.Get("system", false)
            continue
        req := item.Get("requirement","")
        reqEnabled := req = "" || PieRequirementEnabled(req)
        if t = "sep" {
            curSection++
            sectionHasEnabled[curSection] := false
            if hMode {
                sectionControls[curSection] := []
                continue
            }
            lbl := item.Get("label","")
            hdr := LinkGUI.AddText("xm y+" S(8) " w" bw " h" secH " Center +0x200 Background" LinkGUI.BackColor " cAAAAAA", " " lbl " ")
            hdr.SetFont("s" S(6) " cAAAAAA", "Segoe UI")
            hdr.OnEvent("Click", LinkToggleSection.Bind(curSection))
            sectionOrder.Push(curSection)
            sectionHeaders[curSection] := hdr
            sectionControls[curSection] := []
            _pushCtl(hdr)
            inHdr := false
            continue
        }
        if !reqEnabled
            continue

        c := item.Get("color","455A64")
        lbl := item.Get("label","")
        hov := item.Get("hover", lbl)
        icon := IconUse(item.Get("icon",""), "?")
        btnText := icon != "" ? icon : lbl
        pos := hMode && _allC.Length ? "x+" gap " yp" : "xm y+" S(4)
        btn := LinkGUI.AddText(pos " w" bw " h" bh " Center +0x200 Background" c " c" ContrastColor(c), btnText)

        iconSize := item.Get("iconSize", 10)
        btn.SetFont("s" S(iconSize) (item.Get("iconBold", true) ? " Bold" : ""), "Segoe UI Emoji")
        if hov != ""
            AddHoverPopup(btn, hov)

        if t = "system" {
            fn := item.Get("fn","")
            if fn = "ToggleMainWindow"
                btn.OnEvent("Click", (*) => ToggleMainWindow())
            else if fn = "ShowCSPGuide"
                btn.OnEvent("Click", (*) => ShowCSPGuide())
        } else if t = "shortcut" || t = "action" || t = "function" || t = "url" || t = "script" {
            btn.OnEvent("Click", LinkRunItemAction.Bind(item, btn))
            LinkGUI._buttonItems[btn.Hwnd] := item
        }
        sectionHasEnabled[curSection] := true

        if sectionControls.Has(curSection) && t != "system"
            sectionControls[curSection].Push(btn)
        _pushCtl(btn)
        inHdr := false
    }

    for idx, hdr in sectionHeaders {
        if !sectionHasEnabled.Get(idx, false)
            hdr.Visible := false
    }

    LinkGUI.SetFont("s" S(9) " Bold cFFFFFF", "Segoe UI")

    ; ---- store layout data ----
    LinkGUI._sectionControls := sectionControls
    LinkGUI._sectionHeaders := sectionHeaders
    LinkGUI._sectionOrder := sectionOrder
    LinkGUI._sectionHasEnabled := sectionHasEnabled
    origY := Map()
    for ctl in _allC {
        ctl.GetPos(&cx, &cy, &cw, &ch)
        origY[ctl] := [cy, ch]
    }
    LinkGUI._origY := origY
    for secIdx, controls in sectionControls {
        collapsed := _linkCollapsed.Get(secIdx, false)
        for ctl in controls
            ctl.Visible := !collapsed
    }

    LinkGUI.OnEvent("ContextMenu", LinkGUI_ContextMenu)
    LinkGUI._ready := true
    if hMode
        LinkApplyHorizontalLayout()
    else
        LinkApplySectionLayout()
}

LinkApplyHorizontalLayout() {
    global LinkGUI
    if !IsObject(LinkGUI)
        return
    try if !LinkGUI._ready
        return
    allCtrls := LinkGUI._allCtrls
    if !IsObject(allCtrls) || allCtrls.Length = 0
        return

    rightEdge := 0
    bottomEdge := 0
    for ctl in allCtrls {
        ctl.Visible := true
        ctl.GetPos(&cx, &cy, &cw, &ch)
        rightEdge := Max(rightEdge, cx + cw)
        bottomEdge := Max(bottomEdge, cy + ch)
    }

    if rightEdge > 0 && bottomEdge > 0
        LinkGUI.Move(,, rightEdge + S(8), bottomEdge + S(8))
}

LinkToggleSection(secIdx, *) {
    global _linkCollapsed
    _linkCollapsed[secIdx] := !_linkCollapsed.Get(secIdx, false)
    LinkApplySectionLayout()
    DebugLog("Toggled section " secIdx " " (_linkCollapsed[secIdx] ? "collapsed" : "expanded"))
}

LinkApplySectionLayout() {
    global LinkGUI, _linkCollapsed
    if !IsObject(LinkGUI)
        return
    try if !LinkGUI._ready
        return

    allCtrls := LinkGUI._allCtrls
    if !IsObject(allCtrls) || allCtrls.Length = 0
        return

    try
        origY := LinkGUI._origY
    catch
        return
    sectionControls := LinkGUI._sectionControls
    sectionHeaders := LinkGUI._sectionHeaders
    sectionOrder := LinkGUI._sectionOrder
    sectionHasEnabled := LinkGUI._sectionHasEnabled

    for ctl in allCtrls {
        ctl.Visible := true
        ctl.Move(, origY[ctl][1])
    }

    for _, secIdx in sectionOrder {
        hdr := sectionHeaders.Get(secIdx, 0)

        emptySection := !sectionHasEnabled.Get(secIdx, false)
        if emptySection && IsObject(hdr)
            hdr.Visible := false

        collapsed := _linkCollapsed.Get(secIdx, false)
        if collapsed {
            ctrls := sectionControls.Get(secIdx, [])
            for ctl in ctrls
                ctl.Visible := false
        }
    }

    nextY := ""
    gap := S(4)
    for ctl in allCtrls {
        if !ctl.Visible
            continue
        ctl.GetPos(&cx, &cy, &cw, &ch)
        if nextY = ""
            nextY := origY[ctl][1]
        ctl.Move(, nextY)
        nextY += ch + gap
    }

    visibleBottom := 0
    Loop allCtrls.Length {
        idx := allCtrls.Length - A_Index + 1
        ctl := allCtrls[idx]
        if ctl.Visible {
            ctl.GetPos(,, &_cw, &_ch)
            ctl.GetPos(&_cx, &_cy)
            visibleBottom := _cy + _ch
            break
        }
    }
    if visibleBottom > 0 {
        LinkGUI.GetPos(&gx, &gy, &gw, &gh)
        LinkGUI.Move(,, gw, visibleBottom + S(8))
    }
}

LinkRefreshLayout(*) {
    global LinkLayout
    if LinkLayout = "H"
        LinkApplyHorizontalLayout()
    else
        LinkApplySectionLayout()
}

LinkGUI_ContextMenu(guiObj, ctrl, item, isRightClick, x, y) {
    global LinkGUIVisible, LinkManualHide
    if ctrl = guiObj.dragBottom
        return
    m := Menu()
    try {
        if IsObject(ctrl) && guiObj.HasProp("_buttonItems") && guiObj._buttonItems.Has(ctrl.Hwnd) {
            btnItem := guiObj._buttonItems[ctrl.Hwnd]
            m.Add("Test Action A", LinkTestItemAction.Bind(btnItem, "A"))
            try toggleVal := Integer(btnItem.Get("toggle", 0))
            catch
                toggleVal := 0
            if toggleVal
                m.Add("Test Action B", LinkTestItemAction.Bind(btnItem, "B"))
            m.Add()
        }
    }
    m.Add("Toggle Layout", ToggleLinkLayout)
    m.Add("Hide Link GUI", (*) => (LinkGUI.Hide(), LinkGUIVisible := false, LinkManualHide := true,
        GuiHasCtrl(MainGUI, "btnLink") ? MainGUI.btnLink.Opt("BackgroundE53935 cFFFFFF") : "",
        DebugLog("Link hidden via context menu")))
    m.Add("Opacity...", ShowOpacitySlider.Bind("Link"))
    m.Add("Debug Log", ShowDebugGUI)
    m.Show()
}

ToggleLinkLayout(*) {
    global LinkLayout, LinkGUI, LinkGUIVisible, LinkGUI_X, LinkGUI_Y
    wasVisible := LinkGUIVisible || IsGuiVisibleSafe(LinkGUI)
    if IsObject(LinkGUI)
        LinkGUI.GetPos(&LinkGUI_X, &LinkGUI_Y)
    LinkLayout := LinkLayout = "V" ? "H" : "V"
    DebugLog("Link Layout " (LinkLayout = "V" ? "H -> V" : "V -> H"))
    try IniWrite(LinkLayout, SETTINGS_FILE, "Link", "Layout")
    if IsObject(LinkGUI)
        LinkGUI.Destroy()
    CreateLinkGUI()
    if wasVisible {
        LinkGUIVisible := true
        try LinkGUI.Show("x" LinkGUI_X " y" LinkGUI_Y " NoActivate")
        LinkRefreshLayout()
    }
}

LinkActionClick(keys, lbl, color, extra, *) {
    global ReqNastarEnabled
    if !ReqNastarEnabled
        return ShowNotify("Requirement disabled", REQ_NASTAR, "0xE53935")
    SendColor(PieQuickNormalizeShortcutAction(keys), lbl, "", color)
    if extra != ""
        HotkeySendCSP(PieQuickNormalizeShortcutAction(extra))
}

LinkRunItemAction(item, ctrl := "", *) {
    if !IsObject(item)
        return
    t := item.Get("type", "")
    useB := ToggleItemShouldUseSecond(item, t)
    LinkRunItemActionSlot(item, useB)
    try {
        if ctrl != "" && Integer(item.Get("toggle", 0)) {
            nextUseB := !!Integer(item.Get("_toggleState", 0))
            iconCur := IconUse(item.Get(nextUseB ? "icon2" : "icon", ""))
            ctrl.Text := iconCur != "" ? iconCur : item.Get("label", "")
            bgCur := item.Get(nextUseB ? "color2" : "color", item.Get("color","455A64"))
            if bgCur = ""
                bgCur := item.Get("color","455A64")
            ctrl.Opt("Background" PieSafeColor(bgCur))
            ctrl.Redraw()
        }
    }
}

LinkTestItemAction(item, actionSlot := "A", *) {
    if !IsObject(item)
        return
    t := item.Get("type", "")
    useB := StrUpper(actionSlot) = "B"
    if useB {
        key2 := t = "function" ? "action2" : (t = "url" || t = "script") ? "target2" : "keys2"
        if Trim(item.Get(key2, "")) = ""
            return ShowNotify("Action Tester", "Action B is empty", "0xE53935")
    }
    LinkRunItemActionSlot(item, useB)
}

LinkRunItemActionSlot(item, useB := false) {
    t := item.Get("type", "")
    if t = "shortcut" || t = "action" {
        keys := item.Get(useB ? "keys2" : "keys", "")
        if keys = ""
            return
        sendColor := item.Get(useB ? "color2" : "color", item.Get("color","455A64"))
        if sendColor = ""
            sendColor := item.Get("color","455A64")
        LinkActionClick(keys, item.Get("label", ""), "0x" PieSafeColor(sendColor), item.Get(useB ? "extra2" : "extra", ""))
    } else if t = "function" {
        fn := item.Get(useB ? "action2" : "action", "")
        if fn != ""
            _LinkFuncClick(fn, item.Get("hover", ""))
    } else if t = "url" || t = "script" {
        targetKey := useB ? "target2" : "target"
        LinkRunItemTargetByKey(item, targetKey)
    }
}

LinkRunItemTargetByKey(item, targetKey, *) {
    if !IsObject(item)
        return
    target := Trim(item.Get(targetKey, ""))
    if target = "" && targetKey = "target"
        target := LinkPromptForTarget(item)
    if target = ""
        return
    try Run(target)
    catch as e
        ShowNotify("Link", "Failed to open: " e.Message, "0xE53935")
}

_LinkFuncClick(fn, hover, *) {
    global ReqNastarEnabled
    fn := Trim(fn)
    if fn = "ToggleLinkLayout" {
        ToggleLinkLayout()
        return
    }
    if !ReqNastarEnabled
        return ShowNotify("Requirement disabled", REQ_NASTAR, "0xE53935")
    ToolkitRunFunction(fn, hover != "" ? hover : "Link Launcher")
}

LinkPromptForTarget(item) {
    global LinkItems
    t := item.Get("type", "url")
    label := item.Get("hover", item.Get("label", "Link"))
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Add Link / Path")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)
    dlg.SetFont("s" S(10) " Bold cFFFFFF", "Segoe UI")
    dlg.AddText("xm", label)
    dlg.SetFont("s" S(9) " Norm cAAAAAA", "Segoe UI")
    dlg.AddText("xm y+" S(6) " w" S(300), t = "script" ? "This script button has no path yet. Add the .ahk/.exe path first." : "This link button has no URL yet. Add the URL first.")
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.AddText("xm y+" S(10), t = "script" ? "Path:" : "URL:")
    ed := dlg.AddEdit("xm y+" S(4) " w" S(300) " c000000 BackgroundFFFFFF", "")
    if t = "script"
        browseBtn := dlg.AddButton("x+" S(6) " yp-1 w" S(52) " h" S(24), "Browse")
    result := ""
    saveBtn := dlg.AddButton("xm y+" S(12) " w" S(92) " h" S(26) " Default", "Save")
    openBtn := dlg.AddButton("x+" S(8) " yp w" S(92) " h" S(26), "Save+Open")
    dlg.AddButton("x+" S(8) " yp w" S(92) " h" S(26), "Cancel").OnEvent("Click", (*) => dlg.Destroy())

    if t = "script" {
        browseBtn.OnEvent("Click", (*) => (
            f := FileSelect(3,, "Select script", "Scripts (*.ahk; *.exe)"),
            f != "" ? ed.Value := f : ""
        ))
    }
    saveTarget(openAfter := false) {
        val := Trim(ed.Value)
        if val = ""
            return ShowNotify("Link", t = "script" ? "Please add a path first." : "Please add a URL first.", "0xE53935")
        item["target"] := val
        SaveLinkItems()
        RebuildLinkGUI()
        result := openAfter ? val : ""
        dlg.Destroy()
        ShowNotify("Link", "Saved " label)
    }
    saveBtn.OnEvent("Click", (*) => saveTarget(false))
    openBtn.OnEvent("Click", (*) => saveTarget(true))
    dlg.Show("AutoSize")
    ed.Focus()
    GuiWaitForCloseSafe(dlg)
    return result
}

_RebuildLinkGui() {
    global LinkGUI, LinkGUIVisible, LinkGUI_X, LinkGUI_Y
    wasVisible := LinkGUIVisible
    try if LinkGUI.Hwnd {
        LinkGUI.GetPos(&LinkGUI_X, &LinkGUI_Y)
        LinkGUI.Destroy()
    }
    CreateLinkGUI()
    if wasVisible {
        LinkGUIVisible := true
        LinkGUI.Show("x" LinkGUI_X " y" LinkGUI_Y " NoActivate")
        LinkRefreshLayout()
    }
}

; ============================================================
