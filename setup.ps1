function Test-CommandExists {
    param (
        [string]$Command
    )

    return $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

$needRefresh = $false

# 檢查 ffmpeg
if (-not (Test-CommandExists "ffmpeg")) {
    Write-Host "ffmpeg not found, installing..."
    winget install --id Gyan.FFmpeg -e --accept-source-agreements --accept-package-agreements
    $needRefresh = $true
}
else {
    Write-Host "ffmpeg already installed."
}

# 檢查 yt-dlp
if (-not (Test-CommandExists "yt-dlp")) {
    Write-Host "yt-dlp not found, installing..."
    winget install --id yt-dlp.yt-dlp -e --accept-source-agreements --accept-package-agreements
    $needRefresh = $true
}
else {
    Write-Host "yt-dlp already installed."
}

# 更新 PATH
if ($needRefresh) {
    $env:Path = [System.Environment]::GetEnvironmentVariable(
        "Path",
        "Machine"
    ) + ";" + [System.Environment]::GetEnvironmentVariable(
        "Path",
        "User"
    )

    Write-Host "PATH refreshed."
}

Write-Host "Setup completed."