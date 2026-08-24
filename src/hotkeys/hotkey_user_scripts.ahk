; USER SCRIPT MANAGER
; ============================================================
; user_hotkey_scripts/ write, run, and read helpers + HK_UserDefs load/save.
; Extracted from hotkey_core.ahk.

global HK_UserScriptWrapperCache := Map()

HK_UserScriptPath(fnName) {
    global HK_UserScriptDir
    return HK_UserScriptDir "\" HK_SanitizeFnName(fnName) ".ahk"
}

HK_RunUserScript(id, *) {
    if !FeatureEnabled("userscript") {
        DebugLog("User script " id " blocked: User Scripts feature is off")
        return
    }
    d := HK_FindDef(id)
    if !IsObject(d)
        return ShowNotify("Hotkey", "Missing user hotkey")
    if d.HasOwnProp("scriptEnabled") && !d.scriptEnabled {
        fn := HK_FnForName(d.fnName)
        if !IsObject(fn)
            return ShowNotify("Hotkey", "Function " d.fnName " not loaded")
        try {
            fn.Call()
            return
        } catch as e {
            DebugLog("User script function failed " d.fnName " - " e.Message)
            return ShowNotify("Hotkey", "Function " d.fnName " failed: " e.Message)
        }
    }
    if !d.HasOwnProp("scriptFile") || d.scriptFile = ""
        return ShowNotify("Hotkey", "Missing user script")
    if HK_UserScriptDisabled(d.scriptFile)
        return ShowNotify("Hotkey", "Script disabled: " HK_UserScriptName(d.scriptFile))
    if !FileExist(d.scriptFile)
        return ShowNotify("Hotkey", "Script file not found")
    try wrapperPath := HK_EnsureUserScriptWrapper(d)
    catch as e {
        DebugLog("User script wrapper failed " d.fnName " - " e.Message)
        return ShowNotify("Hotkey", "Script wrapper failed: " e.Message)
    }
    Run('"' A_AhkPath '" "' wrapperPath '"')
}

HK_EnsureUserScriptWrapper(d) {
    global HK_UserScriptWrapperCache
    fnName := HK_SanitizeFnName(d.fnName)
    scriptFile := d.scriptFile
    stamp := FileGetTime(scriptFile, "M")
    size := FileGetSize(scriptFile)
    cacheKey := fnName "|" scriptFile "|" stamp "|" size
    if HK_UserScriptWrapperCache.Has(cacheKey) && FileExist(HK_UserScriptWrapperCache[cacheKey])
        return HK_UserScriptWrapperCache[cacheKey]

    wrapperPath := A_Temp "\csp_user_" fnName "_" stamp "_" size ".ahk"
    if !FileExist(wrapperPath) {
        wrapperBody := "#Requires AutoHotkey v2.0`n"
            . "#SingleInstance Off`n"
            . "#NoTrayIcon`n"
            . '#Include "' A_ScriptDir '\src\includes\user_script_helpers.ahk"`n'
            . '#Include "' scriptFile '"`n'
            . fnName '()'
            . "`nSleep(1500)"
        try FileAppend(wrapperBody, wrapperPath, "UTF-8")
    }
    HK_CleanupUserScriptWrappers(fnName, wrapperPath)
    HK_UserScriptWrapperCache[cacheKey] := wrapperPath
    return wrapperPath
}

HK_RunUserScriptGUI(scriptFile, fnName := "") {
    if scriptFile = "" || !FileExist(scriptFile)
        return ShowNotify("User Script", "Script file not found")
    if HK_UserScriptDisabled(scriptFile)
        return ShowNotify("User Script", "Script disabled: " HK_UserScriptName(scriptFile))
    try body := FileRead(scriptFile, "UTF-8")
    catch
        return ShowNotify("User Script", "Failed to read script file")
    target := ""
    safeName := HK_SanitizeFnName(fnName)
    if safeName != "" && RegExMatch(body, "m)^[\t ]*" safeName "\s*\(")
        target := safeName
    if target = "" {
        guiFn := ""
        fnPos := 1
        while (fnPos := RegExMatch(body, "m)^[\t ]*([A-Za-z_]\w*)\s*\(.*?\)\s*(\{|=>)", &m, fnPos)) {
            if m[1] = safeName "_GUI" {
                guiFn := m[1]
                break
            }
            fnPos := m.Pos + m.Len
        }
        if guiFn = "" && RegExMatch(body, "m)^[\t ]*([A-Za-z_]\w*_GUI)\s*\(", &m)
            guiFn := m[1]
        if guiFn = "" {
            hint := safeName != "" ? "No GUI entry point found. Add '" safeName "_GUI()' or map this script to a GUI function in hotkey settings." : "No GUI entry point found. Map this script to a function that shows its GUI in hotkey settings."
            return ShowNotify("User Script", hint)
        }
        target := guiFn
    }
    wrapperPath := A_Temp "\csp_user_" safeName "_gui.ahk"
    wrapperBody := "#Requires AutoHotkey v2.0`n"
        . "#SingleInstance Off`n"
        . "#NoTrayIcon`n"
        . '#Include "' A_ScriptDir '\src\includes\user_script_helpers.ahk"`n'
        . '#Include "' scriptFile '"`n'
        . target '()'
    if FileExist(wrapperPath)
        try FileDelete(wrapperPath)
    try FileAppend(wrapperBody, wrapperPath, "UTF-8")
    try Run('"' A_AhkPath '" "' wrapperPath '"')
}

HK_CleanupUserScriptWrappers(fnName, keepPath := "") {
    global HK_UserScriptWrapperCache
    fnName := HK_SanitizeFnName(fnName)
    staleKeys := []
    for cacheKey, wrapperPath in HK_UserScriptWrapperCache {
        if InStr(wrapperPath, "\csp_user_" fnName "_")
            staleKeys.Push(cacheKey)
    }
    for _, cacheKey in staleKeys
        try HK_UserScriptWrapperCache.Delete(cacheKey)
    try {
        Loop Files A_Temp "\csp_user_" fnName "_*.ahk", "F" {
            if keepPath != "" && A_LoopFileFullPath = keepPath
                continue
            try FileDelete(A_LoopFileFullPath)
        }
    }
}

HK_WriteUserScript(fnName, body) {
    global HK_UserScriptDir
    fnName := HK_SanitizeFnName(fnName)
    if !DirExist(HK_UserScriptDir)
        try DirCreate(HK_UserScriptDir)
    path := HK_UserScriptPath(fnName)
    script := "#Requires AutoHotkey v2.0`n#SingleInstance Off`n#NoTrayIcon`n; User hotkey script: " fnName "`n`n" body "`n"
    if FileExist(path)
        try FileDelete(path)
    try FileAppend(script, path, "UTF-8")
    HK_CleanupUserScriptWrappers(fnName)
    return path
}

HK_ReadUserScriptBody(path, fnName := "") {
    if path = "" || !FileExist(path)
        return ""
    try txt := FileRead(path, "UTF-8")
    catch
        return ""
    lines := StrSplit(txt, "`n", "`r")
    body := ""
    for line in lines {
        if line ~= "i)^#Requires|^#SingleInstance|^#NoTrayIcon|^; User hotkey script:"
            continue
        body .= (body = "" ? "" : "`n") line
    }
    return Trim(body, "`n`r")
}

HK_UserScriptRequirement(path) {
    if path = "" || !FileExist(path)
        return ""
    meta := HK_UserScriptMetadata(path)
    if meta.Has("requirement") && Trim(meta["requirement"]) != ""
        return HK_NormalizeRequirement(meta["requirement"])
    risk := meta.Get("risk", "")
    for part in StrSplit(risk, ["|", ","]) {
        part := Trim(part)
        if part = "Needs Nastar"
            return REQ_NASTAR
        if part = "Needs Animation_autoaction"
            return REQ_ANIM
    }
    return HK_UserScriptName(path)
}

HK_ScriptRequirementForFn(fnName) {
    if fnName = ""
        return ""
    scanned := HK_ScanScriptFunctions()
    if IsObject(scanned) && scanned.Has(fnName)
        return HK_UserScriptRequirement(scanned[fnName])
    return ""
}

HK_LoadUserDefs() {
    global HotkeyDefs, HK_UserDefs, SETTINGS_FILE, HOTKEY_SETTINGS_FILE
    cleaned := []
    for d in HotkeyDefs {
        if !(d.HasOwnProp("user") && d.user)
            cleaned.Push(d)
    }
    HotkeyDefs := cleaned
    HK_UserDefs := []
    ini := FileExist(HOTKEY_SETTINGS_FILE) ? HOTKEY_SETTINGS_FILE : SETTINGS_FILE
    try ids := IniRead(ini, "UserHotkeys", "Ids", "")
    catch
        return
    if ids = ""
        return
    for id in StrSplit(ids, "|") {
        id := Trim(id)
        if id = ""
            continue
        sec := "UserHotkey_" id
        try desc := IniRead(ini, sec, "Action", "")
        catch
            continue
        try key := IniRead(ini, sec, "Hotkey", "")
        catch
            continue
        try req := IniRead(ini, sec, "Requirement", "")
        catch
            continue
        try fnName := IniRead(ini, sec, "Function", "")
        catch
            continue
        try scriptFile := IniRead(ini, sec, "ScriptFile", "")
        catch
            continue
        try scriptEnabled := PieSafeInt(IniRead(ini, sec, "CustomScriptEnabled", scriptFile != "" ? 1 : 0), scriptFile != "" ? 1 : 0, 0, 1)
        catch
            scriptEnabled := 0
        try group := IniRead(ini, sec, "Group", "csp")
        catch
            continue
        if desc = "" || fnName = ""
            continue
        if key = ""
            key := "-"
        d := {id:id, group:group, def:key, desc:desc, req:req, fnName:fnName, scriptFile:scriptFile, scriptEnabled:scriptEnabled, user:true, fn:HK_RunUserScript.Bind(id)}
        HK_UserDefs.Push(d)
        HotkeyDefs.Push(d)
    }
}

HK_SaveUserDefs() {
    global HK_UserDefs, HOTKEY_SETTINGS_FILE
    try oldIds := IniRead(HOTKEY_SETTINGS_FILE, "UserHotkeys", "Ids", "")
    catch
        oldIds := ""
    if oldIds != "" {
        for oldId in StrSplit(oldIds, "|") {
            oldId := Trim(oldId)
            if oldId != ""
                try IniDelete(HOTKEY_SETTINGS_FILE, "UserHotkey_" oldId)
        }
    }
    ids := ""
    for d in HK_UserDefs {
        ids .= (ids = "" ? "" : "|") d.id
        sec := "UserHotkey_" d.id
        IniWrite(d.desc, HOTKEY_SETTINGS_FILE, sec, "Action")
        IniWrite(d.def, HOTKEY_SETTINGS_FILE, sec, "Hotkey")
        IniWrite(d.group, HOTKEY_SETTINGS_FILE, sec, "Group")
        IniWrite(HK_GetRequirement(d), HOTKEY_SETTINGS_FILE, sec, "Requirement")
        IniWrite(d.fnName, HOTKEY_SETTINGS_FILE, sec, "Function")
        IniWrite(d.scriptFile, HOTKEY_SETTINGS_FILE, sec, "ScriptFile")
        IniWrite(d.HasOwnProp("scriptEnabled") && d.scriptEnabled ? 1 : 0, HOTKEY_SETTINGS_FILE, sec, "CustomScriptEnabled")
    }
    IniWrite(ids, HOTKEY_SETTINGS_FILE, "UserHotkeys", "Ids")
}

; --- User script enable/disable state ([UserScripts] section) ---

HK_UserScriptsIni() {
    global HOTKEY_SETTINGS_FILE, SETTINGS_FILE
    return FileExist(HOTKEY_SETTINGS_FILE) ? HOTKEY_SETTINGS_FILE : SETTINGS_FILE
}

HK_UserScriptName(path) {
    SplitPath(path, &name)
    return name
}

HK_UserScriptDisabled(path) {
    name := HK_UserScriptName(path)
    if name = ""
        return false
    ini := HK_UserScriptsIni()
    try v := IniRead(ini, "UserScripts", name, "")
    catch
        v := ""
    return v = "1" || StrLower(v) = "disabled"
}

HK_SetUserScriptDisabled(name, disabled) {
    name := HK_UserScriptName(name)
    if name = ""
        return false
    ini := HK_UserScriptsIni()
    if disabled {
        try IniWrite("1", ini, "UserScripts", name)
    } else {
        try IniDelete(ini, "UserScripts", name)
    }
    return true
}

HK_HasBlockManifest(path) {
    if path = "" || !FileExist(path)
        return false
    try txt := FileRead(path, "UTF-8")
    catch
        return false
    return !!RegExMatch(txt, "im)^\s*;\s*Block\s*:")
}
