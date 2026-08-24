; Provides standalone ShowNotify / DebugLog stubs for user-written hotkey scripts
; that are #Include'd at runtime. Each stub delegates to the real toolkit globals
; so user scripts work identically whether they run inside or outside the toolkit.

#Include ..\vendor\Notify.ahk
global NotifyEnabled := true
global NotifyMonitor := 0
global NotifyPosition := "TC"

ShowNotify(t, s := "", c := "") {
    global NotifyEnabled, NotifyMonitor, NotifyPosition
    if !NotifyEnabled
        return
    posOpt := " pos=" NotifyPosition
    monOpt := NotifyMonitor > 0 ? " mon=" NotifyMonitor : ""
    static _lastT := "", _lastTime := 0
    if t = _lastT && A_TickCount - _lastTime < 1200
        return
    _lastT := t
    _lastTime := A_TickCount
    Notify.Show(t, s,,,, 'dur=1 ts=10 ms=7 pad=8,4,6,6,6,6,2,3 mf=Segoe UI Black mfo=norm Bold mali=Center' posOpt monOpt (c ? " bc=" c : ""))
}

DebugLog(msg) {
    OutputDebug "CSP: " msg
}
