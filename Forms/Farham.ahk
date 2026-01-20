; ==============================================================================
; Farham Referral Slip - AHK v1
; Based on Open Dental Sheet XML Export
; WINDOW_TITLE: Farham Referral Slip
; SPECIALIST_NAME: Endo - Wolfe Dental Cedar Mill
; FORM_NAME: Farham
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
    ; Set GUI defaults
    Gui, Main:New, +Resize +MinSize400x300, Farham Referral Slip
    Gui, Main:Color, FFFFFF
    Gui, Main:Font, s11, Arial
    
    yPos := 10
    
    ; ===========================================================================
    ; Line 1: Office Name (display only)
    ; ===========================================================================
    Gui, Main:Font, s14 Bold, Arial
    Gui, Main:Add, Text, x20 y%yPos% w400 cNavy vTxtOfficeName, %OfficeName%
    
    ; ===========================================================================
    ; Line 2: Patient Name (display only)
    ; ===========================================================================
    yPos += 28
    Gui, Main:Font, s12 Normal, Arial
    Gui, Main:Add, Text, x20 y%yPos% w400 vTxtPatientName, Patient: %PatientName%
    
    ; ===========================================================================
    ; Line 3: Referring Dentist (in header)
    ; ===========================================================================
    yPos += 28
    Gui, Main:Font, s10 Normal, Arial
    Gui, Main:Add, Text, x20 y%yPos% w100 h22 +0x200, Referring Doctor:
    Gui, Main:Add, DropDownList, x125 y%yPos% w180 vReferralSource, Dr. Gabe Proulx|Dr. Curtis Wahlen|Dr. Ben Wolfe|Dr. Jae Lee
    
    ; Separator
    yPos += 30
    Gui, Main:Add, Text, x20 y%yPos% w400 h2 +0x10
    
    ; ===========================================================================
    ; For Treatment Including (Notes)
    ; ===========================================================================
    yPos += 10
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
    Gui, Main:Add, CheckBox, x180 y%yPos% w50 vchkCBCTYes gCBCTChanged, Y
    Gui, Main:Add, CheckBox, x240 y%yPos% w50 vchkCBCTNo gCBCTChanged, N
    
    ; ===========================================================================
    ; PA Question
    ; ===========================================================================
    yPos += 28
    Gui, Main:Add, Text, x20 y%yPos% w150 h22 +0x200, Was PA taken?
    Gui, Main:Add, CheckBox, x180 y%yPos% w50 vchkPAYes gPAChanged, Y
    Gui, Main:Add, CheckBox, x240 y%yPos% w50 vchkPANo gPAChanged, N
    
    ; ===========================================================================
    ; Action Buttons
    ; ===========================================================================
    yPos += 40
    Gui, Main:Add, Text, x20 y%yPos% w400 h2 +0x10
    
    yPos += 10
    Gui, Main:Font, s10 Bold, Arial
    Gui, Main:Add, Button, x20 y%yPos% w100 h35 gBtnClearForm, Clear Form
    Gui, Main:Add, Button, x300 y%yPos% w120 h35 gBtnSubmit Default, Submit Referral
    
    ; Show the GUI
    winHeight := yPos + 50
    Gui, Main:Show, w440 h%winHeight%
}

; ==============================================================================
; Event Handlers
; ==============================================================================

CBCTChanged:
    Gui, Main:Submit, NoHide
    ; Make Y/N mutually exclusive
    if (A_GuiControl = "chkCBCTYes")
    {
        if (chkCBCTYes)
            GuiControl, Main:, chkCBCTNo, 0
    }
    else if (A_GuiControl = "chkCBCTNo")
    {
        if (chkCBCTNo)
            GuiControl, Main:, chkCBCTYes, 0
    }
return

PAChanged:
    Gui, Main:Submit, NoHide
    ; Make Y/N mutually exclusive
    if (A_GuiControl = "chkPAYes")
    {
        if (chkPAYes)
            GuiControl, Main:, chkPANo, 0
    }
    else if (A_GuiControl = "chkPANo")
    {
        if (chkPANo)
            GuiControl, Main:, chkPAYes, 0
    }
return

BtnClearForm:
    ; Clear referral source
    GuiControl, Main:Choose, ReferralSource, 0
    
    ; Clear notes
    GuiControl, Main:, txtNotes,
    
    ; Clear CBCT checkboxes
    GuiControl, Main:, chkCBCTYes, 0
    GuiControl, Main:, chkCBCTNo, 0
    
    ; Clear PA checkboxes
    GuiControl, Main:, chkPAYes, 0
    GuiControl, Main:, chkPANo, 0
return

BtnSubmit:
    Gui, Main:Submit, NoHide
    
    ; Validate required fields
    if (ReferralSource = "")
    {
        MsgBox, 48, Validation Error, Please select a referring doctor.
        return
    }
    
    ; Get form data
    formData := GetFormData()
    
    ; Hide form during transfer
    Gui, Main:Hide
    
    ; Transfer to Open Dental
    FormTransfer("Farham", formData)
    
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
