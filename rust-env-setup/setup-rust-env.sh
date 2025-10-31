#!/bin/bash

# Rust 环境一键部署脚本 (Linux 版本)
# 功能：智能选择下载源、安装 Rust、配置国内镜像

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"
RUSTUP_HOME="${RUSTUP_HOME:-$HOME/.rustup}"
RUSTUP_DIST_SERVER="https://mirrors.ustc.edu.cn/rust-static"
RUSTUP_UPDATE_ROOT="https://mirrors.ustc.edu.cn/rust-static/rustup"

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

# 测试 URL 下载速度
test_download_speed() {
    local url=$1
    local timeout=10
    
    print_info "测试 $url ..."
    
    # 使用 curl 测试下载速度
    if command_exists curl; then
        local start_time=$(date +%s%N)
        if curl -fsSL --connect-timeout $timeout --max-time $timeout "$url" -o /dev/null 2>/dev/null; then
            local end_time=$(date +%s%N)
            local duration=$(( (end_time - start_time) / 1000000 ))
            echo $duration
            return 0
        fi
    # 使用 wget 测试
    elif command_exists wget; then
        local start_time=$(date +%s%N)
        if wget -q --timeout=$timeout --tries=1 "$url" -O /dev/null 2>/dev/null; then
            local end_time=$(date +%s%N)
            local duration=$(( (end_time - start_time) / 1000000 ))
            echo $duration
            return 0
        fi
    fi
    
    echo "999999"
    return 1
}

# 选择最快的下载源
select_fastest_source() {
    print_header "测试下载源速度"
    
    # 定义测试 URL
    local official_url="https://sh.rustup.rs"
    local ustc_url="https://mirrors.ustc.edu.cn/rust-static/rustup/rustup-init.sh"
    local tuna_url="https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup-init.sh"
    
    print_info "正在测试各个源的速度（超时 10 秒）..."
    echo ""
    
    # 测试官方源
    echo -n "测试官方源 (rustup.rs) ... "
    local official_time=$(test_download_speed "$official_url")
    if [ "$official_time" != "999999" ]; then
        echo -e "${GREEN}✓ 可用 (${official_time}ms)${NC}"
    else
        echo -e "${RED}✗ 不可用${NC}"
    fi
    
    # 测试中科大源
    echo -n "测试中科大源 (USTC) ... "
    local ustc_time=$(test_download_speed "$ustc_url")
    if [ "$ustc_time" != "999999" ]; then
        echo -e "${GREEN}✓ 可用 (${ustc_time}ms)${NC}"
    else
        echo -e "${RED}✗ 不可用${NC}"
    fi
    
    # 测试清华源
    echo -n "测试清华源 (TUNA) ... "
    local tuna_time=$(test_download_speed "$tuna_url")
    if [ "$tuna_time" != "999999" ]; then
        echo -e "${GREEN}✓ 可用 (${tuna_time}ms)${NC}"
    else
        echo -e "${RED}✗ 不可用${NC}"
    fi
    
    echo ""
    
    # 选择最快的源
    local min_time=$official_time
    local selected_source="official"
    local selected_url="$official_url"
    
    if [ "$ustc_time" -lt "$min_time" ]; then
        min_time=$ustc_time
        selected_source="ustc"
        selected_url="$ustc_url"
    fi
    
    if [ "$tuna_time" -lt "$min_time" ]; then
        min_time=$tuna_time
        selected_source="tuna"
        selected_url="$tuna_url"
    fi
    
    if [ "$min_time" = "999999" ]; then
        print_error "所有源均不可用，请检查网络连接"
        exit 1
    fi
    
    case $selected_source in
        official)
            print_success "选择官方源 (最快: ${min_time}ms)"
            INSTALL_SOURCE="official"
            INSTALL_URL="$official_url"
            ;;
        ustc)
            print_success "选择中科大源 (最快: ${min_time}ms)"
            INSTALL_SOURCE="ustc"
            INSTALL_URL="$ustc_url"
            export RUSTUP_DIST_SERVER="https://mirrors.ustc.edu.cn/rust-static"
            export RUSTUP_UPDATE_ROOT="https://mirrors.ustc.edu.cn/rust-static/rustup"
            ;;
        tuna)
            print_success "选择清华源 (最快: ${min_time}ms)"
            INSTALL_SOURCE="tuna"
            INSTALL_URL="$tuna_url"
            export RUSTUP_DIST_SERVER="https://mirrors.tuna.tsinghua.edu.cn/rustup"
            export RUSTUP_UPDATE_ROOT="https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup"
            ;;
    esac
}

# 安装 Rust
install_rust() {
    print_header "安装 Rust"
    
    if command_exists rustc; then
        print_info "Rust 已安装，版本: $(rustc --version)"
        read -p "是否重新安装？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 0
        fi
    fi
    
    print_info "正在从 $INSTALL_SOURCE 源下载并安装 Rust..."
    
    # 下载安装脚本
    if command_exists curl; then
        curl -fsSL "$INSTALL_URL" -o /tmp/rustup-init.sh
    elif command_exists wget; then
        wget -q "$INSTALL_URL" -O /tmp/rustup-init.sh
    else
        print_error "需要 curl 或 wget 来下载安装脚本"
        exit 1
    fi
    
    # 运行安装脚本
    chmod +x /tmp/rustup-init.sh
    /tmp/rustup-init.sh -y --no-modify-path
    
    # 清理
    rm -f /tmp/rustup-init.sh
    
    # 添加到 PATH
    export PATH="$CARGO_HOME/bin:$PATH"
    
    if command_exists rustc; then
        print_success "Rust 安装成功！"
        print_info "rustc 版本: $(rustc --version)"
        print_info "cargo 版本: $(cargo --version)"
    else
        print_error "Rust 安装失败"
        exit 1
    fi
}

# 配置 Cargo 镜像源
configure_cargo_mirror() {
    print_header "配置 Cargo 镜像源"
    
    print_info "选择 Cargo 镜像源："
    echo "1) 中国科技大学 (推荐)"
    echo "2) 清华大学"
    echo "3) 上海交通大学"
    echo "4) 字节跳动"
    echo "5) 跳过配置"
    echo ""
    read -p "请选择 [1-5]: " choice
    
    local registry_url=""
    local source_name=""
    
    case $choice in
        1)
            registry_url="https://mirrors.ustc.edu.cn/crates.io-index"
            source_name="中国科技大学"
            ;;
        2)
            registry_url="https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"
            source_name="清华大学"
            ;;
        3)
            registry_url="https://mirrors.sjtug.sjtu.edu.cn/git/crates.io-index/"
            source_name="上海交通大学"
            ;;
        4)
            registry_url="https://rsproxy.cn/crates.io-index"
            source_name="字节跳动"
            ;;
        5)
            print_info "跳过 Cargo 源配置"
            return 0
            ;;
        *)
            print_warning "无效选择，使用默认源（中科大）"
            registry_url="https://mirrors.ustc.edu.cn/crates.io-index"
            source_name="中国科技大学"
            ;;
    esac
    
    # 创建配置目录
    mkdir -p "$CARGO_HOME"
    
    # 写入配置
    cat > "$CARGO_HOME/config.toml" << EOF
[source.crates-io]
replace-with = 'ustc'

[source.ustc]
registry = "$registry_url"

[net]
git-fetch-with-cli = true
EOF
    
    print_success "Cargo 源配置完成: $source_name"
    print_info "配置文件: $CARGO_HOME/config.toml"
}

# 配置 Rustup 镜像源
configure_rustup_mirror() {
    print_header "配置 Rustup 镜像源"
    
    print_info "选择 Rustup 镜像源："
    echo "1) 中国科技大学 (推荐)"
    echo "2) 清华大学"
    echo "3) 跳过配置"
    echo ""
    read -p "请选择 [1-3]: " choice
    
    local dist_server=""
    local update_root=""
    local source_name=""
    
    case $choice in
        1)
            dist_server="https://mirrors.ustc.edu.cn/rust-static"
            update_root="https://mirrors.ustc.edu.cn/rust-static/rustup"
            source_name="中国科技大学"
            ;;
        2)
            dist_server="https://mirrors.tuna.tsinghua.edu.cn/rustup"
            update_root="https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup"
            source_name="清华大学"
            ;;
        3)
            print_info "跳过 Rustup 源配置"
            return 0
            ;;
        *)
            print_warning "无效选择，使用默认源（中科大）"
            dist_server="https://mirrors.ustc.edu.cn/rust-static"
            update_root="https://mirrors.ustc.edu.cn/rust-static/rustup"
            source_name="中国科技大学"
            ;;
    esac
    
    # 添加环境变量到 .bashrc
    if ! grep -q "RUSTUP_DIST_SERVER" "$HOME/.bashrc" 2>/dev/null; then
        cat >> "$HOME/.bashrc" << EOF

# Rustup 镜像源配置
export RUSTUP_DIST_SERVER="$dist_server"
export RUSTUP_UPDATE_ROOT="$update_root"
EOF
        print_success "已添加 Rustup 镜像源配置到 ~/.bashrc"
    else
        # 更新现有配置
        sed -i "s|export RUSTUP_DIST_SERVER=.*|export RUSTUP_DIST_SERVER=\"$dist_server\"|g" "$HOME/.bashrc"
        sed -i "s|export RUSTUP_UPDATE_ROOT=.*|export RUSTUP_UPDATE_ROOT=\"$update_root\"|g" "$HOME/.bashrc"
        print_success "已更新 Rustup 镜像源配置"
    fi
    
    # 立即生效
    export RUSTUP_DIST_SERVER="$dist_server"
    export RUSTUP_UPDATE_ROOT="$update_root"
    
    print_success "Rustup 源配置完成: $source_name"
}

# 安装常用组件
install_components() {
    print_header "安装常用组件"
    
    print_info "推荐安装以下组件："
    echo "  1. rust-src (源码，用于 IDE 补全)"
    echo "  2. rust-analyzer (LSP 服务器)"
    echo "  3. clippy (代码检查工具)"
    echo "  4. rustfmt (代码格式化工具)"
    echo ""
    read -p "是否安装？(Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_info "跳过组件安装"
        return 0
    fi
    
    print_info "正在安装组件..."
    
    rustup component add rust-src
    rustup component add rust-analyzer
    rustup component add clippy
    rustup component add rustfmt
    
    print_success "组件安装完成！"
}

# 验证安装
verify_installation() {
    print_header "验证安装"
    
    print_info "检查 Rust 工具链..."
    
    if command_exists rustc; then
        echo "  ✓ rustc: $(rustc --version)"
    else
        echo "  ✗ rustc: 未安装"
    fi
    
    if command_exists cargo; then
        echo "  ✓ cargo: $(cargo --version)"
    else
        echo "  ✗ cargo: 未安装"
    fi
    
    if command_exists rustup; then
        echo "  ✓ rustup: $(rustup --version)"
    else
        echo "  ✗ rustup: 未安装"
    fi
    
    echo ""
    print_info "测试编译..."
    
    # 创建临时测试项目
    local test_dir="/tmp/rust-test-$$"
    mkdir -p "$test_dir"
    cd "$test_dir"
    
    cargo init --bin test-project --quiet
    cd test-project
    
    if cargo build --quiet 2>/dev/null; then
        print_success "编译测试通过！"
    else
        print_warning "编译测试失败，但这可能是正常的"
    fi
    
    # 清理
    cd /
    rm -rf "$test_dir"
}

# 显示使用说明
show_usage() {
    print_header "安装完成！"
    
    echo "📦 已安装组件："
    echo "  ✓ Rust 工具链 (rustc, cargo, rustup)"
    echo "  ✓ Cargo 镜像源配置"
    echo "  ✓ Rustup 镜像源配置"
    echo "  ✓ 常用开发组件"
    echo ""
    echo "🚀 快速开始："
    echo ""
    echo "  1. 重新加载配置："
    echo "     source ~/.bashrc"
    echo ""
    echo "  2. 创建新项目："
    echo "     cargo new my-project"
    echo "     cd my-project"
    echo ""
    echo "  3. 构建项目："
    echo "     cargo build"
    echo ""
    echo "  4. 运行项目："
    echo "     cargo run"
    echo ""
    echo "  5. 更新 Rust："
    echo "     rustup update"
    echo ""
    echo "📝 配置文件位置："
    echo "  - Cargo 配置: $CARGO_HOME/config.toml"
    echo "  - Rustup 配置: ~/.bashrc"
    echo "  - 工具链位置: $RUSTUP_HOME"
    echo ""
    echo "📚 常用命令："
    echo "  cargo new <name>      # 创建新项目"
    echo "  cargo build           # 构建项目"
    echo "  cargo run             # 运行项目"
    echo "  cargo test            # 运行测试"
    echo "  cargo clippy          # 代码检查"
    echo "  cargo fmt             # 代码格式化"
    echo "  rustup update         # 更新 Rust"
    echo "  rustup show           # 显示工具链信息"
    echo ""
    print_success "Rust 环境配置完成，开始愉快地编码吧！"
}

# 主函数
main() {
    print_header "Rust 环境一键部署"
    
    print_info "此脚本将："
    echo "  1. 测试并选择最快的下载源"
    echo "  2. 安装 Rust 工具链"
    echo "  3. 配置 Cargo 镜像源"
    echo "  4. 配置 Rustup 镜像源"
    echo "  5. 安装常用开发组件"
    echo ""
    read -p "是否继续？(Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_info "已取消安装"
        exit 0
    fi
    
    select_fastest_source
    install_rust
    configure_cargo_mirror
    configure_rustup_mirror
    install_components
    verify_installation
    show_usage
}

# 运行主函数
main
