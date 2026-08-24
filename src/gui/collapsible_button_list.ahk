; COLLAPSIBLE BUTTON LIST — Shared GUI framework
; ============================================================
; Reusable collapsible section list for button-grid GUIs.
; Used by Color Palette and Link Launcher. The existing callers
; are NOT yet wired in — this class is available for new GUIs
; and for gradual migration of existing ones.

class CollapsibleButtonList {
    __New(guiObj, opts := 0) {
        this.gui := guiObj
        isMap := IsObject(opts) && opts is Map
        this.btnW := isMap && opts.Has("btnW") ? opts["btnW"] : S(25)
        this.btnH := isMap && opts.Has("btnH") ? opts["btnH"] : S(30)
        this.gap := isMap && opts.Has("gap") ? opts["gap"] : S(4)
        this.secH := isMap && opts.Has("secH") ? opts["secH"] : S(14)
        this.horizontal := isMap && opts.Has("horizontal") ? opts["horizontal"] : false
        this.sections := Map()
        this.sectionOrder := []
        this.curSection := ""
        this.allControls := []
        this.secBounds := Map()
        this.sectionHasEnabled := Map()
    }

    AddSection(id, label) {
        this.curSection := id
        if !this.sections.Has(id)
            this.sections[id] := {controls:[], collapsed:false}
        this.sectionOrder.Push(id)
        this.secBounds[id] := [this.allControls.Length + 1, this.allControls.Length + 1]
        this.sectionHasEnabled[id] := true

        hdr := this.gui.AddText("xm y+" S(8) " w" this.btnW " h" this.secH " Center +0x200 Background" this.gui.BackColor " cAAAAAA", " " label " ")
        hdr.SetFont("s" S(6) " cAAAAAA", "Segoe UI")
        hdr.OnEvent("Click", this._ToggleSection.Bind(this, id))
        this.allControls.Push(hdr)
    }

    AddButton(label, opts := 0) {
        isMap := IsObject(opts) && opts is Map
        c := isMap && opts.Has("color") ? opts["color"] : "455A64"
        hov := isMap && opts.Has("hover") ? opts["hover"] : label
        fontSize := isMap && opts.Has("fontSize") ? opts["fontSize"] : 9
        iconBold := isMap && opts.Has("iconBold") ? opts["iconBold"] : true
        icon := isMap && opts.Has("icon") ? opts["icon"] : ""
        btnText := icon != "" ? icon : label
        pos := this.horizontal && this.allControls.Length ? "x+" this.gap " yp" : "xm y+" S(4)
        btn := this.gui.AddText(pos " w" this.btnW " h" this.btnH " Center +0x200 Background" c " c" ContrastColor(c), btnText)
        btn.SetFont("s" S(fontSize) (iconBold ? " Bold" : ""), icon != "" ? "Segoe UI Emoji" : "Segoe UI")
        if hov != ""
            AddHoverPopup(btn, hov)
        this.allControls.Push(btn)
        this.secBounds[this.curSection][2] := this.allControls.Length
        return btn
    }

    AddSeparator() {
        this.gui.AddText("xm y+" S(4) " w" this.btnW " h1 Background2A2A2A")
    }

    _ToggleSection(id, *) {
        sec := this.sections[id]
        sec["collapsed"] := !sec["collapsed"]
        first := this.secBounds[id][1] + 1
        last := this.secBounds[id][2]
        Loop (last - first + 1) {
            idx := first + A_Index - 1
            if idx <= this.allControls.Length
                this.allControls[idx].Visible := !sec["collapsed"]
        }
    }
}
