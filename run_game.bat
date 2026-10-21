@echo off
setlocal
rem Run DALBEAR with a local Godot 4.7.1 editor.
rem Set the GODOT_EXE environment variable, or put `godot` on PATH.
if not defined GODOT_EXE set "GODOT_EXE=godot"
"%GODOT_EXE%" --path "%~dp0"
endlocal
