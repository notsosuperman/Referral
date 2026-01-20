# Dental Referral Forms - AHK Project

AutoHotkey v1 forms for creating and managing dental referrals, based on Open Dental Sheet XML exports.

## Forms

### Hillsboro OMFS (`HillsboroOMFS.ahk`)
Referral form for **Hillsboro Oral & Maxillofacial Surgery**

**Features:**
- Patient Name and Referring Dentist (header)
- Contact preference (Please call patient / Patient will call)
- Teeth/area to be treated
- Procedures: Extractions, Implants, Biopsy, Alveoloplasty, Frenectomy, Exposure/Bond, Incision/Drainage, Cone Beam CT, Other
- Consultations: Dental implants, Sinus Lift, Bone grafting, Facial Trauma, Oral Pathology, Soft tissue grafting, Skin lesions, Other
- Radiograph requests: Enclosed/Emailed, Given to patient, Please take new ones
- Management, Medical or Treatment concerns (notes)

### Northwest Perio (`NorthwestPerio.ahk`)
Referral form for **Northwest Periodontics & Dental Implants**

**Features:**
- Patient Name and Referring Dentist (header)
- Treatment Requested: Implant, Periodontal, Recession, Crown Lengthening
- Radiographs: Yes/No, Will Send/Patient Will Bring
- Remarks (notes)

### Farham (`Farham.ahk`)
Referral form for **Farham**

**Features:**
- Patient Name and Referring Doctor (header)
- For Treatment Including (notes field)
- Full Mouth X-Rays / Pano: Mailed, With Patient, Please Take
- Was a CBCT taken? (Y/N)
- Was PA taken? (Y/N)

## Usage

### Development Mode

**Running the Launcher:**
```powershell
AutoHotkeyU64.exe Launcher.ahk
```

**Running Forms Directly:**
```powershell
# Standalone mode - manual F1 workflow
AutoHotkeyU64.exe Forms\HillsboroOMFS.ahk

# With preset
AutoHotkeyU64.exe Forms\HillsboroOMFS.ahk "" "" "Wisdom Teeth"
```

### Production Deployment

**Building Executables:**

Option 1 - VS Code (Recommended):
1. Press `Ctrl+Shift+B` or `Cmd+Shift+B`
2. Select "Build All (Compile to EXE)"

Option 2 - Terminal:
```powershell
powershell -ExecutionPolicy Bypass -File Build.ps1
```

Output: `Build\` folder with all executables

**Deploying to Production:**
1. Copy entire `Build\` folder to target location (e.g., `O:\Script\`)
2. Run `Launcher.exe` on target machine
3. No AutoHotkey installation required!

**Behavior:**
- If Open Dental is found but not active: Shows tooltip, waits for you to activate OD and press F1
- If Open Dental is not found: Uses test data (`Smith, John`) for development/testing
- Captures patient name from OD window title
- Passes patient context to forms automatically

### Running Tools from Terminal
```powershell
# Screenshot a form
AutoHotkeyU64.exe Tools\ScreenshotHelper.ahk Farham.ahk

# Run CoordHelper to capture Open Dental coordinates
AutoHotkeyU64.exe Tools\CoordHelper.ahk Farham.ahk
```

### Utility Functions
All forms include helper functions:

```ahk
SetPatientName("Smith, John")       ; Set patient name display
SetOfficeName("Custom Office Name")  ; Change office name
GetFormData()                        ; Returns object with all form values (reads from Mappings.ini)
```

**Important:** `GetFormData()` now automatically reads field names from `Mappings.ini`, so you must run `CoordHelper.ahk` for each form before submitting. If mappings are missing, a user-friendly error will appear.

## Development Tools

### Screenshot Helper (`ScreenshotHelper.ahk`)
Automated screenshot tool for form development and testing. **Automatically detects** the window by reading the `WINDOW_TITLE` comment from the target script.

**Usage:**
```bash
# Default (screenshots HillsboroOMFS.ahk)
ScreenshotHelper.ahk

# Specify target form
ScreenshotHelper.ahk NorthwestPerio.ahk
```

**How it works:**
1. Reads the target script file
2. Finds the `; WINDOW_TITLE:` comment line
3. Launches the target AHK script
4. Waits for window with that title to appear
5. Captures screenshot to `screenshot.png`
6. Closes the form window
7. Exits

**No manual configuration needed!** Just ensure each form has the `WINDOW_TITLE` comment.

## Form Design Guidelines

All referral forms must follow these standards:

### Required Header Comments
Every form MUST include these comment lines in the header:
```ahk
; WINDOW_TITLE: Your Form Window Title Here
; SPECIALIST_NAME: Specialist Name As It Appears In Open Dental
```
- `WINDOW_TITLE` - Used by ScreenshotHelper to detect the window
- `SPECIALIST_NAME` - Used for Open Dental referral search (stored in Mappings.ini)

### Standard Layout Structure
1. **Header Section** (lines 1-3):
   - Office Name (display only, 14pt Bold Navy)
   - Patient Name (display only, 12pt Normal)
   - Referring Dentist dropdown (same for all forms)
   
2. **Main Content**: Form-specific fields and checkboxes

3. **Footer Section** (last elements):
   - Clear Form button (left side, 100px wide)
   - Submit Referral button (right side, 120-140px wide)

### Standard Elements

**Header:**
```ahk
; Office Name
Gui, Main:Font, s14 Bold, Arial
Gui, Main:Add, Text, x20 y10 w[width] cNavy vTxtOfficeName, %OfficeName%

; Patient Name
yPos += 28
Gui, Main:Font, s12 Normal, Arial
Gui, Main:Add, Text, x20 y%yPos% w[width] vTxtPatientName, Patient: %PatientName%

; Referring Dentist
yPos += 28
Gui, Main:Font, s10 Normal, Arial
Gui, Main:Add, Text, x20 y%yPos% w100 h22 +0x200, Referring Dentist:
Gui, Main:Add, DropDownList, x125 y%yPos% w180 vReferralSource, |Dr. Gabe Proulx|Dr. Curtis Wahlen|Dr. Ben Wolfe|Dr. Jae Lee
```

**Buttons:**
```ahk
Gui, Main:Font, s10 Bold, Arial
Gui, Main:Add, Button, x20 y%yPos% w100 h35 gBtnClearForm, Clear Form
Gui, Main:Add, Button, x[right-160] y%yPos% w140 h35 gBtnSubmit Default, Submit Referral
```

### Required Utility Functions
Every form must include:
- `SetPatientName(name)` - Updates patient name display
- `SetOfficeName(name)` - Updates office name display
- `GetFormData()` - Returns object with all form values

### GetFormData() Rule
**The key names in `GetFormData()` MUST match the GUI variable names exactly.**

```ahk
; GUI control definition:
Gui, Main:Add, CheckBox, ... vchkExtraction, Extraction(s)
Gui, Main:Add, Edit, ... vtxtManagementNotes

; GetFormData() - use the SAME variable names as keys:
GetFormData()
{
    Gui, Main:Submit, NoHide
    
    data := {}
    data.chkExtraction := chkExtraction           ; ✓ Key matches var name
    data.txtManagementNotes := txtManagementNotes ; ✓ Key matches var name
    
    return data
}
```

This is required because CoordHelper scrapes the GUI variable names and stores them in `Mappings.ini`. FormTransfer then looks up values using those same names.

### Common Features
- Allman brace style (per coding rules)
- Global variables for all form fields
- Event handlers for checkbox logic
- Validation on submit
- Summary display before automation

## Implemented Features

- [x] Open Dental automation - transfers form data to Fill Sheet
- [x] CoordHelper - captures control coordinates from Open Dental
- [x] Launcher - main menu to select specialist forms
- [x] Preset system - save/load form presets with auto-fill

## Preset System

Forms auto-load a `Default` preset on startup, pre-filling controls with saved values.

### Save a Preset
1. Fill out the form with desired values
2. Press **Ctrl+Shift+S**
3. Enter a preset name (e.g., "Urgent", "Routine")
4. Preset saved to `Config/Presets.ini`

### Load a Preset
```powershell
# Load Default preset (automatic)
AutoHotkeyU64.exe Forms\Farham.ahk

# Load specific preset
AutoHotkeyU64.exe Forms\Farham.ahk "Urgent"
```

### Presets.ini Format
```ini
[Farham_Default]
ReferralSource=Dr. Gabe Proulx
txtNotes=
chkCBCTYes=0
chkCBCTNo=1

[Farham_Urgent]
ReferralSource=Dr. Gabe Proulx
txtNotes=URGENT - Priority case
chkCBCTYes=1
chkCBCTNo=0
```

## Upcoming Features

- [ ] Patient data auto-load from Open Dental
- [ ] Pre-automation clicks (navigate to create referral, open sheet)
- [ ] Additional referral forms as needed

## Technical Details

- **Language:** AutoHotkey v1
- **Based on:** Open Dental Sheet XML exports
- **Window sizes:**
  - HillsboroOMFS: 620x750
  - NorthwestPerio: 540x480

## Project Structure

```
Referral/
├── Forms/                     # Referral form scripts
│   ├── HillsboroOMFS.ahk      # Hillsboro OMFS referral form
│   ├── NorthwestPerio.ahk     # Northwest Perio referral form
│   ├── Farham.ahk             # Farham referral form
│   └── Logs/                  # Form logs (auto-created)
├── Config/                    # Configuration files
│   ├── Mappings.ini           # Control coordinates for all forms
│   └── Presets.ini            # Form presets (auto-fill values)
├── Lib/                       # Shared libraries
│   ├── FormTransfer.ahk       # Transfer automation + preset system
│   ├── ODAutomation.ahk       # Open Dental navigation
│   └── Logging.ahk            # Debug logging functions
├── Tools/                     # Development/setup tools
│   ├── ScreenshotHelper.ahk   # Capture form screenshots
│   └── CoordHelper.ahk        # Gather Open Dental coordinates
├── Docs/                      # Documentation
│   ├── PLANNING.md            # Architecture and build plan
│   ├── PRESET_SYSTEM.md       # Preset system documentation
│   └── OD_NAVIGATION_PLAN.md  # Open Dental automation plan
├── Resources/                 # Reference code
│   ├── Combo Master.ahk       # Pattern reference
│   └── iTeroClick.ahk         # Pattern reference
├── Open Dental Sheets xmls/   # Source XML files
│   ├── Hillsboro OMFS
│   ├── Northwest Perio
│   └── Farham
├── Launcher.ahk               # Main menu
├── Logs/                      # Launcher logs (auto-created)
├── screenshot.png             # Latest screenshot (auto-generated)
└── README.md                  # This file
```

### Logging

Logs are created relative to the **main script** being run:
- Running `Forms\Farham.ahk` → Creates `Forms\Logs\referral.log`
- Running `Launcher.ahk` → Creates `Logs\referral.log`

This means when deployed to `O:\Script\`, logs will automatically be in `O:\Script\Logs\` (no hardcoding needed).

### Hotkeys

- **Esc**: Exit script immediately (works even during automation with BlockInput)
- **F1**: Capture Open Dental context (Launcher only, when OD not initially active)
- **Ctrl+Shift+S**: Save current form state as preset
