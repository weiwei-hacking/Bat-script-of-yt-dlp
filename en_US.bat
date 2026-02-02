@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Set download directory
set "DOWNLOAD_DIR=%userprofile%\downloads"

:CHECK_FFMPEG
echo Checking ffmpeg...
where ffmpeg >nul 2>&1
if %errorlevel% neq 0 (
    echo ffmpeg not found, preparing to install...
    call :INSTALL_FFMPEG
    goto CHECK_FFMPEG
) else (
    echo [OK] ffmpeg is installed
)

:CHECK_YTDLP
echo Checking yt-dlp...
where yt-dlp >nul 2>&1
if %errorlevel% neq 0 (
    echo yt-dlp not found, preparing to install...
    call :INSTALL_YTDLP
    goto CHECK_YTDLP
) else (
    echo [OK] yt-dlp is installed
    echo Updating yt-dlp...
    yt-dlp -U
)

:MAIN_LOOP
cls
set /p "URL=Enter the URL you want to download: "
if "!URL!"=="" goto MAIN_LOOP

echo.
echo Select download type: [1] Video or [2] Audio
choice /c 12 /n /m "Your choice: "
set "CHOICE=!errorlevel!"

if "!CHOICE!"=="1" (
    call :DOWNLOAD_VIDEO "!URL!"
) else (
    call :DOWNLOAD_AUDIO "!URL!"
)

echo.
echo Download completed!
echo.
choice /c YN /m "Continue downloading other content"
if !errorlevel! equ 1 goto MAIN_LOOP

echo Thank you for using! Goodbye!
timeout /t 1 >nul
exit

:INSTALL_FFMPEG
set "TEMP_BAT=%temp%\install_ffmpeg.bat"
(
echo @echo off
echo chcp 65001 ^>nul
echo echo Downloading ffmpeg...
echo.
echo :: Download ffmpeg
echo curl -L "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip" -o "%temp%\ffmpeg.zip"
echo.
echo :: Extract
echo echo Extracting...
echo powershell -command "Expand-Archive -Path '%temp%\ffmpeg.zip' -DestinationPath '%temp%\ffmpeg_extract' -Force"
echo.
echo :: Move to target directory
echo if not exist "C:\ffmpeg" mkdir "C:\ffmpeg"
echo xcopy /E /I /Y "%temp%\ffmpeg_extract\ffmpeg-master-latest-win64-gpl\bin" "C:\ffmpeg"
echo.
echo :: Add to system PATH
echo setx /M PATH "%%PATH%%;C:\ffmpeg"
echo.
echo :: Clean up temporary files
echo del "%temp%\ffmpeg.zip"
echo rmdir /s /q "%temp%\ffmpeg_extract"
echo.
echo echo ffmpeg installation completed!
echo timeout /t 2
) > "%TEMP_BAT%"

echo Administrator privileges required to install ffmpeg...
powershell -Command "Start-Process '%TEMP_BAT%' -Verb RunAs -Wait"
del "%TEMP_BAT%"

:: Refresh environment variables
call :REFRESH_ENV
exit /b

:INSTALL_YTDLP
set "TEMP_BAT=%temp%\install_ytdlp.bat"
(
echo @echo off
echo chcp 65001 ^>nul
echo echo Downloading yt-dlp...
echo.
echo :: Create directory
echo if not exist "C:\yt-dlp" mkdir "C:\yt-dlp"
echo.
echo :: Download yt-dlp
echo curl -L "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe" -o "C:\yt-dlp\yt-dlp.exe"
echo.
echo :: Add to system PATH
echo setx /M PATH "%%PATH%%;C:\yt-dlp"
echo.
echo echo yt-dlp installation completed!
echo timeout /t 2
) > "%TEMP_BAT%"

echo Administrator privileges required to install yt-dlp...
powershell -Command "Start-Process '%TEMP_BAT%' -Verb RunAs -Wait"
del "%TEMP_BAT%"

:: Refresh environment variables
call :REFRESH_ENV
exit /b

:REFRESH_ENV
:: Refresh environment variables for current command prompt
for /f "tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path') do set "SYS_PATH=%%b"
for /f "tokens=2*" %%a in ('reg query "HKCU\Environment" /v Path 2^>nul') do set "USER_PATH=%%b"
set "PATH=%SYS_PATH%;%USER_PATH%"
exit /b

:DOWNLOAD_VIDEO
set "VIDEO_URL=%~1"
set "TEMP_VIDEO_BAT=%temp%\download_video.bat"
set "OUTPUT_FORMAT=%%%%(title)s.%%%%(ext)s"

>"%TEMP_VIDEO_BAT%" echo @echo off
>>"%TEMP_VIDEO_BAT%" echo setlocal
>>"%TEMP_VIDEO_BAT%" echo.
>>"%TEMP_VIDEO_BAT%" echo echo Downloading video...
>>"%TEMP_VIDEO_BAT%" echo.
>>"%TEMP_VIDEO_BAT%" echo cd /d "%DOWNLOAD_DIR%"
>>"%TEMP_VIDEO_BAT%" echo.
>>"%TEMP_VIDEO_BAT%" echo yt-dlp --output "%OUTPUT_FORMAT%" -f "bestvideo+bestaudio[ext=m4a]" -S vcodec:h264 --embed-thumbnail --add-metadata --merge-output-format mp4 --no-playlist "%VIDEO_URL%"
>>"%TEMP_VIDEO_BAT%" echo.
>>"%TEMP_VIDEO_BAT%" echo echo.
>>"%TEMP_VIDEO_BAT%" echo echo Download finished.

call "%TEMP_VIDEO_BAT%"
del "%TEMP_VIDEO_BAT%"
exit /b

:DOWNLOAD_AUDIO
set "AUDIO_URL=%~1"
set "TEMP_AUDIO_BAT=%temp%\download_audio.bat"
set "OUTPUT_FORMAT=%%%%(title)s.%%%%(ext)s"

>"%TEMP_AUDIO_BAT%" echo @echo off
>>"%TEMP_AUDIO_BAT%" echo setlocal
>>"%TEMP_AUDIO_BAT%" echo.
>>"%TEMP_AUDIO_BAT%" echo echo Downloading audio...
>>"%TEMP_AUDIO_BAT%" echo.
>>"%TEMP_AUDIO_BAT%" echo cd /d "%DOWNLOAD_DIR%"
>>"%TEMP_AUDIO_BAT%" echo.
>>"%TEMP_AUDIO_BAT%" echo yt-dlp --output "%OUTPUT_FORMAT%" --embed-thumbnail --add-metadata --extract-audio --audio-format mp3 --audio-quality 320K --no-playlist "%AUDIO_URL%"
>>"%TEMP_AUDIO_BAT%" echo.
>>"%TEMP_AUDIO_BAT%" echo echo.

call "%TEMP_AUDIO_BAT%"
del "%TEMP_AUDIO_BAT%"
exit /b