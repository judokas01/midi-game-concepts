@echo off
rem Plays one King Gong song on the game's piano, its tune and chords, at 80 BPM, and prints
rem each bar as it starts (see scripts/play_song.gd). Ctrl+C stops it.
rem   play-song 57              song 57 (play-song list shows the numbers)
rem   play-song "skakal pes"    by part of its name, accents optional
rem   play-song 57 60           at 60 BPM
rem   play-song 57 80 tune      the tune alone, no chords
rem   play-song list            every song: number, difficulty, category, name
setlocal
chcp 65001 >nul
set "GODOT=C:\game-dev\godot\Godot_v4.7.2-stable_win64_console.exe"
set "RUN="%GODOT%" --path "%~dp0." --display-driver headless --audio-driver WASAPI --script res://scripts/play_song.gd --"
if "%~1"=="" (
	echo Which song? play-song ^<number or name^> [bpm] [tune], or play-song list
	exit /b 1
)
if /i "%~1"=="list" (
	%RUN% --list
	exit /b
)
set "BPM=%~2"
if "%BPM%"=="" set "BPM=80"
set "EXTRA="
if /i "%~3"=="tune" set "EXTRA=--tune"
%RUN% "--song=%~1" "--bpm=%BPM%" %EXTRA%
