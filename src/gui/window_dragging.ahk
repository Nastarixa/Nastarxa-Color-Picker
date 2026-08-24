; GUI — Window Dragging
; ============================================================

; Drag support for transient mode panels (ShowModeSelector / ShowModeManager).
global ModeDragHandles := Map()
; The IB bottom-right separator is both a drag handle and a double-click target
; (double-click opens the mode selector), so its caption-drag starts with a short
; delay to keep the double-click from being swallowed by the modal drag loop.
global _IBDragBottomPending := 0

ScheduleIBDragBottom() {
    global _IBDragBottomPending
    _IBDragBottomPending := SetTimer(_IBDragBottomStart, -150)
}

_IBDragBottomStart(*) {
    global _IBDragBottomPending, IB_GUI
    _IBDragBottomPending := 0
    if !GetKeyState("LButton", "P")
        return
    gh := SafeGuiHwnd(IB_GUI)
    if gh
        PostMessage(0xA1, 2,,, "ahk_id " gh)
}

; The transient mode panels' headers are drag handles, but a plain click must not
; grab the window (that made the panel "move" on click), so the caption-drag only
; starts once the cursor moves past a small threshold while the button is held.
global _ModeDragCand := {has: false, win: 0, x: 0, y: 0}

WM_ModeDrag(wParam, lParam, msg, hwnd) {
    global ModeDragHandles, _ModeDragCand
    if !(wParam & 1)
        return
    win := ModeDragHandles.Get(hwnd, 0)
    if !win
        return
    CoordMode("Mouse", "Screen")
    MouseGetPos(&mx, &my)
    _ModeDragCand := {has: true, win: win, x: mx, y: my}
}

WM_ModeDragMove(wParam, lParam, msg, hwnd) {
    global _ModeDragCand
    if !_ModeDragCand.has
        return
    if !GetKeyState("LButton", "P") {
        _ModeDragCand.has := false
        return
    }
    CoordMode("Mouse", "Screen")
    MouseGetPos(&mx, &my)
    if (Abs(mx - _ModeDragCand.x) > 6 || Abs(my - _ModeDragCand.y) > 6)
        StartModeDrag(_ModeDragCand.win)
}

WM_ModeDragUp(wParam, lParam, msg, hwnd) {
    global _ModeDragCand
    _ModeDragCand.has := false
}

StartModeDrag(win) {
    global _ModeDragCand
    _ModeDragCand.has := false
    if win
        PostMessage(0xA1, 2,,, "ahk_id " win)
}

WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
    global ColorGUI, IB_GUI, LinkGUI, MainGUI, PieGUI, _pieControlMap, _pieCloseMap, _pieActivated, _ccGUI, _ccFollowCursor
    if hwnd && SafeGuiHwnd(PieGUI) && _pieControlMap.Has(hwnd) {
        if !_pieActivated {
            _pieActivated := true
            item := _pieControlMap[hwnd]
            PieClose()
            PieRunItem(item)
        }
        return
    }
    if hwnd && SafeGuiHwnd(PieGUI) && _pieCloseMap.Has(hwnd) {
        PieClose()
        return
    }
    if hwnd && hwnd = SafeGuiHwnd(PieGUI) {
        MouseGetPos(,,, &ctrlHwnd, 2)
        if ctrlHwnd && _pieControlMap.Has(ctrlHwnd) {
            if !_pieActivated {
                _pieActivated := true
                item := _pieControlMap[ctrlHwnd]
                PieClose()
                PieRunItem(item)
            }
        } else {
            PieClose()
        }
        return
    }
    if hwnd && hwnd = SafeGuiHwnd(_ccGUI) && !_ccFollowCursor {
        PostMessage(0xA1, 2,,, "ahk_id " hwnd)
        return
    }
    if IsMyGuiOrChild(hwnd) {
        MouseGetPos(,,, &ctrlHwnd, 2)
        if !ctrlHwnd
            PostMessage(0xA1, 2,,, "ahk_id " hwnd)
        else if IsObject(LinkGUI) && LinkGUI.HasProp("dragBottom") && ctrlHwnd = LinkGUI.dragBottom.Hwnd
            PostMessage(0xA1, 2,,, "ahk_id " hwnd)
        else if IsObject(IB_GUI) && IB_IsDragHandle(ctrlHwnd) {
            if IB_GUI.HasProp("dragBottom") && ctrlHwnd = IB_GUI.dragBottom.Hwnd
                ScheduleIBDragBottom()
            else
                PostMessage(0xA1, 2,,, "ahk_id " hwnd)
        }
        else if IsObject(ColorGUI) && ColorGUI.HasProp("dragBottom") && ctrlHwnd = ColorGUI.dragBottom.Hwnd
            PostMessage(0xA1, 2,,, "ahk_id " hwnd)
        else if IsObject(MainGUI) && MainGUI.HasProp("dragBottom") && ctrlHwnd = MainGUI.dragBottom.Hwnd
            PostMessage(0xA1, 2,,, "ahk_id " hwnd)
    }
}

IB_IsDragHandle(ctrlHwnd) {
    global IB_GUI, IB_Text, IB_LTInd
    if !IsObject(IB_GUI)
        return false
    if IB_GUI.HasProp("dragBottom") && ctrlHwnd = IB_GUI.dragBottom.Hwnd
        return true
    return IsObject(IB_Text) && ctrlHwnd = IB_Text.Hwnd
        || IsObject(IB_LTInd) && ctrlHwnd = IB_LTInd.Hwnd
}

WM_EXITSIZEMOVE(wParam, lParam, msg, hwnd) {
    global IB_GUI, ColorGUI, LinkGUI, MainGUI, _ccGUI, _ccFollowCursor, _ccX, _ccY
    if hwnd && hwnd = SafeGuiHwnd(_ccGUI) && !_ccFollowCursor {
        try _ccGUI.GetPos(&_ccX, &_ccY)
    }
    if IsMyGui(hwnd)
        SaveGUIPositions()
}

IsMyGui(hwnd) {
    global IB_GUI, ColorGUI, LinkGUI, MainGUI, _ccGUI
    return hwnd && hwnd = SafeGuiHwnd(IB_GUI)
        || hwnd && hwnd = SafeGuiHwnd(ColorGUI)
        || hwnd && hwnd = SafeGuiHwnd(LinkGUI)
        || hwnd && hwnd = SafeGuiHwnd(MainGUI)
        || hwnd && hwnd = SafeGuiHwnd(_ccGUI)
}

; A click on a child control is delivered with the control's hwnd, so also accept
; any hwnd whose root ancestor is one of our GUIs.
IsMyGuiOrChild(hwnd) {
    if IsMyGui(hwnd)
        return true
    return hwnd && IsMyGui(DllCall("GetAncestor", "Ptr", hwnd, "UInt", 2))
}

SafeGuiHwnd(guiObj) {
    if !IsObject(guiObj)
        return 0
    try return guiObj.Hwnd
    catch
        return 0
}

GuiWaitForCloseSafe(guiObj) {
    hwnd := SafeGuiHwnd(guiObj)
    if hwnd
        WinWaitClose("ahk_id " hwnd)
}

GuiHasCtrl(guiObj, prop) {
    if !IsObject(guiObj) || !HasProp(guiObj, prop)
        return false
    try return IsObject(guiObj.%prop%)
    catch
        return false
}

IsGuiVisibleSafe(guiObj) {
    hwnd := SafeGuiHwnd(guiObj)
    return hwnd && DllCall("IsWindowVisible", "Ptr", hwnd)
}

; ============================================================
