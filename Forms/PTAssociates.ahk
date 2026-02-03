; ==============================================================================
; PT Associates Referral Slip - AHK v1
; Based on Open Dental Sheet XML Export
; SPECIALIST_NAME: TMJ - PT Associates
; FORM_NAME: PTAssociates
; WINDOW_TITLE: Referral - TMJ - PT Associates
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
global OfficeName := "PT Associates"
global PatientName := ""  ; Will be set when form is launched

; GUI Control variables (required for GuiControl updates)
global TxtOfficeName := ""
global TxtPatientName := ""

; User-editable fields (ReferralSource in header)
global ReferralSource := ""

; Notes field
global txtNotes := ""

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
    ; Notes
    ; ===========================================================================
    Gui, Main:Font, s10 Bold Italic Underline, Arial
    Gui, Main:Add, Text, x20 y%yPos% w200, Notes

    Gui, Main:Font, s10 Normal, Arial
    yPos += 24
    Gui, Main:Add, Edit, x20 y%yPos% w400 h110 Multi vtxtNotes, %txtNotes%

    ; ===========================================================================
    ; Action Buttons
    ; ===========================================================================
    yPos += 125
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
