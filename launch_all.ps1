<#
.SYNOPSIS
    GoMandap Multi-App Development Launcher v1.0
.DESCRIPTION
    Launches Client, Vendor, and Admin Flutter apps simultaneously in Chrome.
    All apps are pre-configured with mock auth bypass (no real OTP needed).
.PARAMETER ClientOnly
    Launch only the Client Panel
.PARAMETER VendorOnly
    Launch only the Vendor Suite
.PARAMETER AdminOnly
    Launch only the Admin Portal
.PARAMETER NoBrowser
    Start dev servers but skip auto-opening Chrome windows
.PARAMETER Help
    Show this help message
.EXAMPLE
    .\launch_all.ps1                Launch all 3 apps
    .\launch_all.ps1 -ClientOnly   Launch only the Client Panel
    .\launch_all.ps1 -Help         Show usage
#>

param(
    [switch]$ClientOnly,
    [switch]$VendorOnly,
    [switch]$AdminOnly,
    [switch]$NoBrowser,
    [switch]$Help
)

# ==============================================================================
# Configuration
# ==============================================================================
$FLUTTER     = "C:\flutter\bin\flutter.bat"
$WORKSPACE   = "C:\Users\manoj\OneDrive\Desktop\Gomandap\flutter_app"
$CLIENT_DIR  = "$WORKSPACE\apps\client"
$VENDOR_DIR  = "$WORKSPACE\apps\vendor"
$ADMIN_DIR   = "$WORKSPACE\apps\admin"

# Fixed ports for each Flutter web dev server
$CLIENT_PORT = 8081
$VENDOR_PORT = 8082
$ADMIN_PORT  = 8083

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
    Write-Host "   GoMandap  ---  Multi-App Dev Launcher v1.0" -ForegroundColor Yellow
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
# Help
# ==============================================================================
if ($Help) {
    Write-Banner
    Write-Host "  USAGE:" -ForegroundColor White
    Write-Host "    .\launch_all.ps1                  Launch all 3 apps"
    Write-Host "    .\launch_all.ps1 -ClientOnly       Launch only the Client Panel"
    Write-Host "    .\launch_all.ps1 -VendorOnly       Launch only the Vendor Suite"
    Write-Host "    .\launch_all.ps1 -AdminOnly        Launch only the Admin Portal"
    Write-Host "    .\launch_all.ps1 -NoBrowser        Start servers, skip Chrome"
    Write-Host "    .\launch_all.ps1 -Help             Show this help"
    Write-Host ""
    Write-Host "  PORTS:" -ForegroundColor White
    Write-Host "    Client Panel  -->  http://localhost:$CLIENT_PORT"
    Write-Host "    Vendor Suite  -->  http://localhost:$VENDOR_PORT"
    Write-Host "    Admin Portal  -->  http://localhost:$ADMIN_PORT"
    Write-Host ""
    Write-Host "  MOCK AUTH:" -ForegroundColor White
    Write-Host "    All apps bypass real login."
    Write-Host "    Client app starts directly at /home."
    Write-Host "    Vendor and Admin apps start at their dashboards."
    Write-Host "    If you visit /login manually, use OTP: 123456"
    Write-Host ""
    exit 0
}

# ==============================================================================
# Prerequisites
# ==============================================================================
function Test-Prerequisites {
    Write-Step "Checking prerequisites..." "White"

    if (-not (Test-Path $FLUTTER)) {
        Write-Err "Flutter not found at: $FLUTTER"
        Write-Err "Update the FLUTTER variable at the top of this script."
        exit 1
    }
    Write-Ok "Flutter: $FLUTTER"

    if (-not $CHROME) {
        Write-Warn "Chrome not found in standard paths. Open Chrome manually."
    } else {
        Write-Ok "Chrome: $CHROME"
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
# Port cleanup
# ==============================================================================
function Stop-PortProcess([int]$port) {
    $result = netstat -ano 2>$null | Select-String ":$port\s"
    foreach ($line in $result) {
        $parts = ($line -split '\s+') | Where-Object { $_ -ne '' }
        $pid2  = $parts[-1]
        if ($pid2 -match '^\d+$' -and [int]$pid2 -gt 0) {
            try { Stop-Process -Id ([int]$pid2) -Force -ErrorAction SilentlyContinue } catch {}
        }
    }
}

function Clear-Ports {
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
        [string]$Color = "Cyan"
    )

    Write-Host "  +-------------------------------------------------+" -ForegroundColor $Color
    Write-Host "  |  Launching: $Name" -ForegroundColor $Color
    Write-Host "  |  URL: http://localhost:$Port" -ForegroundColor DarkGray
    Write-Host "  +-------------------------------------------------+" -ForegroundColor $Color
    Write-Host ""

    # Key dart-defines:
    #   MOCK_AUTH=true  -> login screens skip real Supabase calls
    #   MOCK_OTP=123456 -> OTP boxes are pre-filled with 123456
    $flutterArgs = @(
        "run",
        "-d", "chrome",
        "--web-port", $Port,
        "--web-renderer", "canvaskit",
        "--dart-define=MOCK_AUTH=true",
        "--dart-define=MOCK_OTP=123456"
    )

    $proc = Start-Process `
        -FilePath $FLUTTER `
        -ArgumentList $flutterArgs `
        -WorkingDirectory $Dir `
        -PassThru `
        -WindowStyle Normal

    return $proc
}

# ==============================================================================
# Wait for port helper
# ==============================================================================
function Wait-ForPort([int]$port, [string]$name, [int]$timeoutSecs = 180) {
    Write-Info "Waiting for $name on port $port (up to ${timeoutSecs}s)..."
    $deadline = (Get-Date).AddSeconds($timeoutSecs)
    while ((Get-Date) -lt $deadline) {
        try {
            $tcp = New-Object System.Net.Sockets.TcpClient
            $tcp.Connect("localhost", $port)
            $tcp.Close()
            Write-Ok "$name is live --> http://localhost:$port"
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
Test-Prerequisites
Clear-Ports

$jobs = [System.Collections.ArrayList]@()

# Determine which apps to launch
$launchClient = (-not $VendorOnly -and -not $AdminOnly) -or $ClientOnly
$launchVendor = (-not $ClientOnly -and -not $AdminOnly) -or $VendorOnly
$launchAdmin  = (-not $ClientOnly -and -not $VendorOnly) -or $AdminOnly

Write-Host "  -------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "  Launch Plan:" -ForegroundColor White
if ($launchClient) { Write-Host "    [*] Client Panel  -->  http://localhost:$CLIENT_PORT" -ForegroundColor Cyan }
if ($launchVendor) { Write-Host "    [*] Vendor Suite  -->  http://localhost:$VENDOR_PORT" -ForegroundColor Magenta }
if ($launchAdmin)  { Write-Host "    [*] Admin Portal  -->  http://localhost:$ADMIN_PORT"  -ForegroundColor Yellow }
Write-Host "  -------------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""

# Launch Client
if ($launchClient) {
    $proc = Start-FlutterApp -Name "GoMandap Client Panel" -Dir $CLIENT_DIR -Port $CLIENT_PORT -Color "Cyan"
    $null = $jobs.Add(@{ Name = "Client Panel"; Process = $proc; Port = $CLIENT_PORT })
    Start-Sleep -Seconds 3
}

# Launch Vendor
if ($launchVendor) {
    $proc = Start-FlutterApp -Name "GoMandap Vendor Suite" -Dir $VENDOR_DIR -Port $VENDOR_PORT -Color "Magenta"
    $null = $jobs.Add(@{ Name = "Vendor Suite"; Process = $proc; Port = $VENDOR_PORT })
    Start-Sleep -Seconds 3
}

# Launch Admin
if ($launchAdmin) {
    $proc = Start-FlutterApp -Name "GoMandap Admin Portal" -Dir $ADMIN_DIR -Port $ADMIN_PORT -Color "Yellow"
    $null = $jobs.Add(@{ Name = "Admin Portal"; Process = $proc; Port = $ADMIN_PORT })
}

# Wait for servers to come up
Write-Host ""
Write-Host "  -------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "  Waiting for Flutter dev servers..." -ForegroundColor White
Write-Host "  (First compile: 30-90 sec. Hot-reload after that is instant)" -ForegroundColor DarkGray
Write-Host "  -------------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""

foreach ($job in $jobs) {
    $ready = Wait-ForPort -port $job.Port -name $job.Name -timeoutSecs 180
    if ($ready) {
        Write-Info "Chrome window for $($job.Name) was opened automatically by flutter run."
    }
}

# Summary box
Write-Host ""
Write-Host "  ========================================================" -ForegroundColor DarkYellow
Write-Host "  GoMandap Dev Suite -- All Systems Live!" -ForegroundColor Yellow
Write-Host "  ========================================================" -ForegroundColor DarkYellow
if ($launchClient) { Write-Host "  [C] Client Panel  -->  http://localhost:$CLIENT_PORT" -ForegroundColor Cyan }
if ($launchVendor) { Write-Host "  [V] Vendor Suite  -->  http://localhost:$VENDOR_PORT" -ForegroundColor Magenta }
if ($launchAdmin)  { Write-Host "  [A] Admin Portal  -->  http://localhost:$ADMIN_PORT"  -ForegroundColor Yellow }
Write-Host "  --------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "  Mock Auth: ON  |  Mock OTP: 123456  |  No login needed" -ForegroundColor Green
Write-Host "  --------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "  Hot Reload  : press 'r' in each Flutter terminal window" -ForegroundColor White
Write-Host "  Hot Restart : press 'R' in each Flutter terminal window" -ForegroundColor White
Write-Host "  Quit all    : press 'q' in each Flutter terminal window" -ForegroundColor White
Write-Host "  ========================================================" -ForegroundColor DarkYellow
Write-Host ""
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
