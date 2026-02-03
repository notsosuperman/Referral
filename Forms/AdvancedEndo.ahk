; ==============================================================================
; Advanced Endo Referral Slip - AHK v1
; Based on Open Dental Sheet XML Export
; SPECIALIST_NAME: Endo - Advanced Endo
; FORM_NAME: AdvancedEndo
; WINDOW_TITLE: Referral - Endo - Advanced Endo
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
global OfficeName := "Advanced Endo"
global PatientName := ""  ; Will be set when form is launched

; GUI Control variables (required for GuiControl updates)
global TxtOfficeName := ""
global TxtPatientName := ""

; User-editable fields (ReferralSource in header)
global ReferralSource := ""

; Tooth checkboxes (1-16 top row, 32-17 bottom row)
global chkTooth1 := 0
global chkTooth2 := 0
global chkTooth3 := 0
global chkTooth4 := 0
global chkTooth5 := 0
global chkTooth6 := 0
global chkTooth7 := 0
global chkTooth8 := 0
global chkTooth9 := 0
global chkTooth10 := 0
global chkTooth11 := 0
global chkTooth12 := 0
global chkTooth13 := 0
global chkTooth14 := 0
global chkTooth15 := 0
global chkTooth16 := 0
global chkTooth32 := 0
global chkTooth31 := 0
global chkTooth30 := 0
global chkTooth29 := 0
global chkTooth28 := 0
global chkTooth27 := 0
global chkTooth26 := 0
global chkTooth25 := 0
global chkTooth24 := 0
global chkTooth23 := 0
global chkTooth22 := 0
global chkTooth21 := 0
global chkTooth20 := 0
global chkTooth19 := 0
global chkTooth18 := 0
global chkTooth17 := 0

; Place temporary only
global chkCottonCavitIRM := 0
global chkCottonGlassIonomer := 0
global chkEndodontistDiscretionTemp := 0
global chkLeavePostSpace := 0

; Permanent access fill
global chkComposite := 0
global chkAmalgam := 0
global chkPostAndCore := 0
global chkEndodontistDiscretionPerm := 0

; Notes
global txtNotes := ""  ; Multiline

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
    ; Tooth Chart (1-16 top row, 32-17 bottom row)
    ; ===========================================================================
    Gui, Main:Font, s10 Bold Italic Underline, Arial
    Gui, Main:Add, Text, x20 y%yPos% w200, Select Teeth:
    
    Gui, Main:Font, s9 Normal, Arial
    yPos += 22
    ; Top row: Numbers above checkboxes (1-16)
    ; Checkboxes have internal padding, so we need to align text with the checkbox square
    startX := 22  ; Adjust for checkbox internal padding (~2px)
    spacing := 32
    checkboxWidth := 25
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 1
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 2
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 3
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 4
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 5
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 6
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 7
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 8
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 9
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 10
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 11
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 12
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 13
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 14
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 15
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 16
    
    ; Top row: Checkboxes (moved 8px to the right)
    yPos += 18
    startX := 28
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth1
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth2
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth3
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth4
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth5
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth6
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth7
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth8
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth9
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth10
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth11
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth12
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth13
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth14
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth15
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth16
    
    ; Bottom row: Checkboxes (moved 8px to the right)
    yPos += 25
    startX := 28
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth32
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth31
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth30
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth29
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth28
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth27
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth26
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth25
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth24
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth23
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth22
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth21
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth20
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth19
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth18
    startX += spacing
    Gui, Main:Add, CheckBox, x%startX% y%yPos% w%checkboxWidth% h20 vchkTooth17
    
    ; Bottom row: Numbers below checkboxes (32-17)
    yPos += 25
    startX := 22  ; Adjust for checkbox internal padding (~2px)
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 32
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 31
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 30
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 29
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 28
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 27
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 26
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 25
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 24
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 23
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 22
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 21
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 20
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 19
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 18
    startX += spacing
    Gui, Main:Add, Text, x%startX% y%yPos% w%checkboxWidth% Center, 17
    
    ; ===========================================================================
    ; Place temporary only and Permanent access fill (side by side)
    ; ===========================================================================
    yPos += 35
    Gui, Main:Add, Text, x20 y%yPos% w540 h2 +0x10
    
    yPos += 8
    colRight := 300
    Gui, Main:Font, s10 Bold Italic Underline, Arial
    Gui, Main:Add, Text, x20 y%yPos% w250, Place Temporary Only:
    Gui, Main:Add, Text, x%colRight% y%yPos% w250, Permanent Access Fill:
    
    Gui, Main:Font, s10 Normal, Arial
    yPos += 22
    tempYPos := yPos
    Gui, Main:Add, CheckBox, x20 y%yPos% w250 vchkCottonCavitIRM, Cotton/Cavit/IRM
    
    yPos += 22
    Gui, Main:Add, CheckBox, x20 y%yPos% w250 vchkCottonGlassIonomer, Cotton/Glass Ionomer
    
    yPos += 22
    Gui, Main:Add, CheckBox, x20 y%yPos% w250 vchkEndodontistDiscretionTemp, Endodontist's discretion
    
    yPos += 22
    Gui, Main:Add, CheckBox, x20 y%yPos% w250 vchkLeavePostSpace, Leave post space
    
    ; Permanent access fill (right column)
    yPos := tempYPos
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w250 vchkComposite, Composite
    
    yPos += 22
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w250 vchkAmalgam, Amalgam
    
    yPos += 22
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w250 vchkPostAndCore, Post and Core
    
    yPos += 22
    Gui, Main:Add, CheckBox, x%colRight% y%yPos% w250 vchkEndodontistDiscretionPerm, Endodontist's discretion
    
    ; ===========================================================================
    ; Notes
    ; ===========================================================================
    yPos += 35
    Gui, Main:Add, Text, x20 y%yPos% w540 h2 +0x10
    
    yPos += 8
    Gui, Main:Font, s10 Bold Italic Underline, Arial
    Gui, Main:Add, Text, x20 y%yPos% w200, Notes:
    
    Gui, Main:Font, s10 Normal, Arial
    yPos += 22
    Gui, Main:Add, Edit, x20 y%yPos% w540 h100 Multi vtxtNotes, %txtNotes%
    
    ; ===========================================================================
    ; Action Buttons
    ; ===========================================================================
    yPos += 115  ; Notes edit box height (100) + spacing (15)
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
