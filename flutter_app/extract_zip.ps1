# Extract using standard .NET ZipFile (very reliable)
$zipPath = "$env:TEMP\flutter.zip"
$destPath = "C:\"

Write-Host "Extracting $zipPath to $destPath using .NET ZipFile..."

try {
    # Check if C:\flutter already exists and remove it to avoid conflicts
    if (Test-Path "C:\flutter") {
        Write-Host "Removing existing C:\flutter folder..."
        Remove-Item -Path "C:\flutter" -Recurse -Force -ErrorAction SilentlyContinue
    }

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $destPath)
    
    if (Test-Path "C:\flutter\bin\flutter.bat") {
        Write-Host "Extraction completely successful!"
        $env:PATH = "C:\flutter\bin;$env:PATH"
        flutter --version
    } else {
        Write-Host "Flutter executable not found in extracted files"
        exit 1
    }
} catch {
    Write-Host "Error during extraction: $_"
    exit 1
}
