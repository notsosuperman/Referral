; ==============================================================================
; Cain Denture Center Referral Slip - AHK v1
; Based on Open Dental Sheet XML Export
; SPECIALIST_NAME: Denturist - Cain Denture Center
; FORM_NAME: CainDentureCenter
; WINDOW_TITLE: Referral - Denturist - Cain Denture Center
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
global OfficeName := "Cain Denture Center"
global PatientName := ""  ; Will be set when form is launched

; GUI Control variables (required for GuiControl updates)
global TxtOfficeName := ""
global TxtPatientName := ""

; User-editable fields (ReferralSource in header)
global ReferralSource := ""

; Checkboxes (arranged in two columns)
global chkDentureReline := 0
global chkFullDentures := 0
global chkPartialDentures := 0
global chkImplantSupportedDentures := 0
global chkOther := 0
global txtOther := ""
global chkDentureRepair := 0
global chkImmediateDentures := 0
global chkReplacementDentures := 0

; Sending radiographs (xray options)
global chkSendingFMX := 0
global chkSendingPA := 0
global chkSendingPANO := 0
global chkSendingCHART := 0

; Remarks
global txtRemarks := ""  ; Multiline

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
    formWidth := 580
    FT_BuildHeader(yPos, formWidth)
    
    ; ===========================================================================
    ; Checkboxes (two columns)
    ; ===========================================================================
    Gui, Main:Font, s10 Bold Italic Underline, Arial
    Gui, Main:Add, Text, x20 y%yPos% w200, Treatment Options:
    
    Gui, Main:Font, s10 Normal, Arial
    yPos += 22
    colRight := 300
    ; Column 1: Denture Reline
    Gui, Main:Add, CheckBox, x20 y%yPos% w250 vchkDentureReline, Denture Reline
    ; Column 2: Denture Repair
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w250 vchkDentureRepair, Denture Repair
    
    yPos += 22
    ; Column 1: Full Dentures
    Gui, Main:Add, CheckBox, x20 y%yPos% w250 vchkFullDentures, Full Dentures
    ; Column 2: Immediate Dentures
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w250 vchkImmediateDentures, Immediate Dentures
    
    yPos += 22
    ; Column 1: Partial Dentures
    Gui, Main:Add, CheckBox, x20 y%yPos% w250 vchkPartialDentures, Partial Dentures
    ; Column 2: Replacement Dentures
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w250 vchkReplacementDentures, Replacement Dentures
    
    yPos += 22
    ; Column 1: Implant Supported Dentures
    Gui, Main:Add, CheckBox, x20 y%yPos% w250 vchkImplantSupportedDentures, Implant Supported Dentures
    
    yPos += 22
    ; Column 1: Other (with text box spanning both columns)
    Gui, Main:Add, CheckBox, x20 y%yPos% w70 vchkOther, Other:
    Gui, Main:Add, Edit, x92 y%yPos% w468 h22 vtxtOther, %txtOther%
    
    ; ===========================================================================
    ; Sending radiographs
    ; ===========================================================================
    yPos += 35
    Gui, Main:Add, Text, x20 y%yPos% w540 h2 +0x10
    
    yPos += 8
    Gui, Main:Font, s10 Bold Italic Underline, Arial
    Gui, Main:Add, Text, x20 y%yPos% w200, Sending radiographs:
    
    Gui, Main:Font, s10 Normal, Arial
    yPos += 22
    Gui, Main:Add, CheckBox, x20 y%yPos% w100 vchkSendingFMX, FMX
    Gui, Main:Add, CheckBox, x130 y%yPos% w100 vchkSendingPA, PA
    Gui, Main:Add, CheckBox, x240 y%yPos% w100 vchkSendingPANO, Pano
    Gui, Main:Add, CheckBox, x350 y%yPos% w100 vchkSendingCHART, Chart
    
    ; ===========================================================================
    ; Remarks
    ; ===========================================================================
    yPos += 35
    Gui, Main:Add, Text, x20 y%yPos% w540 h2 +0x10
    
    yPos += 8
    Gui, Main:Font, s10 Bold Italic Underline, Arial
    Gui, Main:Add, Text, x20 y%yPos% w200, Remarks:
    
    Gui, Main:Font, s10 Normal, Arial
    yPos += 22
    Gui, Main:Add, Edit, x20 y%yPos% w540 h100 Multi vtxtRemarks, %txtRemarks%
    
    ; ===========================================================================
    ; Action Buttons
    ; ===========================================================================
    yPos += 110  ; Remarks edit box height (100) + spacing (10)
    Gui, Main:Add, Text, x20 y%yPos% w540 h2 +0x10
    
    yPos += 10
    Gui, Main:Font, s10 Bold, Arial
    Gui, Main:Add, Button, x20 y%yPos% w100 h35 gBtnClearForm, Clear Form
    Gui, Main:Add, Button, x440 y%yPos% w120 h35 gBtnSubmit Default, Submit Referral
    
    ; Calculate window height (buttons are at yPos with height 35, so bottom is yPos + 35)
    ; Add minimal padding (15 pixels) below buttons
    winHeight := yPos + 50
    Gui, Main:Show, w580 h%winHeight%
}

; ==============================================================================
; Include Standard Handlers
; ==============================================================================
#Include %A_ScriptDir%\..\Lib\FormHandlers.ahk
