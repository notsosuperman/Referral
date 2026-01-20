# Dynamic Launcher System - Planning Document

## Overview

Transform the Launcher from a hardcoded GUI to a fully dynamic system that automatically discovers forms and presets from the filesystem and configuration files. Zero maintenance required when adding new forms or presets.

## Goals

- **Zero Hardcoding**: No manual editing of Launcher when adding forms/presets
- **Automatic Discovery**: Scan filesystem and configuration files
- **Alphabetical Sorting**: Forms and presets sorted automatically
- **Simple UX**: Add form → Restart launcher → Form appears
- **Fast Performance**: <50ms startup time (imperceptible)

## Current State

**Launcher.ahk (~250 lines):**
- Hardcoded button definitions
- Hardcoded button handlers (`LaunchOMFS:`, `LaunchPerio:`, etc.)
- Manual maintenance required for each new form/preset

**Adding New Form Currently Requires:**
1. Create form .ahk file
2. Run CoordHelper
3. **Edit Launcher.ahk** (add button + handler) ← Manual step to eliminate
4. Rebuild if deploying

## Target State

**Adding New Form Will Require:**
1. Create form .ahk file
2. Run CoordHelper
3. Restart Launcher ← Done!

**Adding New Preset Will Require:**
1. Fill form
2. Press Ctrl+Shift+S
3. Save preset
4. Restart Launcher ← Done!

## Data Sources (Zero Hardcoding)

### 1. Form Metadata (from Form Headers)

**Required Header:**
```ahk
; FORM_NAME: HillsboroOMFS
```

**Optional Header (for pretty display):**
```ahk
; DISPLAY_NAME: OS - Hillsboro OMFS
```

**Extraction Method:**
- Read first 30 lines of each .ahk file
- Parse `FORM_NAME:` and `DISPLAY_NAME:` using RegEx
- Fallback to filename if headers missing

### 2. Preset Discovery (from Presets.ini)

**Format (already exists):**
```ini
[HillsboroOMFS_Wisdom Teeth]
[HillsboroOMFS_Urgent Consult]
[Farham_Default]
```

**Parsing Logic:**
- Read all section names
- Split on first underscore: `FormName_PresetName`
- Group presets by form name
- Filter out `_Default` (not shown as button)

### 3. Form Paths (from Filesystem)

**Discovery:**
```ahk
Loop, Files, Forms\*.ahk
{
    ; Store A_LoopFileFullPath
}
```

## Data Structures

### Form Object
```ahk
{
    name: "HillsboroOMFS",              ; FORM_NAME from header
    display: "OS - Hillsboro OMFS",     ; DISPLAY_NAME or fallback to name
    path: "Forms\HillsboroOMFS.ahk",    ; Full path
    presets: ["Urgent Consult", "Wisdom Teeth"]  ; Sorted array
}
```

### Button Lookup Map
```ahk
ButtonMap := {
    "OS - Hillsboro OMFS": {path: "Forms\HillsboroOMFS.ahk", preset: ""},
    "  > Urgent Consult": {path: "Forms\HillsboroOMFS.ahk", preset: "Urgent Consult"},
    "  > Wisdom Teeth": {path: "Forms\HillsboroOMFS.ahk", preset: "Wisdom Teeth"}
}
```

**Key Insight:** Button text is the key. A_GuiControl gives us the button text when clicked.

## Implementation Flow

### Phase 1: Discovery (On Launcher Startup)

```
1. DiscoverForms()
   ├─ Scan Forms\*.ahk
   ├─ For each file:
   │  ├─ Read header (first 30 lines)
   │  ├─ Extract FORM_NAME (required)
   │  ├─ Extract DISPLAY_NAME (optional)
   │  └─ Store {name, display, path}
   └─ Return array of form objects

2. DiscoverPresets()
   ├─ Read Presets.ini section names
   ├─ Parse "FormName_PresetName" format
   ├─ Filter out "_Default" sections
   ├─ Group by form name
   └─ Return map: formName → [preset1, preset2, ...]

3. MergeFormData()
   ├─ For each form:
   │  └─ Attach presets from preset map
   ├─ Sort forms alphabetically by display name
   └─ Sort presets alphabetically within each form

4. Result: Sorted array of complete form objects ready for GUI
```

### Phase 2: GUI Building

```
1. Initialize ButtonMap := {}
2. yPos := 20 (starting position)

3. For each form (in sorted order):
   
   a. Create main form button:
      ├─ Text: form.display (e.g., "OS - Hillsboro OMFS")
      ├─ Position: x20, y%yPos%
      ├─ Handler: gHandleButtonClick
      ├─ Store: ButtonMap[form.display] = {path, preset: ""}
      └─ yPos += 45
   
   b. For each preset (in sorted order):
      ├─ Text: "  > " . presetName (indented)
      ├─ Position: x40, y%yPos% (indented)
      ├─ Handler: gHandleButtonClick (same handler)
      ├─ Store: ButtonMap["  > " . presetName] = {path, preset}
      └─ yPos += 35

4. Calculate window height: yPos + 20
5. Show GUI with calculated height
```

### Phase 3: Button Click Handler

```
HandleButtonClick:
    buttonText := A_GuiControl          ; AHK provides button text
    data := ButtonMap[buttonText]       ; Lookup launch info
    
    if (!data)
    {
        MsgBox, Error: Unknown button
        return
    }
    
    LaunchForm(data.path, data.preset)  ; Existing function
return
```

## File Changes

### Forms/*.ahk (Minor Update)

**Add to existing header (if not present):**
```ahk
; DISPLAY_NAME: Pretty Name Here
```

**Forms already have FORM_NAME, so this is optional.**

**Example:**
```ahk
; FORM_NAME: HillsboroOMFS
; DISPLAY_NAME: OS - Hillsboro OMFS
; SPECIALIST_NAME: OS - Hillsboro OMFS
```

### Launcher.ahk (Major Refactor)

**Replace:**
- Hardcoded button definitions → Dynamic GUI building
- Individual button handlers → Single universal handler
- Static layout → Calculated layout

**Keep:**
- Patient context capture logic
- LaunchForm() function (already abstracts launching)
- F1 hotkey, Esc hotkey
- Window title and basic structure

**New Functions:**
```ahk
DiscoverForms()           ; Scan Forms\ directory
ParseFormHeader(path)     ; Extract metadata from form file
DiscoverPresets()         ; Parse Presets.ini
SortForms(forms)          ; Alphabetical sorting
BuildDynamicGUI(forms)    ; Generate GUI from data
HandleButtonClick:        ; Universal button handler
```

## Sorting Strategy

### Forms
- **Sort by:** `DISPLAY_NAME` (or `FORM_NAME` if no display name)
- **Method:** Bubble sort or AHK `Sort` command
- **Order:** Alphabetical (case-insensitive)

**Example Output:**
1. Endo - Wolfe Dental Cedar Mill
2. OS - Hillsboro OMFS
3. Perio - Northwest Periodontics

### Presets (within each form)
- **Sort by:** Preset name (from section name)
- **Method:** Same as forms
- **Order:** Alphabetical

**Example Output under "OS - Hillsboro OMFS":**
1. > Urgent Consult
2. > Wisdom Teeth

## Performance Considerations

### Startup Time Estimate
- Scan 3-10 files: ~2-5ms
- Read 30 lines each: ~5-10ms
- Parse Presets.ini: ~5ms
- Build GUI: ~5ms
- **Total: ~20-30ms** (imperceptible)

### Scalability
- 50 forms: ~100ms (barely noticeable)
- 100 forms: ~200ms (threshold of perception)

**Conclusion:** No caching needed. Direct discovery is fast enough.

## Error Handling

### Missing FORM_NAME
```ahk
if (!formName)
{
    ; Fallback to filename
    formName := A_LoopFileName
    formName := StrReplace(formName, ".ahk", "")
}
```

### Malformed Presets.ini
```ahk
; Skip sections that don't match pattern
if (!InStr(sectionName, "_"))
    continue
```

### File Read Errors
```ahk
FileRead, content, %path%
if (ErrorLevel)
{
    ; Log error, skip this form
    continue
}
```

## Testing Strategy

### Test Cases

**1. Basic Discovery:**
- ✅ 3 forms discovered
- ✅ All have correct names
- ✅ Sorted alphabetically

**2. Preset Discovery:**
- ✅ Presets grouped correctly by form
- ✅ Presets sorted alphabetically
- ✅ `_Default` presets filtered out

**3. GUI Building:**
- ✅ Buttons appear in correct order
- ✅ Preset buttons indented
- ✅ Window height calculated correctly

**4. Button Clicks:**
- ✅ Main button launches form without preset
- ✅ Preset button launches form with preset
- ✅ Unknown button shows error

**5. Edge Cases:**
- ✅ Form with no presets
- ✅ Form with no DISPLAY_NAME (uses FORM_NAME)
- ✅ Empty Forms\ directory
- ✅ Malformed form header

## Migration Path

### Phase 1: Core Implementation
1. Create discovery functions
2. Build dynamic GUI
3. Test with current 3 forms
4. Verify presets work

### Phase 2: Refinement
1. Add error handling
2. Improve sorting
3. Add logging for debugging

### Phase 3: Cleanup
1. Remove old hardcoded buttons
2. Remove individual handlers
3. Update documentation

### Phase 4: Validation
1. Build and test compiled version
2. Deploy to test environment
3. Verify all forms launch correctly

## Benefits Summary

### For Developers
- ✅ Add form → Done (no launcher edits)
- ✅ Less code to maintain
- ✅ Fewer merge conflicts
- ✅ Easier to understand (single handler)

### For Users
- ✅ Consistent UI (all buttons same style)
- ✅ Always sorted (easy to find)
- ✅ Automatically updated
- ✅ No manual "refresh" needed

### For System
- ✅ Scalable (works with 3 or 300 forms)
- ✅ Self-documenting (filesystem = config)
- ✅ Fast (<50ms startup)
- ✅ Robust (handles edge cases)

## Code Estimate

**Current Launcher:** ~250 lines

**New Launcher:**
- Discovery logic: ~60 lines
- GUI building: ~40 lines
- Sorting helpers: ~20 lines
- Button handler: ~10 lines
- Context capture (unchanged): ~80 lines
- **Total: ~210 lines** (actually smaller!)

**Complexity:** Medium (but worth it for maintainability)

## Success Criteria

✅ Add new form without touching Launcher code
✅ Add new preset without touching Launcher code
✅ Forms appear alphabetically
✅ Presets appear under correct form
✅ All existing functionality preserved
✅ Startup time <50ms
✅ Compiled version works correctly

## Future Enhancements (Not in Scope)

- Custom sort order (via metadata in headers)
- Form categories/groups
- Search/filter functionality
- Recently used forms at top
- Custom button colors per form
- Icons for forms

## Decision: Proceed?

**Recommendation:** Yes, implement dynamic launcher

**Rationale:**
- Significant reduction in maintenance burden
- Minimal complexity increase
- Performance is not a concern
- Better developer experience
- More professional system design

**Estimated Implementation Time:** 2-3 hours
**Risk Level:** Low (can test thoroughly before deployment)
**Maintenance Impact:** High reduction (zero touch for new forms)
