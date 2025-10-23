@echo off
REM Post-build script to copy PDFium DLL to output directory
REM Usage: copy-pdfium-dll.bat <Platform> <Config>
REM Example: copy-pdfium-dll.bat Win32 Debug

set PLATFORM=%1
set CONFIG=%2

if "%PLATFORM%"=="" set PLATFORM=Win32
if "%CONFIG%"=="" set CONFIG=Debug

set OUTPUT_DIR=%PLATFORM%\%CONFIG%
set SOURCE_DLL=lib\pdfium-bin\bin\pdfium.dll

echo Copying PDFium DLL to %OUTPUT_DIR%...

if not exist "%OUTPUT_DIR%" (
  echo Creating output directory: %OUTPUT_DIR%
  mkdir "%OUTPUT_DIR%"
)

if exist "%SOURCE_DLL%" (
  copy /Y "%SOURCE_DLL%" "%OUTPUT_DIR%\pdfium.dll"
  echo PDFium DLL copied successfully.
) else (
  echo ERROR: Source DLL not found: %SOURCE_DLL%
  exit /b 1
)

