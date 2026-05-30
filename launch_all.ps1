<#
.SYNOPSIS
    GoMandap Multi-App Development Launcher v2.0
.DESCRIPTION
    Launches Client, Vendor, and Admin Flutter apps in Chrome Web or Android Mobile (debug mode).
    All apps are pre-configured with mock auth bypass (no real OTP needed).
.PARAMETER Device
    Target device: 'chrome' (web), 'android' (mobile), 'auto' (detect - Chrome if no Android found)
    Default: 'chrome'
.PARAMETER ClientOnly
    Launch only the Client Panel
.PARAMETER VendorOnly
    Launch only the Vendor Suite
.PARAMETER AdminOnly
    Launch only the Admin Portal
.PARAMETER NoWait
    Start dev servers but skip waiting for startup completion
.PARAMETER Help
    Show this help message
.EXAMPLE
    .\launch_all.ps1                       Launch all 3 apps in Chrome
    .\launch_all.ps1 -Device android      Launch in Android mobile (debug)
    .\launch_all.ps1 -Device auto         Auto-detect device
    .\launch_all.ps1 -ClientOnly           Launch only Client in Chrome
    .\launch_all.ps1 -Device android -VendorOnly  Launch only Vendor in Android
    .\launch_all.ps1 -Help                Show usage
#>


# ==============================================================================
# Parameters
# ==============================================================================
param(
    [ValidateSet("chrome", "android", "auto")]
    [string]$Device = "chrome",
    [switch]$ClientOnly,
    [switch]$VendorOnly,
    [switch]$AdminOnly,
    [switch]$NoWait,
    [switch]$Help
)

# ==============================================================================
# Configuration & Environment Loader
# ==============================================================================
$FLUTTER     = "C:\flutter\bin\flutter.bat"
$ANDROID_SDK = $env:ANDROID_SDK_ROOT
if (-not $ANDROID_SDK -or -not (Test-Path $ANDROID_SDK)) {
    $ANDROID_SDK = $env:ANDROID_HOME
}
if (-not $ANDROID_SDK -or -not (Test-Path $ANDROID_SDK)) {
    $defaultSdk = Join-Path $env:LOCALAPPDATA "Android\Sdk"
    if (Test-Path $defaultSdk) {
        $ANDROID_SDK = $defaultSdk
    }
}
$WORKSPACE   = "C:\Users\manoj\OneDrive\Desktop\Gomandap\flutter_app"
$CLIENT_DIR  = "$WORKSPACE\apps\client"
$VENDOR_DIR  = "$WORKSPACE\apps\vendor"
$ADMIN_DIR   = "$WORKSPACE\apps\admin"

# Fixed ports for each Flutter web dev server
$CLIENT_PORT = 8081
$VENDOR_PORT = 8082
$ADMIN_PORT  = 8083

# Auto-load .env.local environment variables if present
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$envLocalPath = Join-Path $ScriptDir ".env.local"
if (Test-Path $envLocalPath) {
    Write-Host "  [--] Loading environment configurations from .env.local..." -ForegroundColor Gray
    Get-Content $envLocalPath | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith("#") -and $line.Contains("=")) {
            $key, $value = $line -split '=', 2
            $key = $key.Trim()
            $value = $value.Trim()
            
            # Remove enclosing quotes if any
            if (($value.StartsWith('"') -and $value.EndsWith('"')) -or ($value.StartsWith("'") -and $value.EndsWith("'"))) {
                $value = $value.Substring(1, $value.Length - 2)
            }
            
            if ($value) {
                # Map specific local env keys to the standard variables expected by Flutter
                if ($key -eq "NEXT_PUBLIC_SUPABASE_URL") {
                    $env:SUPABASE_URL = $value
                    Write-Host "       -> Loaded SUPABASE_URL: $value" -ForegroundColor DarkGray
                } elseif ($key -eq "NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY") {
                    $env:SUPABASE_ANON_KEY = $value
                    Write-Host "       -> Loaded SUPABASE_ANON_KEY: [Configured]" -ForegroundColor DarkGray
                } elseif ($key -eq "R2_ACCESS_KEY_ID") {
                    $env:R2_ACCESS_KEY = $value
                    Write-Host "       -> Loaded R2_ACCESS_KEY: [Configured]" -ForegroundColor DarkGray
                } elseif ($key -eq "R2_SECRET_ACCESS_KEY") {
                    $env:R2_SECRET_KEY = $value
                    Write-Host "       -> Loaded R2_SECRET_KEY: [Configured]" -ForegroundColor DarkGray
                } elseif ($key -eq "R2_ENDPOINT") {
                    $env:R2_ENDPOINT = $value
                    # Parse Account ID from R2 endpoint URL (e.g., https://<account_id>.r2.cloudflarestorage.com)
                    if ($value -match "https://([^.]+)\.r2\.cloudflarestorage\.com") {
                        $env:R2_ACCOUNT_ID = $Matches[1]
                        Write-Host "       -> Parsed R2_ACCOUNT_ID: $env:R2_ACCOUNT_ID" -ForegroundColor DarkGray
                    }
                } else {
                    [System.Environment]::SetEnvironmentVariable($key, $value, [System.EnvironmentVariableTarget]::Process)
                }
            }
        }
    }
    # Provide defaults if not specified
    if (-not $env:R2_BUCKET) {
        $env:R2_BUCKET = "gomandap-vendor-kyc"
        Write-Host "       -> R2_BUCKET (defaulted): $env:R2_BUCKET" -ForegroundColor DarkGray
    }
    Write-Host ""
}

# Chrome auto-detect
$CHROME_PATHS = @(
    "C:\Program Files\Google\Chrome\Application\chrome.exe",
    "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
    "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
)
$CHROME = $CHROME_PATHS | Where-Object { Test-Path $_ } | Select-Object -First 1

# ==============================================================================
# Logging helpers
# ==============================================================================
function Write-Banner {
    Write-Host ""
    Write-Host "  -------------------------------------------------------" -ForegroundColor DarkYellow
    Write-Host "   GoMandap  ---  Multi-App Dev Launcher v2.0" -ForegroundColor Yellow
    Write-Host "   India's Premier Wedding Portal  |  Mock Auth ON" -ForegroundColor DarkYellow
    Write-Host "  -------------------------------------------------------" -ForegroundColor DarkYellow
    Write-Host ""
}

function Write-Step([string]$msg, [string]$color = "Cyan") {
    Write-Host "  > $msg" -ForegroundColor $color
}

function Write-Ok([string]$msg) {
    Write-Host "  [OK] $msg" -ForegroundColor Green
}

function Write-Warn([string]$msg) {
    Write-Host "  [!!] $msg" -ForegroundColor Yellow
}

function Write-Err([string]$msg) {
    Write-Host "  [XX] $msg" -ForegroundColor Red
}

function Write-Info([string]$msg) {
    Write-Host "  [--] $msg" -ForegroundColor DarkGray
}

# ==============================================================================
# Device Detection & Validation
# ==============================================================================
function Get-AndroidDevices {
    <# Returns list of connected Android devices #>
    try {
        $adbPath = if ($script:ANDROID_SDK) { Join-Path $script:ANDROID_SDK "platform-tools\adb.exe" } else { "adb" }
        if (-not (Test-Path $adbPath)) {
            return @()
        }
        
        $output = & $adbPath devices 2>$null | Select-Object -Skip 1 | Where-Object { $_ -and -not $_.StartsWith("List") }
        $devices = @()
        foreach ($line in $output) {
            $parts = $line -split '\s+' | Where-Object { $_ }
            if ($parts.Count -ge 2 -and $parts[1] -eq "device") {
                $devices += $parts[0]
            }
        }
        return $devices
    } catch {
        return @()
    }
}

function Test-AndroidSDK {
    <# Validates Android SDK setup #>
    if (-not $script:ANDROID_SDK) {
        Write-Warn "ANDROID_SDK_ROOT environment variable not set"
        return $false
    }
    if (-not (Test-Path $script:ANDROID_SDK)) {
        Write-Warn "Android SDK not found at: $script:ANDROID_SDK"
        return $false
    }
    $adbPath = Join-Path $script:ANDROID_SDK "platform-tools\adb.exe"
    if (-not (Test-Path $adbPath)) {
        Write-Warn "adb not found at: $adbPath"
        return $false
    }
    return $true
}

function Resolve-Device {
    <# Determines target device based on parameter and availability #>
    param([string]$DeviceParam)
    
    if ($DeviceParam -eq "chrome") {
        return "chrome"
    } elseif ($DeviceParam -eq "android") {
        if (-not (Test-AndroidSDK)) {
            Write-Err "Android SDK not properly configured. Cannot launch on Android."
            Write-Err "Please set ANDROID_SDK_ROOT environment variable or use -Device chrome"
            exit 1
        }
        $devices = Get-AndroidDevices
        if ($devices.Count -eq 0) {
            Write-Err "No Android devices found. Please:"
            Write-Err "  - Start an Android emulator, or"
            Write-Err "  - Connect an Android device with USB debugging enabled"
            exit 1
        }
        Write-Ok "Found Android device(s): $($devices -join ', ')"
        return "android"
    } elseif ($DeviceParam -eq "auto") {
        # Auto-detect: Android if available, otherwise Chrome
        if ((Test-AndroidSDK) -and ((Get-AndroidDevices).Count -gt 0)) {
            Write-Ok "Auto-detected Android device - using Android mode"
            return "android"
        } else {
            Write-Info "No Android device found - falling back to Chrome web mode"
            return "chrome"
        }
    }
    return "chrome"
}

# ==============================================================================
# Help
# ==============================================================================
if ($Help) {
    Write-Banner
    Write-Host "  USAGE:" -ForegroundColor White
    Write-Host "    .\launch_all.ps1                           Launch all 3 apps in Chrome (default)"
    Write-Host "    .\launch_all.ps1 -Device android           Launch all 3 apps in Android mobile"
    Write-Host "    .\launch_all.ps1 -Device auto              Auto-detect Chrome or Android"
    Write-Host "    .\launch_all.ps1 -ClientOnly                Launch only Client in Chrome"
    Write-Host "    .\launch_all.ps1 -Device android -VendorOnly  Launch only Vendor in Android"
    Write-Host "    .\launch_all.ps1 -Help                     Show this help"
    Write-Host ""
    Write-Host "  DEVICES:" -ForegroundColor White
    Write-Host "    -Device chrome   : Flutter web in Chrome browser (default)"
    Write-Host "    -Device android  : Flutter native on Android device (debug mode)"
    Write-Host "    -Device auto     : Automatically select Chrome or Android"
    Write-Host ""
    if ($CHROME) {
        Write-Host "  PORTS (Chrome mode):" -ForegroundColor White
        Write-Host "    Client Panel  -->  http://localhost:$CLIENT_PORT"
        Write-Host "    Vendor Suite  -->  http://localhost:$VENDOR_PORT"
        Write-Host "    Admin Portal  -->  http://localhost:$ADMIN_PORT"
        Write-Host ""
    }
    Write-Host "  MOCK AUTH:" -ForegroundColor White
    Write-Host "    All apps bypass real login."
    Write-Host "    Client app starts directly at /home."
    Write-Host "    Vendor and Admin apps start at their dashboards."
    Write-Host "    If you visit /login manually, use OTP: 123456"
    Write-Host ""
    Write-Host "  FEATURES:" -ForegroundColor White
    Write-Host "    Hot Reload  : press 'r' in Flutter terminal"
    Write-Host "    Hot Restart : press 'R' in Flutter terminal"
    Write-Host "    Quit        : press 'q' in Flutter terminal"
    Write-Host ""
    exit 0
}

# ==============================================================================
# Prerequisites
# ==============================================================================
function Test-Prerequisites {
    Write-Step "Checking prerequisites..." "White"

    if (-not (Test-Path $script:FLUTTER)) {
        Write-Err "Flutter not found at: $script:FLUTTER"
        Write-Err "Update the FLUTTER variable at the top of this script."
        exit 1
    }
    Write-Ok "Flutter: $script:FLUTTER"

    # Device-specific checks
    if ($TargetDevice -eq "chrome") {
        if (-not $CHROME) {
            Write-Err "Chrome not found in standard paths."
            Write-Err "Install Chrome or use -Device android"
            exit 1
        }
        Write-Ok "Chrome: $CHROME"
    } elseif ($TargetDevice -eq "android") {
        if (-not (Test-AndroidSDK)) {
            exit 1
        }
        Write-Ok "Android SDK configured"
    }

    foreach ($dir in @($CLIENT_DIR, $VENDOR_DIR, $ADMIN_DIR)) {
        if (-not (Test-Path $dir)) {
            Write-Err "App directory missing: $dir"
            exit 1
        }
    }
    Write-Ok "All app directories confirmed"
    Write-Host ""
}

# ==============================================================================
# Port cleanup (Chrome web mode only)
# ==============================================================================
function Stop-PortProcess([int]$port) {
    try {
        $result = netstat -ano 2>$null | Select-String ":$port\s"
        if ($result) {
            foreach ($line in @($result)) {
                $line = [string]$line
                $parts = $line -split '\s+' | Where-Object { $_ -and $_ -ne "" }
                if ($parts.Count -ge 5) {
                    $pidIndex = $parts.Count - 1
                    $pid = $parts[$pidIndex]
                    if ($pid -match '^\d+$' -and [int]$pid -gt 0) {
                        try {
                            Stop-Process -Id ([int]$pid) -Force -ErrorAction SilentlyContinue
                            Write-Info "Stopped process on port $port (PID: $pid)"
                        } catch {}
                    }
                }
            }
        }
    } catch {}
}

function Clear-Ports {
    param([string]$device)
    
    if ($device -eq "android") {
        Write-Info "Skipping port cleanup (Android doesn't use ports)"
        Write-Host ""
        return
    }
    
    Write-Step "Clearing ports $CLIENT_PORT, $VENDOR_PORT, $ADMIN_PORT..." "White"
    Stop-PortProcess $CLIENT_PORT
    Stop-PortProcess $VENDOR_PORT
    Stop-PortProcess $ADMIN_PORT
    Start-Sleep -Milliseconds 800
    Write-Ok "Ports cleared"
    Write-Host ""
}

# ==============================================================================
# App launcher
# ==============================================================================
function Start-FlutterApp {
    param(
        [string]$Name,
        [string]$Dir,
        [int]$Port,
        [string]$Device,
        [string]$Color = "Cyan"
    )

    Write-Host "  +-------------------------------------------------+" -ForegroundColor $Color
    Write-Host "  |  Launching: $Name" -ForegroundColor $Color
    if ($Device -eq "chrome") {
        Write-Host "  |  Device: Chrome Web (Port: $Port)" -ForegroundColor DarkGray
    } else {
        Write-Host "  |  Device: Android Mobile (Debug Mode)" -ForegroundColor DarkGray
    }
    Write-Host "  +-------------------------------------------------+" -ForegroundColor $Color
    Write-Host ""

    # Base Flutter arguments
    $flutterArgs = @("run")
    
    # Device-specific configuration
    if ($Device -eq "chrome") {
        $flutterArgs += @("-d", "chrome", "--web-port", $Port)
    } else {
        $devices = Get-AndroidDevices
        if ($devices.Count -gt 0) {
            $flutterArgs += @("-d", $devices[0])
        } else {
            $flutterArgs += @("-d", "android")
        }
        $flutterArgs += "--android-skip-build-dependency-validation"
    }
    
    # Dart defines for all platforms
    $flutterArgs += @(
        "--dart-define=MOCK_AUTH=false",
        "--dart-define=MOCK_OTP=",
        "--dart-define=GOOGLE_PLACES_API_KEY=AIzaSyCtY8cOiQHGddusRv7s08gAaB-KIcYsJRg"
    )

    # Add environment variables if present
    if ($env:SUPABASE_URL)      { $flutterArgs += "--dart-define=SUPABASE_URL=$env:SUPABASE_URL" }
    if ($env:SUPABASE_ANON_KEY) { $flutterArgs += "--dart-define=SUPABASE_ANON_KEY=$env:SUPABASE_ANON_KEY" }
    if ($env:R2_ACCOUNT_ID)     { $flutterArgs += "--dart-define=R2_ACCOUNT_ID=$env:R2_ACCOUNT_ID" }
    if ($env:R2_BUCKET)         { $flutterArgs += "--dart-define=R2_BUCKET=$env:R2_BUCKET" }
    if ($env:R2_ACCESS_KEY)     { $flutterArgs += "--dart-define=R2_ACCESS_KEY=$env:R2_ACCESS_KEY" }
    if ($env:R2_SECRET_KEY)     { $flutterArgs += "--dart-define=R2_SECRET_KEY=$env:R2_SECRET_KEY" }
    if ($env:R2_PUBLIC_URL)     { $flutterArgs += "--dart-define=R2_PUBLIC_URL=$env:R2_PUBLIC_URL" }

    try {
        $proc = Start-Process `
            -FilePath $script:FLUTTER `
            -ArgumentList $flutterArgs `
            -WorkingDirectory $Dir `
            -PassThru `
            -WindowStyle Normal `
            -ErrorAction Stop

        Write-Ok "Process started (PID: $($proc.Id))"
        return $proc
    } catch {
        Write-Err "Failed to start Flutter app: $_"
        return $null
    }
}

function Wait-ForPort([int]$port, [string]$name, [int]$timeoutSecs = 360) {
    Write-Info "Waiting for $name on port $port (up to ${timeoutSecs}s)..."
    $deadline = (Get-Date).AddSeconds($timeoutSecs)
    while ((Get-Date) -lt $deadline) {
        try {
            $tcp = New-Object System.Net.Sockets.TcpClient
            $tcp.Connect("localhost", $port)
            $tcp.Close()
            Write-Ok "$name is live --> http://localhost:$port"
            if ($CHROME) {
                Write-Info "Auto-launching Chrome: http://localhost:$port"
                Start-Process $CHROME "http://localhost:$port"
            } else {
                Write-Info "Chrome not detected. Please manually visit: http://localhost:$port"
            }
            return $true
        } catch {
            Start-Sleep -Milliseconds 1500
        }
    }
    Write-Warn "$name did not respond within ${timeoutSecs}s. It may still be compiling."
    return $false
}

# ==============================================================================
# Main execution
# ==============================================================================
Write-Banner

# Resolve target device
$TargetDevice = Resolve-Device $Device
Write-Host "  -------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "  Target Device: $($TargetDevice.ToUpper())" -ForegroundColor White
Write-Host "  -------------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""

Test-Prerequisites
Clear-Ports $TargetDevice

$jobs = [System.Collections.ArrayList]@()

# Determine which apps to launch
$launchClient = (-not $VendorOnly -and -not $AdminOnly) -or $ClientOnly
$launchVendor = (-not $ClientOnly -and -not $AdminOnly) -or $VendorOnly
$launchAdmin  = (-not $ClientOnly -and -not $VendorOnly) -or $AdminOnly

# Resolve individual app devices based on platform support
$clientDev = $TargetDevice
$vendorDev = $TargetDevice
$adminDev  = $TargetDevice

function Get-AppDeviceChoice {
    param([string]$AppName, [string]$Dir, [string]$DefaultDev)
    if ($DefaultDev -eq "android" -and -not (Test-Path (Join-Path $Dir "android"))) {
        Write-Host ""
        Write-Host "  [!!] $AppName does not support Android (no 'android' directory found)." -ForegroundColor Yellow
        Write-Host "       Would you like to debug/launch this app in Chrome Web instead? [Y/n]: " -NoNewline -ForegroundColor White
        $choice = Read-Host
        if ($null -ne $choice -and $choice.Trim().ToLower() -eq "n") {
            Write-Warn "Skipping launch of $AppName."
            return $null
        } else {
            Write-Ok "Redirected $AppName to Chrome Web."
            return "chrome"
        }
    }
    return $DefaultDev
}

if ($TargetDevice -eq "android") {
    if ($launchClient) { $clientDev = Get-AppDeviceChoice -AppName "Client Panel" -Dir $CLIENT_DIR -DefaultDev $clientDev }
    if ($launchVendor) { $vendorDev = Get-AppDeviceChoice -AppName "Vendor Suite" -Dir $VENDOR_DIR -DefaultDev $vendorDev }
    if ($launchAdmin)  { $adminDev  = Get-AppDeviceChoice -AppName "Admin Portal"  -Dir $ADMIN_DIR  -DefaultDev $adminDev }
}

Write-Host "  -------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "  Launch Plan:" -ForegroundColor White
if ($launchClient -and $clientDev) {
    if ($clientDev -eq "chrome") {
        Write-Host "    [*] Client Panel  -->  http://localhost:$CLIENT_PORT (Chrome Web)" -ForegroundColor Cyan
    } else {
        Write-Host "    [*] Client Panel  -->  Android Mobile (Debug)" -ForegroundColor Cyan
    }
}
if ($launchVendor -and $vendorDev) {
    if ($vendorDev -eq "chrome") {
        Write-Host "    [*] Vendor Suite  -->  http://localhost:$VENDOR_PORT (Chrome Web)" -ForegroundColor Magenta
    } else {
        Write-Host "    [*] Vendor Suite  -->  Android Mobile (Debug)" -ForegroundColor Magenta
    }
}
if ($launchAdmin -and $adminDev) {
    if ($adminDev -eq "chrome") {
        Write-Host "    [*] Admin Portal  -->  http://localhost:$ADMIN_PORT (Chrome Web)"  -ForegroundColor Yellow
    } else {
        Write-Host "    [*] Admin Portal  -->  Android Mobile (Debug)"  -ForegroundColor Yellow
    }
}
Write-Host "  -------------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""

# Launch Client
if ($launchClient -and $clientDev) {
    $proc = Start-FlutterApp -Name "GoMandap Client Panel" -Dir $CLIENT_DIR -Port $CLIENT_PORT -Device $clientDev -Color "Cyan"
    if ($proc) {
        $null = $jobs.Add(@{ Name = "Client Panel"; Process = $proc; Port = $CLIENT_PORT; Device = $clientDev })
        Start-Sleep -Seconds 3
    }
}

# Launch Vendor
if ($launchVendor -and $vendorDev) {
    $proc = Start-FlutterApp -Name "GoMandap Vendor Suite" -Dir $VENDOR_DIR -Port $VENDOR_PORT -Device $vendorDev -Color "Magenta"
    if ($proc) {
        $null = $jobs.Add(@{ Name = "Vendor Suite"; Process = $proc; Port = $VENDOR_PORT; Device = $vendorDev })
        Start-Sleep -Seconds 3
    }
}

# Launch Admin
if ($launchAdmin -and $adminDev) {
    $proc = Start-FlutterApp -Name "GoMandap Admin Portal" -Dir $ADMIN_DIR -Port $ADMIN_PORT -Device $adminDev -Color "Yellow"
    if ($proc) {
        $null = $jobs.Add(@{ Name = "Admin Portal"; Process = $proc; Port = $ADMIN_PORT; Device = $adminDev })
    }
}

if ($jobs.Count -eq 0) {
    Write-Err "No apps were successfully launched."
    exit 1
}

# Wait for servers to come up
if (-not $NoWait) {
    $chromeJobs = $jobs | Where-Object { $_.Device -eq "chrome" }
    $androidJobs = $jobs | Where-Object { $_.Device -eq "android" }

    if ($chromeJobs -and $chromeJobs.Count -gt 0) {
        Write-Host ""
        Write-Host "  -------------------------------------------------------" -ForegroundColor DarkGray
        Write-Host "  Waiting for Flutter Web dev servers..." -ForegroundColor White
        Write-Host "  (First compile: 30-90 sec. Hot-reload after that is instant)" -ForegroundColor DarkGray
        Write-Host "  -------------------------------------------------------" -ForegroundColor DarkGray
        Write-Host ""

        foreach ($job in $chromeJobs) {
            $ready = Wait-ForPort -port $job.Port -name $job.Name -timeoutSecs 360
        }
    }
    
    if ($androidJobs -and $androidJobs.Count -gt 0) {
        Write-Host ""
        Write-Host "  -------------------------------------------------------" -ForegroundColor DarkGray
        Write-Host "  Building and deploying to Android..." -ForegroundColor White
        Write-Host "  (First build: 1-3 minutes. Please wait...)" -ForegroundColor DarkGray
        Write-Host "  -------------------------------------------------------" -ForegroundColor DarkGray
        Write-Host ""
        Start-Sleep -Seconds 5  # Give flutter time to initialize
    }
}

# Summary box
Write-Host ""
Write-Host "  ========================================================" -ForegroundColor DarkYellow
Write-Host "  GoMandap Dev Suite -- All Systems Live!" -ForegroundColor Yellow
Write-Host "  ========================================================" -ForegroundColor DarkYellow
foreach ($job in $jobs) {
    $prefix = if ($job.Name -match "Client") { "[C]" } elseif ($job.Name -match "Vendor") { "[V]" } else { "[A]" }
    $color = if ($job.Name -match "Client") { "Cyan" } elseif ($job.Name -match "Vendor") { "Magenta" } else { "Yellow" }
    
    if ($job.Device -eq "chrome") {
        Write-Host "  $prefix $($job.Name)  -->  http://localhost:$($job.Port)" -ForegroundColor $color
    } else {
        Write-Host "  $prefix $($job.Name)  -->  Android Mobile (Debug)" -ForegroundColor $color
    }
}
Write-Host "  --------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "  Mock Auth: ON  |  Mock OTP: 123456  |  No login needed" -ForegroundColor Green
Write-Host "  --------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "  Hot Reload  : press 'r' in each Flutter terminal window" -ForegroundColor White
Write-Host "  Hot Restart : press 'R' in each Flutter terminal window" -ForegroundColor White
Write-Host "  Quit all    : press 'q' in each Flutter terminal window" -ForegroundColor White
Write-Host "  ========================================================" -ForegroundColor DarkYellow
Write-Host ""
if ($TargetDevice -eq "chrome") {
    Write-Host "  TIP: Chrome should auto-open. If not, manually visit the URLs above." -ForegroundColor DarkGray
}
Write-Host "  TIP: Use -ClientOnly / -VendorOnly / -AdminOnly flags" -ForegroundColor DarkGray
Write-Host "  Press Ctrl+C here to stop all dev servers." -ForegroundColor DarkGray
Write-Host ""

# Keep console alive; wait for all child processes
try {
    $allProcs = $jobs | ForEach-Object { $_.Process } | Where-Object { $null -ne $_ }
    if ($allProcs.Count -gt 0) {
        Wait-Process -InputObject $allProcs -ErrorAction SilentlyContinue
    }
} catch {
    # Ctrl+C
} finally {
    Write-Host ""
    Write-Host "  Shutting down GoMandap Dev Suite..." -ForegroundColor Red
    foreach ($job in $jobs) {
        if ($job.Process -and -not $job.Process.HasExited) {
            try {
                $job.Process.Kill()
                Write-Info "Stopped: $($job.Name)"
            } catch {}
        }
    }
    Write-Host "  Goodbye!" -ForegroundColor DarkYellow
    Write-Host ""
}
