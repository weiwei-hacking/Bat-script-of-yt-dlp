@echo off
chcp 65001 >nul
title YouTube Downloader (yt-dlp + ffmpeg)
setlocal enabledelayedexpansion
cls

:: ====================== 檢查並安裝 yt-dlp + ffmpeg ======================
where yt-dlp.exe >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] yt-dlp.exe 未在 Path 中，開始透過 winget 安裝官方版本...
    winget install -e --id yt-dlp.yt-dlp --silent --accept-source-agreements --accept-package-agreements
)

where ffmpeg.exe >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] ffmpeg.exe 未在 Path 中，開始透過 winget 安裝官方版本...
    winget install -e --id Gyan.FFmpeg --silent --accept-source-agreements --accept-package-agreements
)

:: 刷新目前視窗的 PATH（安裝後立即生效）
echo.
echo [INFO] 正在刷新系統 Path...
for /f "usebackq tokens=*" %%a in (`powershell -NoProfile -Command "[System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')"`) do set "PATH=%%a"

:: 再次確認是否安裝成功
where yt-dlp.exe >nul 2>&1 && where ffmpeg.exe >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] 安裝失敗，請關閉此視窗後重新執行腳本。
    pause
    exit
)

:: 如果原本就都有，執行更新
where yt-dlp.exe >nul 2>&1 && where ffmpeg.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo [INFO] 正在更新 yt-dlp 到最新版本...
    yt-dlp -U
)

cls

:paste
echo =============================================
echo       YouTube Downloader 已準備就緒
echo =============================================
echo.
echo Paste your link here:
set /p "link="

if "%link%"=="" (
    cls
    echo [ERROR] 連結不能為空，請重新輸入。
    goto paste
)

:select
cls
echo Please use keyboard 1, 2, 3, C to choose a type
echo [1] Video     [2] Audio     [3] Repaste link     [C] Close
choice /c 123C /n
if errorlevel 4 goto end
if errorlevel 3 cls & goto paste
if errorlevel 2 goto audio_download
if errorlevel 1 goto video_download

:video_download
echo.
echo [1] 正在下載最高畫質 + 最高音質 MP4（單一影片，不下載清單）...
yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format mp4 --no-playlist -o "%userprofile%\Downloads\%%(title)s.%%(ext)s" "%link%"
echo.
echo Download complete, did you want keep use downloader?
choice /c yn /m ""
if errorlevel 2 timeout /t 3 & goto end
if errorlevel 1 cls & goto paste

:audio_download
echo.
echo [2] 正在下載最高音質 MP3（單一影片，不下載清單）...
yt-dlp -f "bestaudio/best" --extract-audio --audio-format mp3 --no-playlist -o "%userprofile%\Downloads\%%(title)s.%%(ext)s" "%link%"
echo.
echo Download complete, did you want keep use downloader?
choice /c yn /m ""
if errorlevel 2 timeout /t 3 & goto end
if errorlevel 1 cls & goto paste

:end
echo.
echo 正在關閉...
timeout /t 2 >nul
exit