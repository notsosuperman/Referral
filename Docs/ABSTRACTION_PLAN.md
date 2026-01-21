# Form Abstraction Plan

## Overview
This document outlines the plan to abstract and simplify form creation by moving common code to shared libraries. The goal is to make new forms as barebones as possible, requiring only form-specific fields.

---

## Abstraction Goals

### 1. Header Section (Office Name, Patient Name, Referring Doctor)
**Current State:** Duplicated in all 3 forms with identical structure
**Action:** Create `FT_BuildHeader(ByRef yPos, formWidth)` function in `FormTransfer.ahk`

**Functionality:**
- Builds the complete header section:
  - Office Name (s14 Bold, Navy)
  - Patient Name (s12 Normal)
  - Referring Dentist dropdown (hardcoded options: Dr. Gabe Proulx|Dr. Curtis Wahlen|Dr. Ben Wolfe|Dr. Jae Lee)
  - Separator line
- Modifies `yPos` by reference for next section
- Uses global variables: `OfficeName`, `PatientName`, `ReferralSource`

**Benefits:**
- One place to update header layout
- One place to update referring doctor list
- Consistent across all forms

---

### 2. SetPatientName and SetOfficeName Functions
**Current State:** Duplicated in all 3 forms (identical implementations)
**Action:** Move to `FormTransfer.ahk` library

**Functionality:**
- `SetPatientName(name)` - Updates global and GUI control
- `SetOfficeName(name)` - Updates global and GUI control

**Benefits:**
- Centralized utility functions
- Forms just need global variable declarations

---

### 3. Button Handlers (Clear Form, Submit, Close/Escape)
**Current State:** Duplicated in all 3 forms (identical implementations)
**Action:** Create `Lib/FormHandlers.ahk` with standard handlers

**Functionality:**
- `BtnClearForm:` label handler
- `BtnSubmit:` label handler
- `MainGuiClose:` and `MainGuiEscape:` handlers

**Implementation:**
- Forms include: `#Include %A_ScriptDir%\..\Lib\FormHandlers.ahk`
- Includes must be placed AFTER BuildReferralForm() function
- Handlers call library functions: `ClearForm()`, `GetFormData()`, `FormTransfer()`

**Benefits:**
- Zero boilerplate for button handlers
- Consistent behavior across forms

---

### 4. Window Title Simplification
**Current State:** Separate `WINDOW_TITLE` and `DISPLAY_NAME` headers
**Action:** Remove `DISPLAY_NAME`, use `SPECIALIST_NAME` for both

**Changes:**
- Window title format: `"Referral - " . SPECIALIST_NAME`
  - Example: `"Referral - OS - Hillsboro OMFS"`
- Launcher uses `SPECIALIST_NAME` for button text
- Remove `DISPLAY_NAME` from header comments

**Benefits:**
- Single source of truth (SPECIALIST_NAME)
- Simpler header structure

---

### 5. Default Preset Override Logic
**Current State:** Manual creation, no override logic
**Action:** Update `PS_SavePreset()` to handle "Default" special case

**Functionality:**
- If preset name = "Default", delete existing `[FormName_Default]` section before saving
- Uses `IniDelete` to remove old default, then saves normally
- No special CoordHelper logic needed

**Benefits:**
- Users can create/update default by naming preset "Default"
- Simple implementation

---

## Implementation Steps

### Phase 1: Library Functions (FormTransfer.ahk)
1. Add `FT_BuildHeader(ByRef yPos, formWidth)` function
   - Hardcode referring doctor options in function
   - Use global variables: OfficeName, PatientName, ReferralSource
   
2. Move `SetPatientName(name)` function
3. Move `SetOfficeName(name)` function
4. Update `PS_SavePreset()` to handle "Default" override

### Phase 2: Form Handlers (New File)
1. Create `Lib/FormHandlers.ahk`
   - Add `BtnClearForm:` handler
   - Add `BtnSubmit:` handler
   - Add `MainGuiClose:` and `MainGuiEscape:` handlers
   - Note: Forms must pass FORM_NAME to FormTransfer()

### Phase 3: Update Existing Forms
1. Update `Forms/Farham.ahk`:
   - Remove DISPLAY_NAME from header
   - Remove SetPatientName/SetOfficeName functions
   - Replace header section with `FT_BuildHeader(yPos, formWidth)` call
   - Update window title to use SPECIALIST_NAME
   - Remove button handlers
   - Include FormHandlers.ahk
   
2. Update `Forms/HillsboroOMFS.ahk` (same changes)
3. Update `Forms/NorthwestPerio.ahk` (same changes)

### Phase 4: Update Launcher
1. Update `LauncherDynamic.ahk`:
   - Parse `SPECIALIST_NAME` instead of `DISPLAY_NAME`
   - Use `SPECIALIST_NAME` for button text

### Phase 5: Update Documentation
1. Update `Docs/FORM_CREATION_GUIDE.md`:
   - Remove DISPLAY_NAME from header format
   - Show window title using SPECIALIST_NAME
   - Document new simplified form structure
   - Show FT_BuildHeader() usage
   - Show FormHandlers.ahk include
   - Update examples to show barebones form

---

## New Form Structure (After Abstraction)

### Minimal Form Template
```ahk
; ==============================================================================
; [Form Description] Referral Slip - AHK v1
; SPECIALIST_NAME: [Category] - [Full Practice Name]
; FORM_NAME: [CamelCaseFormName]
; ==============================================================================
#NoEnv
#SingleInstance, Force
SetWorkingDir %A_ScriptDir%

; Include libraries
#Include %A_ScriptDir%\..\Lib\FormTransfer.ahk

; ==============================================================================
; Global Variables
; ==============================================================================
; Display only (set externally, not editable)
global OfficeName := "[Practice Name]"
global PatientName := ""

; GUI Control variables (required for GuiControl updates)
global TxtOfficeName := ""
global TxtPatientName := ""

; User-editable fields
global ReferralSource := ""
; ... form-specific fields ...

; ==============================================================================
; Main Entry Point
; ==============================================================================
BuildReferralForm()
InitPresets()
return

; ==============================================================================
; Build the GUI
; ==============================================================================
BuildReferralForm()
{
    ; Get specialist name for window title
    specialistName := PS_GetSpecialistName()
    windowTitle := "Referral - " . specialistName
    
    ; GUI Setup
    Gui, Main:New, , %windowTitle%
    Gui, Main:Color, FFFFFF
    
    ; Build standard header (modifies yPos by reference)
    yPos := 20
    formWidth := 580  ; Adjust per form
    FT_BuildHeader(yPos, formWidth)
    
    ; ===========================================================================
    ; FORM-SPECIFIC FIELDS (start here after header)
    ; ===========================================================================
    
    ; Add your form-specific fields here...
    
    ; ===========================================================================
    ; FOOTER: Action Buttons
    ; ===========================================================================
    ; Calculate yPos for buttons based on your fields
    
    Gui, Main:Add, Button, x20 y%yPos% w100 h35 gBtnClearForm, Clear Form
    Gui, Main:Add, Button, x460 y%yPos% w140 h35 gBtnSubmit Default, Submit Referral
    
    ; Calculate window height
    winHeight := yPos + 50
    
    ; Show the GUI
    Gui, Main:Show, w620 h%winHeight%
}

; ==============================================================================
; Include Standard Handlers
; ==============================================================================
#Include %A_ScriptDir%\..\Lib\FormHandlers.ahk
```

### Key Changes:
1. **Header:** Single line `FT_BuildHeader(yPos, formWidth)` replaces ~20 lines
2. **Utility Functions:** Removed (now in library)
3. **Button Handlers:** Single include replaces ~20 lines
4. **Window Title:** Derived from SPECIALIST_NAME
5. **DISPLAY_NAME:** Removed entirely

---

## Testing Checklist

### For Each Updated Form:
- [ ] Form loads and displays correctly
- [ ] Header shows office name, patient name, referring doctor dropdown
- [ ] Clear Form button works
- [ ] Submit Referral button works
- [ ] Close/Escape exits form
- [ ] Presets load correctly
- [ ] Default preset can be created/updated via Ctrl+Shift+S
- [ ] Form appears in launcher with correct name (SPECIALIST_NAME)
- [ ] Window title shows "Referral - [SPECIALIST_NAME]"
- [ ] FormTransfer works correctly

### Launcher:
- [ ] Discovers all forms using SPECIALIST_NAME
- [ ] Shows forms in alphabetical order
- [ ] Button text uses SPECIALIST_NAME
- [ ] Launches forms correctly

### CoordHelper:
- [ ] Still parses forms correctly
- [ ] Extracts SPECIALIST_NAME from header
- [ ] No issues with simplified header

---

## Benefits Summary

### Code Reduction:
- **Before:** ~200 lines per form
- **After:** ~80-100 lines per form (50% reduction)

### Maintenance:
- Header changes: 1 place instead of 3+
- Button handler changes: 1 place instead of 3+
- Doctor list changes: 1 place instead of 3+
- Window title: Automatic from SPECIALIST_NAME

### New Form Creation:
- Copy minimal template
- Add form-specific fields only
- No boilerplate header/handlers
- Faster, less error-prone

---

## Rollout Plan

1. ✅ Create this plan document
2. ✅ Commit current state
3. ✅ Create branch: `feature/form-abstraction`
4. Implement library functions
5. Create FormHandlers.ahk
6. Update existing forms (test each)
7. Update launcher
8. Update documentation
9. Test full system
10. Merge to main

---

## Notes

- **Backward Compatibility:** Old forms with DISPLAY_NAME will still work (launcher falls back), but new forms should not include it
- **Breaking Changes:** None - existing functionality preserved
- **Migration:** Existing forms updated in this branch, no user action needed
- **Future:** Consider abstracting footer buttons too (Clear Form, Submit Referral positioning)
