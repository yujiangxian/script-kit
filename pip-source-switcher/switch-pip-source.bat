@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: pip 源一键切换脚本 (Windows 版本)
:: 支持多个国内镜像源，自动测试可用性并切换

:: pip 配置文件路径
set "PIP_CONF_DIR=%USERPROFILE%\pip"
set "PIP_CONF_FILE=%PIP_CONF_DIR%\pip.ini"

:: 定义镜像源列表
set "SOURCE_1_NAME=清华大学"
set "SOURCE_1_URL=https://pypi.tuna.tsinghua.edu.cn/simple"
set "SOURCE_2_NAME=阿里云"
set "SOURCE_2_URL=https://mirrors.aliyun.com/pypi/simple/"
set "SOURCE_3_NAME=中国科技大学"
set "SOURCE_3_URL=https://pypi.mirrors.ustc.edu.cn/simple/"
set "SOURCE_4_NAME=豆瓣"
set "SOURCE_4_URL=https://pypi.douban.com/simple/"
set "SOURCE_5_NAME=华为云"
set "SOURCE_5_URL=https://repo.huaweicloud.com/repository/pypi/simple"
set "SOURCE_6_NAME=腾讯云"
set "SOURCE_6_URL=https://mirrors.cloud.tencent.com/pypi/simple"
set "SOURCE_7_NAME=网易"
set "SOURCE_7_URL=https://mirrors.163.com/pypi/simple/"
set "SOURCE_8_NAME=官方源"
set "SOURCE_8_URL=https://pypi.org/simple"

:: 主函数
if "%~1"=="" goto :interactive_menu
if /i "%~1"=="auto" goto :auto_select
if /i "%~1"=="show" goto :show_current
if /i "%~1"=="tsinghua" goto :set_tsinghua
if /i "%~1"=="tuna" goto :set_tsinghua
if /i "%~1"=="aliyun" goto :set_aliyun
if /i "%~1"=="ali" goto :set_aliyun
if /i "%~1"=="ustc" goto :set_ustc
if /i "%~1"=="douban" goto :set_douban
if /i "%~1"=="huawei" goto :set_huawei
if /i "%~1"=="tencent" goto :set_tencent
if /i "%~1"=="163" goto :set_163
if /i "%~1"=="pypi" goto :set_pypi
if /i "%~1"=="official" goto :set_pypi

echo 用法: %~nx0 [auto^|show^|tsinghua^|aliyun^|ustc^|douban^|huawei^|tencent^|163^|pypi]
exit /b 1

:set_tsinghua
call :set_pip_source "!SOURCE_1_NAME!" "!SOURCE_1_URL!"
exit /b 0

:set_aliyun
call :set_pip_source "!SOURCE_2_NAME!" "!SOURCE_2_URL!"
exit /b 0

:set_ustc
call :set_pip_source "!SOURCE_3_NAME!" "!SOURCE_3_URL!"
exit /b 0

:set_douban
call :set_pip_source "!SOURCE_4_NAME!" "!SOURCE_4_URL!"
exit /b 0

:set_huawei
call :set_pip_source "!SOURCE_5_NAME!" "!SOURCE_5_URL!"
exit /b 0

:set_tencent
call :set_pip_source "!SOURCE_6_NAME!" "!SOURCE_6_URL!"
exit /b 0

:set_163
call :set_pip_source "!SOURCE_7_NAME!" "!SOURCE_7_URL!"
exit /b 0

:set_pypi
call :set_pip_source "!SOURCE_8_NAME!" "!SOURCE_8_URL!"
exit /b 0

:: 显示当前 pip 源
:show_current
echo [INFO] 当前 pip 源配置：
if exist "%PIP_CONF_FILE%" (
    type "%PIP_CONF_FILE%"
) else (
    echo [WARNING] 未找到 pip 配置文件，使用默认源
)
echo.
exit /b 0

:: 测试源的可用性
:test_source
set "test_url=%~1"
curl -s --connect-timeout 5 --max-time 5 "%test_url%" >nul 2>&1
exit /b %errorlevel%

:: 设置 pip 源
:set_pip_source
set "source_name=%~1"
set "source_url=%~2"

:: 创建 pip 目录
if not exist "%PIP_CONF_DIR%" (
    mkdir "%PIP_CONF_DIR%"
    echo [INFO] 创建配置目录: %PIP_CONF_DIR%
)

:: 提取主机名
for /f "tokens=2 delims=/" %%a in ("%source_url%") do set "host=%%a"
for /f "tokens=1 delims=/" %%a in ("!host!") do set "trusted_host=%%a"

:: 写入配置文件
(
    echo [global]
    echo index-url = %source_url%
    echo trusted-host = !trusted_host!
    echo.
    echo [install]
    echo trusted-host = !trusted_host!
) > "%PIP_CONF_FILE%"

if !errorlevel! equ 0 (
    echo [SUCCESS] 已成功切换到 %source_name% 源
    echo [SUCCESS] 源地址: %source_url%
    exit /b 0
) else (
    echo [ERROR] 切换失败
    exit /b 1
)

:: 自动选择最快的源
:auto_select
echo [INFO] 正在测试各个源的可用性...
echo.

set "fastest_source="
set "fastest_url="

for /l %%i in (1,1,8) do (
    set "source_name=!SOURCE_%%i_NAME!"
    set "source_url=!SOURCE_%%i_URL!"
    
    echo | set /p="测试 !source_name! ... "
    
    call :test_source "!source_url!"
    if !errorlevel! equ 0 (
        echo ✓ 可用
        if "!fastest_source!"=="" (
            set "fastest_source=!source_name!"
            set "fastest_url=!source_url!"
        )
    ) else (
        echo ✗ 不可用
    )
)

echo.

if not "!fastest_source!"=="" (
    echo [INFO] 选择第一个可用源: !fastest_source!
    call :set_pip_source "!fastest_source!" "!fastest_url!"
) else (
    echo [ERROR] 所有源均不可用，请检查网络连接
    exit /b 1
)
exit /b 0

:: 显示菜单
:show_menu
cls
echo.
echo ======================================
echo        pip 源一键切换工具
echo ======================================
echo.
echo 请选择操作：
echo.
echo   0^) 自动选择可用源
echo   1^) 清华大学源
echo   2^) 阿里云源
echo   3^) 中国科技大学源
echo   4^) 豆瓣源
echo   5^) 华为云源
echo   6^) 腾讯云源
echo   7^) 网易源
echo   8^) 官方源 (PyPI)
echo   9^) 查看当前源
echo   q^) 退出
echo.
set /p "choice=请输入选项 [0-9/q]: "
exit /b 0

:: 交互式菜单
:interactive_menu
:menu_loop
call :show_menu

if /i "!choice!"=="0" (
    call :auto_select
    goto :menu_continue
)
if "!choice!"=="1" (
    call :set_pip_source "!SOURCE_1_NAME!" "!SOURCE_1_URL!"
    goto :menu_continue
)
if "!choice!"=="2" (
    call :set_pip_source "!SOURCE_2_NAME!" "!SOURCE_2_URL!"
    goto :menu_continue
)
if "!choice!"=="3" (
    call :set_pip_source "!SOURCE_3_NAME!" "!SOURCE_3_URL!"
    goto :menu_continue
)
if "!choice!"=="4" (
    call :set_pip_source "!SOURCE_4_NAME!" "!SOURCE_4_URL!"
    goto :menu_continue
)
if "!choice!"=="5" (
    call :set_pip_source "!SOURCE_5_NAME!" "!SOURCE_5_URL!"
    goto :menu_continue
)
if "!choice!"=="6" (
    call :set_pip_source "!SOURCE_6_NAME!" "!SOURCE_6_URL!"
    goto :menu_continue
)
if "!choice!"=="7" (
    call :set_pip_source "!SOURCE_7_NAME!" "!SOURCE_7_URL!"
    goto :menu_continue
)
if "!choice!"=="8" (
    call :set_pip_source "!SOURCE_8_NAME!" "!SOURCE_8_URL!"
    goto :menu_continue
)
if "!choice!"=="9" (
    call :show_current
    goto :menu_continue
)
if /i "!choice!"=="q" (
    echo [INFO] 退出程序
    exit /b 0
)

echo [ERROR] 无效选项，请重新选择
timeout /t 2 >nul

:menu_continue
echo.
pause
goto :menu_loop
