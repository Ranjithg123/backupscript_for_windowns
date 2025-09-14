@echo off
title Pro Backup Manager
echo.
echo ========================================
echo    Pro Backup Manager v2.0 Professional
echo ========================================
echo.
echo Starting application...
echo.
powershell -ExecutionPolicy Bypass -File "backups.ps1"
echo.
echo Application closed.
pause
