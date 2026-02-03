# ==============================================================================
# Deploy.ps1 - Deploy built files to network server
# Deploys to \\server01\OfficeFiles\Script\FormsLauncher
# NEVER overwrites Config folder (Mappings.ini, Presets.ini are server-specific)
# ==============================================================================

$deployPath = "\\server01\OfficeFiles\Script\FormsLauncher"
$buildPath = Join-Path $PSScriptRoot "Build"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Deploying to Server" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Target: $deployPath" -ForegroundColor Yellow

# Check if parent network path is accessible
$parentPath = Split-Path $deployPath -Parent
if (!(Test-Path $parentPath))
{
    Write-Host "ERROR: Network path not accessible!" -ForegroundColor Red
    Write-Host "Path: $parentPath" -ForegroundColor Red
    exit 1
}

# Create FormsLauncher directory if it doesn't exist
if (!(Test-Path $deployPath))
{
    New-Item -Path $deployPath -ItemType Directory -Force | Out-Null
    Write-Host "  [NEW] Created FormsLauncher directory" -ForegroundColor Yellow
}

# Copy LauncherDynamic.exe (always overwrite)
Write-Host ""
Write-Host "Copying LauncherDynamic.exe..." -ForegroundColor Yellow
$exePath = Join-Path $buildPath "LauncherDynamic.exe"
if (Test-Path $exePath)
{
    Copy-Item -Path $exePath -Destination (Join-Path $deployPath "LauncherDynamic.exe") -Force
    Write-Host "  [OK] LauncherDynamic.exe" -ForegroundColor Green
}
else
{
    Write-Host "  [ERROR] LauncherDynamic.exe not found in Build folder!" -ForegroundColor Red
    exit 1
}

# Copy Tools folder (always overwrite)
Write-Host ""
Write-Host "Copying Tools folder..." -ForegroundColor Yellow
$toolsSource = Join-Path $buildPath "Tools"
$toolsDest = Join-Path $deployPath "Tools"
if (Test-Path $toolsSource)
{
    if (Test-Path $toolsDest)
    {
        Remove-Item -Path $toolsDest -Recurse -Force
    }
    Copy-Item -Path $toolsSource -Destination $toolsDest -Recurse -Force
    Write-Host "  [OK] Tools folder (CoordHelper.exe)" -ForegroundColor Green
}
else
{
    Write-Host "  [WARN] Tools folder not found in Build - skipping" -ForegroundColor Yellow
}

# Copy Forms folder (always overwrite - these are code, not user data)
Write-Host ""
Write-Host "Copying Forms folder..." -ForegroundColor Yellow
$formsSource = Join-Path $buildPath "Forms"
$formsDest = Join-Path $deployPath "Forms"
if (Test-Path $formsSource)
{
    if (Test-Path $formsDest)
    {
        Remove-Item -Path $formsDest -Recurse -Force
    }
    Copy-Item -Path $formsSource -Destination $formsDest -Recurse -Force
    $formCount = (Get-ChildItem -Path $formsDest -Filter "*.exe").Count
    Write-Host "  [OK] Forms folder ($formCount form executables)" -ForegroundColor Green
}
else
{
    Write-Host "  [ERROR] Forms folder not found in Build folder!" -ForegroundColor Red
    exit 1
}

# Config folder - create if missing, NEVER overwrite existing
Write-Host ""
Write-Host "Checking Config folder..." -ForegroundColor Yellow
$configDest = Join-Path $deployPath "Config"
if (!(Test-Path $configDest))
{
    # Fresh install - create Config from templates
    $configSource = Join-Path $buildPath "Config"
    if (Test-Path $configSource)
    {
        Copy-Item -Path $configSource -Destination $configDest -Recurse -Force
        Write-Host "  [NEW] Config folder created (fresh install)" -ForegroundColor Yellow
    }
    else
    {
        New-Item -Path $configDest -ItemType Directory -Force | Out-Null
        Write-Host "  [NEW] Empty Config folder created" -ForegroundColor Yellow
    }
}
else
{
    Write-Host "  [SKIP] Config folder exists - preserving Mappings.ini & Presets.ini" -ForegroundColor Cyan
}

# Create Logs folder if missing
$logsDest = Join-Path $deployPath "Logs"
if (!(Test-Path $logsDest))
{
    New-Item -Path $logsDest -ItemType Directory -Force | Out-Null
    Write-Host "  [NEW] Logs folder created" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Deployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Deployed to: $deployPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "Contents:" -ForegroundColor Yellow
Write-Host "  - LauncherDynamic.exe (run this)" -ForegroundColor Gray
Write-Host "  - Forms\ (compiled forms + .ahk for metadata)" -ForegroundColor Gray
Write-Host "  - Tools\ (CoordHelper.exe for Dev Mode)" -ForegroundColor Gray
Write-Host "  - Config\ (Mappings.ini, Presets.ini - PRESERVED)" -ForegroundColor Gray
Write-Host "  - Logs\ (runtime logs)" -ForegroundColor Gray
Write-Host ""
