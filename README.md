# Quick Reference for Windows

Your cheat sheets, one key away, on top of whatever you're doing.

> **In development.** It works, but expect changes.

You're in the middle of something and need one small fact: a shortcut key,
a command you always forget, a setting on a piece of equipment. Instead of
hunting through folders, press **Win+Shift+K**. A small window opens on top
with your sheets. Pick one, read it, press **Esc**, and you're back in the
window you were using.

A Windows sibling of
[Omarchy Quick Reference](https://github.com/ggregoro/Omarchy-Quick-Reference),
built with [AutoHotkey v2](https://www.autohotkey.com).

## What to put in it

A short list you pick yourself, the documents you keep coming back to:
cheat sheets, keyboard shortcuts for an app you use all day, equipment
settings, procedures, announcements you read out. Plain `.txt` and `.md`
files. Markdown is shown as plain text.

## Install

1. Install AutoHotkey v2: `winget install AutoHotkey.AutoHotkey`
2. Download or clone this repo.
3. Double-click `QuickReference.ahk`. A green **H** icon appears in the tray.
4. Put your sheets in `Documents\Quick Reference` (created on first run).
   The `examples` folder has three sample sheets to try.

To start it with Windows, press `Win+R`, type `shell:startup`, and put a
shortcut to `QuickReference.ahk` in the folder that opens.

## Use

| Key | What it does |
|---|---|
| `Win+Shift+K` | Open, or close if it's already in front |
| type | Filter the list by name |
| `Up` / `Down` | Pick a sheet |
| `Enter` | Move into the sheet to scroll it |
| `PgUp` / `PgDn` | Scroll the sheet |
| `Ctrl` + `+` / `-` | Bigger / smaller text (remembered) |
| `Esc` | Close and go back to your previous window |

The folder is read again every time the window opens, so a sheet you edit,
add or remove (also from another PC, through OneDrive or similar) shows up
the next time. If a sheet exists as both `.txt` and `.md`, the `.txt` is
shown.

Right-click the tray icon to open the sheets folder, edit the settings,
reload or exit.

## Settings

`QuickReference.ini` is created next to the script on first run:

```ini
[Settings]
Folder=C:\Users\you\Documents\Quick Reference
Hotkey=#+k
FontName=Consolas
FontSize=12
Width=1000
Height=650
Theme=auto
```

`Theme` is `auto` (follow Windows' light or dark app mode), `dark` or
`light`.

`Mode` is `normal` (the default) or `nofocus`. The window also remembers
where you last put it (`X`, `Y`).

### No-focus mode

Normally the Quick Reference window takes the keyboard while it's open, like
any window. In an app that is driven by keyboard shortcuts (a radio
automation program, a video editor, a game) or by a Stream Deck or macro pad
that sends keys to it, those keys then go to Quick Reference instead.

With `Mode=nofocus` the window never takes focus. It shows on top, but the
app you're working in keeps the keyboard, so its shortcuts keep working
while a sheet is on screen. In this mode:

- pick a sheet by clicking it, scroll with the mouse wheel
- there is no filter box (you can't type into the window)
- `Win+Shift+K` shows and hides it; the window's close button also hides it
- change the text size from the tray menu (**Bigger text** / **Smaller text**)

Tip: park the window beside your app; it opens in the same place next time.

`Hotkey` uses [AutoHotkey's notation](https://www.autohotkey.com/docs/v2/Hotkeys.htm):
`#` Win, `+` Shift, `^` Ctrl, `!` Alt. `Folder` may use environment
variables such as `%USERPROFILE%`. Choose **Reload** from the tray menu
after editing.

## How this was made

This project is AI-assisted. The idea, the testing and the decisions are
mine; the code and most of the documentation were written by Claude,
Anthropic's AI assistant, using Claude Code. I tested it on my own
machines before publishing, but I'm not a professional software
developer, so please read any script before you run it, and open an
issue if something is wrong.

My own work here is under the license in `LICENSE`. Third-party material
(wallpapers, fonts, code from other projects) keeps its own license and
is credited in this README where the source is known. If something isn't
credited correctly, open an issue and I'll fix or remove it.

## License

GPL-3.0, see [LICENSE](LICENSE).
