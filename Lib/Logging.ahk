; ==============================================================================
; Logging Library - Debug logging for automation scripts
; Include: #Include %A_ScriptDir%\..\Lib\Logging.ahk
; ==============================================================================

; ==============================================================================
; Configuration
; ==============================================================================
global LOG_TO_CONSOLE := true  ; Show ToolTips for debugging
global LOG_TO_FILE := false     ; Write to file (set path below)
global LOG_FILE_PATH := A_ScriptDir . "\..\Logs\referral.log"

; ==============================================================================
; Logging Functions
; ==============================================================================

; Log a checkpoint (progress indicator)
Checkpoint(message, logWindow := true)
{
    if (logWindow)
    {
        WinGetTitle, currentTitle, A
        message := message . " | Window: " . currentTitle
    }
    
    LogEvent("CHECKPOINT", message)
}

; Log a failure (error)
Failure(message, logWindow := true, showMsgBox := true, exitScript := true)
{
    if (logWindow)
    {
        WinGetTitle, currentTitle, A
        message := message . " | Window: " . currentTitle
    }
    
    LogEvent("FAILURE", message)
    
    if (showMsgBox)
        MsgBox, 48, Automation Error, %message%
    
    if (exitScript)
    {
        BlockInput, Off
        BlockInput, MouseMoveOff
        ExitApp
    }
}

; Log a success
Success(message, logWindow := true)
{
    if (logWindow)
    {
        WinGetTitle, currentTitle, A
        message := message . " | Window: " . currentTitle
    }
    
    LogEvent("SUCCESS", message)
}

; Internal: Write log entry
LogEvent(level, message)
{
    global LOG_TO_CONSOLE
    global LOG_TO_FILE
    global LOG_FILE_PATH
    
    FormatTime, timestamp,, yyyy-MM-dd HH:mm:ss
    logLine := timestamp . " [" . level . "] " . message
    
    ; Console output (ToolTip)
    if (LOG_TO_CONSOLE)
    {
        ToolTip, %logLine%
        SetTimer, RemoveLogTooltip, -2000
    }
    
    ; File output
    if (LOG_TO_FILE)
    {
        ; Create directory if needed
        SplitPath, LOG_FILE_PATH,, logDir
        if (!InStr(FileExist(logDir), "D"))
            FileCreateDir, %logDir%
        
        FileAppend, %logLine%`n, %LOG_FILE_PATH%
    }
}

RemoveLogTooltip:
    ToolTip
return
