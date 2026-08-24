; CORE FUNCTIONS - CSP state & light table helpers
; ============================================================

; --- Z-order fix: re-assert topmost position after Show("NoActivate") ---
_ZFixGUI(guiObj) {
    try DllCall("SetWindowPos", "ptr", guiObj.Hwnd, "ptr", -1, "int", 0, "int", 0, "int", 0, "int", 0, "uint", 0x0002 | 0x0001 | 0x0004)
}
; Reassert topmost Z-order for all main GUIs
_FixGUIZ() {
    global IB_GUI, ColorGUI, LinkGUI, MainGUI
    try _ZFixGUI(IB_GUI)
    try _ZFixGUI(ColorGUI)
    try _ZFixGUI(LinkGUI)
    try _ZFixGUI(MainGUI)
}

NormalizeLTColor(value) {
    value := Trim(value)
    clean := RegExReplace(value, "i)^(#|0x)", "")
    clean := RegExReplace(clean, "[^0-9A-Fa-f]", "")
    if RegExMatch(clean, "i)^[0-9A-F]{6}$")
        return Integer("0x" clean)
    try return Integer(value)
    return -1
}

NormalizeHexColorText(value, fallback := "455A64") {
    fallback := RegExReplace(Trim(fallback), "i)^(#|0x)", "")
    fallback := RegExReplace(fallback, "[^0-9A-Fa-f]", "")
    fallback := RegExMatch(fallback, "i)^[0-9A-F]{6}$") ? StrUpper(fallback) : "455A64"
    clean := RegExReplace(Trim(value), "i)^(#|0x)", "")
    clean := RegExReplace(clean, "[^0-9A-Fa-f]", "")
    if RegExMatch(clean, "i)^[0-9A-F]{6}$")
        return StrUpper(clean)
    try {
        n := Integer(value)
        if n >= 0 && n <= 0xFFFFFF
            return Format("{:06X}", n)
    }
    return fallback
}

ContrastColor(bgHex) {
    bgHex := RegExReplace(Trim(bgHex), "i)^(#|0x)", "")
    bgHex := RegExReplace(bgHex, "[^0-9A-Fa-f]", "")
    if !RegExMatch(bgHex, "i)^[0-9A-F]{6}$")
        return "FFFFFF"
    r := Integer("0x" SubStr(bgHex, 1, 2))
    g := Integer("0x" SubStr(bgHex, 3, 2))
    b := Integer("0x" SubStr(bgHex, 5, 2))
    return (0.299 * r + 0.587 * g + 0.114 * b) > CONTRAST_THRESHOLD ? "000000" : "FFFFFF"
}

HotkeyDisplayName(key) {
    key := Trim(key)
    if key = "" || key = "-"
        return key

    key := RegExReplace(key, "i)SC029", "``")

    ; Hide AHK-only registration prefixes in user-facing labels.
    while key != "" && InStr("~*$<>", SubStr(key, 1, 1))
        key := SubStr(key, 2)

    mods := ""
    while key != "" {
        ch := SubStr(key, 1, 1)
        switch ch {
            case "!":
                mods .= "Alt+"
            case "^":
                mods .= "Ctrl+"
            case "+":
                mods .= "Shift+"
            case "#":
                mods .= "Win+"
            default:
                break
        }
        key := SubStr(key, 2)
    }

    if key = ""
        return RTrim(mods, "+")
    return mods HotkeyDisplayKeyName(key)
}

HotkeyDisplayKeyName(key) {
    key := Trim(key)
    if key = ""
        return ""

    lower := StrLower(key)
    static names := 0
    if !IsObject(names) {
        names := Map()
        names["esc"] := "Esc"
        names["escape"] := "Esc"
        names["tab"] := "Tab"
        names["space"] := "Space"
        names["enter"] := "Enter"
        names["return"] := "Enter"
        names["ins"] := "Insert"
        names["insert"] := "Insert"
        names["del"] := "Delete"
        names["delete"] := "Delete"
        names["pgup"] := "Page Up"
        names["pgdn"] := "Page Down"
        names["up"] := "Up"
        names["down"] := "Down"
        names["left"] := "Left"
        names["right"] := "Right"
        names["lbutton"] := "LButton"
        names["rbutton"] := "RButton"
        names["mbutton"] := "MButton"
        names["wheelup"] := "WheelUp"
        names["wheeldown"] := "WheelDown"
    }
    if names.Has(lower)
        return names[lower]
    return StrLen(key) = 1 ? StrUpper(key) : key
}

IBThemePresets() {
    presets := Map(
        "Default", Map("25","5D4037","33","795548","40","FFB300","60","2E7D32","66","81C784","75","43A047","empty","555555","s2e","4CAF50","e2s","E53935","25_se","5D4037","33_se","795548","40_se","FFB300","60_se","2E7D32","66_se","81C784","75_se","43A047","empty_se","555555","25_es","8D6E63","33_es","A1887F","40_es","FFD54F","60_es","66BB6A","66_es","A5D6A7","75_es","81C784","empty_es","AAAAAA"),
        "Dark", Map("25","3E2723","33","4E342E","40","FF8F00","60","1B5E20","66","2E7D32","75","388E3C","empty","333333","s2e","2E7D32","e2s","C62828","25_se","3E2723","33_se","4E342E","40_se","FF8F00","60_se","1B5E20","66_se","2E7D32","75_se","388E3C","empty_se","333333","25_es","5D4037","33_es","6D4C41","40_es","FFA000","60_es","2E7D32","66_es","388E3C","75_es","43A047","empty_es","555555"),
        "Light", Map("25","8D6E63","33","A1887F","40","FFD54F","60","66BB6A","66","A5D6A7","75","81C784","empty","AAAAAA","s2e","66BB6A","e2s","EF5350","25_se","8D6E63","33_se","A1887F","40_se","FFD54F","60_se","66BB6A","66_se","A5D6A7","75_se","81C784","empty_se","AAAAAA","25_es","5D4037","33_es","795548","40_es","FFB300","60_es","2E7D32","66_es","81C784","75_es","43A047","empty_es","555555"),
        "Vivid", Map("25","D84315","33","FF8F00","40","FDD835","60","00897B","66","039BE5","75","1A237E","empty","424242","s2e","00897B","e2s","E53935","25_se","D84315","33_se","FF8F00","40_se","FDD835","60_se","00897B","66_se","039BE5","75_se","1A237E","empty_se","424242","25_es","4A148C","33_es","283593","40_es","1565C0","60_es","EF6C00","66_es","E65100","75_es","BF360C","empty_es","555555"),
        "Rainbow", Map("25","E53935","33","FF9800","40","FFEB3B","60","4CAF50","66","2196F3","75","9C27B0","empty","616161","s2e","4CAF50","e2s","E53935","25_se","E53935","33_se","FF9800","40_se","FFEB3B","60_se","4CAF50","66_se","2196F3","75_se","9C27B0","empty_se","616161","25_es","9C27B0","33_es","2196F3","40_es","4CAF50","60_es","FFEB3B","66_es","FF9800","75_es","E53935","empty_es","555555"),
        "Muted", Map("25","616161","33","757575","40","9E9E9E","60","558B2F","66","7CB342","75","8BC34A","empty","555555","s2e","7CB342","e2s","E57373","25_se","616161","33_se","757575","40_se","9E9E9E","60_se","558B2F","66_se","7CB342","75_se","8BC34A","empty_se","555555","25_es","757575","33_es","8D8D8D","40_es","AAAAAA","60_es","6D8F6D","66_es","8FB08F","75_es","A5D6A7","empty_es","757575"),
        "Ocean", Map("25","0D47A1","33","1565C0","40","29B6F6","60","00838F","66","26C6DA","75","80DEEA","empty","546E7A","s2e","00ACC1","e2s","EF5350","25_se","0D47A1","33_se","1565C0","40_se","29B6F6","60_se","00838F","66_se","26C6DA","75_se","80DEEA","empty_se","546E7A","25_es","64B5F6","33_es","42A5F5","40_es","4FC3F7","60_es","4DD0E1","66_es","80DEEA","75_es","B2EBF2","empty_es","90A4AE"),
        "Sakura", Map("25","AD1457","33","C2185B","40","EC407A","60","F48FB1","66","F8BBD0","75","FCE4EC","empty","9E9E9E","s2e","EC407A","e2s","D32F2F","25_se","AD1457","33_se","C2185B","40_se","EC407A","60_se","F48FB1","66_se","F8BBD0","75_se","FCE4EC","empty_se","9E9E9E","25_es","D81B60","33_es","E91E63","40_es","F06292","60_es","F8BBD0","66_es","FCE4EC","75_es","FFFFFF","empty_es","CCCCCC"),
        "Cyber", Map("25","311B92","33","512DA8","40","7C4DFF","60","00B8D4","66","18FFFF","75","64FFDA","empty","424242","s2e","00E5FF","e2s","FF1744","25_se","311B92","33_se","512DA8","40_se","7C4DFF","60_se","00B8D4","66_se","18FFFF","75_se","64FFDA","empty_se","424242","25_es","651FFF","33_es","7C4DFF","40_es","536DFE","60_es","00E5FF","66_es","18FFFF","75_es","84FFFF","empty_es","616161"),
        "Autumn", Map("25","6D4C41","33","8D6E63","40","FB8C00","60","F9A825","66","FDD835","75","FFF176","empty","616161","s2e","F9A825","e2s","D84315","25_se","6D4C41","33_se","8D6E63","40_se","FB8C00","60_se","F9A825","66_se","FDD835","75_se","FFF176","empty_se","616161","25_es","A1887F","33_es","BCAAA4","40_es","FFB74D","60_es","FFD54F","66_es","FFF176","75_es","FFF9C4","empty_es","9E9E9E"),
        "Cold Hot", Map("25","0D47A1","33","1565C0","40","00BCD4","60","F9A825","66","E65100","75","C62828","empty","546E7A","s2e","00BCD4","e2s","E65100","25_se","0D47A1","33_se","1565C0","40_se","00BCD4","60_se","F9A825","66_se","E65100","75_se","C62828","empty_se","546E7A","25_es","C62828","33_es","E65100","40_es","F9A825","60_es","00BCD4","66_es","1565C0","75_es","0D47A1","empty_es","78909C"),
        "Mono", Map("25","212121","33","424242","40","616161","60","9E9E9E","66","BDBDBD","75","EEEEEE","empty","757575","s2e","9E9E9E","e2s","616161","25_se","212121","33_se","424242","40_se","616161","60_se","9E9E9E","66_se","BDBDBD","75_se","EEEEEE","empty_se","757575","25_es","424242","33_es","616161","40_es","757575","60_es","BDBDBD","66_es","E0E0E0","75_es","FAFAFA","empty_es","BDBDBD"),
        "Color Blind", Map("25","0072B2","33","56B4E9","40","F0E442","60","E69F00","66","CC79A7","75","7B3294","empty","757575","s2e","009E73","e2s","D55E00","25_se","0072B2","33_se","56B4E9","40_se","F0E442","60_se","E69F00","66_se","CC79A7","75_se","7B3294","empty_se","757575","25_es","5DADE2","33_es","85C1E9","40_es","F7DC6F","60_es","F5B041","66_es","D7BDE2","75_es","BB8FCE","empty_es","B0B0B0")
    )
    presets["Neon"] := Map("25","FF1744","33","F50057","40","D500F9","60","00E676","66","1DE9B6","75","00B0FF","empty","263238","s2e","00E676","e2s","FF1744","25_se","FF1744","33_se","F50057","40_se","D500F9","60_se","00E676","66_se","1DE9B6","75_se","00B0FF","empty_se","263238","25_es","651FFF","33_es","2979FF","40_es","00E5FF","60_es","76FF03","66_es","FFFF00","75_es","FF9100","empty_es","455A64")
    presets["Pastel"] := Map("25","BCAAA4","33","D7CCC8","40","FFE082","60","A5D6A7","66","C8E6C9","75","DCEDC8","empty","B0BEC5","s2e","A5D6A7","e2s","EF9A9A","25_se","BCAAA4","33_se","D7CCC8","40_se","FFE082","60_se","A5D6A7","66_se","C8E6C9","75_se","DCEDC8","empty_se","B0BEC5","25_es","CE93D8","33_es","B39DDB","40_es","90CAF9","60_es","80DEEA","66_es","B2EBF2","75_es","F8BBD0","empty_es","CFD8DC")
    presets["Forest"] := Map("25","3E2723","33","4E342E","40","827717","60","1B5E20","66","33691E","75","689F38","empty","37474F","s2e","2E7D32","e2s","8D6E63","25_se","3E2723","33_se","4E342E","40_se","827717","60_se","1B5E20","66_se","33691E","75_se","689F38","empty_se","37474F","25_es","5D4037","33_es","6D4C41","40_es","9E9D24","60_es","2E7D32","66_es","558B2F","75_es","8BC34A","empty_es","546E7A")
    presets["Candy"] := Map("25","EC407A","33","AB47BC","40","7E57C2","60","26C6DA","66","66BB6A","75","FFCA28","empty","78909C","s2e","26C6DA","e2s","EC407A","25_se","EC407A","33_se","AB47BC","40_se","7E57C2","60_se","26C6DA","66_se","66BB6A","75_se","FFCA28","empty_se","78909C","25_es","F06292","33_es","BA68C8","40_es","9575CD","60_es","4DD0E1","66_es","81C784","75_es","FFD54F","empty_es","B0BEC5")
    presets["Sunset"] := Map("25","BF360C","33","E65100","40","FF8F00","60","F9A825","66","FDD835","75","FFF176","empty","5D4037","s2e","FFB300","e2s","D84315","25_se","BF360C","33_se","E65100","40_se","FF8F00","60_se","F9A825","66_se","FDD835","75_se","FFF176","empty_se","5D4037","25_es","4A148C","33_es","6A1B9A","40_es","8E24AA","60_es","C2185B","66_es","E91E63","75_es","FF7043","empty_es","795548")
    presets["Graphite"] := Map("25","111111","33","212121","40","424242","60","616161","66","9E9E9E","75","E0E0E0","empty","303030","s2e","616161","e2s","424242","25_se","111111","33_se","212121","40_se","424242","60_se","616161","66_se","9E9E9E","75_se","E0E0E0","empty_se","303030","25_es","263238","33_es","37474F","40_es","455A64","60_es","607D8B","66_es","90A4AE","75_es","ECEFF1","empty_es","546E7A")
    presets["Lavender"] := Map("25","4A148C","33","6A1B9A","40","8E24AA","60","7E57C2","66","B39DDB","75","E1BEE7","empty","6D6D6D","s2e","7E57C2","e2s","C2185B","25_se","4A148C","33_se","6A1B9A","40_se","8E24AA","60_se","7E57C2","66_se","B39DDB","75_se","E1BEE7","empty_se","6D6D6D","25_es","311B92","33_es","512DA8","40_es","673AB7","60_es","9575CD","66_es","D1C4E9","75_es","F3E5F5","empty_es","9E9E9E")
    presets["Warm Gray"] := Map("25","6D4C41","33","8D6E63","40","A1887F","60","BCAAA4","66","D7CCC8","75","EFEBE9","empty","757575","s2e","8D6E63","e2s","A1887F","25_se","6D4C41","33_se","8D6E63","40_se","A1887F","60_se","BCAAA4","66_se","D7CCC8","75_se","EFEBE9","empty_se","757575","25_es","4E342E","33_es","5D4037","40_es","795548","60_es","A1887F","66_es","BCAAA4","75_es","D7CCC8","empty_es","9E9E9E")
    presets["Cool Gray"] := Map("25","37474F","33","455A64","40","546E7A","60","78909C","66","90A4AE","75","B0BEC5","empty","616161","s2e","546E7A","e2s","455A64","25_se","37474F","33_se","455A64","40_se","546E7A","60_se","78909C","66_se","90A4AE","75_se","B0BEC5","empty_se","616161","25_es","263238","33_es","37474F","40_es","455A64","60_es","607D8B","66_es","78909C","75_es","90A4AE","empty_es","78909C")
    presets["Midnight"] := Map("25","1A237E","33","283593","40","3949AB","60","5C6BC0","66","7986CB","75","9FA8DA","empty","263238","s2e","3949AB","e2s","283593","25_se","1A237E","33_se","283593","40_se","3949AB","60_se","5C6BC0","66_se","7986CB","75_se","9FA8DA","empty_se","263238","25_es","0D47A1","33_es","1565C0","40_es","1976D2","60_es","42A5F5","66_es","64B5F6","75_es","90CAF9","empty_es","455A64")
    presets["Tropical"] := Map("25","006064","33","00838F","40","26A69A","60","66BB6A","66","9CCC65","75","D4E157","empty","455A64","s2e","26A69A","e2s","00838F","25_se","006064","33_se","00838F","40_se","26A69A","60_se","66BB6A","66_se","9CCC65","75_se","D4E157","empty_se","455A64","25_es","004D40","33_es","00695C","40_es","00897B","60_es","4DB6AC","66_es","80CBC4","75_es","B2DFDB","empty_es","607D8B")
    presets["Retro"] := Map("25","BF360C","33","E65100","40","F57F17","60","FBC02D","66","FDD835","75","FFF176","empty","6D4C41","s2e","F57F17","e2s","E65100","25_se","BF360C","33_se","E65100","40_se","F57F17","60_se","FBC02D","66_se","FDD835","75_se","FFF176","empty_se","6D4C41","25_es","D84315","33_es","EF6C00","40_es","FF8F00","60_es","FFCA28","66_es","FFD54F","75_es","FFE082","empty_es","8D6E63")
    presets["Steampunk"] := Map("25","3E2723","33","4E342E","40","BF8F00","60","D4A017","66","C68E17","75","E8C56E","empty","5D4037","s2e","BF8F00","e2s","3E2723","25_se","3E2723","33_se","4E342E","40_se","BF8F00","60_se","D4A017","66_se","C68E17","75_se","E8C56E","empty_se","5D4037","25_es","5D4037","33_es","6D4C41","40_es","A67C00","60_es","B8860B","66_es","D4A017","75_es","DAA520","empty_es","795548")
    presets["Arctic"] := Map("25","006064","33","00838F","40","00ACC1","60","26C6DA","66","80DEEA","75","E0F7FA","empty","78909C","s2e","00ACC1","e2s","00838F","25_se","006064","33_se","00838F","40_se","00ACC1","60_se","26C6DA","66_se","80DEEA","75_se","E0F7FA","empty_se","78909C","25_es","00838F","33_es","00ACC1","40_es","00BCD4","60_es","4DD0E1","66_es","B2EBF2","75_es","E0F7FA","empty_es","90A4AE")
    presets["Toxic"] := Map("25","33691E","33","558B2F","40","76FF03","60","C6FF00","66","EEFF41","75","FFFF00","empty","424242","s2e","76FF03","e2s","558B2F","25_se","33691E","33_se","558B2F","40_se","76FF03","60_se","C6FF00","66_se","EEFF41","75_se","FFFF00","empty_se","424242","25_es","1B5E20","33_es","2E7D32","40_es","689F38","60_es","AED581","66_es","DCE775","75_es","FFF59D","empty_es","616161")
    presets["Royal"] := Map("25","311B92","33","4527A0","40","673AB7","60","9575CD","66","B39DDB","75","D1C4E9","empty","546E7A","s2e","673AB7","e2s","4527A0","25_se","311B92","33_se","4527A0","40_se","673AB7","60_se","9575CD","66_se","B39DDB","75_se","D1C4E9","empty_se","546E7A","25_es","4A148C","33_es","6A1B9A","40_es","7B1FA2","60_es","AB47BC","66_es","CE93D8","75_es","E1BEE7","empty_es","78909C")
    presets["Marshmallow"] := Map("25","F8BBD0","33","F48FB1","40","F06292","60","FFAB91","66","FFCCBC","75","FBE9E7","empty","B0BEC5","s2e","F06292","e2s","F48FB1","25_se","F8BBD0","33_se","F48FB1","40_se","F06292","60_se","FFAB91","66_se","FFCCBC","75_se","FBE9E7","empty_se","B0BEC5","25_es","F48FB1","33_es","EC407A","40_es","E91E63","60_es","FF8A65","66_es","FFAB91","75_es","FFCCBC","empty_es","CFD8DC")
    return presets
}

IBThemePresetNames(includeCustom := true) {
    names := ["Default"]
    if includeCustom
        names.Push("Custom")
    names.Push("--- Base ---",
        "Dark", "Light", "Muted", "Warm Gray", "Cool Gray",
        "--- Cold ---",
        "Ocean", "Cyber", "Midnight", "Arctic", "Lavender", "Royal",
        "Forest", "Tropical", "Toxic",
        "--- Warm ---",
        "Autumn", "Sunset", "Sakura", "Marshmallow",
        "Retro", "Steampunk",
        "--- Colorful ---",
        "Vivid", "Neon", "Rainbow", "Candy", "Cold Hot",
        "--- Calm ---",
        "Pastel",
        "Color Blind", "Mono", "Graphite")
    return names
}

IsLTActive() {
    global LT_X, LT_Y, LT_Color
    try x := Integer(LT_X)
    catch
        return false
    try y := Integer(LT_Y)
    catch
        return false
    if x <= 0 || y <= 0
        return false
    target := NormalizeLTColor(LT_Color)
    if target < 0
        return false
    try {
        ; Fast path: exact coordinate match
        if NormalizeLTColor(PixelGetColor(x, y)) = target
            return true
        ; Fallback: search 7x7 area for tolerance against small window offsets
        if PixelSearch(&fx, &fy, x - 3, y - 3, x + 3, y + 3, target)
            return true
    }
    return false
}

ResetLT() {
    global InbetweenIndex
    HotkeySendCSP("+^!w")
    UpdateIBGui(InbetweenIndex)
}

ResetLTIfActive() {
    if IsLTActive()
        ResetLT()
}

NormalizeInbetweenMode(mode) {
    return mode = "Start > End" ? "Start > End" : "End > Start"
}

IB_ColorGet(key, mode) {
    global _IBColors
    suffix := mode = "Start > End" ? "_se" : "_es"
    return _IBColors.Has(key suffix) ? _IBColors[key suffix] : (_IBColors.Has(key) ? _IBColors[key] : "555555")
}
BuildInbetweenData(mode) {
    global _IBColors
    mode := NormalizeInbetweenMode(mode)
    if mode = "Start > End" {
        return Map(
            1, {bar:"50 |-----|-----|>", desc:"50", color:"0x000000"},
            2, {bar:"66 |-------|---|>", desc:"Start > End", color:"0x" IB_ColorGet("66", mode)},
            3, {bar:"33 |---|-------|>", desc:"Start > End", color:"0x" IB_ColorGet("33", mode)},
            4, {bar:"75 |--------|--|>", desc:"Start > End", color:"0x" IB_ColorGet("75", mode)},
            5, {bar:"25 |--|--------|>", desc:"Start > End", color:"0x" IB_ColorGet("25", mode)},
            6, {bar:"60 |------|----|>", desc:"Start > End", color:"0x" IB_ColorGet("60", mode)},
            7, {bar:"40 |----|------|>", desc:"Start > End", color:"0x" IB_ColorGet("40", mode)},
            8, {bar:"─ empty ─", desc:"Empty", color:"0x" IB_ColorGet("empty", mode)}
        )
    }
    return Map(
        1, {bar:"50 |-----|-----|>", desc:"50", color:"0x000000"},
        2, {bar:"33 |---|-------|>", desc:"End > Start", color:"0x" IB_ColorGet("33", mode)},
        3, {bar:"66 |-------|---|>", desc:"End > Start", color:"0x" IB_ColorGet("66", mode)},
        4, {bar:"25 |--|--------|>", desc:"End > Start", color:"0x" IB_ColorGet("25", mode)},
        5, {bar:"75 |--------|--|>", desc:"End > Start", color:"0x" IB_ColorGet("75", mode)},
        6, {bar:"40 |----|------|>", desc:"End > Start", color:"0x" IB_ColorGet("40", mode)},
        7, {bar:"60 |------|----|>", desc:"End > Start", color:"0x" IB_ColorGet("60", mode)},
        8, {bar:"─ empty ─", desc:"Empty", color:"0x" IB_ColorGet("empty", mode)}
    )
}

DoLayer(key, name, color:="", extra:="") {
    ResetLTIfActive()
    HotkeySendCSP("+" key extra)
    ShowNotify(name, "Shift+" key, color)
}

CheckCSP() {
    global IB_GUI, ColorGUI, LinkGUI
    global IBVisible, ColorGUIVisible, LinkGUIVisible
    global IBManualHide, LinkManualHide, ColorManualHide
    global CSPActive, IB_LTInd, LTLock, CSP_PID, InbetweenIndex
    global GUIEnabled, GUIVisible, MainGUIVisible
    global LT_ClickX, LT_ClickY
    global NavEnabled, NavBtn, CapslockEnabled, CapslockBtn, TabCombosEnabled, TabCombosBtn, LWinEnabled, LWinBtn, MainGUI
    global HotkeysPaused
    global IB_Opacity, Color_Opacity, Link_Opacity
    global _timerRunning
    global _TypingState
    global _capslockModActive, _tabModActive
    global CSP_RestartMonitor
    global _selfPID
    _pid := _selfPID

    ; --- Process guard: detect CSP restart ---
    cspHwnd := WinExist("ahk_exe CLIPStudioPaint.exe")
    if cspHwnd {
        try pid := WinGetPID(cspHwnd)
        catch
            pid := 0
        if pid != CSP_PID && CSP_PID != 0
            CSPActive := false
        if pid
            CSP_PID := pid
    }

    try {
        isCSP   := cspHwnd && WinActive("ahk_exe CLIPStudioPaint.exe")
        isIB    := SafeGuiHwnd(IB_GUI) && WinActive("ahk_id " SafeGuiHwnd(IB_GUI))
        isColor := SafeGuiHwnd(ColorGUI) && WinActive("ahk_id " SafeGuiHwnd(ColorGUI))
        isLink  := SafeGuiHwnd(LinkGUI) && WinActive("ahk_id " SafeGuiHwnd(LinkGUI))
        isScriptDlg := WinExist("A") && (WinGetPID("A") = _pid) && !isCSP && !isIB && !isColor && !isLink
    } catch {
        ; A window may have closed between the existence check and the query.
        isCSP := isIB := isColor := isLink := isScriptDlg := false
    }

    ; --- State tracking ---
    if isCSP
        CSPActive := true

    ; --- Mode flag enforcement: hard force the active mode's toggles ---
    HK_EnforceModeFlags()

    ; --- Auto mode switching: follow the active target window ---
    HK_AutoSwitchPoll()

    ; --- LT indicator ---
    if IsObject(IB_GUI) {
        static _prevState := ""
        ltOn := CSPActive && IsLTActive()
        state := InbetweenIndex = 8 ? "FFFFFF" : (LTLock || !ltOn ? "E53935" : "42A5F5")
        if state != _prevState {
            _prevState := state
            IB_LTInd.Opt("Background" state)
        }
    }

    ; --- LT Lock: auto-kill LT when active ---
    if LTLock && CSPActive && IsLTActive() {
        static _lockLastAction := 0
        if A_TickCount - _lockLastAction > 800 {
            _lockLastAction := A_TickCount
            MouseClick "left", LT_ClickX, LT_ClickY
            Sleep 30
            ResetLT()
        }
    }

    ; --- Show / Hide GUIs based on CSP focus ---
    if GUIEnabled {
        showGUI := isCSP || (CSPActive && (isIB || isColor || isLink))
        static _hideCooldown := 0
        if showGUI || _capslockModActive || _tabModActive {
            _hideCooldown := 0
        } else {
            _hideCooldown++
        }
        if showGUI || isScriptDlg {
            if !isScriptDlg
                CSPActive := true
            _EnsureGUIs()
            if !IBVisible && !IBManualHide && FeatureEnabled("ibgui") {
                try IB_PositionGui()
                try _ZFixGUI(IB_GUI)
                IBVisible := true
                GUIVisible := true
                if GuiHasCtrl(MainGUI, "btnIB")
                    MainGUI.btnIB.Opt("Background4CAF50 cFFFFFF")
                DebugLog("IB auto-shown (opacity " IB_Opacity ")")
            }
            if !ColorGUIVisible && !ColorManualHide && FeatureEnabled("colorgui") {
                try PositionColorGui()
                try _ZFixGUI(ColorGUI)
                ColorGUIVisible := true
                GUIVisible := true
                if GuiHasCtrl(MainGUI, "btnColor")
                    MainGUI.btnColor.Opt("Background4CAF50 cFFFFFF")
                DebugLog("Color auto-shown (opacity " Color_Opacity ")")
            }
            if !LinkGUIVisible && !LinkManualHide && FeatureEnabled("linkgui") {
                try PositionLinkGUI()
                try _ZFixGUI(LinkGUI)
                LinkGUIVisible := true
                GUIVisible := true
                if GuiHasCtrl(MainGUI, "btnLink")
                    MainGUI.btnLink.Opt("Background4CAF50 cFFFFFF")
                DebugLog("Link auto-shown (opacity " Link_Opacity ")")
            }
            if MainGUIVisible && !IsGuiVisibleSafe(MainGUI) {
                ShowMainGUI()
                try _ZFixGUI(MainGUI)
            }
        } else if _hideCooldown >= 3 && (IBVisible || ColorGUIVisible || LinkGUIVisible
            || IsGuiVisibleSafe(IB_GUI)
            || IsGuiVisibleSafe(ColorGUI)
            || IsGuiVisibleSafe(LinkGUI)) {
            try IB_GUI.Hide()
            try ColorGUI.Hide()
            try LinkGUI.Hide()
            IBVisible := false
            IBManualHide := false
            ColorGUIVisible := false
            ColorManualHide := false
            LinkGUIVisible := false
            LinkManualHide := false
            GUIVisible := false
            if IsGuiVisibleSafe(MainGUI)
                MainGUI.Hide()
            if _timerRunning
                DebugLog("GUIs auto-hidden (CSP focus lost), timer active")
            else
                DebugLog("GUIs auto-hidden (CSP focus lost)")
        }
        if CSPActive && !showGUI && !isScriptDlg
            CSPActive := false
    }

    ; --- CSP auto-restart monitor ---
    if CSP_RestartMonitor && !cspHwnd && CSP_PID != 0 {
        CSP_PID := 0
        DebugLog("CSP process detected missing, attempting restart...")
        if _HK_Confirm("CSP appears to have closed. Restart it?", "CSP Monitor")
            Run("C:\Program Files\CELSYS\CLIP STUDIO 1.5\CLIP STUDIO\CLIPStudioPaint.exe")
    }

    ; --- Auto-disable Nav/Capslock/Tab/LWin/HK indicators when typing ---
    if isCSP || isScriptDlg {
        if IsTyping() {
            if NavEnabled {
                _TypingState["nav"] := true
                NavEnabled := false
                if IsObject(NavBtn) {
                    NavBtn.Text := IconUse("🚫", "X")
                    NavBtn.Opt("Background2A2A2A cFFFFFF")
                }
            }
            if CapslockEnabled {
                _TypingState["caps"] := true
                CapslockEnabled := false
                if IsObject(CapslockBtn) {
                    CapslockBtn.Text := IconUse("🚫", "X")
                    CapslockBtn.Opt("Background2A2A2A cFFFFFF")
                }
            }
            if TabCombosEnabled {
                _TypingState["tab"] := true
                TabCombosEnabled := false
                if IsObject(TabCombosBtn) {
                    TabCombosBtn.Text := IconUse("🚫", "X")
                    TabCombosBtn.Opt("Background2A2A2A cFFFFFF")
                }
            }
            if LWinEnabled {
                _TypingState["lwin"] := true
                LWinEnabled := false
                if IsObject(LWinBtn) {
                    LWinBtn.Text := IconUse("🚫", "X")
                    LWinBtn.Opt("Background2A2A2A cFFFFFF")
                }
            }
            if !HotkeysPaused {
                _TypingState["hk"] := true
                if GuiHasCtrl(MainGUI, "btnHotkeys") {
                    MainGUI.btnHotkeys.Text := IconUse("🚫", "X")
                    MainGUI.btnHotkeys.Opt("Background2A2A2A cFFFFFF")
                }
            }
        } else {
            if _TypingState["nav"] && !NavEnabled {
                _TypingState["nav"] := false
                NavEnabled := true
                if IsObject(NavBtn) {
                    NavBtn.Text := IconUse("🖐", "Nav")
                    NavBtn.Opt("BackgroundE65100 cFFFFFF")
                }
            }
            if _TypingState["caps"] && !CapslockEnabled {
                _TypingState["caps"] := false
                CapslockEnabled := true
                if IsObject(CapslockBtn) {
                    CapslockBtn.Text := IconUse("⇪", "C")
                    CapslockBtn.Opt("Background1565C0 cFFFFFF")
                }
            }
            if _TypingState["tab"] && !TabCombosEnabled {
                _TypingState["tab"] := false
                TabCombosEnabled := true
                if IsObject(TabCombosBtn) {
                    TabCombosBtn.Text := "Tab"
                    TabCombosBtn.Opt("Background2E7D32 cFFFFFF")
                }
            }
            if _TypingState["lwin"] && !LWinEnabled {
                _TypingState["lwin"] := false
                LWinEnabled := true
                if IsObject(LWinBtn) {
                    LWinBtn.Text := IconUse("⊞", "W")
                    LWinBtn.Opt("BackgroundFF6F00 cFFFFFF")
                }
            }
            if _TypingState["hk"] {
                _TypingState["hk"] := false
                if GuiHasCtrl(MainGUI, "btnHotkeys")
                    UpdateHotkeysPauseButton()
            }
        }
    }
}

; ============================================================
; NOTIFICATION SYSTEM
; ============================================================

ShowNotify(t, s:="", c:="") {
    global NotifyEnabled, NotifyMonitor, NotifyPosition
    if !NotifyEnabled
        return
    posOpt := " pos=" NotifyPosition
    monOpt := NotifyMonitor > 0 ? " mon=" NotifyMonitor : ""
    static _lastT := "", _lastTime := 0, _lastAnyTime := 0
    if t = _lastT && A_TickCount - _lastTime < 1200
        return
    if A_TickCount - _lastAnyTime < 150
        return
    _lastT := t
    _lastTime := A_TickCount
    _lastAnyTime := A_TickCount
    _NotifyHistoryPush(t, s)
    Notify.Show(t, s,,,, 'dur=1 ts=10 ms=7 pad=8,4,6,6,6,6,2,3 mf=Segoe UI Black mfo=norm Bold mali=Center' posOpt monOpt (c ? " bc=" c : ""))
}

; --- Notification history (ring buffer, newest last) ---

global _notifyHistory := []

_NotifyHistoryPush(t, s) {
    global _notifyHistory
    _notifyHistory.Push({time: FormatTime(, "HH:mm:ss"), title: t, msg: s})
    if _notifyHistory.Length > 100
        _notifyHistory.RemoveAt(1, _notifyHistory.Length - 100)
}

ShowNotifyCenter(*) {
    global _notifyHistory
    txt := ""
    i := _notifyHistory.Length
    while (i >= 1) {
        n := _notifyHistory[i]
        txt .= "[" n.time "] " n.title "`n"
        if (n.msg != "")
            txt .= "    " StrReplace(n.msg, "`n", "`n    ") "`n"
        i -= 1
    }
    if (txt = "")
        txt := "(no notifications yet)"

    dlg := Gui("+AlwaysOnTop +ToolWindow", "Notification Center")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s10", "Segoe UI")
    dlg.MarginX := 14
    dlg.MarginY := 14

    dlg.SetFont("s13 Bold cFFFFFF", "Segoe UI")
    dlg.AddText("xm w" S(520), "Notification Center")
    count := _notifyHistory.Length
    dlg.SetFont("s9 norm c888888", "Segoe UI")
    dlg.AddText("xm y+2 w" S(520), "Last " count " notification(s) this session.")

    dlg.SetFont("s9 cE8EAED", "Consolas")
    ed := dlg.AddEdit("xm y+10 w" S(520) " h" S(480) " +ReadOnly +VScroll +Wrap Background24272E cE8EAED", txt)

    clearBtn := dlg.AddButton("xm y+10 w" S(100) " h" S(28), "Clear")
    clearBtn.OnEvent("Click", (*) => NotifyCenterClear(ed))
    closeBtn := dlg.AddButton("x+" S(8) " yp w" S(100) " h" S(28) " Default", "Close")
    closeBtn.OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("AutoSize")
    closeBtn.Focus()
}

NotifyCenterClear(ed) {
    global _notifyHistory
    _notifyHistory := []
    ed.Value := "(no notifications yet)"
}

; Copy text to the clipboard safely. Returns true on success; on failure
; (clipboard locked by another app) shows a warning and returns false.
SetClipboardSafe(text, title := "Copy") {
    try {
        A_Clipboard := text
        return true
    } catch {
        ShowNotify(title, "Clipboard is busy - try again", "0xE53935")
        return false
    }
}

DebugLog(msg) {
    global _debugLog, _debugDateShown, _debugGUI, _debugRevision
    if !_debugDateShown {
        d := FormatTime(, "dd-MM-yyyy HH:mm:ss")
        w := FormatTime(, "dddd")
        _debugLog.Push("=== " w " " d " ===")
        _debugDateShown := true
    }
    _debugLog.Push(FormatTime(, "HH:mm:ss") " " msg)
    if _debugLog.Length > 600
        _debugLog.RemoveAt(1, _debugLog.Length - 500)
    _debugRevision++
    if IsObject(_debugGUI)
        DebugRenderLog()
}

DebugLineLevel(line) {
    lower := StrLower(line)
    if SubStr(line, 1, 3) = "==="
        return "date"
    if InStr(lower, "error") || InStr(lower, "failed") || InStr(lower, "exception") || InStr(lower, "invalid") || InStr(lower, "conflict")
        return "error"
    if InStr(lower, "warning") || InStr(lower, "missing") || InStr(lower, "ignored") || InStr(lower, "disabled")
        return "warn"
    if InStr(lower, "saved") || InStr(lower, "loaded") || InStr(lower, "applied") || InStr(lower, "migrated") || InStr(lower, "success")
        return "ok"
    return "info"
}

DebugEnsureFilters() {
    global _debugFilters
    if !IsObject(_debugFilters)
        _debugFilters := Map("date", true, "info", true, "ok", true, "warn", true, "error", true)
}

DebugFilterPass(line) {
    global _debugFilters
    DebugEnsureFilters()
    level := DebugLineLevel(line)
    return !_debugFilters.Has(level) || !!_debugFilters[level]
}

_DebugToggleFilter(ctrl, *) {
    global _debugFilters, _debugRevision
    DebugEnsureFilters()
    level := ctrl.level
    _debugFilters[level] := !!ctrl.Value
    _debugRevision++
    DebugRenderLog()
}

ShowDebugGUI(*) {
    global _debugLog, _debugGUI, _debugSaveOnExit, _debugDateShown, SETTINGS_FILE, _debugRevision, SCRIPT_VERSION
    DebugEnsureFilters()
    if IsObject(_debugGUI) {
        _debugGUI.Show()
        SetTimer(_DebugAutoRefresh, 2000)
        return
    }
    _debugGUI := Gui("+AlwaysOnTop +ToolWindow", "Debug Log")
    _debugGUI.BackColor := "1E1F22"
    _debugGUI.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    _debugGUI.MarginX := S(10)
    _debugGUI.MarginY := S(10)
    _debugGUI.SetFont("s" S(8) " c000000", "Consolas")
    DllCall("LoadLibrary", "Str", "Msftedit.dll", "Ptr")
    logW := S(533)
    btnW := S(72)
    btnGap := S(5)
    ed := _debugGUI.AddCustom("ClassRICHEDIT50W xm w" logW " h" S(350) " +ReadOnly -Wrap VScroll +0x4 +0x40 +0x100000 +0x200000 Background1E1F22")
    ed.SetFont("s" S(8), "Consolas")
    _debugGUI.ed := ed
    _debugGUI.OnEvent("Close", (*) => (_debugGUI.Destroy(), _debugGUI := 0))
    _debugGUI.SetFont("s" S(8) " cFFFFFF", "Segoe UI")

    _debugGUI.AddText("xm cAAAAAA", "Show:")
    for info in [["Info","info"],["OK","ok"],["Warn","warn"],["Error","error"]] {
        cbx := _debugGUI.AddCheckbox("x+" S(6) " yp cCCCCCC Background1E1F22", info[1])
        cbx.level := info[2]
        cbx.Value := _debugFilters[info[2]] ? 1 : 0
        cbx.OnEvent("Click", _DebugToggleFilter)
    }

    _debugGUI.AddText("x+" S(3) " yp-1 cAAAAAA", "|")
    cb := _debugGUI.AddCheckbox("x+" S(12) " yp+2 Background1E1F22 cCCCCCC", "Save on exit")
    cb.Value := _debugSaveOnExit
    cb.OnEvent("Click", _DebugSaveOnExitToggle)

    _debugGUI.AddText("x" logW-S(50) " yp c80CBC4", "Version " SCRIPT_VERSION)

    _debugGUI.AddButton("xm y+" S(10) " w" btnW " h" S(28), "Health").OnEvent("Click", ShowSettingsHealth)
    _debugGUI.AddButton("x+" btnGap " yp w" btnW " h" S(28), "Self-Heal").OnEvent("Click", SelfHealSettings)
    _debugGUI.AddButton("x+" btnGap " yp w" btnW " h" S(28), "Validator").OnEvent("Click", ShowCSPSetupValidator)
    _debugGUI.AddButton("x+" btnGap " yp w" btnW " h" S(28), "Scanner").OnEvent("Click", ShowBrokenActionScanner)
    _debugGUI.AddButton("x+" btnGap " yp w" btnW " h" S(28), "Conflict").OnEvent("Click", ShowActionConflictTester)
    _debugGUI.AddButton("x+" btnGap " yp w" btnW " h" S(28), "Diag").OnEvent("Click", ShowSettingsLoadDiagnostics)
    _debugGUI.AddButton("x+" btnGap " yp w" btnW " h" S(28), "Refresh").OnEvent("Click", _DebugRefresh)
    _debugGUI.AddButton("xm y+" S(8) " w" btnW " h" S(28), "Clear").OnEvent("Click", (*) => (
        _debugLog := [],
        _debugDateShown := false,
        _debugRevision++,
        DebugRenderLog()
    ))
    _debugGUI.AddButton("x+" btnGap " yp w" btnW " h" S(28), "Save").OnEvent("Click", (*) => _DebugSave())
    _debugGUI.AddButton("x+" btnGap " yp w" btnW " h" S(28), "Doctor").OnEvent("Click", ShowConfigDoctor)
    _debugGUI.AddButton("x+" btnGap " yp w" btnW " h" S(28), "Typing").OnEvent("Click", ShowTypingSafeguardInspector)
    _debugGUI.AddButton("x+" btnGap " yp w" btnW " h" S(28), "Stress").OnEvent("Click", ShowHotkeyStressTest)
    if DevToolsAvailable()
        _debugGUI.AddButton("x+" btnGap " yp w" btnW " h" S(28), "Dev").OnEvent("Click", OpenDevTools)
    btnClose := _debugGUI.AddButton("x+" btnGap " yp w" btnW " h" S(28), "Close")
    btnClose.OnEvent("Click",(*) => (_debugGUI.Destroy(), _debugGUI := 0))
    DebugRenderLog()
    _debugGUI.Show("AutoSize")
    btnClose.Focus()
    SetTimer(_DebugAutoRefresh, 2000)
}

_DebugSaveOnExitToggle(ctrl, *) {
    global _debugSaveOnExit, SETTINGS_FILE
    _debugSaveOnExit := ctrl.Value
    try IniWrite(_debugSaveOnExit, SETTINGS_FILE, "Settings", "DebugSaveOnExit")
}

_DebugRefresh(*) {
    DebugRenderLog()
}

_DebugAutoRefresh(*) {
    global _debugGUI, _debugLog
    if !IsObject(_debugGUI) {
        SetTimer(_DebugAutoRefresh, 0)
        return
    }
    if !IsObject(_debugGUI.ed)
        return
    DebugRenderLog()
}

DebugRenderLog() {
    global _debugGUI, _debugLog, _debugFilters, _debugRevision
    if !IsObject(_debugGUI) || !IsObject(_debugGUI.ed)
        return
    hwnd := _debugGUI.ed.Hwnd
    static lastSig := ""
    DebugEnsureFilters()
    filterSig := (_debugFilters["info"] ? "1" : "0") (_debugFilters["ok"] ? "1" : "0") (_debugFilters["warn"] ? "1" : "0") (_debugFilters["error"] ? "1" : "0") (_debugFilters["date"] ? "1" : "0")
    sig := hwnd "|" _debugRevision "|" filterSig
    if lastSig = sig
        return
    lastSig := sig
    firstVisible := DllCall("SendMessage", "Ptr", hwnd, "UInt", 0xCE, "Ptr", 0, "Ptr", 0, "Ptr") ; EM_GETFIRSTVISIBLELINE
    SendMessage(0x0B, false, 0, hwnd) ; WM_SETREDRAW
    ; COLORREF uses BGR byte order.
    SendMessage(0x443, 0, DebugRgbToColorRef("1E1F22"), hwnd) ; EM_SETBKGNDCOLOR
    DllCall("SetWindowText", "Ptr", hwnd, "Str", "")
    i := _debugLog.Length
    while i >= 1 {
        v := _debugLog[i]
        if DebugFilterPass(v)
            DebugRichAppend(hwnd, DebugDecorateLine(v) "`r`n", DebugLineColor(v))
        i--
    }
    SendMessage(0xB1, 0, 0, hwnd) ; EM_SETSEL, avoid stale inactive-selection artifacts
    SendMessage(0x43F, true, 0, hwnd) ; EM_HIDESELECTION
    curFirst := DllCall("SendMessage", "Ptr", hwnd, "UInt", 0xCE, "Ptr", 0, "Ptr", 0, "Ptr")
    delta := firstVisible - curFirst
    if delta
        SendMessage(0xB6, 0, delta, hwnd) ; EM_LINESCROLL
    SendMessage(0x0B, true, 0, hwnd) ; WM_SETREDRAW
    DllCall("RedrawWindow", "Ptr", hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x85)
}

DebugDecorateLine(line) {
    level := DebugLineLevel(line)
    if level = "date"
        return line
    if level = "error"
        return "[ERROR] " line
    if level = "warn"
        return "[WARN]  " line
    if level = "ok"
        return "[OK]    " line
    return "[INFO]  " line
}

DebugLineColor(line) {
    level := DebugLineLevel(line)
    if level = "date"
        return "9E9E9E"
    if level = "error"
        return "FF6B6B"
    if level = "warn"
        return "FFD166"
    if level = "ok"
        return "7BD88F"
    return "E8EAED"
}

DebugRichAppend(hwnd, text, rgbHex) {
    static EM_SETSEL := 0xB1, EM_REPLACESEL := 0xC2, EM_SETCHARFORMAT := 0x444
    static SCF_SELECTION := 0x1, CFM_COLOR := 0x40000000, CFM_BACKCOLOR := 0x04000000
    SendMessage(EM_SETSEL, -1, -1, hwnd)
    cf := Buffer(116, 0)
    NumPut("UInt", 116, cf, 0)
    NumPut("UInt", CFM_COLOR | CFM_BACKCOLOR, cf, 4)
    NumPut("UInt", DebugRgbToColorRef(rgbHex), cf, 20)
    NumPut("UInt", DebugRgbToColorRef("1E1F22"), cf, 96)
    SendMessage(EM_SETCHARFORMAT, SCF_SELECTION, cf.Ptr, hwnd)
    SendMessage(EM_REPLACESEL, false, StrPtr(text), hwnd)
}

DebugRgbToColorRef(rgbHex) {
    clean := RegExReplace(Trim(rgbHex), "i)^(#|0x)", "")
    if !RegExMatch(clean, "i)^[0-9A-F]{6}$")
        clean := "E8EAED"
    r := Integer("0x" SubStr(clean, 1, 2))
    g := Integer("0x" SubStr(clean, 3, 2))
    b := Integer("0x" SubStr(clean, 5, 2))
    return (b << 16) | (g << 8) | r
}

_DebugSave() {
    global _debugLog
    if _debugLog.Length = 0
        return
    ts := FormatTime(, "yyyy-MM-dd_HH-mm-ss")
    def := A_MyDocuments "\CSPtoolkit_debug_log_" ts ".txt"
    fp := FileSelect("S", def, "Save Debug Log", "Text (*.txt)")
    if fp = ""
        return
    _txt := ""
    for v in _debugLog
        _txt .= v "`n"
    try FileAppend(RTrim(_txt, "`n") "`n", fp, "UTF-8")
    ShowNotify("Debug Log", "Saved")
}

SaveDebugLog() {
    global _debugLog
    if _debugLog.Length = 0
        return
    ts := FormatTime(, "yyyy-MM-dd_HH-mm-ss")
    fp := A_MyDocuments "\CSPtoolkit_debug_log_" ts ".txt"
    _txt := ""
    for v in _debugLog
        _txt .= v "`n"
    try FileAppend(RTrim(_txt, "`n") "`n", fp, "UTF-8")
}

SendColor(keys, label, desc:="", color:="") {
    global NotifyEnabled, NotifyMonitor, NotifyPosition
    if WinExist("ahk_exe CLIPStudioPaint.exe") {
        WinActivate("ahk_exe CLIPStudioPaint.exe")
        WinWaitActive("ahk_exe CLIPStudioPaint.exe",, 0.5)
        HotkeySendCSP(keys)
        hasColor := (Type(color)="String" && RegExMatch(color, "^0x[0-9A-Fa-f]{6}$"))
    } else {
        if NotifyEnabled {
            ShowNotify("CSP not found", "Open Clip Studio Paint first", "0xE53935")
        }
        return
    }
    if !NotifyEnabled
        return
    ShowNotify(label, desc, hasColor ? color : "")
}

; ============================================================
global _debugRevision := 0
