@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo.
echo  ============================================================
echo   光影志 - 图库更新工具
echo   正在扫描 photos 文件夹...
echo  ============================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0update-gallery.ps1"
if %errorlevel% neq 0 (
  echo.
  echo  [错误] 更新失败。请检查 update-gallery.ps1 是否存在，
  echo  或右键本文件选择"以管理员身份运行"。
  echo.
  pause
  exit /b 1
)
echo.
echo  按任意键打开网站...
pause >nul
start "" "%~dp0index.html"
