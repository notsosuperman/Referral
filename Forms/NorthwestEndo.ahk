; ==============================================================================
; Northwest Endodontics Referral Slip - AHK v1
; Based on Open Dental Sheet XML Export
; SPECIALIST_NAME: Endo - Northwest Endodontics
; FORM_NAME: NorthwestEndo
; WINDOW_TITLE: Referral - Endo - Northwest Endodontics
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
global OfficeName := "Northwest Endodontics"
global PatientName := ""  ; Will be set when form is launched

; GUI Control variables (required for GuiControl updates)
global TxtOfficeName := ""
global TxtPatientName := ""

; User-editable fields (ReferralSource in header)
global ReferralSource := ""

; Tooth/Teeth/Area
global txtToothTeethArea := ""

; Check all that apply (Symptoms/Conditions)
global chkPreviousRCT := 0
global chkRCTStarted := 0
global chkPulpExposure := 0
global chkPeriapicalLesion := 0
global chkPainInconsistent := 0
global chkPossibleRootFracture := 0
global chkRecentRestoration := 0
global txtRecentRestoration := ""
global chkSwelling := 0
global chkSinusTract := 0
global chkResorption := 0
global chkTempCrown := 0
global chkAntibioticsRxd := 0

; Treatment requested
global chkCBCTScanOnly := 0
global chkExamOnly := 0
global chkRootCanalAsIndicated := 0
global chkRetreatmentAsIndicated := 0
global chkTreatmentOther := 0
global txtTreatmentOther := ""

; Restoration requested
global chkTempFilling := 0
global chkCoreBuildUp := 0
global chkRestoreAccessThroughCrown := 0
global chkLeavePostSpace := 0
global chkPostAndCore := 0

; Your restorative plans
global chkPostCore := 0
global chkCrownBridge := 0
global chkFilling := 0
global chkRestorativeNA := 0

; History/Comments/Special instructions
global txtHistoryComments := ""

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
    ; Tooth/Teeth/Area
    ; ===========================================================================
    Gui, Main:Font, s10 Bold Italic Underline, Arial
    Gui, Main:Add, Text, x20 y%yPos% w200, Tooth/Teeth/Area:
    
    Gui, Main:Font, s10 Normal, Arial
    yPos += 22
    Gui, Main:Add, Edit, x20 y%yPos% w540 h22 vtxtToothTeethArea, %txtToothTeethArea%
    
    ; ===========================================================================
    ; Check all that apply (Symptoms/Conditions)
    ; ===========================================================================
    yPos += 35
    Gui, Main:Add, Text, x20 y%yPos% w540 h2 +0x10
    
    yPos += 8
    Gui, Main:Font, s10 Bold Italic Underline, Arial
    Gui, Main:Add, Text, x20 y%yPos% w200, Check all that apply:
    
    Gui, Main:Font, s10 Normal, Arial
    yPos += 22
    colRight := 300
    Gui, Main:Add, CheckBox, x20 y%yPos% w250 vchkPreviousRCT, Previous RCT
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w250 vchkSwelling, Swelling
    
    yPos += 22
    Gui, Main:Add, CheckBox, x20 y%yPos% w250 vchkRCTStarted, RCT started
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w250 vchkSinusTract, Sinus tract (fistula)
    
    yPos += 22
    Gui, Main:Add, CheckBox, x20 y%yPos% w250 vchkPulpExposure, Pulp exposure
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w250 vchkResorption, Resorption
    
    yPos += 22
    Gui, Main:Add, CheckBox, x20 y%yPos% w250 vchkPeriapicalLesion, Periapical lesion
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w250 vchkTempCrown, Temp crown
    
    yPos += 22
    Gui, Main:Add, CheckBox, x20 y%yPos% w250 vchkPainInconsistent, Pain inconsistent/difficult to localize
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w250 vchkAntibioticsRxd, Antibiotics Rx'd
    
    yPos += 22
    Gui, Main:Add, CheckBox, x20 y%yPos% w250 vchkPossibleRootFracture, Possible root fracture/crack
    
    yPos += 22
    Gui, Main:Add, CheckBox, x20 y%yPos% w250 vchkRecentRestoration, Recent restoration (type/date)
    Gui, Main:Add, Edit, x212 y%yPos% w348 h22 vtxtRecentRestoration, %txtRecentRestoration%
    
    ; ===========================================================================
    ; Treatment requested
    ; ===========================================================================
    yPos += 35
    Gui, Main:Add, Text, x20 y%yPos% w540 h2 +0x10
    
    yPos += 8
    Gui, Main:Font, s10 Bold Italic Underline, Arial
    Gui, Main:Add, Text, x20 y%yPos% w200, Treatment requested:
    
    Gui, Main:Font, s10 Normal, Arial
    yPos += 22
    Gui, Main:Add, CheckBox, x20 y%yPos% w280 vchkCBCTScanOnly, CBCT scan only (includes radiology report)
    
    yPos += 22
    Gui, Main:Add, CheckBox, x20 y%yPos% w280 vchkExamOnly, Exam only
    
    yPos += 22
    Gui, Main:Add, CheckBox, x20 y%yPos% w280 vchkRootCanalAsIndicated, Root canal as indicated
    
    yPos += 22
    Gui, Main:Add, CheckBox, x20 y%yPos% w280 vchkRetreatmentAsIndicated, Retreatment (including apico) as indicated
    
    yPos += 22
    Gui, Main:Add, CheckBox, x20 y%yPos% w70 vchkTreatmentOther, Other:
    Gui, Main:Add, Edit, x77 y%yPos% w483 h22 vtxtTreatmentOther, %txtTreatmentOther%
    
    ; ===========================================================================
    ; Restoration requested
    ; ===========================================================================
    yPos += 35
    Gui, Main:Add, Text, x20 y%yPos% w540 h2 +0x10
    
    yPos += 8
    Gui, Main:Font, s10 Bold Italic Underline, Arial
    Gui, Main:Add, Text, x20 y%yPos% w200, Restoration requested:
    
    Gui, Main:Font, s10 Normal, Arial
    yPos += 22
    Gui, Main:Add, CheckBox, x20 y%yPos% w250 vchkTempFilling, Temp filling
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w250 vchkLeavePostSpace, Leave post space
    
    yPos += 22
    Gui, Main:Add, CheckBox, x20 y%yPos% w250 vchkCoreBuildUp, Core build-up
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w250 vchkPostAndCore, Post and core
    
    yPos += 22
    Gui, Main:Add, CheckBox, x20 y%yPos% w250 vchkRestoreAccessThroughCrown, Restore access through crown
    
    ; ===========================================================================
    ; Your restorative plans
    ; ===========================================================================
    yPos += 35
    Gui, Main:Add, Text, x20 y%yPos% w540 h2 +0x10
    
    yPos += 8
    Gui, Main:Font, s10 Bold Italic Underline, Arial
    Gui, Main:Add, Text, x20 y%yPos% w200, Your restorative plans:
    
    Gui, Main:Font, s10 Normal, Arial
    yPos += 22
    Gui, Main:Add, CheckBox, x20 y%yPos% w120 vchkPostCore, Post/Core
    Gui, Main:Add, CheckBox, x150 y%yPos% w120 vchkCrownBridge, Crown/Bridge
    Gui, Main:Add, CheckBox, x280 y%yPos% w100 vchkFilling, Filling
    Gui, Main:Add, CheckBox, x390 y%yPos% w100 vchkRestorativeNA, N/A
    
    ; ===========================================================================
    ; History/Comments/Special instructions
    ; ===========================================================================
    yPos += 35
    Gui, Main:Add, Text, x20 y%yPos% w540 h2 +0x10
    
    yPos += 8
    Gui, Main:Font, s10 Bold Italic Underline, Arial
    Gui, Main:Add, Text, x20 y%yPos% w400, History/Comments/Special instructions:
    
    Gui, Main:Font, s10 Normal, Arial
    yPos += 22
    Gui, Main:Add, Edit, x20 y%yPos% w540 h100 Multi vtxtHistoryComments, %txtHistoryComments%
    
    ; ===========================================================================
    ; Action Buttons
    ; ===========================================================================
    yPos += 115
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
