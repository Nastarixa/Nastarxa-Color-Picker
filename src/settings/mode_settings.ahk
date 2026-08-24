; ============================================================
; Module: src\settings\mode_settings.ahk
; ============================================================
; Per-mode category settings.
;
; System/GUI settings (gui_settings.ini: general settings, positions, colors)
; are GLOBAL — a single shared file that applies to every mode. Only the
; action-oriented categories are per-mode. Each mode gets its own folder under
; the settings folder with one file per per-mode category:
;
;   settings\gui_settings.ini               (global, affects all modes)
;   settings\<mode_id>\pie_settings.ini      (pie items)
;   settings\<mode_id>\hotkey_settings.ini   (hotkeys + mode definitions)
;   settings\<mode_id>\link_settings.ini     (link GUI items)
;   settings\<mode_id>\color_settings.ini    (color GUI items)
;
; Switching to a mode saves the currently active category files, swaps the
; per-mode file pointers to the mode folder, and reloads every category. The
; first time a mode is used its folder is created from a copy of the base
; settings so it starts from the current configuration.

ModeSettingsModeDir(id) {
    global SETTINGS_DIR
    if id = ""
        id := "default"
    return SETTINGS_DIR "\" StrReplace(RegExReplace(id, "[\\/:\*\?`"<>\|]", "_"), " ", "_")
}

; Canonical base-level settings path (the per-mode folders live alongside them).
ModeSettingsBaseFile(name) {
    global SETTINGS_DIR
    return SETTINGS_DIR "\" name
}

ModeSettingsRetarget(modeId) {
    global SETTINGS_DIR, SETTINGS_FILE, PIE_SETTINGS_FILE, HOTKEY_SETTINGS_FILE, LINK_SETTINGS_FILE, COLOR_SETTINGS_FILE, FEATURE_SETTINGS_FILE
    ; System/GUI settings live in one global file that affects all modes, so the
    ; gui pointer never leaves the base settings folder.
    SETTINGS_FILE := SETTINGS_DIR "\gui_settings.ini"
    ; The "default" mode uses the base settings files directly.
    if modeId = "default" {
        PIE_SETTINGS_FILE := SETTINGS_DIR "\pie_settings.ini"
        HOTKEY_SETTINGS_FILE := SETTINGS_DIR "\hotkey_settings.ini"
        LINK_SETTINGS_FILE := SETTINGS_DIR "\link_settings.ini"
        COLOR_SETTINGS_FILE := SETTINGS_DIR "\color_settings.ini"
        FEATURE_SETTINGS_FILE := SETTINGS_DIR "\feature_switches.ini"
        DebugLog("ModeSettingsRetarget -> default (base settings)")
        return
    }
    ; Repoint the per-mode category file globals so every existing Load*/Save*
    ; helper reads and writes inside the requested mode's folder.
    dir := ModeSettingsModeDir(modeId)
    if !DirExist(dir)
        DirCreate(dir)
    PIE_SETTINGS_FILE := dir "\pie_settings.ini"
    HOTKEY_SETTINGS_FILE := dir "\hotkey_settings.ini"
    LINK_SETTINGS_FILE := dir "\link_settings.ini"
    COLOR_SETTINGS_FILE := dir "\color_settings.ini"
    FEATURE_SETTINGS_FILE := SETTINGS_DIR "\feature_switches.ini"
    DebugLog("ModeSettingsRetarget -> " modeId " (" dir ")")
}

; Returns the id of the mode whose per-mode files the globals currently point at.
ModeSettingsActive() {
    global SETTINGS_DIR, HOTKEY_SETTINGS_FILE
    base := SETTINGS_DIR "\"
    if InStr(HOTKEY_SETTINGS_FILE, base, true) = 1 && StrLen(HOTKEY_SETTINGS_FILE) > StrLen(base) {
        rel := SubStr(HOTKEY_SETTINGS_FILE, StrLen(base) + 1)
        slash := InStr(rel, "\")
        if slash
            return SubStr(rel, 1, slash - 1)
    }
    return "default"
}

; Display name of the mode the per-mode settings editors currently target.
ModeSettingsActiveName() {
    global HK_Modes
    id := ModeSettingsActive()
    if id = "default"
        return "Default Mode"
    m := HK_Modes.Get(id, 0)
    if IsObject(m) && Trim(m.Get("name", "")) != ""
        return m.Get("name", id)
    return id
}

; Updates the mode badge shown on any open settings editor GUIs after a mode
; switch/reload so the displayed edit target matches the repointed file globals.
ModeSettingsEditGUIRefresh() {
    global _HK_SettingsGui, _PieOvenGui, _FeatureSwitcherGui
    name := ModeSettingsActiveName()
    try if IsObject(_HK_SettingsGui) && _HK_SettingsGui.HasProp("modeLabel") {
        _HK_SettingsGui.modeLabel.Text := "Mode: " name
        _HK_SettingsGui.Title := "Hotkey Settings - " name
    }
    try if IsObject(_PieOvenGui) && _PieOvenGui.HasProp("modeLabel") {
        _PieOvenGui.modeLabel.Text := "Mode: " name
        _PieOvenGui.Title := "Pie Oven - " name
    }
    try if IsObject(_FeatureSwitcherGui) && _FeatureSwitcherGui.HasProp("modeLabel")
        _FeatureSwitcherGui.modeLabel.Text := "Mode: " name
}

; Stores the currently active category files into their own folder so the mode
; keeps its own snapshot. This is what makes "switch away and come back"
; restore exactly what was configured.
ModeSettingsSaveCurrent() {
    try SaveGUIPositions()            ; commit in-memory GUI positions to SETTINGS_FILE
    try SavePieItems()
    try SaveColorItems()
    try SaveLinkItems()
    try SaveFeatureSwitches()         ; snapshot the mode's feature on/off switches
    try HK_SnapshotModeFlags()        ; keep each mode's forced flags in sync with runtime state
    DebugLog("ModeSettingsSaveCurrent -> snapshot saved for '" ModeSettingsActive() "'")
}

; Loads every category fresh from wherever the globals currently point at.
ModeSettingsLoadCurrent() {
    try LoadFeatureSwitches()
    try LoadConfigurablePaths()
    try LoadLinkItems()
    try LoadColorItems()
    try LoadPieItems()
    try LoadPieQuickHotkeys()
    try LoadGUIPositions()
    try _LoadIBThemeFromIni()
    try _LoadColorHistory()
    try RefreshModeSettingsGUIs()
    ; Apply the loaded mode's feature switches: re-registers the affected
    ; hotkeys, hides any disabled GUIs and refreshes the main state buttons.
    FeatureApplyAll()
    DebugLog("ModeSettingsLoadCurrent -> reloaded from '" ModeSettingsActive() "'")
}

ModeSettingsApplyStartup() {
    ; On boot the file globals start at the base settings; retarget them to the
    ; active mode (from the persisted [Modes] active entry) so every load below
    ; runs against the right files. Re-runs HK_Load only when a non-default
    ; mode is active (HK_Load already ran against the base file just before).
    active := HK_ModeActive()
    DebugLog("ModeSettingsApplyStartup -> active mode is '" active "'")
    ModeSettingsEnsureBuiltInDefaults()
    ModeSettingsEnsureModeFiles(active)
    ModeSettingsRetarget(active)
    if active != "default"
        HK_Load()
    try PieQuickSeedModeDefaults(active)
    ; Seed quick-pie defaults and ensure settings files for all built-in modes,
    ; so first-run starts with the intended presets in every mode.
    modes := ["default", "setup", "tracing", "animate", "painting"]
    for _, modeId in modes {
        if modeId = active
            continue
        ModeSettingsEnsureModeFiles(modeId)
        ModeSettingsRetarget(modeId)
        try PieQuickSeedModeDefaults(modeId)
    }
    ModeSettingsRetarget(active)
    DebugLog("ModeSettingsApplyStartup -> retargeted to '" active "', ensured " modes.Length " mode folders")
    return active
}

; Seeds the built-in modes with their intended first-run hotkey/flag defaults.
; The seed is versioned per mode so user edits are not overwritten on every boot.
ModeSettingsEnsureBuiltInDefaults() {
    DebugLog("ModeSettingsEnsureBuiltInDefaults: checking seed versions...")
    version := "2026-08-23-mode-defaults-13"
    applyBlockVersion := "2026-08-21-apply-block-6"
    frameCelSwapVersion := "2026-08-18-frame-cel-swap-1"
    disabled := ModeSettingsPaintingDisabledHotkeys()
    blocked := ModeSettingsFeatureBlockedHotkeys()
    blocks := ModeSettingsFeatureBlockedHotkeyBlocks()
    ModeSettingsSeedDefaultPaintingIsolation(version, disabled)
    setupPairs := disabled.Clone()
    setupPairs["set_cels_to_track"] := "q"
    setupPairs["feature_kf"] := "1"
    setupPairs["feature_ref"] := "2"
    setupPairs["feature_rm"] := "3"
    ModeSettingsSeedModeHotkeys("setup", version, setupPairs)
    ModeSettingsSeedTracingMode(version, disabled, blocked, blocks)
    ModeSettingsSeedModeHotkeys("animate", version, ModeSettingsMergeHotkeyMaps(disabled, blocked), blocks)
    ModeSettingsSeedPaintingMode(version)
    ModeSettingsSeedApplyBlock("tracing", applyBlockVersion)
    ModeSettingsSeedApplyBlock("animate", applyBlockVersion)
    ModeSettingsSeedApplyBlock("painting", applyBlockVersion)
    ModeSettingsSeedApplyBlockClear(applyBlockVersion, ["default", "setup"])
    ModeSettingsSeedFrameCelSwap("tracing", frameCelSwapVersion)
    ModeSettingsSeedFrameCelSwap("animate", frameCelSwapVersion)
    ModeSettingsSeedFrameCelSwap("painting", frameCelSwapVersion)
    ModeSettingsGenerateDefaultsIni(version, disabled, blocked)
}

; Generates docs/mode_defaults.ini from the same seed data used by the per-mode
; seed functions.  This keeps the Reset Sel / Reset All reference file in sync
; with the actual defaults without manual maintenance.
ModeSettingsGenerateDefaultsIni(version, disabled, blocked) {
    file := A_ScriptDir "\src\docs\mode_defaults.ini"
    out := "; CSP Animator Toolkit — Built-in Mode Default Hotkeys`r`n"
    out .= "; ============================================================`r`n"
    out .= "; AUTO-GENERATED by ModeSettingsGenerateDefaultsIni().`r`n"
    out .= "; Do NOT edit manually — changes are overwritten on next seed.`r`n"
    out .= ";`r`n"
    out .= "; This file is consumed by Reset Sel / Reset All in the Hotkey`r`n"
    out .= "; Settings editor via HK_LoadModeDefaults().`r`n"
    out .= ";`r`n"
    out .= "; Format:  [Mode_<modeId>]`r`n"
    out .= ";          hotkey_id=key_value`r`n"
    out .= ";`r`n"
    out .= "; Only key = '-' means the hotkey is disabled in that mode.`r`n"
    out .= "; An entry missing entirely means the compiled default applies.`r`n"
    out .= "; A blank value is NOT a disabled sentinel — use '-' instead.`r`n"
    out .= ";`r`n"
    out .= "; Seed version: " version "`r`n"
    out .= "`r`n"

    ; --- Default mode ---
    out .= "; ------------------------------------------------------------`r`n"
    out .= "; Default mode`r`n"
    out .= "; Painting hotkeys disabled (paint_*=-).`r`n"
    out .= "; ------------------------------------------------------------`r`n"
    out .= "[Mode_default]`r`n"
    out .= _DefaultsIniPairs(disabled)
    out .= "`r`n"

    ; --- Setup mode ---
    out .= "; ------------------------------------------------------------`r`n"
    out .= "; Setup mode`r`n"
    out .= "; Painting hotkeys disabled.  Features mapped to 1-3; set_cels_to_track = Q.`r`n"
    out .= "; ------------------------------------------------------------`r`n"
    out .= "[Mode_setup]`r`n"
    setupPairs := disabled.Clone()
    setupPairs["set_cels_to_track"] := "q"
    setupPairs["feature_kf"] := "1"
    setupPairs["feature_ref"] := "2"
    setupPairs["feature_rm"] := "3"
    out .= _DefaultsIniPairs(setupPairs)
    out .= "`r`n"

    ; --- Tracing mode ---
    out .= "; ------------------------------------------------------------`r`n"
    out .= "; Tracing mode`r`n"
    out .= "; Painting hotkeys disabled.  toggle_lt = Alt+W (pipe Ctrl+Alt+W).`r`n"
    out .= "; toggle_onion disabled.  A/D select cels; Alt+A/Alt+D move frames.`r`n"
    out .= "; ------------------------------------------------------------`r`n"
    out .= "[Mode_tracing]`r`n"
    tracingPairs := ModeSettingsMergeHotkeyMaps(disabled, blocked)
    tracingPairs["toggle_lt"] := "!w|^!w"
    tracingPairs["toggle_onion"] := "-"
    tracingPairs["select_prev_cel"] := "a"
    tracingPairs["select_next_cel"] := "d"
    tracingPairs["prev_frame"] := "$!a"
    tracingPairs["next_frame"] := "$!d"
    out .= _DefaultsIniPairs(tracingPairs)
    out .= "`r`n"

    ; --- Animate mode ---
    out .= "; ------------------------------------------------------------`r`n"
    out .= "; Animate mode`r`n"
    out .= "; Painting hotkeys disabled.  A/D select cels; Alt+A/Alt+D move frames.`r`n"
    out .= "; ------------------------------------------------------------`r`n"
    out .= "[Mode_animate]`r`n"
    animatePairs := ModeSettingsMergeHotkeyMaps(disabled, blocked)
    animatePairs["select_prev_cel"] := "a"
    animatePairs["select_next_cel"] := "d"
    animatePairs["prev_frame"] := "$!a"
    animatePairs["next_frame"] := "$!d"
    out .= _DefaultsIniPairs(animatePairs)
    out .= "`r`n"

    ; --- Painting mode ---
    out .= "; ------------------------------------------------------------`r`n"
    out .= "; Painting mode`r`n"
    out .= "; Painting hotkeys active with number-key bindings.  A/D swapped.`r`n"
    out .= "; ------------------------------------------------------------`r`n"
    out .= "[Mode_painting]`r`n"
    paintingPairs := Map(
        "paint_red", "1",
        "paint_green", "2",
        "paint_blue", "3",
        "paint_pink", "4",
        "paint_cyan", "5",
        "paint_orange", "6",
        "paint_purple", "7",
        "set_to_paint_anim", "q",
        "create_6", "y",
        "paint_checker_single", "e",
        "paint_checker_image", "r",
        "delete_paint_checker", "t",
        "layer_9", "s",
        "feature_paper_white", "+1",
        "feature_paper_purple", "+2",
        "feature_paper_green", "+3",
        "ref_layer", "w",
        "layer_1", "-",
        "layer_2", "-",
        "layer_3", "-",
        "select_prev_cel", "a",
        "select_next_cel", "d",
        "prev_frame", "$!a",
        "next_frame", "$!d")
    out .= _DefaultsIniPairs(paintingPairs)
    out .= "`r`n"

    try AtomicFileWrite(file, out)
    DebugLog("Generated mode_defaults.ini from seed data")
}

_DefaultsIniPairs(pairs) {
    out := ""
    for id, key in pairs
        out .= id "=" key "`r`n"
    return out
}

; Formerly blocked Ctrl+Shift+1-3 here; those keys now live in Apply Block.
ModeSettingsFeatureBlockedHotkeys() {
    return Map()
}

; Block flags formerly matched the disabled feature hotkeys above.
ModeSettingsFeatureBlockedHotkeyBlocks() {
    return Map()
}

; Returns the complete set of default Apply Block keys for a given mode.
; Each mode is independent — no grouped functions. Add new modes here.
; Any mode not listed gets the base block only (baseKeys).
; User-created modes get baseKeys automatically; they can add more via the editor.
ModeSettingsApplyBlockForMode(modeId) {
    baseKeys := Map(
        "^SC029", "target", "^2", "target", "^3", "target",
        "^4", "target", "^5", "target", "^6", "target",
        "^7", "target", "^8", "target", "^9", "target",
        "^0", "target", "^+1", "target", "^+2", "target",
        "^+3", "target")
    extraKeys := Map(
        "painting",  Map("!+w", "target"))
    if extraKeys.Has(modeId) {
        for k, v in extraKeys[modeId]
            baseKeys[k] := v
    }
    return baseKeys
}

; Seeds the [ApplyBlock] section in a mode's hotkey_settings.ini so the
; editor shows the default blocked keys on first open.
ModeSettingsSeedApplyBlock(modeId, version) {
    dir := ModeSettingsModeDir(modeId)
    if !DirExist(dir)
        ModeSettingsCopyBaseTo(modeId)
    hot := dir "\hotkey_settings.ini"
    if !FileExist(hot)
        ModeSettingsCopyBaseTo(modeId)
    try current := IniRead(hot, "ApplyBlockVersion", "Version", "")
    catch
        current := ""
    if current = version
        return
    defaults := ModeSettingsApplyBlockForMode(modeId)
    try IniDelete(hot, "ApplyBlock")
    try {
        for keyName, scope in defaults
            IniWrite(scope, hot, "ApplyBlock", keyName)
        IniWrite(version, hot, "ApplyBlockVersion", "Version")
    }
    DebugLog("Seeded " modeId " mode apply block defaults")
}

ModeSettingsSeedApplyBlockClear(version, modeIds) {
    global SETTINGS_DIR
    for modeId in modeIds {
        if modeId = "default"
            hot := SETTINGS_DIR "\hotkey_settings.ini"
        else {
            dir := ModeSettingsModeDir(modeId)
            if !DirExist(dir)
                continue
            hot := dir "\hotkey_settings.ini"
        }
        if !FileExist(hot)
            continue
        try current := IniRead(hot, "ApplyBlockVersion", "Version", "")
        catch
            current := ""
        if current = version
            continue
        try IniDelete(hot, "ApplyBlock")
        try IniDelete(hot, "ApplyBlockVersion")
        try IniWrite(version, hot, "ApplyBlockVersion", "Version")
    }
}

; In animate/tracing modes, swap A/D with Alt+A/Alt+D so bare keys
; select cels (sending Alt+A/D) and Alt keys move frames (sending A/D).
ModeSettingsSeedFrameCelSwap(modeId, version) {
    dir := ModeSettingsModeDir(modeId)
    if !DirExist(dir)
        ModeSettingsCopyBaseTo(modeId)
    hot := dir "\hotkey_settings.ini"
    if !FileExist(hot)
        ModeSettingsCopyBaseTo(modeId)
    try current := IniRead(hot, "FrameCelSwap", "Version", "")
    catch
        current := ""
    if current = version
        return
    pairs := Map(
        "select_prev_cel", "a",
        "select_next_cel", "d",
        "prev_frame", "$!a",
        "next_frame", "$!d")
    for id, key in pairs
        IniWrite(StrLower(key), hot, "Hotkeys", id)
    IniWrite(version, hot, "FrameCelSwap", "Version")
    DebugLog("Seeded " modeId " mode frame/cel swap")
}

ModeSettingsMergeHotkeyMaps(a, b) {
    merged := Map()
    for k, v in a
        merged[k] := v
    for k, v in b
        merged[k] := v
    return merged
}

; The painting hotkeys are Painting-mode only: a "-" (disabled) binding in every
; non-painting mode keeps them from firing while another mode is active. The
; shared base file covers Default mode and is the template new modes are copied
; from, so it is seeded once here too.
ModeSettingsPaintingDisabledHotkeys() {
    return Map(
        "paint_red", "-",
        "paint_green", "-",
        "paint_blue", "-",
        "paint_pink", "-",
        "paint_cyan", "-",
        "paint_orange", "-",
        "paint_purple", "-",
        "set_to_paint_anim", "-",
        "paint_checker_single", "-",
        "paint_checker_image", "-",
        "delete_paint_checker", "-",
        "create_6", "-",
        "layer_9", "-")
}

ModeSettingsSeedDefaultPaintingIsolation(version, pairs) {
    hot := ModeSettingsBaseFile("hotkey_settings.ini")
    if !FileExist(hot)
        return
    try current := IniRead(hot, "ModeDefaults", "Version", "")
    catch
        current := ""
    if current = version
        return
    for id, key in pairs
        IniWrite(StrLower(key), hot, "Hotkeys", id)
    IniWrite(version, hot, "ModeDefaults", "Version")
    DebugLog("Seeded painting hotkey isolation into Default mode")
}

ModeSettingsSeedModeHotkeys(modeId, version, pairs, blocks := Map()) {
    dir := ModeSettingsModeDir(modeId)
    if !DirExist(dir)
        ModeSettingsCopyBaseTo(modeId)
    hot := dir "\hotkey_settings.ini"
    if !FileExist(hot)
        ModeSettingsCopyBaseTo(modeId)
    try current := IniRead(hot, "ModeDefaults", "Version", "")
    catch
        current := ""
    if current = version
        return
    for id, key in pairs
        IniWrite(StrLower(key), hot, "Hotkeys", id)
    for id, on in blocks
        IniWrite(on ? 1 : 0, hot, "HotkeyBlock", id)
    IniWrite(version, hot, "ModeDefaults", "Version")
    DebugLog("Seeded " modeId " mode hotkey defaults")
}

ModeSettingsSeedTracingMode(version, disabled, blocked, blocks := Map()) {
    dir := ModeSettingsModeDir("tracing")
    if !DirExist(dir)
        ModeSettingsCopyBaseTo("tracing")
    flagFile := dir "\mode_flags.ini"
    try current := IniRead(flagFile, "ModeDefaults", "Version", "")
    catch
        current := ""
    if current != version {
        IniWrite(1, flagFile, "Flags", "ltLock")
        IniWrite(version, flagFile, "ModeDefaults", "Version")
        DebugLog("Seeded tracing mode LT Lock flag")
    }
    pairs := ModeSettingsMergeHotkeyMaps(disabled, blocked)
    pairs["toggle_lt"] := "!w|^!w"
    pairs["toggle_onion"] := "-"
    ModeSettingsSeedModeHotkeys("tracing", version, pairs, blocks)
}

ModeSettingsSeedPaintingMode(version) {
    ModeSettingsSeedModeHotkeys("painting", version, Map(
        "paint_red", "1",
        "paint_green", "2",
        "paint_blue", "3",
        "paint_pink", "4",
        "paint_cyan", "5",
        "paint_orange", "6",
        "paint_purple", "7",
        "set_to_paint_anim", "q",
        "create_6", "y",
        "paint_checker_single", "e",
        "paint_checker_image", "r",
        "delete_paint_checker", "t",
        "layer_9", "s",
        "feature_paper_white", "+1",
        "feature_paper_purple", "+2",
        "feature_paper_green", "+3",
        "ref_layer", "w",
        "layer_1", "-",
        "layer_2", "-",
        "layer_3", "-"))
}

; Ensures a mode folder has all required settings files, copying from base
; any that are missing. Works even when the folder already exists but individual
; files were deleted or never created.
ModeSettingsEnsureModeFiles(modeId) {
    global SETTINGS_DIR
    if modeId = "default"
        return
    dir := ModeSettingsModeDir(modeId)
    if !DirExist(dir)
        DirCreate(dir)
    pairs := Map(
        SETTINGS_DIR "\pie_settings.ini", "pie_settings.ini",
        SETTINGS_DIR "\hotkey_settings.ini", "hotkey_settings.ini",
        SETTINGS_DIR "\link_settings.ini", "link_settings.ini",
        SETTINGS_DIR "\color_settings.ini", "color_settings.ini",
        SETTINGS_DIR "\feature_switches.ini", "feature_switches.ini")
    missing := []
    for src, name in pairs {
        dest := dir "\" name
        if !FileExist(dest) && FileExist(src) {
            FileCopy(src, dest, 1)
            missing.Push(name)
        }
    }
    if missing.Length
        DebugLog("ModeSettingsEnsureModeFiles: restored " missing.Length " file(s) for '" modeId "': " JoinTextList(missing, ", "))
}

; Copies the base settings files into the mode folder so a fresh mode starts
; from the current configuration. Each category is its own file.
ModeSettingsCopyBaseTo(modeId) {
    global SETTINGS_DIR
    if modeId = "default"
        return
    dir := ModeSettingsModeDir(modeId)
    if !DirExist(dir)
        DirCreate(dir)
    pairs := Map(
        SETTINGS_DIR "\pie_settings.ini", "pie_settings.ini",
        SETTINGS_DIR "\hotkey_settings.ini", "hotkey_settings.ini",
        SETTINGS_DIR "\link_settings.ini", "link_settings.ini",
        SETTINGS_DIR "\color_settings.ini", "color_settings.ini",
        SETTINGS_DIR "\feature_switches.ini", "feature_switches.ini")
    for src, name in pairs {
        if FileExist(src)
            FileCopy(src, dir "\" name, 1)
    }
}

; Switches the active category files to the given mode and reloads everything.
; If the mode has no folder yet, it starts from a copy of the base settings.
ModeSettingsSwitchTo(modeId) {
    active := ModeSettingsActive()
    if modeId = active {
        DebugLog("ModeSettingsSwitchTo -> already on '" active "', nothing to do")
        return
    }
    ModeSettingsSaveCurrent()
    ModeSettingsEnsureModeFiles(modeId)
    ModeSettingsRetarget(modeId)
    try SettingsSyncIniWatcher()
    try PieQuickSeedModeDefaults(modeId)
    ModeSettingsLoadCurrent()
    modeColor := ""
    try modeColor := HK_Modes[modeId].Get("color", "")
    ShowNotify("Mode", "Mode settings applied for '" modeId "'", modeColor != "" ? "0x" modeColor : "6D28D9")
}

; Deletes a mode's settings folder. If the mode is currently active the file
; globals are retargeted back to the base settings first so nothing points into
; the removed folder. The hotkey subsystem (HK_DeleteMode) switches the active
; mode before calling this, so this retarget is a defensive fallback only.
ModeSettingsDelete(id) {
    if id = "default"
        return
    if ModeSettingsActive() = id {
        try ModeSettingsSaveCurrent()
        ModeSettingsRetarget("default")
        try SettingsSyncIniWatcher()
        try ModeSettingsLoadCurrent()
    }
    dir := ModeSettingsModeDir(id)
    if DirExist(dir) {
        try DirDelete(dir, true)
        catch as err
            DebugLog("ModeSettingsDelete: failed to remove " dir ": " err.Message)
    }
    DebugLog("ModeSettingsDelete -> removed settings for '" id "'")
}

; Refresh every settings-driven GUI so the newly loaded category files are
; reflected. Each helper is independently guarded since some GUIs may not have
; been created yet.
RefreshModeSettingsGUIs() {
    try RebuildLinkGUI()
    try _RebuildColorGui()
    try UpdateMainModeButton()
    try UpdateIBModeIndicator()
    try RebuildIBFromTheme()
    try ModeSettingsEditGUIRefresh()
}

; ============================================================
; Mode bundle export / import
; ============================================================
; A mode bundle is a portable folder carrying one mode's category INI files
; plus a manifest.ini describing the mode identity/definition. It is the
; per-mode equivalent of the old full Settings Export Bundle.

ModeBundleExportRoot() {
    return A_MyDocuments "\Nastarxa_CSP_Mode_Bundles"
}

ModeBundleManifestPath(dir) {
    return dir "\manifest.ini"
}

; Renders the manifest body from a key/value map.
ModeBundleManifestText(meta) {
    s := "[meta]`n"
    for k, v in meta
        s .= k "=" v "`n"
    return s
}

; Reads manifest.ini from a bundle folder into a map (missing keys become "").
ModeBundleReadManifest(src) {
    meta := Map()
    if FileExist(ModeBundleManifestPath(src)) {
        for key in ["type", "mode_id", "mode_name", "mode_switch", "version", "config_version", "exported", "files"]
            meta[key] := IniRead(ModeBundleManifestPath(src), "meta", key, "")
    }
    return meta
}

; Picks a mode to export with a dropdown dialog. Returns the mode id or "".
ModeBundlePickExportMode() {
    global HK_Modes, HK_ModeOrder, _ShowAdvancedModes
    showAdvanced := !!_ShowAdvancedModes
    options := []
    ids := []
    BuildExportOptions() {
        options := []
        ids := []
        for id in HK_ModeOrder {
            if id = "default" || !HK_Modes.Has(id)
                continue
            if !HK_ShowModeInPicker(id, showAdvanced, "")
                continue
            options.Push(id " (" HK_Modes[id].Get("name", id) ")")
            ids.Push(id)
        }
    }
    BuildExportOptions()
    if options.Length = 0 {
        _HK_ResultPopup("Export Mode Bundle", "Create a mode first, then export it.`n`nThe default mode uses the shared base settings and is not exported as a bundle.", "FF9800")
        return ""
    }
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Export Mode Bundle")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)
    dlg.AddText("xm cFFD54F", "Choose a mode to export")
    dlg.AddText("xm y+4 w" S(360) " cAAAAAA", "The mode's category settings and definition are saved to a portable bundle folder.")
    ddl := dlg.AddDropDownList("xm y+8 w" S(360) " Choose1", options)
    chkAdv := dlg.AddCheckbox("xm y+6 +Background1E1F22 cAAAAAA", "Show advanced (built-in) modes")
    chkAdv.SetFont("s" S(7) " cAAAAAA", "Segoe UI")
    chkAdv.OnEvent("Click", (*) => (
        showAdvanced := !showAdvanced,
        _ShowAdvancedModes := showAdvanced,
        HK_SaveShowAdvancedModesState(),
        BuildExportOptions(),
        ddl.Delete(),
        options.Length > 0 ? (ddl.Add(options), ddl.Choose(1)) : 0
    ))
    result := false
    selIdx := 0
    dlg.AddButton("xm y+10 w" S(88) " h" S(26) " cFFFFFF Default", "Export").OnEvent("Click", (*) => (selIdx := ddl.Value, result := true, dlg.Destroy()))
    dlg.AddButton("x+8 yp w" S(88) " h" S(26), "Cancel").OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("AutoSize")
    GuiWaitForCloseSafe(dlg)
    if !result || selIdx = 0
        return ""
    return ids[selIdx]
}

; Exports one mode as a mode bundle folder. When modeId is empty a picker is
; shown. Returns the created bundle folder or "" on failure/cancel.
ModeSettingsExportBundle(modeId := "") {
    global HK_Modes, SCRIPT_VERSION, CONFIG_VERSION
    if modeId = ""
        modeId := ModeBundlePickExportMode()
    if modeId = "" || modeId = "default"
        return ""
    try {
        dir := ModeSettingsModeDir(modeId)
        if !DirExist(dir)
            ModeSettingsCopyBaseTo(modeId)
        exportRoot := ModeBundleExportRoot()
        if !DirExist(exportRoot)
            DirCreate(exportRoot)
        ts := FormatTime(, "yyyyMMdd_HHmmss")
        dest := exportRoot "\mode_" StrReplace(modeId, " ", "_") "_" ts
        if DirExist(dest)
            DirDelete(dest, true)
        DirCreate(dest)

        copied := 0
        for name in ["pie_settings.ini", "hotkey_settings.ini", "link_settings.ini", "color_settings.ini", "mode_flags.ini", "feature_switches.ini"] {
            p := dir "\" name
            if FileExist(p) {
                FileCopy(p, dest "\" name, 1)
                copied++
            }
        }
        if copied = 0
            throw Error("No settings files found for mode '" modeId "'")

        m := 0
        try m := HK_Modes.Get(modeId, 0)
        mName := IsObject(m) ? m.Get("name", modeId) : modeId
        mSwitch := IsObject(m) ? m.Get("switch", "") : ""
        meta := Map(
            "type", "mode_bundle",
            "mode_id", modeId,
            "mode_name", mName,
            "mode_switch", mSwitch,
            "version", SCRIPT_VERSION,
            "config_version", CONFIG_VERSION,
            "exported", FormatTime(, "yyyy-MM-dd HH:mm:ss"),
            "files", copied)
        FileAppend(ModeBundleManifestText(meta), ModeBundleManifestPath(dest), "UTF-8-RAW")

        DebugLog("Mode bundle exported to " dest " (" copied " ini files)")
        _HK_ResultPopup("Export Mode Bundle", "Mode '" mName "' exported:`n" dest, "4CAF50")
        return dest
    } catch as e {
        DebugLog("Mode bundle export failed: " e.Message)
        _HK_ResultPopup("Export Mode Bundle Error", "Export failed: " e.Message, "E53935")
        return ""
    }
}

; Parses a "[Mode_<id>]" section body into a definition map.
ModeBundleParseModeSection(sectionText) {
    return HK_ParseModeSectionText(sectionText)
}

; Copies the bundle's INI files into the target mode folder and rewrites the
; mode definition inside the copied hotkey file so it matches the target id.
; Returns the copied hotkey file path.
ModeBundleApplyFiles(src, dir, targetId, srcId, srcName, srcSwitch) {
    iniFiles := []
    Loop Files src "\*.ini", "F" {
        if A_LoopFileName = "manifest.ini"
            continue
        iniFiles.Push(A_LoopFileFullPath)
    }
    if iniFiles.Length = 0
        throw Error("No INI settings files found in: " src)
    if !DirExist(dir)
        DirCreate(dir)
    copied := 0
    for fn in iniFiles {
        SplitPath fn, &fileName
        FileCopy(fn, dir "\" fileName, 1)
        copied++
    }
    ; gui_settings.ini is global (shared by all modes), so a mode folder must
    ; never hold a copy — drop one even if an older bundle carried it.
    try FileDelete(dir "\gui_settings.ini")
    hot := dir "\hotkey_settings.ini"
    if FileExist(hot) && targetId != srcId {
        ; transplant the source mode's definition onto the new id
        section := ""
        try section := IniRead(hot, "Mode_" srcId)
        catch
            section := ""
        def := ModeBundleParseModeSection(section)
        IniDelete(hot, "Mode_" srcId)
        IniDelete(hot, "Mode_" targetId)
        IniWrite(def.Get("name", "") != "" ? def["name"] : srcName, hot, "Mode_" targetId, "name")
        sw := def.Get("switch", "")
        if sw = "" && srcSwitch != ""
            sw := srcSwitch
        if sw != ""
            IniWrite(sw, hot, "Mode_" targetId, "switch")
    }
    return [hot, copied]
}

; Shows the import target dialog. Returns [targetId, isNew] or ["", false].
ModeBundlePickImportTarget(src, srcId, srcName) {
    global HK_Modes, HK_ModeOrder
    options := []
    ids := []
    ; prefer the bundle's own mode id as the first choice when it exists locally
    if srcId != "" && HK_Modes.Has(srcId) {
        options.Push("Import into '" srcId "' (" HK_Modes[srcId].Get("name", srcId) ")")
        ids.Push(srcId)
    }
    for id in HK_ModeOrder {
        if !HK_Modes.Has(id) || id = "default" || (srcId != "" && id = srcId)
            continue
        options.Push("Overwrite '" id "' (" HK_Modes[id].Get("name", id) ")")
        ids.Push(id)
    }
    if srcId != "" && !HK_Modes.Has(srcId) {
        options.Push("New: '" srcId "' (" srcName ") from bundle")
        ids.Push(srcId)
    }
    options.Push("New mode (auto id)...")
    ids.Push("")

    dlg := Gui("+AlwaysOnTop +ToolWindow", "Import Mode Bundle")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)
    dlg.AddText("xm cFFD54F", "Import mode bundle from:`n" src)
    if srcId != ""
        dlg.AddText("xm y+4 w" S(420) " cAAAAAA", "Bundle contains mode '" srcId "' (" srcName "). Choose where to import it.")
    dlg.AddText("xm y+4 w" S(420) " c888888", "Importing overwrites the target mode's folder. A settings backup is created first.")
    ddl := dlg.AddDropDownList("xm y+8 w" S(420) " Choose1", options)
    result := false
    selIdx := 0
    dlg.AddButton("xm y+10 w" S(88) " h" S(26) " cFFFFFF Default", "Import").OnEvent("Click", (*) => (selIdx := ddl.Value, result := true, dlg.Destroy()))
    dlg.AddButton("x+8 yp w" S(88) " h" S(26), "Cancel").OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("AutoSize")
    GuiWaitForCloseSafe(dlg)
    if !result || selIdx = 0
        return ["", false]
    return [ids[selIdx], ids[selIdx] = ""]
}

; Imports a mode bundle folder. When src is empty a folder picker is shown.
; When targetId is given the target dialog is skipped and the bundle is
; imported directly into that mode (created with a fresh id if empty).
; Returns the target mode id or "" on failure/cancel.
ModeSettingsImportBundle(src := "", targetId := "") {
    global SETTINGS_DIR, HK_Modes, HK_ModeOrder, CONFIG_VERSION
    try {
        if src = "" {
            src := DirSelect(A_MyDocuments, 3, "Select Mode Bundle folder")
            if src = ""
                return ""
        }
        if !DirExist(src) {
            _HK_ResultPopup("Import Mode Bundle Error", "Folder not found:`n" src, "E53935")
            return ""
        }
        meta := ModeBundleReadManifest(src)
        srcId := meta.Get("mode_id", "")
        srcName := meta.Get("mode_name", srcId != "" ? srcId : "mode")
        srcSwitch := meta.Get("mode_switch", "")

        if meta.Get("type", "") != "mode_bundle" {
            _HK_ResultPopup("Import Mode Bundle Error", "This folder is not a mode bundle (manifest.ini is missing 'type=mode_bundle').", "E53935")
            return ""
        }

        ; A bundle created by a newer version may use a settings layout this
        ; version does not understand — warn instead of silently importing it.
        cfgVer := meta.Get("config_version", "")
        if cfgVer != "" {
            cfgNum := 0
            try cfgNum := Integer(cfgVer)
            catch
                cfgNum := 0
            if cfgNum > CONFIG_VERSION {
                _HK_ResultPopup("Import Mode Bundle Warning", "This bundle was exported by a newer version of the toolkit (config v" cfgVer ", current v" CONFIG_VERSION ").`nImporting it could produce broken settings. Import cancelled.", "FF9800")
                DebugLog("Mode bundle import rejected: bundle config v" cfgVer " > current v" CONFIG_VERSION)
                return ""
            }
        }

        ; The default mode uses the shared base settings; importing a bundle as
        ; "default" would write into a dead folder and clobber the definition.
        if srcId = "default" {
            _HK_ResultPopup("Import Mode Bundle Error", "This bundle contains the default mode, which uses the shared base settings and cannot be imported as a mode bundle.", "E53935")
            return ""
        }
        if targetId = "default" {
            DebugLog("Mode bundle import into 'default' is not allowed")
            return ""
        }

        if targetId = "" {
            pick := ModeBundlePickImportTarget(src, srcId, srcName)
            targetId := pick[1]
            if targetId = "" && !pick[2]
                return ""
            if pick[2]
                targetId := HK_NextModeId()
        }

        CreateConfigBackup("before_mode_bundle_import", false)
        dir := ModeSettingsModeDir(targetId)
        applied := ModeBundleApplyFiles(src, dir, targetId, srcId, srcName, srcSwitch)
        hot := applied[1]
        copied := applied[2]

        ; never let an import force the app into the imported mode
        if FileExist(hot)
            IniWrite(HK_ModeActive(), hot, "Modes", "active")

        ; register the mode definition in memory (name/switch)
        def := Map("name", srcName, "switch", srcSwitch, "overrides", Map(), "color", "")
        if FileExist(hot) {
            section := ""
            try section := IniRead(hot, "Mode_" targetId)
            catch
                section := ""
            parsed := ModeBundleParseModeSection(section)
            if parsed["name"] != ""
                def["name"] := parsed["name"]
            if parsed["switch"] != ""
                def["switch"] := parsed["switch"]
        }
        HK_Modes[targetId] := def
        inOrder := false
        for mid in HK_ModeOrder {
            if mid = targetId {
                inOrder := true
                break
            }
        }
        if !inOrder
            HK_ModeOrder.Push(targetId)
        HK_SaveModes()
        HK_ReapplyAll()
        ; the import may have replaced the active mode's flag file; re-apply so
        ; the live runtime toggles match what the imported mode now forces.
        HK_ApplyModeFlags(HK_ModeActive())

        ; keep the base hotkey file aware of the mode so it survives a restart
        baseHot := ModeSettingsBaseFile("hotkey_settings.ini")
        if FileExist(baseHot) {
            order := ""
            try order := IniRead(baseHot, "Modes", "order", "")
            catch
                order := ""
            found := false
            for mid in StrSplit(order, ",") {
                if Trim(mid) = targetId {
                    found := true
                    break
                }
            }
            if !found
                IniWrite((Trim(order) != "" ? Trim(order) "," : "") targetId, baseHot, "Modes", "order")
            IniDelete(baseHot, "Mode_" targetId)
            IniWrite(def["name"], baseHot, "Mode_" targetId, "name")
            if def["switch"] != ""
                IniWrite(def["switch"], baseHot, "Mode_" targetId, "switch")
        }
        SettingsSyncIniWatcher()

        ; If the bundle was imported over the mode that is currently active,
        ; reload the live settings so the GUI matches the new files and a later
        ; switch away does not overwrite the import with stale state.
        if targetId = HK_ModeActive()
            ModeSettingsLoadCurrent()

        DebugLog("Mode bundle imported into '" targetId "' from " src " (" copied " ini files)")
        _HK_ResultPopup("Import Mode Bundle", "Mode '" def["name"] "' imported as '" targetId "'.`nUse the mode switch to activate it.", "4CAF50")
        return targetId
    } catch as e {
        DebugLog("Mode bundle import failed: " e.Message)
        _HK_ResultPopup("Import Mode Bundle Error", "Import failed: " e.Message, "E53935")
        return ""
    }
}
