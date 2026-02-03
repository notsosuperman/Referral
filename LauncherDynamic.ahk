; ==============================================================================
; Dental Referral Launcher (Dynamic Version)
; Automatically discovers forms and presets from filesystem
; Zero maintenance required when adding new forms/presets
; ==============================================================================
#NoEnv
#SingleInstance, Force
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2

; ==============================================================================
; Global Variables
; ==============================================================================
global LauncherPatientName := ""
global LauncherODTitle := ""
global LauncherReady := false
global ButtonMap := {}  ; Maps button text → {path, preset}
global PresetPath := A_ScriptDir . "\Config\Presets.ini"
global MappingPath := A_ScriptDir . "\Config\Mappings.ini"

; Developer Mode
global DevModeActive := false
global DevForms := []           ; Stores form data for dev mode
global MappingStatuses := {}    ; Stores mapping status per form
global DevBtnActions := {}      ; Maps button text → {action, formName, presetName}

; ==============================================================================
; Startup: Capture OD Window Context
; ==============================================================================
CaptureODContext()
return

; ==============================================================================
; Hotkeys
; ==============================================================================
F1::
    if (!LauncherReady)
    {
        ; User pressed F1 to indicate OD is ready
        CaptureODContextNow()
    }
return

$Esc::
    ExitApp
return

; Developer Mode Toggle
^+d::
    DevModeActive := !DevModeActive
    if (LauncherReady)
        ShowLauncherGUI(DevModeActive)
return

; ==============================================================================
; Patient Context Capture
; ==============================================================================
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
    ShowLauncherGUI(DevModeActive)
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
    ShowLauncherGUI(DevModeActive)
}

; ==============================================================================
; DYNAMIC DISCOVERY FUNCTIONS
; ==============================================================================

; Discover all forms in Forms\ directory
DiscoverForms()
{
    forms := []
    
    ; Check if running as compiled (look for .exe) or dev mode (look for .ahk)
    if (A_IsCompiled)
    {
        ; Compiled mode - scan .exe files, read metadata from .ahk
        Loop, Files, %A_ScriptDir%\Forms\*.exe
        {
            ; Extract base name (e.g., "Farham" from "Farham.exe")
            SplitPath, A_LoopFileName, , , , baseName
            
            ; Look for corresponding .ahk file in same directory (copied by build script)
            ahkFile := A_ScriptDir . "\Forms\" . baseName . ".ahk"
            if (FileExist(ahkFile))
            {
                formData := ParseFormHeader(ahkFile)
            }
            else
            {
                ; Fallback: use filename as both name and display
                formData := {name: baseName, display: baseName}
            }
            
            if (formData.name != "")
            {
                ; Use .exe path for launching
                formData.path := A_LoopFileFullPath
                forms.Push(formData)
            }
        }
    }
    else
    {
        ; Dev mode - scan .ahk files
        Loop, Files, %A_ScriptDir%\Forms\*.ahk
        {
            formData := ParseFormHeader(A_LoopFileFullPath)
            if (formData.name != "")
            {
                formData.path := A_LoopFileFullPath
                forms.Push(formData)
            }
        }
    }
    
    return forms
}

; Parse form header metadata
ParseFormHeader(filePath)
{
    formData := {name: "", display: ""}
    
    ; Read first 30 lines
    FileRead, content, %filePath%
    if (ErrorLevel)
        return formData
    
    lines := StrSplit(content, "`n", "`r", 30)
    
    for index, line in lines
    {
        if (index > 30)
            break
        
        ; Extract FORM_NAME
        if (RegExMatch(line, "i)^\s*;\s*FORM_NAME:\s*(.+)", match))
        {
            formData.name := Trim(match1)
        }
        
        ; Extract SPECIALIST_NAME (used for button text)
        if (RegExMatch(line, "i)^\s*;\s*SPECIALIST_NAME:\s*(.+)", match))
        {
            formData.display := Trim(match1)
        }
    }
    
    ; SPECIALIST_NAME is required
    if (formData.display = "")
    {
        ; Error: SPECIALIST_NAME is required
        formData.name := ""
        return formData
    }
    
    return formData
}

; Discover presets from Presets.ini
DiscoverPresets()
{
    global PresetPath
    
    presetMap := {}
    
    ; Read all section names
    IniRead, sections, %PresetPath%
    if (sections = "ERROR" || sections = "")
        return presetMap
    
    ; Parse each section
    Loop, Parse, sections, `n, `r
    {
        sectionName := A_LoopField
        if (sectionName = "")
            continue
        
        ; Parse format: "FormName_PresetName"
        if (InStr(sectionName, "_"))
        {
            underscorePos := InStr(sectionName, "_")
            formName := SubStr(sectionName, 1, underscorePos - 1)
            presetName := SubStr(sectionName, underscorePos + 1)
            
            ; Filter out "_Default"
            if (presetName = "Default")
                continue
            
            ; Add to map
            if (!presetMap.HasKey(formName))
                presetMap[formName] := []
            
            presetMap[formName].Push(presetName)
        }
    }
    
    return presetMap
}

; Merge forms with presets and sort
MergeAndSortForms(forms, presetMap)
{
    ; Attach presets to each form
    for index, form in forms
    {
        if (presetMap.HasKey(form.name))
        {
            ; Sort presets alphabetically
            form.presets := SortArray(presetMap[form.name])
        }
        else
        {
            form.presets := []
        }
    }
    
    ; Sort forms alphabetically by display name
    forms := SortFormsByDisplay(forms)
    
    return forms
}

; Sort array alphabetically (case-insensitive)
SortArray(arr)
{
    ; Bubble sort (simple for small arrays)
    n := arr.Length()
    Loop, %n%
    {
        swapped := false
        maxIdx := n - A_Index + 1
        Loop, %maxIdx%
        {
            if (A_Index >= maxIdx)
                break
            
            current := arr[A_Index]
            next := arr[A_Index + 1]
            
            ; Case-insensitive compare
            if (current > next)
            {
                ; Swap
                arr[A_Index] := next
                arr[A_Index + 1] := current
                swapped := true
            }
        }
        
        if (!swapped)
            break
    }
    
    return arr
}

; Sort forms by display name
SortFormsByDisplay(forms)
{
    ; Bubble sort
    n := forms.Length()
    Loop, %n%
    {
        swapped := false
        maxIdx := n - A_Index + 1
        Loop, %maxIdx%
        {
            if (A_Index >= maxIdx)
                break
            
            current := forms[A_Index]
            next := forms[A_Index + 1]
            
            ; Case-insensitive compare by display name
            if (current.display > next.display)
            {
                ; Swap
                forms[A_Index] := next
                forms[A_Index + 1] := current
                swapped := true
            }
        }
        
        if (!swapped)
            break
    }
    
    return forms
}

; ==============================================================================
; DEVELOPER MODE FUNCTIONS
; ==============================================================================

; Check if a form has mappings in Mappings.ini
CheckMappingStatus(formName)
{
    global MappingPath
    
    result := {exists: false, fieldCount: 0}
    
    ; Try to read the section
    IniRead, sectionContent, %MappingPath%, %formName%
    if (sectionContent = "ERROR" || sectionContent = "")
        return result
    
    ; Count fields (excluding _specialistName metadata)
    fieldCount := 0
    Loop, Parse, sectionContent, `n, `r
    {
        line := A_LoopField
        if (line = "")
            continue
        
        ; Skip metadata fields starting with _
        if (SubStr(line, 1, 1) = "_")
            continue
        
        fieldCount++
    }
    
    result.exists := true
    result.fieldCount := fieldCount
    return result
}

; Discover ALL presets for a form (including Default)
DiscoverAllPresets(formName)
{
    global PresetPath
    
    presets := []
    
    ; Read all section names
    IniRead, sections, %PresetPath%
    if (sections = "ERROR" || sections = "")
        return presets
    
    ; Parse each section looking for this form's presets
    prefix := formName . "_"
    Loop, Parse, sections, `n, `r
    {
        sectionName := A_LoopField
        if (sectionName = "")
            continue
        
        ; Check if this section belongs to our form
        if (InStr(sectionName, prefix) = 1)
        {
            presetName := SubStr(sectionName, StrLen(prefix) + 1)
            if (presetName != "")
                presets.Push(presetName)
        }
    }
    
    return SortArray(presets)
}

; Get specialist name from form's SPECIALIST_NAME header
GetSpecialistNameForForm(formName)
{
    global DevForms
    
    for index, form in DevForms
    {
        if (form.name = formName)
            return form.display
    }
    return formName
}

; Launch CoordHelper for a specific form
LaunchCoordHelperForForm(formName)
{
    specialistName := GetSpecialistNameForForm(formName)
    
    ; Show instruction dialog
    MsgBox, 64, Map Form, Open "Fill Sheet" in Open Dental for:`n`n%specialistName%`n`nClick OK when ready to start mapping.
    
    ; Activate Fill Sheet window
    WinActivate, Fill Sheet
    Sleep, 300
    
    ; Launch CoordHelper and wait for it to complete
    coordHelperPath := A_ScriptDir . "\Tools\CoordHelper.ahk"
    formScript := formName . ".ahk"
    
    if (A_IsCompiled)
    {
        ; In compiled mode, we need AutoHotkey to run the .ahk file
        ; Check if AutoHotkey is available
        RunWait, AutoHotkeyU64.exe "%coordHelperPath%" %formScript%, %A_ScriptDir%
    }
    else
    {
        ; In dev mode, run directly
        RunWait, "%A_AhkPath%" "%coordHelperPath%" %formScript%, %A_ScriptDir%
    }
    
    ; Refresh the dev mode GUI
    ShowLauncherGUI(true)
}

; Delete mapping for a form
DeleteFormMapping(formName)
{
    global MappingPath
    
    MsgBox, 52, Delete Mapping, Delete all mappings for "%formName%"?`n`nThis cannot be undone.
    IfMsgBox, No
        return
    
    ; Delete the section from Mappings.ini
    IniDelete, %MappingPath%, %formName%
    
    ; Refresh the GUI
    ShowLauncherGUI(true)
}

; Delete a preset
DeleteFormPreset(formName, presetName)
{
    global PresetPath
    
    MsgBox, 52, Delete Preset, Delete preset "%presetName%" for "%formName%"?
    IfMsgBox, No
        return
    
    ; Delete the section from Presets.ini
    sectionName := formName . "_" . presetName
    IniDelete, %PresetPath%, %sectionName%
    
    ; Refresh the GUI
    ShowLauncherGUI(true)
}

; Open config files in editor
ViewConfig()
{
    global MappingPath
    global PresetPath
    
    ; Open both config files in default editor
    Run, notepad.exe "%MappingPath%"
    Sleep, 200
    Run, notepad.exe "%PresetPath%"
}

; Map all unmapped forms
MapAllUnmapped()
{
    global DevForms
    global MappingStatuses
    
    ; Find all unmapped forms
    unmapped := []
    for index, form in DevForms
    {
        if (!MappingStatuses[form.name].exists)
            unmapped.Push(form)
    }
    
    if (unmapped.Length() = 0)
    {
        MsgBox, 64, Map All, All forms are already mapped!
        return
    }
    
    totalCount := unmapped.Length()
    currentNum := 0
    
    for index, form in unmapped
    {
        currentNum++
        formDisplay := form.display
        formName := form.name
        
        ; Show dialog with options
        MsgBox, 35, Map All Unmapped (%currentNum%/%totalCount%), Ready to map: %formDisplay%`n`nOpen "Fill Sheet" in Open Dental for this specialist.`n`nYes = Start mapping`nNo = Skip this form`nCancel = Stop mapping
        
        IfMsgBox, Cancel
        {
            mappedCount := currentNum - 1
            MsgBox, 64, Map All, Mapping cancelled.`n`nMapped: %mappedCount% forms`nSkipped: remaining forms
            break
        }
        IfMsgBox, No
            continue
        
        ; User clicked Yes - activate Fill Sheet and launch CoordHelper
        WinActivate, Fill Sheet
        Sleep, 300
        
        coordHelperPath := A_ScriptDir . "\Tools\CoordHelper.ahk"
        formScript := formName . ".ahk"
        
        if (A_IsCompiled)
            RunWait, AutoHotkeyU64.exe "%coordHelperPath%" %formScript%, %A_ScriptDir%
        else
            RunWait, "%A_AhkPath%" "%coordHelperPath%" %formScript%, %A_ScriptDir%
    }
    
    ; Refresh the GUI to show updated statuses
    ShowLauncherGUI(true)
}

; ==============================================================================
; Dynamic GUI Building
; ==============================================================================
ShowLauncherGUI(devMode := false)
{
    global LauncherPatientName
    global ButtonMap
    global DevModeActive
    global DevForms
    global MappingStatuses
    global DevBtnActions
    
    ; Destroy existing GUI
    Gui, Launcher:Destroy
    
    ; Discover forms and presets
    forms := DiscoverForms()
    presetMap := DiscoverPresets()
    forms := MergeAndSortForms(forms, presetMap)
    
    ; Store for dev mode use
    DevForms := forms
    
    if (devMode)
    {
        ; Check mapping status for all forms
        MappingStatuses := {}
        for index, form in forms
            MappingStatuses[form.name] := CheckMappingStatus(form.name)
        
        ; Build dev mode GUI
        BuildDevModeGUI(forms)
    }
    else
    {
        ; Build normal GUI
        BuildNormalGUI(forms)
    }
}

; Build normal user GUI
BuildNormalGUI(forms)
{
    global LauncherPatientName
    global ButtonMap
    
    ButtonMap := {}
    
    ; Build GUI
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
    
    ; Dynamically create buttons for each form
    for index, form in forms
    {
        ; Main form button
        Gui, Launcher:Font, s11 Normal, Arial
        buttonText := form.display
        Gui, Launcher:Add, Button, x20 y%yPos% w260 h40 gHandleButtonClick, %buttonText%
        
        ; Store in ButtonMap
        ButtonMap[buttonText] := {path: form.path, preset: ""}
        yPos += 45
        
        ; Preset buttons (if any)
        if (form.presets.Length() > 0)
        {
            Gui, Launcher:Font, s9 Normal, Arial
            for pIndex, presetName in form.presets
            {
                buttonText := "  > " . presetName
                Gui, Launcher:Add, Button, x40 y%yPos% w240 h28 gHandleButtonClick, %buttonText%
                
                ; Store in ButtonMap
                ButtonMap[buttonText] := {path: form.path, preset: presetName}
                yPos += 33
            }
            
            yPos += 5  ; Extra spacing after presets
        }
    }
    
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

; Build developer mode GUI
BuildDevModeGUI(forms)
{
    global MappingStatuses
    global DevBtnActions
    
    ; Reset button tracking
    DevBtnActions := {}
    
    ; Build GUI - wider for dev mode
    Gui, Launcher:New, , Dental Referral System - Developer Mode
    Gui, Launcher:Color, F0F0F0
    
    ; Header
    Gui, Launcher:Font, s12 Bold, Arial
    Gui, Launcher:Add, Text, x20 y15 w400 h25 cMaroon, Developer Mode (Ctrl+Shift+D to exit)
    
    ; Global action buttons
    Gui, Launcher:Font, s9 Normal, Arial
    Gui, Launcher:Add, Button, x20 y45 w120 h25 gDevViewConfig, View Config
    Gui, Launcher:Add, Button, x150 y45 w150 h25 gDevMapAllUnmapped, Map All Unmapped
    
    ; Separator
    yPos := 80
    Gui, Launcher:Add, Text, x20 y%yPos% w520 h2 +0x10
    yPos += 15
    
    ; Forms section
    for index, form in forms
    {
        status := MappingStatuses[form.name]
        formName := form.name
        
        ; Form name and status on same line
        Gui, Launcher:Font, s10 Bold, Arial
        Gui, Launcher:Add, Text, x20 y%yPos% w300, % form.display
        
        ; Status indicator
        if (status.exists)
        {
            statusText := "Mapped (" . status.fieldCount . " fields)"
            Gui, Launcher:Font, s9 Normal, Arial
            Gui, Launcher:Add, Text, x330 y%yPos% w150 cGreen, % statusText
        }
        else
        {
            Gui, Launcher:Font, s9 Normal, Arial
            Gui, Launcher:Add, Text, x330 y%yPos% w150 cRed, Not Mapped
        }
        yPos += 25
        
        ; Map button with unique text (index prefix)
        Gui, Launcher:Font, s8 Normal, Arial
        mapBtnText := index . ":Map"
        Gui, Launcher:Add, Button, x40 y%yPos% w60 h22 gDevBtnHandler, %mapBtnText%
        DevBtnActions[mapBtnText] := {action: "map", formName: formName, presetName: ""}
        
        ; Delete Mapping button (only if mapped)
        if (status.exists)
        {
            delMapBtnText := index . ":DelMap"
            Gui, Launcher:Add, Button, x105 y%yPos% w100 h22 gDevBtnHandler, %delMapBtnText%
            DevBtnActions[delMapBtnText] := {action: "delmap", formName: formName, presetName: ""}
        }
        yPos += 28
        
        ; Presets section
        allPresets := DiscoverAllPresets(form.name)
        if (allPresets.Length() > 0)
        {
            Gui, Launcher:Font, s8 Normal, Arial
            Gui, Launcher:Add, Text, x40 y%yPos% w50 cGray, Presets:
            
            xPos := 95
            for pIndex, presetName in allPresets
            {
                ; Preset name as text
                Gui, Launcher:Add, Text, x%xPos% y%yPos%, % presetName
                textWidth := StrLen(presetName) * 7 + 5
                xPos += textWidth
                
                ; Delete button with unique text
                delPresetBtnText := index . ":" . pIndex . ":x"
                Gui, Launcher:Add, Button, x%xPos% y%yPos% w20 h18 gDevBtnHandler, %delPresetBtnText%
                DevBtnActions[delPresetBtnText] := {action: "delpreset", formName: formName, presetName: presetName}
                xPos += 30
                
                ; Wrap to next line if too wide
                if (xPos > 450)
                {
                    xPos := 95
                    yPos += 22
                }
            }
            yPos += 25
        }
        else
        {
            Gui, Launcher:Font, s8 Normal Italic, Arial
            Gui, Launcher:Add, Text, x40 y%yPos% w200 cGray, (no presets)
            yPos += 22
        }
        
        ; Spacing between forms
        yPos += 10
    }
    
    ; Separator
    Gui, Launcher:Add, Text, x20 y%yPos% w520 h2 +0x10
    yPos += 15
    
    ; Exit button
    Gui, Launcher:Font, s10 Normal, Arial
    Gui, Launcher:Add, Button, x20 y%yPos% w100 h28 gLauncherGuiClose, Exit
    Gui, Launcher:Add, Button, x380 y%yPos% w140 h28 gDevExitDevMode, Exit Dev Mode
    
    ; Calculate window height
    winHeight := yPos + 50
    
    ; Show the GUI
    Gui, Launcher:Show, w560 h%winHeight%
}

; ==============================================================================
; Universal Button Handler
; ==============================================================================
HandleButtonClick:
    global ButtonMap
    
    ; Get button text
    buttonText := A_GuiControl
    
    ; Lookup in ButtonMap
    if (!ButtonMap.HasKey(buttonText))
    {
        MsgBox, 16, Error, Unknown button: %buttonText%
        return
    }
    
    data := ButtonMap[buttonText]
    LaunchForm(data.path, data.preset)
return

; ==============================================================================
; Developer Mode Button Handlers
; ==============================================================================

; View Config button
DevViewConfig:
    ViewConfig()
return

; Map All Unmapped button
DevMapAllUnmapped:
    MapAllUnmapped()
return

; Universal dev button handler - uses button text to identify action
DevBtnHandler:
    global DevBtnActions
    
    ; A_GuiControl contains the button text
    btnText := A_GuiControl
    
    ; Look up action in our map
    if (!DevBtnActions.HasKey(btnText))
    {
        MsgBox, 16, Error, Unknown dev button: %btnText%
        return
    }
    
    data := DevBtnActions[btnText]
    
    if (data.action = "map")
    {
        LaunchCoordHelperForForm(data.formName)
    }
    else if (data.action = "delmap")
    {
        DeleteFormMapping(data.formName)
    }
    else if (data.action = "delpreset")
    {
        DeleteFormPreset(data.formName, data.presetName)
    }
return

; Exit Dev Mode button
DevExitDevMode:
    global DevModeActive
    DevModeActive := false
    ShowLauncherGUI(false)
return

; ==============================================================================
; Launch Form Helper
; ==============================================================================
LaunchForm(formPath, presetName := "")
{
    global LauncherPatientName
    global LauncherODTitle
    
    ; Path is already correct from DiscoverForms()
    ; (.exe in compiled mode, .ahk in dev mode)
    
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
; GUI Close Handler
; ==============================================================================
LauncherGuiClose:
LauncherGuiEscape:
    ExitApp
return
