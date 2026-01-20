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
; DYNAMIC DISCOVERY FUNCTIONS
; ==============================================================================

; Discover all forms in Forms\ directory
DiscoverForms()
{
    forms := []
    
    Loop, Files, %A_ScriptDir%\Forms\*.ahk
    {
        formData := ParseFormHeader(A_LoopFileFullPath)
        if (formData.name != "")
        {
            formData.path := A_LoopFileFullPath
            forms.Push(formData)
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
        
        ; Extract DISPLAY_NAME
        if (RegExMatch(line, "i)^\s*;\s*DISPLAY_NAME:\s*(.+)", match))
        {
            formData.display := Trim(match1)
        }
    }
    
    ; DISPLAY_NAME is required
    if (formData.display = "")
    {
        ; Error: DISPLAY_NAME is required
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
; Dynamic GUI Building
; ==============================================================================
ShowLauncherGUI()
{
    global LauncherPatientName
    global ButtonMap
    
    ; Discover forms and presets
    forms := DiscoverForms()
    presetMap := DiscoverPresets()
    forms := MergeAndSortForms(forms, presetMap)
    
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
; Launch Form Helper
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
; GUI Close Handler
; ==============================================================================
LauncherGuiClose:
LauncherGuiEscape:
    ExitApp
return
