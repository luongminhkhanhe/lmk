@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0LMK_Builder.ps1"
if errorlevel 1 (
  echo.
  echo Khong mo duoc giao dien. Thu chuot phai RUN_LMK_BUILDER.bat va chon Run as administrator.
  pause
)
