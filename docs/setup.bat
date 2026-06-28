@echo off
chcp 65001 >nul
title RustDesk 一键配置 - hhc.gqru.com

echo ============================================
echo   RustDesk 一键配置脚本
echo   服务器: hhc.gqru.com
echo   固定密码: kulacc123Q
echo ============================================
echo.

:: 1. 停止 RustDesk
echo [1/5] 停止 RustDesk 进程和服务...
taskkill /f /im rustdesk.exe 2>nul
taskkill /f /im rustdesk-service.exe 2>nul
sc stop rustdesk 2>nul
timeout /t 2 /nobreak >nul

:: 2. 配置目录
echo [2/5] 准备配置目录...
set "RUSTDESK_DIR=%APPDATA%\RustDesK"
if not exist "%RUSTDESK_DIR%" mkdir "%RUSTDESK_DIR%"

:: 3. 写入服务器配置（RustDesk2.toml）
echo [3/5] 写入 ID服务器、中继、Key、API 配置...
(
echo rendezvous_server = 'hhc.gqru.com:21116'
echo nat_type = 0
echo serial = 0
echo.
echo [options]
echo allow-remote-config-modification = 'Y'
echo custom-rendezvous-server = 'hhc.gqru.com'
echo relay-server = 'hhc.gqru.com'
echo key = 'LEdIKvbiBTLZIdeWDLtE8mYyvO07+sY4EFypb9a0NgA='
echo api-server = 'http://hhc.gqru.com:8585'
echo direct-server = 'Y'
) > "%RUSTDESK_DIR%\RustDesk2.toml"

:: 4. 用 PowerShell 算密码 hash 并写入 RustDesk.toml
echo [4/5] 计算并写入固定密码（kulacc123Q）...
powershell -ExecutionPolicy Bypass -Command ^
$salt = -join ((34..126) -ne 39 -ne 92 ^| Get-Random -Count 12 ^| %% { [char]$_ }); ^
$password = 'kulacc123Q'; ^
$bytes = [System.Text.Encoding]::UTF8.GetBytes($password + $salt); ^
$hash = [System.Security.Cryptography.SHA256]::Create().ComputeHash($bytes); ^
$b64 = [Convert]::ToBase64String($hash); ^
$passField = '00' + $b64; ^
@^"
password = '$passField'
salt = '$salt'
key_pair = [
    []
]
"@ ^| Out-File -FilePath "%RUSTDESK_DIR%\RustDesk.toml" -Encoding utf8

:: 5. 完成
echo [5/5] 配置完成！
echo.
echo   ✅ 服务器: hhc.gqru.com
echo   ✅ 密钥: LEdIKvbiBTLZIdeWDLtE8mYyvO07+sY4EFypb9a0NgA=
echo   ✅ API: http://hhc.gqru.com:8585
echo   ✅ 中继: hhc.gqru.com
echo   ✅ 远程配置修改: 已允许
echo   ✅ 固定密码: kulacc123Q （已写入）
echo.
echo ============================================
echo   正在启动 RustDesk...
echo ============================================
timeout /t 2 /nobreak >nul

:: 启动
if exist "%~dp0rustdesk.exe" (
    start "" "%~dp0rustdesk.exe"
) else (
    echo 未找到 rustdesk.exe，请手动启动程序。
    pause
)
