; GUI - Color Palette
; ============================================================

global ColorItems := []

; Maps color palette action function names → hotkey IDs for live keyLabel resolution.
_ColorActionToHotkeyId := Map(
    "HotkeyPaintRedLine", "paint_red",
    "HotkeyPaintGreenLine", "paint_green",
    "HotkeyPaintBlueLine", "paint_blue",
    "HotkeyPaintTransparent", "paint_transparent",
    "HotkeyPaintPinkLine", "paint_pink",
    "HotkeyPaintCyanLine", "paint_cyan",
    "HotkeyPaintOrangeLine", "paint_orange",
    "HotkeyPaintPurpleLine", "paint_purple",
    "HotkeySetCelsToTrack", "set_cels_to_track",
    "HotkeySetToPaintAnimation", "set_to_paint_anim",
    "HotkeyPaintCheckerLayer", "paint_checker_single",
    "HotkeyPaintCheckerImage", "paint_checker_image",
    "HotkeyIsolateLayer", "isolate_layer",
    "HotkeyOpenFolder", "group_folder",
    "HotkeyCloseAllFolder", "ungroup_folder"
)

_ResolveColorKeyLabel(item) {
    t := item.Get("type", "")
    if t = "shortcut" {
        keys := item.Get("keys", "")
        return keys != "" ? HotkeyDisplayName(keys) : ""
    }
    if t != "function"
        return item.Get("keyLabel", "")
    action := item.Get("action", "")
    if !_ColorActionToHotkeyId.Has(action)
        return item.Get("keyLabel", "")
    hid := _ColorActionToHotkeyId[action]
    key := HK_Get(hid, "")
    if key = "" || key = "-"
        return ""
    return HotkeyDisplayName(key)
}

ColorItemsRefreshKeyLabels() {
    global ColorItems
    for item in ColorItems {
        if item.Has("action") && item["action"] = "HotkeyToggleDraft"
            continue
        if item.Has("action") && item["action"] = "HotkeyVectorPaths"
            continue
        if item.Has("action") && item["action"] = "ShowColorHistory"
            continue
        if item.Has("action") && item["action"] = "ToggleColorLayout"
            continue
        newLabel := _ResolveColorKeyLabel(item)
        if newLabel != ""
            item["keyLabel"] := newLabel
    }
}

ColorItemsDefaults() {
    items := []
    items.Push(Map("type","sep","label","- RGBA -","color","2A2A2A"))
    items.Push(Map("type","function","label","R","hover","Paint Red Line","note","Fill red line 255.0.0 with primary color.","color","BF0000","action","HotkeyPaintRedLine","colorName","Paint Red Line","keyLabel","Shift+Ctrl+Alt+C","colorDefault","0xBF0000","requirement",REQ_NASTAR))
    items.Push(Map("type","function","label","G","hover","Paint Green Line","note","Fill green line 0.255.0 with primary color.","color","2E7D32","action","HotkeyPaintGreenLine","colorName","Paint Green Line","keyLabel","Shift+Ctrl+Alt+V","colorDefault","0x5CD377","requirement",REQ_NASTAR))
    items.Push(Map("type","function","label","B","hover","Paint Blue Line","note","Fill blue line 0.0.255 with primary color.","color","1565C0","action","HotkeyPaintBlueLine","colorName","Paint Blue Line","keyLabel","Shift+Ctrl+Alt+B","colorDefault","0x487AE3","requirement",REQ_NASTAR))
    items.Push(Map("type","function","label","A","hover","Paint Alpha/Transparent","note","Fill transparent and white 255.255.255 with primary color.","color","333333","action","HotkeyPaintTransparent","colorName","Paint Alpha/Transparent","keyLabel","Shift+Ctrl+Alt+F","colorDefault","0x333333","requirement",REQ_NASTAR))
    items.Push(Map("type","sep","label","- Colors -","color","2A2A2A"))
    items.Push(Map("type","function","label","P","hover","Paint Pink Line","note","Fill pink line 255.0.255 with primary color.","color","E53BEB","action","HotkeyPaintPinkLine","colorName","Paint Pink Line","keyLabel","Shift+Ctrl+Alt+N","colorDefault","0xFF00FF","requirement",REQ_NASTAR))
    items.Push(Map("type","function","label","C","hover","Paint Cyan Line","note","Fill cyan line 0.255.255 with primary color.","color","00BCD4","action","HotkeyPaintCyanLine","colorName","Paint Cyan Line","keyLabel","Shift+Ctrl+Alt+M","colorDefault","0x00FFF0","requirement",REQ_NASTAR))
    items.Push(Map("type","function","label","O","hover","Paint Orange Line","note","Fill orange line 255.128.0 with primary color.","color","FF9800","action","HotkeyPaintOrangeLine","colorName","Paint Orange Line","keyLabel","Shift+Ctrl+Alt+,","colorDefault","0xFA9600","requirement",REQ_NASTAR))
    items.Push(Map("type","function","label","Pu","hover","Paint Purple Line","note","Fill purple line 128.0.255 with primary color.","color","9C27B0","action","HotkeyPaintPurpleLine","colorName","Paint Purple Line","keyLabel","Shift+Ctrl+Alt+.","colorDefault","0x9C27B0","requirement",REQ_NASTAR))
    items.Push(Map("type","sep","label","- Check -","color","2A2A2A"))
    items.Push(Map("type","function","label","Cels","hover","Set Cels to Track","note","Insert the layers to cels track in the timeline.","color","689F38","action","HotkeySetCelsToTrack","colorName","Set Cels to Track","keyLabel","Ctrl+Shift+Alt+PageUp","colorDefault","0x689F38","requirement",REQ_NASTAR))
    items.Push(Map("type","function","label","Set","hover","Set to Paint: Animation","note","Setup the layer folder for ready to paint.","color","689F38","action","HotkeySetToPaintAnimation","colorName","Set to Paint: Animation","keyLabel","Shift+Ctrl+Alt+Insert","colorDefault","0x689F38","requirement",REQ_NASTAR))
    items.Push(Map("type","function","label","Paint Check: Layer","icon","🔍","icon2","🗑","iconBold",false,"hover","Paint Check: Layer","note","Make one paint checker layer, then alternate to delete it.","color","689F38","color2","E53935","action","HotkeyPaintCheckerLayer","toggle",1,"action2","HotkeyDeletePaintChecker","colorName","Paint Check: Layer","keyLabel","A: Ctrl+Shift+Alt+End / B: Delete Paint Checker","colorDefault","0x689F38","requirement",REQ_NASTAR))
    items.Push(Map("type","function","label","Paint Checker: Image","icon","🖼","icon2","🗑","iconBold",false,"hover","Paint Checker: Image","note","Make paint checker image setup, then alternate to delete it.","color","558B2F","color2","E53935","action","HotkeyPaintCheckerImage","toggle",1,"action2","HotkeyDeletePaintChecker","colorName","Paint Checker: Image","keyLabel","A: Ctrl+Shift+Alt+Home / B: Delete Paint Checker","colorDefault","0x558B2F","requirement",REQ_NASTAR))
    items.Push(Map("type","sep","label","- Utils -","color","2A2A2A"))
    items.Push(Map("type","shortcut","label","Deselect","icon","⊘","iconBold",true,"hover","Deselect","note","Deselect the current selection.","color","777777","keys","^d","colorName","Deselect","keyLabel","CTRL+D","colorDefault","0x888888"))
    items.Push(Map("type","shortcut","label","Inverse Sel","icon","⇄","iconBold",true,"hover","Inverse Selection","note","Invert the current selection.","color","777777","keys","^+i","colorName","Inverse Selection","keyLabel","CTRL+Shift+I","colorDefault","0x888888"))
    items.Push(Map("type","function","label","Isolate","icon","◎","iconBold",true,"hover","Isolate Layer","note","Toggle layer view isolation.","color","777777","action","HotkeyIsolateLayer","colorName","Isolate Layer","keyLabel","Shift+Ctrl+Alt+Q","colorDefault","0x888888","requirement",REQ_NASTAR))
    items.Push(Map("type","function","label","Draft","icon","📄","iconBold",false,"hover","Toggle Draft Layers Visibility","note","Toggle the visibility of all draft layers.","color","777777","action","HotkeyToggleDraft","colorName","Toggle Draft Layers Visibility","keyLabel","Shift+Ctrl+Alt+'","colorDefault","0x888888","requirement",REQ_NASTAR))
    items.Push(Map("type","function","label","Vector Paths","icon","✒","iconBold",false,"hover","Vector Paths","note","Open vector path display controls.","color","777777","action","HotkeyVectorPaths"))
    items.Push(Map("type","function","label","Color History","icon","=","iconBold",false,"hover","Color History","note","Open the color history popup.","color","4527A0","action","ShowColorHistory"))
    items.Push(Map("type","sep","label","- Folders -","color","2A2A2A"))
    items.Push(Map("type","function","label","Open Folder","icon","📂","iconBold",false,"hover","Open Folder","note","Open the currently selected folder.","color","F9A825","action","HotkeyOpenFolder","colorName","Open Folder","keyLabel","Shift+Ctrl+Alt+=","colorDefault","0x888888","requirement",REQ_NASTAR))
    items.Push(Map("type","function","label","Close All","icon","📁","iconBold",false,"hover","Close All Folder","note","Close all opened folders in the file.","color","E65100","action","HotkeyCloseAllFolder","colorName","Close All Folder","keyLabel","Shift+Ctrl+Alt+-","colorDefault","0x888888","requirement",REQ_NASTAR))
    items.Push(Map("type","sep","label","---","color","2A2A2A"))
    items.Push(Map("type","function","label","Toggle Layout","icon","↕","iconBold",false,"hover","Toggle Horizontal/Vertical","note","Switch Color GUI between vertical and horizontal layout.","color","777777","action","ToggleColorLayout"))
    return items
}

LoadColorItems() {
    global ColorItems, COLOR_SETTINGS_FILE, SETTINGS_FILE, SETTINGS_DIR
    if ColorItems.Length = 0 {
        ColorItems := ColorItemsDefaults()
        ExportIconRef()
    }
    src := COLOR_SETTINGS_FILE
    migrated := false
    if !FileExist(src) {
        ; First run of per-mode color storage. Prefer the base color file so a
        ; mode missing its own file starts from the current config (same as
        ; ModeSettingsCopyBaseTo); fall back to the legacy global gui_settings.ini
        ; so pre-upgrade installs lose nothing.
        try {
            base := SETTINGS_DIR "\color_settings.ini"
            if base != COLOR_SETTINGS_FILE && FileExist(base) && IniRead(base, "ColorItems", "count", 0) > 0 {
                src := base
                migrated := true
            } else if IniRead(SETTINGS_FILE, "ColorItems", "count", 0) > 0 {
                src := SETTINGS_FILE
                migrated := true
            }
        }
    }
    try {
        cnt := IniRead(src, "ColorItems", "count", 0)
        if cnt <= 0 {
            ; An existing per-mode color file with zero items means the list was
            ; emptied by the user; drop stale items carried over from the
            ; previous mode instead of leaking them into this mode.
            if FileExist(COLOR_SETTINGS_FILE)
                ColorItems := []
            return
        }
        loaded := []
        loop cnt {
            i := A_Index
            t := IniRead(src, "ColorItems", i "_type", "")
            if t = ""
                continue
            m := Map("type", t)
        for key in ["label","hover","color","color2","keys","extra","action","target","icon","icon2","iconBold","fontSize","colorName","keyLabel","colorDefault","note","requirement","_origType","toggle","keys2","extra2","action2","target2","enabled"] {
                v := IniRead(src, "ColorItems", i "_" key, "")
                if v != "" {
                    if key = "icon" || key = "icon2"
                        v := IconDec(v)
                    m[key] := v
                }
            }
            en := IniRead(src, "ColorItems", i "_enabled", "")
            if en = "0" && m.Get("type","") != "disabled" {
                m["_origType"] := m.Get("type","shortcut")
                m["type"] := "disabled"
            }
            loaded.Push(m)
        }
        if loaded.Length > 0
            ColorItems := loaded
        if migrated
            SaveColorItems()
        if RepairColorItemFunctions()
            SaveColorItems()
        if RepairColorItemIcons()
            SaveColorItems()
        if DedupeColorItems()
            SaveColorItems()
        ColorItemsRefreshKeyLabels()
    } catch as err {
        DebugLog("LoadColorItems error: " err.Message)
        SettingsDiagPush("ERR", "Color items load failed", err.Message)
    }
}

RepairColorItemFunctions() {
    global ColorItems
    defaults := ColorItemsDefaults()
    lookup := Map()
    for _, def in defaults {
        if StrLower(Trim(def.Get("type", ""))) != "function"
            continue
        key := ColorItemLabelHoverKey(def)
        if key != ""
            lookup[key] := def
    }

    changed := false
    for _, item in ColorItems {
        key := ColorItemLabelHoverKey(item)
        if key = "" || !lookup.Has(key)
            continue
        def := lookup[key]
        wantedAction := Trim(def.Get("action", ""))
        if wantedAction = ""
            continue
        currentType := StrLower(Trim(item.Get("type", "")))
        currentOrig := StrLower(Trim(item.Get("_origType", "")))
        if currentType = "disabled" {
            if currentOrig != "function" {
                item["_origType"] := "function"
                changed := true
            }
        } else if currentType != "function" {
            item["type"] := "function"
            changed := true
        }
        if Trim(item.Get("action", "")) != wantedAction {
            item["action"] := wantedAction
            changed := true
        }
        if item.Has("keys") {
            item.Delete("keys")
            changed := true
        }
        if item.Has("extra") {
            item.Delete("extra")
            changed := true
        }
        for _, keyName in ["note","colorName","keyLabel","colorDefault","requirement"] {
            if def.Has(keyName) && item.Get(keyName, "") != def.Get(keyName, "") {
                item[keyName] := def.Get(keyName, "")
                changed := true
            }
        }
    }
    return changed
}

ColorItemLabelHoverKey(item) {
    label := StrLower(Trim(item.Get("label", "")))
    hover := StrLower(Trim(item.Get("hover", "")))
    if label = "" && hover = ""
        return ""
    return label "|" hover
}

RepairColorItemIcons() {
    global ColorItems
    current := ColorItems
    defaults := ColorItemsDefaults()
    lookup := Map()
    for _, def in defaults {
        key := ColorItemStableKey(def)
        if key != "" && def.Has("icon")
            lookup[key] := def
    }

    changed := false
    fallbackIcons := Map("?", true, "?A", true, "?N", true, "??", true, "⏱", true, "◆", true, "▶", true, "▤", true, "⊞", true, "◎", true)
    for _, item in current {
        key := ColorItemStableKey(item)
        if !lookup.Has(key)
            continue
        def := lookup[key]
        icon := Trim(item.Get("icon", ""))
        defIcon := Trim(def.Get("icon", ""))
        if icon != "" && icon = defIcon
            continue
        if icon != "" && !fallbackIcons.Has(icon) && SubStr(icon, 1, 2) != "??"
            continue
        item["icon"] := defIcon
        if def.Has("icon2")
            item["icon2"] := def.Get("icon2", "")
        if def.Has("iconBold")
            item["iconBold"] := def.Get("iconBold", false)
        if def.Has("fontSize")
            item["fontSize"] := def.Get("fontSize", 9)
        else if item.Has("fontSize")
            item.Delete("fontSize")
        changed := true
    }
    return changed
}

DedupeColorItems() {
    global ColorItems
    seen := Map()
    defaultKeys := Map()
    for _, def in ColorItemsDefaults() {
        defKey := ColorItemStableKey(def)
        if defKey != ""
            defaultKeys[defKey] := true
    }
    cleaned := []
    changed := false
    for _, item in ColorItems {
        key := ColorItemStableKey(item)
        if key != "" && defaultKeys.Has(key) && seen.Has(key) {
            changed := true
            continue
        }
        if key != ""
            seen[key] := true
        cleaned.Push(item)
    }
    if changed
        ColorItems := cleaned
    return changed
}

ColorItemStableKey(item) {
    t := StrLower(Trim(item.Get("type", "")))
    if t = "disabled"
        t := StrLower(Trim(item.Get("_origType", "disabled")))
    label := StrLower(Trim(item.Get("label", "")))
    hover := StrLower(Trim(item.Get("hover", "")))
    action := StrLower(Trim(item.Get("action", "")))
    keys := StrLower(Trim(item.Get("keys", "")))
    target := StrLower(Trim(item.Get("target", "")))
    if t = "sep"
        return "sep|" label
    if action != ""
        return "action|" action
    if keys != ""
        return "keys|" keys "|" hover
    if target != ""
        return "target|" target
    if label != ""
        return t "|" label "|" hover
    return ""
}

SaveColorItems() {
    global ColorItems, COLOR_SETTINGS_FILE
    DedupeColorItems()
    try {
        IniDelete(COLOR_SETTINGS_FILE, "ColorItems")
        cnt := 0
        for idx, item in ColorItems {
            cnt++
            i := cnt
            IniWrite(item.Get("type",""), COLOR_SETTINGS_FILE, "ColorItems", i "_type")
            itemType := item.Get("type","")
            for key in ["label","hover","color","color2","keys","extra","action","target","icon","icon2","iconBold","fontSize","colorName","keyLabel","colorDefault","note","requirement","_origType","toggle","keys2","extra2","action2","target2"] {
                v := item.Get(key, "")
                if v != "" {
                    if (key = "keys" || key = "extra" || key = "keys2" || key = "extra2" || key = "action" || key = "action2") && (itemType = "shortcut" || itemType = "action")
                        v := PieQuickNormalizeShortcutAction(v)
                    if key = "icon" || key = "icon2"
                        v := IconEnc(IconSafe(v))
                    IniWrite(v, COLOR_SETTINGS_FILE, "ColorItems", i "_" key)
                }
            }
        }
        if cnt > 0
            IniWrite(cnt, COLOR_SETTINGS_FILE, "ColorItems", "count")
        try SettingsSyncIniWatcher()
    }
}

ColorItemDialog(existing, applyCallback := 0) {
    if !IsObject(existing) || !existing.Has("type")
        existing := Map("type","shortcut","label","","hover","","color","455A64","color2","","icon","","icon2","","iconBold",true,"note","","keys","","extra","","action","","target","","toggle",0,"keys2","","extra2","","action2","","target2","")
    isNew := existing.Get("type","") = ""
    rawType := existing.Get("type","shortcut")
    if rawType = "action"
        rawType := "shortcut"

    dlg := Gui("+AlwaysOnTop +ToolWindow", isNew ? "Add Color Item" : "Edit Color Item")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(12)
    dlg.MarginY := S(12)
    px := S(105), ew := S(260), displayW := S(190), smallBtnW := S(60)
    Header(title) {
        hdrText := dlg.AddText("xm y+" S(8) " cFFD54F", title)
        hdrLine := dlg.AddText("xm y+" S(2) " w" S(355) " h1 Background444444", "")
        return [hdrText, hdrLine]
    }

    commonHdr := Header("Common data")
    dlg.AddText("xm", "Type:")
    ddl := dlg.AddDropDownList("x" px " yp w" ew, ["shortcut","function","url","script","sep","disabled"])
    ddl.Value := rawType = "shortcut" ? 1 : rawType = "function" ? 2 : rawType = "url" ? 3 : rawType = "script" ? 4 : rawType = "sep" ? 5 : 6
    ddl.OnEvent("Change", (*) => ColorItemDlg_ToggleType())

    dlg.AddText("xm y+" S(4), "Color (hex):")
    colorEd := dlg.AddEdit("x" px " yp w" S(86) " c000000", PieSafeColor(existing.Get("color","455A64")))
    c0 := dlg.AddText("x+" S(4) " yp w" S(22) " h" S(22) " +0x200 Background" PieSafeColor(existing.Get("color","455A64")), "")
    dlg.AddText("x+" S(4) " yp w" S(18) " h" S(22) " +0x200 BackgroundE53935 cFFFFFF Center", "R").OnEvent("Click", (*) => (colorEd.Value := "E53935", ColorItemDlg_UpdateSwatch(), colorEd.Focus()))
    dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background0F9D58 cFFFFFF Center", "G").OnEvent("Click", (*) => (colorEd.Value := "0F9D58", ColorItemDlg_UpdateSwatch(), colorEd.Focus()))
    dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background4285F4 cFFFFFF Center", "B").OnEvent("Click", (*) => (colorEd.Value := "4285F4", ColorItemDlg_UpdateSwatch(), colorEd.Focus()))
    dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 BackgroundE39A2D cFFFFFF Center", "O").OnEvent("Click", (*) => (colorEd.Value := "E39A2D", ColorItemDlg_UpdateSwatch(), colorEd.Focus()))
    dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background9C27B0 cFFFFFF Center", "V").OnEvent("Click", (*) => (colorEd.Value := "9C27B0", ColorItemDlg_UpdateSwatch(), colorEd.Focus()))
    dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background00BCD4 cFFFFFF Center", "C").OnEvent("Click", (*) => (colorEd.Value := "00BCD4", ColorItemDlg_UpdateSwatch(), colorEd.Focus()))
    dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background607D8B cFFFFFF Center", "Gr").OnEvent("Click", (*) => (colorEd.Value := "607D8B", ColorItemDlg_UpdateSwatch(), colorEd.Focus()))

    lblLbl := dlg.AddText("xm y+" S(4), "Label:")
    lblEd := dlg.AddEdit("x" px " yp w" ew " c000000", existing.Get("label",""))

    hovLbl := dlg.AddText("xm y+" S(4), "Hover text:")
    hovEd := dlg.AddEdit("x" px " yp w" ew " c000000", existing.Get("hover",""))

    noteLbl := dlg.AddText("xm y+" S(4), "Note:")
    noteEd := dlg.AddEdit("x" px " yp w" ew " c000000", existing.Get("note",""))

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
    iconEd := dlg.AddEdit("x" px " y+4 w" ew " c000000", existing.Get("icon",""))
    typeHdr := Header("Type data")
    typeHelp := dlg.AddText("xm y+" S(2) " w" S(355) " cFFFFFF -Border", "Shortcut: keystrokes to send")
    actionLbl := dlg.AddText("xm y+" S(6), "Action:")
    actionValue := rawType = "function" ? existing.Get("action","")
        : (rawType = "url" || rawType = "script") ? existing.Get("target","")
        : existing.Get("keys","")
    actionEd := dlg.AddEdit("x" px " yp w" ew " c000000 BackgroundFFFFFF", actionValue)
    actionDisplay := dlg.AddText("x" px " y+" S(4) " w" (displayW+5) " h" S(24) " +0x200 Center cFFFFFF Background2D2D32", actionValue != "" ? actionValue : "...")
    actionRecBtn := dlg.AddButton("x+4 yp w" smallBtnW " h" S(24), "Rec")
    fnPick := dlg.AddButton("x" px " y+" S(4) " w" smallBtnW " h" S(24), "Pick")
    browseBtn := dlg.AddButton("x+4 yp w" smallBtnW " h" S(24), "...")
    actExtraL := dlg.AddText("xm y+" S(6), "Extra:")
    actExtra := dlg.AddEdit("x" px " yp w" ew " c000000 BackgroundFFFFFF", existing.Get("extra",""))

    actionBHdr := Header("Action B data")
    icon2Lbl := dlg.AddText("xm y+" S(4), "B icon:")
    icon2CustomCb := dlg.AddCheckbox("x" px " yp cFFFFFF", "Custom text")
    icon2CustomCb.Value := !LinkIconPresetIndex(existing.Get("icon2",""), iconPresets)
    icon2Dd := dlg.AddDropDownList("x" px " y+" S(4) " w" ew, iconPresets)
    preset2Idx := LinkIconPresetIndex(existing.Get("icon2",""), iconPresets)
    icon2Dd.Value := preset2Idx ? preset2Idx : 1
    icon2Ed := dlg.AddEdit("x" px " y+4 w" ew " c000000", existing.Get("icon2",""))
    iconCustomCb.OnEvent("Click", (*) => ColorItemDlg_ToggleIconMode())
    icon2CustomCb.OnEvent("Click", (*) => ColorItemDlg_ToggleIconMode())
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
    bColorBtns[1].OnEvent("Click", (*) => (color2Ed.Value := "E53935", ColorItemDlg_UpdateSwatch2(), color2Ed.Focus()))
    bColorBtns.Push(dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background0F9D58 cFFFFFF Center", "G"))
    bColorBtns[2].OnEvent("Click", (*) => (color2Ed.Value := "0F9D58", ColorItemDlg_UpdateSwatch2(), color2Ed.Focus()))
    bColorBtns.Push(dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background4285F4 cFFFFFF Center", "B"))
    bColorBtns[3].OnEvent("Click", (*) => (color2Ed.Value := "4285F4", ColorItemDlg_UpdateSwatch2(), color2Ed.Focus()))
    bColorBtns.Push(dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 BackgroundE39A2D cFFFFFF Center", "O"))
    bColorBtns[4].OnEvent("Click", (*) => (color2Ed.Value := "E39A2D", ColorItemDlg_UpdateSwatch2(), color2Ed.Focus()))
    bColorBtns.Push(dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background9C27B0 cFFFFFF Center", "V"))
    bColorBtns[5].OnEvent("Click", (*) => (color2Ed.Value := "9C27B0", ColorItemDlg_UpdateSwatch2(), color2Ed.Focus()))
    bColorBtns.Push(dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background00BCD4 cFFFFFF Center", "C"))
    bColorBtns[6].OnEvent("Click", (*) => (color2Ed.Value := "00BCD4", ColorItemDlg_UpdateSwatch2(), color2Ed.Focus()))
    bColorBtns.Push(dlg.AddText("x+" S(2) " yp w" S(18) " h" S(22) " +0x200 Background607D8B cFFFFFF Center", "Gr"))
    bColorBtns[7].OnEvent("Click", (*) => (color2Ed.Value := "607D8B", ColorItemDlg_UpdateSwatch2(), color2Ed.Focus()))

    action2Lbl := dlg.AddText("xm y+" S(6), "Action B:")
    action2Value := rawType = "function" ? existing.Get("action2","")
        : (rawType = "url" || rawType = "script") ? existing.Get("target2","")
        : existing.Get("keys2","")
    action2Ed := dlg.AddEdit("x" px " yp w" ew " c000000 BackgroundFFFFFF", action2Value)
    action2Display := dlg.AddText("x" px " y+" S(4) " w" (displayW+5) " h" S(24) " +0x200 Center cFFFFFF Background2D2D32", action2Value != "" ? action2Value : "...")
    action2RecBtn := dlg.AddButton("x+4 yp w" smallBtnW " h" S(24), "Rec")
    fnPick2 := dlg.AddButton("x" px " y+" S(4) " w" smallBtnW " h" S(24), "Pick")
    browseBtn2 := dlg.AddButton("x+4 yp w" smallBtnW " h" S(24), "...")
    actExtra2L := dlg.AddText("xm y+" S(6), "Extra B:")
    actExtra2 := dlg.AddEdit("x" px " yp w" ew " c000000 BackgroundFFFFFF", existing.Get("extra2",""))

    dlg.AddText("xm y-2", "")
    okBtn := dlg.AddButton("xm w" S(80) " h" S(26) " cFFFFFF Default", "OK")
    if IsObject(applyCallback)
        dlg.AddButton("x+" S(8) " yp w" S(80) " h" S(26), "Apply").OnEvent("Click", (*) => (
            _result := ColorItemDlg_BuildResult(),
            result := _result,
            applyCallback(_result),
            ShowNotify("Color Item", "Applied")
        ))
    caBtn := dlg.AddButton("x+" S(10) " yp w" S(80) " h" S(26), "Cancel")
    dlg.AddButton("x+" S(12) " yp w" S(80) " h" S(26) " c9C27B0", "Keys Guide").OnEvent("Click", (*) => ShowKeysGuide())

    result := false

    ColorItemDlg_ToggleIconMode() {
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

    ColorItemDlg_ToggleType() {
        t := ddl.Text
        s := t = "shortcut"
        f := t = "function"
        u := t = "url"
        sc := t = "script"
        isSep := t = "sep"
        activeType := !(isSep || t = "disabled")
        hasLabel := t != "disabled"
        hasMetaText := activeType
        hasIconData := activeType
        lblLbl.Visible := hasLabel
        lblEd.Visible := hasLabel
        hovLbl.Visible := hasMetaText
        hovEd.Visible := hasMetaText
        noteLbl.Visible := hasMetaText
        noteEd.Visible := hasMetaText
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
        fnPick.Visible := activeType
        browseBtn.Visible := activeType
        actionDisplay.Visible := activeType
        actExtraL.Visible := s
        actExtra.Visible := s
        toggleCb.Visible := activeType
        action2Lbl.Visible := showToggle
        action2Ed.Visible := showToggle
        action2Display.Visible := showToggle
        action2RecBtn.Visible := showToggle
        fnPick2.Visible := showToggle
        browseBtn2.Visible := showToggle
        actExtra2L.Visible := showToggle && s
        actExtra2.Visible := showToggle && s
        actionLbl.Text := u ? "URL / Link:" : sc ? "Script path:" : "Action:"
        actionRecBtn.Enabled := s
        fnPick.Enabled := f
        browseBtn.Enabled := u || sc
        action2RecBtn.Enabled := s
        fnPick2.Enabled := f
        browseBtn2.Enabled := u || sc
        actionEd.Enabled := activeType
        action2Ed.Enabled := showToggle
        typeHelp.Text := s ? "Shortcut: keystrokes to send"
            : f ? "Function: AHK function name to call"
            : u ? "URL: web address to open"
            : sc ? "Script: .ahk/.exe path to run"
            : isSep ? "Separator: section header"
            : "Disabled: placeholder slot"
        dlg.Show("AutoSize")
    }

    ColorItemDlg_UpdateSwatch(*) {
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
    ColorItemDlg_UpdateSwatch2(*) {
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
    colorEd.OnEvent("Change", ColorItemDlg_UpdateSwatch)
    color2Ed.OnEvent("Change", ColorItemDlg_UpdateSwatch2)
    actionEd.OnEvent("Change", (*) => actionDisplay.Text := actionEd.Value != "" ? actionEd.Value : "...")
    action2Ed.OnEvent("Change", (*) => action2Display.Text := action2Ed.Value != "" ? action2Ed.Value : "...")
    toggleCb.OnEvent("Click", (*) => ColorItemDlg_ToggleType())

    actionRecBtn.OnEvent("Click", (*) => HK_CaptureKey(dlg, actionEd, actionDisplay, actionRecBtn))
    action2RecBtn.OnEvent("Click", (*) => HK_CaptureKey(dlg, action2Ed, action2Display, action2RecBtn))
    fnPick.OnEvent("Click", (*) => HK_FunctionPicker(actionEd))
    fnPick2.OnEvent("Click", (*) => HK_FunctionPicker(action2Ed))
    okBtn.OnEvent("Click", (*) => (result := ColorItemDlg_BuildResult(), dlg.Destroy()))
    browseBtn.OnEvent("Click", (*) => ColorItemDlg_Browse(actionEd))
    browseBtn2.OnEvent("Click", (*) => ColorItemDlg_Browse(action2Ed))

    ColorItemDlg_BuildResult() {
        iconValue := IconSafe(iconCustomCb.Value ? iconEd.Value : LinkIconFromPreset(iconDd.Text))
        icon2Value := IconSafe(icon2CustomCb.Value ? icon2Ed.Value : LinkIconFromPreset(icon2Dd.Text))
        t := ddl.Text
        isSep := t = "sep"
        built := Map(
            "type", t,
            "icon", iconValue,
            "iconBold", iconBoldCb.Value,
            "label", isSep ? lblEd.Value : iconValue,
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

    ColorItemDlg_Browse(targetEd := 0, *) {
        if !IsObject(targetEd)
            targetEd := actionEd
        if ddl.Text = "url" {
            urlDlg := Gui("+AlwaysOnTop +ToolWindow", "Item URL")
            urlDlg.BackColor := "1E1F22"
            urlDlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
            urlDlg.MarginX := S(12)
            urlDlg.MarginY := S(12)
            urlDlg.AddText("xm", "URL / Link:")
            urlEd2 := urlDlg.AddEdit("x" S(80) " yp w" S(340) " c000000 BackgroundFFFFFF", targetEd.Value)
            urlDlg.AddText("xm y+" S(4) " c888888", "Enter a URL, for example https://example.com")
            urlResult := ""
            urlDlg.AddButton("xm y+" S(12) " w" S(80) " h" S(26) " Default", "OK").OnEvent("Click", (*) => (urlResult := Trim(urlEd2.Value), urlDlg.Destroy()))
            urlDlg.AddButton("x+" S(8) " yp w" S(80) " h" S(26), "Cancel").OnEvent("Click", (*) => urlDlg.Destroy())
            urlDlg.Show("AutoSize")
            GuiWaitForCloseSafe(urlDlg)
            if urlResult != ""
                targetEd.Value := urlResult
            return
        }
        f := FileSelect(3,, "Select script", "Scripts (*.ahk; *.exe)")
        if f != ""
            targetEd.Value := f
    }

    ColorItemDlg_ToggleType()
    ColorItemDlg_ToggleIconMode()
    ColorItemDlg_UpdateSwatch()
    ColorItemDlg_UpdateSwatch2()
    actionDisplay.Text := actionEd.Value != "" ? actionEd.Value : "..."
    dlg.Show("w" S(410) " AutoSize")
    GuiWaitForCloseSafe(dlg)
    return result
}

CreateColorGui() => ToolScaleCall(CreateColorGui_Impl)

CreateColorGui_Impl() {
    global ColorGUI, ColorLayout, _colorCollapsed, ColorItems
    if IsObject(ColorGUI) {
        try if ColorGUI.Hwnd
            return
    }
    ColorGUI := Gui("+AlwaysOnTop -Caption +ToolWindow")
    ColorGUI.BackColor := "1E1E1E"
    ColorGUI.SetFont("s" S(7) " cFFFFFF", "Segoe UI")

    LoadColorItems()
    hMode := ColorLayout = "H"
    bw := S(25)
    bh := S(30)
    gap := S(4)
    secH := S(14)

    ColorGUI.dragBottom := ColorGUI.AddText("xm w" bw " h" S(6) " +0x200 Background555555", "")

    ; ---- layout state ----
    global _colorCollapsed
    if !IsObject(_colorCollapsed)
        _colorCollapsed := Map()
    ColorGUI._allCtrls := []
    ColorGUI._buttonItems := Map()
    _allC := ColorGUI._allCtrls
    _ctlIdx := 0
    _pushCtl(ctl) {
        _ctlIdx++
        _allC.Push(ctl)
        return ctl
    }

    ; ---- requirement alerts (visible only when requirement is off) ----
    if !PieRequirementEnabled(REQ_ANIM) {
        pos := hMode && _allC.Length ? "x+" gap " yp" : "xm y+" S(4)
        btn := ColorGUI.AddText(pos " w" bw " h" bh " Center +0x200 cWhite BackgroundFF6F00", "! A")
        btn.SetFont("s" S(8) " Bold", "Segoe UI")
        AddHoverPopup(btn, "Animation_autoaction.laf is disabled — click for help")
        _pushCtl(btn)
        btn.OnEvent("Click", _ShowReqAlert.Bind(REQ_ANIM))
    }
    if !PieRequirementEnabled(REQ_NASTAR) {
        pos := hMode && _allC.Length ? "x+" gap " yp" : "xm y+" S(4)
        btn := ColorGUI.AddText(pos " w" bw " h" bh " Center +0x200 cWhite BackgroundE65100", "! N")
        btn.SetFont("s" S(8) " Bold", "Segoe UI")
        AddHoverPopup(btn, "Nastar.laf is disabled — click for help")
        _pushCtl(btn)
        btn.OnEvent("Click", _ShowReqAlert.Bind(REQ_NASTAR))
    }

    ; ---- render items ----
    curSection := 0
    sectionOrder := []
    sectionHeaders := Map()
    sectionControls := Map()
    secBounds := Map()
    sectionHasEnabled := Map()
    inHdr := false

    ColorGUI.SetFont("s" S(9) " Bold cFFFFFF", "Segoe UI")
    for idx, item in ColorItems {
        t := item.Get("type","")
        if t = "disabled"
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
            hdr := ColorGUI.AddText("xm y+" S(8) " w" bw " h" secH " Center +0x200 Background" ColorGUI.BackColor " cAAAAAA", " " lbl " ")
            hdr.SetFont("s" S(6) " cAAAAAA", "Segoe UI")
            hdr.OnEvent("Click", ColorToggleSection.Bind(curSection))
            sectionOrder.Push(curSection)
            sectionHeaders[curSection] := hdr
            sectionControls[curSection] := []
            secBounds[curSection] := [_allC.Length + 1, _allC.Length + 1]
            _pushCtl(hdr)
            inHdr := false
            continue
        }
        if !reqEnabled
            continue
        c := item.Get("color","455A64")
        lbl := item.Get("label","")
        hov := item.Get("hover", lbl)
        icon := IconUse(item.Get("icon",""))
        btnText := icon != "" ? icon : lbl
        pos := hMode && _allC.Length ? "x+" gap " yp" : "xm y+" S(4)
        btn := ColorGUI.AddText(pos " w" bw " h" bh " Center +0x200 Background" c " c" ContrastColor(c), btnText)
        fontSize := item.Get("fontSize", icon != "" ? 10 : 9)
        btn.SetFont("s" S(fontSize) (item.Get("iconBold", true) ? " Bold" : ""), icon != "" ? "Segoe UI Emoji" : "Segoe UI")
        if hov != ""
            AddHoverPopup(btn, hov)

        if item.Get("label", "") = "Paint Check: Layer" || item.Get("action", "") = "HotkeyPaintCheckerLayer" {
            item["type"] := "function"
            item["action"] := "HotkeyPaintCheckerLayer"
            item["icon"] := "🔍"
            item["icon2"] := "🗑"
            item["color2"] := "E53935"
            item["toggle"] := 1
            item["action2"] := "HotkeyDeletePaintChecker"
            item["keyLabel"] := "A: Ctrl+Shift+Alt+End / B: Delete Paint Checker"
            t := "function"
            btn.Text := IconUse(item["icon"], item.Get("label", ""))
            btn.Opt("Background" PieSafeColor(item.Get("color", "689F38")))
            btn.SetFont("s" S(10) "", "Segoe UI Emoji")
        } else if item.Get("label", "") = "Paint Checker: Image" || item.Get("action", "") = "HotkeyPaintCheckerImage" {
            item["type"] := "function"
            item["action"] := "HotkeyPaintCheckerImage"
            item["icon"] := "🖼"
            item["icon2"] := "🗑"
            item["color"] := "558B2F"
            item["color2"] := "E53935"
            item["toggle"] := 1
            item["action2"] := "HotkeyDeletePaintChecker"
            item["keyLabel"] := "A: Ctrl+Shift+Alt+Home / B: Delete Paint Checker"
            t := "function"
            btn.Text := IconUse(item["icon"])
            btn.Opt("Background" PieSafeColor(item.Get("color", "558B2F")))
            btn.SetFont("s" S(10) "", "Segoe UI Emoji")
        }
        if t = "shortcut" || t = "action" || t = "function" || t = "url" || t = "script" {
            btn.OnEvent("Click", _ColorItemClick.Bind(item, btn))
            ColorGUI._buttonItems[btn.Hwnd] := item
            if item.Get("action", "") = "HotkeyPaintCheckerLayer"
                ColorGUI.paintCheckLayerBtn := btn
        }
        sectionHasEnabled[curSection] := true

        if sectionControls.Has(curSection)
            sectionControls[curSection].Push(btn)
        _pushCtl(btn)
        if secBounds.Has(curSection)
            secBounds[curSection][2] := _allC.Length
        inHdr := false
    }

    ; hide section headers where all items are disabled
    for idx, hdr in sectionHeaders {
        if !sectionHasEnabled.Get(idx, false)
            hdr.Visible := false
    }

    ColorGUI.SetFont("s" S(9) " Bold cFFFFFF", "Segoe UI")

    ; ---- store layout data ----
    ColorGUI._sectionControls := sectionControls
    ColorGUI._sectionHeaders := sectionHeaders
    ColorGUI._sectionOrder := sectionOrder
    ColorGUI._secBounds := secBounds
    ColorGUI._sectionHasEnabled := sectionHasEnabled
    ; calculate section heights
    origY := Map()
    for ctl in _allC {
        ctl.GetPos(&cx, &cy, &cw, &ch)
        origY[ctl] := [cy, ch]
    }
    ColorGUI._origY := origY
    secHeights := Map()
    for secIdx, bounds in secBounds {
        if bounds[1] > _allC.Length {
            secHeights[secIdx] := 0
            continue
        }
        if !secBounds.Has(secIdx) {
            secHeights[secIdx] := 0
            continue
        }
        f := _allC[bounds[1]]
        l := _allC[bounds[2]]
        hdrH := sectionHeaders.Has(secIdx) ? origY[sectionHeaders[secIdx]][2] : 0
        secHeights[secIdx] := origY[l][1] + origY[l][2] - origY[f][1]
        if hdrH > 0
            secHeights[secIdx] -= origY[sectionHeaders[secIdx]][2]
    }
    ColorGUI._secHeights := secHeights
    ; apply initial collapse
    for secIdx, controls in sectionControls {
        collapsed := _colorCollapsed.Get(secIdx, false)
        for ctl in controls
            ctl.Visible := !collapsed
    }

    ColorGUI.OnEvent("ContextMenu", Color_ContextMenu)
    ColorGUI._ready := true
    if hMode
        ColorApplyHorizontalLayout()
    else
        ColorApplySectionLayout()
}

; ---- variadic wrappers for Bind (capture values at bind time, ignore event extras) ----
_ColorSendClick(keys, label, desc, color, req, *) {
    if req != "" && !PieRequirementEnabled(req)
        return ShowNotify("Requirement disabled", req, "0xE53935")
    SendColor(keys, label, desc, color)
}

_ColorItemClick(item, ctrl := "", *) {
    if !IsObject(item)
        return
    try {
        t := item.Get("type", "")
        useB := ToggleItemShouldUseSecond(item, t)
        _ColorRunItemActionSlot(item, useB)
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
    } catch as e {
        ShowNotify("Color Click Error", e.Message, "0xE53935")
    }
}

_ColorItemTestAction(item, actionSlot := "A", *) {
    if !IsObject(item)
        return
    t := item.Get("type", "")
    useB := StrUpper(actionSlot) = "B"
    if useB {
        key2 := t = "function" ? "action2" : (t = "url" || t = "script") ? "target2" : "keys2"
        if Trim(item.Get(key2, "")) = ""
            return ShowNotify("Action Tester", "Action B is empty", "0xE53935")
    }
    _ColorRunItemActionSlot(item, useB)
}

_ColorRunItemActionSlot(item, useB := false) {
    t := item.Get("type", "")
    if t = "shortcut" || t = "action" {
        keys := item.Get(useB ? "keys2" : "keys", "")
        if keys = ""
            return
        req := item.Get("requirement","")
        if req != "" && !PieRequirementEnabled(req)
            return ShowNotify("Requirement disabled", req, "0xE53935")
        sendColor := item.Get(useB ? "color2" : "color", item.Get("color","455A64"))
        if sendColor = ""
            sendColor := item.Get("color","455A64")
        _ColorSendClick(PieQuickNormalizeShortcutAction(keys), item.Get("colorName", item.Get("hover", "")), item.Get("keyLabel",""), "0x" PieSafeColor(sendColor), item.Get("requirement",""))
        extra := item.Get(useB ? "extra2" : "extra", "")
        if extra != ""
            HotkeySendCSP(PieQuickNormalizeShortcutAction(extra))
    } else if t = "function" {
        fn := item.Get(useB ? "action2" : "action", "")
        if fn != ""
            _ColorFuncClickRef(fn, item.Get("hover", ""), item.Get("requirement",""))
    } else if t = "url" || t = "script" {
        target := item.Get(useB ? "target2" : "target", "")
        if target != ""
            _ColorRunClick(target)
    }
}

ToggleItemShouldUseSecond(item, itemType := "") {
    try {
        if !IsObject(item) || !Integer(item.Get("toggle", 0))
            return false
        key2 := itemType = "function" ? "action2" : (itemType = "url" || itemType = "script") ? "target2" : "keys2"
        if Trim(item.Get(key2, "")) = ""
            return false
        state := Integer(item.Get("_toggleState", 0))
        item["_toggleState"] := state ? 0 : 1
        return !!state
    }
}

_ColorFuncClickRef(fn, hover, req, *) {
    if req != "" && !PieRequirementEnabled(req)
        return ShowNotify("Requirement disabled", req, "0xE53935")
    fn := Trim(fn)
    if fn = ""
        return
    fnBase := RegExReplace(fn, "\(\s*\)$")
    if fnBase = "HotkeyPaintCheckerLayer" || fnBase = "FunctionPaintCheckerLayer" {
        HotkeyPaintCheckerLayer()
        return
    }
    if fnBase = "HotkeyPaintCheckerImage" || fnBase = "FunctionPaintCheckerImage" {
        HotkeyPaintCheckerImage()
        return
    }
    if fnBase = "HotkeyDeleteLayer" {
        HotkeyDeleteLayer()
        return
    }
    if fnBase = "HotkeyDeletePaintChecker" {
        HotkeyDeletePaintChecker()
        return
    }
    if fnBase = "HotkeyVectorPaths" {
        HotkeyVectorPaths()
        return
    }
    if fnBase = "HotkeyOpenFolder" {
        HotkeyOpenFolder()
        return
    }
    if fnBase = "HotkeyCloseAllFolder" {
        HotkeyCloseAllFolder()
        return
    }
    if fnBase = "HotkeyIsolateLayer" {
        HotkeyIsolateLayer()
        return
    }
    if fnBase = "HotkeyToggleDraft" {
        HotkeyToggleDraft()
        return
    }
    if fnBase = "HotkeyDraftLayer" {
        HotkeyDraftLayer()
        return
    }
    if fnBase = "ShowColorHistory" {
        ShowColorHistory()
        return
    }
    if fnBase = "ToggleColorLayout" {
        ToggleColorLayout()
        return
    }
    ToolkitRunFunction(fn, hover != "" ? hover : "Color GUI")
}
_ColorRunClick(target, *) {
    Try Run(target)
}

ColorApplySectionLayout() {
    global ColorGUI, _colorCollapsed
    if !IsObject(ColorGUI)
        return
    allCtrls := ColorGUI._allCtrls
    if !IsObject(allCtrls) || allCtrls.Length = 0
        return
    try
        origY := ColorGUI._origY
    catch
        return
    sectionControls := ColorGUI._sectionControls
    sectionHeaders := ColorGUI._sectionHeaders
    sectionOrder := ColorGUI._sectionOrder
    sectionHasEnabled := ColorGUI._sectionHasEnabled

    for ctl in allCtrls {
        ctl.Visible := true
        ctl.Move(, origY[ctl][1])
    }

    for _, secIdx in sectionOrder {
        hdr := sectionHeaders.Get(secIdx, 0)

        emptySection := !sectionHasEnabled.Get(secIdx, false)
        if emptySection && IsObject(hdr)
            hdr.Visible := false

        collapsed := _colorCollapsed.Get(secIdx, false)
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
        ColorGUI.GetPos(&gx, &gy, &gw, &gh)
        ColorGUI.Move(,, gw, visibleBottom + S(8))
    }
}

ColorApplyHorizontalLayout() {
    global ColorGUI
    if !IsObject(ColorGUI)
        return
    allCtrls := ColorGUI._allCtrls
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

    if rightEdge > 0 && bottomEdge > 0 {
        ColorGUI.GetPos(&gx, &gy, &gw, &gh)
        ColorGUI.Move(,, rightEdge + S(8), bottomEdge + S(8))
    }
}

ColorRefreshLayout(*) {
    global ColorLayout
    if ColorLayout = "H"
        ColorApplyHorizontalLayout()
    else
        ColorApplySectionLayout()
}

_ShowReqAlert(reqName, *) {
    popup := Gui("+AlwaysOnTop +ToolWindow", "Add Auto Action!")
    popup.BackColor := "1E1F22"
    popup.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    popup.MarginX := S(16)
    popup.MarginY := S(14)
    popup.AddText("xm cFF9800 w" S(260), reqName " is disabled")
    popup.AddText("xm y+" S(8) " w" S(260), "Some features and shortcuts require this Auto Action preset.")
    popup.AddText("xm y+" S(6) " w" S(260), "To enable it:")
    popup.AddText("xm y+" S(4), "1. Ensure the .laf file is in your CSP Auto Actions folder")
    popup.AddText("xm y+0", "2. Open System Settings -> CSP AutoAction Presets")
    popup.AddText("xm y+0", "3. Check the box for " reqName)
    popup.AddText("xm y+" S(4), "Or set the hotkey to the action:  AutoAction/" reqName)
    btnOk := popup.AddButton("xm y+" S(12) " w" S(80) " h" S(26) " cFFFFFF Default", "OK")
    btnOk.OnEvent("Click", (*) => popup.Destroy())
    popup.Show("AutoSize")
}

ColorToggleSection(secIdx, *) {
    global _colorCollapsed, ColorGUI
    _colorCollapsed[secIdx] := !_colorCollapsed.Get(secIdx, false)
    ColorApplySectionLayout()
}

Color_ContextMenu(guiObj, ctrl, item, isRightClick, x, y) {
    m := Menu()
    try {
        if IsObject(ctrl) && guiObj.HasProp("_buttonItems") && guiObj._buttonItems.Has(ctrl.Hwnd) {
            btnItem := guiObj._buttonItems[ctrl.Hwnd]
            m.Add("Test Action A", _ColorItemTestAction.Bind(btnItem, "A"))
            try toggleVal := Integer(btnItem.Get("toggle", 0))
            catch
                toggleVal := 0
            if toggleVal
                m.Add("Test Action B", _ColorItemTestAction.Bind(btnItem, "B"))
            m.Add()
        }
    }
    m.Add("Hide Color GUI", _HideColorMenu)
    m.Add("Toggle Layout", ToggleColorLayout)
    m.Add("Toggle Cursor Color Info", ToggleColorInfo)
    m.Add("Color Info Mode: " ColorInfoModeText(), ToggleColorInfoFollowMode)
    m.Add("Middle Pick: " ColorInfoMiddlePickText(), ToggleColorInfoMiddlePick)
    m.Add("Clipboard Format: " ColorInfoClipboardFormatText(), ToggleColorInfoClipboardFormat)
    m.Add("Color Info Offset...", ShowColorInfoOffsetDialog)
    m.Add("Customize Colors...", (*) => ShowColorButtonCustomizer())
    m.Add("Opacity...", ShowOpacitySlider.Bind("Color"))
    m.Add("Debug Log", ShowDebugGUI)
    m.Show()
}
_HideColorMenu(*) {
    global ColorGUIVisible, ColorManualHide
    try ColorGUI.Hide()
    ColorGUIVisible := false
    ColorManualHide := true
    if GuiHasCtrl(MainGUI, "btnColor")
        MainGUI.btnColor.Opt("BackgroundE53935 cFFFFFF")
    DebugLog("Color hidden via context menu")
}

ShowColorManager(*) {
    global ColorItems, _colorCollapsed, ColorGUI, ColorGUIVisible, ColorGUI_X, ColorGUI_Y
    if !FeatureEnabled("colorgui") {
        ShowNotify("Color GUI", "Color GUI feature is OFF", "0xE53935")
        return
    }
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Color GUI Button Manager - " ModeSettingsActiveName())
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)

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

    _RefreshList()

    btnW := S(93), gap := S(6), btnH := S(28), enableW := (btnW * 2) + gap
    dlg.AddButton("xm y+" gap " w" btnW " h" btnH, "▲ Up").OnEvent("Click", (*) => MoveItem(-1))
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "▼ Down").OnEvent("Click", (*) => MoveItem(1))
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Add").OnEvent("Click", (*) => AddItem())
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Edit").OnEvent("Click", (*) => EditItem())
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Remove").OnEvent("Click", (*) => RemoveItem())
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Reset Sel").OnEvent("Click", (*) => ResetSelected())
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Reset All").OnEvent("Click", (*) => ResetAll())
    dlg.AddButton("xm y+" gap " w" enableW " h" btnH, "Enable/Disable").OnEvent("Click", (*) => ToggleItem())
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Export").OnEvent("Click", (*) => ExportColorItems())
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Import").OnEvent("Click", (*) => ImportColorItems())
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH " Default", "Save").OnEvent("Click", (*) => DoSave())
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Close").OnEvent("Click", (*) => dlg.Destroy())
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH " Background4CAF50 cFFFFFF", "Done").OnEvent("Click", (*) => DoApply())

    dlg.Show("AutoSize")

    _RefreshList() {
        global ColorItems
        lv.Delete()
        for idx, item in ColorItems {
            t := item.Get("type","")
            iconText := item.Get("icon","")
            if iconText = "" && t != "sep"
                iconText := item.Get("label","")
            noteText := item.Get("note","")
            if t = "disabled" {
                noteText := noteText != "" ? "DISABLED - " noteText : "DISABLED"
            }
            lv.Add("", idx, t, iconText, item.Get("label",""), item.Get("hover",""), noteText, t = "disabled" ? "No" : "Yes")
        }
    }
    AddItem() {
        global ColorItems
        item := ColorItemDialog(Map())
        if item {
            ColorItems.Push(item)
            SaveColorItems()
            _RebuildColorGui()
            _RefreshList()
        }
    }

    EditItem() {
        global ColorItems
        r := lv.GetNext()
        if !r
            return
        idx := Integer(lv.GetText(r, 1))
        item := ColorItems[idx]
        newItem := ColorItemDialog(item.Clone(), (applied) => (
            ColorItems[idx] := applied,
            SaveColorItems(),
            _RebuildColorGui(),
            _RefreshList()
        ))
        if newItem {
            ColorItems[idx] := newItem
            SaveColorItems()
            _RebuildColorGui()
            _RefreshList()
        }
    }

    RemoveItem() {
        global ColorItems
        rows := []
        r := 0
        while r := lv.GetNext(r)
            rows.Push(Integer(lv.GetText(r, 1)))
        if rows.Length = 0
            return
        if !_Confirm("Remove", "Remove selected item(s)?")
            return
        for i in rows {
            idx := rows[rows.Length - A_Index + 1]
            ColorItems.RemoveAt(idx)
        }
        SaveColorItems()
        _RebuildColorGui()
        _RefreshList()
    }

    ToggleItem() {
        global ColorItems
        r := lv.GetNext()
        if !r
            return
        idx := Integer(lv.GetText(r, 1))
        item := ColorItems[idx]
        if item.Get("type","") = "sep"
            return
        if item.Get("type","") = "disabled" {
            item["type"] := item.Get("_origType", "shortcut")
            if item.Has("_origType")
                item.Delete("_origType")
        } else {
            item["_origType"] := item.Get("type","shortcut")
            item["type"] := "disabled"
        }
        SaveColorItems()
        _RebuildColorGui()
        _RefreshList()
    }

    MoveItem(dir) {
        global ColorItems
        r := lv.GetNext()
        if !r
            return
        idx := Integer(lv.GetText(r, 1))
        ni := idx + dir
        if ni < 1 || ni > ColorItems.Length
            return
        tmp := ColorItems[idx]
        ColorItems[idx] := ColorItems[ni]
        ColorItems[ni] := tmp
        SaveColorItems()
        _RebuildColorGui()
        _RefreshList()
        lv.Modify(r + dir, "Select Focus")
    }

    ResetAll() {
        global ColorItems
        if !_Confirm("Reset", "Restore default color items? This will remove all custom items.")
            return
        ColorItems := ColorItemsDefaults()
        SaveColorItems()
        _RebuildColorGui()
        _RefreshList()
    }

    ResetSelected() {
        global ColorItems
        r := lv.GetNext()
        if !r
            return
        idx := Integer(lv.GetText(r, 1))
        item := ColorItems[idx]
        label := item.Get("label", "")
        hover := item.Get("hover", "")
        action := item.Get("action", "")
        defaults := ColorItemsDefaults()
        def := Map()
        for d in defaults {
            dl := d.Get("label", "")
            dh := d.Get("hover", "")
            da := d.Get("action", "")
            if dl = label && dh = hover && da = action {
                def := d.Clone()
                break
            }
            if dl = label && dh = hover {
                def := d.Clone()
                break
            }
            if action != "" && da != "" && da = action {
                def := d.Clone()
                break
            }
        }
        if !def.Has("type") {
            ; match by label only
            for d in defaults {
                if d.Get("label", "") = label {
                    def := d.Clone()
                    break
                }
            }
        }
        if !def.Has("type") {
            ShowNotify("Reset", "No default found for: " label, "0xE53935")
            return
        }
        if !_Confirm("Reset", "Reset '" label "' to default?")
            return
        ColorItems[idx] := def
        SaveColorItems()
        _RebuildColorGui()
        _RefreshList()
        lv.Modify(r, "Select Focus")
    }

    DoSave() {
        SaveColorItems()
        _RebuildColorGui()
    }

    DoApply() {
        SaveColorItems()
        _RebuildColorGui()
        dlg.Destroy()
    }

    _Confirm(title, msg) {
        popup := Gui("+AlwaysOnTop +ToolWindow", title)
        popup.BackColor := "1E1F22"
        popup.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
        popup.MarginX := S(14)
        popup.MarginY := S(14)
        popup.AddText("cFFD54F", msg)
        result := false
        popup.AddButton("xm y+10 w" S(80) " h" S(26) " BackgroundE53935 cFFFFFF", "Yes").OnEvent("Click", (*) => (result := true, popup.Destroy()))
        popup.AddButton("x+8 yp w" S(80) " h" S(26), "No").OnEvent("Click", (*) => popup.Destroy())
        popup.Show("AutoSize")
        GuiWaitForCloseSafe(popup)
        return result
    }
}

_RebuildColorGui() {
    global ColorGUI, ColorGUIVisible, ColorGUI_X, ColorGUI_Y
    wasVisible := ColorGUIVisible
    try if ColorGUI.Hwnd {
        ColorGUI.GetPos(&ColorGUI_X, &ColorGUI_Y)
        ColorGUI.Destroy()
    }
    CreateColorGui()
    if wasVisible {
        ColorGUIVisible := true
        try ColorGUI.Show("x" ColorGUI_X " y" ColorGUI_Y " NoActivate")
        ColorRefreshLayout()
    }
}

ToggleColorLayout(*) {
    global ColorLayout, ColorGUI, ColorGUIVisible, ColorGUI_X, ColorGUI_Y
    wasVisible := ColorGUIVisible || IsGuiVisibleSafe(ColorGUI)
    if IsObject(ColorGUI)
        ColorGUI.GetPos(&ColorGUI_X, &ColorGUI_Y)
    ColorLayout := ColorLayout = "V" ? "H" : "V"
    DebugLog("Color Layout " (ColorLayout = "V" ? "H -> V" : "V -> H"))
    IniWrite(ColorLayout, SETTINGS_FILE, "Color", "Layout")
    if IsObject(ColorGUI)
        ColorGUI.Destroy()
    CreateColorGui()
    if wasVisible {
        ColorGUIVisible := true
        try ColorGUI.Show("x" ColorGUI_X " y" ColorGUI_Y " NoActivate")
        ColorRefreshLayout()
    }
}

PositionColorGui() {
    global ColorGUI, ColorGUI_X, ColorGUI_Y, Color_Opacity
    if !FeatureEnabled("colorgui")
        return
    try if !ColorGUI.Hwnd
        return
    try if !ColorGUI._ready
        return
    try ColorGUI.Show("x" ColorGUI_X " y" ColorGUI_Y " NoActivate")
    try _ZFixGUI(ColorGUI)
    ColorRefreshLayout()
    if Color_Opacity < 255
        WinSetTransparent(Color_Opacity, ColorGUI)
}

ShowColorButtonCustomizer(*) {
    global ColorItems, ColorGUI, ColorGUIVisible, ColorGUI_X, ColorGUI_Y
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Customize Item Colors")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)

    dlg.AddText("xm cAAAAAA", "Edit item background colors (6-digit hex):")
    inputCtrls := Map()
    yp := "y+" S(4)
    for idx, item in ColorItems {
        t := item.Get("type","")
        if t = "sep" || t = "disabled"
            continue
        lbl := item.Get("label","")
        cur := item.Get("color","777777")
        dlg.AddText("xm " yp " w" S(100) " h" S(20) " +0x200 Background" cur " cFFFFFF", "      " lbl)
        ed := dlg.AddEdit("x+8 yp w" S(70) " c000000 BackgroundFFFFFF", cur)
        preview := dlg.AddText("x+8 yp w" S(20) " h" S(20) " +0x200 Background" cur, "")
        boundEd := ed, boundPreview := preview
        ed.OnEvent("Change", (*) => (
            val := Trim(boundEd.Value),
            val ~= "^[0-9A-Fa-f]{6}$" ? boundPreview.Opt("Background" val) : ""
        ))
        inputCtrls[idx] := ed
        yp := "y+" S(2)
    }
    dlg.AddButton("xm y+" S(12) " w" S(80) " h" S(26) " cFFFFFF Default", "Done").OnEvent("Click", (*) => _ColorSaveAndRebuild(dlg, inputCtrls))
    dlg.AddButton("x+" S(8) " yp w" S(80) " h" S(26), "Cancel").OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("AutoSize")

    _ColorSaveAndRebuild(dlg, inputCtrls, *) {
        global ColorItems, ColorGUI, ColorGUIVisible, ColorGUI_X, ColorGUI_Y
        for idx, ed in inputCtrls {
            val := Trim(ed.Value)
            if val ~= "^[0-9A-Fa-f]{6}$" {
                ColorItems[idx]["color"] := val
            }
        }
        SaveColorItems()
        wasVisible := ColorGUIVisible
        if IsObject(ColorGUI) {
            ColorGUI.GetPos(&ColorGUI_X, &ColorGUI_Y)
            ColorGUI.Destroy()
        }
        CreateColorGui()
        if wasVisible {
            ColorGUIVisible := true
            try ColorGUI.Show("x" ColorGUI_X " y" ColorGUI_Y " NoActivate")
            ColorRefreshLayout()
        }
        dlg.Destroy()
    }
}

ExportColorItems() {
    global ColorItems
    fn := FileSelect("S16", A_MyDocuments "\color_items_backup.ini", "Export Color Items", "INI (*.ini)")
    if fn = ""
        return
    try {
        IniDelete(fn, "ColorItems")
        cnt := 0
        for idx, item in ColorItems {
            cnt++
            i := cnt
            itemType := item.Get("type","")
            IniWrite(itemType, fn, "ColorItems", i "_type")
            for key in ["label","hover","color","color2","keys","extra","action","target","icon","icon2","iconBold","fontSize","colorName","keyLabel","colorDefault","note","requirement","_origType","toggle","keys2","extra2","action2","target2"] {
                v := item.Get(key, "")
                if v != "" {
                    if (key = "keys" || key = "extra" || key = "keys2" || key = "extra2" || key = "action" || key = "action2") && (itemType = "shortcut" || itemType = "action")
                        v := PieQuickNormalizeShortcutAction(v)
                    if key = "icon" || key = "icon2"
                        v := IconEnc(IconSafe(v))
                    IniWrite(v, fn, "ColorItems", i "_" key)
                }
            }
        }
        if cnt > 0
            IniWrite(cnt, fn, "ColorItems", "count")
    }
    ShowNotify("Color Items", "Exported " cnt " items", "0x4CAF50")
}

ImportColorItems() {
    global ColorItems
    fn := FileSelect("3", A_MyDocuments "\color_items_backup.ini", "Import Color Items", "INI (*.ini)")
    if fn = ""
        return
    try
        cnt := IniRead(fn, "ColorItems", "count", 0)
    catch
        cnt := 0
    if cnt < 1 {
        ShowNotify("Import", "No color items found in file", "0xE53935")
        return
    }
    try CreateConfigBackup("before_color_import", false)
    items := []
    Loop cnt {
        i := A_Index
        try
            t := IniRead(fn, "ColorItems", i "_type", "")
        catch
            t := ""
        if t = ""
            continue
        m := Map("type", t)
        for key in ["label","hover","color","color2","keys","extra","action","target","icon","icon2","iconBold","fontSize","colorName","keyLabel","colorDefault","note","requirement","_origType","toggle","keys2","extra2","action2","target2"] {
            try
                v := IniRead(fn, "ColorItems", i "_" key, "")
            catch
                v := ""
            if v != "" {
                if key = "icon" || key = "icon2"
                    v := IconDec(v)
                m[key] := v
            }
        }
        items.Push(m)
    }
    ColorItems := items
    SaveColorItems()
    _RebuildColorGui()
    ShowNotify("Color Items", "Imported " items.Length " items", "0x4CAF50")
}

ExportIconRef() {
    dir := A_ScriptDir "\src\docs"
    try {
        if !DirExist(dir)
            DirCreate(dir)
    }
    path := dir "\IconRef.ini"
    icons := Map()

    ; ── Color palette item icons ──
    for item in ColorItemsDefaults() {
        icon := item.Get("icon", "")
        icon2 := item.Get("icon2", "")
        label := item.Get("label", "")
        if icon != "" && !icons.Has(icon)
            icons[icon] := "ColorPalette_" label
        if icon2 != "" && !icons.Has(icon2)
            icons[icon2] := "ColorPalette_" label "_B"
    }

    ; ── Icon presets from LinkIconPresetList ──
    iconPresetEntries := [
        "◆","Main","⚙","Settings","⌨","Hotkeys","∞","Link","▤","Sheets",
        "⊞","Drive","◎","Search","☉","Web","⏏","File","▶","Run",
        "◈","Color","⏱","Timer","⤵","Save","⚒","Tools",
        "★","Star","●","Dot","＋","Add","－","Remove","「」","Canvas Size",
        "⚑","Pin","⚡","Zap","⊠","Lock",
        "⊡","Unlock","✓","Check","✕","Close","↻","Refresh","⌂","Home",
        "⌫","Trash","◉","View","✒","Pen",
        "✏","Pencil","☀","Idea","⭐","Star2","♛","Trophy","◇","Key",
        "◆","Gem","◐","Bell","☰","Chat","✉","Mail",
        "☏","Phone","♫","Music","☽","Moon","∟","Ruler",
        "✎","Brush","⚙","Gear","⊘","Block","⌷","Tag",
        "≡","Note","⊞","Folder","△","Rocket","▶","Timeline",
        "▣","Screen","▷","Reel","◎","Target","△","Fire"
    ]
    i := 1
    while i < iconPresetEntries.Length {
        char := iconPresetEntries[i]
        name := iconPresetEntries[i + 1]
        if !icons.Has(char)
            icons[char] := "Preset_" name
        i += 2
    }

    ; ── GUI button icons ──
    guiIcons := Map(
        "▲","Up","▼","Down","∅","EmptySlot","🖐","NavToggle",
        "⇪","CapslockToggle","⊞","LWinToggle","🔓","Unlock","💤","AutoSaveOff",
        "🎨","ColorGUI","↺","ResetBtn","▶","Play","■","StopBtn",
        "💾","SaveBtn","↥","LoadBtn","🔒","Lock","🚫","Disabled",
        "⟲","ResetPos","🔗","LinkBtn","◷","PieOven","⏱","Stopwatch",
        "⌨","HotkeysBtn","⚙","SettingsBtn","❚❚","Pause","↻","RefreshBtn",
        "⤵","SaveArrow","◀","SubPrev"
    )
    for char, name in guiIcons {
        if !icons.Has(char)
            icons[char] := "GUI_" name
    }

    ; ── Toggle state pairs (IB bar & hotkey states) ──
    toggleStates := Map(
        "🖐","NavEnabled","🔒","Locked","🔓","Unlocked",
        "💤","AutoSaveOff","💾","AutoSaveOn","🚫","Disabled",
        "⇪","CapslockOn","⊞","LWinOn","↻","ResetOn","Tab","TabOn"
    )
    for char, name in toggleStates {
        if !icons.Has(char)
            icons[char] := "Toggle_" name
    }

    ; ── Link launcher icons (persistence.ahk defaults) ──
    linkIcons := Map(
        "◈","LinkMain","◆","LinkMainOverride","🕑","LinkWorktime",
        "🖼️","LinkCanvas","🎞","LinkTimeline","「」","LinkCrop",
        "📊","LinkSheets","📁","LinkDrive","🔎","LinkSearch",
        "⬤","LinkDisabled"
    )
    for char, name in linkIcons {
        if !icons.Has(char)
            icons[char] := "Link_" name
    }

    ; ── Color info & palette indicators ──
    miscIcons := Map(
        "○","ColorInfoPrev","●","ColorInfoCur","=","ColorHistory",
        "🖼","Frame","🗑","Trash","🔍","Magnify","📄","DraftPage",
        "✒","VectorPen","📂","OpenFolder","↕","ToggleLayout",
        "⇄","InverseSel","◎","Isolate","⊘","Deselect","！","Alert"
    )
    for char, name in miscIcons {
        if !icons.Has(char)
            icons[char] := "Misc_" name
    }

    ; ── Main GUI & IB bar text labels ──
    textIcons := Map(
        "Tab","TabBtn","HK","HotkeysBtn","OFF","DisabledBtn",
        "Lap","LapBtn","Guide","GuideBtn","S>E","ModeS2E",
        "E>S","ModeE2S","PNG","SavePNG","TXT","SaveTXT",
        "IB","IBToggle","Link","LinkToggle","Color","ColorToggle",
        "Safe","SafeMode","GUI","GuiOpacity","Status","StatusDsh",
        "Debug","DebugLog","PICK","MiddlePick"
    )
    for text, name in textIcons {
        if !icons.Has(text)
            icons[text] := "Text_" name
    }

    ; ── Color preset quick-select letters ──
    colorPresetLetters := Map(
        "R","Red","G","Green","B","Blue","C","Cyan",
        "O","Orange","V","Purple","Gr","Grey","K","Black",
        "W","White","Y","Yellow"
    )
    for letter, name in colorPresetLetters {
        if !icons.Has(letter)
            icons[letter] := "ColorPreset_" name
    }

    ; ── Fallback/repair icons ──
    fallbackIcons := Map(
        "?","Unknown","??","Unknown2","?A","AnimUnknown",
        "?N","NormalUnknown",
        "❔","FallbackRepair","⏱","FallbackTimer","◆","FallbackDiamond",
        "▶","FallbackPlay","▤","FallbackSheets","⊞","FallbackWin",
        "◎","FallbackTarget"
    )
    for char, name in fallbackIcons {
        if !icons.Has(char)
            icons[char] := "Fallback_" name
    }

    try {
        IniDelete(path, "Icons")
        for char, source in icons
            IniWrite(IconEnc(char), path, "Icons", source)
        IniWrite(IconEnc("🚫"), path, "Icons", "Pie_DisabledBadge")
        IniWrite(icons.Count + 1, path, "Icons", "_count")
    }

    try {
        IniDelete(path, "Backup")
        backupEntries := [
            "🔍","◎","🗑","✕","🖼","◆","🖐","◆",
            "🔒","⊠","🔓","⊡","💤","○","💾","■",
            "🎨","◈","📄","▤","📂","▣","🕑","◉",
            "🎞","▶","📊","▤","📁","▣","🔎","◎",
            "⏱","◉","❚❚","■","◷","↺","🖼️","◆",
            "🚫","∅","⬤","●","∅","○","↕","⇅","❔","?",
            "！","!","⇄","↔","⟲","↺","◀","<"
        ]
        i := 1
        while i < backupEntries.Length {
            primary := backupEntries[i]
            backupChar := backupEntries[i + 1]
            if icons.Has(primary) {
                IniWrite(IconEnc(backupChar), path, "Backup", IconEnc(primary))
            }
            i += 2
        }
        IniWrite(backupEntries.Length // 2, path, "Backup", "_count")
    }
}
; ============================================================
