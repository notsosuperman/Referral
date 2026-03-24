; ==============================================================================
; Yang Referral Slip - AHK v1
; Based on Open Dental Sheet XML Export
; SPECIALIST_NAME: Perio - Dr. Yang (Wolfe Dental - Cedar Mill)
; FORM_NAME: Yang
; WINDOW_TITLE: Referral - Perio - Dr. Yang (Wolfe Dental - Cedar Mill)
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

; User-editable fields (ReferralSource in header)
global ReferralSource := ""

; Symptoms
global chkPainSwelling := 0
global chkAsymptomatic := 0

; Treatment checkboxes (left column)
global chkPeriodontalEvaluation := 0
global chkPeriodontalTreatment := 0
global chkExtraction := 0
global chkBoneGraft := 0

; Treatment checkboxes (right column)
global chkPeriodontalRetreatment := 0
global chkPeriodontalSurgery := 0
global chkImplant := 0

; Other
global chkOther := 0
global txtOther := ""

; History / Comments / Special instructions
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
    formWidth := 540
    FT_BuildHeader(yPos, formWidth)

    ; ===========================================================================
    ; Symptoms
    ; ===========================================================================
    Gui, Main:Font, s10 Normal, Arial
    Gui, Main:Add, CheckBox, x20 y%yPos% w140 vchkPainSwelling, Pain/Swelling
    Gui, Main:Add, CheckBox, x170 y%yPos% w140 vchkAsymptomatic, Asymptomatic

    ; ===========================================================================
    ; Treatment Options (two columns)
    ; ===========================================================================
    yPos += 35
    Gui, Main:Add, Text, x20 y%yPos% w540 h2 +0x10

    yPos += 8
    Gui, Main:Font, s10 Bold Italic Underline, Arial
    Gui, Main:Add, Text, x20 y%yPos% w200, Treatment Options

    Gui, Main:Font, s10 Normal, Arial
    yPos += 24
    colRight := 290

    Gui, Main:Add, CheckBox, x20 y%yPos% w250 vchkPeriodontalEvaluation, Periodontal Evaluation
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w250 vchkPeriodontalRetreatment, Periodontal Re-treatment

    yPos += 24
    Gui, Main:Add, CheckBox, x20 y%yPos% w250 vchkPeriodontalTreatment, Periodontal Treatment
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w250 vchkPeriodontalSurgery, Periodontal Surgery

    yPos += 24
    Gui, Main:Add, CheckBox, x20 y%yPos% w250 vchkExtraction, Extraction
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w250 vchkImplant, Implant

    yPos += 24
    Gui, Main:Add, CheckBox, x20 y%yPos% w250 vchkBoneGraft, Bone Graft

    ; ===========================================================================
    ; Other
    ; ===========================================================================
    yPos += 28
    Gui, Main:Add, CheckBox, x20 y%yPos% w60 vchkOther, Other:
    Gui, Main:Add, Edit, x82 y%yPos% w478 h22 vtxtOther, %txtOther%

    ; ===========================================================================
    ; History / Comments / Special instructions
    ; ===========================================================================
    yPos += 35
    Gui, Main:Add, Text, x20 y%yPos% w540 h2 +0x10

    yPos += 8
    Gui, Main:Font, s10 Bold Italic Underline, Arial
    Gui, Main:Add, Text, x20 y%yPos% w400, History / Comments / Special instructions:

    Gui, Main:Font, s10 Normal, Arial
    yPos += 24
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
