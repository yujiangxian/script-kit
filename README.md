# 常用脚本工具集 🛠️

一个收集和整理常用脚本的仓库，帮助快速配置开发环境和自动化日常任务。

## 📦 项目结构

```
.
├── docker/                        # Docker 相关脚本
│   └── kali-docker-install.sh    # Kali Linux Docker 一键安装
├── pip-source-switcher/           # pip 源切换工具
│   ├── switch-pip-source.sh      # Linux 版本
│   ├── switch-pip-source.bat     # Windows CMD 版本
│   └── switch-pip-source.ps1     # Windows PowerShell 版本
├── python-env-setup/              # Python 环境一键部署
│   ├── setup-python-env.sh       # Linux 版本
│   └── setup-python-env.ps1      # Windows 版本
├── rust-env-setup/                # Rust 环境一键部署
│   ├── setup-rust-env.sh         # Linux 版本
│   └── setup-rust-env.ps1        # Windows 版本
└── docs/                          # 详细文档
```

## 🚀 快速开始

### Docker 工具

#### Kali Linux Docker 一键安装

专为 Kali Linux 设计的 Docker 安装脚本，解决官方源 404 问题，集成国内镜像加速。

**特性：**
- ✅ 自动清理旧配置，解决 404 错误
- ✅ 使用 Kali 官方仓库安装
- ✅ 配置国内镜像加速器（多源备份）
- ✅ 自动安装 Docker Compose
- ✅ 配置用户权限（免 sudo）
- ✅ 完整的安装验证

**使用方法：**

```bash
# 下载脚本
wget https://raw.githubusercontent.com/yujiangxian/script-kit/main/docker/kali-docker-install.sh

# 添加执行权限
chmod +x kali-docker-install.sh

# 运行安装
./kali-docker-install.sh
```

详细说明请查看 [docker/README.md](docker/README.md)

### pip 源一键切换工具

跨平台的 pip 镜像源切换脚本，支持 Linux 和 Windows 系统，自动测试源可用性并切换。

**特性：**
- 🚀 支持 8 个国内主流镜像源（清华、阿里、中科大、豆瓣、华为、腾讯、网易、官方源）
- ✅ 自动测试源的可用性
- 🎯 一键切换到可用源
- 💻 支持交互式菜单和命令行参数
- 🌐 跨平台支持（Linux Bash / Windows CMD / Windows PowerShell）

**使用方法：**

Linux:
```bash
cd pip-source-switcher
chmod +x switch-pip-source.sh
./switch-pip-source.sh auto
```

Windows PowerShell:
```powershell
cd pip-source-switcher
.\switch-pip-source.ps1 auto
```

Windows CMD:
```cmd
cd pip-source-switcher
switch-pip-source.bat auto
```

详细说明请查看 [pip-source-switcher/README.md](pip-source-switcher/README.md)

### Python 环境一键部署

跨平台的 Python 开发环境自动化配置工具，一键安装 uv、配置镜像源、创建多版本虚拟环境。

**特性：**
- 🚀 自动安装 uv 包管理器（比 pip 快 10-100 倍）
- 🌐 配置 pip 和 uv 国内镜像源
- 🐍 自动创建多版本虚拟环境（Python 3.9、3.12、3.13）
- ⚡ 提供便捷的环境切换命令（py39、py312、py313）
- 📦 支持 pip 和 uv 两种包管理方式
- 🎯 一键部署，开箱即用

**使用方法：**

Linux:
```bash
cd python-env-setup
chmod +x setup-python-env.sh
./setup-python-env.sh
source ~/.bashrc
```

Windows PowerShell:
```powershell
cd python-env-setup
.\setup-python-env.ps1
. $PROFILE
```

**快速切换环境：**
```bash
py39      # 激活 Python 3.9 环境
py312     # 激活 Python 3.12 环境
py313     # 激活 Python 3.13 环境
pylist    # 查看所有环境
```

详细说明请查看 [python-env-setup/README.md](python-env-setup/README.md)

### Rust 环境一键部署

智能的 Rust 开发环境自动化配置工具，自动测试下载源速度、安装 Rust 工具链、配置国内镜像源。

**特性：**
- 🚀 智能测试下载源速度，自动选择最快的源
- 🌐 配置 Cargo 和 Rustup 国内镜像源
- 🦀 自动安装 Rust 工具链（rustc、cargo、rustup）
- 🛠️ 安装常用开发组件（rust-src、rust-analyzer、clippy、rustfmt）
- ⚡ 一键部署，开箱即用

**使用方法：**

Linux:
```bash
cd rust-env-setup
chmod +x setup-rust-env.sh
./setup-rust-env.sh
source ~/.bashrc
```

Windows PowerShell:
```powershell
cd rust-env-setup
.\setup-rust-env.ps1
```

**快速开始：**
```bash
cargo new my-project    # 创建新项目
cd my-project
cargo build            # 构建项目
cargo run              # 运行项目
```

详细说明请查看 [rust-env-setup/README.md](rust-env-setup/README.md)

## 📚 文档

- [Docker 安装脚本详细说明](docker/README.md)
- [pip 源切换工具详细说明](pip-source-switcher/README.md)
- [Python 环境一键部署详细说明](python-env-setup/README.md)
- [Rust 环境一键部署详细说明](rust-env-setup/README.md)
- [常见问题解答](docs/FAQ.md)（待添加）

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

如果你有好用的脚本想要分享，请：
1. Fork 本仓库
2. 创建你的特性分支 (`git checkout -b feature/AmazingScript`)
3. 提交你的改动 (`git commit -m 'Add some AmazingScript'`)
4. 推送到分支 (`git push origin feature/AmazingScript`)
5. 开启一个 Pull Request

## 📝 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## ⚠️ 免责声明

本仓库中的脚本仅供学习和参考使用，使用前请仔细阅读脚本内容。
作者不对使用这些脚本造成的任何问题负责。

## 📮 联系方式

如有问题或建议，欢迎通过 Issue 联系。

---

**Star ⭐ 本项目如果对你有帮助！**
