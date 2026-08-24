;THEME - Centralized UI color constants
; ============================================================
; Single source of truth for dialog colors. Reference with TC("name")
; inside option strings via concatenation, e.g.:
;   dlg.BackColor := TC("bgDark")
;   dlg.AddText("xm c" TC("textMuted"), "...")
; New dialogs should use these instead of hardcoded hex values.

global THEME_UI := Map()

; dark surfaces
THEME_UI["bgDark"]    := "1E1F22"   ; main dialog background
THEME_UI["bgPanel"]   := "24272E"   ; read-only edit / panel background
THEME_UI["bgInput"]   := "333333"   ; text input fields
THEME_UI["bgDivider"] := "444444"   ; 1px divider lines

; dark-theme text
THEME_UI["textHi"]    := "FFFFFF"   ; headings / buttons
THEME_UI["textMain"]  := "E8EAED"   ; body text
THEME_UI["textSub"]   := "D7D7D7"   ; slightly dimmed body
THEME_UI["textMuted"] := "AAAAAA"   ; secondary info
THEME_UI["textDim"]   := "888888"   ; subtitles / footnotes
THEME_UI["textSoft"]  := "B0B7C3"   ; intro paragraphs

; accents (dark theme)
THEME_UI["accentTeal"]    := "80CBC4" ; version tags, highlights
THEME_UI["accentGold"]    := "FFD166" ; section headers (Guide Centre)
THEME_UI["accentGoldAlt"] := "FFD54F" ; warnings, sub headers
THEME_UI["red"]           := "E53935" ; errors, stop states
THEME_UI["teal"]          := "00897B" ; success, timer actions
THEME_UI["purple"]        := "6D28D9" ; load/import actions

; light surfaces (System Settings Help, Recommended Shortcuts)
THEME_UI["lightBg"]   := "F0F0F0"
THEME_UI["lightText"] := "202020"
THEME_UI["lightSub"]  := "6A6A6A"
THEME_UI["lightDim"]  := "666666"
THEME_UI["black"]     := "000000"

; misc
THEME_UI["warnYellow"] := "FFFF88"  ; caution notes on dark bg

TC(name) {
    global THEME_UI
    return THEME_UI.Has(name) ? THEME_UI[name] : "CCCCCC"
}
