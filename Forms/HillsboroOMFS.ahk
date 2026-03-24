; ==============================================================================
; Hillsboro OMFS Referral Slip - AHK v1
; Based on Open Dental Sheet XML Export
; SPECIALIST_NAME: OS - Hillsboro OMFS
; FORM_NAME: HillsboroOMFS
; WINDOW_TITLE: Referral - OS - Hillsboro OMFS
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
global OfficeName := "Hillsboro Oral & Maxillofacial Surgery"
global PatientName := ""  ; Will be set when form is launched

; GUI Control variables (required for GuiControl updates)
global TxtOfficeName := ""
global TxtPatientName := ""

; User-editable fields
global ReferralSource := ""
global TeethAreaToTreat := ""

; Procedures Requested
global chkExtraction := 0
global chkDiscussImplants := 0
global chkBiopsyExcision := 0
global chkProcedureOther := 0
global txtProcedureOther := ""
global chkConeBeamCT := 0

global chkAlveoloplasty := 0
global chkFrenectomy := 0
global chkExposureBond := 0
global chkIncisionDrainage := 0

; Consultations Requested
global chkDentalImplants := 0
global chkSinusLift := 0
global chkBoneGrafting := 0
global chkFacialTrauma := 0
global chkConsultOther := 0
global txtConsultOther := ""

global chkOralPathology := 0
global chkSoftTissueGrafting := 0
global chkSkinLesions := 0

; Management Notes
global txtManagementNotes := ""

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
    ; Teeth / Area to be Treated
    ; ===========================================================================
    Gui, Main:Font, s10 Bold Italic Underline, Arial
    Gui, Main:Add, Text, x20 y%yPos% w250, Teeth # or area to be treated:
    
    Gui, Main:Font, s11 Normal, Arial
    yPos += 22
    Gui, Main:Add, Edit, x20 y%yPos% w560 h22 vTeethAreaToTreat, %TeethAreaToTreat%
    
    ; Separator
    yPos += 30
    Gui, Main:Add, Text, x20 y%yPos% w580 h2 +0x10
    
    ; ===========================================================================
    ; Procedures and Consultations - Two Column Layout
    ; ===========================================================================
    yPos += 10
    baseY := yPos
    colRight := 380  ; Right column X position
    
    ; ----- LEFT COLUMN: Procedures Requested -----
    Gui, Main:Font, s10 Bold Italic Underline, Arial
    Gui, Main:Add, Text, x20 y%yPos% w250, Procedure(s) Requested
    
    Gui, Main:Font, s10 Normal, Arial
    yPos += 22
    Gui, Main:Add, CheckBox, x20 y%yPos% w150 vchkExtraction, Extraction(s)
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w150 vchkAlveoloplasty, Alveoloplasty
    
    yPos += 22
    Gui, Main:Add, CheckBox, x20 y%yPos% w300 vchkDiscussImplants, Would you like us to discuss implants
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w150 vchkFrenectomy, Frenectomy
    
    yPos += 22
    Gui, Main:Add, Text, x35 y%yPos% w150 h22, or bone grafting?
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w150 vchkExposureBond, Exposure / Bond
    
    yPos += 22
    Gui, Main:Add, CheckBox, x20 y%yPos% w150 vchkBiopsyExcision, Biopsy / Excision
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w160 vchkIncisionDrainage, Incision / Drainage
    
    yPos += 22
    Gui, Main:Add, CheckBox, x20 y%yPos% w55 vchkProcedureOther, Other:
    Gui, Main:Add, Edit, x80 y%yPos% w280 h22 vtxtProcedureOther, %txtProcedureOther%
    
    yPos += 28
    Gui, Main:Add, CheckBox, x20 y%yPos% w170 vchkConeBeamCT, Cone Beam CT Scan
    
    ; ----- LEFT COLUMN: Consultations Requested -----
    yPos += 30
    consultBaseY := yPos
    Gui, Main:Font, s10 Bold Italic Underline, Arial
    Gui, Main:Add, Text, x20 y%yPos% w250, Consultation(s) Requested
    
    Gui, Main:Font, s10 Normal, Arial
    yPos += 22
    Gui, Main:Add, CheckBox, x20 y%yPos% w150 vchkDentalImplants, Dental implants
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w150 vchkOralPathology, Oral Pathology
    
    yPos += 22
    Gui, Main:Add, CheckBox, x20 y%yPos% w120 vchkSinusLift, Sinus Lift
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w170 vchkSoftTissueGrafting, Soft tissue grafting
    
    yPos += 22
    Gui, Main:Add, CheckBox, x20 y%yPos% w130 vchkBoneGrafting, Bone grafting
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w130 vchkSkinLesions, Skin lesions
    
    yPos += 22
    Gui, Main:Add, CheckBox, x20 y%yPos% w130 vchkFacialTrauma, Facial Trauma
    
    yPos += 22
    Gui, Main:Add, CheckBox, x20 y%yPos% w55 vchkConsultOther, Other:
    Gui, Main:Add, Edit, x80 y%yPos% w280 h22 vtxtConsultOther, %txtConsultOther%
    
    ; ===========================================================================
    ; Management, Medical or Treatment Concerns
    ; ===========================================================================
    yPos += 35
    Gui, Main:Add, Text, x20 y%yPos% w580 h2 +0x10
    
    yPos += 8
    Gui, Main:Font, s10 Bold Italic Underline, Arial
    Gui, Main:Add, Text, x20 y%yPos% w350, Management, Medical or Treatment concerns
    
    Gui, Main:Font, s10 Normal, Arial
    yPos += 22
    Gui, Main:Add, Edit, x20 y%yPos% w580 h80 Multi vtxtManagementNotes, %txtManagementNotes%
    
    ; ===========================================================================
    ; Action Buttons
    ; ===========================================================================
    yPos += 95
    Gui, Main:Add, Text, x20 y%yPos% w580 h2 +0x10
    
    yPos += 10
    Gui, Main:Font, s10 Bold, Arial
    Gui, Main:Add, Button, x20 y%yPos% w100 h35 gBtnClearForm, Clear Form
    Gui, Main:Add, Button, x460 y%yPos% w140 h35 gBtnSubmit Default, Submit Referral
    
    ; Calculate window height (buttons are at yPos with height 35, so bottom is yPos + 35)
    ; Add minimal padding (15 pixels) below buttons
    winHeight := yPos + 50
    
    ; Show the GUI
    Gui, Main:Show, w620 h%winHeight%
}

; ==============================================================================
; Include Standard Handlers
; ==============================================================================
#Include %A_ScriptDir%\..\Lib\FormHandlers.ahk
