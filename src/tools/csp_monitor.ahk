; CSP AUTO-RESTART MONITOR
; ============================================================

ToggleCSPMonitor(*) {
    global CSP_RestartMonitor
    CSP_RestartMonitor := !CSP_RestartMonitor
    DebugLog("CSP auto-restart " (CSP_RestartMonitor ? "ON" : "OFF"))
    ShowNotify("CSP Monitor", CSP_RestartMonitor ? "ON" : "OFF", CSP_RestartMonitor ? "0x4CAF50" : "0xE53935")
}

