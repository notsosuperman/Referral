; ==============================================================================
; FormTransfer Library - Transfer form data to Open Dental + Preset System
; Include this in form scripts: #Include %A_ScriptDir%\..\Lib\FormTransfer.ahk
; ==============================================================================

; ==============================================================================
; Include OD Automation Library (includes Logging)
; Use A_LineFile to get path relative to THIS file, not the main script
; ==============================================================================
#Include %A_LineFile%\..\ODAutomation.ahk

; ==============================================================================
; Configuration
; ==============================================================================
global FT_TargetWindow := "Fill Sheet"
global FT_ConfigPath := A_ScriptDir . "\..\Config\Mappings.ini"
global FT_PresetPath := A_ScriptDir . "\..\Config\Presets.ini"
global FT_ActionDelay := 50      ; ms between actions
global FT_DropdownDelay := 30    ; ms between dropdown Down presses
global FT_WindowTimeout := 5     ; seconds to wait for window

; Preset system globals
global PS_FormName := ""

; Patient context globals (set by InitPresets from args)
global FT_PatientName := ""
global FT_ODWindowTitle := ""
global FT_HasPatientContext := false

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

; Global Esc handler - exits script without sending Esc through
; $ prefix prevents it from triggering itself
$Esc::
    Failure("User pressed Esc - aborting automation", true, false, true)
return

PS_SavePresetHotkey:
    PS_PromptAndSavePreset()
return

FT_EndAutoExec:
FT_Dummy := 0  ; Required: label cannot point directly to function

; ==============================================================================
; Main Transfer Function with Auto-Navigation
; ==============================================================================
FormTransfer(formName, formData)
{
    global FT_HasPatientContext
    global FT_ODWindowTitle
    
    Checkpoint("=== FormTransfer Started for: " . formName . " ===", false)
    
    ; Load mappings from INI
    mappings := FT_LoadMappings(formName)
    if (mappings.Length() = 0)
    {
        Failure("No mappings found for form: " . formName . ". Run CoordHelper.ahk first.", false, true, false)
        return false
    }
    
    ; Get specialist name
    specialistName := FT_GetSpecialistName(formName)
    Checkpoint("Specialist name: " . specialistName, false)
    
    ; If we have patient context, do automatic navigation
    if (FT_HasPatientContext)
    {
        Checkpoint("Patient context available - using automatic navigation", false)
        
        BlockInputOn()
        
        ; Validate and activate OD window
        if !FT_ValidateAndActivateOD()
        {
            BlockInputOff()
            return false
        }
        
        ; Ensure we're on Chart view
        if !ODEnsureChartView()
        {
            Failure("Could not switch to Chart view", true, true, false)
            BlockInputOff()
            return false
        }
        
        ; Navigate to Fill Sheet
        if !NavigateToFillSheet(specialistName)
        {
            BlockInputOff()
            return false
        }
        
        ; Now fill the form
        result := FT_FillForm(mappings, formData)
        
        BlockInputOff()
        
        if (result)
            Success("Form transfer completed successfully", true)
        
        return result
    }
    else
    {
        ; Manual mode - wait for user to navigate to Fill Sheet
        Checkpoint("No patient context - using manual F1 mode", false)
        return FT_ManualTransfer(formName, mappings, formData, specialistName)
    }
}

; ==============================================================================
; Validate OD Window and Activate
; ==============================================================================
FT_ValidateAndActivateOD()
{
    global FT_ODWindowTitle
    
    Checkpoint("Validating OD window: " . FT_ODWindowTitle, false)
    
    ; Try to activate the expected OD window
    if !ODActivateMain(FT_ODWindowTitle)
    {
        ; Check if there's a blocking window
        if ODHasBlockingWindow()
        {
            Failure("A sub-window is blocking Open Dental.`nPlease close it and try again.", true, true, false)
            return false
        }
        
        Failure("Could not activate Open Dental main window.`nExpected: " . FT_ODWindowTitle, true, true, false)
        return false
    }
    
    ; Verify the title still matches (patient hasn't changed)
    WinGetTitle, currentTitle, A
    if (currentTitle != FT_ODWindowTitle)
    {
        Failure("Patient has changed!`n`nExpected: " . FT_ODWindowTitle . "`nCurrent: " . currentTitle, false, true, false)
        return false
    }
    
    Checkpoint("OD window validated and active", true)
    return true
}

; ==============================================================================
; Manual Transfer Mode (F1 to start)
; ==============================================================================
FT_ManualTransfer(formName, mappings, formData, specialistName)
{
    global FT_TargetWindow
    global FT_WindowTimeout
    global FT_ReadyToFill
    global FT_Aborted
    
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
    {
        Checkpoint("User aborted transfer", false)
        return false
    }
    
    ; Check if Fill Sheet window exists
    if !WinExist(FT_TargetWindow)
    {
        Failure("Could not find '" . FT_TargetWindow . "' window. Make sure it's open before pressing F1.", true, true, false)
        return false
    }
    
    ; Activate the window
    WinActivate, %FT_TargetWindow%
    WinWaitActive, %FT_TargetWindow%,, %FT_WindowTimeout%
    if ErrorLevel
    {
        Failure("Timeout waiting for '" . FT_TargetWindow . "' window.", true, true, false)
        return false
    }
    
    ; Fill the form
    result := FT_FillForm(mappings, formData)
    
    if (result)
        Success("Form transfer completed successfully (manual mode)", true)
    
    return result
}

; ==============================================================================
; Fill Form Fields
; ==============================================================================
FT_FillForm(mappings, formData)
{
    global FT_ActionDelay
    global FT_DropdownDelay
    
    ; Set coordinate mode to client-relative
    CoordMode, Mouse, Client
    
    ; Show filling tooltip
    CoordMode, ToolTip, Screen
    ToolTip, Filling form..., 100, 100
    
    Checkpoint("Starting to fill form fields", false)
    
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
                Checkpoint("Checked: " . mapping.var, false)
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
                ; Use clipboard paste for instant text entry (handles special chars)
                PasteText(value)
                Sleep, %FT_ActionDelay%
                Checkpoint("Filled: " . mapping.var . " = " . SubStr(value, 1, 30), false)
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
                    Checkpoint("Selected: " . mapping.var . " = " . value, false)
                }
            }
        }
    }
    
    ; Clear tooltip
    ToolTip
    
    Checkpoint("Finished filling form fields", false)
    return true
}

; ==============================================================================
; Load Mappings from INI
; ==============================================================================
FT_LoadMappings(formName)
{
    global FT_ConfigPath
    
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
    global FT_ConfigPath
    
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

; ==============================================================================
; ABSTRACTED GetFormData() - Reads field names from Mappings.ini
; ==============================================================================
GetFormData()
{
    global FT_ConfigPath
    global PS_FormName
    
    ; Ensure form name is set
    if (PS_FormName = "")
        PS_FormName := PS_GetFormName()
    
    ; Submit GUI to update variables
    Gui, Main:Submit, NoHide
    
    ; Check if mappings exist
    IniRead, sectionTest, %FT_ConfigPath%, %PS_FormName%
    if (sectionTest = "ERROR" || sectionTest = "")
    {
        MsgBox, 16, Error, Mappings.ini does not contain data for form: %PS_FormName%`n`nPlease run CoordHelper first to generate mappings.
        return {}
    }
    
    ; Build data object from mappings
    data := {}
    mappings := FT_LoadMappings(PS_FormName)
    
    for index, mapping in mappings
    {
        ; Skip metadata fields
        if (mapping.type = "metadata")
            continue
        
        varName := mapping.var
        
        ; Dynamically access the variable value
        ; Use %% for dynamic variable access
        value := %varName%
        data[varName] := value
    }
    
    return data
}

; ==============================================================================
; ABSTRACTED ClearForm() - Clears all form fields using Mappings.ini
; ==============================================================================
ClearForm()
{
    global FT_ConfigPath
    global PS_FormName
    
    ; Ensure form name is set
    if (PS_FormName = "")
        PS_FormName := PS_GetFormName()
    
    ; Load mappings
    mappings := FT_LoadMappings(PS_FormName)
    
    for index, mapping in mappings
    {
        ; Skip metadata fields
        if (mapping.type = "metadata")
            continue
        
        varName := mapping.var
        fieldType := mapping.type
        
        ; Clear based on type
        if (fieldType = "dropdown")
        {
            ; Reset dropdown to no selection
            GuiControl, Main:Choose, %varName%, 0
        }
        else if (fieldType = "checkbox")
        {
            ; Uncheck checkbox
            GuiControl, Main:, %varName%, 0
        }
        else if (fieldType = "textfield" || fieldType = "multiline")
        {
            ; Clear text
            GuiControl, Main:, %varName%,
        }
    }
}

; ==============================================================================
; FORM HEADER AND UTILITY FUNCTIONS
; ==============================================================================

; ==============================================================================
; FT_BuildHeader - Build standard form header (Office Name, Patient Name, Referring Doctor)
; Parameters:
;   yPos (ByRef) - Starting Y position, modified to position after header
;   formWidth - Width of form content area (for separator line)
; ==============================================================================
FT_BuildHeader(ByRef yPos, formWidth)
{
    global OfficeName
    global PatientName
    global ReferralSource
    
    ; Line 1: Office Name (display only)
    Gui, Main:Font, s14 Bold, Arial
    Gui, Main:Add, Text, x20 y%yPos% w%formWidth% cNavy vTxtOfficeName, %OfficeName%
    
    ; Line 2: Patient Name (display only)
    yPos += 28
    Gui, Main:Font, s12 Normal, Arial
    Gui, Main:Add, Text, x20 y%yPos% w%formWidth% vTxtPatientName, Patient: %PatientName%
    
    ; Line 3: Referring Dentist Dropdown
    yPos += 28
    Gui, Main:Font, s10 Normal, Arial
    Gui, Main:Add, Text, x20 y%yPos% w100 h22 +0x200, Referring Dentist:
    ; Hardcoded referring doctor options - update here when doctors change
    Gui, Main:Add, DropDownList, x125 y%yPos% w180 vReferralSource, Dr. Gabe Proulx|Dr. Curtis Wahlen|Dr. Ben Wolfe|Dr. Jae Lee
    
    ; Separator line
    yPos += 30
    Gui, Main:Add, Text, x20 y%yPos% w%formWidth% h2 +0x10
    
    ; Return with yPos ready for next section
    yPos += 10
}

; ==============================================================================
; SetPatientName - Set the patient name display (call this before showing the form)
; ==============================================================================
SetPatientName(name)
{
    global PatientName
    PatientName := name
    GuiControl, Main:, TxtPatientName, Patient: %name%
}

; ==============================================================================
; SetOfficeName - Set the office name display (call this before showing the form)
; ==============================================================================
SetOfficeName(name)
{
    global OfficeName
    OfficeName := name
    GuiControl, Main:, TxtOfficeName, %name%
}

; ==============================================================================
; PS_GetSpecialistName - Parse SPECIALIST_NAME from main script's header comments
; ==============================================================================
PS_GetSpecialistName()
{
    ; Determine which file to read
    if (A_IsCompiled)
    {
        ; When compiled, read from corresponding .ahk file in same directory
        SplitPath, A_ScriptFullPath, , scriptDir, , scriptNameNoExt
        scriptPath := scriptDir . "\" . scriptNameNoExt . ".ahk"
        
        ; Fallback: try parent directory if .ahk not in same dir
        if (!FileExist(scriptPath))
            scriptPath := scriptDir . "\..\Forms\" . scriptNameNoExt . ".ahk"
    }
    else
    {
        ; Dev mode - read from the script itself
        scriptPath := A_ScriptFullPath
    }
    
    ; Read the script file
    FileRead, scriptContent, %scriptPath%
    if (ErrorLevel)
    {
        DebugLog("PS_GetSpecialistName: Failed to read " . scriptPath)
        return ""
    }
    
    ; Look for ; SPECIALIST_NAME: xxx in the first 20 lines
    lineCount := 0
    Loop, Parse, scriptContent, `n, `r
    {
        lineCount++
        if (lineCount > 20)
            break
        
        if (RegExMatch(A_LoopField, ";\s*SPECIALIST_NAME:\s*(.+)", match))
            return Trim(match1)
    }
    
    return ""
}

; ==============================================================================
; PRESET SYSTEM FUNCTIONS
; ==============================================================================

; ==============================================================================
; InitPresets - Call after GUI is built
; Handles new argument structure:
;   With patient context: Args = "patientName" "odWindowTitle" "presetName"
;   Standalone mode: Args = "presetName" (or empty for Default)
; ==============================================================================
InitPresets()
{
    global PS_FormName
    global FT_PatientName
    global FT_ODWindowTitle
    global FT_HasPatientContext
    
    ; Get form name from script header
    PS_FormName := PS_GetFormName()
    if (PS_FormName = "")
    {
        ; No FORM_NAME found, skip preset loading
        DebugLog("InitPresets: No FORM_NAME found in script header")
        return
    }
    
    DebugLog("InitPresets: FORM_NAME = " . PS_FormName)
    DebugLog("InitPresets: A_Args count = " . A_Args.Length())
    
    ; Determine argument structure
    ; If A_Args[2] contains "Open Dental", we have patient context
    if (A_Args.Length() >= 2 && InStr(A_Args[2], "Open Dental"))
    {
        ; Full mode with patient context
        FT_PatientName := A_Args[1]
        FT_ODWindowTitle := A_Args[2]
        FT_HasPatientContext := true
        
        presetName := (A_Args.Length() >= 3 && A_Args[3] != "") ? A_Args[3] : "Default"
        
        DebugLog("InitPresets: Full mode - Patient: " . FT_PatientName)
        DebugLog("InitPresets: OD Title: " . FT_ODWindowTitle)
        DebugLog("InitPresets: Preset: " . presetName)
        
        ; Update form's patient display
        SetPatientName(FT_PatientName)
    }
    else
    {
        ; Standalone mode - A_Args[1] is preset name (or empty)
        FT_HasPatientContext := false
        presetName := (A_Args.Length() >= 1 && A_Args[1] != "") ? A_Args[1] : "Default"
        
        DebugLog("InitPresets: Standalone mode - Preset: " . presetName)
    }
    
    ; Load and apply preset (silently fails if preset doesn't exist)
    presetData := PS_LoadPreset(PS_FormName, presetName)
    if (presetData.Count() > 0)
    {
        PS_ApplyPreset(presetData)
        DebugLog("InitPresets: Applied preset with " . presetData.Count() . " values")
    }
    else
    {
        DebugLog("InitPresets: No preset data found for " . PS_FormName . "_" . presetName)
    }
    
    ; Register save preset hotkey (Ctrl+Shift+S)
    Hotkey, ^+s, PS_SavePresetHotkey, On
}

; ==============================================================================
; PS_GetFormName - Parse FORM_NAME from main script's header comments
; ==============================================================================
PS_GetFormName()
{
    ; Determine which file to read
    if (A_IsCompiled)
    {
        ; When compiled, read from corresponding .ahk file in same directory
        ; Build script copies .ahk files alongside .exe files for this purpose
        SplitPath, A_ScriptFullPath, , scriptDir, , scriptNameNoExt
        scriptPath := scriptDir . "\" . scriptNameNoExt . ".ahk"
        
        ; Fallback: try parent directory if .ahk not in same dir
        if (!FileExist(scriptPath))
            scriptPath := scriptDir . "\..\Forms\" . scriptNameNoExt . ".ahk"
    }
    else
    {
        ; Dev mode - read from the script itself
        scriptPath := A_ScriptFullPath
    }
    
    ; Read the script file
    FileRead, scriptContent, %scriptPath%
    if (ErrorLevel)
    {
        DebugLog("PS_GetFormName: Failed to read " . scriptPath)
        return ""
    }
    
    ; Look for ; FORM_NAME: xxx in the first 20 lines
    lineCount := 0
    Loop, Parse, scriptContent, `n, `r
    {
        lineCount++
        if (lineCount > 20)
            break
        
        if (RegExMatch(A_LoopField, ";\s*FORM_NAME:\s*(.+)", match))
            return Trim(match1)
    }
    
    return ""
}

; ==============================================================================
; PS_LoadPreset - Load preset from Presets.ini
; Returns object with key=value pairs
; ==============================================================================
PS_LoadPreset(formName, presetName)
{
    global FT_PresetPath
    
    data := {}
    sectionName := formName . "_" . presetName
    
    ; Read section content
    IniRead, sectionContent, %FT_PresetPath%, %sectionName%
    if (sectionContent = "ERROR" || sectionContent = "")
        return data
    
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
        
        key := SubStr(line, 1, equalPos - 1)
        value := SubStr(line, equalPos + 1)
        
        ; Decode {NEWLINE} markers back to actual newlines
        value := StrReplace(value, "{NEWLINE}", "`n")
        
        data[key] := value
    }
    
    return data
}

; ==============================================================================
; PS_ApplyPreset - Apply preset data to GUI controls
; ==============================================================================
PS_ApplyPreset(data)
{
    for key, value in data
    {
        ; Skip empty keys
        if (key = "")
            continue
        
        ; Determine control type by prefix
        if (SubStr(key, 1, 3) = "chk")
        {
            ; Checkbox - set checked state
            GuiControl, Main:, %key%, %value%
        }
        else if (SubStr(key, 1, 3) = "txt")
        {
            ; Text/Edit field
            GuiControl, Main:, %key%, %value%
        }
        else
        {
            ; Assume dropdown or other - try ChooseString first, then direct set
            GuiControl, Main:ChooseString, %key%, %value%
            if (ErrorLevel)
                GuiControl, Main:, %key%, %value%
        }
    }
}

; ==============================================================================
; PS_SavePreset - Save current form data to Presets.ini
; ==============================================================================
PS_SavePreset(formName, presetName)
{
    global FT_PresetPath
    
    sectionName := formName . "_" . presetName
    
    ; If saving "Default", delete existing Default section first (override)
    if (presetName = "Default")
    {
        IniDelete, %FT_PresetPath%, %sectionName%
    }
    
    ; Get form data (requires form to have GetFormData function)
    formData := GetFormData()
    
    ; Write each key=value to the INI section
    ; Encode newlines as {NEWLINE} since IniWrite doesn't support multiline values
    for key, value in formData
    {
        ; Encode newlines: replace actual newlines with {NEWLINE} marker
        encodedValue := StrReplace(value, "`r`n", "{NEWLINE}")
        encodedValue := StrReplace(encodedValue, "`n", "{NEWLINE}")
        encodedValue := StrReplace(encodedValue, "`r", "{NEWLINE}")
        
        ; Write the encoded value (single line)
        IniWrite, %encodedValue%, %FT_PresetPath%, %sectionName%, %key%
    }
}

; ==============================================================================
; PS_PromptAndSavePreset - Show input box and save preset
; ==============================================================================
PS_PromptAndSavePreset()
{
    global PS_FormName
    
    if (PS_FormName = "")
    {
        MsgBox, 48, Save Preset, FORM_NAME not found in script header.`nAdd "; FORM_NAME: YourFormName" to the script.
        return
    }
    
    ; Prompt for preset name
    InputBox, presetName, Save Preset, Enter preset name:,, 300, 130
    if (ErrorLevel || presetName = "")
        return
    
    ; Save the preset
    PS_SavePreset(PS_FormName, presetName)
    
    MsgBox, 64, Save Preset, Preset "%presetName%" saved successfully!`n`nSection: [%PS_FormName%_%presetName%]
}
