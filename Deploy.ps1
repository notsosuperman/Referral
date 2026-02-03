# ==============================================================================
# Deploy.ps1 - Deploy built files to network server
# Copies LauncherDynamic.exe, Forms folder, and Config folder to \\server01\OfficeFiles\Script
# ==============================================================================

$deployPath = "\\server01\OfficeFiles\Script"
$buildPath = Join-Path $PSScriptRoot "Build"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Deploying to Server" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Target: $deployPath" -ForegroundColor Yellow

# Check if network path is accessible
if (!(Test-Path $deployPath))
{
    Write-Host "ERROR: Network path not accessible!" -ForegroundColor Red
    Write-Host "Path: $deployPath" -ForegroundColor Red
    exit 1
}

# Copy LauncherDynamic.exe
Write-Host ""
Write-Host "Copying LauncherDynamic.exe..." -ForegroundColor Yellow
$exePath = Join-Path $buildPath "LauncherDynamic.exe"
if (Test-Path $exePath)
{
    Copy-Item -Path $exePath -Destination (Join-Path $deployPath "LauncherDynamic.exe") -Force
    Write-Host "  [OK] LauncherDynamic.exe copied" -ForegroundColor Green
}
else
{
    Write-Host "  [ERROR] LauncherDynamic.exe not found in Build folder!" -ForegroundColor Red
    exit 1
}

# Copy Forms folder
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
    Write-Host "  [OK] Forms folder copied" -ForegroundColor Green
}
else
{
    Write-Host "  [ERROR] Forms folder not found in Build folder!" -ForegroundColor Red
    exit 1
}

# Copy Config folder
Write-Host ""
Write-Host "Copying Config folder..." -ForegroundColor Yellow
$configSource = Join-Path $buildPath "Config"
$configDest = Join-Path $deployPath "Config"
if (Test-Path $configSource)
{
    if (Test-Path $configDest)
    {
        Remove-Item -Path $configDest -Recurse -Force
    }
    Copy-Item -Path $configSource -Destination $configDest -Recurse -Force
    Write-Host "  [OK] Config folder copied" -ForegroundColor Green
}
else
{
    Write-Host "  [ERROR] Config folder not found in Build folder!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Deployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
