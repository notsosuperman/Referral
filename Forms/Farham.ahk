; ==============================================================================
; Farham Referral Slip - AHK v1
; Based on Open Dental Sheet XML Export
; SPECIALIST_NAME: Endo - Wolfe Dental Cedar Mill
; FORM_NAME: Farham
; WINDOW_TITLE: Referral - Endo - Wolfe Dental Cedar Mill
; ==============================================================================
#NoEnv
#SingleInstance, Force
SetWorkingDir %A_ScriptDir%

; Include FormTransfer library
#Include %A_ScriptDir%\..\Lib\FormTransfer.ahk

; ==============================================================================
; Global Variables for Form Data
; ==============================================================================
; Display only (set externally, not editable)
global OfficeName := "Wolfe Dental"
global PatientName := ""  ; Will be set when form is launched

; GUI Control variables (required for GuiControl updates)
global TxtOfficeName := ""
global TxtPatientName := ""

; User-editable fields
global ReferralSource := ""

; Notes field
global txtNotes := ""

; CBCT question
global chkCBCTYes := 0
global chkCBCTNo := 0

; PA question
global chkPAYes := 0
global chkPANo := 0

; ==============================================================================
; Build the GUI
; ==============================================================================
BuildReferralForm()
InitPresets()
return

BuildReferralForm()
{
    ; Get specialist name for window title
    specialistName := PS_GetSpecialistName()
    windowTitle := "Referral - " . specialistName
    
    ; Set GUI defaults (non-resizable, size calculated at end)
    Gui, Main:New, , %windowTitle%
    Gui, Main:Color, FFFFFF
    Gui, Main:Font, s11, Arial
    
    ; Build standard header (modifies yPos by reference)
    yPos := 20
    formWidth := 400
    FT_BuildHeader(yPos, formWidth)
    
    ; ===========================================================================
    ; For Treatment Including (Notes)
    ; ===========================================================================
    Gui, Main:Font, s10 Bold Italic Underline, Arial
    Gui, Main:Add, Text, x20 y%yPos% w200, For Treatment Including
    
    Gui, Main:Font, s10 Normal, Arial
    yPos += 24
    Gui, Main:Add, Edit, x20 y%yPos% w400 h80 Multi vtxtNotes, %txtNotes%
    
    ; ===========================================================================
    ; CBCT Question
    ; ===========================================================================
    yPos += 95
    Gui, Main:Add, Text, x20 y%yPos% w400 h2 +0x10
    
    yPos += 10
    Gui, Main:Font, s10 Normal, Arial
    Gui, Main:Add, Text, x20 y%yPos% w150 h22 +0x200, Was a CBCT taken?
    Gui, Main:Add, CheckBox, x180 y%yPos% w50 vchkCBCTYes, Y
    Gui, Main:Add, CheckBox, x240 y%yPos% w50 vchkCBCTNo, N
    
    ; ===========================================================================
    ; PA Question
    ; ===========================================================================
    yPos += 28
    Gui, Main:Add, Text, x20 y%yPos% w150 h22 +0x200, Was PA taken?
    Gui, Main:Add, CheckBox, x180 y%yPos% w50 vchkPAYes, Y
    Gui, Main:Add, CheckBox, x240 y%yPos% w50 vchkPANo, N
    
    ; ===========================================================================
    ; Action Buttons
    ; ===========================================================================
    yPos += 40
    Gui, Main:Add, Text, x20 y%yPos% w400 h2 +0x10
    
    yPos += 10
    Gui, Main:Font, s10 Bold, Arial
    Gui, Main:Add, Button, x20 y%yPos% w100 h35 gBtnClearForm, Clear Form
    Gui, Main:Add, Button, x300 y%yPos% w120 h35 gBtnSubmit Default, Submit Referral
    
    ; Calculate window height (buttons are at yPos with height 35, so bottom is yPos + 35)
    ; Add minimal padding (15 pixels) below buttons
    winHeight := yPos + 50
    ; Show the GUI
    Gui, Main:Show, w440 h%winHeight%
}

; ==============================================================================
; Include Standard Handlers
; ==============================================================================
#Include %A_ScriptDir%\..\Lib\FormHandlers.ahk
