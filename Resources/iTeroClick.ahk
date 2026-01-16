; AutoHotkey v1 script to open My iTero patient search from Open Dental bridge
; Uses command line arguments: LastName and FirstName
; ABSTRACTED VERSION: Unified HandleLogin, Loop-based SearchForPatient
#SingleInstance Force ; Avoids multiple script instances
SetWorkingDir %A_ScriptDir%

CoordMode, Tooltip
CoordMode, Mouse, Client
CoordMode, Pixel, Client

SetTitleMatchMode, RegEx

; ===== GLOBAL VARIABLES =====
global postSearchClickCount := 0
global monitoringActive := false
global loginInProgress := false
global monitoringForiTeroSearchFieldLongClick := false
global postSearchMode := false  ; Flag: false = pre-search (wait for patients page), true = post-search (don't wait)

; ===== HELPER FUNCTIONS =====

; Function to show a tooltip at the cursor position
ShowTooltipAtCursor(message, duration := 10000)
{
    global currentTooltipMessage := message
    ToolTip, %message%
    SetTimer, RemoveToolTip, -%duration% ; Remove tooltip after specified duration
    SetTimer, UpdateToolTipPosition, 100 ; Update tooltip position every 100ms
    return
}

; Custom Return function
Return() 
{
    BlockInput, Off
	BlockInput, MouseMoveOff
    ExitApp
}

; Function to log checkpoint events
Checkpoint(message, logWindow := true)
{
    if (logWindow)
    {
        WinGetTitle, currentTitle, A
        message := message . " Current window title: " . currentTitle
    }
    LogEvent("\\Server01\OfficeFiles\Script\Logs\Itero.log", "CHECKPOINT: " . message)
    return
}

; Function to log failure events
Failure(message, logWindow := true, showMsgBox := true, exitScript := true)
{
    BlockInput, Off
	BlockInput, MouseMoveOff
    if (logWindow)
    {
        WinGetTitle, currentTitle, A
        message := message . " Current window title: " . currentTitle
    }
    LogEvent("\\Server01\OfficeFiles\Script\Logs\IteroFailures.log", message)
    LogEvent("\\Server01\OfficeFiles\Script\Logs\Itero.log", "FAILURE: " . message . "`n`n")
    
    if (showMsgBox)
        MsgBox, %message%
    
    if (exitScript)
        Return()
    
    return
}

; Function to log success events
Success(message, logWindow := true)
{
    if (logWindow)
    {
        WinGetTitle, currentTitle, A
        message := message . " Current window title: " . currentTitle
    }
    LogEvent("\\Server01\OfficeFiles\Script\Logs\IteroSuccesses.log", "SUCCESS: " . message)
    LogEvent("\\Server01\OfficeFiles\Script\Logs\Itero.log", "SUCCESS: " . message)
    return
}

; Function to log events
LogEvent(logFile, message) 
{
    ; Create directory path if it doesn't exist
    SplitPath, logFile,, logDir
    if (!InStr(FileExist(logDir), "D"))
        FileCreateDir, %logDir%

    FormatTime, timestamp,, yyyy-MM-dd HH:mm:ss
    computerName := A_ComputerName
    FileAppend, %timestamp% | %computerName% | %message%`n, %logFile%
    
    ; Also log to local file for easy debugging
    ; localLogFile := A_ScriptDir . "\iTeroClick_debug.log"
    ; FileAppend, %timestamp% | %computerName% | %message%`n, %localLogFile%
    return
}

; Function to save click position
SaveClickPosition(clickName, x, y)
{
    clickLogFile := "\\Server01\OfficeFiles\Script\Logs\Clicks\" . A_ComputerName . clickName . ".log"
     
    ; Create directory path if it doesn't exist
    SplitPath, clickLogFile,, clickLogDir
    if (!InStr(FileExist(clickLogDir), "D"))
        FileCreateDir, %clickLogDir%
        
    FileDelete, %clickLogFile% ; Delete existing file to ensure clean write
    FileAppend, %x%`,%y%, %clickLogFile%
    return
}

; Function to get click position
GetClickPosition(clickName)
{
    iniFile := "\\Server01\OfficeFiles\Script\Logs\Clicks\" . A_ComputerName . clickName . ".log"
    
    FileRead, content, %iniFile%
    if (ErrorLevel)
        return false
    
    if (RegExMatch(content, "^(\d+),(\d+)$", match))
        return {x: match1, y: match2}
    return false
}

; ===== MAIN SCRIPT FLOW =====

; Get command line arguments (Open Dental bridge passes: LastName FirstName)
if (A_Args.Length() < 2)
{
    Failure("Not enough command line arguments. Expected: LastName FirstName. Got " . A_Args.Length() . " arguments.", false, false, true)
    return
}

LastName := A_Args[1]
FirstName := A_Args[2]

Checkpoint("Script started. LastName: " . LastName . ", FirstName: " . FirstName, false)

; Extract simple first name and first initial
FirstNameSimp := RegExReplace(FirstName, "[\s,].*$", "") ; Get first word before space or comma
FirstInitial := SubStr(FirstNameSimp, 1, 1) ; Get the first initial

; Get Open Dental window position to move Chrome to same monitor
WinGetActiveTitle, openDentalTitle
WinGetPos, openDentalX, openDentalY, openDentalWidth, openDentalHeight, %openDentalTitle%
if (openDentalY < 0) ; Check if openDentalY is negative and set it to zero if it is
    openDentalY := 0

iTeroWelcomeWindowTitle := "(Welcome.*My iTero|pre-login-app).*Chrome"
iTeroLoginWindowTitle := "(Login.*My iTero|myaccount-us\.aligntech\.com.*login).*Chrome"
myPatientsWindowTitle := "Patients.*My iTero.*Chrome"
iTeroAnyWindowTitle := "(myitero|aligntech|iterocloud|pre-login-app).*Chrome"

; Block input and mouse movement at the very start
BlockInput, On
BlockInput, MouseMove
Checkpoint("Script started - input and mouse movement blocked.", false)

; Open Chrome to the patients page directly
Run, chrome.exe "https://bff.cloud.myitero.com/doctors/patients"

; Wait for either the Welcome page (not logged in) or Patients page (already logged in)
; Wait up to 7 seconds for one of these windows
Checkpoint("Waiting for iTero window to load...", false)
startTime := A_TickCount
foundWindow := false
Loop
{
    if (A_TickCount - startTime > 7000)
    {
        WinGetActiveTitle, debugTitle
        Failure("No iTero window detected within 7 seconds. Current title: " . debugTitle, false, false, true)
        return
    }
    
    WinGetActiveTitle, currentTitle
    LogEvent("\\Server01\OfficeFiles\Script\Logs\Itero.log", "DEBUG: Checking window title: " . currentTitle)
    
    ; Check if we're on the Patients page (already logged in)
    if (RegExMatch(currentTitle, myPatientsWindowTitle))
    {
        Checkpoint("Already logged in - Patients page detected. Title: " . currentTitle, false)
        foundWindow := true
        GoSub, SearchForPatient
        return
    }
    
    ; Check if we're on the Welcome page (need to enter email)
    if (RegExMatch(currentTitle, iTeroWelcomeWindowTitle))
    {
        Checkpoint("Welcome page detected - need to log in. Title: " . currentTitle, false)
        foundWindow := true
        break
    }
    
    Sleep, 100
}

; If we get here, we're on the Welcome page and need to log in
Checkpoint("Exited detection loop - foundWindow: " . foundWindow, false)

if (!foundWindow)
{
    Failure("Did not detect Welcome or Patients page in detection loop", false, false, true)
    return
}

; Move Chrome window to the same monitor as Open Dental
WinGet, activeWindow, ID, A
WinRestore, ahk_id %activeWindow%
WinMove, ahk_id %activeWindow%,, %openDentalX%, %openDentalY%, %openDentalWidth%, %openDentalHeight%
WinMaximize, ahk_id %activeWindow%

Checkpoint("Window moved and maximized, calling HandleLogin", false)

; Call the reusable login handler
GoSub, HandleLogin

; After login, go to patient search
GoSub, SearchForPatient
return

; ===== UNIFIED LOGIN HANDLER (DRY) =====
; Uses global flag: postSearchMode
;   false = Pre-search: Wait for Patients page after login
;   true  = Post-search: Don't wait, just unblock and return (browser redirects user back)
HandleLogin:
    Checkpoint("HandleLogin: Starting login flow (postSearchMode=" . postSearchMode . ")", false)
    
    ; Clear any tooltips and stop tooltip timer
    ToolTip
    SetTimer, UpdateToolTipPosition, Off
    
    ; If post-search redirect, pause the right-click checking
    if (postSearchMode)
        SetTimer, CheckRightClick, Off
    
    ; Block input while handling login
    BlockInput, On
    BlockInput, MouseMove
    
    ; Make sure the Welcome window is active
    WinActivate, %iTeroWelcomeWindowTitle%
    Sleep, 300
    
    ; Tab to focus on email field and paste email, then press Enter
    Checkpoint("HandleLogin: Sending Tab to focus email field", false)
    SendInput, {Tab}
    Sleep, 200
    Checkpoint("HandleLogin: Entering email address", false)
    SendInput, benwolfe@wolfedental.com
    Sleep, 200
    Checkpoint("HandleLogin: Pressing Enter to submit email", false)
    SendInput, {Enter}
    
    ; Wait for the Login page with password field
    Checkpoint("HandleLogin: Waiting for Login page with password field...", false)
    WinWaitActive, %iTeroLoginWindowTitle%,, 7
    if (ErrorLevel)
    {
        WinGetActiveTitle, debugTitle
        Failure("HandleLogin: Login page did not appear after entering email. Current title: " . debugTitle, false, false, true)
        return
    }
    
    Checkpoint("HandleLogin: Login page loaded - handling password.", false)
    
    ; We're on the password page - Chrome should autofill, just need to Tab and Enter
    Sleep, 500
    Checkpoint("HandleLogin: Sending Tab to focus password field", false)
    SendInput, {Tab}
    Sleep, 200
    Checkpoint("HandleLogin: Pressing Enter to submit password", false)
    SendInput, {Enter}
    
    ; Wait behavior depends on flag
    if (!postSearchMode)
    {
        ; Wait for Patients page specifically (not in post-search mode)
        Checkpoint("HandleLogin: Waiting for Patients page after password submit...", false)
        WinWaitActive, % myPatientsWindowTitle,, 10
        if (ErrorLevel)
        {
            WinGetActiveTitle, debugTitle
            Failure("HandleLogin: Failed to reach Patients page after login. Current title: " . debugTitle, false, false, true)
            return
        }
        Checkpoint("HandleLogin: Login successful - now on Patients page.", false)
    }
    else
    {
        ; Post-search mode: wait until we're OFF the login page, then unblock
        Checkpoint("HandleLogin: Waiting to leave login page...", false)
        Loop, 20  ; Up to 10 seconds (20 * 500ms)
        {
            Sleep, 500
            WinGetActiveTitle, currentTitle
            if (!RegExMatch(currentTitle, iTeroLoginWindowTitle))
            {
                Checkpoint("HandleLogin: Left login page. Current: " . currentTitle, false)
                Break
            }
        }
        if (A_Index >= 20)
            Checkpoint("HandleLogin: Timeout waiting to leave login page, continuing anyway.", false)
    }
    
    ; Unblock input
    BlockInput, Off
    BlockInput, MouseMoveOff
    
    ; If post-search redirect, resume right-click checking
    if (postSearchMode)
        SetTimer, CheckRightClick, 100
    
    Checkpoint("HandleLogin: Login complete, input unblocked.", false)
return

; ===== PATIENT SEARCH (Loop-based) =====
SearchForPatient:
    ; Move Chrome window to the same monitor as Open Dental (ONCE, outside loop)
    WinGet, activeWindow, ID, A
    WinRestore, ahk_id %activeWindow%
    WinMove, ahk_id %activeWindow%,, %openDentalX%, %openDentalY%, %openDentalWidth%, %openDentalHeight%
    WinMaximize, ahk_id %activeWindow%
    
    Checkpoint("SearchForPatient: Patients page ready for search.", true)
    Sleep, 800  ; Longer wait to let any redirect settle before checking
    
    ; Loop up to 2 times (original attempt + 1 retry after login)
    Loop, 2
    {
        Checkpoint("SearchForPatient: Search attempt #" . A_Index, false)
        
        ; Check page BEFORE any input to avoid race condition
        WinGetActiveTitle, currentTitle
        Checkpoint("SearchForPatient: Checking page before input. Title: " . currentTitle, false)
        
        if (RegExMatch(currentTitle, iTeroWelcomeWindowTitle))
        {
            ; Already redirected to login - handle it before trying to search
            if (A_Index = 1)
            {
                Checkpoint("SearchForPatient: Redirect detected BEFORE search - going to login", false)
                GoSub, HandleLogin
                
                Checkpoint("SearchForPatient: Login successful, retrying search...", false)
                Sleep, 500
                Continue  ; Go back to top of loop for retry
            }
            else
            {
                ; Second attempt also failed
                Failure("SearchForPatient: Still on Welcome page after retry", false, false, true)
                return
            }
        }
        else if (RegExMatch(currentTitle, myPatientsWindowTitle))
        {
            ; On Patients page - proceed with search
            Checkpoint("SearchForPatient: On Patients page - Tab, paste name, Enter", false)
            SendInput, {Tab}
            SendInput, % LastName . ", " . FirstNameSimp
            SendInput, {Enter}
            
            ; Transition to post-search phase
            postSearchMode := true
            
            GoSub, StartPostSearchMonitoring
            return
        }
        else
        {
            ; Unexpected page
            Failure("SearchForPatient: Ended up on unexpected page: " . currentTitle, false, false, true)
            return
        }
    }
    
    ; Should not reach here, but just in case
    Failure("SearchForPatient: Exited loop unexpectedly", false, false, true)
return

; ===== START POST-SEARCH MONITORING =====
StartPostSearchMonitoring:
    ; Unblock input and mouse now that search is complete
    BlockInput, Off
    BlockInput, MouseMoveOff
    
    ; Show tooltip and enable long-click search feature
    ShowTooltipAtCursor("No results? Long click search field to search first initial")
    monitoringForiTeroSearchFieldLongClick := true
    
    ; Start post-search monitoring for login redirects
    postSearchClickCount := 0
    monitoringActive := true
    loginInProgress := false
    SetTimer, MonitorForLoginRedirect, 300
    Checkpoint("StartPostSearchMonitoring: Post-search monitoring started (3 clicks or 20 seconds)", false)
    
    ; Start timers for right-click monitor move feature and overall timeout
    SetTimer, CheckRightClick, 100
    SetTimer, EndRightClickFeature, -20000 ; End the feature after 20 seconds
    
    Success("Script completed patient search successfully. Monitoring for login redirects.", true)
return

; ===== POST-SEARCH LOGIN MONITOR =====
MonitorForLoginRedirect:
    ; Check if we should stop monitoring
    if (!monitoringActive)
    {
        SetTimer, MonitorForLoginRedirect, Off
        Checkpoint("MonitorForLoginRedirect: Monitoring ended, exiting script", false)
        Return()
    }
    
    ; Skip if login is already in progress
    if (loginInProgress)
        return
    
    ; Get active window title
    WinGetActiveTitle, currentTitle
    
    ; Check if it's an iTero-related window
    if (!RegExMatch(currentTitle, iTeroAnyWindowTitle))
        return ; Not an iTero window, ignore
    
    ; Check for login redirect (Welcome page)
    if (RegExMatch(currentTitle, iTeroWelcomeWindowTitle))
    {
        Checkpoint("MonitorForLoginRedirect: Login redirect detected! Title: " . currentTitle, false)
        loginInProgress := true
        
        ; Handle the login (flag is already false since we're in post-search phase)
        GoSub, HandleLogin
        
        loginInProgress := false
        Checkpoint("MonitorForLoginRedirect: Returned from HandleLogin, continuing monitoring", false)
    }
    
    ; Check if we've reached 3 clicks
    if (postSearchClickCount >= 3)
    {
        Checkpoint("MonitorForLoginRedirect: 3 clicks detected, ending monitoring", false)
        monitoringActive := false
        ; Next cycle will clean up and exit
    }
return

; ===== CLICK TRACKING =====
~LButton::
    ; EXISTING FEATURE: Long-click search field for first initial search
    if (monitoringForiTeroSearchFieldLongClick)
    {
        SetTimer, RemoveToolTip, -0
        monitoringForiTeroSearchFieldLongClick := false
        KeyWait, LButton, T1
        
        if (ErrorLevel) ; Button was held for 1+ second = long click
        {
            ; Long click - do first initial search
            WinGetActiveTitle, currentTitle
            if (RegExMatch(currentTitle, myPatientsWindowTitle))
            {
                SendInput, ^a ; Select all
                SendInput, % LastName . ", " . FirstInitial . "{Enter}"
            }
        }
        
        ; Both short and long click lead here - switch to right-click feature
        ShowTooltipAtCursor("Long press right click to move Chrome to right monitor", 4000)
        return ; Don't count this as a post-search click
    }
    
    ; NEW FEATURE: Track post-search clicks for monitoring timeout
    if (monitoringActive && !loginInProgress)
    {
        ; Check if click is on iTero-related window
        WinGetActiveTitle, currentTitle
        if (RegExMatch(currentTitle, iTeroAnyWindowTitle))
        {
            ; Check if it's a short click (not held down)
            KeyWait, LButton, T0.5
            if (!ErrorLevel) ; Released within 0.5 sec = short click
            {
                postSearchClickCount++
                remainingClicks := 3 - postSearchClickCount
                Checkpoint("Click tracking: Post-search click #" . postSearchClickCount . " detected. " . remainingClicks . " clicks remaining.", false)
                
                if (postSearchClickCount >= 3)
                    Checkpoint("Click tracking: 3 clicks reached, monitoring will end soon", false)
            }
        }
    }
return

; ===== TIMERS =====

CheckRightClick:
    if (GetKeyState("RButton", "P"))
    {
        KeyWait, RButton, T1
        if (!ErrorLevel) ; If the button was released within 1 second, do nothing
            return
        
        ; If we get here, the button was held for 1 second - move window and exit
        
        ; Stop all timers and remove tooltip
        SetTimer, CheckRightClick, Off
        SetTimer, EndRightClickFeature, Off
        SetTimer, MonitorForLoginRedirect, Off
        SetTimer, UpdateToolTipPosition, Off
        ToolTip ; Remove tooltip immediately
        
        ; Moves Chrome to the right monitor using window width
        WinGet, activeWindow, ID, A
        WinGetPos, , , windowWidth, , ahk_id %activeWindow%
        WinRestore, ahk_id %activeWindow%
        WinMove, ahk_id %activeWindow%,, %windowWidth%, 0
        WinMaximize, ahk_id %activeWindow%
        
        ; Done - exit script
        Checkpoint("iTero window moved to right monitor. Script complete.`n`n", false)
        Return()
    }
return

EndRightClickFeature:
    Checkpoint("EndRightClickFeature: 20 seconds elapsed", false)
    
    ; Check if login is in progress - if so, wait for it to complete
    if (loginInProgress)
    {
        Checkpoint("EndRightClickFeature: Login in progress, waiting for completion...", false)
        ; Reschedule to check again in 1 second
        SetTimer, EndRightClickFeature, -1000
        return
    }
    
    ; Stop post-search monitoring
    monitoringActive := false
    Checkpoint("EndRightClickFeature: Closing script after timeout`n`n", false)
Return()

; Function to update tooltip position
UpdateToolTipPosition:
    MouseGetPos, mouseX, mouseY
    ToolTip, %currentTooltipMessage%, mouseX+10, mouseY+10
return

; Function to remove the tooltip
RemoveToolTip:
    ToolTip ; Remove the tooltip
    SetTimer, UpdateToolTipPosition, Off ; Turn off the position update timer
return

