; ==============================================================================
; Dental Referral Launcher
; Main menu for selecting specialist referral forms
; ==============================================================================
#NoEnv
#SingleInstance, Force
SetWorkingDir %A_ScriptDir%

; ==============================================================================
; Build the GUI
; ==============================================================================
Gui, Launcher:New, , Dental Referral System
Gui, Launcher:Color, FFFFFF
Gui, Launcher:Font, s14 Bold, Arial

; Header
Gui, Launcher:Add, Text, x20 y15 w260 h30 cNavy Center, Dental Referral System

; Separator
Gui, Launcher:Add, Text, x20 y50 w260 h2 +0x10

; Buttons
Gui, Launcher:Font, s11 Normal, Arial
yPos := 70

Gui, Launcher:Add, Button, x20 y%yPos% w260 h40 gLaunchOMFS, Hillsboro OMFS
yPos += 45

; OMFS Presets (indented, smaller)
Gui, Launcher:Font, s9 Normal, Arial
Gui, Launcher:Add, Button, x40 y%yPos% w240 h28 gLaunchOMFS_WisdomTeeth, > Wisdom Teeth
yPos += 35

Gui, Launcher:Font, s11 Normal, Arial
Gui, Launcher:Add, Button, x20 y%yPos% w260 h40 gLaunchPerio, Northwest Periodontics
yPos += 50

Gui, Launcher:Add, Button, x20 y%yPos% w260 h40 gLaunchFarham, Farham
yPos += 50

; Separator
Gui, Launcher:Add, Text, x20 y%yPos% w260 h2 +0x10
yPos += 15

; Exit button
Gui, Launcher:Font, s10, Arial
Gui, Launcher:Add, Button, x20 y%yPos% w260 h30 gLauncherGuiClose, Exit

; Calculate window height
winHeight := yPos + 50

; Show the GUI
Gui, Launcher:Show, w300 h%winHeight%
return

; ==============================================================================
; Button Handlers
; ==============================================================================

LaunchOMFS:
    formPath := A_ScriptDir . "\Forms\HillsboroOMFS.ahk"
    if !FileExist(formPath)
    {
        MsgBox, 48, Launcher, File not found: %formPath%
        return
    }
    Run, "%formPath%"
    Sleep, 500
    ExitApp
return

LaunchOMFS_WisdomTeeth:
    formPath := A_ScriptDir . "\Forms\HillsboroOMFS.ahk"
    if !FileExist(formPath)
    {
        MsgBox, 48, Launcher, File not found: %formPath%
        return
    }
    Run, "%formPath%" "Wisdom Teeth"
    Sleep, 500
    ExitApp
return

LaunchPerio:
    formPath := A_ScriptDir . "\Forms\NorthwestPerio.ahk"
    if !FileExist(formPath)
    {
        MsgBox, 48, Launcher, File not found: %formPath%
        return
    }
    Run, "%formPath%"
    Sleep, 500
    ExitApp
return

LaunchFarham:
    formPath := A_ScriptDir . "\Forms\Farham.ahk"
    if !FileExist(formPath)
    {
        MsgBox, 48, Launcher, File not found: %formPath%
        return
    }
    Run, "%formPath%"
    Sleep, 500
    ExitApp
return

; ==============================================================================
; GUI Close Handler
; ==============================================================================
LauncherGuiClose:
LauncherGuiEscape:
    ExitApp
return
