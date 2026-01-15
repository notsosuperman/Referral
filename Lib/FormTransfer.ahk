; ==============================================================================
; FormTransfer Library - Transfer form data to Open Dental
; Include this in form scripts: #Include, %A_ScriptDir%\..\Lib\FormTransfer.ahk
; ==============================================================================

; ==============================================================================
; Configuration
; ==============================================================================
global FT_TargetWindow := "Fill Sheet"
global FT_ConfigPath := A_ScriptDir . "\..\Config\Mappings.ini"
global FT_ActionDelay := 50      ; ms between actions
global FT_DropdownDelay := 30    ; ms between dropdown Down presses
global FT_WindowTimeout := 5     ; seconds to wait for window

; ==============================================================================
; State for waiting
; ==============================================================================
global FT_ReadyToFill := false
global FT_Aborted := false

; Skip past label handlers during auto-execute (labels would terminate with return)
goto FT_EndAutoExec

; ==============================================================================
; Hotkey Handlers (placed here so goto can skip them)
; ==============================================================================
FT_StartFill:
    FT_ReadyToFill := true
return

FT_Abort:
    FT_Aborted := true
return

FT_EndAutoExec:
FT_Dummy := 0  ; Required: label cannot point directly to function

; ==============================================================================
; Main Transfer Function
; ==============================================================================
FormTransfer(formName, formData)
{
    ; Load mappings from INI
    mappings := FT_LoadMappings(formName)
    if (mappings.Length() = 0)
    {
        MsgBox, 48, FormTransfer, No mappings found for form: %formName%`n`nRun CoordHelper.ahk first to capture coordinates.
        return false
    }
    
    ; Get specialist name for display
    specialistName := FT_GetSpecialistName(formName)
    
    ; Reset state
    FT_ReadyToFill := false
    FT_Aborted := false
    
    ; Set up hotkeys
    Hotkey, F1, FT_StartFill, On
    Hotkey, Escape, FT_Abort, On
    
    ; Show tooltip with instructions
    CoordMode, ToolTip, Screen
    ToolTip, Navigate to "%FT_TargetWindow%" in Open Dental`nSpecialist: %specialistName%`n`nPress F1 when ready to fill`nPress Escape to cancel, 100, 100
    
    ; Wait for F1 or Escape
    while (!FT_ReadyToFill && !FT_Aborted)
    {
        Sleep, 100
    }
    
    ; Clean up hotkeys
    Hotkey, F1, Off
    Hotkey, Escape, Off
    ToolTip
    
    ; Check if aborted
    if (FT_Aborted)
        return false
    
    ; Check if Fill Sheet window exists
    if !WinExist(FT_TargetWindow)
    {
        MsgBox, 48, FormTransfer, Could not find "%FT_TargetWindow%" window.`nMake sure it's open before pressing F1.
        return false
    }
    
    ; Activate the window
    WinActivate, %FT_TargetWindow%
    WinWaitActive, %FT_TargetWindow%,, %FT_WindowTimeout%
    if ErrorLevel
    {
        MsgBox, 48, FormTransfer, Timeout waiting for "%FT_TargetWindow%" window.
        return false
    }
    
    ; Set coordinate mode to client-relative
    CoordMode, Mouse, Client
    
    ; Show filling tooltip
    CoordMode, ToolTip, Screen
    ToolTip, Filling form..., 100, 100
    
    ; Process each mapping
    for index, mapping in mappings
    {
        ; Skip metadata entries
        if (SubStr(mapping.var, 1, 1) = "_")
            continue
        
        ; Get value from form data
        value := formData[mapping.var]
        
        ; Handle based on control type
        if (mapping.type = "checkbox")
        {
            ; Only click if checkbox should be checked
            if (value = 1)
            {
                xPos := mapping.x
                yPos := mapping.y
                Click, %xPos%, %yPos%
                Sleep, %FT_ActionDelay%
            }
        }
        else if (mapping.type = "textfield" || mapping.type = "multiline")
        {
            ; Only fill if there's content
            if (value != "")
            {
                xPos := mapping.x
                yPos := mapping.y
                Click, %xPos%, %yPos%
                Sleep, %FT_ActionDelay%
                Send, ^a
                Sleep, %FT_ActionDelay%
                SendInput, %value%
                Sleep, %FT_ActionDelay%
            }
        }
        else if (mapping.type = "dropdown")
        {
            ; Only select if there's a value
            if (value != "")
            {
                ; Find index of selected value in options
                idx := FT_FindIndex(value, mapping.options)
                if (idx > 0)
                {
                    xPos := mapping.x
                    yPos := mapping.y
                    Click, %xPos%, %yPos%
                    Sleep, %FT_ActionDelay%
                    
                    ; Press Down the appropriate number of times
                    Loop, %idx%
                    {
                        Send, {Down}
                        Sleep, %FT_DropdownDelay%
                    }
                    Send, {Enter}
                    Sleep, %FT_ActionDelay%
                }
            }
        }
    }
    
    ; Clear tooltip
    ToolTip
    
    return true
}

; ==============================================================================
; Load Mappings from INI
; ==============================================================================
FT_LoadMappings(formName)
{
    mappings := []
    
    ; Read all keys from the form's section
    IniRead, sectionContent, %FT_ConfigPath%, %formName%
    if (sectionContent = "ERROR" || sectionContent = "")
        return mappings
    
    ; Parse each line
    Loop, Parse, sectionContent, `n, `r
    {
        line := A_LoopField
        if (line = "")
            continue
        
        ; Split key=value
        equalPos := InStr(line, "=")
        if !equalPos
            continue
        
        varName := SubStr(line, 1, equalPos - 1)
        valueStr := SubStr(line, equalPos + 1)
        
        ; Skip metadata for now (but still include _specialistName)
        if (SubStr(varName, 1, 1) = "_")
        {
            mapping := {var: varName, type: "metadata", value: valueStr}
            mappings.Push(mapping)
            continue
        }
        
        ; Parse value: type,x,y[,options]
        parts := StrSplit(valueStr, ",", " ", 4)
        
        mapping := {}
        mapping.var := varName
        mapping.type := parts[1]
        mapping.x := parts[2]
        mapping.y := parts[3]
        mapping.options := (parts.Length() >= 4) ? parts[4] : ""
        
        mappings.Push(mapping)
    }
    
    return mappings
}

; ==============================================================================
; Get Specialist Name for a Form
; ==============================================================================
FT_GetSpecialistName(formName)
{
    IniRead, specialistName, %FT_ConfigPath%, %formName%, _specialistName
    if (specialistName = "ERROR")
        return ""
    return specialistName
}

; ==============================================================================
; Find Index of Value in Pipe-Delimited Options (1-based)
; ==============================================================================
FT_FindIndex(value, options)
{
    idx := 0
    Loop, Parse, options, |
    {
        idx++
        if (A_LoopField = value)
            return idx
    }
    return 0
}
