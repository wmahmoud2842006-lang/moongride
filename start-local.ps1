# MoonGride Local Development Server Launcher
$ErrorActionPreference = "Stop"

Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "         MOONGRIDE LOCAL ENVIRONMENT LAUNCHER          " -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

$env:PHP_CLI_SERVER_WORKERS = "4"

# Locate PHP
$PhpBin = ""
if (Test-Path "$ScriptDir\php\php.exe") {
    $PhpBin = "$ScriptDir\php\php.exe"
} else {
    $found = Get-Command "php" -ErrorAction SilentlyContinue
    if ($found) {
        $PhpBin = $found.Source
    }
}

if (-not $PhpBin) {
    Write-Error "[ERROR] PHP 8.2+ executable was not found. Please ensure PHP is in PATH or in .\php\."
    exit 1
}

# Locate Python
$PythonBin = (Get-Command "python" -ErrorAction SilentlyContinue)?.Source
if (-not $PythonBin) {
    Write-Warning "[WARNING] Python not found in PATH. GeoTIFF elevation fallback requires Python with Pillow."
}

# Set GDAL Tools
$GdalBin = "$ScriptDir\tools\bin"
if (Test-Path $GdalBin) {
    $env:GDAL_BIN_DIR = $GdalBin
    $env:PATH = "$GdalBin;" + $env:PATH
}

# Public Directory
$PublicDir = "$ScriptDir\test\lunar-south-pole-backend\public"
if (-not (Test-Path $PublicDir)) {
    if (Test-Path "$ScriptDir\public") {
        $PublicDir = "$ScriptDir\public"
    }
}

$Port = 8000

Write-Host "[OK] PHP Binary:      $PhpBin" -ForegroundColor Green
Write-Host "[OK] GDAL Tools:      $GdalBin" -ForegroundColor Green
Write-Host "[OK] Web Root:        $PublicDir" -ForegroundColor Green
Write-Host "[OK] Local Server:    http://127.0.0.1:$Port" -ForegroundColor Green
Write-Host ""
Write-Host "Starting MoonGride web server... Press Ctrl+C to stop." -ForegroundColor Yellow
Write-Host ""

# Open Browser asynchronously
Start-Job -ScriptBlock {
    param($Port)
    Start-Sleep -Seconds 2
    Start-Process "http://127.0.0.1:$Port/index.html"
} -ArgumentList $Port | Out-Null

# Run server with project configuration
$PhpIni = "$ScriptDir\php\php.ini"
if (Test-Path $PhpIni) {
    & $PhpBin -c $PhpIni -S "127.0.0.1:$Port" -t "$PublicDir"
} else {
    & $PhpBin -S "127.0.0.1:$Port" -t "$PublicDir"
}
