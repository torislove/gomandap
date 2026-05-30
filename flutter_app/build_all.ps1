$ErrorActionPreference = "Stop"

Write-Host "Starting GoMandap Monorepo Build Check..." -ForegroundColor Cyan

# 1. Build Client App
Write-Host "Building Client App (APK)..." -ForegroundColor Yellow
Set-Location .\apps\client
& C:\flutter\bin\flutter.bat build apk --debug
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Client App Build Failed" -ForegroundColor Red
    exit 1
}
Set-Location ..\..

# 2. Build Vendor App
Write-Host "Building Vendor App (APK)..." -ForegroundColor Yellow
Set-Location .\apps\vendor
& C:\flutter\bin\flutter.bat build apk --debug
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Vendor App Build Failed" -ForegroundColor Red
    exit 1
}
Set-Location ..\..

# 3. Build Admin App
Write-Host "Building Admin App (APK)..." -ForegroundColor Yellow
Set-Location .\apps\admin
& C:\flutter\bin\flutter.bat build apk --debug
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Admin App Build Failed" -ForegroundColor Red
    exit 1
}
Set-Location ..\..

Write-Host "✅ All applications successfully compiled!" -ForegroundColor Green
