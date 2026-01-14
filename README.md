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

## Usage

### Running a Form
```bash
# Run directly from Forms directory
cd Forms
HillsboroOMFS.ahk
NorthwestPerio.ahk

# Or with AutoHotkey
AutoHotkey.exe Forms\HillsboroOMFS.ahk
```

### Utility Functions
Both forms include helper functions for external automation:

```ahk
SetPatientName("Smith, John")       ; Set patient name display
SetOfficeName("Custom Office Name")  ; Change office name
GetFormData()                        ; Returns object with all form values
```

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

### Common Features
- Allman brace style (per coding rules)
- Global variables for all form fields
- Event handlers for checkbox logic
- Validation on submit
- Summary display before automation

## Upcoming Features

- [ ] Open Dental automation to create referrals
- [ ] Tab-through field transfer automation
- [ ] Patient data auto-load from Open Dental
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
│   └── NorthwestPerio.ahk     # Northwest Perio referral form
├── Config/                    # Configuration files
│   └── Mappings.ini           # Control coordinates for all forms
├── Lib/                       # Shared libraries
│   └── FormTransfer.ahk       # Transfer automation logic
├── Tools/                     # Development/setup tools
│   ├── ScreenshotHelper.ahk   # Capture form screenshots
│   └── CoordHelper.ahk        # Gather Open Dental coordinates
├── Docs/                      # Documentation
│   └── PLANNING.md            # Architecture and build plan
├── Open Dental Sheets xmls/   # Source XML files
│   ├── Hillsboro OMFS
│   └── Northwest Perio
├── Launcher.ahk               # Main menu (future)
├── screenshot.png             # Latest screenshot (auto-generated)
└── README.md                  # This file
```
