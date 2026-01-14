# Dental Referral System - Planning Document

## Overview

This system automates the creation of dental referrals in Open Dental by:
1. Presenting user-friendly AHK forms for each specialist
2. Capturing form data on submit
3. Automatically transferring data to Open Dental's "Fill Sheet" window

---

## Architecture

### Directory Structure

```
Referral/
├── Forms/                         # Referral form GUIs
│   ├── HillsboroOMFS.ahk
│   └── NorthwestPerio.ahk
├── Config/
│   └── Mappings.ini               # Control coordinates for all forms
├── Lib/
│   └── FormTransfer.ahk           # Shared transfer automation logic
├── Tools/
│   ├── ScreenshotHelper.ahk       # Development: capture form screenshots
│   └── CoordHelper.ahk            # Setup: gather Open Dental coordinates
├── Docs/
│   └── PLANNING.md                # This file
├── Launcher.ahk                   # Main menu with specialist buttons
└── README.md
```

### Data Flow

```
┌─────────────────┐
│   Launcher.ahk  │  User clicks specialist button
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Form AHK      │  User fills out referral form
│   (e.g. OMFS)   │
└────────┬────────┘
         │ Submit button clicked
         ▼
┌─────────────────┐
│  GetFormData()  │  Collects all form values into object
└────────┬────────┘
         │
         ▼
┌─────────────────┐     ┌──────────────────┐
│ FormTransfer()  │◄────│  Mappings.ini    │
│                 │     │  (coordinates)   │
└────────┬────────┘     └──────────────────┘
         │
         ▼
┌─────────────────┐
│  Open Dental    │  Clicks/types into "Fill Sheet" window
│  "Fill Sheet"   │
└─────────────────┘
```

---

## Control Types & Actions

| Type | AHK Control | Value in formData | Transfer Action |
|------|-------------|-------------------|-----------------|
| `checkbox` | `Gui, Add, CheckBox` | 0 or 1 | Click if value = 1 |
| `textfield` | `Gui, Add, Edit` (single line) | string | Click → Ctrl+A → Type |
| `multiline` | `Gui, Add, Edit, Multi` | string | Click → Ctrl+A → Type |
| `dropdown` | `Gui, Add, DropDownList` | selected text | Click → Down × index → Enter |

### Assumptions
- All checkboxes in Open Dental default to **unchecked**
- Dropdown options in AHK forms match Open Dental's order exactly
- No empty/blank first option in dropdowns

---

## Required Form Header Comments

Every form script MUST include these comment lines near the top:

```ahk
; ==============================================================================
; Hillsboro OMFS Referral Slip - AHK v1
; WINDOW_TITLE: Hillsboro OMFS Referral Slip
; SPECIALIST_NAME: Hillsboro Oral & Maxillofacial Surgery
; ==============================================================================
```

| Comment | Purpose | Used By |
|---------|---------|---------|
| `WINDOW_TITLE` | AHK window title for detection | ScreenshotHelper |
| `SPECIALIST_NAME` | Text to search in Open Dental referral dropdown | CoordHelper → Mappings.ini → FormTransfer |

**Why SPECIALIST_NAME matters**: When creating a referral in Open Dental, you search for the specialist by name. This value is typed into that search field. If the specialist's name changes in Open Dental, just update the form script and re-run CoordHelper.

---

## Configuration Format

### Mappings.ini

Each form has a section with metadata and control mappings:

```ini
[HillsboroOMFS]
; Metadata (parsed from form script header comments)
_specialistName=Hillsboro Oral & Maxillofacial Surgery

; Controls - Format: varName=type,x,y[,options for dropdowns]
chkExtractions=checkbox,150,200
chkImplants=checkbox,150,224
chkBiopsy=checkbox,150,248
txtTeethArea=textfield,300,180
txtRemarks=multiline,100,500
ReferralSource=dropdown,400,80,Dr. Gabe Proulx|Dr. Curtis Wahlen|Dr. Ben Wolfe|Dr. Jae Lee

[NorthwestPerio]
_specialistName=Northwest Periodontics

chkImplantTreatment=checkbox,120,180
chkPeriodontalTreatment=checkbox,280,180
chkRecessionTreatment=checkbox,120,204
chkCrownLengthening=checkbox,280,204
chkRadiographsYes=checkbox,120,280
chkRadiographsNo=checkbox,280,280
chkWillSend=checkbox,120,304
chkPatientWillBring=checkbox,280,304
txtRemarks=multiline,100,350
ReferralSource=dropdown,400,80,Dr. Gabe Proulx|Dr. Curtis Wahlen|Dr. Ben Wolfe|Dr. Jae Lee
```

### Coordinate System
- All coordinates are **client-relative** using `CoordMode, Mouse, Client`
- Origin (0,0) is top-left corner of the window's client area
- No manual coordinate math needed - AHK handles translation automatically
- Works regardless of where window is positioned on screen

---

## Component Specifications

### 1. CoordHelper.ahk (Setup Tool)

**Purpose**: Gather Open Dental control coordinates for a form

**Usage**:
```
CoordHelper.ahk HillsboroOMFS.ahk
```

**Process**:
1. Parse target form script to extract:
   - **SPECIALIST_NAME** from header comment (for Open Dental search)
   - Control variable names (regex: `v([a-zA-Z0-9_]+)`)
   - Control types (from `Gui, Add, CheckBox|Edit|DropDownList`)
   - Dropdown options (from DropDownList definition)
2. Build list of controls needing coordinates
3. Wait for user to have "Fill Sheet" window open
4. Focus "Fill Sheet" window
5. Use `CoordMode, Mouse, Client` for capture
6. For each control:
   - Display tooltip: `"[1/23] Click on: chkExtractions (checkbox)"`
   - Wait for mouse click anywhere
   - Capture click position (already client-relative due to CoordMode)
   - Store coordinates
   - Advance to next control
7. Allow Escape key to abort at any time
8. On completion, write/update `Config/Mappings.ini` including `_specialistName`

**Parsing Details**:
```ahk
; Specialist name from header comment (required)
; SPECIALIST_NAME: Hillsboro Oral & Maxillofacial Surgery
→ _specialistName = "Hillsboro Oral & Maxillofacial Surgery"

; Checkbox detection
Gui, Main:Add, CheckBox, ... vchkExtractions, ...
→ {var: "chkExtractions", type: "checkbox"}

; Text field detection (no Multi keyword)
Gui, Main:Add, Edit, x150 y200 w300 vtxtTeethArea
→ {var: "txtTeethArea", type: "textfield"}

; Multiline detection (has Multi keyword)
Gui, Main:Add, Edit, x20 y400 w500 h100 Multi vtxtRemarks
→ {var: "txtRemarks", type: "multiline"}

; Dropdown detection (extract options after last comma)
Gui, Main:Add, DropDownList, ... vReferralSource, Dr. Gabe Proulx|Dr. Curtis Wahlen|...
→ {var: "ReferralSource", type: "dropdown", options: ["Dr. Gabe Proulx", "Dr. Curtis Wahlen", ...]}
```

---

### 2. FormTransfer.ahk (Shared Library)

**Purpose**: Transfer form data to Open Dental

**Main Function**:
```ahk
FormTransfer(formName, formData)
{
    ; Load mappings from Config/Mappings.ini
    ; Get specialist name for search
    ; Activate "Fill Sheet" window
    ; Use CoordMode, Mouse, Client for simple clicking
    ; Iterate through mappings and perform actions
}
```

**Pseudocode**:
```
Function FormTransfer(formName, formData):
    mappings = LoadMappings(formName)  ; From Mappings.ini
    specialistName = GetSpecialistName(formName)  ; For Open Dental search
    
    ; Set coordinate mode to client-relative (no manual math needed!)
    CoordMode, Mouse, Client
    
    WinActivate, Fill Sheet
    WinWaitActive, Fill Sheet,, 5
    If ErrorLevel:
        MsgBox, Could not find Fill Sheet window
        Return false
    
    For each mapping in mappings:
        value = formData[mapping.var]
        
        Switch mapping.type:
            Case "checkbox":
                If value = 1:
                    Click, mapping.x, mapping.y
                    Sleep, 50
                    
            Case "textfield", "multiline":
                If value != "":
                    Click, mapping.x, mapping.y
                    Sleep, 50
                    Send, ^a
                    Sleep, 50
                    SendInput, %value%
                    Sleep, 50
                    
            Case "dropdown":
                If value != "":
                    index = FindIndex(value, mapping.options)
                    If index > 0:
                        Click, mapping.x, mapping.y
                        Sleep, 50
                        Loop, index:
                            Send, {Down}
                            Sleep, 30
                        Send, {Enter}
                        Sleep, 50
    
    Return true
```

**Helper Functions**:
```ahk
; Find index of value in options array (1-based)
FindIndex(value, options)
{
    Loop, Parse, options, |
        If (A_LoopField = value)
            Return A_Index
    Return 0
}

; Load mappings for a form from INI
LoadMappings(formName)
{
    ; Read [formName] section from Config/Mappings.ini
    ; Parse each line into {var, type, x, y, options}
    ; Skip lines starting with _ (metadata)
    ; Return array of mappings
}

; Get specialist name for Open Dental search
GetSpecialistName(formName)
{
    ; Read _specialistName from [formName] section
    IniRead, specialistName, Config/Mappings.ini, %formName%, _specialistName
    Return specialistName
}
```

**Note**: Using `CoordMode, Mouse, Client` eliminates the need for manual coordinate translation. All `Click` commands automatically use coordinates relative to the active window's client area.

---

### 3. Form Script Changes

Each form's submit handler calls FormTransfer:

```ahk
#Include, %A_ScriptDir%\..\Lib\FormTransfer.ahk

BtnSubmit:
    Gui, Main:Submit, NoHide
    
    ; Validation...
    
    ; Get form data
    formData := GetFormData()
    
    ; Hide form during transfer
    Gui, Main:Hide
    
    ; Transfer to Open Dental
    success := FormTransfer("HillsboroOMFS", formData)
    
    ; Close form (no message)
    ExitApp
return
```

---

### 4. Launcher.ahk

**Purpose**: Main menu for selecting specialist

**Layout**:
```
┌─────────────────────────────────────┐
│     Dental Referral System          │
├─────────────────────────────────────┤
│                                     │
│   [ Hillsboro OMFS          ]       │
│                                     │
│   [ Northwest Periodontics  ]       │
│                                     │
│   [ (Future Specialist)     ]       │
│                                     │
└─────────────────────────────────────┘
```

**Behavior**:
- Each button runs the corresponding form script
- **Launcher exits** after launching the form (keeps things clean)
- Can add new specialists by adding buttons

---

## Build Phases

### Phase 1: Infrastructure
- [x] Forms directory with existing forms
- [x] Create `Config/` directory
- [x] Create empty `Config/Mappings.ini`
- [x] Create `Lib/` directory
- [x] Create `Tools/` directory (moved ScreenshotHelper)
- [x] Create `Docs/` directory with PLANNING.md

### Phase 2: CoordHelper Tool
- [ ] Create `Tools/CoordHelper.ahk`
- [ ] Implement form script parsing (control names, types, dropdown options)
- [ ] Implement coordinate capture UI (tooltips, click detection)
- [ ] Implement INI file writing

### Phase 3: FormTransfer Library
- [ ] Create `Lib/FormTransfer.ahk`
- [ ] Implement `LoadMappings()` - INI parsing
- [ ] Implement `ClickAtClient()` - coordinate translation
- [ ] Implement `FormTransfer()` - main transfer logic
- [ ] Handle all control types (checkbox, textfield, multiline, dropdown)

### Phase 4: Form Integration
- [ ] Update `HillsboroOMFS.ahk` to call FormTransfer on submit
- [ ] Update `NorthwestPerio.ahk` to call FormTransfer on submit
- [ ] Test end-to-end with real Open Dental

### Phase 5: Launcher
- [ ] Create `Launcher.ahk` with specialist buttons
- [ ] Style and polish

### Phase 6: Testing & Tuning
- [ ] Run CoordHelper for each form
- [ ] Test transfers, adjust delays if needed
- [ ] Update README.md with final documentation

---

## Configuration Values

| Setting | Value | Notes |
|---------|-------|-------|
| Action delay | 50ms | Between each action |
| Window title | "Fill Sheet" | Open Dental sheet window |
| Dropdown delay | 30ms | Between Down key presses |
| Window timeout | 5 seconds | WinWaitActive timeout |

---

## Future Enhancements

- [ ] Pre-automation clicks (navigate to create referral, open sheet)
- [ ] Error handling and retry logic
- [ ] Logging/audit trail
- [ ] Additional specialist forms

---

## Testing Checklist

For each form:
- [ ] CoordHelper successfully parses all controls
- [ ] All coordinates captured correctly
- [ ] Checkboxes click when checked
- [ ] Checkboxes don't click when unchecked
- [ ] Text fields populate correctly
- [ ] Multiline fields handle line breaks
- [ ] Dropdowns select correct option
- [ ] Form closes after transfer
- [ ] Works with "Fill Sheet" at different screen positions
