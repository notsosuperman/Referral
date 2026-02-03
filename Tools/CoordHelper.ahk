; ==============================================================================
; CoordHelper - Capture Open Dental control coordinates for form mapping
; Usage: CoordHelper.ahk FormName.ahk
; Example: CoordHelper.ahk HillsboroOMFS.ahk
; ==============================================================================
#NoEnv
#SingleInstance, Force
SetWorkingDir %A_ScriptDir%

; ==============================================================================
; Configuration
; ==============================================================================
global TargetWindow := "Fill Sheet"
global ConfigPath := A_ScriptDir . "\..\Config\Mappings.ini"
global Controls := []
global CurrentIndex := 0
global SpecialistName := ""
global FormName := ""
global IsCapturing := false
global ClickHotkeyRegistered := false
global WaitingForF1 := false
global WinX, WinY, WinW, WinH  ; Fill Sheet window position

; Set coordinate modes globally
CoordMode, Mouse, Client
CoordMode, ToolTip, Screen

; ==============================================================================
; Auto-Execute Section
; ==============================================================================

; Get target form from command line argument
targetScript := A_Args[1]
if (targetScript = "")
{
    MsgBox, 48, CoordHelper, Usage: CoordHelper.ahk FormName.ahk`n`nExample: CoordHelper.ahk HillsboroOMFS.ahk
    ExitApp
}

; Prepend Forms directory if needed
if !InStr(targetScript, "\")
    targetScript := "..\Forms\" . targetScript

; Extract form name (without .ahk extension)
SplitPath, targetScript, fileName
FormName := RegExReplace(fileName, "\.ahk$", "")

; Parse the form script
if !ParseFormScript(targetScript)
{
    MsgBox, 48, CoordHelper, Failed to parse form script: %targetScript%
    ExitApp
}

controlCount := Controls.Length()

; Try to find and activate Fill Sheet window
if WinExist(TargetWindow)
{
    ; Fill Sheet is open - activate and start capturing immediately
    WinActivate, %TargetWindow%
    WinWaitActive, %TargetWindow%,, 3
    Sleep, 300
    
    ; Get window position for tooltip centering
    UpdateWindowPosition()
    
    ; Start capturing automatically
    GoSub, DoStartCapture
}
else
{
    ; Fill Sheet not found - wait for user to open it and press F1
    WaitingForF1 := true
    ToolTip, Parsed %FormName% - %controlCount% controls`n`nFill Sheet not found!`nOpen it in Open Dental`, then press F1`n`nPress Escape to abort, 100, 100
}
return

; ==============================================================================
; Hotkeys
; ==============================================================================

F1::
    if (!WaitingForF1)
        return
    
    ; Check if Fill Sheet window exists now
    if !WinExist(TargetWindow)
    {
        MsgBox, 48, CoordHelper, Could not find "%TargetWindow%" window.`nPlease open it in Open Dental first.
        return
    }
    
    WaitingForF1 := false
    
    ; Activate the window
    WinActivate, %TargetWindow%
    WinWaitActive, %TargetWindow%,, 3
    Sleep, 300
    
    ; Get window position for tooltip centering
    UpdateWindowPosition()
    
    ; Start capturing
    GoSub, DoStartCapture
return

Escape::
    IsCapturing := false
    ; Only turn off click hotkey if it was registered
    if (ClickHotkeyRegistered)
        Hotkey, ~LButton, Off
    ToolTip
    MsgBox, 48, CoordHelper, Capture aborted. No changes saved.
    ExitApp
return

~LButton::
    if !IsCapturing
        return
    
    ; Make sure Fill Sheet window is active
    WinActivate, %TargetWindow%
    Sleep, 50  ; Give window time to activate
    
    ; Update window position in case user moved it
    UpdateWindowPosition()
    
    ; Get mouse position relative to client area
    MouseGetPos, mouseX, mouseY
    
    ; Store coordinates
    ctrl := Controls[CurrentIndex]
    ctrl.x := mouseX
    ctrl.y := mouseY
    Controls[CurrentIndex] := ctrl
    
    ; Move to next control
    CurrentIndex++
    
    if (CurrentIndex > Controls.Length())
    {
        ; All done!
        IsCapturing := false
        Hotkey, ~LButton, Off
        ToolTip
        
        ; Save to INI
        SaveMappings()
        
        MsgBox, 64, CoordHelper, Coordinate capture complete!`n`nMappings saved to:`n%ConfigPath%
        ExitApp
    }
    else
    {
        ; Show next prompt
        Sleep, 200  ; Small delay to avoid double-clicks
        ShowCurrentPrompt()
    }
return

; ==============================================================================
; Start Capture Subroutine
; ==============================================================================
DoStartCapture:
    IsCapturing := true
    CurrentIndex := 1
    
    ; Enable click handler
    Hotkey, ~LButton, On
    ClickHotkeyRegistered := true
    
    ; Show first control prompt
    ShowCurrentPrompt()
return

; ==============================================================================
; Parse Form Script
; ==============================================================================
ParseFormScript(scriptPath)
{
    global Controls, SpecialistName
    
    FileRead, content, %scriptPath%
    if ErrorLevel
        return false
    
    ; Extract SPECIALIST_NAME (capture only to end of line)
    if RegExMatch(content, ";\s*SPECIALIST_NAME:\s*([^\r\n]+)", match)
        SpecialistName := Trim(match1)
    
    ; Skip these display-only controls
    skipControls := "TxtOfficeName,TxtPatientName"
    
    ; Always add ReferralSource since it's part of the standard header (FT_BuildHeader)
    ; It won't be in the form script, but every form uses it
    referralOptions := "Dr. Gabe Proulx|Dr. Curtis Wahlen|Dr. Ben Wolfe|Dr. Jae Lee"
    Controls.Push({var: "ReferralSource", type: "dropdown", options: referralOptions, x: 0, y: 0})
    
    ; Parse each line for GUI controls
    Loop, Parse, content, `n, `r
    {
        line := A_LoopField
        
        ; Skip if not a Gui Add line
        if !InStr(line, "Gui, Main:Add,")
            continue
        
        ; Extract control type
        controlType := ""
        if InStr(line, "CheckBox")
            controlType := "checkbox"
        else if InStr(line, "DropDownList")
            controlType := "dropdown"
        else if InStr(line, "Edit")
        {
            if InStr(line, "Multi")
                controlType := "multiline"
            else
                controlType := "textfield"
        }
        else
            continue  ; Skip Text, Button, etc.
        
        ; Extract variable name (v followed by name)
        if !RegExMatch(line, "\sv([a-zA-Z0-9_]+)", varMatch)
            continue
        
        varName := varMatch1
        
        ; Skip display-only controls
        if InStr(skipControls, varName)
            continue
        
        ; For dropdowns, extract options
        options := ""
        if (controlType = "dropdown")
        {
            ; Options come after the last comma in the line
            if RegExMatch(line, ",\s*([^,]+)$", optMatch)
            {
                options := Trim(optMatch1)
                ; Remove any trailing comment
                if InStr(options, ";")
                    options := Trim(SubStr(options, 1, InStr(options, ";") - 1))
            }
        }
        
        ; Add to controls array
        ctrl := {var: varName, type: controlType, options: options, x: 0, y: 0}
        Controls.Push(ctrl)
    }
    
    return (Controls.Length() > 0)
}

; ==============================================================================
; Helper Functions
; ==============================================================================

; Get Fill Sheet window position for tooltip centering
UpdateWindowPosition()
{
    global TargetWindow, WinX, WinY, WinW, WinH
    WinGetPos, WinX, WinY, WinW, WinH, %TargetWindow%
}

ShowCurrentPrompt()
{
    global Controls, CurrentIndex, WinX, WinY, WinW
    
    ctrl := Controls[CurrentIndex]
    total := Controls.Length()
    
    ; Build prompt text
    prompt := "[" . CurrentIndex . "/" . total . "] Click on: " . ctrl.var
    prompt .= "`nType: " . ctrl.type
    if (ctrl.options != "")
        prompt .= "`nOptions: " . ctrl.options
    prompt .= "`n`nPress Escape to abort"
    
    ; Position tooltip centered above Fill Sheet window
    ; Estimate tooltip width ~250px, height ~80px
    tooltipX := WinX + (WinW // 2) - 125
    tooltipY := WinY - 90
    
    ; Make sure tooltip doesn't go off-screen top
    if (tooltipY < 10)
        tooltipY := 10
    
    ToolTip, %prompt%, %tooltipX%, %tooltipY%
}

; ==============================================================================
; Save Mappings to INI
; ==============================================================================
SaveMappings()
{
    global ConfigPath, FormName, SpecialistName, Controls
    
    ; Read entire INI file
    FileRead, fileContent, %ConfigPath%
    if ErrorLevel
        fileContent := ""
    
    ; Remove existing section for this form
    sectionStart := InStr(fileContent, "[" . FormName . "]")
    if (sectionStart > 0)
    {
        ; Find next section or end of file
        nextSection := InStr(fileContent, "[", false, sectionStart + 1)
        if (nextSection > 0)
        {
            ; Remove from section start to next section
            fileContent := SubStr(fileContent, 1, sectionStart - 1) . SubStr(fileContent, nextSection)
        }
        else
        {
            ; Remove from section start to end
            fileContent := SubStr(fileContent, 1, sectionStart - 1)
        }
    }
    
    ; Build new section
    newSection := "[" . FormName . "]`n"
    newSection .= "_specialistName=" . SpecialistName . "`n"
    
    ; Add each control mapping
    for index, ctrl in Controls
    {
        mappingValue := ctrl.type . "," . ctrl.x . "," . ctrl.y
        if (ctrl.options != "")
            mappingValue .= "," . ctrl.options
        
        newSection .= ctrl.var . "=" . mappingValue . "`n"
    }
    
    ; Append new section to INI content
    if (fileContent != "" && !RegExMatch(fileContent, "\n$"))
        fileContent .= "`n"
    fileContent .= newSection
    
    ; Write back to file
    FileDelete, %ConfigPath%
    FileAppend, %fileContent%, %ConfigPath%
}

; ==============================================================================
; GUI Close Handler
; ==============================================================================
GuiClose:
GuiEscape:
    ExitApp
return
