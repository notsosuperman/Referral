; ==============================================================================
; Open Dental Automation Library
; Window management, navigation, and click helpers for OD automation
; ==============================================================================

; ==============================================================================
; Include Logging Library
; Use A_LineFile to get path relative to THIS file, not the main script
; ==============================================================================
#Include %A_LineFile%\..\Logging.ahk

; ==============================================================================
; COORDINATE CONFIGURATION
; All click locations - update these if UI changes
; ==============================================================================

; Patient Info Panel (main OD window, client coords)
global OD_PATIENT_SCROLLBAR := {x: 451, y: 579, desc: "Patient Info Scrollbar"}
global OD_REFERRED_FROM := {x: 100, y: 642, desc: "Referred From Line"}

; "Referrals for Patient" window (client coords)
global REF_REFER_TO_BTN := {x: 62, y: 81, desc: "Refer To Button"}
global REF_SLIP_BTN := {x: 61, y: 475, desc: "Referral Slip Button"}

; "Referrals" search window (client coords)
global REF_FIRST_RESULT := {x: 77, y: 107, desc: "First Search Result"}

; OD Mode detection pixels (client coords, x=1 for left sidebar)
global OD_MODES := {"Appts": {x: 1, y: 82}
    , "Family": {x: 1, y: 140}
    , "Account": {x: 1, y: 198}
    , "TxPlan": {x: 1, y: 256}
    , "Chart": {x: 1, y: 314}
    , "Imaging": {x: 1, y: 372}
    , "Manage": {x: 1, y: 430}}
global OD_MODE_SELECTED_COLOR := 0xFFFFFF  ; White when tab selected

; ==============================================================================
; TIMEOUT CONFIGURATION
; ==============================================================================
global OD_WINDOW_TIMEOUT := 3  ; Seconds to wait for windows

; ==============================================================================
; INPUT BLOCKING
; ==============================================================================
global OD_BlockInputActive := false

BlockInputOn()
{
    global OD_BlockInputActive
    OD_BlockInputActive := true
    BlockInput, On
    BlockInput, MouseMove
    Checkpoint("BlockInput ON", false)
}

BlockInputOff()
{
    global OD_BlockInputActive
    OD_BlockInputActive := false
    BlockInput, Off
    BlockInput, MouseMoveOff
    Checkpoint("BlockInput OFF", false)
}

; ==============================================================================
; WINDOW MANAGEMENT
; ==============================================================================

; Check if any OD sub-window is blocking the main window
ODHasBlockingWindow()
{
    ; If OD main is not active but an OD process window is, there's a blocker
    if !WinActive("Open Dental {")
    {
        if WinActive("ahk_exe OpenDental.exe")
            return true
    }
    return false
}

; Activate OD main window, check for blockers
; Returns: true if successful, false if blocked
ODActivateMain(expectedTitle := "")
{
    ; Try to activate OD main window
    if (expectedTitle != "")
        WinActivate, %expectedTitle%
    else
        WinActivate, Open Dental {
    
    Sleep, 100
    
    ; Check if we actually activated the main window
    if ODHasBlockingWindow()
        return false
    
    if !WinActive("Open Dental {")
        return false
    
    return true
}

; Get current OD mode (Chart, Appts, etc)
ODGetMode()
{
    global OD_MODES
    global OD_MODE_SELECTED_COLOR
    
    if !WinActive("Open Dental {")
        return "NA"
    
    CoordMode, Pixel, Client
    
    for mode, coord in OD_MODES
    {
        px := coord.x
        py := coord.y
        PixelGetColor, color, %px%, %py%, RGB
        if (color = OD_MODE_SELECTED_COLOR)
            return mode
    }
    
    return "Unknown"
}

; Set OD mode (Chart, Appts, etc)
ODSetMode(modeToSet)
{
    global OD_MODES
    global OD_MODE_SELECTED_COLOR
    
    if !WinActive("Open Dental {")
    {
        Checkpoint("ODSetMode failed - OD not active", true)
        return false
    }
    
    CoordMode, Pixel, Client
    CoordMode, Mouse, Client
    
    coord := OD_MODES[modeToSet]
    if (!coord)
    {
        Checkpoint("ODSetMode failed - invalid mode: " . modeToSet, false)
        return false
    }
    
    px := coord.x
    py := coord.y
    PixelGetColor, color, %px%, %py%, RGB
    if (color != OD_MODE_SELECTED_COLOR)
    {
        ; Mode not selected, click to select
        Click, %px%, %py%
        Sleep, 200
        Checkpoint("ODSetMode clicked " . modeToSet, false)
    }
    
    return true
}

; Check if Chart view is active
ODIsChartView()
{
    return (ODGetMode() = "Chart")
}

; Ensure Chart view is active
ODEnsureChartView()
{
    if !ODIsChartView()
    {
        Checkpoint("Switching to Chart view", false)
        return ODSetMode("Chart")
    }
    return true
}

; ==============================================================================
; WAITING HELPERS
; ==============================================================================

; Wait for window with timeout and logging
; Returns: true if window appeared, false on timeout
WaitWin(windowTitle, timeoutSeconds := 3, description := "")
{
    if (description = "")
        description := windowTitle
    
    Checkpoint("Waiting for: " . description, false)
    
    WinWait, %windowTitle%,, %timeoutSeconds%
    
    if ErrorLevel
    {
        Checkpoint("TIMEOUT waiting for: " . description, true)
        return false
    }
    
    WinActivate, %windowTitle%
    Sleep, 100
    Checkpoint("Found: " . description, true)
    return true
}

; Wait for window to be active
WaitWinActive(windowTitle, timeoutSeconds := 3, description := "")
{
    if (description = "")
        description := windowTitle
    
    Checkpoint("Waiting for active: " . description, false)
    
    WinWaitActive, %windowTitle%,, %timeoutSeconds%
    
    if ErrorLevel
    {
        Checkpoint("TIMEOUT waiting for active: " . description, true)
        return false
    }
    
    Checkpoint("Active: " . description, true)
    return true
}

; ==============================================================================
; CLICK HELPERS
; ==============================================================================

; Click at coordinate object with logging
; coordObj: {x: n, y: n, desc: "description"}
; doubleClick: true for double-click
ClickAt(coordObj, doubleClick := false)
{
    CoordMode, Mouse, Client
    
    desc := coordObj.HasKey("desc") ? coordObj.desc : "x" . coordObj.x . " y" . coordObj.y
    clickType := doubleClick ? "Double-click" : "Click"
    
    Checkpoint(clickType . " at: " . desc, false)
    
    px := coordObj.x
    py := coordObj.y
    if (doubleClick)
        Click, %px%, %py%, 2
    else
        Click, %px%, %py%
    
    Sleep, 50
}

; ==============================================================================
; PATIENT NAME PARSING
; ==============================================================================

; Parse patient name from OD window title
; Title format: "Open Dental {username} - LastName, FirstName ..."
; Returns: "LastName, FirstName" or empty string if not found
ParsePatientFromTitle(windowTitle)
{
    ; Match pattern: "Open Dental {...} - PatientName"
    if (RegExMatch(windowTitle, "Open Dental \{[^}]+\} - (.+)", match))
    {
        ; Clean up - remove extra info after patient name if any
        patientName := match1
        ; Trim any trailing info (like chart number etc)
        if (InStr(patientName, " ("))
            patientName := SubStr(patientName, 1, InStr(patientName, " (") - 1)
        return Trim(patientName)
    }
    return ""
}

; ==============================================================================
; NAVIGATION TO FILL SHEET
; Main automation sequence
; ==============================================================================

; Navigate from OD main window to Fill Sheet
; specialistName: name to search for in referrals
; Returns: true if successful, false on any failure
NavigateToFillSheet(specialistName)
{
    global OD_WINDOW_TIMEOUT
    global OD_PATIENT_SCROLLBAR
    global OD_REFERRED_FROM
    global REF_REFER_TO_BTN
    global REF_FIRST_RESULT
    global REF_SLIP_BTN
    
    Checkpoint("=== Starting Navigation to Fill Sheet ===", false)
    Checkpoint("Specialist: " . specialistName, false)
    
    CoordMode, Mouse, Client
    
    ; Step 1: Scroll Patient Info to top
    Checkpoint("Step 1: Scrolling Patient Info to top", false)
    ClickAt(OD_PATIENT_SCROLLBAR)
    Sleep, 200
    
    ; Step 2: Double-click Referred From
    Checkpoint("Step 2: Opening Referrals for Patient", false)
    ClickAt(OD_REFERRED_FROM, true)
    
    ; Step 3: Wait for Referrals for Patient window
    if !WaitWin("Referrals for Patient", OD_WINDOW_TIMEOUT, "Referrals for Patient window")
    {
        Failure("Timeout waiting for 'Referrals for Patient' window", true, true, false)
        return false
    }
    
    ; Step 4: Click Refer To button
    Checkpoint("Step 4: Clicking Refer To button", false)
    ClickAt(REF_REFER_TO_BTN)
    
    ; Step 5: Wait for Referrals search window
    if !WaitWin("Referrals", OD_WINDOW_TIMEOUT, "Referrals search window")
    {
        Failure("Timeout waiting for 'Referrals' search window", true, true, false)
        return false
    }
    Sleep, 200
    
    ; Step 6: Paste specialist name (window already has focus on search)
    Checkpoint("Step 6: Searching for specialist: " . specialistName, false)
    
    ; Use clipboard for instant paste
    ClipboardBackup := ClipboardAll
    Clipboard := specialistName
    ClipWait, 1
    Send, ^v
    Sleep, 300
    Clipboard := ClipboardBackup
    ClipboardBackup := ""
    
    Sleep, 200  ; Wait for search results
    
    ; Step 7: Click first result
    Checkpoint("Step 7: Selecting first result", false)
    ClickAt(REF_FIRST_RESULT)
    Sleep, 100
    
    ; Step 8: Press Alt+O to click OK
    Checkpoint("Step 8: Confirming selection (Alt+O)", false)
    Send, !o
    Sleep, 200
    
    ; Step 9: Wait for Referrals for Patient to reopen
    if !WaitWin("Referrals for Patient", OD_WINDOW_TIMEOUT, "Referrals for Patient window (after add)")
    {
        Failure("Timeout waiting for 'Referrals for Patient' to reopen", true, true, false)
        return false
    }
    Sleep, 200
    
    ; Step 10: Click Referral Slip button
    Checkpoint("Step 10: Clicking Referral Slip button", false)
    ClickAt(REF_SLIP_BTN)
    
    ; Step 11: Wait for Fill Sheet window
    if !WaitWin("Fill Sheet", OD_WINDOW_TIMEOUT, "Fill Sheet window")
    {
        Failure("Timeout waiting for 'Fill Sheet' window", true, true, false)
        return false
    }
    
    Checkpoint("=== Navigation Complete - Fill Sheet Ready ===", true)
    return true
}
