; ==============================================================================
; Screenshot Helper - Takes screenshot of a target AHK script's window
; Usage: ScreenshotHelper.ahk [ScriptName.ahk]
; Example: ScreenshotHelper.ahk NorthwestPerio.ahk
; If no argument provided, defaults to HillsboroOMFS.ahk
; ==============================================================================
#NoEnv
#SingleInstance, Force
SetWorkingDir %A_ScriptDir%

; Get target script from command line argument, or use default
targetScript := A_Args[1] ? A_Args[1] : "HillsboroOMFS.ahk"

; Prepend Forms directory if the script doesn't contain a path
if !InStr(targetScript, "\")
    targetScript := "..\Forms\" . targetScript

screenshotPath := A_ScriptDir . "\..\screenshot.png"

; Parse the target script to find WINDOW_TITLE
windowTitle := ""
FileRead, scriptContent, %targetScript%
Loop, Parse, scriptContent, `n, `r
{
    if InStr(A_LoopField, "WINDOW_TITLE:")
    {
        ; Extract the window title after "WINDOW_TITLE:"
        windowTitle := RegExReplace(A_LoopField, "^.*WINDOW_TITLE:\s*", "")
        break
    }
}

; Run the target script
Run, %targetScript%

; Wait for the window to appear (timeout after 5 seconds)
if (windowTitle != "")
{
    WinWait, %windowTitle%,, 5
    if !ErrorLevel
    {
        ; Give it a moment to fully render
        Sleep, 500
        
        ; Activate the window
        WinActivate, %windowTitle%
        Sleep, 200
        
        ; Get window position and size
        WinGetPos, X, Y, W, H, %windowTitle%
        
        ; Take screenshot of the window
        CaptureScreen(X, Y, W, H, screenshotPath)
        
        ; Close the target window
        WinClose, %windowTitle%
    }
}

ExitApp

; ==============================================================================
; Screenshot Function using GDI+
; ==============================================================================
CaptureScreen(x, y, w, h, filePath)
{
    ; Initialize GDI+
    pToken := Gdip_Startup()
    
    ; Create bitmap
    pBitmap := Gdip_BitmapFromScreen(x "|" y "|" w "|" h)
    
    ; Save to file
    Gdip_SaveBitmapToFile(pBitmap, filePath)
    
    ; Cleanup
    Gdip_DisposeImage(pBitmap)
    Gdip_Shutdown(pToken)
}

; ==============================================================================
; GDI+ Functions (minimal implementation)
; ==============================================================================
Gdip_Startup()
{
    if !DllCall("GetModuleHandle", "str", "gdiplus", "UPtr")
        DllCall("LoadLibrary", "str", "gdiplus")
    VarSetCapacity(si, A_PtrSize = 8 ? 24 : 16, 0)
    NumPut(1, si, 0, "UInt")
    DllCall("gdiplus\GdiplusStartup", "UPtr*", pToken, "UPtr", &si, "UPtr", 0)
    return pToken
}

Gdip_Shutdown(pToken)
{
    DllCall("gdiplus\GdiplusShutdown", "UPtr", pToken)
}

Gdip_BitmapFromScreen(screen)
{
    ; Parse coordinates
    StringSplit, S, screen, |
    x := S1, y := S2, w := S3, h := S4
    
    ; Create compatible DC and bitmap
    hdc := DllCall("GetDC", "UPtr", 0, "UPtr")
    hbm := DllCall("CreateCompatibleBitmap", "UPtr", hdc, "Int", w, "Int", h, "UPtr")
    hdc2 := DllCall("CreateCompatibleDC", "UPtr", hdc, "UPtr")
    obm := DllCall("SelectObject", "UPtr", hdc2, "UPtr", hbm, "UPtr")
    
    ; Copy screen to bitmap
    DllCall("BitBlt", "UPtr", hdc2, "Int", 0, "Int", 0, "Int", w, "Int", h
        , "UPtr", hdc, "Int", x, "Int", y, "UInt", 0x00CC0020)
    
    ; Create GDI+ bitmap from HBITMAP
    DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "UPtr", hbm, "UPtr", 0, "UPtr*", pBitmap)
    
    ; Cleanup
    DllCall("SelectObject", "UPtr", hdc2, "UPtr", obm)
    DllCall("DeleteObject", "UPtr", hbm)
    DllCall("DeleteDC", "UPtr", hdc2)
    DllCall("ReleaseDC", "UPtr", 0, "UPtr", hdc)
    
    return pBitmap
}

Gdip_SaveBitmapToFile(pBitmap, filePath)
{
    ; Get PNG encoder CLSID
    VarSetCapacity(CLSID, 16, 0)
    DllCall("ole32\CLSIDFromString", "WStr", "{557CF406-1A04-11D3-9A73-0000F81EF32E}", "UPtr", &CLSID)
    
    ; Save
    DllCall("gdiplus\GdipSaveImageToFile", "UPtr", pBitmap, "WStr", filePath, "UPtr", &CLSID, "UPtr", 0)
}

Gdip_DisposeImage(pBitmap)
{
    DllCall("gdiplus\GdipDisposeImage", "UPtr", pBitmap)
}
