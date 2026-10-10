@echo OFF
setlocal EnableDelayedExpansion
cd /d "%~dp0"
set REPO=%CD%
echo ============================================
echo  materialgram one-click build
echo  repo: %REPO%
echo ============================================

where git >nul 2>nul
if %errorlevel% neq 0 ( echo [FAIL] need Git for Windows. & pause & exit /b 1 )
where python >nul 2>nul
if %errorlevel% neq 0 ( echo [FAIL] need Python 3.10+. & pause & exit /b 1 )
where cmake >nul 2>nul
if %errorlevel% neq 0 ( echo [FAIL] need CMake. & pause & exit /b 1 )
where ninja >nul 2>nul
if %errorlevel% neq 0 ( echo [FAIL] need Ninja. & pause & exit /b 1 )

set VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe
if not exist "%VSWHERE%" ( echo [FAIL] need Visual Studio 2022/2026 with C++ tools. & pause & exit /b 1 )
for /f "usebackq tokens=*" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set VSDIR=%%i
if not defined VSDIR ( echo [FAIL] VS C++ tools not found. & pause & exit /b 1 )
echo [OK] VS: %VSDIR%
call "%VSDIR%\VC\Auxiliary\Build\vcvars64.bat" -vcvars_ver=14.44
if %errorlevel% neq 0 ( echo [FAIL] vcvars failed. & pause & exit /b 1 )

echo [1/4] preparing ThirdParty libraries (takes a while)...
cd /d "%REPO%\.."
call "%REPO%\Telegram\build\prepare\win.bat" silent
if %errorlevel% neq 0 ( echo [FAIL] prepare failed. & pause & exit /b 1 )

echo [2/4] configuring...
cd /d "%REPO%\Telegram"
call configure.bat x64 -D TDESKTOP_API_ID=33728218 -D TDESKTOP_API_HASH=2c416c3a6e867f9c67169a6c8506990b -D CMAKE_CONFIGURATION_TYPES=MinSizeRel
if %errorlevel% neq 0 ( echo [FAIL] configure failed. & pause & exit /b 1 )

echo [3/4] building (go drink tea, this takes hours)...
cmake --build ..\out --config MinSizeRel --parallel
if %errorlevel% neq 0 ( echo [FAIL] build failed. & pause & exit /b 1 )

echo [4/4] collecting...
if not exist "%REPO%\DIST" mkdir "%REPO%\DIST"
copy /y "%REPO%\out\MinSizeRel\materialgram.exe" "%REPO%\DIST\"
copy /y "%REPO%\out\MinSizeRel\Updater.exe" "%REPO%\DIST\"
echo ============================================
echo  DONE. exe here: %REPO%\DIST\materialgram.exe
echo ============================================
pause
