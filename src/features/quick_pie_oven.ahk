;FEATURES - Quick Pie Utilities
; ============================================================

PieQuickSlotKey(item) {
    global PieQuickHotkeys, _pieActiveIndex
    if !IsObject(PieQuickHotkeys) || !IsObject(item)
        return ""
    action := Trim(item.Get("action", ""))
    type := StrLower(Trim(item.Get("type", "disabled")))
    if action = "" || type = "disabled" || type = "nav"
        return ""
    for _, raw in PieQuickHotkeys {
        q := PieQuickSanitizeItem(raw)
        if !q.Get("enabled", 1)
            continue
        if !PieQuickScopeMatches(q.Get("scope", "all"))
            continue
        if StrLower(Trim(q.Get("type", ""))) != type
            continue
        if Trim(q.Get("action", "")) != action
            continue
        key := PieQuickNormalizeKey(q.Get("key", ""))
        if key = "" || key = "-" || PieQuickIsReservedKey(key)
            continue
        return HK_DisplayKey(key)
    }
    return ""
}

PieRenderSlotQuickKey(guiObj, item, x, y, slotW, slotH, compact) {
    global _pieAllCtrls
    key := PieQuickSlotKey(item)
    if key = ""
        return
    kw := Max(PieS(20), slotW - PieS(6))
    kh := PieS(14)
    kx := x + PieS(1)
    ky := y + slotH - kh - PieS(1)
    guiObj.SetFont("s" PieS(6) " Bold", "Segoe UI")
    ctrl := guiObj.AddText("x" kx " y" ky " w" kw " h" kh " Center +0x200 BackgroundFFD54F c202020", key)
    _pieAllCtrls.Push(ctrl)
}

PieQuickSlotPosChanged(ddl, *) {
    global _pieQuickSlotHintsPos
    _pieQuickSlotHintsPos := PieQuickSlotPosNorm(ddl.Text)
}

PieQuickSlotPosIndex(pos) {
    static list := ["top-left", "top-center", "top-right", "bottom-left", "bottom-center", "bottom-right"]
    for i, v in list {
        if v = pos
            return i
    }
    return 5
}

PieQuickSlotPosNorm(text) {
    static list := Map(
        "Top-Left", "top-left", "Top-Center", "top-center", "Top-Right", "top-right",
        "Bottom-Left", "bottom-left", "Bottom-Center", "bottom-center", "Bottom-Right", "bottom-right"
    )
    return list.Has(text) ? list[text] : "bottom-center"
}
