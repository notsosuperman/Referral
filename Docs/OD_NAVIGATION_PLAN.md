# Open Dental Navigation Automation Plan

## Overview

Automate the navigation from Open Dental main window to the "Fill Sheet" referral form, including patient context validation and debug logging.

---

## Requirements

### Launcher Startup
1. Check if Open Dental is active window
2. If Cursor (or other) is active: show tooltip "Activate Open Dental, then press F1", wait for F1
3. Capture OD window title: `"Open Dental {username} - LastName, FirstName..."`
4. Parse patient name from title
5. Pass to form: `patientName`, `odWindowTitle`, `presetName` (optional)

### Form Submit Navigation
1. **Block input** at start of automation
2. **Validate OD title** matches what launcher captured
3. **Check for blocking sub-windows** - if any, quit with user-friendly error
4. **Ensure Chart view** is active (not Appts/Imaging/etc)
5. **Navigate to Fill Sheet:**
   - Scroll Patient Info to top
   - Double-click "Referred from"
   - Wait for "Referrals for Patient" window
   - Click "Refer to" button
   - Wait for "Referrals" window
   - Type SPECIALIST_NAME
   - Click first result
   - Alt+O to confirm
   - Wait for "Referrals for Patient" again
   - Click "Referral Slip" button
   - Wait for "Fill Sheet" window
6. **Proceed with FormTransfer** field filling
7. **Unblock input** at end

### Standalone Form Testing
- Forms must work without command-line arguments
- If no args, skip OD validation and use manual F1 wait (existing behavior)

### Logging
- Log file at configurable path
- Checkpoint() for progress
- Failure() for errors (with optional MsgBox and exit)
- Success() for completion
- Include window title in logs

---

## Coordinate Configuration

All click locations defined as variables at top of ODAutomation.ahk:

```ahk
; Patient Info Panel (main OD window)
global OD_PATIENT_SCROLLBAR := {x: 451, y: 579}
global OD_REFERRED_FROM := {x: 100, y: 642}

; "Referrals for Patient" window
global REF_REFER_TO_BTN := {x: 62, y: 81}
global REF_SLIP_BTN := {x: 61, y: 475}

; "Referrals" search window
global REF_FIRST_RESULT := {x: 77, y: 107}
```

---

## Library Structure

```
Lib/
├── FormTransfer.ahk      # Existing (transfer + presets) - will add navigation
├── ODAutomation.ahk      # NEW: OD window management, navigation, click helpers
└── Logging.ahk           # NEW: Checkpoint/Failure/Success/LogEvent
```

### Logging.ahk Functions
```ahk
LogEvent(logFile, message)           ; Write timestamped entry to log
Checkpoint(message, logWindow)       ; Log progress point
Failure(message, logWindow, showMsgBox, exitScript)  ; Log failure, optionally show/exit
Success(message, logWindow)          ; Log success
```

### ODAutomation.ahk Functions
```ahk
; Input blocking
BlockInputOn()
BlockInputOff()

; Window management
ODActivateMain(expectedTitle)        ; Activate OD, check for blocking windows
ODHasBlockingWindow()                ; Check if sub-window is blocking
ODGetMode()                          ; Get current mode (Chart/Appt/etc)
ODSetMode(mode)                      ; Switch to mode
ODIsChartView()                      ; Check if chart view active
ODEnsureChartView()                  ; Switch to chart if needed

; Waiting
WaitWin(title, timeout, description) ; Wait for window with logging

; Clicking
ClickAt(coordObj, description, doubleClick := false)  ; Click with logging
```

---

## Data Flow

### Launcher Startup
```
Launcher starts
    |
    v
Is OD active? ----No----> Show tooltip "Activate OD, press F1"
    |                              |
   Yes                         Wait for F1
    |                              |
    v                              v
Capture OD window title <----------+
    |
    v
Parse patient name: "Open Dental {user} - Smith, John..." -> "Smith, John"
    |
    v
User clicks specialist button
    |
    v
Run form.ahk "Smith, John" "Open Dental {user} - Smith, John" "PresetName"
             ^^^^^^^^^^^^^  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^     ^^^^^^^^^^^
              A_Args[1]              A_Args[2]                  A_Args[3]
```

### Form Startup
```
Form receives args
    |
    v
A_Args[1] = patientName (or preset name if no patient)
A_Args[2] = odWindowTitle (optional)
A_Args[3] = presetName (optional)
    |
    v
If A_Args[2] exists:
    - Store odWindowTitle for validation
    - Use A_Args[1] as patientName
    - Use A_Args[3] as presetName (or "Default")
Else:
    - Standalone mode
    - Use A_Args[1] as presetName (existing behavior)
    - Skip OD validation on submit
```

### Form Submit
```
User clicks Submit
    |
    v
Validate form fields
    |
    v
If odWindowTitle was passed:
    |
    v
BlockInputOn()
    |
    v
Activate OD main window
    |
    v
Check title matches ----No----> Failure("Patient changed!")
    |
   Yes
    v
Check for blocking windows ----Yes----> Failure("Close sub-window first")
    |
   No
    v
Ensure Chart view
    |
    v
Navigate to Fill Sheet (with logging at each step)
    |
    v
FormTransfer fills fields
    |
    v
BlockInputOff()
    |
    v
Success!
```

---

## Timeout Handling

- Default timeout: 3 seconds for all window waits
- On timeout: Show warning message with what didn't happen
- Future: Make timeouts configurable/disableable

---

## Implementation Steps

1. Create `Lib/Logging.ahk` with logging functions
2. Create `Lib/ODAutomation.ahk` with:
   - Coordinate variables
   - BlockInputOn/Off
   - ODActivateMain, ODHasBlockingWindow
   - ODGetMode, ODSetMode, ODEnsureChartView
   - WaitWin, ClickAt
3. Update `Launcher.ahk`:
   - OD detection / F1 wait flow
   - Patient name parsing
   - Pass args to forms
4. Update `FormTransfer.ahk`:
   - Include new libraries
   - Add NavigateToFillSheet() function
   - Update FormTransfer() to call navigation first
   - Handle standalone mode (no args)
5. Test with screenshot helper and manual testing
6. Update README with new library documentation

---

## Command-Line Bridge Pattern (for future scripts)

The Open Dental Program Link passes `[LName] [FName]` as command-line arguments.

**Reusable pattern:**
```ahk
; At script start
if (A_Args.Length() < 2)
{
    ; No args - manual/test mode
    ; Show tooltip, wait for user to activate OD + press F1
}
else
{
    LastName := A_Args[1]
    FirstName := A_Args[2]
    ; Additional args as needed
}
```

This pattern should be documented in README for easy reuse in future scripts.
