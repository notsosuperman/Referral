# Open Dental Navigation Automation Plan

## Overview
Automate navigation from referral form submission to Open Dental "Fill Sheet" window, with patient validation and error handling.

## Architecture

### New Libraries
1. **Lib/ODAutomation.ahk** - Open Dental window management and navigation
2. **Lib/Logging.ahk** - Debug logging (Checkpoint/Failure/Success)

### Data Flow
```
Launcher (captures OD window + patient)
    ↓
Referral Form (displays patient, stores OD window title)
    ↓
Submit → ODNavigate() → FormTransfer()
```

## Navigation Steps

### Pre-Submit: Launcher
1. Detect if Open Dental main window is active: `"Open Dental {username} - LastName, FirstName..."`
2. Parse patient name from title
3. Pass to form: `Run, "form.ahk" "patientName" "fullODTitle" "presetName"`

### On Submit: Navigate to Fill Sheet
```ahk
ODNavigate(odWindowTitle, specialistName)
{
    1. BlockInput On
    2. Checkpoint: "Starting navigation"
    
    3. ODWinActivate(odWindowTitle)
       - WinActivate Open Dental main
       - Check for blocking windows (other ahk_exe OpenDental.exe)
       - If blocking: Failure + exit
    
    4. ValidateChartView()
       - GetODMode() must return "Chart"
       - If not: SetODMode("Chart")
    
    5. ScrollPatientInfoToTop()
       - Click CLIENT: 451, 579
    
    6. ClickAt(OD_REFERRED_FROM, "Open Referrals")
       - DoubleClick CLIENT: 100, 642
    
    7. WaitForWindow("Referrals for Patient", 3, "Referrals window")
    
    8. ClickAt(REF_REFER_TO_BTN, "Click Refer To")
       - Click CLIENT: 62, 81
    
    9. WaitForWindow("Referrals", 3, "Referral search")
    
    10. SendInput specialistName
    
    11. ClickAt(REF_FIRST_RESULT, "Select specialist")
        - Click CLIENT: 77, 107
    
    12. Send Alt+O (OK button)
    
    13. WaitForWindow("Referrals for Patient", 3, "Confirm selection")
    
    14. ClickAt(REF_SLIP_BTN, "Open Referral Slip")
        - Click CLIENT: 61, 475
    
    15. WaitForWindow("Fill Sheet", 3, "Fill Sheet window")
    
    16. Checkpoint: "Navigation complete"
    17. BlockInput Off
    18. return true
}
```

## Coordinate Definitions
```ahk
; Open Dental - Patient Info
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
```

## Library Functions

### Lib/ODAutomation.ahk
```ahk
ODNavigate(odWindowTitle, specialistName)  ; Main navigation function
ODWinActivate(expectedTitle)  ; Activate OD main, check for blocking windows
GetODMode()  ; Detect Chart/Appt/etc view (from Combo Master)
SetODMode(mode)  ; Switch to Chart/Appt/etc (from Combo Master)
ValidateChartView()  ; Ensure chart view active
UnfocusImagingModeFrame()  ; Handle imaging mode focus (from Combo Master)
ClickAt(coordObj, description)  ; Click + log
WaitForWindow(title, timeout, description)  ; Wait + log + error handling
```

### Lib/Logging.ahk
```ahk
Checkpoint(message, logWindow := true)  ; Log progress
Failure(message, logWindow := true, showMsgBox := true, exitScript := true)  ; Log error
Success(message, logWindow := true)  ; Log success
LogEvent(logFile, message)  ; Write to file
```

## Command-Line Arguments

### Current Usage (Launcher → Form)
```ahk
; Option 1: Three separate args
Run, "form.ahk" "Smith, John" "Open Dental {...}" "Wisdom Teeth"
A_Args[1] = patientName
A_Args[2] = odWindowTitle
A_Args[3] = presetName (optional)

; Option 2: Delimited string (if spaces cause issues)
Run, "form.ahk" "Smith, John|Open Dental {...}|Wisdom Teeth"
```

### Open Dental Program Link Pattern
See `Resources\iTeroClick.ahk` for reference.

**Setup in Open Dental:**
```
Main Menu → Setup → Program Links → Add
  Description: Referral Form
  Path to exe: C:\Path\To\AutoHotkey.exe
  Command Line: "C:\Path\To\Forms\HillsboroOMFS.ahk" "[LName]" "[FName]"
  
  Available placeholders:
    [LName] - Last name
    [FName] - First name
    [NameFL] - Full name (First Last)
    [ChartNumber] - Patient chart number
    [WirelessPhone] - Cell phone
    [PatNum] - Patient ID
```

**In form script:**
```ahk
; Parse OD bridge arguments
if (A_Args.Length() >= 2)
{
    lastName := A_Args[1]
    firstName := A_Args[2]
    SetPatientName(lastName . ", " . firstName)
}
```

## Error Handling

### Blocking Windows
- If other `ahk_exe OpenDental.exe` window detected when activating main window
- Show user-friendly error: "Please close the [WindowTitle] window and try again"
- Exit cleanly

### Timeouts
- All `WaitForWindow()` calls have 3-second timeout
- On timeout: `Failure("Window [title] did not appear within 3 seconds")`
- User sees MsgBox, script exits

### Mode Detection Failure
- If `GetODMode()` returns nothing
- `Failure("Could not detect Open Dental mode. Ensure Chart view is visible")`

## Debug Logging
All steps log to console via Checkpoint/Failure/Success for now.
File logging optional (can add later if needed).

## Testing Plan
1. Test with blocking window (should fail gracefully)
2. Test with wrong OD mode (should switch to Chart)
3. Test timeout scenarios
4. Test full end-to-end automation
