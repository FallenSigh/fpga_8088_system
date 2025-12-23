@echo off

if "%1"=="" (
    echo Usage: build.bat ^<basename^>
    echo Example: build.bat main
    exit /b 1
)

set NAME=%1

ml /c /Fl %NAME%.asm
link %NAME%.obj < nul
python exe2hex.py %NAME%.exe rom.hex
rm %NAME%.exe
rm %NAME%.obj
