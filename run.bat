@echo off
REM تشغيل PowerShell مع تجاوز سياسة التنفيذ مؤقتاً
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1"
pause
