; ==============================================================================
; Oregon Periodontics Referral Slip - AHK v1
; Based on Open Dental Sheet XML Export
; SPECIALIST_NAME: Perio - Oregon Periodontics
; FORM_NAME: OregonPeriodontics
; WINDOW_TITLE: Referral - Perio - Oregon Periodontics
; TIER: additional
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
global OfficeName := "Oregon Periodontics"
global PatientName := ""  ; Will be set when form is launched

; GUI Control variables (required for GuiControl updates)
global TxtOfficeName := ""
global TxtPatientName := ""

; User-editable fields (ReferralSource in header)
global ReferralSource := ""

; Referral options with text fields
global chkDentalImplants := 0
global txtDentalImplants := ""
global chkMicrosurgicalExtraction := 0
global chkAnteriorCustomProvisional := 0
global chkRootCoverageProcedure := 0
global txtRootCoverageProcedure := ""
global chkCrownLengthening := 0
global txtCrownLengthening := ""
global chkPeriodontalPockets := 0
global txtPeriodontalPockets := ""
global chkOther := 0
global txtOther := ""

; Comments
global txtComments := ""  ; Multiline

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
    ; Dental Implants
    ; ===========================================================================
    Gui, Main:Font, s10 Normal, Arial
    Gui, Main:Add, CheckBox, x20 y%yPos% w180 vchkDentalImplants, Dental Implants #
    Gui, Main:Add, Edit, x155 y%yPos% w405 h22 vtxtDentalImplants, %txtDentalImplants%
    
    yPos += 30
    Gui, Main:Add, CheckBox, x40 y%yPos% w400 vchkMicrosurgicalExtraction, Microsurgical Extraction / Immediate placement
    
    yPos += 24
    Gui, Main:Add, CheckBox, x40 y%yPos% w250 vchkAnteriorCustomProvisional, Anterior Custom Provisional
    
    ; ===========================================================================
    ; Root Coverage Procedure
    ; ===========================================================================
    yPos += 35
    Gui, Main:Add, CheckBox, x20 y%yPos% w220 vchkRootCoverageProcedure, Recession/root coverage #
    Gui, Main:Add, Edit, x200 y%yPos% w360 h22 vtxtRootCoverageProcedure, %txtRootCoverageProcedure%
    
    ; ===========================================================================
    ; Crown Lengthening
    ; ===========================================================================
    yPos += 35
    Gui, Main:Add, CheckBox, x20 y%yPos% w180 vchkCrownLengthening, Crown Lengthening #
    Gui, Main:Add, Edit, x165 y%yPos% w395 h22 vtxtCrownLengthening, %txtCrownLengthening%
    
    ; ===========================================================================
    ; Periodontal Pockets
    ; ===========================================================================
    yPos += 35
    Gui, Main:Add, CheckBox, x20 y%yPos% w180 vchkPeriodontalPockets, Periodontal Pockets
    Gui, Main:Add, Edit, x162 y%yPos% w398 h22 vtxtPeriodontalPockets, %txtPeriodontalPockets%
    
    ; ===========================================================================
    ; Other
    ; ===========================================================================
    yPos += 35
    Gui, Main:Add, CheckBox, x20 y%yPos% w50 vchkOther, Other
    Gui, Main:Add, Edit, x80 y%yPos% w480 h22 vtxtOther, %txtOther%
    
    ; ===========================================================================
    ; Comments
    ; ===========================================================================
    yPos += 35
    Gui, Main:Add, Text, x20 y%yPos% w540 h2 +0x10
    
    yPos += 8
    Gui, Main:Font, s10 Bold Italic Underline, Arial
    Gui, Main:Add, Text, x20 y%yPos% w200, Comments:
    
    Gui, Main:Font, s10 Normal, Arial
    yPos += 24
    Gui, Main:Add, Edit, x20 y%yPos% w540 h100 Multi vtxtComments, %txtComments%
    
    ; ===========================================================================
    ; Action Buttons
    ; ===========================================================================
    yPos += 110  ; Comments edit box height (100) + spacing (10)
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
