@echo off

FOR /F "usebackq tokens=3*" %%A IN (`reg query "HKCU\Software\Embarcadero\BDS\22.0" /v RootDir`) DO set EmbSourceDir=%%A %%B 
set EmbSourceDir=%EmbSourceDir:~0,-1%source

FOR %%a IN ("%%~dp0") DO set "ProjectDir=%%~dpa"
IF %ProjectDir:~-1%==\ SET ProjectDir=%ProjectDir:~0,-1%

if not exist "%ProjectDir%\..\..\..\Source\Alcinoe.inc" goto ERROR

SET FileName=%ProjectDir%\fmx
IF EXIST "%FileName%" rmdir /s /q "%FileName%"
IF EXIST "%FileName%" goto ERROR
mkdir "%FileName%"

SET FileName=%ProjectDir%\rtl
IF EXIST "%FileName%" rmdir /s /q "%FileName%"
IF EXIST "%FileName%" goto ERROR
mkdir "%FileName%"
mkdir "%FileName%\ios"
mkdir "%FileName%\android"
mkdir "%FileName%\win"
mkdir "%FileName%\net"

echo Copy "%EmbSourceDir%\fmx" to "%ProjectDir%\fmx"
xcopy "%EmbSourceDir%\fmx" "%ProjectDir%\fmx"
IF ERRORLEVEL 1 goto ERROR
echo.

IF EXIST "%EmbSourceDir%\rtl\ios" (
  echo Copy "%EmbSourceDir%\rtl\ios" to "%ProjectDir%\rtl\ios"
  xcopy "%EmbSourceDir%\rtl\ios" "%ProjectDir%\rtl\ios"
  IF ERRORLEVEL 1 goto ERROR
  echo.
)

IF EXIST "%EmbSourceDir%\rtl\android" (
  echo Copy "%EmbSourceDir%\rtl\android" to "%ProjectDir%\rtl\android"
  xcopy "%EmbSourceDir%\rtl\android" "%ProjectDir%\rtl\android"
  IF ERRORLEVEL 1 goto ERROR
  echo.
)

echo Copy "%EmbSourceDir%\rtl\win" to "%ProjectDir%\rtl\win"
xcopy "%EmbSourceDir%\rtl\win" "%ProjectDir%\rtl\win"
IF ERRORLEVEL 1 goto ERROR
echo.

echo Copy "%EmbSourceDir%\rtl\net" to "%ProjectDir%\rtl\net"
xcopy "%EmbSourceDir%\rtl\net" "%ProjectDir%\rtl\net"
IF ERRORLEVEL 1 goto ERROR
echo.

echo Patch the source code
CHDIR ".\..\..\..\"
git apply --ignore-space-change --ignore-whitespace .\Embarcadero\Alexandria\11_2\Alexandria_11_2.patch -v
CHDIR "%ProjectDir%"
echo.

FOR %%a IN ("%ProjectDir%\rtl\win\*") DO IF /i NOT "%%~nxa"=="Winapi.Isapi2.pas" DEL "%%a"

REM add <UTF8BOM>{$HINTS OFF}{ at the beginning of each .pas
SET TmpFileName=%ProjectDir%\~temp.pas
set "RemoveUTF8BOM=(pause & pause & pause)>nul"
for /f "delims=" %%a IN ('dir /b /s %ProjectDir%\*.pas') do (
  IF EXIST "%TmpFileName%" del "%TmpFileName%"
  IF EXIST "%TmpFileName%" goto ERROR
  echo ﻿{$HINTS OFF}{>"%TmpFileName%"
  type "%%a">>"%TmpFileName%"
  del "%%a"
  move "%TmpFileName%" "%%a" >nul
)

:FINISHED
@echo Finished
PAUSE
goto EXIT 

:ERROR
pause

:EXIT