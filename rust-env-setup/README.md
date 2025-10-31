# Rust 环境一键部署工具

一个智能的跨平台 Rust 开发环境自动化配置脚本，支持 Linux 和 Windows 系统。自动测试下载源速度、安装 Rust 工具链、配置国内镜像源。

## 功能特点

- 🚀 智能测试下载源速度，自动选择最快的源
- 🌐 配置 Cargo 和 Rustup 国内镜像源
- 🦀 自动安装 Rust 工具链（rustc、cargo、rustup）
- 🛠️ 安装常用开发组件（rust-src、rust-analyzer、clippy、rustfmt）
- ⚡ 一键部署，开箱即用
- 🎯 支持官方源和多个国内镜像源

## 为什么需要配置镜像源？

在国内访问 Rust 官方源可能会遇到：
- ❌ 下载速度慢
- ❌ 连接超时
- ❌ 无法访问

使用国内镜像源可以：
- ✅ 下载速度快（通常 10-100 倍）
- ✅ 连接稳定
- ✅ 节省时间

## 支持的镜像源

### Rustup 安装源
| 源名称 | 说明 | 推荐度 |
|--------|------|--------|
| 官方源 | rustup.rs | ⭐⭐⭐ |
| 中国科技大学 | mirrors.ustc.edu.cn | ⭐⭐⭐⭐⭐ |
| 清华大学 | mirrors.tuna.tsinghua.edu.cn | ⭐⭐⭐⭐⭐ |

### Cargo 包源
| 源名称 | 说明 | 推荐度 |
|--------|------|--------|
| 中国科技大学 | mirrors.ustc.edu.cn | ⭐⭐⭐⭐⭐ |
| 清华大学 | mirrors.tuna.tsinghua.edu.cn | ⭐⭐⭐⭐⭐ |
| 上海交通大学 | mirrors.sjtug.sjtu.edu.cn | ⭐⭐⭐⭐ |
| 字节跳动 | rsproxy.cn | ⭐⭐⭐⭐ |

## 安装使用

### Linux 系统

#### 1. 下载脚本

```bash
# 克隆仓库
git clone <repository-url>
cd rust-env-setup

# 或直接下载脚本
wget https://raw.githubusercontent.com/your-repo/rust-env-setup/main/setup-rust-env.sh
```

#### 2. 运行安装

```bash
chmod +x setup-rust-env.sh
./setup-rust-env.sh
```

#### 3. 重新加载配置

```bash
source ~/.bashrc
```

### Windows 系统

#### 1. 下载脚本

下载 `setup-rust-env.ps1` 文件到本地。

#### 2. 运行安装

在 PowerShell 中执行：

```powershell
# 如果遇到执行策略限制，先运行（仅需一次）
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 运行安装脚本
.\setup-rust-env.ps1
```

#### 3. 刷新环境变量

```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
```

或者重启终端。

## 安装过程

脚本会按以下步骤执行：

1. **测试下载源速度** - 自动测试官方源和国内镜像源的速度
2. **选择最快的源** - 根据测试结果自动选择最快的下载源
3. **安装 Rust** - 下载并安装 Rust 工具链
4. **配置 Cargo 源** - 配置 Cargo 包管理器的镜像源
5. **配置 Rustup 源** - 配置 Rustup 工具链管理器的镜像源
6. **安装开发组件** - 安装 rust-src、rust-analyzer、clippy、rustfmt
7. **验证安装** - 测试编译确保环境正常

## 使用指南

### 创建新项目

```bash
# 创建二进制项目
cargo new my-project
cd my-project

# 创建库项目
cargo new --lib my-library
```

### 构建和运行

```bash
# 构建项目（debug 模式）
cargo build

# 构建项目（release 模式，优化编译）
cargo build --release

# 运行项目
cargo run

# 运行并传递参数
cargo run -- arg1 arg2
```

### 测试

```bash
# 运行所有测试
cargo test

# 运行特定测试
cargo test test_name

# 显示测试输出
cargo test -- --nocapture
```

### 代码质量

```bash
# 代码检查（推荐）
cargo clippy

# 代码格式化
cargo fmt

# 检查代码格式
cargo fmt -- --check
```

### 依赖管理

```bash
# 添加依赖（编辑 Cargo.toml）
# [dependencies]
# serde = "1.0"

# 更新依赖
cargo update

# 查看依赖树
cargo tree
```

### 工具链管理

```bash
# 更新 Rust
rustup update

# 查看已安装的工具链
rustup show

# 安装特定版本
rustup install nightly

# 切换默认工具链
rustup default stable

# 添加编译目标
rustup target add x86_64-pc-windows-gnu
```

## 配置文件位置

### Linux
- **Cargo 配置**: `~/.cargo/config.toml`
- **Rustup 环境变量**: `~/.bashrc`
- **工具链位置**: `~/.rustup/`
- **已安装的二进制**: `~/.cargo/bin/`

### Windows
- **Cargo 配置**: `%USERPROFILE%\.cargo\config.toml`
- **Rustup 环境变量**: 用户环境变量
- **工具链位置**: `%USERPROFILE%\.rustup\`
- **已安装的二进制**: `%USERPROFILE%\.cargo\bin\`

## 手动配置镜像源

如果需要手动配置或更改镜像源：

### Cargo 镜像源

编辑 `~/.cargo/config.toml` (Linux) 或 `%USERPROFILE%\.cargo\config.toml` (Windows)：

```toml
[source.crates-io]
replace-with = 'ustc'

[source.ustc]
registry = "https://mirrors.ustc.edu.cn/crates.io-index"

[net]
git-fetch-with-cli = true
```

### Rustup 镜像源

**Linux** - 添加到 `~/.bashrc`:
```bash
export RUSTUP_DIST_SERVER="https://mirrors.ustc.edu.cn/rust-static"
export RUSTUP_UPDATE_ROOT="https://mirrors.ustc.edu.cn/rust-static/rustup"
```

**Windows** - 设置环境变量:
```powershell
[System.Environment]::SetEnvironmentVariable("RUSTUP_DIST_SERVER", "https://mirrors.ustc.edu.cn/rust-static", "User")
[System.Environment]::SetEnvironmentVariable("RUSTUP_UPDATE_ROOT", "https://mirrors.ustc.edu.cn/rust-static/rustup", "User")
```

## 常见问题

### 1. 安装失败怎么办？

**检查网络连接**：
```bash
# 测试网络
ping mirrors.ustc.edu.cn
```

**手动安装**：
- Linux: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
- Windows: 下载 https://win.rustup.rs/x86_64 并运行

### 2. 如何切换镜像源？

重新运行脚本，或手动编辑配置文件（见上方"手动配置镜像源"）。

### 3. 如何验证镜像源是否生效？

```bash
# 查看 Cargo 配置
cat ~/.cargo/config.toml  # Linux
type %USERPROFILE%\.cargo\config.toml  # Windows

# 查看环境变量
echo $RUSTUP_DIST_SERVER  # Linux
echo $env:RUSTUP_DIST_SERVER  # Windows

# 测试安装包
cargo install ripgrep
```

### 4. cargo build 很慢怎么办？

首次构建会下载依赖，使用镜像源后会快很多。如果还是慢：

```bash
# 使用更多 CPU 核心编译
cargo build -j 8

# 使用 release 模式（更快的运行速度）
cargo build --release
```

### 5. 如何更新 Rust？

```bash
rustup update
```

### 6. 如何卸载 Rust？

```bash
rustup self uninstall
```

### 7. Visual Studio Code 配置

安装推荐插件：
- **rust-analyzer** - 智能代码补全和分析
- **CodeLLDB** - 调试支持
- **crates** - 依赖管理

### 8. 编译错误：链接器找不到

**Windows** - 需要安装 Visual Studio Build Tools：
- 下载：https://visualstudio.microsoft.com/visual-cpp-build-tools/
- 安装时选择 "C++ build tools"

**Linux** - 安装构建工具：
```bash
# Ubuntu/Debian
sudo apt install build-essential

# CentOS/RHEL
sudo yum groupinstall "Development Tools"

# Arch Linux
sudo pacman -S base-devel
```

## 性能对比

使用国内镜像源 vs 官方源（根据网络环境差异较大）：

| 操作 | 官方源 | 国内镜像源 | 说明 |
|------|--------|-----------|------|
| 安装 Rust | 较慢或超时 | 快速 | 取决于网络环境 |
| 下载依赖 | 较慢或超时 | 快速 | 取决于网络环境 |
| 更新工具链 | 较慢或超时 | 快速 | 取决于网络环境 |

**注意**：实际速度提升取决于你的网络环境、地理位置和当时的网络状况。在某些网络环境下，官方源可能无法访问或速度极慢，而国内镜像源通常能提供稳定快速的访问。

## 常用 Cargo 命令速查

```bash
# 项目管理
cargo new <name>          # 创建新项目
cargo init                # 在当前目录初始化项目
cargo build               # 构建项目
cargo run                 # 运行项目
cargo clean               # 清理构建文件

# 测试和检查
cargo test                # 运行测试
cargo check               # 快速检查代码（不生成可执行文件）
cargo clippy              # 代码检查
cargo fmt                 # 代码格式化

# 依赖管理
cargo add <crate>         # 添加依赖（需要 cargo-edit）
cargo update              # 更新依赖
cargo tree                # 查看依赖树

# 发布
cargo build --release     # 发布构建
cargo publish             # 发布到 crates.io

# 文档
cargo doc                 # 生成文档
cargo doc --open          # 生成并打开文档

# 工具安装
cargo install <tool>      # 安装命令行工具
cargo uninstall <tool>    # 卸载工具
```

## 推荐的 Cargo 工具

```bash
# 代码质量
cargo install cargo-edit      # 命令行管理依赖
cargo install cargo-watch     # 监听文件变化自动构建
cargo install cargo-expand    # 展开宏

# 性能分析
cargo install cargo-flamegraph  # 性能分析
cargo install cargo-bloat       # 分析二进制大小

# 实用工具
cargo install ripgrep         # 快速搜索工具
cargo install fd-find         # 快速查找文件
cargo install bat             # 更好的 cat
cargo install exa             # 更好的 ls
```

## 学习资源

- [Rust 官方文档](https://doc.rust-lang.org/)
- [Rust 程序设计语言（中文版）](https://kaisery.github.io/trpl-zh-cn/)
- [通过例子学 Rust](https://rustwiki.org/zh-CN/rust-by-example/)
- [Rust 语言圣经](https://course.rs/)
- [Rustlings 练习](https://github.com/rust-lang/rustlings)

## 卸载

如果需要完全卸载 Rust：

**Linux:**
```bash
rustup self uninstall
rm -rf ~/.cargo ~/.rustup
# 从 ~/.bashrc 中删除 Rust 相关配置
```

**Windows:**
```powershell
rustup self uninstall
Remove-Item -Recurse -Force $env:USERPROFILE\.cargo
Remove-Item -Recurse -Force $env:USERPROFILE\.rustup
# 删除环境变量 RUSTUP_DIST_SERVER 和 RUSTUP_UPDATE_ROOT
```

## 相关链接

- [Rust 官网](https://www.rust-lang.org/)
- [Rustup 文档](https://rust-lang.github.io/rustup/)
- [Cargo 文档](https://doc.rust-lang.org/cargo/)
- [中科大 Rust 镜像](https://mirrors.ustc.edu.cn/help/rust-static.html)
- [清华 Rust 镜像](https://mirrors.tuna.tsinghua.edu.cn/help/rustup/)

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！
