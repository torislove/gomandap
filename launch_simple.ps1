<#
.SYNOPSIS
    GoMandap Simple Launcher - Simplified version with better error handling
.DESCRIPTION
    Launches Flutter apps with real-time output visible
#>

param(
    [ValidateSet("chrome", "android")]
    [string]$Device = "chrome",
    [switch]$ClientOnly,
    [switch]$VendorOnly,
    [switch]$AdminOnly,
    [switch]$Help
)

# Configuration
$FLUTTER = "C:\flutter\bin\flutter.bat"
$WORKSPACE = "C:\Users\manoj\OneDrive\Desktop\Gomandap\flutter_app"
$CLIENT_DIR = "$WORKSPACE\apps\client"
$VENDOR_DIR = "$WORKSPACE\apps\vendor"
$ADMIN_DIR = "$WORKSPACE\apps\admin"
$CLIENT_PORT = 8081
$VENDOR_PORT = 8082
$ADMIN_PORT = 8083

Write-Host ""
Write-Host "  ======================================================" -ForegroundColor Yellow
Write-Host "   GoMandap Multi-App Dev Launcher v2.1 (SIMPLIFIED)" -ForegroundColor Yellow
Write-Host "  ======================================================" -ForegroundColor Yellow
Write-Host ""

# Help
if ($Help) {
    Write-Host "USAGE:"
    Write-Host "  .\launch_simple.ps1                Launch Client in Chrome"
    Write-Host "  .\launch_simple.ps1 -ClientOnly   Launch only Client"
    Write-Host "  .\launch_simple.ps1 -VendorOnly   Launch only Vendor"
    Write-Host "  .\launch_simple.ps1 -AdminOnly    Launch only Admin"
    Write-Host "  .\launch_simple.ps1 -Device android -ClientOnly"
    Write-Host ""
    exit 0
}

# Validation
if (-not (Test-Path $FLUTTER)) {
    Write-Host "ERROR: Flutter not found at $FLUTTER" -ForegroundColor Red
    Write-Host "Please install Flutter to C:\flutter" -ForegroundColor Red
    exit 1
}

if ($Device -eq "chrome" -and -not (Test-Path "C:\Program Files\Google\Chrome\Application\chrome.exe")) {
    Write-Host "WARNING: Chrome not found. Make sure Chrome is installed." -ForegroundColor Yellow
}

# Determine which apps to launch
$apps = @()
if ($ClientOnly -or (-not $VendorOnly -and -not $AdminOnly)) {
    $apps += @{ Name = "Client"; Dir = $CLIENT_DIR; Port = $CLIENT_PORT; Color = "Cyan" }
}
if ($VendorOnly -or (-not $ClientOnly -and -not $AdminOnly)) {
    $apps += @{ Name = "Vendor"; Dir = $VENDOR_DIR; Port = $VENDOR_PORT; Color = "Magenta" }
}
if ($AdminOnly -or (-not $ClientOnly -and -not $VendorOnly)) {
    $apps += @{ Name = "Admin"; Dir = $ADMIN_DIR; Port = $ADMIN_PORT; Color = "Yellow" }
}

Write-Host "Target Device: $Device" -ForegroundColor Green
Write-Host "Apps to launch:" -ForegroundColor White
foreach ($app in $apps) {
    Write-Host "  - $($app.Name) (Port: $($app.Port))" -ForegroundColor $app.Color
}
Write-Host ""

# Kill old processes on ports
Write-Host "Clearing ports..." -ForegroundColor Cyan
foreach ($port in @($CLIENT_PORT, $VENDOR_PORT, $ADMIN_PORT)) {
    $result = netstat -ano 2>$null | Select-String ":$port\s"
    if ($result) {
        foreach ($line in @($result)) {
            $parts = $line -split '\s+' | Where-Object { $_ }
            if ($parts.Count -ge 5) {
                $procId = $parts[-1]
                if ($procId -match '^\d+$') {
                    try {
                        Stop-Process -Id ([int]$procId) -Force -ErrorAction SilentlyContinue
                        Write-Host "  Stopped process on port $port (PID: $procId)" -ForegroundColor DarkGray
                    } catch {}
                }
            }
        }
    }
}
Start-Sleep -Seconds 1

# Launch apps
$processes = @()
foreach ($app in $apps) {
    Write-Host ""
    Write-Host "================================" -ForegroundColor $app.Color
    Write-Host "Launching: $($app.Name)" -ForegroundColor $app.Color
    Write-Host "Directory: $($app.Dir)" -ForegroundColor DarkGray
    Write-Host "================================" -ForegroundColor $app.Color
    Write-Host ""

    $flutterArgs = @("run")
    if ($Device -eq "chrome") {
        $flutterArgs += @("-d", "chrome", "--web-port", $app.Port)
    } else {
        $flutterArgs += @("-d", "android")
    }
    $flutterArgs += @(
        "--dart-define=MOCK_AUTH=false",
        "--dart-define=MOCK_OTP=",
        "--dart-define=GOOGLE_PLACES_API_KEY=AIzaSyCtY8cOiQHGddusRv7s08gAaB-KIcYsJRg"
    )

    try {
        # Run Flutter and capture output
        $proc = Start-Process $FLUTTER `
            -ArgumentList $flutterArgs `
            -WorkingDirectory $app.Dir `
            -PassThru `
            -NoNewWindow `
            -ErrorAction Stop

        Write-Host "Process started (PID: $($proc.Id))" -ForegroundColor Green
        $processes += @{ Name = $app.Name; Process = $proc; Port = $app.Port; Device = $Device }
        
        Start-Sleep -Seconds 2
    } catch {
        Write-Host "ERROR: Failed to start $($app.Name): $_" -ForegroundColor Red
    }
}

if ($processes.Count -eq 0) {
    Write-Host ""
    Write-Host "ERROR: No apps were launched!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "================================" -ForegroundColor Green
Write-Host "Waiting for servers to start..." -ForegroundColor Green
Write-Host "First compile takes 30-90 seconds" -ForegroundColor DarkGray
Write-Host "================================" -ForegroundColor Green
Write-Host ""

# Wait for ports if Chrome mode
if ($Device -eq "chrome") {
    foreach ($proc in $processes) {
        $port = $proc.Port
        $name = $proc.Name
        Write-Host "Waiting for $name on port $port..." -ForegroundColor Cyan
        
        $timeout = 180
        $waited = 0
        while ($waited -lt $timeout) {
            try {
                $tcp = New-Object System.Net.Sockets.TcpClient
                $tcp.Connect("localhost", $port)
                $tcp.Close()
                Write-Host "✓ $name is live at http://localhost:$port" -ForegroundColor Green
                break
            } catch {
                Start-Sleep -Milliseconds 2000
                $waited += 2
                Write-Host "  ... still compiling ($waited/$timeout seconds)" -ForegroundColor DarkGray
            }
        }
    }
}

Write-Host ""
Write-Host "================================" -ForegroundColor Yellow
Write-Host "GoMandap Dev Suite Ready!" -ForegroundColor Yellow
Write-Host "================================" -ForegroundColor Yellow
Write-Host ""
foreach ($proc in $processes) {
    Write-Host "  [*] $($proc.Name) → http://localhost:$($proc.Port)" -ForegroundColor $proc.Color
}
Write-Host ""
Write-Host "Commands in Flutter terminal:" -ForegroundColor White
Write-Host "  r - Hot reload" -ForegroundColor DarkGray
Write-Host "  R - Hot restart" -ForegroundColor DarkGray
Write-Host "  q - Quit" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Press Ctrl+C to stop all servers" -ForegroundColor Yellow
Write-Host ""

# Keep running and wait for processes
try {
    Wait-Process -InputObject $processes.Process -ErrorAction SilentlyContinue
} catch {
    # Ctrl+C caught
}

Write-Host ""
Write-Host "Shutting down..." -ForegroundColor Red
foreach ($proc in $processes) {
    if (-not $proc.Process.HasExited) {
        try {
            $proc.Process.Kill()
            Write-Host "Stopped: $($proc.Name)" -ForegroundColor DarkGray
        } catch {}
    }
}
Write-Host "Goodbye!" -ForegroundColor Yellow
Write-Host ""
