<#
.SYNOPSIS
    GOMANDAP -- Complete Firebase Setup and Deployment Script
    Installs Firebase CLI, logs you in, deploys security rules,
    and guides you through registering all 3 Android apps.

.NOTES
    Run this from the root of the Gomandap project:
        .\firebase-setup.ps1

    Prerequisites:
        - Node.js 18+ (already installed)
        - npm (already installed)
        - A Firebase project created at console.firebase.google.com
#>

$ErrorActionPreference = 'Stop'
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

# --- Banner ---
Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "   GOMANDAP -- FIREBASE FULL-STACK SETUP ORCHESTRATOR" -ForegroundColor Yellow
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Package Names:" -ForegroundColor White
Write-Host "     Client App  -->  com.gomandap.app" -ForegroundColor Green
Write-Host "     Vendor App  -->  com.gomandap.vendor" -ForegroundColor Magenta
Write-Host "     Admin App   -->  com.gomandap.admin" -ForegroundColor Cyan
Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan

# --- Step 1: Install / Verify Firebase CLI ---
Write-Host ""
Write-Host "[Step 1] Checking Firebase CLI..." -ForegroundColor Yellow

$firebaseVersion = & firebase --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK: Firebase CLI already installed: $firebaseVersion" -ForegroundColor Green
} else {
    Write-Host "   Installing Firebase CLI globally via npm..." -ForegroundColor Cyan
    npm install -g firebase-tools
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   ERROR: Failed to install Firebase CLI. Ensure npm is in PATH." -ForegroundColor Red
        Exit 1
    }
    Write-Host "   OK: Firebase CLI installed successfully!" -ForegroundColor Green
}

# --- Step 2: Firebase Login ---
Write-Host ""
Write-Host "[Step 2] Firebase Authentication..." -ForegroundColor Yellow

$loginStatus = & firebase login:list 2>&1
if ($loginStatus -match "@") {
    Write-Host "   OK: Already logged in: $loginStatus" -ForegroundColor Green
} else {
    Write-Host "   Opening browser for Firebase login (Google account)..." -ForegroundColor Cyan
    Write-Host "   IMPORTANT: Use the same Google account that owns your Firebase project." -ForegroundColor Yellow
    & firebase login
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   ERROR: Login failed. Please try again." -ForegroundColor Red
        Exit 1
    }
    Write-Host "   OK: Login successful!" -ForegroundColor Green
}

# --- Step 3: Project Selection ---
Write-Host ""
Write-Host "[Step 3] Firebase Project Configuration..." -ForegroundColor Yellow
Write-Host ""
Write-Host "   Your available Firebase projects:" -ForegroundColor Cyan
& firebase projects:list

Write-Host ""
$projectId = Read-Host "   Enter your Firebase Project ID (e.g., gomandap-prod)"

if ([string]::IsNullOrWhiteSpace($projectId)) {
    Write-Host "   ERROR: No project ID provided. Exiting." -ForegroundColor Red
    Exit 1
}

Write-Host "   Setting active project to: $projectId" -ForegroundColor Cyan
Set-Location $scriptRoot
& firebase use $projectId
if ($LASTEXITCODE -ne 0) {
    Write-Host "   ERROR: Could not switch to project '$projectId'. Check the project ID." -ForegroundColor Red
    Exit 1
}
Write-Host "   OK: Active project set to: $projectId" -ForegroundColor Green

# --- Step 4: Deploy Firestore Security Rules ---
Write-Host ""
Write-Host "[Step 4] Deploying Firestore Security Rules..." -ForegroundColor Yellow

if (Test-Path "$scriptRoot\firestore.rules") {
    & firebase deploy --only firestore:rules
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   WARNING: Firestore rules deploy failed (Firestore may not be enabled yet)." -ForegroundColor Yellow
        Write-Host "   --> Enable Cloud Firestore at: https://console.firebase.google.com/project/$projectId/firestore" -ForegroundColor Cyan
    } else {
        Write-Host "   OK: Firestore rules deployed successfully!" -ForegroundColor Green
    }
} else {
    Write-Host "   WARNING: firestore.rules not found in project root." -ForegroundColor Yellow
}

# --- Step 5: Deploy Storage Rules ---
Write-Host ""
Write-Host "[Step 5] Deploying Firebase Storage Rules..." -ForegroundColor Yellow

if (Test-Path "$scriptRoot\storage.rules") {
    & firebase deploy --only storage
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   WARNING: Storage rules deploy failed (Storage may not be enabled yet)." -ForegroundColor Yellow
        Write-Host "   --> Enable Storage at: https://console.firebase.google.com/project/$projectId/storage" -ForegroundColor Cyan
    } else {
        Write-Host "   OK: Storage rules deployed successfully!" -ForegroundColor Green
    }
} else {
    Write-Host "   WARNING: storage.rules not found in project root." -ForegroundColor Yellow
}

# --- Step 6: google-services.json Instructions ---
Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "  MANUAL STEP: Download google-services.json for each app" -ForegroundColor Yellow
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Go to: https://console.firebase.google.com/project/$projectId/settings/general" -ForegroundColor Cyan
Write-Host "  Scroll to 'Your Apps' and register these 3 Android apps:" -ForegroundColor White
Write-Host ""
Write-Host "  App 1 -- Client (Couples) App" -ForegroundColor Green
Write-Host "    Package Name: com.gomandap.app" -ForegroundColor White
Write-Host "    Save JSON to: android\app\google-services.json" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  App 2 -- Vendor (Partner) App" -ForegroundColor Magenta
Write-Host "    Package Name: com.gomandap.vendor" -ForegroundColor White
Write-Host "    Save JSON to: android\vendor\google-services.json" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  App 3 -- Admin (Operations) App" -ForegroundColor Cyan
Write-Host "    Package Name: com.gomandap.admin" -ForegroundColor White
Write-Host "    Save JSON to: android\admin\google-services.json" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Press ENTER after placing all 3 google-services.json files..." -ForegroundColor Yellow
Read-Host ""

# --- Step 7: Verify google-services.json Placement ---
Write-Host "[Step 7] Verifying google-services.json placement..." -ForegroundColor Yellow

$allPresent = $true
$jsonFiles = @(
    @{ Path = "android\app\google-services.json";    Label = "Client App (com.gomandap.app)" },
    @{ Path = "android\vendor\google-services.json"; Label = "Vendor App (com.gomandap.vendor)" },
    @{ Path = "android\admin\google-services.json";  Label = "Admin App (com.gomandap.admin)" }
)

foreach ($file in $jsonFiles) {
    $fullPath = Join-Path $scriptRoot $file.Path
    if (Test-Path $fullPath) {
        Write-Host "   OK: Found: $($file.Label)" -ForegroundColor Green
    } else {
        Write-Host "   MISSING: $($file.Label) --> $($file.Path)" -ForegroundColor Red
        $allPresent = $false
    }
}

if (-not $allPresent) {
    Write-Host ""
    Write-Host "   WARNING: Some google-services.json files are missing." -ForegroundColor Yellow
    Write-Host "   The build will fail without them. Please place them and re-run." -ForegroundColor Yellow
}

# --- Step 8: Enable Firebase Services (Links) ---
Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "  Enable these Firebase services in the console:" -ForegroundColor Yellow
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  [1] Authentication (Phone OTP + Email/Password)" -ForegroundColor White
Write-Host "      https://console.firebase.google.com/project/$projectId/authentication" -ForegroundColor Cyan
Write-Host ""
Write-Host "  [2] Cloud Firestore (Native mode, asia-south1 for India)" -ForegroundColor White
Write-Host "      https://console.firebase.google.com/project/$projectId/firestore" -ForegroundColor Cyan
Write-Host ""
Write-Host "  [3] Firebase Storage (Standard bucket)" -ForegroundColor White
Write-Host "      https://console.firebase.google.com/project/$projectId/storage" -ForegroundColor Cyan
Write-Host ""
Write-Host "  [4] Cloud Messaging (FCM -- auto-enabled with project)" -ForegroundColor White
Write-Host "      https://console.firebase.google.com/project/$projectId/messaging" -ForegroundColor Cyan
Write-Host ""

# --- Step 9: Build All 3 Apps ---
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "  [Step 9] Building all 3 Android apps with Firebase..." -ForegroundColor Yellow
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

if ($allPresent) {
    & "$scriptRoot\build.ps1"
} else {
    Write-Host "   SKIPPING build -- google-services.json files are missing." -ForegroundColor Yellow
    Write-Host "   Run '.\build.ps1' after placing them." -ForegroundColor Cyan
}

# --- Done! ---
Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "  FIREBASE SETUP COMPLETE!" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Firebase Project ID: $projectId" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Next steps to wire Firebase into the app code:" -ForegroundColor White
Write-Host "    1. FirebaseAuthRepository.kt   -- already created!" -ForegroundColor Green
Write-Host "    2. FirestoreVendorRepository.kt -- already created!" -ForegroundColor Green
Write-Host "    3. FirebaseStorageRepository.kt -- real photo/video uploads" -ForegroundColor DarkGray
Write-Host "    4. FirebaseMessagingService.kt  -- push notifications" -ForegroundColor DarkGray
Write-Host ""
