# ==============================================================================
# Build Script for Dental Referral System
# Compiles all AHK scripts to standalone executables
# ==============================================================================

$ErrorActionPreference = "Stop"

# Configuration
$AHK_COMPILER = "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe"
$BUILD_DIR = "Build"

# Colors for output
function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "    [OK] $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "    [ERROR] $Message" -ForegroundColor Red
}

# Check if compiler exists
if (!(Test-Path $AHK_COMPILER)) {
    Write-Error "AutoHotkey compiler not found at: $AHK_COMPILER"
    Write-Host "Please install AutoHotkey v1.1.37+ from https://www.autohotkey.com/" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n========================================" -ForegroundColor Yellow
Write-Host "  Dental Referral System - Build Script" -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Yellow

# Clean and create build directory
Write-Step "Preparing build directory..."
if (Test-Path $BUILD_DIR) {
    Remove-Item -Recurse -Force $BUILD_DIR
    Write-Success "Cleaned existing build directory"
}
New-Item -Path $BUILD_DIR -ItemType Directory -Force | Out-Null
New-Item -Path "$BUILD_DIR\Forms" -ItemType Directory -Force | Out-Null
Write-Success "Created $BUILD_DIR directory"

# Compile Launchers
Write-Step "Compiling Launchers..."

# Compile original Launcher (legacy/backup)
& $AHK_COMPILER /in "Launcher.ahk" /out "$BUILD_DIR\Launcher.exe" | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Success "Launcher.exe (legacy)"
} else {
    Write-Error "Failed to compile Launcher.ahk"
    exit 1
}

# Compile dynamic Launcher (new default)
& $AHK_COMPILER /in "LauncherDynamic.ahk" /out "$BUILD_DIR\LauncherDynamic.exe" | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Success "LauncherDynamic.exe (dynamic)"
} else {
    Write-Error "Failed to compile LauncherDynamic.ahk"
    exit 1
}

# Compile Forms
Write-Step "Compiling Forms..."

# Get all .ahk files from Forms directory
$formFiles = Get-ChildItem -Path "Forms\*.ahk" -File
foreach ($formFile in $formFiles) {
    $formName = $formFile.BaseName
    $inFile = $formFile.FullName
    $outFile = "$BUILD_DIR\Forms\$formName.exe"
    
    & $AHK_COMPILER /in $inFile /out $outFile | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "$formName.exe"
    } else {
        Write-Error "Failed to compile $formName.ahk"
        exit 1
    }
}

# Copy Config files
Write-Step "Copying configuration files..."
Copy-Item -Recurse "Config" "$BUILD_DIR\Config"
Write-Success "Config folder copied"

# Copy source .ahk files (needed for dynamic launcher to read headers)
Write-Step "Copying source form files for metadata..."
Copy-Item "Forms\*.ahk" "$BUILD_DIR\Forms\"
Write-Success "Form .ahk files copied (for header metadata)"

# Create Logs directory
Write-Step "Creating Logs directory..."
New-Item -Path "$BUILD_DIR\Logs" -ItemType Directory -Force | Out-Null
Write-Success "Logs folder created"

# Copy documentation (optional)
if (Test-Path "README.md") {
    Copy-Item "README.md" "$BUILD_DIR\README.md"
    Write-Success "README.md copied"
}

# Summary
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  Build Complete!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

Write-Host "Output directory: $BUILD_DIR\"
Write-Host "`nContents:"
$buildPath = (Get-Item $BUILD_DIR).FullName
Get-ChildItem -Recurse $BUILD_DIR | ForEach-Object {
    $relativePath = $_.FullName.Replace("$buildPath\", "")
    if ($_.PSIsContainer) {
        Write-Host "  [DIR]  $relativePath" -ForegroundColor Yellow
    } else {
        $size = "{0:N2} KB" -f ($_.Length / 1KB)
        Write-Host "  [FILE] $relativePath ($size)" -ForegroundColor Gray
    }
}

Write-Host "`nDeployment Instructions:" -ForegroundColor Cyan
Write-Host "  1. Copy entire 'Build' folder to target location (e.g., O:\Script\)"
Write-Host "  2. Run Launcher.exe on the target machine"
Write-Host "  3. No AutoHotkey installation required!`n"
