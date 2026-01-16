; ==============================================================================
; Northwest Periodontics Referral Slip - AHK v1
; Based on Open Dental Sheet XML Export
; WINDOW_TITLE: Northwest Periodontics Referral Slip
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
    ; Set GUI defaults
    Gui, Main:New, +Resize +MinSize400x400, Northwest Periodontics Referral Slip
    Gui, Main:Color, FFFFFF
    Gui, Main:Font, s11, Arial
    
    yPos := 10
    colRight := 260  ; Right column X position
    
    ; ===========================================================================
    ; Line 1: Office Name (display only)
    ; ===========================================================================
    Gui, Main:Font, s14 Bold, Arial
    Gui, Main:Add, Text, x20 y%yPos% w500 cNavy vTxtOfficeName, %OfficeName%
    
    ; ===========================================================================
    ; Line 2: Patient Name (display only)
    ; ===========================================================================
    yPos += 28
    Gui, Main:Font, s12 Normal, Arial
    Gui, Main:Add, Text, x20 y%yPos% w500 vTxtPatientName, Patient: %PatientName%
    
    ; ===========================================================================
    ; Line 3: Referring Dentist (in header)
    ; ===========================================================================
    yPos += 28
    Gui, Main:Font, s10 Normal, Arial
    Gui, Main:Add, Text, x20 y%yPos% w100 h22 +0x200, Referring Dentist:
    Gui, Main:Add, DropDownList, x125 y%yPos% w180 vReferralSource, Dr. Gabe Proulx|Dr. Curtis Wahlen|Dr. Ben Wolfe|Dr. Jae Lee
    
    ; Separator
    yPos += 30
    Gui, Main:Add, Text, x20 y%yPos% w500 h2 +0x10
    
    ; ===========================================================================
    ; Treatment Types
    ; ===========================================================================
    yPos += 10
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
    Gui, Main:Add, CheckBox, x20 y%yPos% w80 vchkRadiographsYes gRadiographsYesNoChanged, Yes
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w80 vchkRadiographsNo gRadiographsYesNoChanged, No
    
    yPos += 24
    Gui, Main:Add, CheckBox, x20 y%yPos% w120 vchkWillSend gRadiographsSendChanged, Will Send
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w150 vchkPatientWillBring gRadiographsSendChanged, Patient Will Bring
    
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
    
    ; Show the GUI
    Gui, Main:Show, w540 h480
}

; ==============================================================================
; Event Handlers
; ==============================================================================

RadiographsYesNoChanged:
    Gui, Main:Submit, NoHide
    ; Make Yes/No mutually exclusive
    if (A_GuiControl = "chkRadiographsYes")
    {
        if (chkRadiographsYes)
            GuiControl, Main:, chkRadiographsNo, 0
    }
    else if (A_GuiControl = "chkRadiographsNo")
    {
        if (chkRadiographsNo)
            GuiControl, Main:, chkRadiographsYes, 0
    }
return

RadiographsSendChanged:
    Gui, Main:Submit, NoHide
    ; Make Will Send / Patient Will Bring mutually exclusive
    if (A_GuiControl = "chkWillSend")
    {
        if (chkWillSend)
            GuiControl, Main:, chkPatientWillBring, 0
    }
    else if (A_GuiControl = "chkPatientWillBring")
    {
        if (chkPatientWillBring)
            GuiControl, Main:, chkWillSend, 0
    }
return

BtnClearForm:
    ; Clear referral source
    GuiControl, Main:Choose, ReferralSource, 0
    
    ; Clear checkboxes - Treatments
    GuiControl, Main:, chkImplantTreatment, 0
    GuiControl, Main:, chkPeriodontalTreatment, 0
    GuiControl, Main:, chkRecessionTreatment, 0
    GuiControl, Main:, chkCrownLengthening, 0
    
    ; Clear checkboxes - Radiographs
    GuiControl, Main:, chkRadiographsYes, 0
    GuiControl, Main:, chkRadiographsNo, 0
    GuiControl, Main:, chkWillSend, 0
    GuiControl, Main:, chkPatientWillBring, 0
    
    ; Clear remarks
    GuiControl, Main:, txtRemarks,
return

BtnSubmit:
    Gui, Main:Submit, NoHide
    
    ; Validate required fields
    if (ReferralSource = "")
    {
        MsgBox, 48, Validation Error, Please select a referring dentist.
        return
    }
    
    ; Get form data
    formData := GetFormData()
    
    ; Hide form during transfer
    Gui, Main:Hide
    
    ; Transfer to Open Dental
    FormTransfer("NorthwestPerio", formData)
    
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
    data.ReferringTo := "Dr. Patrick Corning"
    
    ; Treatments
    data.chkImplantTreatment := chkImplantTreatment
    data.chkPeriodontalTreatment := chkPeriodontalTreatment
    data.chkRecessionTreatment := chkRecessionTreatment
    data.chkCrownLengthening := chkCrownLengthening
    
    ; Radiographs
    data.chkRadiographsYes := chkRadiographsYes
    data.chkRadiographsNo := chkRadiographsNo
    data.chkWillSend := chkWillSend
    data.chkPatientWillBring := chkPatientWillBring
    
    ; Remarks
    data.txtRemarks := txtRemarks
    
    return data
}
