# ========================================
# Requirements file installer | by Grok AI
# ========================================

function Test-CommandExists {
    param ([string]$Command)
    return $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

Write-Host "Requirements file installer" -ForegroundColor Cyan

$needRestart = $false

# Check yt-dlp
if (-not (Test-CommandExists "yt-dlp")) {
    Write-Host "yt-dlp is not installed. Installing via winget..." -ForegroundColor Yellow
    winget install --id yt-dlp.yt-dlp -e --accept-source-agreements --accept-package-agreements --silent
    $needRestart = $true
} else {
    Write-Host "✓ yt-dlp is already installed" -ForegroundColor Green
}

# Check FFmpeg
if (-not (Test-CommandExists "ffmpeg")) {
    Write-Host "FFmpeg is not installed. Installing via winget..." -ForegroundColor Yellow
    winget install --id Gyan.FFmpeg -e --accept-source-agreements --accept-package-agreements --silent
    $needRestart = $true
} else {
    Write-Host "✓ FFmpeg is already installed" -ForegroundColor Green
}

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + 
            [System.Environment]::GetEnvironmentVariable("Path","User")

if ($needRestart) {
    Write-Host "`nInstallation completed! Restarting the BAT script..." -ForegroundColor Cyan
    # Exit with code 100 to let BAT know it needs to restart
    exit 100
} else {
    Write-Host "`nAll components are ready!" -ForegroundColor Green
}
