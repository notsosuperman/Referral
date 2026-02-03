; ==============================================================================
; Hi 5 Dental Referral Slip - AHK v1
; Based on Open Dental Sheet XML Export
; SPECIALIST_NAME: Pedo - Hi 5 Dental
; FORM_NAME: Hi5
; WINDOW_TITLE: Referral - Pedo - Hi 5 Dental
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
global OfficeName := "Hi 5 Dental"
global PatientName := ""  ; Will be set when form is launched

; GUI Control variables (required for GuiControl updates)
global TxtOfficeName := ""
global TxtPatientName := ""

; User-editable fields (ReferralSource in header)
global ReferralSource := ""

; Notes fields
global txtPleaseEvaluateAndTreat := ""  ; Multiline
global txtRadiographsTaken := ""  ; Single line

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
    formWidth := 500
    FT_BuildHeader(yPos, formWidth)
    
    ; ===========================================================================
    ; Please Evaluate & Treat
    ; ===========================================================================
    Gui, Main:Font, s10 Bold Italic Underline, Arial
    Gui, Main:Add, Text, x20 y%yPos% w200, Please Evaluate and Treat:
    
    Gui, Main:Font, s10 Normal, Arial
    yPos += 24
    Gui, Main:Add, Edit, x20 y%yPos% w500 h100 Multi vtxtPleaseEvaluateAndTreat, %txtPleaseEvaluateAndTreat%
    
    ; ===========================================================================
    ; Radiographs Taken
    ; ===========================================================================
    yPos += 115
    Gui, Main:Font, s10 Bold Italic Underline, Arial
    Gui, Main:Add, Text, x20 y%yPos% w200, Radiographs taken:
    
    Gui, Main:Font, s10 Normal, Arial
    yPos += 24
    Gui, Main:Add, Edit, x20 y%yPos% w500 h22 vtxtRadiographsTaken, %txtRadiographsTaken%
    
    ; ===========================================================================
    ; Action Buttons
    ; ===========================================================================
    yPos += 35
    Gui, Main:Add, Text, x20 y%yPos% w500 h2 +0x10
    
    yPos += 10
    Gui, Main:Font, s10 Bold, Arial
    Gui, Main:Add, Button, x20 y%yPos% w100 h35 gBtnClearForm, Clear Form
    Gui, Main:Add, Button, x400 y%yPos% w120 h35 gBtnSubmit Default, Submit Referral
    
    ; Calculate window dimensions
    winWidth := 540
    winHeight := yPos + 50  ; Buttons are at yPos with height 35, so bottom is yPos + 35, plus 15px padding
    
    ; Set MinSize to match display size (can't change after Gui, New, so using small default)
    ; The actual size is set by Gui, Show below
    Gui, Main:Show, w%winWidth% h%winHeight%
}

; ==============================================================================
; Include Standard Handlers
; ==============================================================================
#Include %A_ScriptDir%\..\Lib\FormHandlers.ahk
