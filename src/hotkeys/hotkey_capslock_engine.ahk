; CAPSLOCK SLOT ENGINE + CORE HOLD DETECTION
; ============================================================
; CapsLock mod/slot dispatch, hold overlay, SpacePan, Tab handling and modifier reset.
; Extracted from hotkey_core.ahk. Fully internal cluster (0 external references).


; Groups:
;   csp       = WinActive("ahk_exe CLIPStudioPaint.exe")
;   csp_nav   = ... && NavEnabled && !IsTyping()
;   csp_caps  = ... && CapslockEnabled && !IsTyping()
;   csp_tab   = ... && TabCombosEnabled && !IsTyping()
;   csp_reset = ... && ResetEnabled
;   bg        = WinExist(...) && !WinActive(...)
;   global    = (none)

; --- Extracted inline handlers ---
SpacePan(*) {
    Send("{Space Down}{LButton Down}")
    KeyWait("Space")
    Send("{LButton Up}{Space Up}{Ctrl Up}")
}
SpacePanCtrl(*) {
    Send("{Ctrl Down}{Space Down}{LButton Down}")
    KeyWait("Space")
    Send("{LButton Up}{Space Up}{Ctrl Up}")
}
SpacePanShiftAlt(*) {
    Send("{Shift Down}{Alt Down}{Space Down}{LButton Down}")
    KeyWait("Space")
    Send("{LButton Up}{Space Up}{Alt Up}{Shift Up}")
}

; Disables or re-enables all "csp" group hotkeys so physical keystrokes
; pass through to CSP during CapsLock hold. Uses HK_RegisteredAll to
; cover multi-shortcut hotkeys (e.g. !w|^!w).
_CapsLockDisableCSPHotkeys(disable) {
    global HK_RegisteredAll, HK_RegisteredCond
    for id, keys in HK_RegisteredAll {
        d := HK_FindDef(id)
        if IsObject(d) && d.group = "csp" {
            cond := HK_RegisteredCond.Get(id, 0)
            if IsObject(cond) {
                HotIf(cond)
                for _, key in keys
                    try Hotkey(key, disable ? "Off" : "On")
            }
        }
    }
    HotIf()
}

CapslockMod(*) {
    global _capslockModActive, HOLD_THRESHOLD_MS, _capslockSlotConsumed, _capsBlockOutput
    if IsTyping() {
        if !_capsBlockOutput
            Send("{CapsLock}")
        return
    }
    _capslockSlotConsumed := false
    initialState := GetKeyState("CapsLock", "T")
    holdStarted := false
    _HoldOverlayShow("CapsLock", HOLD_THRESHOLD_MS)
    while GetKeyState("CapsLock", "P") {
        if _capslockSlotConsumed {
            _HoldOverlayDestroy()
            if holdStarted {
                _capslockModActive := false
                Send("{Alt Up}{Shift Up}{Ctrl Up}")
                HK_ApplyBlockSetState(true)
                _CapsLockDisableCSPHotkeys(false)
                SetCapsLockState(initialState ? "On" : "Off")
            }
            return
        }
        if assignedSlot := CapslockAssignedSlotPressed(&assignedKey) {
            _HoldOverlayDestroy()
            if holdStarted {
                _capslockModActive := false
                Send("{Alt Up}{Shift Up}{Ctrl Up}")
                HK_ApplyBlockSetState(true)
                _CapsLockDisableCSPHotkeys(false)
                SetCapsLockState(initialState ? "On" : "Off")
            }
            CapslockRunSlot(assignedSlot)
            try KeyWait(assignedKey)
            return
        }
        if PieIsOpen() {
            ; A custom CapsLock chord may have opened a pie/menu; exit early.
            if holdStarted {
                _capslockModActive := false
                Send("{Alt Up}{Shift Up}{Ctrl Up}")
                HK_ApplyBlockSetState(true)
                _CapsLockDisableCSPHotkeys(false)
                SetCapsLockState(initialState ? "On" : "Off")
            }
            break
        }
        if !holdStarted && (A_TimeSinceThisHotkey > HOLD_THRESHOLD_MS || CapslockAllowedKeyPressed()) {
            holdStarted := true
            _capslockModActive := true
            SetCapsLockState("AlwaysOff")
            Send("{Ctrl Down}{Shift Down}{Alt Down}")
            HK_ApplyBlockSetState(false)
            _CapsLockDisableCSPHotkeys(true)
            _HoldOverlayDone(100)
            ShowNotify("Capslock","LightTable 1-2-3")
        }
        if !holdStarted
            _HoldOverlayTick(A_TimeSinceThisHotkey, HOLD_THRESHOLD_MS)
        Sleep(5)
    }
    _HoldOverlayDestroy()
    if PieIsOpen() {
        if holdStarted {
            _capslockModActive := false
            Send("{Alt Up}{Shift Up}{Ctrl Up}")
            HK_ApplyBlockSetState(true)
            _CapsLockDisableCSPHotkeys(false)
            SetCapsLockState(initialState ? "On" : "Off")
        }
        return  ; A custom CapsLock chord opened a pie/menu; don't toggle CapsLock state.
    }
    if holdStarted {
        _capslockModActive := false
        ; Release Alt first so a late Tab press cannot become Windows Alt+Tab.
        Send("{Alt Up}{Shift Up}{Ctrl Up}")
        HK_ApplyBlockSetState(true)
        _CapsLockDisableCSPHotkeys(false)
        SetCapsLockState(initialState ? "On" : "Off")
    } else if !_capsBlockOutput {
        SetCapsLockState(initialState ? "Off" : "On")
    }
}

CapslockSlot1(*) => CapslockRunSlot("1")
CapslockSlot2(*) => CapslockRunSlot("2")
CapslockSlot3(*) => CapslockRunSlot("3")
CapslockSlot4(*) => CapslockRunSlot("4")
CapslockSlot5(*) => CapslockRunSlot("5")
CapslockSlot6(*) => CapslockRunSlot("6")
CapslockSlot7(*) => CapslockRunSlot("7")
CapslockSlot8(*) => CapslockRunSlot("8")
CapslockSlot9(*) => CapslockRunSlot("9")
CapslockSlot0(*) => CapslockRunSlot("0")
CapslockSlotBacktick(*) => CapslockRunSlot("backtick")

CapslockRunSlot(slot) {
    global CapslockSlotActions
    slot := Trim(slot)
    if !CapslockSlotActions.Has(slot)
        return
    item := CapslockSlotActions[slot]
    if !IsObject(item) || !item.Get("enabled", 0)
        return
    slotLabel := slot = "backtick" ? "``" : slot
    req := HK_NormalizeRequirement(item.Get("requirement", ""))
    if req != "" && !PieRequirementEnabled(req) {
        DebugLog("CapsLock + " slotLabel " blocked by requirement: " req)
        return
    }
    type := StrLower(Trim(item.Get("type", "disabled")))
    action := Trim(item.Get("action", ""))
    if type = "disabled" || action = ""
        return
    ToolkitRunAction(type, action, item.Get("label", "CapsLock + " slotLabel))
}

CapslockHoldPoll(*) {
    global _capslockPollDown, _capslockPollStarted, _capslockPollStart, _capslockPollInitialState, _capslockSlotConsumed
    global _capslockModActive, HOLD_THRESHOLD_MS, _capsBlockOutput

    isDown := GetKeyState("CapsLock", "P")
    isActive := HotIfConditionCaps()

    if IsTyping() && !_capslockPollStarted {
        if _capslockPollDown {
            _HoldOverlayDestroy()
            _capslockPollDown := false
        }
        return
    }

    if !isDown {
        _capslockSlotConsumed := false
        if !_capslockPollDown
            return
        _HoldOverlayDestroy()
        if _capslockPollStarted {
            _capslockModActive := false
            Send("{Alt Up}{Shift Up}{Ctrl Up}")
            HK_ApplyBlockSetState(true)
            _CapsLockDisableCSPHotkeys(false)
            SetCapsLockState(_capslockPollInitialState ? "On" : "Off")
        } else if isActive && !_capsBlockOutput {
            SetCapsLockState(_capslockPollInitialState ? "Off" : "On")
        }
        _capslockPollDown := false
        _capslockPollStarted := false
        return
    }

    if !isActive {
        ; Once a physical CapsLock hold has begun, keep Ctrl+Shift+Alt down
        ; until CapsLock is physically released. Pie menus/focus changes can
        ; make HotIfConditionCaps() false mid-hold, but should not fight the user.
        if _capslockPollDown && _capslockPollStarted
            return
        if _capslockPollDown {
            _HoldOverlayDestroy()
            _capslockPollDown := false
            _capslockPollStarted := false
        }
        return
    }

    if !_capslockPollDown {
        _capslockSlotConsumed := false
        _capslockPollDown := true
        _capslockPollStarted := false
        _capslockPollStart := A_TickCount
        _capslockPollInitialState := GetKeyState("CapsLock", "T")
        _HoldOverlayShow("CapsLock", HOLD_THRESHOLD_MS)
    }

    if assignedSlot := CapslockAssignedSlotPressed(&assignedKey) {
        _HoldOverlayDestroy()
        if _capslockPollStarted {
            _capslockModActive := false
            Send("{Alt Up}{Shift Up}{Ctrl Up}")
            HK_ApplyBlockSetState(true)
            _CapsLockDisableCSPHotkeys(false)
            SetCapsLockState(_capslockPollInitialState ? "On" : "Off")
        }
        CapslockRunSlot(assignedSlot)
        _capslockPollDown := false
        _capslockPollStarted := false
        try KeyWait(assignedKey)
        return
    }

    elapsed := A_TickCount - _capslockPollStart
    if !_capslockPollStarted && (elapsed >= HOLD_THRESHOLD_MS || CapslockAllowedKeyPressed()) {
        _capslockPollStarted := true
        _capslockModActive := true
        SetCapsLockState("AlwaysOff")
        Send("{Ctrl Down}{Shift Down}{Alt Down}")
        HK_ApplyBlockSetState(false)
        _CapsLockDisableCSPHotkeys(true)
        _HoldOverlayDone(100)
        ShowNotify("Capslock", "LightTable 1-2-3")
    }
    if !_capslockPollStarted
        _HoldOverlayTick(elapsed, HOLD_THRESHOLD_MS)
}
CapslockAllowedKeyPressed() {
    static allowedKeys := ["SC029", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "="]
    for keyName in allowedKeys {
        if GetKeyState(keyName, "P") {
            slot := CapslockSlotFromKeyName(keyName)
            if slot != "" && CapslockSlotConfigured(slot)
                continue
            return true
        }
    }
    return false
}

CapslockSlotFromKeyName(keyName) {
    keyName := StrLower(Trim(keyName))
    if keyName = "sc029"
        return "backtick"
    if StrLen(keyName) = 1 && IsNumber(keyName)
        return keyName
    return ""
}

CapslockKeyNameForSlot(slot) {
    slot := Trim(slot)
    return slot = "backtick" ? "SC029" : slot
}

CapslockSlotConfigured(slot) {
    global CapslockSlotActions
    slot := Trim(slot)
    if !CapslockSlotActions.Has(slot)
        return false
    item := CapslockSlotActions[slot]
    if !IsObject(item) || !item.Get("enabled", 0)
        return false
    type := ToolkitNormalizeActionType(item.Get("type", "disabled"))
    action := Trim(item.Get("action", ""))
    return type != "disabled" && action != ""
}

CapslockAssignedKeyNames() {
    global CapslockSlotActions
    keys := []
    for slot, item in CapslockSlotActions {
        slot := HK_NormalizeCapslockSlotId(slot)
        if CapslockSlotConfigured(slot)
            keys.Push(CapslockKeyNameForSlot(slot))
    }
    return keys
}

CapslockAssignedSlotPressed(&pressedKey := "") {
    global CapslockSlotActions
    static slotKeys := [
        ["backtick", "SC029"],
        ["1", "1"], ["2", "2"], ["3", "3"], ["4", "4"], ["5", "5"],
        ["6", "6"], ["7", "7"], ["8", "8"], ["9", "9"], ["0", "0"]
    ]
    for pair in slotKeys {
        slot := pair[1], keyName := pair[2]
        if !GetKeyState(keyName, "P")
            continue
        if !CapslockSlotActions.Has(slot)
            continue
        item := CapslockSlotActions[slot]
        if !IsObject(item) || !item.Get("enabled", 0)
            continue
        type := ToolkitNormalizeActionType(item.Get("type", "disabled"))
        action := Trim(item.Get("action", ""))
        if type = "disabled" || action = ""
            continue
        pressedKey := keyName
        return slot
    }
    pressedKey := ""
    return ""
}
BlockCapslockTab(*) {
    global _capslockSlotConsumed, _capslockModActive, _capslockPollStarted, _capslockPollDown, _capslockPollInitialState
    slot := CapslockSlotFromKeyName(StripModifierPrefix(A_ThisHotkey))
    if slot != "" && CapslockSlotConfigured(slot) {
        _capslockSlotConsumed := true
        _HoldOverlayDestroy()
        if _capslockModActive || _capslockPollStarted {
            _capslockModActive := false
            _capslockPollStarted := false
            _capslockPollDown := false
            Send("{Alt Up}{Shift Up}{Ctrl Up}")
            SetCapsLockState(_capslockPollInitialState ? "On" : "Off")
        }
        CapslockRunSlot(slot)
        try KeyWait(CapslockKeyNameForSlot(slot))
        return
    }
    ; Swallow wrong keys while CapsLock is held without changing the held modifiers.
    ; CapslockMod() releases Ctrl/Shift/Alt when CapsLock itself is released.
}
PaperColorShiftCtrlClick() {
    Sleep(80)
    Send("{Ctrl Down}{Shift Down}{LButton Down}{LButton Up}{Shift Up}{Ctrl Up}")
}

TabKeyHandler(*) {
    global HOLD_THRESHOLD_MS, _tabModActive, _tabBlockPassthrough, PieHotkeys
    if IsTyping() {
        if !_tabBlockPassthrough
            Send("{Blind}{Tab}")
        return
    }
    if GetKeyState("LWin", "P") || GetKeyState("RWin", "P") {
        WinTabHandler()
        return
    }
    if GetKeyState("Shift", "P") || GetKeyState("Ctrl", "P") || GetKeyState("Alt", "P") {
        if !_tabBlockPassthrough
            Send("{Blind}{Tab}")
        return
    }
    if GetKeyState("CapsLock", "P") {
        ShowPieMenu(1)
        return
    }
    _tabModActive := true
    _HoldOverlayShow("Tab", HOLD_THRESHOLD_MS)
    while GetKeyState("Tab", "P") && A_TimeSinceThisHotkey < HOLD_THRESHOLD_MS {
        _HoldOverlayTick(A_TimeSinceThisHotkey, HOLD_THRESHOLD_MS)
        Sleep(5)
    }
    _HoldOverlayDestroy()
    if GetKeyState("Tab", "P") {
        tabPieIndex := 0
        Loop PieHotkeys.Length {
            key := PieHotkeys[A_Index]
            if key != "" && StrLower(StripModifierPrefix(key)) = "tab" {
                tabPieIndex := A_Index
                break
            }
        }
        if tabPieIndex > 0
            ShowPieMenu(tabPieIndex)
        else if !_tabBlockPassthrough
            Send("{Tab}")
        KeyWait("Tab")
    } else if !_tabBlockPassthrough {
        Send("{Tab}")
    }
    _tabModActive := false
}

WinTabHandler(*) {
    ; Explicitly send Task View because the Tab hold hook can swallow native Win+Tab.
    Send("{LWin Down}{Tab}{LWin Up}")
}

ResetModifiers(*) {
    Send("{LControl Up}{RControl Up}{LShift Up}{RShift Up}{LAlt Up}{RAlt Up}{LWin Up}{RWin Up}{Ctrl Up}{Shift Up}{Alt Up}{LButton Up}{RButton Up}{Space Up}{MButton Up}")
    ShowNotify("Reset Keys","All modifiers released")
}

ReleaseHeldInputs(*) {
    Send("{LButton Up}{RButton Up}{MButton Up}{Space Up}{LControl Up}{RControl Up}{LShift Up}{RShift Up}{LAlt Up}{RAlt Up}{LWin Up}{RWin Up}{Ctrl Up}{Shift Up}{Alt Up}")
}

; --- Hold overlay progress bar ---
global _HoldOverlay := 0
global _HoldOverlayBar := 0
global _HoldOverlayKey := ""
global _HoldOverlayKeyText := 0

_HoldOverlayShow(key, thresholdMs) {
    global _HoldOverlay, _HoldOverlayBar, _HoldOverlayKey, _HoldOverlayKeyText
    _HoldOverlayKey := key
    if !IsObject(_HoldOverlay) {
        _HoldOverlay := Gui("+AlwaysOnTop -Caption +ToolWindow +DPIScale +Border")
        _HoldOverlay.BackColor := "1E1F22"
        _HoldOverlay.SetFont("s8 cAAAAAA", "Segoe UI")
        _HoldOverlay.MarginX := 6
        _HoldOverlay.MarginY := 4
        _HoldOverlayKeyText := _HoldOverlay.AddText("xm Center w130", "")
        _HoldOverlayBar := _HoldOverlay.AddProgress("xm w80 h6 Background333333 c4CAF50", 0)
    }
    _HoldOverlayKeyText.Value := "Hold " key " " thresholdMs "ms"
    _HoldOverlayBar.Value := 0
    _HoldOverlay.Show("NoActivate x" (A_ScreenWidth//2 - 50) " y" (A_ScreenHeight - 100))
}
_HoldOverlayTick(elapsed, threshold) {
    global _HoldOverlayBar
    if !IsObject(_HoldOverlayBar)
        return
    pct := Min(100, elapsed / threshold * 100)
    _HoldOverlayBar.Value := pct
}
_HoldOverlayDone(pct := 100) {
    global _HoldOverlayBar
    if IsObject(_HoldOverlayBar) {
        _HoldOverlayBar.Value := pct
        _HoldOverlayBar.Opt("c4CAF50")
    }
}
_HoldOverlayDestroy() {
    global _HoldOverlay, _HoldOverlayKey
    if IsObject(_HoldOverlay) {
        try _HoldOverlay.Hide()
    }
    _HoldOverlayKey := ""
}

ResetModifierWatchdog(*) {
    if GetKeyState("Space", "P") || GetKeyState("CapsLock", "P")
        return
    static tracked := [
        {name:"Ctrl",  phys:["LControl", "RControl"], up:"{Ctrl Up}"},
        {name:"Shift", phys:["LShift", "RShift"],     up:"{Shift Up}"},
        {name:"Alt",   phys:["LAlt", "RAlt"],         up:"{Alt Up}"},
        {name:"LWin",  phys:["LWin"],                 up:"{LWin Up}"},
        {name:"RWin",  phys:["RWin"],                 up:"{RWin Up}"}
    ]
    for item in tracked {
        logicalDown := GetKeyState(item.name)
        if !logicalDown
            continue
        physicalDown := false
        for physKey in item.phys {
            if GetKeyState(physKey, "P") {
                physicalDown := true
                break
            }
        }
        if !physicalDown
            Send(item.up)
    }
}

UpdateResetWatchdog() {
    global ResetEnabled, HotkeysPaused, _resetWatchdogFn
    if !_resetWatchdogFn
        _resetWatchdogFn := ResetModifierWatchdog
    SetTimer(_resetWatchdogFn, 0)
    if ResetEnabled && !HotkeysPaused
        SetTimer(_resetWatchdogFn, 75)
}
