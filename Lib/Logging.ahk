; ==============================================================================
; Logging Library for Dental Referral Automation
; Provides debug logging, checkpoints, and error handling
; ==============================================================================

; ==============================================================================
; Configuration
; ==============================================================================
global LOG_PATH := A_ScriptDir . "\..\Logs"
global LOG_FILE := LOG_PATH . "\referral.log"
global LOG_FAILURES_FILE := LOG_PATH . "\referral_failures.log"

; ==============================================================================
; Ensure log directory exists
; ==============================================================================
if (!InStr(FileExist(LOG_PATH), "D"))
    FileCreateDir, %LOG_PATH%

; ==============================================================================
; LogEvent - Write timestamped entry to log file
; ==============================================================================
LogEvent(logFile, message)
{
    FormatTime, timestamp,, yyyy-MM-dd HH:mm:ss
    computerName := A_ComputerName
    FileAppend, %timestamp% | %computerName% | %message%`n, %logFile%
}

; ==============================================================================
; Checkpoint - Log progress point
; logWindow: if true, appends current window title to message
; ==============================================================================
Checkpoint(message, logWindow := true)
{
    global LOG_FILE
    
    if (logWindow)
    {
        WinGetTitle, currentTitle, A
        message := message . " | Window: " . currentTitle
    }
    
    LogEvent(LOG_FILE, "CHECKPOINT: " . message)
}

; ==============================================================================
; Failure - Log failure, optionally show message box and/or exit
; ==============================================================================
Failure(message, logWindow := true, showMsgBox := true, exitScript := true)
{
    global LOG_FILE
    global LOG_FAILURES_FILE
    
    ; Unblock input before showing error
    BlockInput, Off
    BlockInput, MouseMoveOff
    
    if (logWindow)
    {
        WinGetTitle, currentTitle, A
        message := message . " | Window: " . currentTitle
    }
    
    LogEvent(LOG_FAILURES_FILE, message)
    LogEvent(LOG_FILE, "FAILURE: " . message)
    
    if (showMsgBox)
        MsgBox, 48, Referral Error, %message%
    
    if (exitScript)
        ExitApp
}

; ==============================================================================
; Success - Log successful completion
; ==============================================================================
Success(message, logWindow := true)
{
    global LOG_FILE
    
    if (logWindow)
    {
        WinGetTitle, currentTitle, A
        message := message . " | Window: " . currentTitle
    }
    
    LogEvent(LOG_FILE, "SUCCESS: " . message)
}

; ==============================================================================
; DebugLog - Simple debug message (always logs, no window info)
; ==============================================================================
DebugLog(message)
{
    global LOG_FILE
    LogEvent(LOG_FILE, "DEBUG: " . message)
}
