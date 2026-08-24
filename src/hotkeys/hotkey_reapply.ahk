; HOTKEY APPLY ENGINE (HotIf conditions + HK_Reapply*)
; ============================================================
; #HotIf condition functions and the reapply/register pipeline. Extracted from hotkey_core.ahk.


; --- "What fired?" monitor ---
; Ring buffer of the last actions actually invoked, timestamped. Backs the
; What-Fired OSD and the live panel in the Hotkey Stress Test.
global _FiredLog := []
global _FiredLogMax := 40
; What-Fired OSD state: 1 = a brief toast shows the last fired action each time.
global _FiredOSD := 0
global _FiredOSDGui := 0
; Tracks ApplyBlock keys registered by HK_ReapplyApplyBlock() so
; HK_UnregisterAll() can clean them up even when the current mode's
; HK_ApplyBlock is empty (mode switch from a mode with blocks to one without).
global _HK_RegApplyBlockKeys := Map()

HK_FiredEvent(text) {
    global _FiredLog, _FiredOSD
    if text = ""
        return
    _FiredLog.Push(FormatTime(, "HH:mm:ss") "." SubStr(A_MSec + 1000, 2) "  " text)
    while _FiredLog.Length > _FiredLogMax
        _FiredLog.RemoveAt(1)
    if _FiredOSD
        HK_FiredOSDShow(text)
}

HK_LogFired(id) {
    global HK_Registered
    d := HK_FindDef(id)
    desc := IsObject(d) ? d.desc : id
    key := HK_Registered.Get(id, "")
    line := desc
    if key != "" && key != "-"
        line .= "  [" HK_DisplayKey(key) "]"
    HK_FiredEvent(line)
}

; ---- What fired? OSD ----
HK_FiredOSDBuild() {
    global _FiredOSDGui
    if IsObject(_FiredOSDGui)
        return _FiredOSDGui
    g := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x80000")
    g.BackColor := "1E1F22"
    g.SetFont("s" S(9) " cFFFFFF", "Segoe UI")
    g.MarginX := S(12)
    g.MarginY := S(8)
    g.lbl := g.AddText("w" S(440) " Center +0x100 cFFFFFF", "")
    _FiredOSDGui := g
    return g
}

HK_FiredOSDShow(text, dur := 1400) {
    global _FiredOSDGui
    g := HK_FiredOSDBuild()
    g.lbl.Text := text
    g.AutoSize()
    MonitorGetWorkArea(, &ml, &mt, &mr, &mb)
    g.GetPos(, , &w, &h)
    g.Move(mr - w - S(20), mb - h - S(90), w, h)
    g.Show("NoActivate")
    SetTimer(HK_FiredOSDHide, -dur)
}

HK_FiredOSDHide() {
    global _FiredOSDGui
    if IsObject(_FiredOSDGui)
        _FiredOSDGui.Hide()
}

; Persists the OSD toggle to gui_settings.ini.
HK_SaveFiredOSDState() {
    global _FiredOSD, SETTINGS_FILE
    try IniWrite(_FiredOSD ? 1 : 0, SETTINGS_FILE, "Settings", "FiredOSD")
    catch as e
        DebugLog("Failed to save FiredOSD state: " e.Message)
}

; Toggle hotkey target: enables/disables the What-Fired OSD.
HK_ToggleFiredOSD(*) {
    global _FiredOSD
    _FiredOSD := !_FiredOSD
    HK_SaveFiredOSDState()
    ShowNotify("What Fired", _FiredOSD ? "OSD enabled" : "OSD disabled")
    return _FiredOSD
}

; --- Registration-issue aggregator ---
; Every failed/conflicted registration during one reapply pass is collected and
; reported once by HK_IssueReport() (called at the end of HK_ReapplyAll) so the
; user gets a single conflict toast instead of a flood.
global _HK_ApplyIssue := Map()

HK_IssueAdd(id, detail) {
    global _HK_ApplyIssue
    if !_HK_ApplyIssue.Has(id)
        _HK_ApplyIssue[id] := []
    _HK_ApplyIssue[id].Push(detail)
}

HK_IssueReport() {
    global _HK_ApplyIssue, HK_Modes
    if _HK_ApplyIssue.Count = 0
        return
    body := ""
    shown := 0
    for id, details in _HK_ApplyIssue {
        if SubStr(id, 1, 5) = "mode:" {
            mid := SubStr(id, 6)
            m := HK_Modes.Get(mid, 0)
            desc := IsObject(m) ? "Mode: " m.Get("name", mid) : id
        } else {
            d := HK_FindDef(id)
            desc := IsObject(d) ? d.desc : id
        }
        body .= (body = "" ? "" : "`n") desc ": " details[1]
        shown++
        if shown >= 3
            break
    }
    remaining := _HK_ApplyIssue.Count - shown
    if remaining > 0
        body .= "`n...and " remaining " more issue" (remaining = 1 ? "" : "s")
    DebugLog("Hotkey apply issues (" _HK_ApplyIssue.Count "): " body)
    ShowNotify("Hotkey conflicts", body, "0xE53935")
    _HK_ApplyIssue := Map()
}


; --- Re-apply overrides for all groups (call at startup + after save) ---
; Each group function is positioned under its #HotIf so Hotkey() calls get the right context.

HK_BaseCSPCond(*) {
    global HotkeysPaused
    return !PieIsOpen() && !HotkeysPaused && !IsTyping()
}
HotIfConditionCSP(*) {
    return HK_BaseCSPCond() && HK_TargetActive()
}
HotIfConditionPieOpenKey(*) {
    return HK_BaseCSPCond() && HK_TargetActive()
}
HotIfConditionNav(*) {
    global NavEnabled
    return HK_BaseCSPCond() && HK_TargetActive() && NavEnabled
}
HotIfConditionCaps(*) {
    global CapslockEnabled
    return HK_BaseCSPCond() && HK_TargetActive() && CapslockEnabled && FeatureEnabled("capslock")
}
HotIfConditionCSPCapsGuard(*) {
    global CapslockEnabled
    return HotIfConditionCSP() && CapslockEnabled && FeatureEnabled("capslock")
}
HotIfConditionCapsTabBlock(*) {
    return HotIfConditionCaps() && GetKeyState("CapsLock", "P")
}
HotIfConditionCSPTabGuard(*) {
    global TabCombosEnabled
    return HotIfConditionCSP() && TabCombosEnabled && FeatureEnabled("tab")
}
HotIfConditionSelectLayerWindow(*) {
    return WinExist("Select layer")
}
StripModifierPrefix(s) {
    s := Trim(s)
    i := 1
    while i <= StrLen(s) {
        ch := SubStr(s, i, 1)
        if (ch != "~" && ch != "*" && ch != "$" && ch != "<" && ch != ">")
            break
        i++
    }
    return SubStr(s, i)
}

HK_KeyUsesTab(key) {
    key := StrLower(StripModifierPrefix(key))
    return key = "tab" || InStr(key, "tab &") || InStr(key, "& tab") || _EndsWithModifierKey(key, "tab")
}
HK_KeyUsesCapslock(key) {
    key := StrLower(StripModifierPrefix(key))
    return key = "capslock" || InStr(key, "capslock &") || InStr(key, "& capslock") || _EndsWithModifierKey(key, "capslock")
}
_EndsWithModifierKey(key, suffix) {
    n := StrLen(key)
    sLen := StrLen(suffix)
    if n < sLen || SubStr(key, n - sLen + 1) != suffix
        return false
    if n = sLen
        return true
    ch := SubStr(key, n - sLen, 1)
    return ch = "!" || ch = "^" || ch = "+" || ch = "#"
}
HK_SelectHotIf(hotifFn, groupName, key) {
    if groupName = "csp" {
        if HK_KeyUsesTab(key)
            return HotIfConditionCSPTabGuard
        if HK_KeyUsesCapslock(key)
            return HotIfConditionCSPCapsGuard
    }
    return hotifFn
}
HK_DisableHotkeyAllContexts(key) {
    global HK_RegisteredCond
    if key = "" || key = "-"
        return
    for hotifFn in [
        HotIfConditionCSP,
        HotIfConditionPieOpenKey,
        HotIfConditionCSPTabGuard,
        HotIfConditionCSPCapsGuard,
        HotIfConditionNav,
        HotIfConditionCaps,
        HotIfConditionReset,
        HotIfConditionLWin,
        HotIfConditionGlobal,
        HotIfConditionBG
    ] {
        HotIf(hotifFn)
        try Hotkey(key, "Off")
    }
    if IsObject(HK_RegisteredCond) {
        for _, condFn in HK_RegisteredCond {
            HotIf(condFn)
            try Hotkey(key, "Off")
        }
    }
    HotIf()
}

HotIfConditionReset(*) {
    global ResetEnabled
    return HK_BaseCSPCond() && HK_TargetActive() && ResetEnabled
}
HotIfConditionBG(*) {
    return HK_BaseCSPCond() && HK_TargetExists() && !HK_TargetActive()
}
HotIfConditionLWin(*) {
    global LWinEnabled
    return HK_BaseCSPCond() && HK_TargetActive() && LWinEnabled
}
HotIfConditionGlobal(*) {
    return HK_BaseCSPCond()
}
HotIfConditionGlobalCheatSheet(*) {
    ; Cheat sheet toggle (default ^+F2): like the global group but ignores the
    ; typing safeguard so it always toggles, even while focus is in a text field.
    return !PieIsOpen() && !HotkeysPaused
}

HK_ReapplyGroup(hotifFn, groupName) {
    global HK_Registered, HK_RegisteredFn, HK_RegisteredCond, HK_RegisteredTarget, HK_RegisteredAll, TabCombosEnabled
    targeted := (groupName = "csp" || groupName = "csp_nav" || groupName = "csp_caps" || groupName = "csp_reset" || groupName = "csp_lwin")
    wanted := []
    wantedKeys := Map()
    removed := Map()
    disabledKeys := Map()
    for d in HotkeyDefs {
        if d.group != groupName
            continue
        if groupName = "csp_caps" && HK_IsCapslockSlotId(d.id) {
            if HK_Registered.Has(d.id) {
                removed[d.id] := {key: HK_Registered[d.id], cond: HK_RegisteredCond.Get(d.id, 0)}
                try HK_Registered.Delete(d.id)
                try HK_RegisteredFn.Delete(d.id)
                try HK_RegisteredCond.Delete(d.id)
                try HK_RegisteredTarget.Delete(d.id)
            }
            if HK_RegisteredAll.Has(d.id) {
                for _, oldKey in HK_RegisteredAll[d.id] {
                    if oldKey != HK_Registered.Get(d.id, "")
                        removed["__all_" d.id "_" oldKey] := {key: oldKey, cond: 0}
                }
                try HK_RegisteredAll.Delete(d.id)
            }
            continue
        }
        rawKey := HK_ModeEffectiveKey(d.id, HK_Get(d.id, d.def))
        keys := HK_SplitKeys(rawKey)
        fn := HK_GetFn(d)
        fnName := HK_GetFnName(d)
        oldKey := HK_Registered.Has(d.id) ? HK_Registered[d.id] : ""
        oldCond := HK_RegisteredCond.Get(d.id, 0)
        oldAllKeys := HK_RegisteredAll.Has(d.id) ? HK_RegisteredAll[d.id] : []
        target := HK_GetTarget(d.id)

        if HK_IsBlockEnabled(d.id) {
            blockKeys := []
            for _, k in keys {
                bKey := k
                if bKey = "" || bKey = "-"
                    bKey := d.def
                if bKey = "" || bKey = "-"
                    continue
                if wantedKeys.Has(bKey) {
                    prev := wantedKeys[bKey]
                    HK_IssueAdd(prev, "shares hotkey " HK_DisplayKey(bKey) " with " d.id)
                    HK_IssueAdd(d.id, "shares hotkey " HK_DisplayKey(bKey) " with " prev)
                    DebugLog("Hotkey conflict: " prev " and " d.id " both use " bKey)
                    SettingsDiagPush("WARN", "Hotkey conflict", prev " and " d.id " both use " HK_DisplayKey(bKey))
                    continue
                }
                wantedKeys[bKey] := d.id
                bCond := HK_SelectHotIf(hotifFn, groupName, bKey)
                if d.id = "toggle_cheat_sheet" && groupName = "global"
                    bCond := HotIfConditionGlobalCheatSheet
                if targeted
                    bCond := HK_MakeHotKeyCond(bCond, d.id)
                wanted.Push({id:d.id, key:bKey, condFn:bCond, target:target, fn:HK_BlockHotkey, fnName:"HK_BlockHotkey", oldKey:"", blocked:true})
                blockKeys.Push(bKey)
            }
            if blockKeys.Length > 0 {
                for _, ok in oldAllKeys {
                    found := false
                    for _, bk in blockKeys {
                        if ok = bk {
                            found := true
                            break
                        }
                    }
                    if !found
                        removed[d.id "_blk_" ok] := {key: ok, cond: oldCond}
                }
            } else {
                for _, ok in oldAllKeys
                    removed[d.id "_blk_" ok] := {key: ok, cond: oldCond}
                try HK_Registered.Delete(d.id)
                try HK_RegisteredFn.Delete(d.id)
                try HK_RegisteredCond.Delete(d.id)
                try HK_RegisteredTarget.Delete(d.id)
                try HK_RegisteredAll.Delete(d.id)
            }
            continue
        }

        activeKeys := []
        inactiveCount := 0
        for _, k in keys {
            if k = "" || k = "-" {
                inactiveCount++
                continue
            } else if !TabCombosEnabled && HK_KeyUsesTab(k) {
                removed["__tab_" d.id] := {key: k, cond: 0}
                inactiveCount++
                continue
            } else if !HK_IsRequirementEnabled(d) {
                inactiveCount++
                continue
            }
            activeKeys.Push(k)
        }
        if activeKeys.Length = 0 {
            for _, ok in oldAllKeys
                removed[d.id "_reg_" ok] := {key: ok, cond: oldCond}
            if oldKey != ""
                removed[d.id] := {key: oldKey, cond: oldCond}
            else if keys.Length > 0 && keys[1] != "" && keys[1] != "-" && !HK_IsRequirementEnabled(d)
                removed["__req_" d.id] := {key: keys[1], cond: 0}
            try HK_Registered.Delete(d.id)
            try HK_RegisteredFn.Delete(d.id)
            try HK_RegisteredCond.Delete(d.id)
            try HK_RegisteredTarget.Delete(d.id)
            try HK_RegisteredAll.Delete(d.id)
            continue
        }

        registeredKeys := []
        primaryCondFn := 0
        for _, k in activeKeys {
            if wantedKeys.Has(k) {
                prev := wantedKeys[k]
                HK_IssueAdd(prev, "shares hotkey " HK_DisplayKey(k) " with " d.id)
                HK_IssueAdd(d.id, "shares hotkey " HK_DisplayKey(k) " with " prev)
                DebugLog("Hotkey conflict: " prev " and " d.id " both use " k)
                SettingsDiagPush("WARN", "Hotkey conflict", prev " and " d.id " both use " HK_DisplayKey(k))
                continue
            }
            wantedKeys[k] := d.id
            condFn := HK_SelectHotIf(hotifFn, groupName, k)
            if d.id = "toggle_cheat_sheet" && groupName = "global"
                condFn := HotIfConditionGlobalCheatSheet
            if targeted
                condFn := HK_MakeHotKeyCond(condFn, d.id)
            if registeredKeys.Length = 0
                primaryCondFn := condFn
            wanted.Push({id:d.id, key:k, condFn:condFn, target:target, fn:fn, fnName:fnName, oldKey:"", blocked:false})
            registeredKeys.Push(k)
        }

        for _, ok in oldAllKeys {
            found := false
            for _, rk in registeredKeys {
                if ok = rk {
                    found := true
                    break
                }
            }
            if !found
                removed[d.id "_reg_" ok] := {key: ok, cond: oldCond}
        }

        if registeredKeys.Length = 0 {
            for _, ok in oldAllKeys
                removed[d.id "_reg_" ok] := {key: ok, cond: oldCond}
            if oldKey != ""
                removed[d.id] := {key: oldKey, cond: oldCond}
            try HK_Registered.Delete(d.id)
            try HK_RegisteredFn.Delete(d.id)
            try HK_RegisteredCond.Delete(d.id)
            try HK_RegisteredTarget.Delete(d.id)
            try HK_RegisteredAll.Delete(d.id)
        }
    }
    for _, item in removed {
        if IsObject(item.cond) {
            HotIf(item.cond)
            try Hotkey(item.key, "Off")
        } else {
            HK_DisableHotkeyAllContexts(item.key)
        }
        disabledKeys[item.key] := true
        DebugLog("Hotkey off (reapply): " item.key)
    }
    HotIf()
    for w in wanted {
        needRegister := w.fn && (!HK_Registered.Has(w.id) || HK_Registered[w.id] != w.key || HK_RegisteredTarget.Get(w.id, "") != w.target || !HK_RegisteredFn.Has(w.id) || HK_RegisteredFn[w.id] != w.fnName || disabledKeys.Has(w.key))
        if !needRegister
            continue
        try {
            HotIf(w.condFn)
            Hotkey(w.key, w.blocked ? HK_BlockHotkey.Bind(w.id) : HK_Invoke.Bind(w.id))
            if !w.blocked {
                HK_Registered[w.id] := w.key
                HK_RegisteredFn[w.id] := w.fnName
                HK_RegisteredCond[w.id] := w.condFn
                HK_RegisteredTarget[w.id] := w.target
            }
            ; Track all registered keys (blocked and non-blocked) for cleanup
            if !HK_RegisteredAll.Has(w.id)
                HK_RegisteredAll[w.id] := []
            found := false
            for _, ek in HK_RegisteredAll[w.id] {
                if ek = w.key {
                    found := true
                    break
                }
            }
            if !found
                HK_RegisteredAll[w.id].Push(w.key)
            if w.blocked
                DebugLog("Block registered: " w.id " swallows " w.key)
        } catch as e {
            HK_IssueAdd(w.id, "failed to register " w.key)
            DebugLog("HK_ReapplyGroup: failed to register " w.id " as " w.key " - " e.Message)
            SettingsDiagPush("ERR", "Hotkey register failed", w.id " as " w.key ": " e.Message)
        }
    }
    HotIf()
}

HK_IsCapslockSlotId(id) {
    return SubStr(id, 1, 9) = "caps_num_"
}

HK_Invoke(id, *) {
    d := HK_FindDef(id)
    if !HK_IsRequirementEnabled(d)
        return
    if HK_FeatureHotkeyBlocked(id)
        return
    fn := HK_GetFn(d)
    if fn {
        if SubStr(id, 1, 8) = "feature_"
            DebugLog("INVOKE fired: " id " (" HK_Registered.Get(id, "?") ")")
        fn.Call()
        HK_LogFired(id)
    }
}

; Consumes the keypress entirely so CSP never sees it. The action is not run;
; this is the "Block output to CSP" mode, distinct from disabled ("-") which
; leaves the key native to CSP.
HK_BlockHotkey(id, *) {
    HK_LogFired(id)
    DebugLog("BLOCK fired: " id " (" HK_Registered.Get(id, "?") ")")
}

HK_IsBlockEnabled(id) {
    global HK_CustomBlock
    return HK_CustomBlock.Has(id) && HK_CustomBlock[id]
}

HK_GetActivate(id) {
    global HK_CustomActivate
    if HK_CustomActivate.Has(id)
        return HK_CustomActivate[id] ? true : false
    d := HK_FindDef(id)
    return HK_DefaultActivate(d)
}

HK_DefaultActivate(d) {
    return IsObject(d) && d.HasOwnProp("activate") && d.activate ? true : false
}

HK_ActivateWrapper(id, *) {
    global HK_TargetWindows
    HK_EnsureTargetDefaults()
    t := HK_GetTarget(id)
    target := ""
    if t = "any" {
        target := HK_DefaultTargetWinTitle()
        if !WinExist(target)
            target := "ahk_exe CLIPStudioPaint.exe"
    } else {
        entry := (t != "" && HK_TargetWindows.Has(t)) ? HK_TargetWindows[t] : HK_TargetWindows.Get("win1", Map())
        exes := HK_TargetExeList(entry)
        for exe in exes
            if WinExist("ahk_exe " exe) {
                target := "ahk_exe " exe
                break
            }
        if target = ""
            target := "ahk_exe " (exes.Length ? exes[1] : "CLIPStudioPaint.exe")
    }
    if !WinActive(target) {
        WinActivate(target)
        WinWaitActive(target,, 2.0)
        Sleep 80
    }
    HK_Invoke(id)
}

HK_ReapplyActivate() {
    global HK_Registered, HK_RegisteredFn, HotkeyDefs, HK_RegisteredAll
    wanted := []
    wantedKeys := Map()
    removed := Map()
    for d in HotkeyDefs {
        if !HK_GetActivate(d.id)
            continue
        if d.group = "bg"
            continue
        actId := d.id "_activate"
        rawKey := HK_ModeEffectiveKey(d.id, HK_Get(d.id, d.def))
        keys := HK_SplitKeys(rawKey)
        activeKeys := []
        for _, k in keys {
            if k = "" || k = "-" || !HK_IsRequirementEnabled(d) {
                continue
            }
            activeKeys.Push(k)
        }
        if activeKeys.Length = 0 {
            if HK_Registered.Has(actId)
                removed[actId] := HK_Registered[actId]
            if HK_RegisteredAll.Has(actId) {
                for _, ok in HK_RegisteredAll[actId]
                    removed[actId "_all_" ok] := ok
                try HK_RegisteredAll.Delete(actId)
            }
            continue
        }
        for _, k in activeKeys {
            if wantedKeys.Has(k) {
                prev := wantedKeys[k]
                HK_IssueAdd(prev, "shares activate hotkey " HK_DisplayKey(k) " with " actId)
                HK_IssueAdd(actId, "shares activate hotkey " HK_DisplayKey(k) " with " prev)
                continue
            }
            wantedKeys[k] := actId
            wanted.Push({id:actId, key:k})
        }
        oldAllKeys := HK_RegisteredAll.Has(actId) ? HK_RegisteredAll[actId] : []
        for _, ok in oldAllKeys {
            found := false
            for _, k in activeKeys {
                if ok = k {
                    found := true
                    break
                }
            }
            if !found
                removed[actId "_all_" ok] := ok
        }
    }
    for actId, oldKey in removed {
        HotIf(HotIfConditionBG)
        try Hotkey(oldKey, "Off")
        try HK_Registered.Delete(actId)
        try HK_RegisteredFn.Delete(actId)
    }
    HotIf(HotIfConditionBG)
    for item in wanted {
        if HK_Registered.Has(item.id) && HK_Registered[item.id] = item.key
            continue
        try {
            Hotkey(item.key, HK_ActivateWrapper.Bind(SubStr(item.id, 1, -9)))
            HK_Registered[item.id] := item.key
            HK_RegisteredFn[item.id] := "HK_ActivateWrapper"
        } catch as e {
            HK_IssueAdd(item.id, "failed to register activate hotkey")
            DebugLog("HK_ReapplyActivate: failed to register " item.id " - " e.Message)
            SettingsDiagPush("ERR", "Hotkey register failed", item.id " activate: " e.Message)
        }
    }
    HotIf()
}

HK_ReapplyCSP()    => HK_ReapplyGroup(HotIfConditionCSP,    "csp")
HK_ReapplyNav()    => HK_ReapplyGroup(HotIfConditionNav,    "csp_nav")
HK_ReapplyCaps() {
    HK_ReapplyGroup(HotIfConditionCaps, "csp_caps")
    HK_ReapplyCoreHoldKeys()
}

HK_ReapplyCoreHoldKeys() {
    global _capslockPollEnabled, TabCombosEnabled
    ; Keep physical hold detectors protected from custom override / pie cleanup drift.
    HotIf(HotIfConditionCaps)
    try Hotkey("*CapsLock", CapslockMod, "On")
    HotIf(HotIfConditionCSPTabGuard)
    try Hotkey("$Tab", "Off")
    try Hotkey("$#Tab", "Off")
    if TabCombosEnabled {
        try Hotkey("$Tab", TabKeyHandler, "On")
        try Hotkey("$#Tab", WinTabHandler, "On")
    }
    HotIf()
    _capslockPollEnabled := false
    SetTimer(CapslockHoldPoll, 0)
}
HK_ReapplyCapsTabBlock() {
    global _capslockAssignedBlockKeys
    HotIf(HotIfConditionCapsTabBlock)
    for _, keyName in _capslockAssignedBlockKeys
        try Hotkey("$*" keyName, "Off")
    _capslockAssignedBlockKeys := []
    static blockedKeys := [
        "Tab", "Space", "Enter", "Escape", "Backspace", "Delete", "Insert",
        "Home", "End", "PgUp", "PgDn", "Up", "Down", "Left", "Right",
        "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
        "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
        "[", "]", "\", ";", "'", ",", ".", "/",
        "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
        "Numpad0", "Numpad1", "Numpad2", "Numpad3", "Numpad4", "Numpad5",
        "Numpad6", "Numpad7", "Numpad8", "Numpad9", "NumpadDot", "NumpadDiv",
        "NumpadMult", "NumpadAdd", "NumpadSub", "NumpadEnter"
    ]
    for keyName in blockedKeys
        try Hotkey("$*" keyName, BlockCapslockTab, "On")
    for _, keyName in CapslockAssignedKeyNames() {
        try {
            Hotkey("$*" keyName, BlockCapslockTab, "On")
            _capslockAssignedBlockKeys.Push(keyName)
        }
    }
    HotIf()
}
HK_ReapplyTab() {
    try Pie_ReapplyHotkeys()
    try PieQuickReapplyHotkeys()
}
HK_ReapplyReset()  => HK_ReapplyGroup(HotIfConditionReset,  "csp_reset")
HK_ReapplyLWin()   => HK_ReapplyGroup(HotIfConditionLWin,   "csp_lwin")
HK_ReapplyGlobal() => HK_ReapplyGroup(HotIfConditionGlobal, "global")
HK_ReapplyBG()     => HK_ReapplyGroup(HotIfConditionBG,     "bg")

; Universal teardown: unregisters every hotkey the toolkit currently has live,
; across all subsystems (def hotkeys, block hotkeys, activate hotkeys, pie open
; keys, quick-pie keys, mode-switch keys, capslock-tab blocks, core hold keys,
; ctrl+num blocks). Each variant is disabled under its exact stored HotIf
; criteria (AHK only turns off the variant matching the current context), then
; all bookkeeping maps are cleared. Called at the start of every reapply pass so
; registration is always a clean full rebuild — nothing can leak into a mode
; from a previous mode, profile, pie/quickpie edit or settings change.
HK_UnregisterAll() {
    global HK_Registered, HK_RegisteredFn, HK_RegisteredCond, HK_RegisteredTarget, HK_RegisteredAll
    global HK_RegisteredModeHotkey, PieRegistered, PieQuickRegistered
    global _capslockAssignedBlockKeys, _HK_RegApplyBlockKeys
    ; 1) def hotkeys + activate hotkeys, each under its stored per-def criteria
    if IsObject(HK_RegisteredAll) {
        for id, keys in HK_RegisteredAll {
            cond := HK_RegisteredCond.Get(id, 0)
            if IsObject(cond) {
                HotIf(cond)
                for _, key in keys
                    try Hotkey(key, "Off")
            } else {
                for _, key in keys
                    HK_DisableHotkeyAllContexts(key)
            }
        }
    }
    if IsObject(HK_Registered) {
        for id, key in HK_Registered {
            if HK_RegisteredAll.Has(id)
                continue
            cond := HK_RegisteredCond.Get(id, 0)
            if IsObject(cond) {
                HotIf(cond)
                try Hotkey(key, "Off")
            } else {
                HK_DisableHotkeyAllContexts(key)
            }
        }
    }
    HotIf()
    ; 2) pie open hotkeys (HotIfConditionPieOpenKey context)
    if IsObject(PieRegistered) {
        for _, key in PieRegistered
            PieDisableHotkey(key)
        PieRegistered := Map()
    }
    ; 3) quick-pie hotkeys (HotIf(PieIsOpen) context)
    if IsObject(PieQuickRegistered)
        PieQuickDisableAll()
    ; 4) mode-switch hotkeys (HotIfConditionGlobal context)
    if IsObject(HK_RegisteredModeHotkey) {
        HotIf(HotIfConditionGlobal)
        for _, key in HK_RegisteredModeHotkey
            try Hotkey(key, "Off")
        HotIf()
        HK_RegisteredModeHotkey := Map()
    }
    ; 5) capslock-tab block keys (HotIfConditionCapsTabBlock context)
    HotIf(HotIfConditionCapsTabBlock)
    if IsObject(_capslockAssignedBlockKeys) {
        for _, keyName in _capslockAssignedBlockKeys
            try Hotkey("$*" keyName, "Off")
    }
    HotIf()
    _capslockAssignedBlockKeys := []
    ; 6) core hold keys (*CapsLock under HotIfConditionCaps, $Tab/$#Tab under
    ;    HotIfConditionCSPTabGuard)
    HotIf(HotIfConditionCaps)
    try Hotkey("*CapsLock", "Off")
    HotIf(HotIfConditionCSPTabGuard)
    try Hotkey("$Tab", "Off")
    try Hotkey("$#Tab", "Off")
    HotIf()
    ; 7) apply block keys — unregister ALL previously registered block keys
    ; (not just the current mode's HK_ApplyBlock) to handle mode switches from
    ; a mode with ApplyBlock entries to one without.
    for keyName, _ in _HK_RegApplyBlockKeys {
        HotIf(HotIfConditionCSP)
        try Hotkey("$" keyName, "Off")
        HotIf()
        try Hotkey("$" keyName, "Off")
    }
    _HK_RegApplyBlockKeys := Map()
    ; 8) reset registration bookkeeping so the rebuild registers everything
    HK_Registered := Map()
    HK_RegisteredFn := Map()
    HK_RegisteredCond := Map()
    HK_RegisteredTarget := Map()
    HK_RegisteredAll := Map()
}

; Registers all Apply Block hotkeys. Keys are registered before the normal
; hotkey groups so they take precedence when the condition is met.
; scope="target" → registered under HotIfConditionCSP (CSP window only)
; scope="global" → registered with no condition (always active)
HK_ReapplyApplyBlock() {
    global HK_ApplyBlock, _HK_RegApplyBlockKeys
    _HK_RegApplyBlockKeys := Map()
    if !FeatureEnabled("applyblock") {
        HotIf()
        return
    }
    for keyName, scope in HK_ApplyBlock {
        _HK_RegApplyBlockKeys[keyName] := scope
        if scope = "global" {
            HotIf()
        } else {
            HotIf(HotIfConditionCSP)
        }
        try Hotkey("$" keyName, _HK_ApplyBlockSink, "On")
    }
    HotIf()
}

_HK_ApplyBlockSink(*) {
}

HK_ApplyBlockSetState(enabled) {
    global HK_ApplyBlock, _HK_RegApplyBlockKeys
    for keyName, scope in HK_ApplyBlock {
        if scope = "global" {
            HotIf()
        } else {
            HotIf(HotIfConditionCSP)
        }
        try Hotkey("$" keyName, _HK_ApplyBlockSink, enabled ? "On" : "Off")
    }
    HotIf()
}

HK_ReapplyAll() {
    global _HK_ApplyIssue, _HK_FeatureBlockCache
    DebugLog("HK_ReapplyAll: start (mode='" HK_ModeActive() "', paused=" (HotkeysPaused ? "yes" : "no") ")")
    _HK_ApplyIssue := Map()
    _HK_FeatureBlockCache := Map()
    HK_UnregisterAll()
    HK_ReapplyCSP()
    HK_ReapplyNav()
    HK_ReapplyCaps()
    HK_ReapplyCapsTabBlock()
    HK_ReapplyTab()
    HK_ReapplyReset()
    HK_ReapplyLWin()
    HK_ReapplyGlobal()
    HK_ReapplyBG()
    HK_ReapplyApplyBlock()
    HK_ReapplyActivate()
    HK_ApplyRequirements()
    HK_ReapplyCoreHoldKeys()
    HK_RegisterModeHotkeys()
    if FeatureEnabled("selectlayer")
        HK_ReapplySelectLayerWindow()
    ; If CapsLock hold is active, ApplyBlock must stay Off so the hold
    ; engine can send its Ctrl+Shift+Alt+key combos without interception.
    ; Also re-disable CSP group hotkeys so number keys pass through.
    global _capslockModActive
    if _capslockModActive {
        HK_ApplyBlockSetState(false)
        _CapsLockDisableCSPHotkeys(true)
    }
    HK_IssueReport()
    DebugLog("HK_ReapplyAll: done (" HK_Registered.Count " registered)")
}

HK_ReapplySelectLayerWindow() {
    HotIf(HotIfConditionSelectLayerWindow)
    try Hotkey("$LCtrl", SelectLayerWindowCtrlToEnter, "On")
    try Hotkey("$RCtrl", SelectLayerWindowCtrlToEnter, "On")
    HotIf()
}
SelectLayerWindowCtrlToEnter(*) {
    Send("{Tab}")
    Sleep 50
    Send("{Enter}")
}

HK_ApplyRequirements() {
    global ReqAnimationEnabled, ReqNastarEnabled, HK_Registered, HK_RegisteredFn, HK_RegisteredCond, HK_RegisteredTarget
    groups := Map(
        HotIfConditionCSP, "csp",
        HotIfConditionNav, "csp_nav",
        HotIfConditionCaps, "csp_caps",
        HotIfConditionReset, "csp_reset",
        HotIfConditionLWin, "csp_lwin",
        HotIfConditionGlobal, "global",
        HotIfConditionBG, "bg"
    )
    for hotifFn, groupName in groups {
        HotIf(hotifFn)
        for d in HotkeyDefs {
            if d.group = groupName {
                if HK_IsBlockEnabled(d.id)
                    continue
                if !HK_IsRequirementEnabled(d) {
                    key := HK_Get(d.id, d.def)
                    HK_DisableHotkeyAllContexts(key)
                    try HK_Registered.Delete(d.id)
                    try HK_RegisteredFn.Delete(d.id)
                    try HK_RegisteredCond.Delete(d.id)
                    try HK_RegisteredTarget.Delete(d.id)
                }
            }
        }
    }
    HotIf(HotIfConditionBG)
    for d in HotkeyDefs {
        if HK_GetActivate(d.id) && d.group != "bg" && !HK_IsRequirementEnabled(d) {
            actId := d.id "_activate"
            if HK_Registered.Has(actId) {
                HK_DisableHotkeyAllContexts(HK_Registered[actId])
                try HK_Registered.Delete(actId)
                try HK_RegisteredFn.Delete(actId)
            }
        }
    }
    HotIf()
}
