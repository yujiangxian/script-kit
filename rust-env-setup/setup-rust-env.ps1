# Rust 环境一键部署脚本 (Windows PowerShell 版本)
# 功能：智能选择下载源、安装 Rust、配置国内镜像

# 配置
$CargoHome = if ($env:CARGO_HOME) { $env:CARGO_HOME } else { "$env:USERPROFILE\.cargo" }
$RustupHome = if ($env:RUSTUP_HOME) { $env:RUSTUP_HOME } else { "$env:USERPROFILE\.rustup" }

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

# 测试 URL 下载速度
function Test-DownloadSpeed {
    param([string]$Url)
    
    Write-Info "测试 $Url ..."
    
    try {
        $startTime = Get-Date
        $response = Invoke-WebRequest -Uri $Url -Method Head -TimeoutSec 10 -UseBasicParsing -ErrorAction Stop
        $endTime = Get-Date
        $duration = ($endTime - $startTime).TotalMilliseconds
        return [int]$duration
    } catch {
        return 999999
    }
}

# 选择最快的下载源
function Select-FastestSource {
    Write-Header "测试下载源速度"
    
    # 定义测试 URL
    $officialUrl = "https://win.rustup.rs/x86_64"
    $ustcUrl = "https://mirrors.ustc.edu.cn/rust-static/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe"
    $tunaUrl = "https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup-init.exe"
    
    Write-Info "正在测试各个源的速度（超时 10 秒）..."
    Write-Host ""
    
    # 测试官方源
    Write-Host "测试官方源 (rustup.rs) ... " -NoNewline
    $officialTime = Test-DownloadSpeed $officialUrl
    if ($officialTime -ne 999999) {
        Write-Host "✓ 可用 (${officialTime}ms)" -ForegroundColor Green
    } else {
        Write-Host "✗ 不可用" -ForegroundColor Red
    }
    
    # 测试中科大源
    Write-Host "测试中科大源 (USTC) ... " -NoNewline
    $ustcTime = Test-DownloadSpeed $ustcUrl
    if ($ustcTime -ne 999999) {
        Write-Host "✓ 可用 (${ustcTime}ms)" -ForegroundColor Green
    } else {
        Write-Host "✗ 不可用" -ForegroundColor Red
    }
    
    # 测试清华源
    Write-Host "测试清华源 (TUNA) ... " -NoNewline
    $tunaTime = Test-DownloadSpeed $tunaUrl
    if ($tunaTime -ne 999999) {
        Write-Host "✓ 可用 (${tunaTime}ms)" -ForegroundColor Green
    } else {
        Write-Host "✗ 不可用" -ForegroundColor Red
    }
    
    Write-Host ""
    
    # 选择最快的源
    $minTime = $officialTime
    $selectedSource = "official"
    $selectedUrl = $officialUrl
    
    if ($ustcTime -lt $minTime) {
        $minTime = $ustcTime
        $selectedSource = "ustc"
        $selectedUrl = $ustcUrl
    }
    
    if ($tunaTime -lt $minTime) {
        $minTime = $tunaTime
        $selectedSource = "tuna"
        $selectedUrl = $tunaUrl
    }
    
    if ($minTime -eq 999999) {
        Write-Error "所有源均不可用，请检查网络连接"
        exit 1
    }
    
    $script:InstallSource = $selectedSource
    $script:InstallUrl = $selectedUrl
    
    switch ($selectedSource) {
        "official" {
            Write-Success "选择官方源 (最快: ${minTime}ms)"
        }
        "ustc" {
            Write-Success "选择中科大源 (最快: ${minTime}ms)"
            $env:RUSTUP_DIST_SERVER = "https://mirrors.ustc.edu.cn/rust-static"
            $env:RUSTUP_UPDATE_ROOT = "https://mirrors.ustc.edu.cn/rust-static/rustup"
        }
        "tuna" {
            Write-Success "选择清华源 (最快: ${minTime}ms)"
            $env:RUSTUP_DIST_SERVER = "https://mirrors.tuna.tsinghua.edu.cn/rustup"
            $env:RUSTUP_UPDATE_ROOT = "https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup"
        }
    }
}

# 安装 Rust
function Install-Rust {
    Write-Header "安装 Rust"
    
    if (Test-CommandExists rustc) {
        $version = (rustc --version 2>&1)
        Write-Info "Rust 已安装，版本: $version"
        $response = Read-Host "是否重新安装？(y/N)"
        if ($response -notmatch '^[Yy]$') {
            return
        }
    }
    
    Write-Info "正在从 $script:InstallSource 源下载并安装 Rust..."
    
    # 下载安装程序
    $installerPath = "$env:TEMP\rustup-init.exe"
    
    try {
        Write-Info "下载安装程序..."
        Invoke-WebRequest -Uri $script:InstallUrl -OutFile $installerPath -UseBasicParsing
        
        Write-Info "运行安装程序..."
        # 静默安装
        & $installerPath -y --default-toolchain stable --profile default
        
        # 刷新环境变量
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        
        # 清理
        Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
        
        if (Test-CommandExists rustc) {
            Write-Success "Rust 安装成功！"
            Write-Info "rustc 版本: $(rustc --version 2>&1)"
            Write-Info "cargo 版本: $(cargo --version 2>&1)"
        } else {
            Write-Error "Rust 安装失败，请手动安装"
            exit 1
        }
    } catch {
        Write-Error "安装过程出错: $_"
        exit 1
    }
}

# 配置 Cargo 镜像源
function Set-CargoMirror {
    Write-Header "配置 Cargo 镜像源"
    
    Write-Info "选择 Cargo 镜像源："
    Write-Host "1) 中国科技大学 (推荐)"
    Write-Host "2) 清华大学"
    Write-Host "3) 上海交通大学"
    Write-Host "4) 字节跳动"
    Write-Host "5) 跳过配置"
    Write-Host ""
    $choice = Read-Host "请选择 [1-5]"
    
    $registryUrl = ""
    $sourceName = ""
    
    switch ($choice) {
        "1" {
            $registryUrl = "https://mirrors.ustc.edu.cn/crates.io-index"
            $sourceName = "中国科技大学"
        }
        "2" {
            $registryUrl = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"
            $sourceName = "清华大学"
        }
        "3" {
            $registryUrl = "https://mirrors.sjtug.sjtu.edu.cn/git/crates.io-index/"
            $sourceName = "上海交通大学"
        }
        "4" {
            $registryUrl = "https://rsproxy.cn/crates.io-index"
            $sourceName = "字节跳动"
        }
        "5" {
            Write-Info "跳过 Cargo 源配置"
            return
        }
        default {
            Write-Warning "无效选择，使用默认源（中科大）"
            $registryUrl = "https://mirrors.ustc.edu.cn/crates.io-index"
            $sourceName = "中国科技大学"
        }
    }
    
    # 创建配置目录
    if (-not (Test-Path $CargoHome)) {
        New-Item -ItemType Directory -Path $CargoHome -Force | Out-Null
    }
    
    # 写入配置
    $config = @"
[source.crates-io]
replace-with = 'ustc'

[source.ustc]
registry = "$registryUrl"

[net]
git-fetch-with-cli = true
"@
    
    $configPath = Join-Path $CargoHome "config.toml"
    $config | Out-File -FilePath $configPath -Encoding utf8 -Force
    
    Write-Success "Cargo 源配置完成: $sourceName"
    Write-Info "配置文件: $configPath"
}

# 配置 Rustup 镜像源
function Set-RustupMirror {
    Write-Header "配置 Rustup 镜像源"
    
    Write-Info "选择 Rustup 镜像源："
    Write-Host "1) 中国科技大学 (推荐)"
    Write-Host "2) 清华大学"
    Write-Host "3) 跳过配置"
    Write-Host ""
    $choice = Read-Host "请选择 [1-3]"
    
    $distServer = ""
    $updateRoot = ""
    $sourceName = ""
    
    switch ($choice) {
        "1" {
            $distServer = "https://mirrors.ustc.edu.cn/rust-static"
            $updateRoot = "https://mirrors.ustc.edu.cn/rust-static/rustup"
            $sourceName = "中国科技大学"
        }
        "2" {
            $distServer = "https://mirrors.tuna.tsinghua.edu.cn/rustup"
            $updateRoot = "https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup"
            $sourceName = "清华大学"
        }
        "3" {
            Write-Info "跳过 Rustup 源配置"
            return
        }
        default {
            Write-Warning "无效选择，使用默认源（中科大）"
            $distServer = "https://mirrors.ustc.edu.cn/rust-static"
            $updateRoot = "https://mirrors.ustc.edu.cn/rust-static/rustup"
            $sourceName = "中国科技大学"
        }
    }
    
    # 设置用户环境变量
    [System.Environment]::SetEnvironmentVariable("RUSTUP_DIST_SERVER", $distServer, "User")
    [System.Environment]::SetEnvironmentVariable("RUSTUP_UPDATE_ROOT", $updateRoot, "User")
    
    # 立即生效
    $env:RUSTUP_DIST_SERVER = $distServer
    $env:RUSTUP_UPDATE_ROOT = $updateRoot
    
    Write-Success "Rustup 源配置完成: $sourceName"
    Write-Info "环境变量已设置"
}

# 安装常用组件
function Install-Components {
    Write-Header "安装常用组件"
    
    Write-Info "推荐安装以下组件："
    Write-Host "  1. rust-src (源码，用于 IDE 补全)"
    Write-Host "  2. rust-analyzer (LSP 服务器)"
    Write-Host "  3. clippy (代码检查工具)"
    Write-Host "  4. rustfmt (代码格式化工具)"
    Write-Host ""
    $response = Read-Host "是否安装？(Y/n)"
    if ($response -match '^[Nn]$') {
        Write-Info "跳过组件安装"
        return
    }
    
    Write-Info "正在安装组件..."
    
    try {
        rustup component add rust-src
        rustup component add rust-analyzer
        rustup component add clippy
        rustup component add rustfmt
        
        Write-Success "组件安装完成！"
    } catch {
        Write-Warning "部分组件安装失败: $_"
    }
}

# 验证安装
function Test-Installation {
    Write-Header "验证安装"
    
    Write-Info "检查 Rust 工具链..."
    
    if (Test-CommandExists rustc) {
        Write-Host "  ✓ rustc: $(rustc --version 2>&1)"
    } else {
        Write-Host "  ✗ rustc: 未安装"
    }
    
    if (Test-CommandExists cargo) {
        Write-Host "  ✓ cargo: $(cargo --version 2>&1)"
    } else {
        Write-Host "  ✗ cargo: 未安装"
    }
    
    if (Test-CommandExists rustup) {
        Write-Host "  ✓ rustup: $(rustup --version 2>&1)"
    } else {
        Write-Host "  ✗ rustup: 未安装"
    }
    
    Write-Host ""
    Write-Info "测试编译..."
    
    # 创建临时测试项目
    $testDir = "$env:TEMP\rust-test-$(Get-Random)"
    New-Item -ItemType Directory -Path $testDir -Force | Out-Null
    Push-Location $testDir
    
    try {
        cargo init --bin test-project --quiet 2>$null
        Set-Location test-project
        
        if (cargo build --quiet 2>$null) {
            Write-Success "编译测试通过！"
        } else {
            Write-Warning "编译测试失败，但这可能是正常的"
        }
    } catch {
        Write-Warning "测试编译时出错: $_"
    } finally {
        Pop-Location
        Remove-Item -Path $testDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# 显示使用说明
function Show-Usage {
    Write-Header "安装完成！"
    
    Write-Host "📦 已安装组件：" -ForegroundColor Cyan
    Write-Host "  ✓ Rust 工具链 (rustc, cargo, rustup)"
    Write-Host "  ✓ Cargo 镜像源配置"
    Write-Host "  ✓ Rustup 镜像源配置"
    Write-Host "  ✓ 常用开发组件"
    Write-Host ""
    Write-Host "🚀 快速开始：" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1. 重启终端或刷新环境变量："
    Write-Host "     `$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')"
    Write-Host ""
    Write-Host "  2. 创建新项目："
    Write-Host "     cargo new my-project"
    Write-Host "     cd my-project"
    Write-Host ""
    Write-Host "  3. 构建项目："
    Write-Host "     cargo build"
    Write-Host ""
    Write-Host "  4. 运行项目："
    Write-Host "     cargo run"
    Write-Host ""
    Write-Host "  5. 更新 Rust："
    Write-Host "     rustup update"
    Write-Host ""
    Write-Host "📝 配置文件位置：" -ForegroundColor Gray
    Write-Host "  - Cargo 配置: $CargoHome\config.toml"
    Write-Host "  - 环境变量: 用户环境变量"
    Write-Host "  - 工具链位置: $RustupHome"
    Write-Host ""
    Write-Host "📚 常用命令：" -ForegroundColor Cyan
    Write-Host "  cargo new <name>      # 创建新项目"
    Write-Host "  cargo build           # 构建项目"
    Write-Host "  cargo run             # 运行项目"
    Write-Host "  cargo test            # 运行测试"
    Write-Host "  cargo clippy          # 代码检查"
    Write-Host "  cargo fmt             # 代码格式化"
    Write-Host "  rustup update         # 更新 Rust"
    Write-Host "  rustup show           # 显示工具链信息"
    Write-Host ""
    Write-Success "Rust 环境配置完成，开始愉快地编码吧！"
}

# 主函数
function Main {
    Write-Header "Rust 环境一键部署"
    
    Write-Info "此脚本将："
    Write-Host "  1. 测试并选择最快的下载源"
    Write-Host "  2. 安装 Rust 工具链"
    Write-Host "  3. 配置 Cargo 镜像源"
    Write-Host "  4. 配置 Rustup 镜像源"
    Write-Host "  5. 安装常用开发组件"
    Write-Host ""
    $response = Read-Host "是否继续？(Y/n)"
    if ($response -match '^[Nn]$') {
        Write-Info "已取消安装"
        exit 0
    }
    
    Select-FastestSource
    Install-Rust
    Set-CargoMirror
    Set-RustupMirror
    Install-Components
    Test-Installation
    Show-Usage
}

# 运行主函数
Main
