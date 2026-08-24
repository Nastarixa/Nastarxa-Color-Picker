; PRESET WIZARD — Unified Import/Export
; ============================================================
; Wizard dialog for sharing preset configurations between
; installations. Bundles hotkeys, pie menus, colors, links,
; IB colors, and feature switches into one INI file.

global _PresetWizardGui := 0

ShowPresetWizardExport(*) {
    ShowPresetWizard("export")
}

ShowPresetWizardImport(*) {
    ShowPresetWizard("import")
}

ShowPresetWizard(action := "export") {
    global _PresetWizardGui
    if IsObject(_PresetWizardGui) {
        try _PresetWizardGui.Destroy()
        _PresetWizardGui := 0
    }
    _categories := [
        {key:"hotkeys",   label:"Hotkey Profiles",   file:HOTKEY_SETTINGS_FILE},
        {key:"pie",       label:"Pie Menus",          file:PIE_SETTINGS_FILE},
        {key:"colors",    label:"Color Items",        file:COLOR_SETTINGS_FILE},
        {key:"links",     label:"Link Buttons",       file:LINK_SETTINGS_FILE},
        {key:"features",  label:"Feature Switches",   file:FEATURE_SETTINGS_FILE}
    ]

    dlg := Gui("+AlwaysOnTop +ToolWindow", "Preset Wizard")
    _PresetWizardGui := dlg
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)

    title := action = "export" ? "Export Presets" : "Import Presets"
    dlg.AddText("xm y+" S(6) " cFFD54F", title)
    dlg.AddText("xm y+2 cAAAAAA", "Select categories to " action ":")

    checkboxes := Map()
    for cat in _categories {
        available := FileExist(cat.file) ? "available" : "not found"
        color := available = "available" ? "AAAAAA" : "777777"
        cb := dlg.AddCheckbox("xm y+" S(8) " c" color " Background1E1F22 Checked1", cat.label " (" available ")")
        cb.Enabled := available = "available"
        checkboxes[cat.key] := cb
    }

    if action = "import" {
        dlg.AddText("xm y+" S(12) " cAAAAAA", "Import file:")
        dlg.AddEdit("xm y+2 w" S(280) " ReadOnly cFFFFFF Background333333 vPresetImportPath")
        btnBrowse := dlg.AddButton("x+5 yp w" S(50) " h" S(22) " cFFFFFF", "Browse")
        btnBrowse.OnEvent("Click", _PresetWizardBrowse.Bind(dlg))
    }

    result := {selected:[], path:""}

    btnText := action = "export" ? "Export" : "Import"
    dlg.AddButton("xm y+" S(12) " w" S(60) " h" S(26) " cFFFFFF Default", btnText).OnEvent("Click", _PresetWizardExecute.Bind(dlg, action, checkboxes, result, _categories))
    dlg.AddButton("x+5 yp w" S(50) " h" S(26), "Cancel").OnEvent("Click", (*) => (_PresetWizardGui := 0, dlg.Destroy()))
    dlg.AddButton("x+5 yp w" S(68) " h" S(26), "Select All").OnEvent("Click", (*) => _PresetWizardSelectAll(checkboxes, _categories))
    dlg.AddButton("x+5 yp w" S(80) " h" S(26), "Deselect All").OnEvent("Click", (*) => _PresetWizardDeselectAll(checkboxes, _categories))

    dlg.Show("AutoSize")
}

_PresetWizardSelectAll(checkboxes, categories) {
    for cat in categories
        checkboxes[cat.key].Value := 1
}

_PresetWizardDeselectAll(checkboxes, categories) {
    for cat in categories
        checkboxes[cat.key].Value := 0
}

_PresetWizardBrowse(dlg, *) {
    fn := FileSelect("1", A_MyDocuments "\csp_presets.ini", "Import Preset Bundle", "INI (*.ini)")
    if fn != "" {
        dlg["PresetImportPath"].Value := fn
    }
}

_PresetWizardExecute(dlg, action, checkboxes, result, categories, *) {
    selected := []
    for cat in categories {
        if checkboxes[cat.key].Value
            selected.Push(cat)
    }
    if selected.Length = 0 {
        ShowNotify("Preset Wizard", "No categories selected", "E53935")
        return
    }

    if action = "export"
        _PresetWizardDoExport(selected)
    else
        _PresetWizardDoImport(dlg, selected)

    _PresetWizardGui := 0
    dlg.Destroy()
}

_PresetWizardDoExport(categories) {
    ts := FormatTime(, "yyyyMMdd_HHmmss")
    fn := FileSelect("S16", A_MyDocuments "\csp_presets_" ts ".ini", "Export Preset Bundle", "INI (*.ini)")
    if fn = ""
        return
    try {
        total := 0
        out := "[Bundle]`r`n"
        out .= "created=" FormatTime(, "yyyy-MM-dd HH:mm:ss") "`r`n"
        for cat in categories {
            if !FileExist(cat.file)
                continue
            content := FileRead(cat.file)
            if content = ""
                continue
            encoded := ""
            for i, line in StrSplit(content, "`n", "`r") {
                if i > 1
                    encoded .= "|||"
                encoded .= StrLen(line) "|" line
            }
            out .= cat.key "=" encoded "`r`n"
            total++
        }
        out .= "count=" total "`r`n"
        AtomicFileWrite(fn, out)
        _HK_ResultPopup("Preset Export", "Exported " total " categories to:`n" fn, "4CAF50")
    } catch as e {
        _HK_ResultPopup("Export Error", e.Message, "E53935")
    }
}

_PresetWizardDoImport(dlg, categories) {
    fn := dlg["PresetImportPath"].Value
    if fn = "" || !FileExist(fn) {
        ShowNotify("Preset Wizard", "Select a valid import file", "E53935")
        return
    }
    try {
        total := 0
        for cat in categories {
            encoded := IniRead(fn, "Bundle", cat.key, "")
            if encoded = ""
                continue
            content := ""
            for i, chunk in StrSplit(encoded, "|||") {
                if i > 1
                    content .= "`n"
                if RegExMatch(chunk, "^(\d+)\|(.*)$", &m)
                    content .= m[2]
                else
                    content .= chunk
            }
            if FileExist(cat.file) {
                backupDir := SETTINGS_DIR "\preset_backup"
                if !DirExist(backupDir)
                    DirCreate(backupDir)
                try FileCopy(cat.file, backupDir "\" cat.key "_backup.ini", 1)
            }
            if AtomicFileWrite(cat.file, content)
                total++
        }
        _HK_ResultPopup("Preset Import", "Imported " total " categories. Restart recommended.", "4CAF50")
    } catch as e {
        _HK_ResultPopup("Import Error", e.Message, "E53935")
    }
}
