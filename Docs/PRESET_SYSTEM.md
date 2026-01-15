# Preset System Plan

## Overview

A system to save and load form presets, allowing forms to start with pre-filled values.

## Goals

1. **Minimal form changes** - Only 2 lines added per form (FORM_NAME comment + InitPresets() call)
2. **Easy preset creation** - Ctrl+Shift+S hotkey saves current form state as a preset
3. **Auto-load defaults** - Forms load `[FormName_Default]` preset on startup
4. **Command-line presets** - Launcher can pass preset name as argument

## File Structure

```
Config/
├── Mappings.ini      # Coordinates for Open Dental (generated, don't edit)
└── Presets.ini       # Form presets (created via Ctrl+Shift+S)
```

## Presets.ini Format

```ini
[Farham_Default]
ReferralSource=Dr. Gabe Proulx
txtNotes=
chkCBCTYes=0
chkCBCTNo=1
chkPAYes=0
chkPANo=1

[Farham_Urgent]
ReferralSource=Dr. Gabe Proulx
txtNotes=URGENT - Priority case
chkCBCTYes=1
chkCBCTNo=0
chkPAYes=0
chkPANo=0
```

## Library Functions (added to FormTransfer.ahk)

### InitPresets()
Called after GUI build. Parses FORM_NAME from script header, loads preset (from arg or "Default"), registers Ctrl+Shift+S hotkey.

### PS_LoadPreset(formName, presetName)
Reads `[FormName_PresetName]` section from Presets.ini, returns object with key=value pairs.

### PS_ApplyPreset(data)
Iterates through data object, sets each GUI control:
- Checkboxes: `GuiControl, Main:, varName, value`
- Text/Edit: `GuiControl, Main:, varName, value`
- Dropdowns: `GuiControl, Main:ChooseString, varName, value`

### PS_SavePreset(formName, presetName)
Gets form data via GetFormData(), writes to `[FormName_PresetName]` in Presets.ini.

### PS_GetFormName()
Reads main script file, parses `; FORM_NAME: xxx` from header comments.

## Data Flow

### Startup (load preset)
```
Form builds GUI
    ↓
InitPresets()
    ↓
PS_GetFormName() → reads header → "Farham"
    ↓
Check A_Args[1] for preset name (or use "Default")
    ↓
PS_LoadPreset("Farham", "Default")
    ↓
PS_ApplyPreset(data) → sets all controls
    ↓
Register Ctrl+Shift+S hotkey
```

### Save preset (Ctrl+Shift+S)
```
User presses Ctrl+Shift+S
    ↓
InputBox: "Enter preset name:"
    ↓
GetFormData() → collects all form values
    ↓
PS_SavePreset("Farham", userInput)
    ↓
Writes [Farham_userInput] to Presets.ini
```

### Launch with preset (future)
```
Launcher → Run Farham.ahk "Urgent"
    ↓
InitPresets() reads A_Args[1] = "Urgent"
    ↓
PS_LoadPreset("Farham", "Urgent")
```

## Form Changes Required

### Add to header comments:
```ahk
; FORM_NAME: Farham
```

### Add after GUI build:
```ahk
InitPresets()
```

## Implementation Steps

1. Add preset functions to FormTransfer.ahk
2. Update Farham.ahk (FORM_NAME + InitPresets)
3. Update NorthwestPerio.ahk (FORM_NAME + InitPresets)
4. Update HillsboroOMFS.ahk (FORM_NAME + InitPresets)
5. Test with screenshot helper
6. Create Default presets for each form using Ctrl+Shift+S

## Launcher Integration (future)

```ahk
; Vanilla - loads Default preset
LaunchFarham:
    Run, "Forms\Farham.ahk"

; Specific preset
LaunchFarhamUrgent:
    Run, "Forms\Farham.ahk" "Urgent"
```

## Notes

- Dropdowns stored by text value (readable, matches form display)
- If preset doesn't exist, form starts with empty/default values (no error)
- Ctrl+Shift+S available on all forms automatically via InitPresets()
