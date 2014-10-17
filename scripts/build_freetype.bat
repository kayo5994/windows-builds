@echo off
SETLOCAL
SET EL=0

echo ----- freetype-----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download freetype-%FREETYPE_VERSION%.tar.bz2
IF ERRORLEVEL 1 GOTO ERROR

if EXIST freetype (
  echo found extracted sources
)

if NOT EXIST freetype (
  echo extracting
  CALL bsdtar xfz freetype-%FREETYPE_VERSION%.tar.bz2
  rename freetype-%FREETYPE_VERSION% freetype
  IF ERRORLEVEL 1 GOTO ERROR
)

cd freetype
IF ERRORLEVEL 1 GOTO ERROR

if "%TARGET_ARCH%"=="64" (
  echo.
  ECHO "IF building x64 add platform to solution manually!"
  ECHO.
)

ECHO building ...
msbuild ^
.\builds\windows\vc2010\freetype.sln ^
/nologo ^
/m:%NUMBER_OF_PROCESSORS% ^
/toolsversion:%TOOLS_VERSION% ^
/p:BuildInParellel=true ^
/p:Configuration=%BUILD_TYPE% ^
/p:Platform=%BUILDPLATFORM% ^
/p:PlatformToolset=%PLATFORM_TOOLSET%
IF ERRORLEVEL 1 GOTO ERROR

IF %BUILDPLATFORM% EQU x64 (
  IF %BUILD_TYPE% EQU Release (
    CALL copy /Y builds\windows\vc2010\x64\Release\freetype253.lib freetype.lib
    IF ERRORLEVEL 1 GOTO ERROR
  ) ELSE (
    CALL copy /Y objs\win64\vc2010\freetype253_D.lib freetype.lib
    IF ERRORLEVEL 1 GOTO ERROR
    CALL copy /Y objs\debug\freetype.pdb freetype.pdb
    IF ERRORLEVEL 1 GOTO ERROR
  )
) ELSE (
  IF %BUILD_TYPE% EQU Release (
    CALL copy /Y objs\win32\vc2010\freetype253.lib freetype.lib
    IF ERRORLEVEL 1 GOTO ERROR
  ) ELSE (
    CALL copy /Y objs\win32\vc2010\freetype253_D.lib freetype.lib
    IF ERRORLEVEL 1 GOTO ERROR
    CALL copy /Y objs\debug\freetype.pdb freetype.pdb
    IF ERRORLEVEL 1 GOTO ERROR
  )
)

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo -------------FREETYPE ERROR -----------------

:DONE
cd %ROOTDIR%
EXIT /b %EL%
