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

## 🚀 工具列表

### 🐳 Docker 工具
- **[Kali Linux Docker 一键安装](docker/)** - 解决 Kali 官方源 404 问题，配置国内镜像加速

### 🐍 Python 工具
- **[pip 源切换工具](pip-source-switcher/)** - 快速切换 pip 镜像源，支持多个国内源
- **[Python 环境一键部署](python-env-setup/)** - 安装 uv、配置镜像源、创建多版本虚拟环境

### 🦀 Rust 工具
- **[Rust 环境一键部署](rust-env-setup/)** - 智能选择下载源、配置镜像、安装工具链

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
