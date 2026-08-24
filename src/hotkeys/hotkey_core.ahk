; HOTKEY CONFIGURATION SYSTEM
; ============================================================

; Custom hotkey overrides loaded from INI
global HK_Custom := Map()
global HK_CustomFn := Map()
global HK_CustomReq := Map()
global HK_CustomActivate := Map()
global HK_CustomBlock := Map()
global HK_CustomTarget := Map()
global HK_ApplyBlock := Map()
global CapslockSlotActions := Map()
global HK_FN_DISABLED := "__fn_disabled__"
global HK_UserDefs := []
global HK_UserScriptDir := A_ScriptDir "\user_hotkey_scripts"
global HotkeyDefs := []
global _hkFilteredIndices := []
global _capslockModActive := false
global HOLD_THRESHOLD_MS := 80
global CONTRAST_THRESHOLD := 185
global _capslockPollEnabled := false
global _capslockPollDown := false
global _capslockPollStarted := false
global _capslockPollStart := 0
global _capslockPollInitialState := false
global _capslockSlotConsumed := false
global _capslockAssignedBlockKeys := []


ToolkitSafeInt(value, fallback := 0, minVal := "", maxVal := "") {
    try n := Integer(value)
    catch
        n := fallback
    if minVal != "" && n < minVal
        n := minVal
    if maxVal != "" && n > maxVal
        n := maxVal
    return n
}

; Track currently-registered hotkey per id (for clean unregister on customization change)
global HK_Registered := Map()
global HK_RegisteredFn := Map()
global HK_RegisteredCond := Map()
global HK_RegisteredTarget := Map()
; Multi-shortcut: stores all registered keys per id (array of strings)
global HK_RegisteredAll := Map()

; --- Build hotkey definitions ---
InitHotkeyDefs() {
    global HotkeyDefs
    HotkeyDefs := [
        ; ---- Group: csp ----
        {id:"toggle_guis",      group:"csp", def:"^F1",       desc:"Toggle Tool GUIs",                                       fn:ToggleToolGUIs},
        {id:"what_fired_osd",   group:"csp", def:"-",        desc:"What Fired: Toggle OSD",                                 fn:HK_ToggleFiredOSD},
        {id:"toggle_lt_lock",   group:"csp", def:"^F2",      desc:"Toggle LT Lock",                                         fn:ToggleLTLock},
        {id:"toggle_lt_lock_a", group:"csp", def:"!l",       desc:"Toggle LT Lock (Alt)",                                   fn:ToggleLTLock},
        {id:"toggle_autosave",  group:"csp", def:"^F4",      desc:"Toggle Auto Save",                                       fn:ToggleAutoSave},
        {id:"timer_start",      group:"csp", def:"^!+4",     desc:"Timer: Start/Pause",                                     fn:TimerToggle},
        {id:"timer_pause",      group:"csp", def:"-",        desc:"Timer: Pause (optional separate key)",                    fn:TimerPause, fnEnabled:false},
        {id:"timer_stop",       group:"csp", def:"^!+2",     desc:"Timer: Stop",                                            fn:TimerStop},
        {id:"timer_lap",        group:"csp", def:"^!+3",     desc:"Timer: Lap",                                             fn:TimerLap},
        {id:"timer_countdown",  group:"csp", def:"^!+5",     desc:"Timer: Countdown",                                       fn:TimerCountdownShow},
        {id:"timer_save",       group:"csp", def:"^!+1",     desc:"Timer: Save",                                            fn:TimerSave},
        {id:"toggle_nav",       group:"csp", def:"^F5",      desc:"Toggle Nav",                                             fn:ToggleNav},
        {id:"toggle_capslock",  group:"csp", def:"^F6",      desc:"Toggle Capslock",                                        fn:ToggleCapslock},
        {id:"toggle_tab",       group:"csp", def:"^F7",      desc:"Toggle Tab Combos",                                      fn:ToggleTabCombos},
        {id:"toggle_reset",     group:"csp", def:"^F8",      desc:"Toggle Reset Keys",                                      fn:ToggleReset},
        {id:"toggle_lwin",      group:"csp", def:"^F9",      desc:"Toggle LWin Right-click",                                fn:ToggleLWin},
        {id:"lwin_rightclick",  group:"csp_lwin", def:"LWin", desc:"Right-click via LWin",                                  fn:HotkeyLWinRightClick},
        {id:"wheel_down",       group:"csp", def:"WheelDown",desc:"Scroll Down",                                            fn:HotkeyScrollDown},
        {id:"wheel_up",         group:"csp", def:"WheelUp",  desc:"Scroll Up",                                              fn:HotkeyScrollUp},
        {id:"ib_1",             group:"csp", def:"$^1",      desc:"IB: Select current",                                     fn:HotkeyIB1},
        {id:"ib_2",             group:"csp", def:"$^2",      desc:"IB: Type 1 (50/50)",                                     fn:HotkeyIB2},
        {id:"ib_3",             group:"csp", def:"$^3",      desc:"IB: Type 2 (direction mode)",                           fn:HotkeyIB3},
        {id:"ib_4",             group:"csp", def:"$^4",      desc:"IB: Type 3 (direction mode)",                           fn:HotkeyIB4},
        {id:"ib_5",             group:"csp", def:"$^5",      desc:"IB: Type 4 (direction mode)",                           fn:HotkeyIB5},
        {id:"ib_6",             group:"csp", def:"$^6",      desc:"IB: Type 5 (direction mode)",                           fn:HotkeyIB6},
        {id:"ib_7",             group:"csp", def:"$^7",      desc:"IB: Type 6 (direction mode)",                           fn:HotkeyIB7},
        {id:"ib_8",             group:"csp", def:"$^8",      desc:"IB: Type 7 (direction mode)",                           fn:HotkeyIB8},
        {id:"layer_1",          group:"csp", def:"$+1",     desc:"Layer: Black",                                            fn:HotkeyLayerBlack},
        {id:"layer_2",          group:"csp", def:"$+2",     desc:"Layer: Red",                                              fn:HotkeyLayerRed},
        {id:"layer_3",          group:"csp", def:"$+3",     desc:"Layer: Blue",                                             fn:HotkeyLayerBlue},
        {id:"layer_4",          group:"csp", def:"$+4",     desc:"Layer: Green",                                            fn:HotkeyLayerGreen},
        {id:"layer_5",          group:"csp", def:"$+5",     desc:"Layer: Pink",                                             fn:HotkeyLayerPink},
        {id:"layer_6",          group:"csp", def:"$+6",     desc:"Layer: Cyan",                                             fn:HotkeyLayerCyan},
        {id:"layer_7",          group:"csp", def:"$+7",     desc:"Layer: Orange",                                           fn:HotkeyLayerOrange},
        {id:"layer_8",          group:"csp", def:"$+8",     desc:"Layer: Uranuri/Shadow",                                   fn:HotkeyLayerUranuri},
        {id:"layer_9",          group:"csp", def:"$+9",     desc:"Layer: Paint",                                            fn:HotkeyLayerPaint},
        {id:"layer_0",          group:"csp", def:"$+0",     desc:"Layer: Rough",                                            fn:HotkeyLayerRough},
        {id:"layer_select_2",   group:"csp", def:"-",       desc:"Layer: Second Layer",                                     fn:HotkeyLayerSelect2},
        {id:"layer_select_3",   group:"csp", def:"-",       desc:"Layer: Third Layer",                                      fn:HotkeyLayerSelect3},
        {id:"layer_select_4",   group:"csp", def:"-",       desc:"Layer: Fourth Layer",                                     fn:HotkeyLayerSelect4},
        {id:"layer_select_5",   group:"csp", def:"-",       desc:"Layer: Fifth Layer",                                      fn:HotkeyLayerSelect5},
        {id:"layer_select_6",   group:"csp", def:"-",       desc:"Layer: Sixth Layer",                                      fn:HotkeyLayerSelect6},
        {id:"layer_select_7",   group:"csp", def:"-",       desc:"Layer: Seventh Layer",                                    fn:HotkeyLayerSelect7},
        {id:"layer_select_8",   group:"csp", def:"-",       desc:"Layer: Eighth Layer",                                     fn:HotkeyLayerSelect8},
        {id:"layer_select_9",   group:"csp", def:"-",       desc:"Layer: Ninth Layer",                                      fn:HotkeyLayerSelect9},
        {id:"layer_select_10",   group:"csp", def:"-",       desc:"Layer: Tenth Layer",                                      fn:HotkeyLayerSelect10},
        {id:"create_1",         group:"csp", def:"!1",       desc:"Create: Paper Layer",                                    fn:HotkeyCreatePaperLayer},
        {id:"create_2",         group:"csp", def:"!2",       desc:"Create: Raster Layer",                                   fn:HotkeyCreateRasterLayer},
        {id:"create_3",         group:"csp", def:"!3",       desc:"Create: Vector Layer",                                   fn:HotkeyCreateVectorLayer},
        {id:"create_4",         group:"csp", def:"!4",       desc:"Create: Colored Vector Layer",                           fn:HotkeyCreateColoredVectorLayer},
        {id:"create_5",         group:"csp", def:"!5",       desc:"Create: Dummy Layer",                                    fn:HotkeyCreateDummyLayer},
        {id:"create_7",         group:"csp", def:"!7",       desc:"Create: Pink Vector Layer",                              fn:HotkeyCreatePinkVectorLayer},
        {id:"create_8",         group:"csp", def:"!8",       desc:"Create: Cyan Vector Layer",                              fn:HotkeyCreateCyanVectorLayer},
        {id:"create_9",         group:"csp", def:"!9",       desc:"Create: Orange Vector Layer",                            fn:HotkeyCreateOrangeVectorLayer},
        {id:"create_0",         group:"csp", def:"!0",       desc:"Create: Animation Folder",                               fn:HotkeyCreateAnimationFolder},
        {id:"feature_kf",       group:"csp", def:"+^1",     desc:"Feature: Set Keyframe Color",                             fn:HotkeyFeatureKeyframeColor},
        {id:"feature_ref",      group:"csp", def:"+^2",     desc:"Feature: Set Reference Color",                            fn:HotkeyFeatureReferenceColor},
        {id:"feature_rm",       group:"csp", def:"+^3",     desc:"Feature: Remove Layer Color",                             fn:HotkeyFeatureRemoveLayerColor},
        {id:"feature_lt_color", group:"csp", def:"+^4",     desc:"Feature: Change LT Image 1/3 Half Color",                fn:HotkeyChangeColor},
        {id:"feature_norm",     group:"csp", def:"+^5",     desc:"Feature: Normal Color",                                   fn:HotkeyFeatureNormalColor},
        {id:"feature_half_green",  group:"csp", def:"-",   desc:"Feature: Change LT Color Layer to Half Color (Green)",    fn:HotkeyFeatureHalfGreen},
        {id:"feature_half_purple", group:"csp", def:"-",   desc:"Feature: Change LT Color Layer to Half Color (Purple)",   fn:HotkeyFeatureHalfPurple},
        {id:"feature_paper_white",  group:"csp", def:"-",   desc:"Paper Color: White",                                       fn:HotkeyFeaturePaperWhite, req:REQ_NASTAR},
        {id:"feature_paper_purple", group:"csp", def:"-",   desc:"Paper Color: Purple",                                      fn:HotkeyFeaturePaperPurple, req:REQ_NASTAR},
        {id:"feature_paper_green",  group:"csp", def:"-",   desc:"Paper Color: Green",                                       fn:HotkeyFeaturePaperGreen, req:REQ_NASTAR},
        {id:"feature_layer_black",  group:"csp", def:"+^6", desc:"Feature: Layer Color Black",                                fn:HotkeyFeatureLayerColorBlack},
        {id:"transfer_raster",  group:"csp", def:"!;",      desc:"Transfer Down + Rasterize",                               fn:HotkeyTransferRasterize},
        {id:"transfer_vector",  group:"csp", def:"+^!R",   desc:"Transfer Down Vector",                                     fn:HotkeyTransferVector},
        {id:"merge_down",       group:"csp", def:"+^!E",   desc:"Merge Down Layer",                                         fn:HotkeyMergeDownLayer, req:REQ_NASTAR},
        {id:"color_gray",       group:"csp", def:"+^!T",   desc:"Color Expression: Gray",                                   fn:HotkeyColorExpressionGray, req:REQ_NASTAR},
        {id:"delete_layer",     group:"csp", def:"+^!X",   desc:"Delete Layer",                                             fn:HotkeyDeleteLayer},
        {id:"delete_cel_tl",    group:"csp", def:"+^X",    desc:"Delete Cel from Timeline",                                 fn:HotkeyDeleteCelTimeline},
        {id:"copy_cel_tl",      group:"csp", def:"+^C",    desc:"Edit Track: Copy",                                         fn:HotkeyEditTrackCopy},
        {id:"paste_cel_tl",     group:"csp", def:"+^V",    desc:"Edit Track: Paste",                                        fn:HotkeyEditTrackPaste},
        {id:"delete_cel_lt",    group:"csp", def:"+X",     desc:"Delete Cel from Lighttable",                               fn:HotkeyDeleteCelLighttable},
        {id:"slash_command",    group:"csp", def:"!f",      desc:"Slash Command",                                           fn:HotkeySlashCommand},
        {id:"opacity_100",      group:"csp", def:"+B",      desc:"Opacity 100",                                             fn:HotkeyOpacity100, req:REQ_NASTAR},
        {id:"opacity_50",       group:"csp", def:"!B",      desc:"Opacity 50",                                              fn:HotkeyOpacity50, req:REQ_NASTAR},
        {id:"opacity_25",       group:"csp", def:"!^B",    desc:"Opacity 25",                                               fn:HotkeyOpacity25, req:REQ_NASTAR},
        {id:"color_picker",     group:"csp", def:"+^b",     desc:"Screen Color Picker",                                     fn:HotkeyColorPicker, req:REQ_NASTAR, activate:true},
        {id:"toggle_layer_clr", group:"csp", def:"^B",     desc:"Toggle Layer Color",                                       fn:HotkeyToggleLayerColor, req:REQ_NASTAR},
        {id:"duplicate_layer",  group:"csp", def:"+^!D",   desc:"Duplicate Layer",                                          fn:HotkeyDuplicateLayer, req:REQ_NASTAR},
        {id:"group_folder",     group:"csp", def:"+^!G",   desc:"Create Folder and Insert Layer",                          fn:HotkeyCreateFolderInsertLayer, req:REQ_NASTAR},
        {id:"ungroup_folder",   group:"csp", def:"!^G",    desc:"Ungroup Layer Folder",                                    fn:HotkeyUngroupLayerFolder, req:REQ_NASTAR},
        {id:"select_next_cel",  group:"csp", def:"$!D",    desc:"Select Next Cel",                                         fn:HotkeySelectNextCel, req:REQ_NASTAR},
        {id:"select_prev_cel",  group:"csp", def:"$!A",    desc:"Select Previous Cel",                                     fn:HotkeySelectPrevCel, req:REQ_NASTAR},
        {id:"select_next_lt",   group:"csp", def:"$^!D",   desc:"Select Next LT Cel",                                      fn:HotkeySelectNextLTCel, req:REQ_NASTAR},
        {id:"select_prev_lt",   group:"csp", def:"$^!A",   desc:"Select Previous LT Cel",                                  fn:HotkeySelectPrevLTCel, req:REQ_NASTAR},
        {id:"prev_frame",       group:"csp", def:"-",        desc:"Previous Frame",                                          fn:HotkeyPrevFrame},
        {id:"next_frame",       group:"csp", def:"-",        desc:"Next Frame",                                              fn:HotkeyNextFrame},
        {id:"toggle_onion",     group:"csp", def:"!w",     desc:"Toggle Onion Skin",                                        fn:HotkeyToggleOnion},
        {id:"toggle_vis",       group:"csp", def:"!V",     desc:"Toggle Layer Visibility",                                  fn:HotkeyToggleLayerVisibility, req:REQ_NASTAR},
        {id:"toggle_lt",        group:"csp", def:"^!w",   desc:"Toggle Light Table",                                       fn:HotkeyToggleLT},
        {id:"onion_to_lt",      group:"csp", def:"!+W",   desc:"Insert Onion to Lighttable Cell",                           fn:HotkeyInsertOnionToLTCell},
        {id:"paint_transparent",  group:"csp", def:"+^!F",   desc:"Paint Alpha/Transparent",                                       fn:HotkeyPaintTransparent, req:REQ_NASTAR},
        {id:"paint_red",          group:"csp", def:"+^!C",   desc:"Paint Red Line",                                          fn:HotkeyPaintRedLine, req:REQ_NASTAR},
        {id:"paint_green",        group:"csp", def:"+^!V",   desc:"Paint Green Line",                                        fn:HotkeyPaintGreenLine, req:REQ_NASTAR},
        {id:"paint_blue",         group:"csp", def:"+^!B",   desc:"Paint Blue Line",                                         fn:HotkeyPaintBlueLine, req:REQ_NASTAR},
        {id:"paint_pink",         group:"csp", def:"+^!N",   desc:"Paint Pink Line",                                         fn:HotkeyPaintPinkLine, req:REQ_NASTAR},
        {id:"paint_cyan",         group:"csp", def:"+^!M",   desc:"Paint Cyan Line",                                         fn:HotkeyPaintCyanLine, req:REQ_NASTAR},
        {id:"paint_orange",       group:"csp", def:"+^!,",   desc:"Paint Orange Line",                                       fn:HotkeyPaintOrangeLine, req:REQ_NASTAR},
        {id:"paint_purple",       group:"csp", def:"+^!.",   desc:"Paint Purple Line",                                       fn:HotkeyPaintPurpleLine, req:REQ_NASTAR},
        {id:"set_to_paint_anim",  group:"csp", def:"+^!Insert", desc:"Set to Paint: Animation",                              fn:HotkeySetToPaintAnimation, req:REQ_NASTAR},
        {id:"set_cels_to_track",  group:"csp", def:"+^!PgUp",  desc:"Set Cels to Track",                                     fn:HotkeySetCelsToTrack, req:REQ_NASTAR},
        {id:"ref_layer",        group:"csp", def:"+^Q",    desc:"Set as Reference Layer",                                   fn:HotkeyReferenceLayer, req:REQ_NASTAR},
        {id:"paint_checker_single",         group:"csp", def:"+^!End",  desc:"Paint Check: Layer",                                  fn:HotkeyPaintCheckerLayer, req:REQ_NASTAR},
        {id:"paint_checker_image",           group:"csp", def:"+^!Home", desc:"Paint Checker: Image",                                fn:HotkeyPaintCheckerImage, req:REQ_NASTAR},
        {id:"delete_paint_checker",   group:"csp", def:"+^!Del", desc:"Delete Paint Checker",                                        fn:HotkeyDeletePaintChecker, req:REQ_NASTAR},
        {id:"create_6",         group:"csp", def:"!6",       desc:"Create: Separate Black Line + Paint",                    fn:HotkeySeparateBlackLine},
        {id:"isolate_layer",    group:"csp", def:"+^!Q",   desc:"Isolate Layer",                                            fn:HotkeyIsolateLayer, req:REQ_NASTAR},
        {id:"draft_layer",      group:"csp", def:"+^F",    desc:"Set as Draft Layer",                                       fn:HotkeyDraftLayer, req:REQ_NASTAR},
        {id:"clip_below",       group:"csp", def:"+^G",    desc:"Clip to Layer Below",                                      fn:HotkeyClipToLayerBelow, req:REQ_NASTAR},
        {id:"lock_layer",       group:"csp", def:"+^R",    desc:"Lock Layer",                                               fn:HotkeyLockLayer, req:REQ_NASTAR},
        {id:"lock_transparent", group:"csp", def:"+^E",    desc:"Lock Layer Transparent",                                   fn:HotkeyLockTransparent, req:REQ_NASTAR},
        {id:"lock_cel",         group:"csp", def:"+^W",    desc:"Lock Animation Cel",                                       fn:HotkeyLockAnimationCel, req:REQ_NASTAR},
        {id:"swap_brush",       group:"csp", def:"x",      desc:"Swap Brush Primary/Secondary",                             fn:HotkeySwapBrush},
        {id:"toggle_transp",    group:"csp", def:"!C",     desc:"Toggle Brush Transparent",                                 fn:HotkeyToggleTransparent},
        {id:"reset_color",      group:"csp", def:"+C",     desc:"Reset Color",                                              fn:HotkeyResetColor, req:REQ_NASTAR},
        {id:"layer_up",         group:"csp", def:"+!Z",    desc:"Layer Up",                                                 fn:HotkeyLayerUp, req:REQ_NASTAR},
        {id:"layer_down",       group:"csp", def:"+!X",    desc:"Layer Down",                                               fn:HotkeyLayerDown, req:REQ_NASTAR},
        {id:"top_layer",        group:"csp", def:"[",      desc:"Top Layer",                                                fn:HotkeyTopLayer, req:REQ_NASTAR},
        {id:"bottom_layer",     group:"csp", def:"]",      desc:"Bottom Layer",                                             fn:HotkeyBottomLayer, req:REQ_NASTAR},
        {id:"ib_guide",         group:"csp", def:"^F12",   desc:"Guide: InBetween",                                         fn:GuideIBNotify},
        {id:"ib_empty",         group:"csp", def:"$^SC029", desc:"IB: Empty",                                                 fn:HotkeyIBEmpty, req:REQ_ANIM},
        {id:"guide_create",     group:"csp", def:"!SC029",  desc:"Guide: Create New",                                        fn:GuideCreateNotify},
        {id:"guide_shortcut",   group:"csp", def:"+SC029",  desc:"Guide: Shortcuts",                                         fn:GuideShortcutNotify},
        {id:"guide_autoaction", group:"csp", def:"^+SC029", desc:"Guide: AutoAction",                                        fn:GuideAutoActionNotify},
        {id:"guide_anim",       group:"csp", def:"^!SC029", desc:"Guide: Animation",                                         fn:GuideAnimationNotify},

        ; ---- Group: csp (Uranuri Colors) ----
        {id:"urancolor_1",      group:"csp", def:"^!F1",    desc:"Uranuri: Beige Skin",                                      fn:UranColor1},
        {id:"urancolor_2",      group:"csp", def:"^!F2",    desc:"Uranuri: Pale Yellow",                                     fn:UranColor2},
        {id:"urancolor_3",      group:"csp", def:"^!F3",    desc:"Uranuri: Light Cyan",                                      fn:UranColor3},
        {id:"urancolor_4",      group:"csp", def:"^!F4",    desc:"Uranuri: Pale Green",                                      fn:UranColor4},
        {id:"urancolor_5",      group:"csp", def:"^!F5",    desc:"Uranuri: Light Pink",                                      fn:UranColor5},
        {id:"urancolor_6",      group:"csp", def:"^!F6",    desc:"Uranuri: Lavender Blue",                                   fn:UranColor6},
        {id:"urancolor_7",      group:"csp", def:"^!F7",    desc:"Uranuri: Coral Pink",                                      fn:UranColor7},
        {id:"urancolor_8",      group:"csp", def:"^!F8",    desc:"Uranuri: Green Mint",                                      fn:UranColor8},
        {id:"urancolor_9",      group:"csp", def:"^!F9",    desc:"Uranuri: Sky Blue",                                        fn:UranColor9},
        {id:"urancolor_10",     group:"csp", def:"^!F10",   desc:"Uranuri: Red-Orange",                                      fn:UranColor10},
        {id:"urancolor_11",     group:"csp", def:"^!F11",   desc:"Uranuri: Magenta",                                         fn:UranColor11},

        ; ---- Group: csp_nav ----
        {id:"nav_pan",          group:"csp_nav", def:"Space",      desc:"Pan Space",                                        fn:SpacePan},
        {id:"nav_pan_ctrl",     group:"csp_nav", def:"^Space",     desc:"Pan Ctrl+Space",                                   fn:SpacePanCtrl},
        {id:"nav_pan_shalt",    group:"csp_nav", def:"+!Space",    desc:"Pan Shift+Alt+Space",                              fn:SpacePanShiftAlt},

        ; ---- Group: csp_caps ----
        {id:"capslock_mod",     group:"csp_caps", def:"*CapsLock", desc:"CapsLock Mod",                                     fn:CapslockMod},
        {id:"caps_num_1",       group:"csp_caps", def:"-", desc:"CapsLock + 1",                                             fn:CapslockSlot1},
        {id:"caps_num_2",       group:"csp_caps", def:"-", desc:"CapsLock + 2",                                             fn:CapslockSlot2},
        {id:"caps_num_3",       group:"csp_caps", def:"-", desc:"CapsLock + 3",                                             fn:CapslockSlot3},
        {id:"caps_num_4",       group:"csp_caps", def:"-", desc:"CapsLock + 4",                                             fn:CapslockSlot4},
        {id:"caps_num_5",       group:"csp_caps", def:"-", desc:"CapsLock + 5",                                             fn:CapslockSlot5},
        {id:"caps_num_6",       group:"csp_caps", def:"-", desc:"CapsLock + 6",                                             fn:CapslockSlot6},
        {id:"caps_num_7",       group:"csp_caps", def:"-", desc:"CapsLock + 7",                                             fn:CapslockSlot7},
        {id:"caps_num_8",       group:"csp_caps", def:"-", desc:"CapsLock + 8",                                             fn:CapslockSlot8},
        {id:"caps_num_9",       group:"csp_caps", def:"-", desc:"CapsLock + 9",                                             fn:CapslockSlot9},
        {id:"caps_num_0",       group:"csp_caps", def:"-", desc:"CapsLock + 0",                                             fn:CapslockSlot0},
        {id:"caps_num_backtick",group:"csp_caps", def:"-", desc:"CapsLock + ``",                                            fn:CapslockSlotBacktick},

        ; ---- Group: csp_reset ----
        {id:"reset_mods",       group:"csp_reset", def:"^!+Backspace", desc:"Reset Modifier Keys",                          fn:ResetModifiers},

        ; ---- Group: global ----
        {id:"toggle_main_gui",  group:"global", def:"!F1", desc:"Toggle Main GUI",                                          fn:ToggleMainWindow},
        {id:"show_debug_log",   group:"global", def:"^!F12", desc:"Show Debug Log",                                         fn:ShowDebugGUI},
{id:"toggle_csp_monitor",group:"global", def:"^!F13", desc:"Toggle CSP Restart Monitor", fn:ToggleCSPMonitor},
        {id:"toggle_cheat_sheet",group:"global", def:"^+F2", desc:"Toggle Hotkey Cheat Sheet",                              fn:HK_CheatSheetToggle},

    ]
    ; Populate sends descriptions
    for d in HotkeyDefs {
        if d.fn.Name
            d.sends := "Calls " d.fn.Name
        else if InStr(d.desc, "Send") || InStr(d.desc, "scroll") || InStr(d.desc, "Pan") || InStr(d.desc, "Space")
            d.sends := d.desc
        else if InStr(d.desc, "Toggle")
            d.sends := "Toggles " Trim(SubStr(d.desc, 8))
        else if InStr(d.desc, "Create:")
            d.sends := "ShowNotify('" Trim(SubStr(d.desc, 9)) "')"
        else if InStr(d.desc, "Layer:")
            d.sends := "Calls DoLayer() - sets layer " SubStr(d.desc, 8)
        else if InStr(d.desc, "Tab+")
            d.sends := d.desc
        else if InStr(d.desc, "Feature:")
            d.sends := "CSP feature: " Trim(SubStr(d.desc, 10))
        else if InStr(d.desc, "Guide:")
            d.sends := "ShowNotify - CSP guide for " Trim(SubStr(d.desc, 7))
        else if InStr(d.desc, "IB:")
            d.sends := "Selects inbetween type: " Trim(SubStr(d.desc, 4))
        else
            d.sends := d.desc
    }
}

; --- Load custom hotkeys from INI ---
HK_Load() {
    global HK_Custom, HK_CustomFn, HK_CustomReq, HK_CustomActivate, CapslockSlotActions, SETTINGS_FILE, HOTKEY_SETTINGS_FILE
    global HK_CustomTarget, HK_TargetWindows, HK_RegisteredCond, HK_RegisteredTarget, HK_Modes, HK_ModeOrder, HK_Mode
    global HK_CustomBlock, HK_ApplyBlock
    HK_Custom := Map()
    HK_CustomFn := Map()
    HK_CustomReq := Map()
    HK_CustomActivate := Map()
    HK_CustomTarget := Map()
    HK_CustomBlock := Map()
    HK_ApplyBlock := Map()
    ; Keep HK_RegisteredCond/HK_RegisteredTarget: HK_ReapplyGroup needs the
    ; stored per-def HotIf criteria to turn off the previous mode's variants
    ; (Hotkey(name,"Off") only affects the variant matching the active criteria).
    CapslockSlotActions := Map()
    ini := FileExist(HOTKEY_SETTINGS_FILE) ? HOTKEY_SETTINGS_FILE : SETTINGS_FILE
    HK_LoadTargetWindows(ini)
    ; Mode definitions live in the base hotkey file only; a mode's snapshot may
    ; be a stale copy, so always load defs/order/active from the base file.
    baseHot := ModeSettingsBaseFile("hotkey_settings.ini")
    HK_LoadModes(FileExist(baseHot) ? baseHot : ini)
    if !FileExist(ini) {
        SettingsDiagPush("WARN", "Hotkey settings load skipped", "No hotkey settings file found; using defaults.")
        return
    }
    try {
        section := IniRead(ini, "Hotkeys")
    } catch {
        section := ""
    }
    if section != "" {
        for line in StrSplit(section, "`n") {
            if !InStr(line, "=")
                continue
            id := HK_NormalizeSavedHotkeyId(Trim(SubStr(line, 1, InStr(line, "=") - 1)))
            val := HK_NormalizeSavedHotkeyValue(id, Trim(SubStr(line, InStr(line, "=") + 1)))
            HK_Custom[id] := val
        }
    }
    if HK_Custom.Has("reset_mods") && HK_Custom["reset_mods"] = "^!+Space"
        HK_Custom["reset_mods"] := "^!+Backspace"
    try {
        fnSection := IniRead(ini, "HotkeyFns")
    } catch {
        fnSection := ""
    }
    if fnSection != "" {
        for line in StrSplit(fnSection, "`n") {
            if !InStr(line, "=")
                continue
            id := Trim(SubStr(line, 1, InStr(line, "=") - 1))
            val := Trim(SubStr(line, InStr(line, "=") + 1))
            if val != ""
                HK_CustomFn[id] := val
        }
    }
    try {
        reqSection := IniRead(ini, "HotkeyRequirements")
    } catch {
        reqSection := ""
    }
    if reqSection != "" {
        for line in StrSplit(reqSection, "`n") {
            if !InStr(line, "=")
                continue
            id := Trim(SubStr(line, 1, InStr(line, "=") - 1))
            val := Trim(SubStr(line, InStr(line, "=") + 1))
            HK_CustomReq[id] := val
        }
    }
    try {
        actSection := IniRead(ini, "HotkeyActivate")
    } catch
        actSection := ""
    if actSection != "" {
        for line in StrSplit(actSection, "`n") {
            if !InStr(line, "=")
                continue
            id := Trim(SubStr(line, 1, InStr(line, "=") - 1))
            val := Trim(SubStr(line, InStr(line, "=") + 1))
            HK_CustomActivate[id] := val = "1"
        }
    }
    try {
        tgtSection := IniRead(ini, "HotkeyTargets")
    } catch
        tgtSection := ""
    if tgtSection != "" {
        for line in StrSplit(tgtSection, "`n") {
            if !InStr(line, "=")
                continue
            id := Trim(SubStr(line, 1, InStr(line, "=") - 1))
            val := Trim(SubStr(line, InStr(line, "=") + 1))
            HK_CustomTarget[id] := val
        }
    }
    try {
        blkSection := IniRead(ini, "HotkeyBlock")
    } catch
        blkSection := ""
    if blkSection != "" {
        for line in StrSplit(blkSection, "`n") {
            if !InStr(line, "=")
                continue
            id := Trim(SubStr(line, 1, InStr(line, "=") - 1))
            val := Trim(SubStr(line, InStr(line, "=") + 1))
            HK_CustomBlock[id] := val = "1"
        }
    }
    try {
        abSection := IniRead(ini, "ApplyBlock")
    } catch
        abSection := ""
    if abSection != "" {
        for line in StrSplit(abSection, "`n") {
            if !InStr(line, "=")
                continue
            keyName := Trim(SubStr(line, 1, InStr(line, "=") - 1))
            scope := Trim(SubStr(line, InStr(line, "=") + 1))
            if scope != "" && scope != "target" && scope != "global"
                scope := "target"
            HK_ApplyBlock[keyName] := scope
        }
    }
    try {
        capsSection := IniRead(ini, "CapslockSlots")
    } catch
        capsSection := ""
    if capsSection != "" {
        for line in StrSplit(capsSection, "`n") {
            if !InStr(line, "=")
                continue
            keyName := Trim(SubStr(line, 1, InStr(line, "=") - 1))
            val := Trim(SubStr(line, InStr(line, "=") + 1))
            parts := StrSplit(keyName, "_")
            if parts.Length < 2
                continue
            slot := HK_NormalizeCapslockSlotId(parts[1])
            field := parts[2]
            if !CapslockSlotActions.Has(slot) {
                slotLabel := slot = "backtick" ? "``" : slot
                CapslockSlotActions[slot] := Map("label", "CapsLock + " slotLabel, "type", "disabled", "action", "", "requirement", "", "enabled", 0)
            }
            CapslockSlotActions[slot][field] := val
        }
        for slot, item in CapslockSlotActions {
            item["enabled"] := ToolkitSafeInt(item.Get("enabled", 0), 0, 0, 1)
            item["type"] := StrLower(Trim(item.Get("type", "disabled")))
            item["requirement"] := HK_NormalizeRequirement(item.Get("requirement", ""))
        }
    }
    HK_PurgeObsoleteCustomData()
    HK_LoadUserDefs()
    SettingsDiagPush(
        "OK",
        "Loaded hotkey settings",
        ini
        " | keys=" HK_Custom.Count
        ", fn=" HK_CustomFn.Count
        ", req=" HK_CustomReq.Count
        ", activate=" HK_CustomActivate.Count
        ", block=" HK_CustomBlock.Count
        ", caps=" CapslockSlotActions.Count
    )
}

HK_PurgeObsoleteCustomData() {
    global HK_Custom, HK_CustomFn, HK_CustomReq, HK_CustomActivate, HK_CustomBlock
    obsolete := ["bg_picker", "color_picker_bg"]
    for id in obsolete {
        try HK_Custom.Delete(id)
        try HK_CustomFn.Delete(id)
        try HK_CustomReq.Delete(id)
        try HK_CustomActivate.Delete(id)
        try HK_CustomBlock.Delete(id)
    }
    for id, val in HK_CustomFn {
        val := Trim(val)
        if HK_IsFnDisabledMarker(val)
            HK_CustomFn[id] := HK_FnDisabledMarker()
    }
}

; --- Save custom hotkeys to INI ---
HK_Save() {
    global HK_Custom, HK_CustomFn, HK_CustomReq, HK_CustomActivate, CapslockSlotActions, HOTKEY_SETTINGS_FILE, HK_Modes, HK_Mode, HK_ModeOrder
    global HK_CustomBlock, HK_ApplyBlock
    try {
        IniDelete(HOTKEY_SETTINGS_FILE, "Hotkeys")
        for id, val in HK_Custom
            IniWrite(HK_NormalizeSavedHotkeyValue(id, val), HOTKEY_SETTINGS_FILE, "Hotkeys", id)
        IniDelete(HOTKEY_SETTINGS_FILE, "HotkeyFns")
        for id, val in HK_CustomFn
            IniWrite(val, HOTKEY_SETTINGS_FILE, "HotkeyFns", id)
        IniDelete(HOTKEY_SETTINGS_FILE, "HotkeyRequirements")
        for id, val in HK_CustomReq
            IniWrite(val, HOTKEY_SETTINGS_FILE, "HotkeyRequirements", id)
        IniDelete(HOTKEY_SETTINGS_FILE, "HotkeyActivate")
        for id, val in HK_CustomActivate
            IniWrite(val ? "1" : "0", HOTKEY_SETTINGS_FILE, "HotkeyActivate", id)
        IniDelete(HOTKEY_SETTINGS_FILE, "HotkeyBlock")
        for id, val in HK_CustomBlock
            IniWrite(val ? "1" : "0", HOTKEY_SETTINGS_FILE, "HotkeyBlock", id)
        IniDelete(HOTKEY_SETTINGS_FILE, "ApplyBlock")
        for keyName, scope in HK_ApplyBlock
            IniWrite(scope, HOTKEY_SETTINGS_FILE, "ApplyBlock", keyName)
        IniDelete(HOTKEY_SETTINGS_FILE, "HotkeyTargets")
        for id, val in HK_CustomTarget
            IniWrite(val, HOTKEY_SETTINGS_FILE, "HotkeyTargets", id)
        IniDelete(HOTKEY_SETTINGS_FILE, "TargetWindows")
        HK_SaveTargetWindows()
        IniDelete(HOTKEY_SETTINGS_FILE, "CapslockSlots")
        for slot, item in CapslockSlotActions {
            if !IsObject(item)
                continue
            slot := HK_NormalizeCapslockSlotId(slot)
            slotLabel := slot = "backtick" ? "``" : slot
            IniWrite(item.Get("label", "CapsLock + " slotLabel), HOTKEY_SETTINGS_FILE, "CapslockSlots", slot "_label")
            slotType := StrLower(Trim(item.Get("type", "disabled")))
            slotAction := item.Get("action", "")
            if (slotType = "shortcut" || slotType = "action") && slotAction != ""
                slotAction := PieQuickNormalizeShortcutAction(slotAction)
            IniWrite(slotType, HOTKEY_SETTINGS_FILE, "CapslockSlots", slot "_type")
            IniWrite(slotAction, HOTKEY_SETTINGS_FILE, "CapslockSlots", slot "_action")
            IniWrite(HK_NormalizeRequirement(item.Get("requirement", "")), HOTKEY_SETTINGS_FILE, "CapslockSlots", slot "_requirement")
            IniWrite(item.Get("enabled", 0) ? "1" : "0", HOTKEY_SETTINGS_FILE, "CapslockSlots", slot "_enabled")
        }
        HK_SaveUserDefs()
        HK_SaveModes()
        try SettingsSyncIniWatcher()
    }
}

; --- Target windows: configurable set of windows hotkeys can fire in ---
; Each entry: "win<n>" -> Map("exe", "Name.exe", "name", "Display name", "enabled", 0/1)
; Default entry "win1" is Clip Studio Paint and is always present (seeded when the INI has none).

HK_EnsureTargetDefaults() {
    global HK_TargetWindows
    if !IsObject(HK_TargetWindows)
        HK_TargetWindows := Map()
    if HK_TargetWindows.Count = 0 {
        HK_TargetWindows["win1"] := Map("exe", "CLIPStudioPaint.exe", "name", "Clip Studio Paint", "enabled", 1)
    }
}

HK_LoadTargetWindows(ini) {
    global HK_TargetWindows
    HK_TargetWindows := Map()
    if FileExist(ini) {
        try {
            twSection := IniRead(ini, "TargetWindows")
        } catch
            twSection := ""
        if twSection != "" {
            for line in StrSplit(twSection, "`n") {
                if !InStr(line, "=")
                    continue
                keyName := Trim(SubStr(line, 1, InStr(line, "=") - 1))
                val := Trim(SubStr(line, InStr(line, "=") + 1))
                if RegExMatch(keyName, "i)^win(\d+)_(exe|name|enabled)$", &m) {
                    wid := "win" m[1]
                    if !HK_TargetWindows.Has(wid)
                        HK_TargetWindows[wid] := Map("exe", "", "name", "", "enabled", 0)
                    if m[2] = "exe"
                        HK_TargetWindows[wid]["exe"] := val
                    else if m[2] = "name"
                        HK_TargetWindows[wid]["name"] := val
                    else
                        HK_TargetWindows[wid]["enabled"] := val = "1" ? 1 : 0
                }
            }
        }
    }
    HK_EnsureTargetDefaults()
}

HK_SaveTargetWindows() {
    global HK_TargetWindows, HOTKEY_SETTINGS_FILE
    HK_EnsureTargetDefaults()
    for wid, t in HK_TargetWindows {
        if !IsObject(t)
            continue
        IniWrite(t.Get("exe", ""), HOTKEY_SETTINGS_FILE, "TargetWindows", wid "_exe")
        IniWrite(t.Get("name", ""), HOTKEY_SETTINGS_FILE, "TargetWindows", wid "_name")
        IniWrite(t.Get("enabled", 0) ? "1" : "0", HOTKEY_SETTINGS_FILE, "TargetWindows", wid "_enabled")
    }
}

; Exe list of a target entry. Multiple processes (a target group) are stored
; pipe-separated in the exe field, e.g. "Photoshop.exe|Illustrator.exe".
HK_TargetExeList(t) {
    exes := []
    raw := Trim(t.Get("exe", ""))
    if raw = ""
        return exes
    for part in StrSplit(raw, "|") {
        p := Trim(part)
        if p != ""
            exes.Push(p)
    }
    return exes
}

HK_DefaultTargetWinTitle() {
    global HK_TargetWindows
    HK_EnsureTargetDefaults()
    w1 := HK_TargetWindows.Get("win1", Map())
    exes := HK_TargetExeList(w1)
    if exes.Length = 0
        return "ahk_exe CLIPStudioPaint.exe"
    return "ahk_exe " exes[1]
}

HK_TargetActive(title := "") {
    global HK_TargetWindows
    HK_EnsureTargetDefaults()
    if title != "" {
        for _, t in HK_TargetWindows {
            if !t.Get("enabled", 0)
                continue
            for _, exe in HK_TargetExeList(t) {
                if ("ahk_exe " exe) != title
                    continue
                if WinActive(title)
                    return true
            }
        }
        return false
    }
    for _, t in HK_TargetWindows {
        if !t.Get("enabled", 0)
            continue
        for _, exe in HK_TargetExeList(t)
            if WinActive("ahk_exe " exe)
                return true
    }
    return false
}

HK_TargetExists() {
    global HK_TargetWindows
    HK_EnsureTargetDefaults()
    for _, t in HK_TargetWindows {
        if !t.Get("enabled", 0)
            continue
        for _, exe in HK_TargetExeList(t)
            if WinExist("ahk_exe " exe)
                return true
    }
    return false
}

HK_GetTarget(id) {
    global HK_CustomTarget
    return HK_CustomTarget.Has(id) && HK_CustomTarget[id] != "" ? HK_CustomTarget[id] : ""
}

; A per-hotkey condition: base group condition AND the hotkey's own target window active.
HK_MakeHotKeyCond(baseFn, id) {
    return (*) => baseFn() && HK_TargetActiveForId(id) && HK_IBShortcutAllowed(id) && !HK_FeatureHotkeyBlocked(id)
}

; Per-hotkey target check that honors target groups (any process in the group).
; An empty or unknown assignment means the default target (win1), checked as a
; group the same way so all of win1's processes count.
HK_TargetActiveForId(id) {
    global HK_TargetWindows
    HK_EnsureTargetDefaults()
    t := HK_GetTarget(id)
    if t = "any"
        return HK_TargetActive()
    entry := (t != "" && HK_TargetWindows.Has(t)) ? HK_TargetWindows[t] : HK_TargetWindows.Get("win1", Map())
    if !entry.Get("enabled", 0)
        return false
    for exe in HK_TargetExeList(entry)
        if WinActive("ahk_exe " exe)
            return true
    return false
}

; Master feature switch for user script hotkeys: blocks them all when the
; "User Scripts" feature is toggled off. The result is cached per hotkey id
; because this is evaluated inside #HotIf condition closures on key events;
; HK_ReapplyAll clears the cache whenever feature switches are reapplied.
global _HK_FeatureBlockCache := Map()

HK_FeatureHotkeyBlocked(id) {
    global _HK_FeatureBlockCache
    if _HK_FeatureBlockCache.Has(id)
        return _HK_FeatureBlockCache[id]
    d := HK_FindDef(id)
    blocked := IsObject(d) && d.HasOwnProp("user") && d.user && !FeatureEnabled("userscript")
    _HK_FeatureBlockCache[id] := blocked
    return blocked
}

; IB change shortcuts (Ctrl+` and Ctrl+2-8) can be toggled off from the IB bar
; context menu so only Ctrl+1 ("IB: Select current") keeps working.
HK_IBShortcutAllowed(id) {
    if SubStr(id, 1, 3) != "ib_"
        return true
    global IBShortcutsEnabled
    if IBShortcutsEnabled = "" || IBShortcutsEnabled
        return true
    if id = "ib_1" || id = "ib_guide"
        return true
    return false
}

; --- Target window management helpers (used by the GUI) ---

HK_TargetOptionList() {
    global HK_TargetWindows
    HK_EnsureTargetDefaults()
    w1 := HK_TargetWindows["win1"]
    w1Name := Trim(w1.Get("name", ""))
    if w1Name = ""
        w1Name := "Clip Studio Paint"
    opts := [{val: "", label: "Default (" w1Name ")"}, {val: "any", label: "Any enabled target window"}]
    for wid, t in HK_TargetWindows {
        if wid = "win1"
            continue
        exe := t.Get("exe", "")
        name := t.Get("name", "")
        if name = ""
            name := exe != "" ? StrReplace(exe, "|", " + ") : wid
        label := name (t.Get("enabled", 0) ? "" : " (disabled)")
        opts.Push({val: wid, label: label})
    }
    return opts
}

HK_NextTargetId() {
    global HK_TargetWindows
    HK_EnsureTargetDefaults()
    n := 1
    while HK_TargetWindows.Has("win" n)
        n++
    return "win" n
}

; Validate a target exe value and normalize it to a pipe-separated list with no
; empty parts, no duplicate members, and no process already used by another
; target. Returns "" when nothing usable remains.
HK_NormalizeTargetExe(exe, excludeWid := "") {
    global HK_TargetWindows
    parts := []
    seen := Map()
    for part in StrSplit(exe, "|") {
        p := Trim(part)
        if p = ""
            continue
        key := StrLower(p)
        if seen.Has(key)
            continue
        seen[key] := 1
        for wid, t in HK_TargetWindows {
            if wid = excludeWid
                continue
            for _, existing in HK_TargetExeList(t)
                if StrLower(existing) = key
                    return ""
        }
        parts.Push(p)
    }
    if parts.Length = 0
        return ""
    out := ""
    for i, p in parts
        out .= (i = 1 ? "" : "|") p
    return out
}

HK_AddTargetWindow(exe, name := "", enabled := 1) {
    global HK_TargetWindows
    HK_EnsureTargetDefaults()
    exe := HK_NormalizeTargetExe(exe)
    if exe = ""
        return ""
    wid := HK_NextTargetId()
    HK_TargetWindows[wid] := Map("exe", exe, "name", Trim(name), "enabled", enabled ? 1 : 0)
    return wid
}

HK_RemoveTargetWindow(wid) {
    global HK_TargetWindows, HK_CustomTarget
    if !HK_TargetWindows.Has(wid)
        return
    HK_TargetWindows.Delete(wid)
    for id, target in HK_CustomTarget {
        if target = wid
            HK_CustomTarget[id] := ""
    }
}

HK_SetTargetEnabled(wid, enabled) {
    global HK_TargetWindows
    if HK_TargetWindows.Has(wid)
        HK_TargetWindows[wid]["enabled"] := enabled ? 1 : 0
}

HK_FnForName(name) {
    global HotkeyDefs
    name := Trim(name)
    if name = "" || HK_IsFnDisabledMarker(name)
        return 0
    if RegExMatch(name, "^[A-Za-z_][A-Za-z0-9_]*$") && IsSet(%name%) && Type(%name%) = "Func"
        return %name%
    if IsObject(HotkeyDefs) {
        for d in HotkeyDefs {
            if HK_GetDefaultFnName(d) = name && IsObject(d.fn)
                return d.fn
        }
    }
    return 0
}

; --- Get effective hotkey (custom or default) ---
HK_Get(id, def) {
    global HK_Custom
    return HK_Custom.Has(id) && HK_Custom[id] != "" ? HK_Custom[id] : def
}

; Returns a Map of the current mode's backup defaults (id → key) read from
; docs\mode_defaults.ini.  Used by Reset Sel / Reset All so restoring a
; hotkey targets the mode's intended defaults — not user customizations
; that HK_Save has already written into the live INI.
HK_LoadModeDefaults() {
    global HK_Mode
    defaults := Map()
    file := A_ScriptDir "\src\docs\mode_defaults.ini"
    if !FileExist(file)
        return defaults
    sectionName := "Mode_" (HK_Mode != "" ? HK_Mode : "default")
    try section := IniRead(file, sectionName)
    catch
        return defaults
    for line in StrSplit(section, "`n") {
        line := Trim(line)
        if line = "" || SubStr(line, 1, 1) = ";"
            continue
        if !InStr(line, "=")
            continue
        id := HK_NormalizeSavedHotkeyId(Trim(SubStr(line, 1, InStr(line, "=") - 1)))
        val := HK_NormalizeSavedHotkeyValue(id, Trim(SubStr(line, InStr(line, "=") + 1)))
        defaults[id] := val
    }
    return defaults
}

; Returns the mode default key for a single hotkey id, falling back to
; d.def when the backup file has no entry for it.
HK_ModeDefaultKey(id, compiledDef) {
    defaults := HK_LoadModeDefaults()
    return (defaults.Has(id) && defaults[id] != "") ? defaults[id] : compiledDef
}

HK_DisplayKey(key) {
    if key = "" || key = "-"
        return key
    if InStr(key, "|") {
        parts := StrSplit(key, "|")
        result := ""
        for i, p in parts {
            p := Trim(p)
            if p = "" || p = "-"
                continue
            result .= (result = "" ? "" : " | ") HotkeyDisplayName(p)
        }
        return result != "" ? result : key
    }
    return HotkeyDisplayName(key)
}

HK_SplitKeys(key) {
    if !InStr(key, "|")
        return [Trim(key)]
    parts := StrSplit(key, "|")
    result := []
    for p in parts {
        p := Trim(p)
        if p != ""
            result.Push(p)
    }
    return result.Length > 0 ? result : [""]
}

HK_NormalizeSavedHotkeyValue(id, key) {
    global HK_Mode
    key := Trim(key)
    if id = "caps_num_backtick" && (StrLower(key) = "capslock & tilde" || StrLower(key) = "capslock & backtick")
        return "CapsLock & SC029"
    key := StrLower(key)
    if id = "toggle_lt" && HK_Mode != "tracing" && InStr(key, "|") {
        parts := StrSplit(key, "|")
        filtered := []
        for p in parts {
            p := Trim(p)
            if p != "" && p != "-" && p != "!w"
                filtered.Push(p)
        }
        if filtered.Length > 0 {
            result := ""
            for p in filtered
                result .= (result = "" ? "" : "|") p
            return result
        }
    }
    return key
}

HK_NormalizeSavedHotkeyId(id) {
    id := Trim(id)
    return id = "caps_num_tilde" ? "caps_num_backtick" : id
}

HK_NormalizeCapslockSlotId(slot) {
    slot := Trim(slot)
    return slot = "tilde" || slot = "~" || slot = "``" ? "backtick" : slot
}

HK_GetFnName(d) {
    global HK_CustomFn
    if HK_CustomFn.Has(d.id) && HK_IsFnDisabledMarker(HK_CustomFn[d.id])
        return "(disabled)"
    if HK_CustomFn.Has(d.id) && HK_CustomFn[d.id] != ""
        return HK_CustomFn[d.id]
    if !HK_DefaultFnEnabled(d)
        return "(disabled)"
    return HK_GetDefaultFnName(d)
}

HK_DefaultFnEnabled(d) {
    return !(IsObject(d) && d.HasOwnProp("fnEnabled") && !d.fnEnabled)
}

HK_FnDisabledMarker() {
    global HK_FN_DISABLED
    return HK_FN_DISABLED
}

HK_IsFnDisabledMarker(value) {
    value := Trim(value)
    return value = "-" || value = HK_FnDisabledMarker() || value = "(disabled)" || StrLower(value) = "disabled"
}

HK_GetDefaultFnName(d) {
    if d.HasOwnProp("fnName") && d.fnName != ""
        return d.fnName
    try {
        if HasProp(d.fn, "Name") && d.fn.Name != ""
            return d.fn.Name
    }
    return "(inline)"
}

HK_GetFn(d) {
    global HK_CustomFn
    if HK_CustomFn.Has(d.id) && HK_CustomFn[d.id] != "" {
        if HK_IsFnDisabledMarker(HK_CustomFn[d.id])
            return 0
        return HK_FnForName(HK_CustomFn[d.id])
    }
    if !HK_DefaultFnEnabled(d)
        return 0
    return d.fn
}

HK_GetCurrentKey(fnName, def := "") {
    global HotkeyDefs, HK_Registered
    fs := StrSplit(fnName, "(")
    fnBase := Trim(fs[1])
    try {
        if IsObject(HotkeyDefs) {
            for d in HotkeyDefs {
                try {
                    if HK_GetFnName(d) = fnBase && HK_GetFn(d) {
                        if IsObject(HK_Registered) && HK_Registered.Has(d.id)
                            return HotkeyDisplayName(HK_Registered[d.id])
                        return HotkeyDisplayName(d.def)
                    }
                }
            }
        }
    }
    return HotkeyDisplayName(def)
}

HK_ContextRequirement(group) {
    switch group {
        case "csp":
            return "CSP active, not typing"
        case "csp_nav":
            return "CSP active, Nav ON, not typing"
        case "csp_caps":
            return "CSP active, Capslock mod ON, not typing"
        case "csp_reset":
            return "CSP active, Reset keys ON, not typing"
        case "csp_lwin":
            return "CSP active, LWin mode ON, not typing"
        case "bg":
            return "CSP open in background, not typing"
        case "global":
            return "Global, not typing"
    }
    return group
}

HK_GetRequirement(d) {
    global HK_CustomReq
    if HK_CustomReq.Has(d.id)
        return HK_NormalizeRequirement(HK_CustomReq[d.id])
    if d.HasOwnProp("req") && Trim(d.req) != ""
        return HK_NormalizeRequirement(d.req)
    if IsObject(d) && d.HasOwnProp("user") && d.user && d.HasOwnProp("scriptFile") && d.scriptFile != ""
        return HK_UserScriptRequirement(d.scriptFile)
    return HK_NormalizeRequirement(HK_DefaultRequirement(d))
}

HK_NormalizeRequirement(req) {
    req := Trim(req)
    if req = "Animation_autoaction"
        return REQ_ANIM
    if req = "Nastar"
        return REQ_NASTAR
    return req
}

HK_IsRequirementEnabled(d) {
    global ReqAnimationEnabled, ReqNastarEnabled
    if !IsObject(d)
        return false
    req := HK_GetRequirement(d)
    if req = REQ_ANIM
        return !!ReqAnimationEnabled
    if req = REQ_NASTAR
        return !!ReqNastarEnabled
    if IsObject(d) && d.HasOwnProp("user") && d.user && d.HasOwnProp("scriptFile") && d.scriptFile != "" {
        if !FileExist(d.scriptFile)
            return false
        if HK_UserScriptDisabled(d.scriptFile)
            return false
    }
    return true
}

HK_DefaultRequirement(d) {
    id := d.id
    if SubStr(id, 1, 3) = "ib_"
        return REQ_ANIM
    if SubStr(id, 1, 6) = "layer_" || SubStr(id, 1, 8) = "feature_" || SubStr(id, 1, 7) = "create_" || SubStr(id, 1, 6) = "guide_"
        return REQ_NASTAR
    if id = "transfer_raster" || id = "transfer_vector" || id = "delete_layer" || id = "delete_cel_tl" || id = "delete_cel_lt"
        return REQ_NASTAR
    if SubStr(d.def, 1, 1) = "~"
        return REQ_NASTAR
    return ""
}

HK_SanitizeId(text) {
    id := RegExReplace(StrLower(Trim(text)), "[^a-z0-9_]+", "_")
    id := RegExReplace(id, "^_+|_+$", "")
    return id != "" ? id : "user_hotkey"
}

HK_SanitizeFnName(text) {
    name := RegExReplace(Trim(text), "[^A-Za-z0-9_]", "")
    if name = "" || !RegExMatch(name, "^[A-Za-z_]")
        name := "UserHotkey_" A_TickCount
    return name
}
