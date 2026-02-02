@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 设定下载资料夹
set "DOWNLOAD_DIR=%userprofile%\downloads"

:CHECK_FFMPEG
echo 正在检查 ffmpeg...
where ffmpeg >nul 2>&1
if %errorlevel% neq 0 (
echo 找不到 ffmpeg，准备安装...
call :INSTALL_FFMPEG
goto CHECK_FFMPEG
) else (
echo [OK] ffmpeg 已安装
)

:CHECK_YTDLP
echo 正在检查 yt-dlp...
where yt-dlp >nul 2>&1
if %errorlevel% neq 0 (
echo 找不到 yt-dlp，准备安装...
call :INSTALL_YTDLP
goto CHECK_YTDLP
) else (
echo [OK] yt-dlp 已安装
echo.
echo 正在更新 yt-dlp...
yt-dlp -U
)

:MAIN_LOOP
cls
set /p "URL=请输入要下载的 URL: "
if "!URL!"=="" goto MAIN_LOOP

echo.
echo 选择下载类型: [1] 影片 或 [2] 音讯
choice /c 12 /n /m "请选择: "
set "CHOICE=!errorlevel!"

if "!CHOICE!"=="1" (
call :DOWNLOAD_VIDEO "!URL!"
) else (
call :DOWNLOAD_AUDIO "!URL!"
)

echo.
echo 下载完成!
echo.
choice /c YN /m "要继续下载其他内容吗?"
if !errorlevel! equ 1 goto MAIN_LOOP

echo 感谢使用! 再见!
timeout /t 1 >nul
exit

:INSTALL_FFMPEG
set "TEMP_BAT=%temp%\install_ffmpeg.bat"
(
echo @echo off
echo chcp 65001 ^>nul
echo echo 正在下载 ffmpeg...
echo.
echo :: 下载 ffmpeg
echo curl -L "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip" -o "%temp%\ffmpeg.zip"
echo.
echo :: 解压缩
echo echo 正在解压缩...
echo powershell -command "Expand-Archive -Path '%temp%\ffmpeg.zip' -DestinationPath '%temp%\ffmpeg_extract' -Force"
echo.
echo :: 移动到目标资料夹
echo if not exist "C:\ffmpeg" mkdir "C:\ffmpeg"
echo xcopy /E /I /Y "%temp%\ffmpeg_extract\ffmpeg-master-latest-win64-gpl\bin" "C:\ffmpeg"
echo.
echo :: 加入系统 PATH
echo setx /M PATH "%%PATH%%;C:\ffmpeg"
echo.
echo :: 清理暂存档
echo del "%temp%\ffmpeg.zip"
echo rmdir /s /q "%temp%\ffmpeg_extract"
echo.
echo echo ffmpeg 安装完成!
echo timeout /t 2
) > "%TEMP_BAT%"

echo 安装 ffmpeg 需要管理员权限...
powershell -Command "Start-Process '%TEMP_BAT%' -Verb RunAs -Wait"
del "%TEMP_BAT%"

:: 重新整理环境变数
call :REFRESH_ENV
exit /b

:INSTALL_YTDLP
set "TEMP_BAT=%temp%\install_ytdlp.bat"
(
echo @echo off
echo chcp 65001 ^>nul
echo echo 正在下载 yt-dlp...
echo.
echo :: 建立资料夹
echo if not exist "C:\yt-dlp" mkdir "C:\yt-dlp"
echo.
echo :: 下载 yt-dlp
echo curl -L "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe" -o "C:\yt-dlp\yt-dlp.exe"
echo.
echo :: 加入系统 PATH
echo setx /M PATH "%%PATH%%;C:\yt-dlp"
echo.
echo echo yt-dlp 安装完成!
echo timeout /t 2
) > "%TEMP_BAT%"

echo 安装 yt-dlp 需要管理员权限...
powershell -Command "Start-Process '%TEMP_BAT%' -Verb RunAs -Wait"
del "%TEMP_BAT%"

:: 重新整理环境变数
call :REFRESH_ENV
exit /b

:REFRESH_ENV
:: 重新整理目前命令提示字元的环境变数
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
>>"%TEMP_VIDEO_BAT%" echo echo 正在下载影片...
>>"%TEMP_VIDEO_BAT%" echo.
>>"%TEMP_VIDEO_BAT%" echo cd /d "%DOWNLOAD_DIR%"
>>"%TEMP_VIDEO_BAT%" echo.
>>"%TEMP_VIDEO_BAT%" echo yt-dlp --output "%OUTPUT_FORMAT%" -f "bestvideo+bestaudio[ext=m4a]" -S vcodec:h264 --embed-thumbnail --add-metadata --merge-output-format mp4 --no-playlist "%VIDEO_URL%"
>>"%TEMP_VIDEO_BAT%" echo.
>>"%TEMP_VIDEO_BAT%" echo echo.
>>"%TEMP_VIDEO_BAT%" echo echo 下载完成。

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
>>"%TEMP_AUDIO_BAT%" echo echo 正在下载音讯...
>>"%TEMP_AUDIO_BAT%" echo.
>>"%TEMP_AUDIO_BAT%" echo cd /d "%DOWNLOAD_DIR%"
>>"%TEMP_AUDIO_BAT%" echo.
>>"%TEMP_AUDIO_BAT%" echo yt-dlp --output "%OUTPUT_FORMAT%" --embed-thumbnail --add-metadata --extract-audio --audio-format mp3 --audio-quality 320K --no-playlist "%AUDIO_URL%"
>>"%TEMP_AUDIO_BAT%" echo.
>>"%TEMP_AUDIO_BAT%" echo echo.

call "%TEMP_AUDIO_BAT%"
del "%TEMP_AUDIO_BAT%"
exit /b