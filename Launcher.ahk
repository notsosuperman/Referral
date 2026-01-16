; ==============================================================================
; Dental Referral Launcher
; Main menu for selecting specialist referral forms
; ==============================================================================
#NoEnv
#SingleInstance, Force
SetWorkingDir %A_ScriptDir%

; ==============================================================================
; Cursor Mode Check - Pause if running in Cursor IDE
; ==============================================================================
global ODWindowTitle := ""
global PatientName := ""

; Check if running inside Cursor IDE
WinGetTitle, currentTitle, A
if (InStr(currentTitle, "Cursor"))
{
    ToolTip, Running in Cursor mode`n`nActivate an Open Dental patient window and press F1 to continue
    Hotkey, F1, ContinueAfterF1, On
    return  ; Pause auto-execute section
}

ContinueAfterF1:
    ToolTip  ; Clear tooltip
    Hotkey, F1, Off
    ; Fall through to OD parsing

; ==============================================================================
; Parse Open Dental Window & Patient Name
; ==============================================================================

; Check if Open Dental is active
if (WinActive("Open Dental {"))
{
    WinGetActiveTitle, ODWindowTitle
    
    ; Parse patient name from title: "Open Dental {username} - LastName, FirstName..."
    if (RegExMatch(ODWindowTitle, " - (.+?)(\||$)", match))
        PatientName := Trim(match1)
}

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
    LaunchForm("Forms\HillsboroOMFS.ahk", "")
return

LaunchOMFS_WisdomTeeth:
    LaunchForm("Forms\HillsboroOMFS.ahk", "Wisdom Teeth")
return

LaunchPerio:
    LaunchForm("Forms\NorthwestPerio.ahk", "")
return

LaunchFarham:
    LaunchForm("Forms\Farham.ahk", "")
return

; Helper function to launch forms with patient context
LaunchForm(formPath, presetName)
{
    global ODWindowTitle
    global PatientName
    
    fullPath := A_ScriptDir . "\" . formPath
    if !FileExist(fullPath)
    {
        MsgBox, 48, Launcher, File not found: %fullPath%
        return
    }
    
    ; Build command line: "patientName" "odWindowTitle" "presetName"
    ; Use quotes to handle spaces in patient names/titles
    cmdLine := """" . fullPath . """"
    if (PatientName != "")
        cmdLine .= " """ . PatientName . """"
    if (ODWindowTitle != "")
        cmdLine .= " """ . ODWindowTitle . """"
    if (presetName != "")
        cmdLine .= " """ . presetName . """"
    
    Run, %cmdLine%
    Sleep, 500
    ExitApp
}

; ==============================================================================
; GUI Close Handler
; ==============================================================================
LauncherGuiClose:
LauncherGuiEscape:
    ExitApp
return
