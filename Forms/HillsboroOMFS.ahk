; ==============================================================================
; Hillsboro OMFS Referral Slip - AHK v1
; Based on Open Dental Sheet XML Export
; WINDOW_TITLE: Hillsboro OMFS Referral Slip
; SPECIALIST_NAME: Hillsboro Oral & Maxillofacial Surgery
; FORM_NAME: HillsboroOMFS
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

; Radiograph Requests
global chkEnclosedEmailed := 0
global chkGivenToPatient := 0
global chkTakeNewOnes := 0

; Who Calls
global chkPleaseCallPatient := 0
global chkPatientWillCall := 1

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
    ; Set GUI defaults
    Gui, Main:New, +Resize +MinSize500x600, Hillsboro OMFS Referral Slip
    Gui, Main:Color, FFFFFF
    Gui, Main:Font, s11, Arial
    
    yPos := 10
    
    ; ===========================================================================
    ; Line 1: Office Name (display only)
    ; ===========================================================================
    Gui, Main:Font, s14 Bold, Arial
    Gui, Main:Add, Text, x20 y%yPos% w580 cNavy vTxtOfficeName, %OfficeName%
    
    ; ===========================================================================
    ; Line 2: Patient Name (display only)
    ; ===========================================================================
    yPos += 28
    Gui, Main:Font, s12 Normal, Arial
    Gui, Main:Add, Text, x20 y%yPos% w580 vTxtPatientName, Patient: %PatientName%
    
    ; ===========================================================================
    ; Line 3: Referring Dentist (in header)
    ; ===========================================================================
    yPos += 28
    Gui, Main:Font, s10 Normal, Arial
    Gui, Main:Add, Text, x20 y%yPos% w100 h22 +0x200, Referring Dentist:
    Gui, Main:Add, DropDownList, x125 y%yPos% w180 vReferralSource, Dr. Gabe Proulx|Dr. Curtis Wahlen|Dr. Ben Wolfe|Dr. Jae Lee
    
    ; Separator
    yPos += 30
    Gui, Main:Add, Text, x20 y%yPos% w580 h2 +0x10
    
    ; ===========================================================================
    ; Who Calls (on same row)
    ; ===========================================================================
    yPos += 10
    Gui, Main:Add, CheckBox, x20 y%yPos% w150 h22 vchkPleaseCallPatient gWhoCallsChanged, Please call patient
    Gui, Main:Add, CheckBox, x200 y%yPos% w230 h22 vchkPatientWillCall gWhoCallsChanged Checked, Patient will call for appointment
    
    ; ===========================================================================
    ; Teeth / Area to be Treated
    ; ===========================================================================
    yPos += 30
    Gui, Main:Add, Text, x20 y%yPos% w170 h22 +0x200, Teeth # or area to be treated:
    Gui, Main:Add, Edit, x195 y%yPos% w385 h22 vTeethAreaToTreat, %TeethAreaToTreat%
    
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
    ; Radiograph Requests
    ; ===========================================================================
    yPos += 35
    Gui, Main:Add, Text, x20 y%yPos% w580 h2 +0x10
    
    yPos += 8
    Gui, Main:Font, s10 Bold Italic Underline, Arial
    Gui, Main:Add, Text, x20 y%yPos% w150, Radiograph Requests
    
    Gui, Main:Font, s10 Normal, Arial
    yPos += 22
    Gui, Main:Add, CheckBox, x20 y%yPos% w150 vchkEnclosedEmailed, Enclosed/Emailed
    Gui, Main:Add, CheckBox, x200 y%yPos% w150 vchkGivenToPatient, Given to patient
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w180 vchkTakeNewOnes, Please take new ones
    
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
    
    ; Show the GUI
    Gui, Main:Show, w620 h750
}

; ==============================================================================
; Event Handlers
; ==============================================================================

WhoCallsChanged:
    Gui, Main:Submit, NoHide
    ; Make these mutually exclusive
    if (A_GuiControl = "chkPleaseCallPatient")
    {
        if (chkPleaseCallPatient)
            GuiControl, Main:, chkPatientWillCall, 0
    }
    else if (A_GuiControl = "chkPatientWillCall")
    {
        if (chkPatientWillCall)
            GuiControl, Main:, chkPleaseCallPatient, 0
    }
return

BtnClearForm:
    ; Clear referral source
    GuiControl, Main:Choose, ReferralSource, 0
    GuiControl, Main:, TeethAreaToTreat,
    
    ; Clear checkboxes - Procedures
    GuiControl, Main:, chkExtraction, 0
    GuiControl, Main:, chkDiscussImplants, 0
    GuiControl, Main:, chkBiopsyExcision, 0
    GuiControl, Main:, chkProcedureOther, 0
    GuiControl, Main:, txtProcedureOther,
    GuiControl, Main:, chkConeBeamCT, 0
    GuiControl, Main:, chkAlveoloplasty, 0
    GuiControl, Main:, chkFrenectomy, 0
    GuiControl, Main:, chkExposureBond, 0
    GuiControl, Main:, chkIncisionDrainage, 0
    
    ; Clear checkboxes - Consultations
    GuiControl, Main:, chkDentalImplants, 0
    GuiControl, Main:, chkSinusLift, 0
    GuiControl, Main:, chkBoneGrafting, 0
    GuiControl, Main:, chkFacialTrauma, 0
    GuiControl, Main:, chkConsultOther, 0
    GuiControl, Main:, txtConsultOther,
    GuiControl, Main:, chkOralPathology, 0
    GuiControl, Main:, chkSoftTissueGrafting, 0
    GuiControl, Main:, chkSkinLesions, 0
    
    ; Clear checkboxes - Radiographs
    GuiControl, Main:, chkEnclosedEmailed, 0
    GuiControl, Main:, chkGivenToPatient, 0
    GuiControl, Main:, chkTakeNewOnes, 0
    
    ; Reset who calls
    GuiControl, Main:, chkPleaseCallPatient, 0
    GuiControl, Main:, chkPatientWillCall, 1
    
    ; Clear notes
    GuiControl, Main:, txtManagementNotes,
return

BtnSubmit:
    Gui, Main:Submit, NoHide
    
    ; Validate required fields
    if (ReferralSource = "")
    {
        MsgBox, 48, Validation Error, Please select a referral source.
        return
    }
    
    ; Get form data
    formData := GetFormData()
    
    ; Hide form during transfer
    Gui, Main:Hide
    
    ; Transfer to Open Dental
    FormTransfer("HillsboroOMFS", formData)
    
    ; Close form (no message)
    ExitApp
return

; ==============================================================================
; GUI Close Handler
; ==============================================================================
MainGuiClose:
MainGuiEscape:
    ExitApp
return

; ==============================================================================
; Utility Functions
; ==============================================================================

; Set the patient name display (call this before showing the form)
SetPatientName(name)
{
    global PatientName := name
    GuiControl, Main:, TxtPatientName, Patient: %name%
}

; Set the office name display (call this before showing the form)
SetOfficeName(name)
{
    global OfficeName := name
    GuiControl, Main:, TxtOfficeName, %name%
}

; Get all form data as an object (for automation)
GetFormData()
{
    Gui, Main:Submit, NoHide
    
    data := {}
    data.ReferralSource := ReferralSource
    data.TeethAreaToTreat := TeethAreaToTreat
    
    ; Who calls
    data.chkPleaseCallPatient := chkPleaseCallPatient
    data.chkPatientWillCall := chkPatientWillCall
    
    ; Procedures
    data.chkExtraction := chkExtraction
    data.chkDiscussImplants := chkDiscussImplants
    data.chkBiopsyExcision := chkBiopsyExcision
    data.chkProcedureOther := chkProcedureOther
    data.txtProcedureOther := txtProcedureOther
    data.chkConeBeamCT := chkConeBeamCT
    data.chkAlveoloplasty := chkAlveoloplasty
    data.chkFrenectomy := chkFrenectomy
    data.chkExposureBond := chkExposureBond
    data.chkIncisionDrainage := chkIncisionDrainage
    
    ; Consultations
    data.chkDentalImplants := chkDentalImplants
    data.chkSinusLift := chkSinusLift
    data.chkBoneGrafting := chkBoneGrafting
    data.chkFacialTrauma := chkFacialTrauma
    data.chkConsultOther := chkConsultOther
    data.txtConsultOther := txtConsultOther
    data.chkOralPathology := chkOralPathology
    data.chkSoftTissueGrafting := chkSoftTissueGrafting
    data.chkSkinLesions := chkSkinLesions
    
    ; Radiographs
    data.chkEnclosedEmailed := chkEnclosedEmailed
    data.chkGivenToPatient := chkGivenToPatient
    data.chkTakeNewOnes := chkTakeNewOnes
    
    ; Notes
    data.txtManagementNotes := txtManagementNotes
    
    return data
}
