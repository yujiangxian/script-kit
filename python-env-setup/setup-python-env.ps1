# Python 环境一键部署脚本 (Windows PowerShell 版本)
# 功能：安装 uv、配置镜像源、创建多版本虚拟环境

# 配置
$VenvDir = "$env:USERPROFILE\.python-envs"
$PipConfDir = "$env:USERPROFILE\pip"
$PipConfFile = "$PipConfDir\pip.ini"

# 打印带颜色的消息
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Header {
    param([string]$Title)
    Write-Host ""
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host ""
}

# 检查命令是否存在
function Test-CommandExists {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

# 安装 uv
function Install-Uv {
    Write-Header "安装 uv 包管理器"
    
    if (Test-CommandExists uv) {
        $version = (uv --version 2>&1) -replace 'uv ', ''
        Write-Info "uv 已安装，版本: $version"
        $response = Read-Host "是否重新安装？(y/N)"
        if ($response -notmatch '^[Yy]$') {
            return
        }
    }
    
    Write-Info "正在安装 uv..."
    
    try {
        # 下载并安装 uv
        Invoke-WebRequest -Uri "https://astral.sh/uv/install.ps1" -UseBasicParsing | Invoke-Expression
        
        # 刷新环境变量
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        
        if (Test-CommandExists uv) {
            $version = (uv --version 2>&1) -replace 'uv ', ''
            Write-Success "uv 安装成功！版本: $version"
        } else {
            Write-Error "uv 安装失败，请手动安装或检查网络连接"
            Write-Info "手动安装命令: irm https://astral.sh/uv/install.ps1 | iex"
            exit 1
        }
    } catch {
        Write-Error "安装过程出错: $_"
        exit 1
    }
}

# 配置 pip 镜像源
function Set-PipSource {
    Write-Header "配置 pip 镜像源"
    
    Write-Info "选择镜像源："
    Write-Host "1) 阿里云 (推荐)"
    Write-Host "2) 清华大学"
    Write-Host "3) 中国科技大学"
    Write-Host "4) 腾讯云"
    Write-Host "5) 跳过配置"
    Write-Host ""
    $choice = Read-Host "请选择 [1-5]"
    
    switch ($choice) {
        "1" {
            $IndexUrl = "https://mirrors.aliyun.com/pypi/simple/"
            $TrustedHost = "mirrors.aliyun.com"
        }
        "2" {
            $IndexUrl = "https://pypi.tuna.tsinghua.edu.cn/simple"
            $TrustedHost = "pypi.tuna.tsinghua.edu.cn"
        }
        "3" {
            $IndexUrl = "https://pypi.mirrors.ustc.edu.cn/simple/"
            $TrustedHost = "pypi.mirrors.ustc.edu.cn"
        }
        "4" {
            $IndexUrl = "https://mirrors.cloud.tencent.com/pypi/simple"
            $TrustedHost = "mirrors.cloud.tencent.com"
        }
        "5" {
            Write-Info "跳过 pip 源配置"
            return
        }
        default {
            Write-Warning "无效选择，使用默认源（阿里云）"
            $IndexUrl = "https://mirrors.aliyun.com/pypi/simple/"
            $TrustedHost = "mirrors.aliyun.com"
        }
    }
    
    # 创建配置目录
    if (-not (Test-Path $PipConfDir)) {
        New-Item -ItemType Directory -Path $PipConfDir -Force | Out-Null
    }
    
    # 写入配置
    $config = @"
[global]
index-url = $IndexUrl
trusted-host = $TrustedHost

[install]
trusted-host = $TrustedHost
"@
    
    $config | Out-File -FilePath $PipConfFile -Encoding utf8 -Force
    Write-Success "pip 源配置完成: $IndexUrl"
    
    # 配置 uv 使用相同的源
    [System.Environment]::SetEnvironmentVariable("UV_INDEX_URL", $IndexUrl, "User")
    $env:UV_INDEX_URL = $IndexUrl
    
    Write-Success "uv 源配置完成"
}

# 创建虚拟环境
function New-PythonVenv {
    param(
        [string]$Name,
        [string]$PythonVersion
    )
    
    $venvPath = Join-Path $VenvDir $Name
    
    Write-Info "创建虚拟环境: $Name (Python $PythonVersion)"
    
    if (Test-Path $venvPath) {
        Write-Warning "虚拟环境 $Name 已存在"
        $response = Read-Host "是否删除并重新创建？(y/N)"
        if ($response -match '^[Yy]$') {
            Remove-Item -Path $venvPath -Recurse -Force
        } else {
            return
        }
    }
    
    # 使用 uv 创建虚拟环境
    try {
        uv venv $venvPath --python $PythonVersion
        Write-Success "虚拟环境 $Name 创建成功"
        Write-Info "激活命令: $venvPath\Scripts\Activate.ps1"
    } catch {
        Write-Error "虚拟环境 $Name 创建失败: $_"
    }
}

# 创建所有虚拟环境
function New-AllVenvs {
    Write-Header "创建 Python 虚拟环境"
    
    if (-not (Test-Path $VenvDir)) {
        New-Item -ItemType Directory -Path $VenvDir -Force | Out-Null
    }
    
    Write-Info "将创建以下虚拟环境："
    Write-Host "  1. py39  - Python 3.9"
    Write-Host "  2. py312 - Python 3.12"
    Write-Host "  3. py313 - Python 3.13 (最新版)"
    Write-Host ""
    $response = Read-Host "是否继续？(Y/n)"
    if ($response -match '^[Nn]$') {
        Write-Info "跳过虚拟环境创建"
        return
    }
    
    New-PythonVenv -Name "py39" -PythonVersion "3.9"
    New-PythonVenv -Name "py312" -PythonVersion "3.12"
    New-PythonVenv -Name "py313" -PythonVersion "3.13"
    
    Write-Success "所有虚拟环境创建完成！"
}

# 创建便捷脚本
function New-HelperScripts {
    Write-Header "创建便捷管理脚本"
    
    # 创建激活脚本
    $activateScript = @'
# Python 虚拟环境快速激活脚本
param([string]$EnvName)

$VenvDir = "$env:USERPROFILE\.python-envs"

function Activate-PythonEnv {
    param([string]$Name)
    
    $venvPath = Join-Path $VenvDir $Name
    $activateScript = Join-Path $venvPath "Scripts\Activate.ps1"
    
    if (Test-Path $activateScript) {
        & $activateScript
        $version = (python --version 2>&1)
        Write-Host "已激活虚拟环境: $Name ($version)" -ForegroundColor Green
    } else {
        Write-Host "错误: 虚拟环境 $Name 不存在" -ForegroundColor Red
        Write-Host "可用环境:"
        if (Test-Path $VenvDir) {
            Get-ChildItem $VenvDir -Directory | ForEach-Object { Write-Host "  $_" }
        } else {
            Write-Host "  (无)"
        }
    }
}

if ($EnvName) {
    Activate-PythonEnv -Name $EnvName
} else {
    Write-Host "用法: . ~\python-env-activate.ps1 <环境名>"
    Write-Host ""
    Write-Host "可用环境:"
    if (Test-Path $VenvDir) {
        Get-ChildItem $VenvDir -Directory | ForEach-Object { Write-Host "  $($_.Name)" }
    } else {
        Write-Host "  (无)"
    }
}
'@
    
    $activateScript | Out-File -FilePath "$env:USERPROFILE\python-env-activate.ps1" -Encoding utf8 -Force
    
    # 创建 PowerShell Profile（如果不存在）
    if (-not (Test-Path $PROFILE)) {
        New-Item -Path $PROFILE -ItemType File -Force | Out-Null
    }
    
    # 添加别名到 Profile
    $profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
    if ($profileContent -notmatch 'python-env-activate') {
        $aliases = @'

# Python 虚拟环境快捷命令
function pyenv { param($env) . "$env:USERPROFILE\python-env-activate.ps1" $env }
function py39 { . "$env:USERPROFILE\python-env-activate.ps1" py39 }
function py312 { . "$env:USERPROFILE\python-env-activate.ps1" py312 }
function py313 { . "$env:USERPROFILE\python-env-activate.ps1" py313 }
function pylist { Get-ChildItem "$env:USERPROFILE\.python-envs" -Directory | Select-Object Name }
'@
        Add-Content -Path $PROFILE -Value $aliases
        Write-Success "已添加快捷命令到 PowerShell Profile"
    }
    
    Write-Success "便捷脚本创建完成！"
}

# 显示使用说明
function Show-Usage {
    Write-Header "安装完成！"
    
    Write-Host "📦 已安装组件：" -ForegroundColor Cyan
    Write-Host "  ✓ uv 包管理器"
    Write-Host "  ✓ pip 镜像源配置"
    Write-Host "  ✓ Python 虚拟环境 (py39, py312, py313)"
    Write-Host ""
    Write-Host "🚀 快速开始：" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1. 重新加载配置："
    Write-Host "     . `$PROFILE"
    Write-Host ""
    Write-Host "  2. 激活虚拟环境："
    Write-Host "     py39      # 激活 Python 3.9 环境"
    Write-Host "     py312     # 激活 Python 3.12 环境"
    Write-Host "     py313     # 激活 Python 3.13 环境"
    Write-Host ""
    Write-Host "  3. 查看所有环境："
    Write-Host "     pylist"
    Write-Host ""
    Write-Host "  4. 使用 uv 安装包（推荐，速度快）："
    Write-Host "     uv pip install requests"
    Write-Host ""
    Write-Host "  5. 使用 pip 安装包："
    Write-Host "     pip install requests"
    Write-Host ""
    Write-Host "📝 虚拟环境位置: $VenvDir" -ForegroundColor Gray
    Write-Host "📝 pip 配置文件: $PipConfFile" -ForegroundColor Gray
    Write-Host ""
    Write-Success "环境配置完成，开始愉快地编码吧！"
}

# 主函数
function Main {
    Write-Header "Python 环境一键部署"
    
    Write-Info "此脚本将："
    Write-Host "  1. 安装 uv 包管理器"
    Write-Host "  2. 配置 pip/uv 镜像源"
    Write-Host "  3. 创建多版本 Python 虚拟环境"
    Write-Host "  4. 设置便捷管理命令"
    Write-Host ""
    $response = Read-Host "是否继续？(Y/n)"
    if ($response -match '^[Nn]$') {
        Write-Info "已取消安装"
        exit 0
    }
    
    Install-Uv
    Set-PipSource
    New-AllVenvs
    New-HelperScripts
    Show-Usage
}

# 运行主函数
Main
