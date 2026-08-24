; GUI — Hover Popup
; ============================================================

InitHoverPopup() {
    global _HoverState
    _HoverState["popup"] := Gui("-Caption +ToolWindow +AlwaysOnTop +E0x08000020 +Owner")
    local p := _HoverState["popup"]
    p.BackColor := "1E1F22"
    p.SetFont("s" S(9), "Segoe UI")
    p.MarginX := S(8)
    p.MarginY := S(4)
    p.textCtrl := p.AddText("w" S(280) " cFFFFFF Wrap", "")
}

AddHoverPopup(ctrl, text) {
    global _HoverState
    local m := _HoverState["map"]
    m[ctrl.Hwnd] := text
}

_HoverShowPending() {
    global _HoverState
    local m := _HoverState["map"]
    local p := _HoverState["popup"]
    local hwnd := _HoverState["pending"]
    local px := _HoverState["pendingX"]
    local py := _HoverState["pendingY"]
    if hwnd && m.Has(hwnd) {
        local text := StrReplace(m[hwnd], "\n", Chr(10))
        p.textCtrl.Text := text

        hFont := SendMessage(0x0031, 0, 0, p.textCtrl)
        if !hFont
            hFont := DllCall("GetStockObject", "Int", 17)
        local hdc := DllCall("GetDC", "Ptr", p.textCtrl.Hwnd, "Ptr")
        local oldFont := DllCall("SelectObject", "Ptr", hdc, "Ptr", hFont)

        local rect := Buffer(16)
        local maxW := 0
        for line in StrSplit(text, "`n") {
            NumPut("Int", 0, rect, 0)
            NumPut("Int", 0, rect, 4)
            NumPut("Int", 0, rect, 8)
            NumPut("Int", 0, rect, 12)
            DllCall("DrawTextW", "Ptr", hdc, "Str", line, "Int", -1, "Ptr", rect, "UInt", 0x0400)
            local lineW := NumGet(rect, 8, "Int")
            if lineW > maxW
                maxW := lineW
        }

        local pad := S(16)
        local ctrlW := Max(S(40), Min(maxW + pad, S(400)))

        NumPut("Int", 0, rect, 0)
        NumPut("Int", 0, rect, 4)
        NumPut("Int", ctrlW, rect, 8)
        NumPut("Int", 0, rect, 12)
        DllCall("DrawTextW", "Ptr", hdc, "Str", text, "Int", -1, "Ptr", rect, "UInt", 0x0440)
        local needH := NumGet(rect, 12, "Int")

        DllCall("SelectObject", "Ptr", hdc, "Ptr", oldFont)
        DllCall("ReleaseDC", "Ptr", p.textCtrl.Hwnd, "Ptr", hdc)

        local ctrlH := Max(S(20), needH)
        p.textCtrl.Move(,, ctrlW, ctrlH)

        local winW := ctrlW + p.MarginX * 2
        local winH := ctrlH + p.MarginY * 2
        p.Show("NA x" px + 16 " y" py + 20 " w" winW " h" winH)
        DllCall("SetWindowPos", "Ptr", p.Hwnd, "Ptr", -1, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x0002 | 0x0001)
        SetTimer(_HoverCheck, 200)
    }
    _HoverState["pending"] := 0
}

_HoverCheck() {
    global _HoverState
    local m := _HoverState["map"]
    local p := _HoverState["popup"]
    MouseGetPos(,,, &ctrlHwnd, 2)
    if !m.Has(ctrlHwnd) && ctrlHwnd != p.textCtrl.Hwnd && ctrlHwnd != p.Hwnd {
        HoverPopClose()
    }
}

HoverPopClose() {
    global _HoverState
    local p := _HoverState["popup"]
    _HoverState["last"] := 0
    _HoverState["pending"] := 0
    SetTimer(_HoverShowPending, 0)
    SetTimer(_HoverCheck, 0)
    try p.Hide()
}

WM_MOUSEMOVE(wParam, lParam, msg, hwnd) {
    global _HoverState
    local m := _HoverState["map"]
    local p := _HoverState["popup"]
    static lastCursor := 0

    if !_HoverState["enabled"] {
        if _HoverState["last"] {
            _HoverState["last"] := 0
            _HoverState["pending"] := 0
            SetTimer(_HoverShowPending, 0)
            SetTimer(_HoverCheck, 0)
            try p.Hide()
        }
        return
    }

    MouseGetPos(,,, &ctrlHwnd, 2)
    pt := Buffer(8)
    xRaw := lParam & 0xFFFF
    yRaw := lParam >> 16
    if (xRaw > 0x7FFF)
        xRaw -= 0x10000
    if (yRaw > 0x7FFF)
        yRaw -= 0x10000
    NumPut("Int", xRaw, pt, 0)
    NumPut("Int", yRaw, pt, 4)
    DllCall("ClientToScreen", "Ptr", hwnd, "Ptr", pt)
    mx := NumGet(pt, 0, "Int")
    my := NumGet(pt, 4, "Int")

    if m.Has(ctrlHwnd) {
        local delay := _HoverState["delay"]
        if _HoverState["last"] != ctrlHwnd {
            _HoverState["last"] := ctrlHwnd
            _HoverState["pending"] := ctrlHwnd
            _HoverState["pendingX"] := mx
            _HoverState["pendingY"] := my
            SetTimer(_HoverShowPending, 0)
            try p.Hide()
            SetTimer(_HoverShowPending, -delay)
        } else if _HoverState["pending"] {
            _HoverState["pendingX"] := mx
            _HoverState["pendingY"] := my
            SetTimer(_HoverShowPending, -delay)
        } else if DllCall("IsWindowVisible", "Ptr", p.Hwnd) {
            WinMove(mx + 16, my + 20,,, "ahk_id " p.Hwnd)
        }
    } else if ctrlHwnd != p.textCtrl.Hwnd && ctrlHwnd != p.Hwnd {
        _HoverState["last"] := 0
        _HoverState["pending"] := 0
        SetTimer(_HoverShowPending, 0)
        SetTimer(_HoverCheck, 0)
        try p.Hide()
    }

    ; --- Hand cursor on GUI windows ---
    if IsMyGui(hwnd) {
        if lastCursor != hwnd {
            DllCall("SetCursor", "Ptr", DllCall("LoadCursor", "Ptr", 0, "Int", 32649, "Ptr"))
            lastCursor := hwnd
        }
    } else {
        if lastCursor != 0 {
            DllCall("SetCursor", "Ptr", DllCall("LoadCursor", "Ptr", 0, "Int", 32512, "Ptr"))
            lastCursor := 0
        }
    }
}
