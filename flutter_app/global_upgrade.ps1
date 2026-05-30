$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Starting Global Flutter Pub Upgrade...   " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Find all pubspec.yaml files, excluding known build/cache directories
$pubspecs = Get-ChildItem -Path . -Filter "pubspec.yaml" -Recurse | Where-Object {
    $_.FullName -notmatch "\\build\\" -and 
    $_.FullName -notmatch "\\\.dart_tool\\" -and 
    $_.FullName -notmatch "\\windows\\" -and
    $_.FullName -notmatch "\\\.pub-cache\\"
}

foreach ($pubspec in $pubspecs) {
    $dir = $pubspec.DirectoryName
    Write-Host ">>> Processing module at: $($dir.Replace($PWD.Path, ''))" -ForegroundColor Yellow
    
    Push-Location -Path $dir
    
    try {
        Write-Host "Running flutter pub upgrade --major-versions..." -ForegroundColor DarkGray
        C:\flutter\bin\flutter.bat pub upgrade --major-versions
        
        Write-Host "Running flutter pub get..." -ForegroundColor DarkGray
        C:\flutter\bin\flutter.bat pub get
        
        Write-Host "SUCCESS: Updated $dir" -ForegroundColor Green
    }
    catch {
        Write-Host "ERROR: Failed to update $dir" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
    finally {
        Pop-Location
    }
    Write-Host "------------------------------------------" -ForegroundColor DarkGray
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Global Upgrade Complete!                 " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
