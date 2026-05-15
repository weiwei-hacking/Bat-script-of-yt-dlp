# setup.ps1 - 增強版
function Test-CommandExists {
    param ([string]$Command)
    return $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

$needRestart = $false

# 檢查 yt-dlp
if (-not (Test-CommandExists "yt-dlp")) {
    Write-Host "yt-dlp 未安裝，正在透過 winget 安裝..." -ForegroundColor Yellow
    winget install --id yt-dlp.yt-dlp -e --accept-source-agreements --accept-package-agreements --silent
    $needRestart = $true
} else {
    Write-Host "✓ yt-dlp 已安裝" -ForegroundColor Green
}

# 檢查 FFmpeg
if (-not (Test-CommandExists "ffmpeg")) {
    Write-Host "FFmpeg 未安裝，正在安裝..." -ForegroundColor Yellow
    winget install --id Gyan.FFmpeg -e --accept-source-agreements --accept-package-agreements --silent
    $needRestart = $true
} else {
    Write-Host "✓ FFmpeg 已安裝" -ForegroundColor Green
}

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + 
            [System.Environment]::GetEnvironmentVariable("Path","User")

if ($needRestart) {
    Write-Host "`n安裝完成！正在重新啟動 BAT 腳本..." -ForegroundColor Cyan
    # 通知 BAT 要重啟
    exit 100
} else {
    Write-Host "`n所有元件皆已就緒！" -ForegroundColor Green
}
