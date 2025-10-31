# pip 源一键切换脚本 (PowerShell 版本)
# 支持多个国内镜像源，自动测试可用性并切换

# pip 配置文件路径
$PipConfDir = "$env:USERPROFILE\pip"
$PipConfFile = "$PipConfDir\pip.ini"

# 定义镜像源列表
$PipSources = @{
    "清华大学" = "https://pypi.tuna.tsinghua.edu.cn/simple"
    "阿里云" = "https://mirrors.aliyun.com/pypi/simple/"
    "中国科技大学" = "https://pypi.mirrors.ustc.edu.cn/simple/"
    "豆瓣" = "https://pypi.douban.com/simple/"
    "华为云" = "https://repo.huaweicloud.com/repository/pypi/simple"
    "腾讯云" = "https://mirrors.cloud.tencent.com/pypi/simple"
    "网易" = "https://mirrors.163.com/pypi/simple/"
    "官方源" = "https://pypi.org/simple"
}

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

# 显示当前 pip 源
function Show-CurrentSource {
    Write-Info "当前 pip 源配置："
    if (Test-Path $PipConfFile) {
        Get-Content $PipConfFile
    } else {
        Write-Warning "未找到 pip 配置文件，使用默认源"
    }
    Write-Host ""
}

# 测试源的可用性
function Test-Source {
    param([string]$Url)
    
    try {
        $response = Invoke-WebRequest -Uri $Url -Method Head -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# 设置 pip 源
function Set-PipSource {
    param(
        [string]$SourceName,
        [string]$SourceUrl
    )
    
    # 创建 pip 目录
    if (-not (Test-Path $PipConfDir)) {
        New-Item -ItemType Directory -Path $PipConfDir -Force | Out-Null
        Write-Info "创建配置目录: $PipConfDir"
    }
    
    # 提取主机名
    $uri = [System.Uri]$SourceUrl
    $trustedHost = $uri.Host
    
    # 写入配置文件
    $config = @"
[global]
index-url = $SourceUrl
trusted-host = $trustedHost

[install]
trusted-host = $trustedHost
"@
    
    try {
        $config | Out-File -FilePath $PipConfFile -Encoding utf8 -Force
        Write-Success "已成功切换到 $SourceName 源"
        Write-Success "源地址: $SourceUrl"
        return $true
    } catch {
        Write-Error "切换失败: $_"
        return $false
    }
}

# 自动选择最快的源
function Select-AutoSource {
    Write-Info "正在测试各个源的可用性..."
    Write-Host ""
    
    $fastestSource = $null
    $fastestUrl = $null
    
    foreach ($source in $PipSources.GetEnumerator()) {
        Write-Host "测试 $($source.Key) ... " -NoNewline
        
        if (Test-Source $source.Value) {
            Write-Host "✓ 可用" -ForegroundColor Green
            if ($null -eq $fastestSource) {
                $fastestSource = $source.Key
                $fastestUrl = $source.Value
            }
        } else {
            Write-Host "✗ 不可用" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    
    if ($null -ne $fastestSource) {
        Write-Info "选择第一个可用源: $fastestSource"
        Set-PipSource -SourceName $fastestSource -SourceUrl $fastestUrl
    } else {
        Write-Error "所有源均不可用，请检查网络连接"
        return $false
    }
}

# 显示菜单
function Show-Menu {
    Clear-Host
    Write-Host ""
    Write-Host "======================================"
    Write-Host "       pip 源一键切换工具"
    Write-Host "======================================"
    Write-Host ""
    Write-Host "请选择操作："
    Write-Host ""
    Write-Host "  0) 自动选择可用源"
    Write-Host "  1) 清华大学源"
    Write-Host "  2) 阿里云源"
    Write-Host "  3) 中国科技大学源"
    Write-Host "  4) 豆瓣源"
    Write-Host "  5) 华为云源"
    Write-Host "  6) 腾讯云源"
    Write-Host "  7) 网易源"
    Write-Host "  8) 官方源 (PyPI)"
    Write-Host "  9) 查看当前源"
    Write-Host "  q) 退出"
    Write-Host ""
}

# 主函数
function Main {
    param([string]$Action)
    
    # 检查是否有参数
    if ($Action) {
        switch ($Action.ToLower()) {
            "auto" {
                Select-AutoSource
            }
            "show" {
                Show-CurrentSource
            }
            { $_ -in "tsinghua", "tuna" } {
                Set-PipSource -SourceName "清华大学" -SourceUrl $PipSources["清华大学"]
            }
            { $_ -in "aliyun", "ali" } {
                Set-PipSource -SourceName "阿里云" -SourceUrl $PipSources["阿里云"]
            }
            "ustc" {
                Set-PipSource -SourceName "中国科技大学" -SourceUrl $PipSources["中国科技大学"]
            }
            "douban" {
                Set-PipSource -SourceName "豆瓣" -SourceUrl $PipSources["豆瓣"]
            }
            "huawei" {
                Set-PipSource -SourceName "华为云" -SourceUrl $PipSources["华为云"]
            }
            "tencent" {
                Set-PipSource -SourceName "腾讯云" -SourceUrl $PipSources["腾讯云"]
            }
            "163" {
                Set-PipSource -SourceName "网易" -SourceUrl $PipSources["网易"]
            }
            { $_ -in "pypi", "official" } {
                Set-PipSource -SourceName "官方源" -SourceUrl $PipSources["官方源"]
            }
            default {
                Write-Host "用法: .\switch-pip-source.ps1 [auto|show|tsinghua|aliyun|ustc|douban|huawei|tencent|163|pypi]"
                exit 1
            }
        }
        return
    }
    
    # 交互式菜单
    while ($true) {
        Show-Menu
        $choice = Read-Host "请输入选项 [0-9/q]"
        
        switch ($choice) {
            "0" {
                Select-AutoSource
            }
            "1" {
                Set-PipSource -SourceName "清华大学" -SourceUrl $PipSources["清华大学"]
            }
            "2" {
                Set-PipSource -SourceName "阿里云" -SourceUrl $PipSources["阿里云"]
            }
            "3" {
                Set-PipSource -SourceName "中国科技大学" -SourceUrl $PipSources["中国科技大学"]
            }
            "4" {
                Set-PipSource -SourceName "豆瓣" -SourceUrl $PipSources["豆瓣"]
            }
            "5" {
                Set-PipSource -SourceName "华为云" -SourceUrl $PipSources["华为云"]
            }
            "6" {
                Set-PipSource -SourceName "腾讯云" -SourceUrl $PipSources["腾讯云"]
            }
            "7" {
                Set-PipSource -SourceName "网易" -SourceUrl $PipSources["网易"]
            }
            "8" {
                Set-PipSource -SourceName "官方源" -SourceUrl $PipSources["官方源"]
            }
            "9" {
                Show-CurrentSource
            }
            { $_ -in "q", "Q" } {
                Write-Info "退出程序"
                return
            }
            default {
                Write-Error "无效选项，请重新选择"
            }
        }
        
        Write-Host ""
        Read-Host "按回车键继续..."
    }
}

# 运行主函数
Main -Action $args[0]
