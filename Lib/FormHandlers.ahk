; ==============================================================================
; Standard Form Handlers - Include after BuildReferralForm() function
; Provides: Clear Form button, Submit button, Close/Escape handlers
; ==============================================================================

; ==============================================================================
; Event Handlers
; ==============================================================================

BtnClearForm:
    ClearForm()  ; Library function (auto-clears all fields from Mappings.ini)
return

BtnSubmit:
    Gui, Main:Submit, NoHide
    
    ; Get form data (auto-generated from Mappings.ini)
    formData := GetFormData()
    
    ; Hide form during transfer
    Gui, Main:Hide
    
    ; Get form name for FormTransfer
    ; PS_FormName should be set by InitPresets(), but get it if not
    global PS_FormName
    if (PS_FormName = "")
        PS_FormName := PS_GetFormName()
    
    ; Transfer to Open Dental
    FormTransfer(PS_FormName, formData)
    
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
