; Quick Reference for Windows
; Your cheat sheets, one key away. Press the hotkey (default Win+Shift+K),
; pick a sheet, read it, press Esc to go back to what you were doing.
;
; https://github.com/ggregoro/Windows-Quick-Reference
; License: GPL-3.0 (see LICENSE)

#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

AppName := "Quick Reference"
IniFile := A_ScriptDir "\QuickReference.ini"

; ---------- settings (QuickReference.ini next to the script) ----------
Cfg := {
    Folder:   ExpandEnv(IniRead(IniFile, "Settings", "Folder", A_MyDocuments "\Quick Reference")),
    Hotkey:   IniRead(IniFile, "Settings", "Hotkey", "#+k"),
    FontName: IniRead(IniFile, "Settings", "FontName", "Consolas"),
    FontSize: Integer(IniRead(IniFile, "Settings", "FontSize", "12")),
    Width:    Integer(IniRead(IniFile, "Settings", "Width", "1000")),
    Height:   Integer(IniRead(IniFile, "Settings", "Height", "650")),
    Theme:    StrLower(IniRead(IniFile, "Settings", "Theme", "auto")),   ; auto | dark | light
}
if !FileExist(IniFile)
    WriteDefaultIni()
if !DirExist(Cfg.Folder)
    DirCreate(Cfg.Folder)

ListWidth := 260
Docs := []        ; all sheets in the folder: {name, path}
Shown := []       ; the sheets currently in the list (after filtering)
LastName := ""    ; last sheet viewed, selected again next time
PrevHwnd := 0     ; window that was active before we opened

; ---------- window ----------
G := Gui("+AlwaysOnTop +Resize +MinSize560x320", AppName)
G.MarginX := 10, G.MarginY := 10
G.SetFont("s10", "Segoe UI")
FilterBox := G.Add("Edit", "w" ListWidth)
SendMessage(0x1501, true, StrPtr("Type to filter"), FilterBox)   ; EM_SETCUEBANNER
DocList := G.Add("ListBox", "w" ListWidth " r20")
G.SetFont("s" Cfg.FontSize, Cfg.FontName)
Viewer := G.Add("Edit", "x+10 ym w700 h600 ReadOnly Multi VScroll -WantReturn")

FilterBox.OnEvent("Change", (*) => RefreshList())
DocList.OnEvent("Change", (*) => ShowSelected())
DocList.OnEvent("DoubleClick", (*) => Viewer.Focus())
G.OnEvent("Escape", (*) => HideGui())
G.OnEvent("Close", (*) => HideGui())
G.OnEvent("Size", OnSize)

; ---------- tray icon ----------
A_IconTip := AppName
A_TrayMenu.Delete()
A_TrayMenu.Add("Open " AppName, ToggleGui)
A_TrayMenu.Add("Open sheets folder", (*) => Run('explorer.exe "' Cfg.Folder '"'))
A_TrayMenu.Add("Edit settings", (*) => Run('notepad.exe "' IniFile '"'))
A_TrayMenu.Add()
A_TrayMenu.Add("Reload", (*) => Reload())
A_TrayMenu.Add("Exit", (*) => ExitApp())
A_TrayMenu.Default := "Open " AppName

Hotkey(Cfg.Hotkey, ToggleGui)

; ---------- keys while the window is active ----------
#HotIf GuiActive() && G.FocusedCtrl = FilterBox
Up::MoveSel(-1)
Down::MoveSel(1)
#HotIf GuiActive()
Enter::Viewer.Focus()
NumpadEnter::Viewer.Focus()
PgUp::ScrollViewer(2)     ; SB_PAGEUP
PgDn::ScrollViewer(3)     ; SB_PAGEDOWN
^=::ChangeFont(1)
^NumpadAdd::ChangeFont(1)
^-::ChangeFont(-1)
^NumpadSub::ChangeFont(-1)
#HotIf

; ---------- functions ----------
GuiActive() => WinActive("ahk_id " G.Hwnd)

ToggleGui(*) {
    global PrevHwnd
    if DllCall("IsWindowVisible", "Ptr", G.Hwnd) {
        if GuiActive() {
            HideGui()
        } else {
            WinActivate(G.Hwnd)       ; open but behind something: bring it forward
            FilterBox.Focus()
        }
        return
    }
    PrevHwnd := WinExist("A")
    ApplyTheme()
    LoadDocs()
    FilterBox.Value := ""
    RefreshList()
    G.Show("w" Cfg.Width " h" Cfg.Height)
    FilterBox.Focus()
}

HideGui() {
    G.GetClientPos(, , &w, &h)
    if (w > 0 && h > 0 && (w != Cfg.Width || h != Cfg.Height)) {
        Cfg.Width := w, Cfg.Height := h
        IniWrite(w, IniFile, "Settings", "Width")
        IniWrite(h, IniFile, "Settings", "Height")
    }
    G.Hide()
    if (PrevHwnd && WinExist("ahk_id " PrevHwnd))
        try WinActivate("ahk_id " PrevHwnd)
}

; Read the folder again every time we open, so edits made on another machine
; (for example through OneDrive) show up. .txt and .md only; if a sheet exists
; as both, the .txt is shown.
LoadDocs() {
    global Docs
    found := Map()
    found.CaseSense := false
    Loop Files, Cfg.Folder "\*.*", "F" {
        ext := StrLower(A_LoopFileExt)
        if (ext != "txt" && ext != "md")
            continue
        name := SubStr(A_LoopFileName, 1, -(StrLen(A_LoopFileExt) + 1))
        if (found.Has(name) && ext = "md")
            continue
        found[name] := A_LoopFileFullPath
    }
    names := ""
    for name in found
        names .= name "`n"
    names := Sort(RTrim(names, "`n"))
    Docs := []
    if (names != "")
        for name in StrSplit(names, "`n")
            Docs.Push({name: name, path: found[name]})
}

RefreshList() {
    global Shown
    f := Trim(FilterBox.Value)
    Shown := []
    for d in Docs
        if (f = "" || InStr(d.name, f))
            Shown.Push(d)
    DocList.Delete()
    names := []
    pick := 1
    for i, d in Shown {
        names.Push(d.name)
        if (f = "" && d.name = LastName)
            pick := i
    }
    if names.Length {
        DocList.Add(names)
        DocList.Choose(pick)
    }
    ShowSelected()
}

ShowSelected() {
    global LastName
    i := DocList.Value
    if (!i || i > Shown.Length) {
        if !Docs.Length
            Viewer.Value := "No sheets yet.`r`n`r`nPut .txt or .md files in:`r`n" Cfg.Folder
                . "`r`n`r`n(Tray icon > Open sheets folder)"
        else
            Viewer.Value := "No sheet matches the filter."
        return
    }
    d := Shown[i]
    try
        text := FileRead(d.path, "UTF-8")
    catch as e {
        Viewer.Value := "Could not read " d.path "`r`n`r`n" e.Message
        return
    }
    ; the Edit control needs CRLF line endings
    Viewer.Value := StrReplace(StrReplace(text, "`r`n", "`n"), "`n", "`r`n")
    LastName := d.name
}

MoveSel(step) {
    if !Shown.Length
        return
    i := DocList.Value + step
    i := i < 1 ? 1 : (i > Shown.Length ? Shown.Length : i)
    DocList.Choose(i)
    ShowSelected()
}

ScrollViewer(code) {
    SendMessage(0x115, code, 0, Viewer)   ; WM_VSCROLL
}

ChangeFont(step) {
    size := Cfg.FontSize + step
    if (size < 8 || size > 48)
        return
    Cfg.FontSize := size
    Viewer.SetFont("s" size)
    IniWrite(size, IniFile, "Settings", "FontSize")
}

OnSize(gui, minMax, w, h) {
    if (minMax = -1)
        return
    DocList.GetPos(, &ly)
    DocList.Move(, , ListWidth, h - ly - 10)
    Viewer.Move(ListWidth + 20, 10, w - ListWidth - 30, h - 20)
}

; Dark or light, checked every time the window opens, so "auto" follows
; Windows' own setting (Settings > Personalization > Colors > app mode).
IsDark() {
    if (Cfg.Theme = "dark")
        return true
    if (Cfg.Theme = "light")
        return false
    try return RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme") = 0
    return false
}

ApplyTheme() {
    static current := ""
    dark := IsDark()
    if (dark = current)
        return
    current := dark
    G.BackColor := dark ? "202020" : "Default"
    for ctl in [FilterBox, DocList, Viewer] {
        ctl.Opt(dark ? "+Background2B2B2B" : "+BackgroundDefault")
        ctl.SetFont(dark ? "cE4E4E4" : "cDefault")
        DllCall("uxtheme\SetWindowTheme", "Ptr", ctl.Hwnd, "Str", dark ? "DarkMode_Explorer" : "Explorer", "Ptr", 0)
        ctl.Redraw()
    }
    ; dark title bar (DWMWA_USE_IMMERSIVE_DARK_MODE = 20; Windows 10 20H1 and later)
    DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", G.Hwnd, "Int", 20, "Int*", dark ? 1 : 0, "Int", 4)
}

WriteDefaultIni() {
    IniWrite(Cfg.Theme, IniFile, "Settings", "Theme")
    IniWrite(Cfg.Folder, IniFile, "Settings", "Folder")
    IniWrite(Cfg.Hotkey, IniFile, "Settings", "Hotkey")
    IniWrite(Cfg.FontName, IniFile, "Settings", "FontName")
    IniWrite(Cfg.FontSize, IniFile, "Settings", "FontSize")
    IniWrite(Cfg.Width, IniFile, "Settings", "Width")
    IniWrite(Cfg.Height, IniFile, "Settings", "Height")
}

ExpandEnv(s) {
    buf := Buffer(65536)
    DllCall("ExpandEnvironmentStringsW", "Str", s, "Ptr", buf, "UInt", 32768)
    return StrGet(buf)
}
