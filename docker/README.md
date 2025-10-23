# Docker 相关脚本

这个目录包含 Docker 相关的安装和配置脚本。

## 📋 脚本列表

### kali-docker-install.sh - Kali Linux Docker 一键安装脚本

专为 Kali Linux 设计的 Docker 完整安装解决方案。

#### 🎯 解决的问题

- ❌ Docker 官方源在 Kali 上出现 404 错误
- ❌ 国外镜像源下载速度慢
- ❌ 手动配置步骤繁琐易错
- ❌ 权限配置不当需要频繁使用 sudo

#### ✨ 功能特性

1. **智能清理**
   - 自动移除冲突的旧版本 Docker 包
   - 清理错误的仓库配置
   - 停止运行中的服务避免冲突

2. **官方源安装**
   - 使用 Kali 官方仓库的 docker.io 包
   - 避免 Docker CE 仓库的 404 问题
   - 包含完整的 Docker 引擎和客户端

3. **镜像加速配置**
   - 配置多个国内镜像源（自动故障转移）
   - 优化日志配置（限制大小）
   - 使用 overlay2 存储驱动

4. **Docker Compose 安装**
   - 优先尝试 apt 安装
   - 失败时自动从 GitHub 下载
   - 创建符号链接方便使用

5. **用户权限配置**
   - 自动添加当前用户到 docker 组
   - 配置后可免 sudo 运行 Docker

6. **完整验证**
   - 检查版本信息
   - 验证服务状态
   - 测试镜像拉取
   - 可选的速度测试

#### 📦 安装内容

- Docker Engine (docker.io)
- Docker CLI
- Docker Compose
- 必要的依赖工具（curl, gnupg, ca-certificates 等）

#### 🚀 使用方法

##### 方法一：直接下载运行

```bash
# 下载脚本
wget https://raw.githubusercontent.com/yujiangxian/script-kit/main/docker/kali-docker-install.sh

# 添加执行权限
chmod +x kali-docker-install.sh

# 运行安装
./kali-docker-install.sh
```

##### 方法二：克隆仓库

```bash
# 克隆仓库
git clone https://github.com/yujiangxian/script-kit.git
cd script-kit/docker

# 运行脚本
chmod +x kali-docker-install.sh
./kali-docker-install.sh
```

##### 方法三：一键执行（不保存脚本）

```bash
curl -fsSL https://raw.githubusercontent.com/yujiangxian/script-kit/main/docker/kali-docker-install.sh | bash
```

#### 📝 安装步骤说明

脚本会按以下顺序执行：

1. **系统检查** - 确认是否为 Kali Linux
2. **清理旧配置** - 移除可能冲突的包和配置
3. **安装 Docker** - 从 Kali 官方仓库安装
4. **配置服务** - 启动并启用 Docker 服务
5. **配置镜像加速** - 设置国内镜像源
6. **安装 Compose** - 安装 Docker Compose
7. **配置权限** - 添加用户到 docker 组
8. **验证安装** - 运行测试确保一切正常

#### ⚙️ 配置的镜像加速器

脚本会配置以下镜像源（按优先级）：

1. `https://docker.xuanyuan.me`
2. `https://hub-mirror.c.163.com` (网易)
3. `https://mirror.baidubce.com` (百度)
4. `https://docker.nju.edu.cn` (南京大学)
5. `https://dockerproxy.com`

#### 🔧 安装后配置

安装完成后，需要执行以下操作使权限生效：

```bash
# 方法一：重新登录系统（推荐）
# 退出当前会话，重新登录

# 方法二：临时切换组（当前终端有效）
newgrp docker

# 方法三：重启系统
sudo reboot
```

#### 📊 验证安装

```bash
# 检查 Docker 版本
docker --version

# 检查 Docker Compose 版本
docker-compose --version

# 查看 Docker 信息（包括镜像加速器）
docker info

# 运行测试容器
docker run --rm hello-world

# 测试 Alpine 镜像
docker run --rm alpine echo "Hello from Alpine!"
```

#### 🎯 常用命令

```bash
# 查看运行中的容器
docker ps

# 查看所有容器（包括停止的）
docker ps -a

# 查看本地镜像
docker images

# 拉取镜像
docker pull ubuntu:latest

# 删除容器
docker rm <容器ID>

# 删除镜像
docker rmi <镜像ID>

# 查看 Docker 服务状态
sudo systemctl status docker

# 重启 Docker 服务
sudo systemctl restart docker
```

#### ❓ 常见问题

**Q: 安装后运行 docker 命令提示权限不足？**

A: 需要重新登录或运行 `newgrp docker` 使组权限生效。

**Q: 镜像下载还是很慢？**

A: 可以手动编辑 `/etc/docker/daemon.json` 调整镜像源顺序，或添加其他可用的镜像源。

**Q: 如何卸载 Docker？**

A: 运行以下命令：
```bash
sudo apt remove --purge docker.io docker-compose
sudo rm -rf /var/lib/docker
sudo rm -rf /etc/docker
```

**Q: 脚本执行失败怎么办？**

A: 脚本使用 `set -e`，遇到错误会自动停止。查看错误信息，可以尝试：
- 检查网络连接
- 更新系统：`sudo apt update && sudo apt upgrade`
- 查看详细日志：`sudo journalctl -u docker`

**Q: 可以在其他 Debian 系发行版使用吗？**

A: 理论上可以，但脚本针对 Kali 优化。其他发行版建议参考官方文档。

#### 🔍 故障排查

如果遇到问题，可以检查：

```bash
# 查看 Docker 服务状态
sudo systemctl status docker

# 查看 Docker 日志
sudo journalctl -u docker -n 50

# 检查配置文件
cat /etc/docker/daemon.json

# 测试网络连接
ping -c 3 docker.xuanyuan.me
```

#### 📚 相关资源

- [Docker 官方文档](https://docs.docker.com/)
- [Docker Compose 文档](https://docs.docker.com/compose/)
- [Kali Linux 官方文档](https://www.kali.org/docs/)

#### 🤝 贡献

发现问题或有改进建议？欢迎提交 Issue 或 Pull Request！

#### ⚠️ 注意事项

- 脚本需要 sudo 权限
- 建议在全新安装的 Kali 系统上使用
- 安装前会清理旧的 Docker 配置
- 脚本会修改系统配置，使用前请确保了解其功能

#### 📄 许可证

MIT License - 详见仓库根目录的 LICENSE 文件
