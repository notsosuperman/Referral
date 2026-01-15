; ==============================================================================
; ODAutomation Library - Open Dental navigation and window management
; Include: #Include %A_ScriptDir%\..\Lib\ODAutomation.ahk
; ==============================================================================

; Include dependencies
#Include %A_ScriptDir%\..\Lib\Logging.ahk

; ==============================================================================
; Coordinate Definitions
; ==============================================================================

; Open Dental - Patient Info section
global OD_PATIENT_SCROLLBAR := {x: 451, y: 579}
global OD_REFERRED_FROM := {x: 100, y: 642}

; Referrals for Patient window
global REF_REFER_TO_BTN := {x: 62, y: 81}
global REF_SLIP_BTN := {x: 61, y: 475}

; Referrals search window
global REF_FIRST_RESULT := {x: 77, y: 107}

; Open Dental mode detection (from Combo Master)
global ODmodes := {"Appts": {x: 1, y: 82}
    , "Family": {x: 1, y: 140}
    , "Account": {x: 1, y: 198}
    , "TxPlan": {x: 1, y: 256}
    , "Chart": {x: 1, y: 314}
    , "Imaging": {x: 1, y: 372}
    , "Manage": {x: 1, y: 430}}
global ODModeCheckColor := 0xFFFFFF
global imagingCheckPixel := {x: 1, y: 373}

; ==============================================================================
; Main Navigation Function
; ==============================================================================

ODNavigate(odWindowTitle, specialistName)
{
    Checkpoint("Starting Open Dental navigation", false)
    
    ; Block input during automation
    BlockInput, On
    BlockInput, MouseMove
    
    ; 1. Activate Open Dental main window
    if (!ODWinActivate(odWindowTitle))
    {
        BlockInput, Off
        BlockInput, MouseMoveOff
        Failure("Could not activate Open Dental window. Please close any blocking windows and try again.")
        return false
    }
    
    ; 2. Ensure Chart view is active
    if (!ValidateChartView())
    {
        BlockInput, Off
        BlockInput, MouseMoveOff
        Failure("Could not switch to Chart view")
        return false
    }
    
    ; 3. Scroll Patient Info to top
    Checkpoint("Scrolling patient info to top")
    ClickAt(OD_PATIENT_SCROLLBAR, "Scroll patient info")
    Sleep, 200
    
    ; 4. Open Referrals for Patient
    Checkpoint("Opening Referrals for Patient")
    Click, % OD_REFERRED_FROM.x, % OD_REFERRED_FROM.y, 2  ; Double-click
    
    if (!WaitForWindow("Referrals for Patient", 3, "Referrals for Patient window"))
        return false
    
    ; 5. Click Refer To button
    Checkpoint("Clicking Refer To button")
    ClickAt(REF_REFER_TO_BTN, "Refer To button")
    
    if (!WaitForWindow("Referrals", 3, "Referral search window"))
        return false
    
    ; 6. Search for specialist
    Checkpoint("Searching for specialist: " . specialistName)
    SendInput, %specialistName%
    Sleep, 300
    
    ; 7. Select first result
    Checkpoint("Selecting first search result")
    ClickAt(REF_FIRST_RESULT, "First search result")
    Sleep, 200
    
    ; 8. Click OK
    Checkpoint("Confirming specialist selection")
    Send, !o  ; Alt+O for OK button
    
    if (!WaitForWindow("Referrals for Patient", 3, "Referrals for Patient window (confirmation)"))
        return false
    
    ; 9. Open Referral Slip
    Checkpoint("Opening Referral Slip")
    ClickAt(REF_SLIP_BTN, "Referral Slip button")
    
    if (!WaitForWindow("Fill Sheet", 3, "Fill Sheet window"))
        return false
    
    Success("Navigation to Fill Sheet complete")
    BlockInput, Off
    BlockInput, MouseMoveOff
    return true
}

; ==============================================================================
; Helper Functions
; ==============================================================================

; Activate Open Dental main window, check for blocking windows
ODWinActivate(expectedTitle)
{
    Checkpoint("Activating Open Dental: " . expectedTitle)
    
    ; Try to activate the expected window
    WinActivate, %expectedTitle%
    Sleep, 300
    
    ; Check if it's actually active
    WinGetTitle, activeTitle, A
    
    ; Exact title match - correct patient
    if (activeTitle = expectedTitle)
    {
        Checkpoint("Correct patient window confirmed: " . expectedTitle)
        return true
    }
    
    ; Check if a different OpenDental.exe window is active (blocking)
    if (WinActive("ahk_exe OpenDental.exe"))
    {
        WinGetTitle, blockingWindow, A
        
        ; Check if it's a different patient (wrong OD main window)
        if (InStr(blockingWindow, "Open Dental {"))
        {
            BlockInput, Off
            BlockInput, MouseMoveOff
            Failure("PATIENT MISMATCH!`n`nExpected patient:`n" . expectedTitle . "`n`nCurrent patient:`n" . blockingWindow . "`n`nPlease return to the correct patient chart before submitting.")
            return false
        }
        
        ; It's a blocking sub-window
        BlockInput, Off
        BlockInput, MouseMoveOff
        Failure("Open Dental window is blocked by:`n" . blockingWindow . "`n`nPlease close this window and try again.")
        return false
    }
    
    BlockInput, Off
    BlockInput, MouseMoveOff
    Failure("Could not activate Open Dental window")
    return false
}

; Ensure Chart view is active
ValidateChartView()
{
    Checkpoint("Validating Chart view")
    
    mode := GetODMode()
    if (mode = "Chart")
    {
        Checkpoint("Already in Chart view")
        return true
    }
    
    if (mode = "")
    {
        BlockInput, Off
        BlockInput, MouseMoveOff
        Failure("Could not detect Open Dental mode")
        return false
    }
    
    Checkpoint("Switching from " . mode . " to Chart view")
    SetODMode("Chart")
    Sleep, 300
    
    ; Verify switch worked
    mode := GetODMode()
    if (mode = "Chart")
    {
        Checkpoint("Successfully switched to Chart view")
        return true
    }
    
    return false
}

; Get current Open Dental mode (Chart/Appts/etc) - from Combo Master
GetODMode()
{
    global ODModeCheckColor
    global ODmodes
    
    UnfocusImagingModeFrame()
    
    if (!WinActive("Open Dental {"))
        return ""
    
    CoordMode, Pixel, Client
    for mode, coord in ODmodes
    {
        PixelGetColor, color, coord.x, coord.y, RGB
        if (color = ODModeCheckColor)
            return mode
    }
    
    return ""
}

; Set Open Dental mode (Chart/Appts/etc) - from Combo Master
SetODMode(modeToSet)
{
    global ODmodes
    global ODModeCheckColor
    
    if (!WinActive("ahk_exe OpenDental.exe"))
    {
        Failure("SetODMode failed: Open Dental not active")
        return false
    }
    
    UnfocusImagingModeFrame()
    
    if (!WinActive("Open Dental {"))
    {
        Failure("SetODMode failed: Not on main Open Dental window")
        return false
    }
    
    CoordMode, Pixel, Client
    CoordMode, Mouse, Client
    
    x := ODmodes[modeToSet].x
    y := ODmodes[modeToSet].y
    
    PixelGetColor, color, x, y, RGB
    if (color != ODModeCheckColor)
    {
        Click, %x%, %y%
        Sleep, 200
    }
    
    return true
}

; Handle imaging mode focus issue - from Combo Master
UnfocusImagingModeFrame()
{
    global imagingCheckPixel
    global ODModeCheckColor
    
    if (!WinActive("ahk_exe OpenDental.exe"))
        return
    
    CoordMode, Pixel, Screen
    PixelGetColor, color, imagingCheckPixel.x, imagingCheckPixel.y, RGB
    if (color = ODModeCheckColor)
        WinActivate, Open Dental {
    
    CoordMode, Pixel, Client
}

; Click at coordinates with logging
ClickAt(coordObj, description)
{
    CoordMode, Mouse, Client
    x := coordObj.x
    y := coordObj.y
    Click, %x%, %y%
    Sleep, 50
}

; Wait for window with timeout and logging
WaitForWindow(windowTitle, timeoutSeconds, description)
{
    Checkpoint("Waiting for window: " . windowTitle)
    
    WinWaitActive, %windowTitle%,, %timeoutSeconds%
    if (ErrorLevel)
    {
        BlockInput, Off
        BlockInput, MouseMoveOff
        Failure(description . " did not appear within " . timeoutSeconds . " seconds")
        return false
    }
    
    Checkpoint("Window appeared: " . windowTitle)
    return true
}
