@echo off
rem Runs the tests, exports the web build and sends it to itch.io with butler
rem Usage: tools\push_itch.bat

set "TARGET=kozumagames/night-heist:web"
rem Set GODOT to your Godot 4.7 console executable if it isn't there
if not defined GODOT set "GODOT=%USERPROFILE%\Documents\Godot_v4.7.2-stable_win64\Godot_v4.7.2-stable_win64_console.exe"

cd /d "%~dp0.."

echo === TESTS ===
"%GODOT%" --headless --path . tests/ai_test.tscn || goto :error

echo === WEB EXPORT ===
"%GODOT%" --headless --path . --export-release "Web" exports/web/index.html || goto :error

for /f %%i in ('git rev-parse --short HEAD') do set "VERSION=%%i"
rem A build with uncommitted changes must not look like the commit
git diff --quiet HEAD || set "VERSION=%VERSION%-dirty"

echo === BUTLER PUSH %TARGET% (%VERSION%) ===
butler push exports/web %TARGET% --userversion %VERSION% || goto :error

echo Done
exit /b 0

:error
echo *** FAILED with code %errorlevel%
exit /b %errorlevel%
