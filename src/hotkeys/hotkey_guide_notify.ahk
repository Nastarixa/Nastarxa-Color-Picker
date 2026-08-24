; GUIDE NOTIFY ACTIONS
; ============================================================
; Tooltip notifications that teach/guide each CSP feature. Extracted from hotkey_core.ahk.


ShowGuideNotify(title, text) {
    global NotifyEnabled, NotifyMonitor
    if !NotifyEnabled
        return
    if !FeatureEnabled("guidenotify")
        return
    monOpt := NotifyMonitor > 0 ? " mon=" NotifyMonitor : ""
    Notify.Show(title, text,,,, "pos=BL dur=4 ms=12 mf=Segoe UI Black mfo=norm Bold" monOpt)
}


GuideIBNotify(*) {
    global InbetweenMode
    mode := NormalizeInbetweenMode(InbetweenMode)
    if mode = "Start > End" {
        ShowGuideNotify("Inbetween Mode: Start > End",
        "Start > End:`n"
        "Smaller number layer = above edit layer`n"
        "Bigger number layer = below edit layer`n`n"
        "Ctrl+1: 50 |-----|-----|>`n"
        "Ctrl+2: 66 S>E |-------|---|>`n"
        "Ctrl+3: 33 S>E |---|-------|>`n"
        "Ctrl+4: 75 S>E |--------|--|>`n"
        "Ctrl+5: 25 S>E |--|--------|>`n"
        "Ctrl+6: 60 S>E |------|----|>`n"
        "Ctrl+7: 40 S>E |----|------|>`n"
        "Ctrl+``: Toggle Light Table only")
    } else {
        ShowGuideNotify("Inbetween Mode: End > Start",
        "End > Start:`n"
        "Bigger number layer = above edit layer`n"
        "Smaller number layer = below edit layer`n`n"
        "Ctrl+1: 50 |-----|-----|>`n"
        "Ctrl+2: 33 E>S |---|-------|>`n"
        "Ctrl+3: 66 E>S |-------|---|>`n"
        "Ctrl+4: 25 E>S |--|--------|>`n"
        "Ctrl+5: 75 E>S |--------|--|>`n"
        "Ctrl+6: 40 E>S |----|------|>`n"
        "Ctrl+7: 60 E>S |------|----|>`n"
        "Ctrl+``: Toggle Light Table only")
    }
}

GuideCreateNotify(*) {
    ShowGuideNotify("Create New",
        "Alt+1: New Paper Layer`n"
        "Alt+2: New Raster Layer`n"
        "Alt+3: New Vector Layer`n"
        "Alt+4: New Colored Vector Layer`n"
        "Alt+5: New Dummy Reference Layer`n"
        "Alt+6: Separate Black Line + Paint`n"
        "Alt+7: New Pink Vector Layer`n"
        "Alt+8: New Cyan Vector Layer`n"
        "Alt+9: New Orange Vector Layer`n"
        "Alt+0: New Animation Folder")
}

GuideShortcutNotify(*) {
    ShowGuideNotify("Shortcut",
        "X: Swap Brush Primary/Secondary`n"
        "Shift+C: Reset Color`n"
        "Alt+C: Transparent Color`n"
        "Alt+V: Toggle Layer Visible`n`n"
        "Shift+B: Opacity 100`n"
        "Alt+B: Opacity 50`n"
        "Ctrl+Alt+B: Opacity 25`n"
        "Ctrl+B: Toggle Layer Color`n`n"
        "Ctrl+Shift+Alt+C: Paint Red Line`n"
        "Ctrl+Shift+Alt+V: Paint Green Line`n"
        "Ctrl+Shift+Alt+B: Paint Blue Line`n"
        "Ctrl+Shift+Alt+N: Paint Pink Line`n"
        "Ctrl+Shift+Alt+M: Paint Cyan Line`n"
        "Ctrl+Shift+Alt+,: Paint Orange Line`n"
        "Ctrl+Shift+Alt+.: Paint Purple Line`n"
        "Ctrl+Shift+Alt+F: Paint Alpha/Transparent`n"
        "Ctrl+Shift+Alt+Insert: Set to Paint: Animation`n"
        "Ctrl+Shift+Q: Set as Reference Layer`n"
        "Ctrl+Shift+Alt+Q: Isolate Layer`n"
        "Ctrl+Shift+F: Set as Draft Layer`n"
        "Ctrl+Shift+Alt+': Toggle Draft Layers Visibility`n"
        "Ctrl+Shift+G: Clip to Layer Below`n"
        "Ctrl+Shift+R: Lock Layer`n"
        "Ctrl+Shift+E: Lock Layer Transparent`n"
        "Ctrl+Shift+W: Lock Current Animation Cel`n"
        "Ctrl+Shift+X: Delete Cel from Timeline`n"
        "Shift+X: Delete Cel from Lighttable`n`n"
        "Ctrl+Shift+Alt+D: Duplicate Layer`n"
        "Ctrl+Shift+Alt+G: Create Folder and Insert Layer`n"
        "Ctrl+Alt+G: Ungroup Layer Folder`n"
        "Ctrl+Shift+Alt+R: Transfer Down Vector`n"
        "Ctrl+Shift+Alt+E: Merge Down Layer`n"
        "Ctrl+Shift+Alt+X: Delete Layer`n"
        "Ctrl+Shift+Alt+T: Change Color Expression: Gray`n"
        "Ctrl+;: Rasterize Layer`n"
        "Ctrl+Shift+Alt+[: Vector Paths`n"
        "Ctrl+Shift+Alt+=: Open Folder`n"
        "Ctrl+Shift+Alt+-: Close All Folder`n`n"
        "CapsLock: LightTable`n"
        "Shift+Tab: Reset LightTable")
}

GuideAutoActionNotify(*) {
    ShowGuideNotify("Utility / AutoAction",
        "Ctrl+Shift+1: Keyframe Color (red)`n"
        "Ctrl+Shift+2: Reference Color (orange)`n"
        "Ctrl+Shift+3: Remove Keyframe Color`n"
        "Ctrl+Shift+6: Layer Color Black`n"
        "Ctrl+Shift+Alt+T: Color Expression Gray`n`n"
        "Ctrl+Shift+=: LT Half Color Green`n"
        "Ctrl+Shift+-: LT Half Color Purple`n"
        "Ctrl+Shift+5: LT Color Normal`n`n"
        "Ctrl+Shift+7: Paper Color Purple`n"
        "Ctrl+Shift+8: Paper Color Green`n"
        "Ctrl+Shift+9: Paper Color White`n`n"
        "Ctrl+Shift+Alt+End: Paint Check Layer`n"
        "Ctrl+Shift+Alt+Home: Paint Checker Image`n"
        "Ctrl+Shift+Alt+PageUp: Set Cels to Track")
}

GuideAnimationNotify(*) {
    ShowGuideNotify("Animation Feature",
        "Ctrl+Alt+W: Toggle Lighttable`n"
        "Alt+W: Toggle Onionskin`n`n"
        "Shift+Alt+W: Add Onionskin to Lighttable`n"
        "Shift+X: Delete Lighttable layer`n`n"
        "Alt+A / Alt+D: Previous / Next Cel`n"
        "Ctrl+Alt+A / Ctrl+Alt+D: Previous / Next LT Cel`n"
        "Shift+Alt+S: Change Timeline Settings`n"
        "Ctrl+Shift+Alt+1/2/3: Check Cel Motion")
}

GuideTimerNotify(*) {
    ShowGuideNotify("Timer / Worklog",
        "Ctrl+Alt+Shift+4: Start / Pause Timer`n"
        "Ctrl+Alt+Shift+3: Lap`n"
        "Ctrl+Alt+Shift+2: Stop (Save or Reset)`n"
        "Ctrl+Alt+Shift+1: Save Timer Log`n`n"
        "Ctrl+Alt+Shift+5: Countdown Timer`n"
        "Double-click timer display: Countdown`n`n"
        "Countdown end: popup at mouse + timer resets`n"
        "Lap names editable in the save dialog")
}
