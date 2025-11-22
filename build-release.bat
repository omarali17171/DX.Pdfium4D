@echo off
setlocal

REM Check if version parameter is provided
if "%1"=="" (
    echo ERROR: Version parameter required!
    echo Usage: build-release.bat VERSION [upload]
    echo Example: build-release.bat v1.1.0
    echo Example: build-release.bat v1.1.0 upload
    exit /b 1
)

set VERSION=%1
set UPLOAD_FLAG=%2

echo ========================================
echo Building DX PDF Viewer Release %VERSION%
echo ========================================
echo.

REM Set Delphi environment
call "C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\rsvars.bat"

REM Clean previous builds
echo Cleaning previous builds...
if exist "src\PdfViewer\Win32\Release" rmdir /s /q "src\PdfViewer\Win32\Release"
if exist "src\PdfViewer\Win64\Release" rmdir /s /q "src\PdfViewer\Win64\Release"
if exist "release" rmdir /s /q "release"

echo.
echo ========================================
echo Building Win32 Release...
echo ========================================
msbuild src\PdfViewer\DX.PdfViewer.dproj /t:Build /p:Config=Release /p:Platform=Win32 /v:minimal
if errorlevel 1 (
    echo ERROR: Win32 build failed!
    exit /b 1
)

echo.
echo ========================================
echo Building Win64 Release...
echo ========================================
msbuild src\PdfViewer\DX.PdfViewer.dproj /t:Build /p:Config=Release /p:Platform=Win64 /v:minimal
if errorlevel 1 (
    echo ERROR: Win64 build failed!
    exit /b 1
)

echo.
echo ========================================
echo Creating release packages...
echo ========================================

REM Create release directories
mkdir release\DX.PdfViewer-Win32
mkdir release\DX.PdfViewer-Win64

REM Copy Win32 files
echo Copying Win32 files...
copy "src\PdfViewer\Win32\Release\DX.PdfViewer.exe" "release\DX.PdfViewer-Win32\"
copy "lib\pdfium-bin\bin\pdfium.dll" "release\DX.PdfViewer-Win32\"
copy "samples\*.pdf" "release\DX.PdfViewer-Win32\"
copy "README.md" "release\DX.PdfViewer-Win32\"
copy "LICENSE" "release\DX.PdfViewer-Win32\"

REM Copy Win64 files
echo Copying Win64 files...
copy "src\PdfViewer\Win64\Release\DX.PdfViewer.exe" "release\DX.PdfViewer-Win64\"
copy "lib\pdfium-bin\bin\pdfium.dll" "release\DX.PdfViewer-Win64\"
copy "samples\*.pdf" "release\DX.PdfViewer-Win64\"
copy "README.md" "release\DX.PdfViewer-Win64\"
copy "LICENSE" "release\DX.PdfViewer-Win64\"

echo.
echo ========================================
echo Creating ZIP archives...
echo ========================================

REM Create ZIP files using PowerShell with explicit module import
powershell -NoProfile -ExecutionPolicy Bypass -Command "Import-Module Microsoft.PowerShell.Archive -ErrorAction Stop; Compress-Archive -Path 'release\DX.PdfViewer-Win32\*' -DestinationPath 'release\DX.PdfViewer-%VERSION%-Win32.zip' -Force"
if errorlevel 1 (
    echo ERROR: Failed to create Win32 ZIP archive!
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "Import-Module Microsoft.PowerShell.Archive -ErrorAction Stop; Compress-Archive -Path 'release\DX.PdfViewer-Win64\*' -DestinationPath 'release\DX.PdfViewer-%VERSION%-Win64.zip' -Force"
if errorlevel 1 (
    echo ERROR: Failed to create Win64 ZIP archive!
    exit /b 1
)

echo.
echo ========================================
echo Build Complete!
echo ========================================
echo.
echo Release packages created:
echo - release\DX.PdfViewer-%VERSION%-Win32.zip
echo - release\DX.PdfViewer-%VERSION%-Win64.zip
echo.

REM Upload to GitHub if requested
if /i "%UPLOAD_FLAG%"=="upload" (
    echo ========================================
    echo Uploading to GitHub Release %VERSION%
    echo ========================================
    echo.

    REM Check if GITHUB_TOKEN is set
    if "%GITHUB_TOKEN%"=="" (
        echo ERROR: GITHUB_TOKEN environment variable not set!
        echo Please set GITHUB_TOKEN before uploading.
        echo Example: set GITHUB_TOKEN=ghp_your_token_here
        exit /b 1
    )

    powershell -ExecutionPolicy Bypass -File upload-assets.ps1 -ReleaseTag "%VERSION%" -Win32Zip "release\DX.PdfViewer-%VERSION%-Win32.zip" -Win64Zip "release\DX.PdfViewer-%VERSION%-Win64.zip"

    if errorlevel 1 (
        echo ERROR: Upload failed!
        exit /b 1
    )

    echo.
    echo ========================================
    echo Upload Complete!
    echo ========================================
    echo.
) else (
    echo.
    echo To upload to GitHub, run:
    echo build-release.bat %VERSION% upload
    echo.
)

endlocal

