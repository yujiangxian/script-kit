#!/bin/bash

# Python 环境一键部署脚本 (Linux 版本)
# 功能：安装 uv、配置镜像源、创建多版本虚拟环境

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
VENV_DIR="$HOME/.python-envs"
UV_INDEX_URL="https://mirrors.aliyun.com/pypi/simple/"
PIP_CONF_DIR="$HOME/.pip"
PIP_CONF_FILE="$PIP_CONF_DIR/pip.conf"

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_header() {
    echo ""
    echo "======================================"
    echo "  $1"
    echo "======================================"
    echo ""
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 安装 uv
install_uv() {
    print_header "安装 uv 包管理器"
    
    if command_exists uv; then
        print_info "uv 已安装，版本: $(uv --version)"
        read -p "是否重新安装？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 0
        fi
    fi
    
    print_info "正在安装 uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    # 添加到 PATH
    export PATH="$HOME/.cargo/bin:$PATH"
    
    if command_exists uv; then
        print_success "uv 安装成功！版本: $(uv --version)"
    else
        print_error "uv 安装失败，请检查网络连接"
        exit 1
    fi
}

# 配置 pip 镜像源
configure_pip_source() {
    print_header "配置 pip 镜像源"
    
    print_info "选择镜像源："
    echo "1) 阿里云 (推荐)"
    echo "2) 清华大学"
    echo "3) 中国科技大学"
    echo "4) 腾讯云"
    echo "5) 跳过配置"
    echo ""
    read -p "请选择 [1-5]: " choice
    
    case $choice in
        1)
            INDEX_URL="https://mirrors.aliyun.com/pypi/simple/"
            TRUSTED_HOST="mirrors.aliyun.com"
            ;;
        2)
            INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"
            TRUSTED_HOST="pypi.tuna.tsinghua.edu.cn"
            ;;
        3)
            INDEX_URL="https://pypi.mirrors.ustc.edu.cn/simple/"
            TRUSTED_HOST="pypi.mirrors.ustc.edu.cn"
            ;;
        4)
            INDEX_URL="https://mirrors.cloud.tencent.com/pypi/simple"
            TRUSTED_HOST="mirrors.cloud.tencent.com"
            ;;
        5)
            print_info "跳过 pip 源配置"
            return 0
            ;;
        *)
            print_warning "无效选择，使用默认源（阿里云）"
            INDEX_URL="https://mirrors.aliyun.com/pypi/simple/"
            TRUSTED_HOST="mirrors.aliyun.com"
            ;;
    esac
    
    # 创建配置目录
    mkdir -p "$PIP_CONF_DIR"
    
    # 写入配置
    cat > "$PIP_CONF_FILE" << EOF
[global]
index-url = $INDEX_URL
trusted-host = $TRUSTED_HOST

[install]
trusted-host = $TRUSTED_HOST
EOF
    
    print_success "pip 源配置完成: $INDEX_URL"
    
    # 配置 uv 使用相同的源
    export UV_INDEX_URL="$INDEX_URL"
    echo "export UV_INDEX_URL=\"$INDEX_URL\"" >> "$HOME/.bashrc"
    
    print_success "uv 源配置完成"
}

# 创建虚拟环境
create_venv() {
    local name=$1
    local python_version=$2
    local venv_path="$VENV_DIR/$name"
    
    print_info "创建虚拟环境: $name (Python $python_version)"
    
    if [ -d "$venv_path" ]; then
        print_warning "虚拟环境 $name 已存在"
        read -p "是否删除并重新创建？(y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$venv_path"
        else
            return 0
        fi
    fi
    
    # 使用 uv 创建虚拟环境
    uv venv "$venv_path" --python "$python_version"
    
    if [ $? -eq 0 ]; then
        print_success "虚拟环境 $name 创建成功"
        print_info "激活命令: source $venv_path/bin/activate"
    else
        print_error "虚拟环境 $name 创建失败"
    fi
}

# 创建所有虚拟环境
create_all_venvs() {
    print_header "创建 Python 虚拟环境"
    
    mkdir -p "$VENV_DIR"
    
    print_info "将创建以下虚拟环境："
    echo "  1. py39  - Python 3.9"
    echo "  2. py312 - Python 3.12"
    echo "  3. py313 - Python 3.13 (最新版)"
    echo ""
    read -p "是否继续？(Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_info "跳过虚拟环境创建"
        return 0
    fi
    
    create_venv "py39" "3.9"
    create_venv "py312" "3.12"
    create_venv "py313" "3.13"
    
    print_success "所有虚拟环境创建完成！"
}

# 创建便捷脚本
create_helper_scripts() {
    print_header "创建便捷管理脚本"
    
    # 创建激活脚本
    cat > "$HOME/.python-env-activate.sh" << 'EOF'
#!/bin/bash
# Python 虚拟环境快速激活脚本

VENV_DIR="$HOME/.python-envs"

activate_env() {
    local env_name=$1
    local venv_path="$VENV_DIR/$env_name"
    
    if [ -d "$venv_path" ]; then
        source "$venv_path/bin/activate"
        echo "已激活虚拟环境: $env_name (Python $(python --version 2>&1 | cut -d' ' -f2))"
    else
        echo "错误: 虚拟环境 $env_name 不存在"
        echo "可用环境:"
        ls -1 "$VENV_DIR" 2>/dev/null || echo "  (无)"
    fi
}

# 如果提供了参数，直接激活
if [ $# -eq 1 ]; then
    activate_env "$1"
else
    echo "用法: source ~/.python-env-activate.sh <环境名>"
    echo ""
    echo "可用环境:"
    ls -1 "$VENV_DIR" 2>/dev/null || echo "  (无)"
fi
EOF
    
    chmod +x "$HOME/.python-env-activate.sh"
    
    # 添加别名到 .bashrc
    if ! grep -q "alias pyenv=" "$HOME/.bashrc" 2>/dev/null; then
        cat >> "$HOME/.bashrc" << 'EOF'

# Python 虚拟环境快捷命令
alias pyenv='source ~/.python-env-activate.sh'
alias py39='source ~/.python-env-activate.sh py39'
alias py312='source ~/.python-env-activate.sh py312'
alias py313='source ~/.python-env-activate.sh py313'
alias pylist='ls -1 ~/.python-envs'
EOF
        print_success "已添加快捷命令到 ~/.bashrc"
    fi
    
    print_success "便捷脚本创建完成！"
}

# 显示使用说明
show_usage() {
    print_header "安装完成！"
    
    echo "📦 已安装组件："
    echo "  ✓ uv 包管理器"
    echo "  ✓ pip 镜像源配置"
    echo "  ✓ Python 虚拟环境 (py39, py312, py313)"
    echo ""
    echo "🚀 快速开始："
    echo ""
    echo "  1. 重新加载配置："
    echo "     source ~/.bashrc"
    echo ""
    echo "  2. 激活虚拟环境："
    echo "     py39      # 激活 Python 3.9 环境"
    echo "     py312     # 激活 Python 3.12 环境"
    echo "     py313     # 激活 Python 3.13 环境"
    echo ""
    echo "  3. 查看所有环境："
    echo "     pylist"
    echo ""
    echo "  4. 使用 uv 安装包（推荐，速度快）："
    echo "     uv pip install requests"
    echo ""
    echo "  5. 使用 pip 安装包："
    echo "     pip install requests"
    echo ""
    echo "📝 虚拟环境位置: $VENV_DIR"
    echo "📝 pip 配置文件: $PIP_CONF_FILE"
    echo ""
    print_success "环境配置完成，开始愉快地编码吧！"
}

# 主函数
main() {
    print_header "Python 环境一键部署"
    
    print_info "此脚本将："
    echo "  1. 安装 uv 包管理器"
    echo "  2. 配置 pip/uv 镜像源"
    echo "  3. 创建多版本 Python 虚拟环境"
    echo "  4. 设置便捷管理命令"
    echo ""
    read -p "是否继续？(Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_info "已取消安装"
        exit 0
    fi
    
    install_uv
    configure_pip_source
    create_all_venvs
    create_helper_scripts
    show_usage
}

# 运行主函数
main
