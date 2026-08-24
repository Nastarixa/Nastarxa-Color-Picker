; ============================================================
; Developer / Release Tools
; This include can be removed from release builds if dev tooling is not needed.
; ============================================================

global _LastCleanReleaseFolder := ""
global _ReleaseIncludeDevTools := true
global _ReleaseMakeZipOnClean := true
global _ReleaseMakeExeOnClean := false
global _DevToolsIncluded := true

ShowDevTools(*) {
    global _ReleaseIncludeDevTools, _ReleaseMakeZipOnClean, _ReleaseMakeExeOnClean
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Dev Tools")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)
    dlg.AddText("xm w" S(542) " cAAAAAA", "Release/developer helpers. Reports are read-only; buttons that export, zip, or clean release files say so directly.")
    chkDev := dlg.AddCheckbox("xm y+" S(8) " cFFFFFF Background1E1F22", "Include Dev Tools in clean release folder")
    chkDev.Value := _ReleaseIncludeDevTools ? 1 : 0
    chkDev.OnEvent("Click", (*) => (_ReleaseIncludeDevTools := !!chkDev.Value))
    chkZip := dlg.AddCheckbox("x+" S(13) " yp cFFFFFF Background1E1F22", "Make zip on release")
    chkZip.Value := _ReleaseMakeZipOnClean ? 1 : 0
    chkZip.OnEvent("Click", (*) => (_ReleaseMakeZipOnClean := !!chkZip.Value))
    chkExe := dlg.AddCheckbox("x+" S(13) " yp cFFFFFF Background1E1F22", "Make EXE on release")
    chkExe.Value := _ReleaseMakeExeOnClean ? 1 : 0
    chkExe.OnEvent("Click", (*) => (_ReleaseMakeExeOnClean := !!chkExe.Value))

    btnW := S(175), btnH := S(28), gap := S(8)
    dlg.AddText("xm y+" S(14) " w" S(542) " h" S(1) " Background555555")
    dlg.AddText("xm y+" S(7) " cFFD54F", "Release")
    dlg.AddButton("xm y+" S(4) " w" btnW " h" btnH, "Release Checklist").OnEvent("Click", ShowReleaseChecklist)
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Clean Release Folder").OnEvent("Click", CreateCleanReleaseFolder)
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Build Release Package").OnEvent("Click", BuildReleasePackage)
    dlg.AddButton("xm y+" gap " w" btnW " h" btnH, "Open Release Folder").OnEvent("Click", OpenReleaseFolder)
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Tools/Presets Zip").OnEvent("Click", CreateToolsAndPresetsZip)
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Build EXE").OnEvent("Click", CreateReleaseExe)
    dlg.AddButton("xm y+" gap " w" btnW " h" btnH, "Version Check").OnEvent("Click", ShowVersionConsistencyCheck)
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Preset Hub").OnEvent("Click", ShowPresetHub)

    dlg.AddText("xm y+" S(14) " w" S(542) " h" S(1) " Background555555")
    dlg.AddText("xm y+" S(7) " cFFD54F", "Audit")
    dlg.AddButton("xm y+" S(4) " w" btnW " h" btnH, "Release Audit").OnEvent("Click", ShowOneClickReleaseAudit)
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Settings Integrity").OnEvent("Click", ShowSettingsHealth)
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Broken Icon Scanner").OnEvent("Click", ShowBrokenIconScanner)

    dlg.AddText("xm y+" S(14) " w" S(542) " h" S(1) " Background555555")
    dlg.AddText("xm y+" S(7) " cFFD54F", "Diagnostics")
    dlg.AddButton("xm y+" S(4) " w" btnW " h" btnH, "Preset Tester").OnEvent("Click", ShowPresetTester)
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Function Doctor").OnEvent("Click", ShowFunctionRegistryDoctor)
    btnClose := dlg.AddButton("x+" gap " yp w" btnW " h" btnH " Default", "Close")
    btnClose.OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("AutoSize")
    SetTimer((*) => btnClose.Focus(), -10)
}

ShowReleaseChecklist(*) {
    global SCRIPT_VERSION, CONFIG_VERSION, SETTINGS_FILE, PIE_SETTINGS_FILE, HOTKEY_SETTINGS_FILE, LINK_SETTINGS_FILE, _ReleaseIncludeDevTools, _ReleaseMakeZipOnClean, _ReleaseMakeExeOnClean
    snap := StartupHealthSnapshot()
    txt := "Release Checklist`r`n"
        . "Use this before packaging a public build.`r`n`r`n"
        . "Version`r`n"
        . StatusLine(SCRIPT_VERSION != "", "Script version", SCRIPT_VERSION)
        . StatusLine(CONFIG_VERSION > 0, "Config version", CONFIG_VERSION)
        . BuildVersionConsistencyText(false)
        . StatusLine(snap["state"] != "WARN", "Startup health badge", snap["state"] " - " snap["detail"])
        . "`r`nRequired files`r`n"

    required := [
        ["Main script", A_ScriptFullPath],
        ["README", A_ScriptDir "\README.md"],
        ["Changelog", A_ScriptDir "\CHANGELOG.md"],
        ["Tray icon", A_ScriptDir "\CSPToolkit.ico"],
        ["Source folder", A_ScriptDir "\src"],
        ["Notify include", A_ScriptDir "\src\vendor\Notify.ahk"],
        ["Icon reference", A_ScriptDir "\src\docs\IconRef.ini"]
    ]
    if _ReleaseMakeZipOnClean
        required.Push(["Tools/presets zip", A_ScriptDir "\CSP_Tools_and_AutoAction_Presets.zip"])
    if _ReleaseMakeExeOnClean
        required.Push(["Ahk2Exe compiler", ReleaseAhk2ExePath()])
    for item in required {
        path := item[2]
        txt .= StatusLine(FileExist(path) || DirExist(path), item[1], path)
    }

    txt .= "`r`nSettings health`r`n"
    for item in [["GUI settings", SETTINGS_FILE], ["Pie settings", PIE_SETTINGS_FILE], ["Hotkey settings", HOTKEY_SETTINGS_FILE], ["Link settings", LINK_SETTINGS_FILE]]
        txt .= StatusLine(FileExist(item[2]), item[1], item[2])

    txt .= "`r`nClean release guidance`r`n"
        . StatusLine(true, "Ship source files", "Main script, README, icon, src, optional CSP tools/presets")
        . StatusLine(true, "Do not ship personal settings", "settings folder should normally be excluded from release packages")
        . StatusLine(true, "Dev tools in release", _ReleaseIncludeDevTools ? "Included" : "Excluded from clean release folder")
        . StatusLine(true, "Tools/presets zip on release", _ReleaseMakeZipOnClean ? "Create and copy zip" : "Skip zip")
        . StatusLine(true, "Compiled EXE on release", _ReleaseMakeExeOnClean ? "Build with Ahk2Exe" : "Skip EXE")
        . StatusLine(true, "Use Clean Release Folder", "Creates a fresh release copy without live settings")

    txt .= "`r`nRoot junk scan`r`n"
    junk := ["ahk_err.txt", "ahk_out.txt", "link_launcher_err.txt", "link_launcher_out.txt", "analysis_report.md"]
    found := 0
    for name in junk {
        path := A_ScriptDir "\" name
        if FileExist(path) {
            txt .= StatusLine(false, name, "Remove before release: " path)
            found++
        }
    }
    if found = 0
        txt .= StatusLine(true, "Common junk files", "None found")

    ShowReportWindow("Release Checklist", txt, [["Version", ShowVersionConsistencyCheck], ["Preset Hub", ShowPresetHub], ["Release Audit", ShowOneClickReleaseAudit], ["Build Package", BuildReleasePackage], ["Clean Folder", CreateCleanReleaseFolder], ["Open Folder", OpenReleaseFolder]])
}

CreateCleanReleaseFolder(showPopup := true, *) {
    global SCRIPT_VERSION, _LastCleanReleaseFolder, _ReleaseIncludeDevTools, _ReleaseMakeZipOnClean, _ReleaseMakeExeOnClean
    if IsObject(showPopup)
        showPopup := true
    try {
        releaseRoot := A_ScriptDir "\release"
        if !DirExist(releaseRoot)
            DirCreate(releaseRoot)
        dest := releaseRoot "\Nastarxa_CSP_Toolkit_v" SCRIPT_VERSION "_" FormatTime(, "yyyyMMdd_HHmmss")
        DirCreate(dest)

        copied := []
        for fileName in ["Nastarxa_CSP_Animator_Toolkit.ahk", "README.md", "CHANGELOG.md", "CSPToolkit.ico"] {
            src := A_ScriptDir "\" fileName
            if FileExist(src) {
                FileCopy(src, dest "\" fileName, 1)
                copied.Push(fileName)
            }
        }

        for dirName in ["src", "CSP_AutoAction_Presets", "CSP_Tools"] {
            srcDir := A_ScriptDir "\" dirName
            if DirExist(srcDir) {
                DirCopy(srcDir, dest "\" dirName, true)
                copied.Push(dirName "\")
            }
        }

        if !_ReleaseIncludeDevTools {
            devDir := dest "\src\dev"
            if DirExist(devDir) {
                DirDelete(devDir, true)
                copied.Push("src\dev\ excluded")
            }
            ReleaseDisableDevInclude(dest "\Nastarxa_CSP_Animator_Toolkit.ahk")
        }

        zipPath := ""
        if _ReleaseMakeZipOnClean {
            zipPath := CreateToolsAndPresetsZip(false)
            if zipPath != "" && FileExist(zipPath) {
                FileCopy(zipPath, dest "\CSP_Tools_and_AutoAction_Presets.zip", 1)
                copied.Push("CSP_Tools_and_AutoAction_Presets.zip")
            }
        }

        exePath := ""
        if _ReleaseMakeExeOnClean {
            exePath := CreateReleaseExe(false, dest)
            if exePath != "" && FileExist(exePath)
                copied.Push("Nastarxa_CSP_Animator_Toolkit.exe")
        }

        DirCreate(dest "\user_hotkey_scripts")
        manifest := "Clean release folder`r`n"
            . "Version: " SCRIPT_VERSION "`r`n"
            . "Created: " FormatTime(, "yyyy-MM-dd HH:mm:ss") "`r`n"
            . "Source: " A_ScriptDir "`r`n"
            . "Tools/presets zip: " (_ReleaseMakeZipOnClean ? (zipPath != "" ? zipPath : "Not created") : "Skipped") "`r`n"
            . "Compiled EXE: " (_ReleaseMakeExeOnClean ? (exePath != "" ? exePath : "Not created") : "Skipped") "`r`n"
            . "Dev tools included: " (_ReleaseIncludeDevTools ? "Yes" : "No") "`r`n"
            . "Settings folder intentionally not copied.`r`n`r`n"
            . "Copied:`r`n- " JoinTextList(copied, "`r`n- ") "`r`n"
        FileAppend(manifest, dest "\RELEASE_MANIFEST.txt", "UTF-8")

        _LastCleanReleaseFolder := dest
        DebugLog("Clean release folder created: " dest)
        msg := "Created:`n" dest
        if zipPath != ""
            msg .= "`n`nTools/AutoAction zip:`n" zipPath
        if exePath != ""
            msg .= "`n`nEXE created:`n" exePath
        if showPopup
            _HK_ResultPopup("Clean Release Folder", msg, "4CAF50")
        return dest
    } catch as e {
        DebugLog("Clean release folder failed: " e.Message)
        if showPopup
            _HK_ResultPopup("Release Error", "Failed: " e.Message, "E53935")
        return ""
    }
}

BuildReleasePackage(*) {
    global SCRIPT_VERSION
    releaseDir := CreateCleanReleaseFolder(false)
    if releaseDir = "" || !DirExist(releaseDir) {
        _HK_ResultPopup("Build Release Package", "Clean release folder could not be created.", "E53935")
        return ""
    }

    SplitPath(releaseDir, &folderName, &releaseRoot)
    zipPath := releaseRoot "\" folderName ".zip"
    ps1 := A_Temp "\csp_release_package_" A_TickCount ".ps1"
    ps := "$ErrorActionPreference = 'Stop'`r`n"
        . "$src = " ReleasePsQuote(releaseDir) "`r`n"
        . "$zip = " ReleasePsQuote(zipPath) "`r`n"
        . "if (Test-Path -LiteralPath $zip) { Remove-Item -LiteralPath $zip -Force }`r`n"
        . "Compress-Archive -LiteralPath $src -DestinationPath $zip -Force`r`n"
    try FileAppend(ps, ps1, "UTF-8")
    catch as e {
        DebugLog("Release package script write failed: " e.Message)
        _HK_ResultPopup("Build Release Package", "Failed to prepare PowerShell script:`n" e.Message, "E53935")
        return ""
    }

    exitCode := RunWait('powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' ps1 '"', , "Hide")
    try FileDelete(ps1)
    if exitCode != 0 || !FileExist(zipPath) {
        msg := "Failed to create release package zip. PowerShell exit code: " exitCode
        DebugLog("Release package zip failed: " msg)
        _HK_ResultPopup("Build Release Package", msg, "E53935")
        return ""
    }

    size := FileGetSize(zipPath)
    DebugLog("Release package built: " zipPath " (" size " bytes)")
    _HK_ResultPopup("Build Release Package", "Created release folder:`n" releaseDir "`n`nCreated package:`n" zipPath "`n`nSize: " size " bytes", "4CAF50")
    return zipPath
}

ReleaseDisableDevInclude(mainScriptPath) {
    if !FileExist(mainScriptPath)
        return
    try {
        text := FileRead(mainScriptPath, "UTF-8")
        devInclude := "#Include src\dev\dev.ahk"
        disabledInclude := Chr(59) " #Include src\dev\dev.ahk  " Chr(59) " excluded by clean release"
        text := StrReplace(text, devInclude, disabledInclude)
        tmp := mainScriptPath ".tmp"
        try FileDelete(tmp)
        FileAppend(text, tmp, "UTF-8")
        FileMove(tmp, mainScriptPath, 1)
    } catch as e {
        DebugLog("[WARN] Clean release could not disable dev include: " e.Message)
    }
}

OpenReleaseFolder(*) {
    global _LastCleanReleaseFolder
    target := ""
    if _LastCleanReleaseFolder != "" && DirExist(_LastCleanReleaseFolder)
        target := _LastCleanReleaseFolder
    else if DirExist(A_ScriptDir "\release")
        target := A_ScriptDir "\release"
    if target = "" {
        _HK_ResultPopup("Open Release Folder", "No release folder exists yet.`nClick Clean Release Folder first.", "E5A823")
        return
    }
    try Run('"' target '"')
    catch as e
        _HK_ResultPopup("Open Release Folder", "Failed to open:`n" target "`n`n" e.Message, "E53935")
}

ShowPresetHub(*) {
    dlg := Gui("+AlwaysOnTop +ToolWindow", "Preset Hub")
    dlg.BackColor := "1E1F22"
    dlg.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    dlg.MarginX := S(14)
    dlg.MarginY := S(14)
    dlg.AddText("xm w" S(552) " cAAAAAA", "One place for profile, preset, and mode-bundle import/export tools. Link button import/export is opened through Link Manager because those actions live inside that manager.")

    btnW := S(130), btnH := S(28), gap := S(8)
    AddPresetHubSection(dlg, "Modes / Config")
    dlg.AddButton("xm y+" S(4) " w" btnW " h" btnH, "Export Mode Bundle").OnEvent("Click", (*) => ExportSettingsBundle())
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Import Mode Bundle").OnEvent("Click", (*) => ImportSettingsBundle())
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Export JSON").OnEvent("Click", (*) => ExportConfigJSON())
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Import Config").OnEvent("Click", (*) => ShowImportConfigChoice())

    AddPresetHubSection(dlg, "Hotkeys / Pie")
    dlg.AddButton("xm y+" S(4) " w" btnW " h" btnH, "Hotkey Export").OnEvent("Click", (*) => ExportHotkeys())
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Hotkey Import").OnEvent("Click", (*) => ImportHotkeys())
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Pie Export").OnEvent("Click", (*) => ExportPieSettings())
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Pie Import").OnEvent("Click", (*) => ImportPieSettings())
    dlg.AddButton("xm y+" gap " w" btnW " h" btnH, "Pie Oven").OnEvent("Click", (*) => ShowPieOven())
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Quick Pie Presets").OnEvent("Click", (*) => ShowPieQuickPresets())

    AddPresetHubSection(dlg, "GUI Items / Colors")
    dlg.AddButton("xm y+" S(4) " w" btnW " h" btnH, "Color Export").OnEvent("Click", (*) => ExportColorItems())
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Color Import").OnEvent("Click", (*) => ImportColorItems())
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Color Manager").OnEvent("Click", (*) => ShowColorManager())
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "Link Manager").OnEvent("Click", (*) => ShowLinkManager())
    dlg.AddButton("xm y+" gap " w" btnW " h" btnH, "IB Theme Export").OnEvent("Click", (*) => ExportIBColorProfile())
    dlg.AddButton("x+" gap " yp w" btnW " h" btnH, "IB Theme Import").OnEvent("Click", (*) => ImportIBColorProfile())

    dlg.AddText("xm y+" S(14) " w" S(552) " h" S(1) " Background555555")
    btnClose := dlg.AddButton("xm y+" S(8) " w" btnW " h" btnH " Default", "Close")
    btnClose.OnEvent("Click", (*) => dlg.Destroy())
    dlg.Show("AutoSize")
    SetTimer((*) => btnClose.Focus(), -10)
}

AddPresetHubSection(dlg, title) {
    dlg.AddText("xm y+" S(14) " w" S(552) " h" S(1) " Background555555")
    dlg.AddText("xm y+" S(7) " cFFD54F", title)
}

ShowVersionConsistencyCheck(*) {
    ShowReportWindow("Version Consistency Check", "Version Consistency Check`r`n`r`n" BuildVersionConsistencyText(true))
}

BuildVersionConsistencyText(includeReleaseFolder := true) {
    global SCRIPT_VERSION
    txt := ""
    readmePath := A_ScriptDir "\README.md"
    badgeVersion := ""
    if FileExist(readmePath) {
        try {
            readme := FileRead(readmePath, "UTF-8")
            if RegExMatch(readme, "i)version-([0-9]+(?:\.[0-9]+){0,2})-", &m)
                badgeVersion := m[1]
        }
    }
    badgeOk := badgeVersion != "" && (badgeVersion = SCRIPT_VERSION || ReleaseNormalizeVersion(badgeVersion) = ReleaseNormalizeVersion(SCRIPT_VERSION))
    txt .= StatusLine(SCRIPT_VERSION != "", "SCRIPT_VERSION", SCRIPT_VERSION)
    txt .= StatusLine(badgeOk, "README version badge", badgeVersion = "" ? "Missing version badge" : badgeVersion " (script " SCRIPT_VERSION ")")
    txt .= StatusLine(FileExist(A_ScriptDir "\Nastarxa_CSP_Animator_Toolkit.ahk"), "Main script name", "Nastarxa_CSP_Animator_Toolkit.ahk")
    ahk2exe := ReleaseAhk2ExePath()
    base := ReleaseAhk2ExeBasePath()
    baseVersion := ReleaseFileVersion(base)
    txt .= StatusLine(FileExist(ahk2exe), "Ahk2Exe compiler", ahk2exe)
    txt .= StatusLine(base != "" && FileExist(base), "Ahk2Exe base", (base = "" ? "Missing AutoHotkey v2 U64 base" : base " (" (baseVersion = "" ? "unknown version" : baseVersion) ")"))
    txt .= StatusLine(baseVersion = "" || InStr(baseVersion, "2.0.19"), "Preferred base version", baseVersion = "" ? "Could not read base version; expected v2.0.19 U64" : baseVersion)
    txt .= StatusLine(FileExist(A_ScriptDir "\CSPToolkit.ico"), "EXE icon", A_ScriptDir "\CSPToolkit.ico")
    if includeReleaseFolder {
        latest := LatestReleaseFolder()
        if latest = ""
            txt .= StatusLine(true, "Release folder version", "No clean release folder yet")
        else
            txt .= StatusLine(InStr(latest, "_v" SCRIPT_VERSION "_"), "Latest release folder", latest)
    }
    txt .= "`r`nRelease Notes`r`n" ReleaseReadmeSection("Release Notes")
        . "`r`nKnown Issues`r`n" ReleaseReadmeSection("Known Issues")
    return txt
}

ReleaseNormalizeVersion(v) {
    parts := StrSplit(Trim(v), ".")
    while parts.Length > 1 && parts[parts.Length] = "0"
        parts.Pop()
    return JoinTextList(parts, ".")
}

LatestReleaseFolder() {
    root := A_ScriptDir "\release"
    if !DirExist(root)
        return ""
    latest := ""
    latestTime := ""
    Loop Files root "\*", "D" {
        if latest = "" || A_LoopFileTimeModified > latestTime {
            latest := A_LoopFileFullPath
            latestTime := A_LoopFileTimeModified
        }
    }
    return latest
}

ReleasePsQuote(path) {
    return "'" StrReplace(path, "'", "''") "'"
}

CreateToolsAndPresetsZip(showPopup := true, *) {
    if IsObject(showPopup)
        showPopup := true
    zipPath := A_ScriptDir "\CSP_Tools_and_AutoAction_Presets.zip"
    sources := []
    missing := []
    for dirName in ["CSP_AutoAction_Presets", "CSP_Tools"] {
        src := A_ScriptDir "\" dirName
        if DirExist(src)
            sources.Push(src)
        else
            missing.Push(dirName)
    }

    if sources.Length = 0 {
        msg := "Cannot create zip because both source folders are missing:`n- CSP_AutoAction_Presets`n- CSP_Tools"
        DebugLog("Tools/presets zip failed: source folders missing")
        if showPopup
            _HK_ResultPopup("Tools/Presets Zip", msg, "E53935")
        return ""
    }

    ps1 := A_Temp "\csp_tools_presets_zip_" A_TickCount ".ps1"
    srcList := ""
    for src in sources
        srcList .= (srcList = "" ? "" : ", ") ReleasePsQuote(src)
    ps := "$ErrorActionPreference = 'Stop'`r`n"
        . "$zip = " ReleasePsQuote(zipPath) "`r`n"
        . "$sources = @(" srcList ")`r`n"
        . "if (Test-Path -LiteralPath $zip) { Remove-Item -LiteralPath $zip -Force }`r`n"
        . "Compress-Archive -LiteralPath $sources -DestinationPath $zip -Force`r`n"
    try FileAppend(ps, ps1, "UTF-8")
    catch as e {
        DebugLog("Tools/presets zip script write failed: " e.Message)
        if showPopup
            _HK_ResultPopup("Tools/Presets Zip", "Failed to prepare PowerShell script:`n" e.Message, "E53935")
        return ""
    }

    exitCode := RunWait('powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' ps1 '"', , "Hide")
    try FileDelete(ps1)
    if exitCode != 0 || !FileExist(zipPath) {
        msg := "Failed to create zip. PowerShell exit code: " exitCode
        DebugLog("Tools/presets zip failed: " msg)
        if showPopup
            _HK_ResultPopup("Tools/Presets Zip", msg, "E53935")
        return ""
    }

    size := FileGetSize(zipPath)
    msg := "Created:`n" zipPath "`n`nSize: " size " bytes"
    if missing.Length
        msg .= "`n`nSkipped missing folder(s):`n- " JoinTextList(missing, "`n- ")
    DebugLog("Tools/presets zip created: " zipPath " (" size " bytes)")
    if showPopup
        _HK_ResultPopup("Tools/Presets Zip", msg, "4CAF50")
    return zipPath
}

LatestReleasePackageZip() {
    root := A_ScriptDir "\release"
    if !DirExist(root)
        return ""
    latest := ""
    latestTime := ""
    Loop Files root "\Nastarxa_CSP_Toolkit_v*.zip", "F" {
        if latest = "" || A_LoopFileTimeModified > latestTime {
            latest := A_LoopFileFullPath
            latestTime := A_LoopFileTimeModified
        }
    }
    return latest
}

ReleaseReadmeSection(sectionName) {
    path := A_ScriptDir "\README.md"
    if !FileExist(path)
        return StatusLine(false, sectionName, "README.md missing")
    try text := FileRead(path, "UTF-8")
    catch as e
        return StatusLine(false, sectionName, "Cannot read README.md: " e.Message)

    lines := StrSplit(text, "`n", "`r")
    inSection := false
    found := false
    sectionLevel := 0
    body := ""
    for line in lines {
        trimmed := Trim(line)
        if RegExMatch(trimmed, "^(#+)\s+" RegExEscape(sectionName) "\b", &m) {
            inSection := true
            found := true
            sectionLevel := StrLen(m[1])
            continue
        }
        if inSection && RegExMatch(trimmed, "^(#+)\s+\S", &hm) {
            if StrLen(hm[1]) <= sectionLevel
                break
        }
        if inSection && trimmed != "" && !RegExMatch(trimmed, "^-{3,}$")
            body .= (body = "" ? "" : "`r`n") trimmed
    }
    if !found
        return StatusLine(false, sectionName, "Missing README section")
    if body = ""
        return StatusLine(false, sectionName, "Section exists but is empty")
    if StrLen(body) > 900
        body := SubStr(body, 1, 900) "`r`n..."
    return StatusLine(true, sectionName, "Found") body "`r`n"
}

RegExEscape(text) {
    return RegExReplace(text, "([\\\.\*\?\+\[\{\|\(\)\^\$])", "\$1")
}

ReleaseAhk2ExePath() {
    return A_ProgramFiles "\AutoHotkey\Compiler\Ahk2Exe.exe"
}

ReleaseAhk2ExeBasePath() {
    preferred := A_ProgramFiles "\AutoHotkey\v2\AutoHotkey64.exe"
    if FileExist(preferred)
        return preferred
    candidates := []
    Loop Files A_ProgramFiles "\AutoHotkey\*AutoHotkey64*.exe", "FR"
        candidates.Push(A_LoopFileFullPath)
    for path in candidates {
        try {
            if InStr(FileGetVersion(path), "2.0.19")
                return path
        }
    }
    return candidates.Length ? candidates[1] : ""
}

ReleaseFileVersion(path) {
    if path = "" || !FileExist(path)
        return ""
    try return FileGetVersion(path)
    catch
        return ""
}

ReleaseParentDir(path) {
    SplitPath(path, , &dir)
    return dir
}

ReleaseUniqueExistingDirs(paths*) {
    dirs := []
    seen := Map()
    for path in paths {
        path := ReleaseNormalizeDirArg(path)
        if path = ""
            continue
        try full := DirExist(path) ? path : ""
        catch
            full := ""
        if full = ""
            continue
        key := StrLower(RTrim(full, "\/"))
        if !seen.Has(key) {
            seen[key] := true
            dirs.Push(full)
        }
    }
    return dirs
}

ReleaseNormalizeDirArg(path) {
    if IsObject(path)
        return ""
    path := Trim(String(path))
    if path = "" || path = "0"
        return ""
    return path
}

ReleaseLatestSubfolder(root) {
    if root = "" || !DirExist(root)
        return ""
    latest := ""
    latestTime := ""
    Loop Files root "\*", "D" {
        if latest = "" || A_LoopFileTimeModified > latestTime {
            latest := A_LoopFileFullPath
            latestTime := A_LoopFileTimeModified
        }
    }
    return latest
}

ReleaseResolveBuildAsset(fileName, targetDir := "") {
    targetDir := ReleaseNormalizeDirArg(targetDir)
    baseRoot := A_ScriptDir
    releaseRoot := baseRoot "\release"
    parent := ReleaseParentDir(baseRoot)
    targetParent := targetDir != "" ? ReleaseParentDir(targetDir) : ""
    latestRelease := ReleaseLatestSubfolder(releaseRoot)
    latestTargetParent := ReleaseLatestSubfolder(targetParent)
    searchDirs := ReleaseUniqueExistingDirs(
        targetDir,
        latestTargetParent,
        releaseRoot,
        latestRelease,
        baseRoot,
        parent "\CSP"
    )
    for dir in searchDirs {
        path := dir "\" fileName
        if FileExist(path)
            return path
    }
    return (targetDir != "" ? targetDir : baseRoot) "\" fileName
}

ReleaseBrowseBuildAsset(label, suggestedPath, filter) {
    start := suggestedPath
    if start = "" || !FileExist(start) {
        SplitPath(suggestedPath, , &dir)
        start := DirExist(dir) ? dir : A_ScriptDir
    }
    chosen := FileSelect("3", start, "Select " label, filter)
    return chosen
}

ReleaseRunAhk2Exe(ahk2exe, src, out, base, icon) {
    try {
        SplitPath(src, &srcName, &srcDir, , &srcNoExt)
        SplitPath(out, &outName)
        candidates := []
        candidates.Push(out)
        if srcDir != "" {
            candidates.Push(srcDir "\" outName)
            candidates.Push(srcDir "\" srcNoExt ".exe")
        }
        beforeTimes := Map()
        for candidate in candidates {
            key := StrLower(candidate)
            if !beforeTimes.Has(key) {
                try beforeTimes[key] := FileExist(candidate) ? FileGetTime(candidate, "M") : ""
                catch
                    beforeTimes[key] := ""
            }
        }
        try FileDelete(out)
        cmd := '"' ahk2exe '" /in "' src '" /out "' out '" /base "' base '" /icon "' icon '" /compress 0'
        exitCode := RunWait(cmd, , "Hide")
        if exitCode != 0
            return {ok: false, message: "Ahk2Exe failed. Exit code: " exitCode}
        for candidate in candidates {
            if !FileExist(candidate)
                continue
            key := StrLower(candidate)
            try afterTime := FileGetTime(candidate, "M")
            catch
                afterTime := ""
            if candidate = out || beforeTimes.Get(key, "") = "" || afterTime != beforeTimes.Get(key, "")
                return {ok: true, message: "", path: candidate}
        }
        return {ok: false, message: "Ahk2Exe finished with exit code 0, but no fresh output EXE was found near the requested output or source script."}
    } catch as e {
        return {ok: false, message: e.Message}
    }
}

ReleaseExeOutputForSource(src, targetDir := "") {
    global SCRIPT_VERSION
    targetDir := ReleaseNormalizeDirArg(targetDir)
    if targetDir != ""
        return targetDir "\Nastarxa_CSP_Animator_Toolkit.exe"
    SplitPath(src, , &srcDir)
    outDir := DirExist(srcDir) ? srcDir : A_ScriptDir
    return outDir "\Nastarxa_CSP_Animator_Toolkit_v" SCRIPT_VERSION ".exe"
}

CreateReleaseExe(showPopup := true, targetDir := "", *) {
    global SCRIPT_VERSION
    if IsObject(showPopup)
        showPopup := true
    targetDir := ReleaseNormalizeDirArg(targetDir)

    ahk2exe := ReleaseAhk2ExePath()
    base := ReleaseAhk2ExeBasePath()
    src := ReleaseResolveBuildAsset("Nastarxa_CSP_Animator_Toolkit.ahk", targetDir)
    icon := ReleaseResolveBuildAsset("CSPToolkit.ico", targetDir)
    if !FileExist(src) {
        DebugLog("EXE build main script not found automatically: " src)
        picked := ReleaseBrowseBuildAsset("main script (.ahk)", src, "AutoHotkey Script (*.ahk)")
        if picked != ""
            src := picked
    }
    if !FileExist(icon) {
        DebugLog("EXE build icon not found automatically: " icon)
        picked := ReleaseBrowseBuildAsset("icon (.ico)", icon, "Icon (*.ico)")
        if picked != ""
            icon := picked
    }
    out := ReleaseExeOutputForSource(src, targetDir)
    SplitPath(out, , &outDir)

    missing := []
    if !FileExist(ahk2exe)
        missing.Push("Ahk2Exe.exe: " ahk2exe)
    if base = "" || !FileExist(base)
        missing.Push("AutoHotkey v2 U64 base: " (base = "" ? "not found" : base))
    if !FileExist(src)
        missing.Push("Main script: " src)
    if !FileExist(icon)
        missing.Push("Icon: " icon)
    if missing.Length {
        msg := "Cannot build EXE. Missing:`n- " JoinTextList(missing, "`n- ")
        DebugLog("EXE build failed: missing requirement(s)")
        if showPopup
            _HK_ResultPopup("Build EXE", msg, "E53935")
        return ""
    }

    try {
        if !DirExist(outDir)
            DirCreate(outDir)
        result := ReleaseRunAhk2Exe(ahk2exe, src, out, base, icon)
        if !result.ok {
            DebugLog("EXE build first attempt failed: " result.message)
            if !_HK_Confirm(result.message "`n`nDo you want to manually select the main script and icon, then retry?", "Build EXE")
                throw Error(result.message)
            pickedSrc := ReleaseBrowseBuildAsset("main script (.ahk)", src, "AutoHotkey Script (*.ahk)")
            if pickedSrc = ""
                throw Error(result.message "`n`nManual main script selection was cancelled.")
            pickedIcon := ReleaseBrowseBuildAsset("icon (.ico)", icon, "Icon (*.ico)")
            if pickedIcon = ""
                throw Error(result.message "`n`nManual icon selection was cancelled.")

            src := pickedSrc
            icon := pickedIcon
            out := ReleaseExeOutputForSource(src, targetDir)
            SplitPath(out, , &outDir)
            if !DirExist(outDir)
                DirCreate(outDir)
            DebugLog("Retrying EXE build with manually selected script/icon")
            result := ReleaseRunAhk2Exe(ahk2exe, src, out, base, icon)
            if !result.ok
                throw Error(result.message)
        }
        actualOut := result.HasProp("path") ? result.path : out
        if actualOut != out {
            try {
                FileCopy(actualOut, out, 1)
                DebugLog("EXE build output found at " actualOut " and copied to " out)
            } catch as copyErr {
                out := actualOut
                DebugLog("EXE build output found at " actualOut ", but copy to expected path failed: " copyErr.Message)
            }
        }
        size := FileGetSize(out)
        msg := "Created:`n" out "`n`nBase:`n" base "`nVersion: " ReleaseFileVersion(base) "`n`nIcon embedded:`n" icon "`n`nCompress: none`nSize: " size " bytes"
        DebugLog("EXE built: " out " (" size " bytes)")
        if showPopup
            _HK_ResultPopup("Build EXE", msg, "4CAF50")
        return out
    } catch as e {
        DebugLog("EXE build failed: " e.Message)
        if showPopup
            _HK_ResultPopup("Build EXE", "Failed to build EXE:`n" e.Message, "E53935")
        return ""
    }
}

ShowBrokenIconScanner(*) {
    txt := BrokenIconScanText()
    ShowReportWindow("Broken Icon Scanner", txt)
}

BrokenIconScanText() {
    q := "?"
    patterns := [Chr(0xFFFD), Chr(0xE2), Chr(0xF0), Chr(0xC3), q "+", q "10"]
    files := []
    for pattern in ["*.ahk", "*.md", "*.ini"] {
        Loop Files A_ScriptDir "\" pattern, "FR"
            files.Push(A_LoopFileFullPath)
    }

    txt := "Broken Icon Scanner`r`n"
        . "Scans source/docs/settings for common mojibake or fallback icon tokens.`r`n"
        . "Note: plain ? can be a valid help icon, so only known-bad variants are flagged.`r`n`r`n"
    hits := 0
    for file in files {
        rel := StrReplace(file, A_ScriptDir "\")
        if InStr(rel, "settings\settings_backups\") || InStr(rel, "settings\settings_exports\") || InStr(rel, "\release\")
            continue
        try text := FileRead(file, "UTF-8")
        catch
            continue
        lineNo := 0
        Loop Parse text, "`n", "`r" {
            lineNo++
            lineText := A_LoopField
            if InStr(lineText, "patterns :=")
                continue
            for pat in patterns {
                if InStr(lineText, pat) {
                    txt .= StatusLine(false, rel, "Found '" pat "' near line " lineNo)
                    hits++
                }
            }
        }
    }
    if hits = 0
        txt .= StatusLine(true, "Broken icon tokens", "No known-bad icon text found")
    else
        txt .= "`r`nResult: " hits " possible broken icon token(s) found."
    return txt
}

ShowPresetTester(*) {
    ShowReportWindow("Pie Quick Preset Tester", BuildPresetTesterText())
}

BuildPresetTesterText(*) {
    txt := "Pie Quick Preset Tester`r`n"
        . "Checks bundled and user quick-pie preset files without loading them into the active quick-pie list.`r`n`r`n"
    dirs := [
        ["Bundled presets", A_ScriptDir "\src\presets"],
        ["User presets", PieQuickPresetDir()]
    ]
    totalFiles := 0
    totalIssues := 0
    for info in dirs {
        label := info[1], dir := info[2]
        txt .= label "`r`n"
        if !DirExist(dir) {
            txt .= StatusLine(false, label, "Missing folder: " dir)
            totalIssues++
            continue
        }
        filesInDir := 0
        Loop Files dir "\*.ini" {
            filesInDir++, totalFiles++
            result := AuditPieQuickPresetFile(A_LoopFileFullPath)
            totalIssues += result.issues
            txt .= result.text
        }
        if filesInDir = 0
            txt .= StatusLine(false, label, "No .ini preset files found in " dir), totalIssues++
        txt .= "`r`n"
    }
    txt .= "Result: " (totalIssues = 0 ? "All " totalFiles " preset file(s) look usable." : totalIssues " preset issue(s) found across " totalFiles " file(s).")
    return txt
}

AuditPieQuickPresetFile(path) {
    text := ""
    issues := 0
    rel := StrReplace(path, A_ScriptDir "\")
    idsRaw := ""
    try idsRaw := IniRead(path, "PieQuickHotkeys", "Ids", "")
    catch as e {
        return {text: StatusLine(false, rel, "Cannot read preset: " e.Message), issues: 1}
    }
    ids := []
    for rawId in StrSplit(idsRaw, "|") {
        id := Trim(rawId)
        if id != ""
            ids.Push(id)
    }
    if ids.Length = 0
        return {text: StatusLine(false, rel, "No PieQuickHotkeys.Ids entries found"), issues: 1}

    itemIssues := 0
    for id in ids {
        sec := "PieQuickHotkey_" id
        try item := Map(
            "id", id,
            "label", IniRead(path, sec, "Label", ""),
            "key", IniRead(path, sec, "Hotkey", ""),
            "scope", IniRead(path, sec, "Scope", "all"),
            "type", IniRead(path, sec, "Type", "shortcut"),
            "action", IniRead(path, sec, "Action", ""),
            "requirement", IniRead(path, sec, "Requirement", ""),
            "color", IniRead(path, sec, "Color", "455A64"),
            "description", IniRead(path, sec, "Description", ""),
            "enabled", IniRead(path, sec, "Enabled", 1)
        )
        catch
            continue
        item := PieQuickSanitizeItem(item)
        detail := PieQuickPresetItemIssue(item)
        if detail != "" {
            label := item.Get("label", id)
            text .= StatusLine(false, rel " / " label, detail)
            itemIssues++
        }
    }
    issues += itemIssues
    if itemIssues = 0
        text .= StatusLine(true, rel, ids.Length " quick action(s) valid")
    return {text: text, issues: issues}
}

PieQuickPresetItemIssue(item) {
    item := PieQuickSanitizeItem(item)
    type := ToolkitNormalizeActionType(item.Get("type", "shortcut"))
    key := PieQuickNormalizeKey(item.Get("key", ""))
    action := Trim(item.Get("action", ""))
    if !item.Get("enabled", 1) || type = "disabled" || PieQuickNormalizeScope(item.Get("scope", "all")) = "disabled"
        return ""
    if key = "" || key = "-"
        return "Missing quick hotkey key"
    if PieQuickIsReservedKey(key)
        return "Uses reserved number key " key
    if action = ""
        return "Missing action"
    switch type {
        case "shortcut":
            return ""
        case "function":
            return PieFunctionAvailable(action) ? "" : "Missing function: " action
        case "script":
            return FileExist(action) ? "" : "Missing script/file: " action
        case "url":
            return RegExMatch(action, "i)^(https?://|file://|[A-Z]:\\|\\\\)") ? "" : "URL/path does not look openable: " action
        case "show pie", "submenu", "nav":
            return action != "" ? "" : "Missing pie target"
        default:
            return "Unknown action type: " type
    }
}

ShowFunctionRegistryDoctor(*) {
    ShowReportWindow("Function Registry Doctor", BuildFunctionRegistryDoctorText())
}

BuildFunctionRegistryDoctorText(*) {
    global HotkeyDefs, ColorItems, LinkItems, PieConfigs, SubPieConfigs, PieQuickHotkeys
    txt := "Function Registry Doctor`r`n"
        . "Checks callable function references used by hotkeys, Color GUI, Link GUI, pie slots, sub-pies, and pie quick hotkeys.`r`n`r`n"
    issues := 0

    txt .= "Hotkey Functions`r`n"
    hkIssues := 0
    for d in HotkeyDefs {
        fnName := HK_GetFnName(d)
        if fnName = "" || fnName = "(inline)" || fnName = "(disabled)"
            continue
        if !HK_GetFn(d) {
            txt .= StatusLine(false, d.desc, "Missing function: " fnName)
            hkIssues++, issues++
        }
    }
    if hkIssues = 0
        txt .= StatusLine(true, "Hotkey functions", "All enabled named hotkey functions are callable")

    txt .= "`r`nColor GUI Functions`r`n"
    audit := DevAuditGuiFunctionItems(ColorItems, "Color GUI")
    txt .= audit.text
    issues += audit.issues

    txt .= "`r`nLink GUI Functions`r`n"
    audit := DevAuditGuiFunctionItems(LinkItems, "Link GUI")
    txt .= audit.text
    issues += audit.issues

    txt .= "`r`nPie Functions`r`n"
    pieIssues := 0
    Loop PieConfigs.Length {
        p := A_Index
        for idx, item in PieConfigs[p] {
            audit := DevAuditActionItem("Pie " p " slot " idx, item)
            txt .= audit.text
            pieIssues += audit.issues
        }
    }
    for sIdx, cfg in SubPieConfigs {
        for idx, item in cfg {
            audit := DevAuditActionItem("Sub-pie " sIdx " slot " idx, item)
            txt .= audit.text
            pieIssues += audit.issues
        }
    }
    for idx, item in PieQuickHotkeys {
        audit := DevAuditActionItem("Pie Quick " idx, item)
        txt .= audit.text
        pieIssues += audit.issues
    }
    issues += pieIssues
    if pieIssues = 0
        txt .= StatusLine(true, "Pie and quick-pie functions", "All enabled function actions are callable")

    txt .= "`r`nResult: " (issues = 0 ? "No missing function references found." : issues " function reference issue(s) found.")
    return txt
}

DevAuditGuiFunctionItems(items, label) {
    text := ""
    issues := 0
    if !IsObject(items) {
        text .= StatusLine(false, label, "Items are not loaded")
        return {text: text, issues: 1}
    }
    for idx, item in items {
        audit := DevAuditActionItem(label " item " idx, item)
        text .= audit.text
        issues += audit.issues
        if ToolkitSafeInt(PieQuickReadField(item, "toggle", 0), 0, 0, 1) {
            type := ToolkitNormalizeActionType(PieQuickReadField(item, "type", "shortcut"))
            if type = "function"
                action2 := Trim(PieQuickReadField(item, "action2", ""))
            else if type = "script" || type = "url"
                action2 := Trim(PieQuickReadField(item, "target2", ""))
            else
                action2 := Trim(PieQuickReadField(item, "keys2", ""))
            if type = "function" && action2 != "" && !PieFunctionAvailable(action2) {
                text .= StatusLine(false, label " item " idx " Action B", "Missing function: " action2)
                issues++
            }
        }
    }
    if issues = 0
        text .= StatusLine(true, label, "All enabled function actions are callable")
    return {text: text, issues: issues}
}

DevAuditActionItem(label, item) {
    text := ""
    type := ToolkitNormalizeActionType(PieQuickReadField(item, "type", "shortcut"))
    enabled := ToolkitSafeInt(PieQuickReadField(item, "enabled", 1), 1, 0, 1)
    if !enabled || type = "disabled"
        return {text: text, issues: 0}
    if type = "function"
        action := Trim(PieQuickReadField(item, "action", ""))
    else if type = "script" || type = "url"
        action := Trim(PieQuickReadField(item, "target", ""))
    else
        action := Trim(PieQuickReadField(item, "action", ""))
    if type != "function" || action = ""
        return {text: text, issues: 0}
    if PieFunctionAvailable(action)
        return {text: text, issues: 0}
    text .= StatusLine(false, label, "Missing function: " action)
    return {text: text, issues: 1}
}

ShowOneClickReleaseAudit(*) {
    ShowReportWindow("One-Click Release Audit", BuildOneClickReleaseAuditText(), [
        ["Zip Tools", CreateToolsAndPresetsZip],
        ["Build EXE", CreateReleaseExe],
        ["Build Package", BuildReleasePackage],
        ["Clean Folder", CreateCleanReleaseFolder],
        ["Self-Heal", SelfHealSettings]
    ])
}

BuildOneClickReleaseAuditText(*) {
    global _ReleaseIncludeDevTools, _ReleaseMakeZipOnClean, _ReleaseMakeExeOnClean, SCRIPT_VERSION
    zipExists := FileExist(A_ScriptDir "\CSP_Tools_and_AutoAction_Presets.zip")
    pkgPath := LatestReleasePackageZip()
    exePath := ReleaseExeOutputForSource(A_ScriptDir "\Nastarxa_CSP_Animator_Toolkit.ahk")
    exeExists := FileExist(exePath)
    txt := "One-Click Release Audit`r`n"
        . "Read-only release overview. Use this before tagging or sharing a build.`r`n`r`n"
        . "Release Package`r`n"
        . StatusLine(FileExist(A_ScriptDir "\Nastarxa_CSP_Animator_Toolkit.ahk"), "Main script", A_ScriptDir "\Nastarxa_CSP_Animator_Toolkit.ahk")
        . StatusLine(DirExist(A_ScriptDir "\src"), "Source folder", A_ScriptDir "\src")
        . StatusLine(DirExist(A_ScriptDir "\CSP_AutoAction_Presets"), "AutoAction presets folder", A_ScriptDir "\CSP_AutoAction_Presets")
        . StatusLine(DirExist(A_ScriptDir "\CSP_Tools"), "CSP tools folder", A_ScriptDir "\CSP_Tools")
        . StatusLine(!_ReleaseMakeZipOnClean || zipExists, "Tools/presets zip", _ReleaseMakeZipOnClean ? (zipExists ? A_ScriptDir "\CSP_Tools_and_AutoAction_Presets.zip" : "Click Zip Tools or Clean Release Folder") : "Skipped by Dev Tools option")
        . StatusLine(!_ReleaseMakeExeOnClean || exeExists, "Compiled EXE", _ReleaseMakeExeOnClean ? (exeExists ? exePath : "Click Build EXE or Clean Release Folder") : "Skipped by Dev Tools option")
        . StatusLine(pkgPath != "", "Release package zip", pkgPath != "" ? pkgPath : "Click Build Release Package")
        . StatusLine(true, "Dev tools in clean release", _ReleaseIncludeDevTools ? "Included" : "Excluded")
        . StatusLine(true, "Zip on clean release", _ReleaseMakeZipOnClean ? "On" : "Off")
        . StatusLine(true, "EXE on clean release", _ReleaseMakeExeOnClean ? "On" : "Off")
        . "`r`n"
        . BuildSettingsHealthText()
        . "`r`n`r`n"
        . BrokenIconScanText()
        . "`r`n`r`n"
        . BuildPresetTesterText()
        . "`r`n`r`n"
        . BuildFunctionRegistryDoctorText()
    return txt
}

_DevToolsIncluded := true
_DevToolsHandler := ShowDevTools
