; ==============================================================================
; Dental Referral Launcher
; Main menu for selecting specialist referral forms
; Captures Open Dental patient context and passes to forms
; ==============================================================================
#NoEnv
#SingleInstance, Force
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2

; ==============================================================================
; Global Variables for Patient Context
; ==============================================================================
global LauncherPatientName := ""
global LauncherODTitle := ""
global LauncherReady := false

; ==============================================================================
; Startup: Capture OD Window Context
; ==============================================================================
CaptureODContext()
return

; ==============================================================================
; Hotkey for F1 (used when OD not initially active)
; ==============================================================================
F1::
    if (!LauncherReady)
    {
        ; User pressed F1 to indicate OD is ready
        CaptureODContextNow()
    }
return

; ==============================================================================
; Hotkey for Esc (exit launcher)
; ==============================================================================
$Esc::
    ExitApp
return

CaptureODContext()
{
    global LauncherPatientName
    global LauncherODTitle
    global LauncherReady
    
    ; Check if Open Dental window exists
    if WinExist("Open Dental {")
    {
        ; Try to activate it if it exists
        if WinActive("Open Dental {")
            CaptureODContextNow()
        else
        {
            ; OD exists but not active - show tooltip and wait for F1
            tipMsg := "Open Dental is not active.`n`nActivate Open Dental with patient chart open,`nthen press F1."
            ToolTip, %tipMsg%, 100, 100
        }
        return
    }
    
    ; Open Dental not found - use test data
    LauncherPatientName := "Smith, John"
    LauncherODTitle := "Open Dental {testuser} - Smith, John"
    LauncherReady := true
    ShowLauncherGUI()
}

CaptureODContextNow()
{
    global LauncherPatientName
    global LauncherODTitle
    global LauncherReady
    
    ToolTip  ; Clear any tooltip
    
    ; Check if OD is active now
    if !WinActive("Open Dental {")
    {
        ; Try to activate it
        WinActivate, Open Dental {
        Sleep, 200
    }
    
    if WinActive("Open Dental {")
    {
        ; Capture the window title
        WinGetTitle, LauncherODTitle, A
        
        ; Parse patient name from title
        ; Format: "Open Dental {username} - LastName, FirstName ..."
        if (RegExMatch(LauncherODTitle, "Open Dental \{[^}]+\} - (.+)", match))
        {
            LauncherPatientName := match1
            ; Trim any trailing info (like chart number etc)
            if (InStr(LauncherPatientName, " ("))
                LauncherPatientName := SubStr(LauncherPatientName, 1, InStr(LauncherPatientName, " (") - 1)
            LauncherPatientName := Trim(LauncherPatientName)
        }
    }
    else
    {
        ; OD still not active - use test data
        LauncherPatientName := "Smith, John"
        LauncherODTitle := "Open Dental {testuser} - Smith, John"
    }
    
    LauncherReady := true
    
    ; Now show the GUI
    ShowLauncherGUI()
}

; ==============================================================================
; Build and Show the GUI
; ==============================================================================
ShowLauncherGUI()
{
    global LauncherPatientName
    
    Gui, Launcher:New, , Dental Referral System
    Gui, Launcher:Color, FFFFFF
    Gui, Launcher:Font, s14 Bold, Arial
    
    ; Header
    Gui, Launcher:Add, Text, x20 y15 w260 h30 cNavy Center, Dental Referral System
    
    ; Patient name display (if captured)
    yPos := 50
    if (LauncherPatientName != "")
    {
        Gui, Launcher:Font, s10 Normal, Arial
        Gui, Launcher:Add, Text, x20 y%yPos% w260 h20 Center cGreen, Patient: %LauncherPatientName%
        yPos += 25
    }
    
    ; Separator
    Gui, Launcher:Add, Text, x20 y%yPos% w260 h2 +0x10
    yPos += 10
    
    ; Buttons
    Gui, Launcher:Font, s11 Normal, Arial
    
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
}

; ==============================================================================
; Launch Form Helper
; Passes patient context and preset to form
; Args passed: "patientName" "odWindowTitle" "presetName"
; ==============================================================================
LaunchForm(formPath, presetName := "")
{
    global LauncherPatientName
    global LauncherODTitle
    
    ; Detect if we're compiled and adjust form extension
    if (A_IsCompiled)
    {
        ; Running as .exe - launch form .exes
        formPath := StrReplace(formPath, ".ahk", ".exe")
    }
    
    if !FileExist(formPath)
    {
        MsgBox, 48, Launcher, File not found: %formPath%
        return
    }
    
    ; Build command line args
    ; Format: "patientName" "odWindowTitle" "presetName"
    args := ""
    
    if (LauncherPatientName != "")
    {
        ; Full mode with patient context
        args := """" . LauncherPatientName . """ """ . LauncherODTitle . """"
        if (presetName != "")
            args .= " """ . presetName . """"
    }
    else if (presetName != "")
    {
        ; Standalone mode with just preset
        args := """" . presetName . """"
    }
    
    if (args != "")
        Run, "%formPath%" %args%
    else
        Run, "%formPath%"
    
    Sleep, 500
    ExitApp
}

; ==============================================================================
; Button Handlers
; ==============================================================================

LaunchOMFS:
    LaunchForm(A_ScriptDir . "\Forms\HillsboroOMFS.ahk")
return

LaunchOMFS_WisdomTeeth:
    LaunchForm(A_ScriptDir . "\Forms\HillsboroOMFS.ahk", "Wisdom Teeth")
return

LaunchPerio:
    LaunchForm(A_ScriptDir . "\Forms\NorthwestPerio.ahk")
return

LaunchFarham:
    LaunchForm(A_ScriptDir . "\Forms\Farham.ahk")
return

; ==============================================================================
; GUI Close Handler
; ==============================================================================
LauncherGuiClose:
LauncherGuiEscape:
    ExitApp
return
