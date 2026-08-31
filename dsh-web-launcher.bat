@echo off
title DSH Web
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0dsh-web.ps1"
if errorlevel 1 pause
