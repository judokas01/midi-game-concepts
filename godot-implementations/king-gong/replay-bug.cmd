@echo off
rem Plays a King Gong bug report back in the game: the song with the report's settings, then every
rem note, pause and setting change as it came, ending paused where the report was written, with
rem its words in the pause menu (see scripts/dev_replay.gd). The console says whether the game
rem ended up as it was when the report was written.
rem   replay-bug                  the newest report in bug-reports\
rem   replay-bug <file>           that report
rem   replay-bug [<file>] --quit  and quit once it has said so
setlocal
chcp 65001 >nul
set "GODOT=C:\game-dev\godot\Godot_v4.7.2-stable_win64_console.exe"
set "REPORT=%~1"
set "QUIT=%~2"
if /i "%REPORT%"=="--quit" (
	set "REPORT="
	set "QUIT=--quit"
)
if "%REPORT%"=="" (
	for /f "delims=" %%f in ('dir /b /o-d "%~dp0bug-reports\*.json" 2^>nul') do if not defined REPORT set "REPORT=%~dp0bug-reports\%%f"
)
if "%REPORT%"=="" (
	echo No bug reports in bug-reports\ yet: Report bug in the pause menu writes one.
	exit /b 1
)
for %%a in ("%REPORT%") do set "REPORT=%%~fa"
"%GODOT%" --path "%~dp0." -- "--replay=%REPORT%" %QUIT%
