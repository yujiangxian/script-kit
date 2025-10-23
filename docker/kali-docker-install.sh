#!/bin/bash

# Kali Linux Docker 一键安装脚本 (使用Kali官方仓库 + 国内镜像加速)
# 解决 Docker 官方源 404 问题，集成国内镜像配置

set -e  # 遇到错误立即退出

echo "🐳 Kali Linux Docker 一键安装脚本 (解决404错误)"
echo "=============================================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 检查系统
check_system() {
    if ! grep -q "Kali GNU/Linux" /etc/os-release; then
        log_warn "此脚本专为 Kali Linux 设计，当前系统可能不兼容"
        read -p "是否继续? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# 清理可能的错误配置
cleanup_old_config() {
    log_step "1. 清理旧配置..."
    
    # 移除可能出错的 Docker CE 仓库配置
    if [ -f /etc/apt/sources.list.d/docker.list ]; then
        log_info "移除旧的 Docker CE 仓库配置..."
        sudo rm -f /etc/apt/sources.list.d/docker.list
    fi
    
    # 停止 Docker 服务
    if systemctl is-active --quiet docker; then
        log_info "停止运行中的 Docker 服务..."
        sudo systemctl stop docker
    fi
    
    # 移除可能冲突的包
    log_info "移除可能冲突的 Docker 包..."
    sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
}

# 通过 Kali 官方仓库安装 Docker
install_docker_from_kali() {
    log_step "2. 通过 Kali 官方仓库安装 Docker..."
    
    log_info "更新系统包列表..."
    sudo apt update
    
    log_info "安装 docker.io (包含 Docker 引擎和客户端)..."
    sudo apt install -y docker.io
    
    log_info "安装依赖工具..."
    sudo apt install -y curl gnupg apt-transport-https ca-certificates
}

# 配置 Docker 服务
configure_docker_service() {
    log_step "3. 配置 Docker 服务..."
    
    log_info "启动并启用 Docker 服务..."
    sudo systemctl enable docker --now
    
    log_info "检查 Docker 服务状态..."
    if sudo systemctl is-active --quiet docker; then
        log_info "Docker 服务运行正常"
    else
        log_error "Docker 服务启动失败"
        sudo systemctl status docker
        exit 1
    fi
}

# 配置国内镜像加速器
configure_registry_mirrors() {
    log_step "4. 配置国内镜像加速器..."
    
    log_info "创建 Docker 配置目录..."
    sudo mkdir -p /etc/docker
    
    # 备份原有配置
    if [ -f /etc/docker/daemon.json ]; then
        sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak
        log_info "已备份原有配置: /etc/docker/daemon.json.bak"
    fi
    
    log_info "配置国内镜像加速器..."
    sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "registry-mirrors": [
    "https://docker.xuanyuan.me",
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com",
    "https://docker.nju.edu.cn",
    "https://dockerproxy.com"
  ],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
EOF
    
    log_info "重启 Docker 服务应用配置..."
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    
    # 等待服务重启完成
    sleep 3
}

# 安装 Docker Compose
install_docker_compose() {
    log_step "5. 安装 Docker Compose..."
    
    # 尝试通过 apt 安装
    if sudo apt install -y docker-compose 2>/dev/null; then
        log_info "通过 apt 安装 docker-compose 成功"
        return 0
    fi
    
    log_info "通过 apt 安装失败，从 GitHub 下载..."
    
    # 从 GitHub 下载
    COMPOSE_VERSION="v2.24.7"
    log_info "下载 Docker Compose ${COMPOSE_VERSION}..."
    
    sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
    
    sudo chmod +x /usr/local/bin/docker-compose
    
    # 创建符号链接
    if [ ! -f /usr/bin/docker-compose ]; then
        sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    fi
}

# 配置用户权限
configure_user_permissions() {
    log_step "6. 配置用户权限..."
    
    CURRENT_USER=${SUDO_USER:-$USER}
    log_info "当前用户: $CURRENT_USER"
    
    # 创建 docker 组（如果不存在）
    sudo groupadd docker 2>/dev/null || true
    
    # 添加用户到 docker 组
    if groups $CURRENT_USER | grep -q "\bdocker\b"; then
        log_info "用户 $CURRENT_USER 已在 docker 组中"
    else
        log_info "将用户 $CURRENT_USER 添加到 docker 组..."
        sudo usermod -aG docker $CURRENT_USER
    fi
}

# 验证安装
verify_installation() {
    log_step "7. 验证安装..."
    
    echo "=== Docker 版本 ==="
    docker --version || (log_warn "Docker 命令执行失败，使用 sudo 重试..." && sudo docker --version)
    
    echo -e "\n=== Docker Compose 版本 ==="
    docker-compose --version || (log_warn "Docker Compose 命令执行失败，使用 sudo 重试..." && sudo docker-compose --version)
    
    echo -e "\n=== Docker 服务状态 ==="
    sudo systemctl is-active docker
    
    echo -e "\n=== 镜像加速器配置 ==="
    sudo docker info | grep -A 10 "Registry Mirrors" || docker info | grep -A 10 "Registry Mirrors"
    
    echo -e "\n=== 测试 Docker 运行 ==="
    if sudo docker run --rm hello-world | head -10; then
        log_info "🎉 Docker 测试运行成功！"
    else
        log_warn "Docker 测试运行失败，使用 sudo 重试..."
        sudo docker run --rm hello-world | head -10
    fi
}

# 显示使用提示
show_usage_tips() {
    echo -e "\n${GREEN}🎉 安装完成！使用提示：${NC}"
    echo "=============================================="
    echo "1. 重新登录或运行以下命令使组权限生效:"
    echo "   $ newgrp docker"
    echo ""
    echo "2. 测试非 root 用户运行 Docker:"
    echo "   $ docker run --rm alpine echo 'Hello Docker!'"
    echo ""
    echo "3. 查看镜像加速器状态:"
    echo "   $ docker info | grep -A 10 Mirrors"
    echo ""
    echo "4. 常用命令:"
    echo "   - 查看镜像: docker images"
    echo "   - 查看容器: docker ps -a"
    echo "   - 拉取镜像: docker pull ubuntu:latest"
    echo ""
    log_warn "重要：请重新登录或运行 'newgrp docker' 来使组权限生效！"
}

# 显示镜像加速器测试结果
test_mirror_speed() {
    log_step "测试镜像下载速度..."
    echo "正在测试镜像加速器效果，这可能需要几分钟..."
    
    # 测试基础镜像下载
    echo -e "\n测试 Alpine Linux 镜像下载:"
    time sudo docker pull alpine:latest
    
    echo -e "\n测试 Ubuntu 镜像下载:"
    time sudo docker pull ubuntu:latest
    
    log_info "镜像下载测试完成！如果下载速度较快，说明镜像加速器配置成功。"
}

# 主函数
main() {
    echo "开始执行 Kali Linux Docker 一键安装..."
    echo "此脚本将执行以下操作:"
    echo "  1. 清理旧配置 (解决404错误)"
    echo "  2. 通过 Kali 官方仓库安装 docker.io"
    echo "  3. 配置国内镜像加速器"
    echo "  4. 安装 Docker Compose"
    echo "  5. 配置用户权限"
    echo "  6. 验证安装"
    echo ""
    
    read -p "是否继续? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "用户取消安装"
        exit 0
    fi
    
    # 执行安装步骤
    check_system
    cleanup_old_config
    install_docker_from_kali
    configure_docker_service
    configure_registry_mirrors
    install_docker_compose
    configure_user_permissions
    
    log_info "基本安装完成！开始验证..."
    verify_installation
    
    echo ""
    read -p "是否测试镜像下载速度? (可选，需要几分钟) (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        test_mirror_speed
    fi
    
    show_usage_tips
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi