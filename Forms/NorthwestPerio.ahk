; ==============================================================================
; Northwest Periodontics Referral Slip - AHK v1
; Based on Open Dental Sheet XML Export
; SPECIALIST_NAME: Perio - Northwest Periodontics
; FORM_NAME: NorthwestPerio
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
global OfficeName := "Northwest Periodontics & Dental Implants"
global PatientName := ""  ; Will be set when form is launched

; GUI Control variables (required for GuiControl updates)
global TxtOfficeName := ""
global TxtPatientName := ""

; User-editable fields
global ReferralSource := ""

; Treatment Types
global chkImplantTreatment := 0
global chkPeriodontalTreatment := 0
global chkRecessionTreatment := 0
global chkCrownLengthening := 0

; Radiographs
global chkRadiographsYes := 0
global chkRadiographsNo := 0
global chkWillSend := 0
global chkPatientWillBring := 0

; Remarks
global txtRemarks := ""

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
    
    ; Set GUI defaults
    Gui, Main:New, +Resize +MinSize400x400, %windowTitle%
    Gui, Main:Color, FFFFFF
    Gui, Main:Font, s11, Arial
    
    ; Build standard header (modifies yPos by reference)
    yPos := 20
    formWidth := 500
    FT_BuildHeader(yPos, formWidth)
    
    colRight := 260  ; Right column X position
    
    ; ===========================================================================
    ; Treatment Types
    ; ===========================================================================
    Gui, Main:Font, s10 Bold Italic Underline, Arial
    Gui, Main:Add, Text, x20 y%yPos% w200, Treatment Requested
    
    Gui, Main:Font, s10 Normal, Arial
    yPos += 24
    Gui, Main:Add, CheckBox, x20 y%yPos% w200 vchkImplantTreatment, Implant Treatment
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w200 vchkPeriodontalTreatment, Periodontal Treatment
    
    yPos += 24
    Gui, Main:Add, CheckBox, x20 y%yPos% w200 vchkRecessionTreatment, Recession Treatment
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w200 vchkCrownLengthening, Crown Lengthening
    
    ; ===========================================================================
    ; Radiographs
    ; ===========================================================================
    yPos += 35
    Gui, Main:Add, Text, x20 y%yPos% w500 h2 +0x10
    
    yPos += 10
    Gui, Main:Font, s10 Bold Italic Underline, Arial
    Gui, Main:Add, Text, x20 y%yPos% w150, Radiographs
    
    Gui, Main:Font, s10 Normal, Arial
    yPos += 24
    Gui, Main:Add, CheckBox, x20 y%yPos% w80 vchkRadiographsYes, Yes
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w80 vchkRadiographsNo, No
    
    yPos += 24
    Gui, Main:Add, CheckBox, x20 y%yPos% w120 vchkWillSend, Will Send
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w150 vchkPatientWillBring, Patient Will Bring
    
    ; ===========================================================================
    ; Remarks
    ; ===========================================================================
    yPos += 35
    Gui, Main:Add, Text, x20 y%yPos% w500 h2 +0x10
    
    yPos += 10
    Gui, Main:Font, s10 Bold Italic Underline, Arial
    Gui, Main:Add, Text, x20 y%yPos% w150, Remarks
    
    Gui, Main:Font, s10 Normal, Arial
    yPos += 24
    Gui, Main:Add, Edit, x20 y%yPos% w500 h100 Multi vtxtRemarks, %txtRemarks%
    
    ; ===========================================================================
    ; Action Buttons
    ; ===========================================================================
    yPos += 115
    Gui, Main:Add, Text, x20 y%yPos% w500 h2 +0x10
    
    yPos += 10
    Gui, Main:Font, s10 Bold, Arial
    Gui, Main:Add, Button, x20 y%yPos% w100 h35 gBtnClearForm, Clear Form
    Gui, Main:Add, Button, x400 y%yPos% w120 h35 gBtnSubmit Default, Submit Referral
    
    ; Calculate window height
    winHeight := yPos + 50
    
    ; Show the GUI
    Gui, Main:Show, w540 h%winHeight%
}

; ==============================================================================
; Include Standard Handlers
; ==============================================================================
#Include %A_ScriptDir%\..\Lib\FormHandlers.ahk
