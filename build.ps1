param(
    [switch]$Install,
    [switch]$Clean
)

$ErrorActionPreference = 'Stop'

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$androidPath = Join-Path $scriptRoot 'android'

Write-Host '==========================================================' -ForegroundColor Cyan
Write-Host '👑       GOMANDAP TRIPLE-APP SYSTEM ORCHESTRATOR        👑' -ForegroundColor Yellow
Write-Host '==========================================================' -ForegroundColor Cyan

if (-Not (Test-Path $androidPath)) {
    Write-Host '❌ Error: android directory not found' -ForegroundColor Red
    Exit 1
}

Set-Location $androidPath

$tasks = @()
if ($Clean) {
    Write-Host '🧼 Requesting clean build...' -ForegroundColor Cyan
    $tasks += 'clean'
}

if ($Install) {
    Write-Host '📲 Requesting compilation and device installation...' -ForegroundColor Magenta
    $tasks += 'installDebug'
} else {
    Write-Host '🏗️ Requesting compilation (assemble debug targets)...' -ForegroundColor Green
    $tasks += 'assembleDebug'
}

$taskArgs = $tasks -join ' '
Write-Host "🚀 Executing: .\gradlew.bat $taskArgs" -ForegroundColor Yellow
Write-Host '──────────────────────────────────────────────────────────' -ForegroundColor Cyan

# Invoke gradlew directly in PowerShell
& .\gradlew.bat $tasks

$lastExitCode = $LASTEXITCODE

Set-Location $scriptRoot

Write-Host '──────────────────────────────────────────────────────────' -ForegroundColor Cyan

if ($lastExitCode -eq 0) {
    Write-Host '🎉 SUCCESS: All operations completed beautifully!' -ForegroundColor Green
    if ($Install) {
        Write-Host '📱 GoMandap Client, GmAdmin, and GoMandap Vendor apps installed!' -ForegroundColor Green
    } else {
        Write-Host '📦 Debug APKs created for Client, Admin, and Vendor applications!' -ForegroundColor Green
    }
} else {
    Write-Host '❌ ERROR: Gradle execution failed' -ForegroundColor Red
    Exit $lastExitCode
}

Write-Host '==========================================================' -ForegroundColor Cyan
