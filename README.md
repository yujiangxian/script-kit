# 常用脚本工具集 🛠️

一个收集和整理常用脚本的仓库，帮助快速配置开发环境和自动化日常任务。

## 📦 项目结构

```
.
├── docker/              # Docker 相关脚本
│   └── kali-docker-install.sh    # Kali Linux Docker 一键安装
├── script-kit/          # Script Kit 相关脚本
└── docs/                # 详细文档
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

## 📚 文档

- [Docker 安装脚本详细说明](docker/README.md)
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
