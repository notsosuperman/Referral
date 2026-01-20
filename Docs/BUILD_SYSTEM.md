# Build System Memory

## Quick Commands

**To build the project (compile to EXE):**
- VS Code: Press `Ctrl+Shift+B` (or `Cmd+Shift+B` on Mac)
- Terminal: `powershell -ExecutionPolicy Bypass -File Build.ps1`

**Output:**
- Creates `Build\` folder with all executables
- Includes: Launcher.exe, Forms\*.exe, Config\*.ini, Logs\ folder

## What Gets Compiled

1. `Launcher.exe` (from Launcher.ahk)
2. `Forms\Farham.exe` (from Forms\Farham.ahk)
3. `Forms\HillsboroOMFS.exe` (from Forms\HillsboroOMFS.ahk)
4. `Forms\NorthwestPerio.exe` (from Forms\NorthwestPerio.ahk)

## Files Included in Build

- ✅ All .exe files (compiled)
- ✅ Config\Mappings.ini
- ✅ Config\Presets.ini
- ✅ Logs\ folder (empty, auto-created)
- ✅ README.md
- ❌ Lib\ folder (compiled into EXEs, not needed)
- ❌ Tools\ folder (dev only)
- ❌ Source .ahk files (not needed)

## Deployment

1. Run build command
2. Copy entire `Build\` folder to target location (e.g., `O:\Script\`)
3. Run `Launcher.exe` on target machine
4. No AutoHotkey installation required!

## Development vs Production

- **Dev**: Run .ahk files directly with AutoHotkey
- **Prod**: Run compiled .exe files (standalone)

The Launcher automatically detects if it's running as .exe and launches form .exes instead of .ahk files.

## VS Code Tasks Available

1. **Build All (Compile to EXE)** - `Ctrl+Shift+B` - Main build task
2. **Run Launcher (Dev Mode)** - Run Launcher.ahk for testing
3. **Run Launcher (Compiled)** - Build and run Launcher.exe
4. **Clean Build Directory** - Remove Build\ folder

## Build Script Location

`Build.ps1` in project root

## Adding New Forms

When you add a new form, update `Build.ps1`:
```powershell
$forms = @("Farham", "HillsboroOMFS", "NorthwestPerio", "NewFormName")
```
