> Добавление редактора групповой политики (gpedit.msc) в Windows 11 Home
```powershell
@echo off
pushd "%~dp0"
dir /b %SystemRoot%\servicing\Packages\Microsoft-Windows-GroupPolicy-ClientExtensions-Package~3*.mum >List.txt
dir /b %SystemRoot%\servicing\Packages\Microsoft-Windows-GroupPolicy-ClientTools-Package~3*.mum >>List.txt
for /f %%i in ('findstr /i . List.txt 2^>nul') do dism /online /norestart /add-package:"%SystemRoot%\servicing\Packages\%%i"
pause
```
## Local User and Group Management
https://github.com/akruhler/AccountManagement/releases/download/1.6.3/lusrmgr.exe  
или  
 ![Local User and Group Management](../Files/lusrmgr.exe)
