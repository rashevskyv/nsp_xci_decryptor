@echo off
Title Downloading keys.ini
Set "url=https://pastebin.com/raw/GQesC1bj"
Set "file=keys.txt"
Call :Download "%url%" "%file%"
::*********************************************************************************
:Download <url> <file>
Powershell.exe -command "(New-Object System.Net.WebClient).DownloadFile('%1','%2')"
exit /b
::*********************************************************************************