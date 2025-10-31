#!/bin/bash

# pip 源一键切换脚本
# 支持多个国内镜像源，自动测试可用性并切换

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# pip 配置文件路径
PIP_CONF_DIR="$HOME/.pip"
PIP_CONF_FILE="$PIP_CONF_DIR/pip.conf"

# 定义镜像源列表
declare -A PIP_SOURCES=(
    ["清华大学"]="https://pypi.tuna.tsinghua.edu.cn/simple"
    ["阿里云"]="https://mirrors.aliyun.com/pypi/simple/"
    ["中国科技大学"]="https://pypi.mirrors.ustc.edu.cn/simple/"
    ["豆瓣"]="https://pypi.douban.com/simple/"
    ["华为云"]="https://repo.huaweicloud.com/repository/pypi/simple"
    ["腾讯云"]="https://mirrors.cloud.tencent.com/pypi/simple"
    ["网易"]="https://mirrors.163.com/pypi/simple/"
    ["官方源"]="https://pypi.org/simple"
)

# 打印带颜色的消息
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

# 显示当前 pip 源
show_current_source() {
    print_info "当前 pip 源配置："
    if [ -f "$PIP_CONF_FILE" ]; then
        cat "$PIP_CONF_FILE"
    else
        print_warning "未找到 pip 配置文件，使用默认源"
    fi
    echo ""
}

# 测试源的可用性
test_source() {
    local url=$1
    local timeout=5
    
    # 使用 curl 测试连接
    if command -v curl &> /dev/null; then
        if curl -s --connect-timeout $timeout --max-time $timeout "$url" > /dev/null 2>&1; then
            return 0
        fi
    # 使用 wget 测试连接
    elif command -v wget &> /dev/null; then
        if wget -q --timeout=$timeout --tries=1 --spider "$url" > /dev/null 2>&1; then
            return 0
        fi
    else
        print_warning "未找到 curl 或 wget，无法测试源可用性"
        return 1
    fi
    
    return 1
}

# 设置 pip 源
set_pip_source() {
    local source_name=$1
    local source_url=$2
    
    # 创建 .pip 目录
    if [ ! -d "$PIP_CONF_DIR" ]; then
        mkdir -p "$PIP_CONF_DIR"
        print_info "创建配置目录: $PIP_CONF_DIR"
    fi
    
    # 写入配置文件
    cat > "$PIP_CONF_FILE" << EOF
[global]
index-url = $source_url
trusted-host = $(echo $source_url | sed -e 's|https\?://||' -e 's|/.*||')

[install]
trusted-host = $(echo $source_url | sed -e 's|https\?://||' -e 's|/.*||')
EOF
    
    if [ $? -eq 0 ]; then
        print_success "已成功切换到 ${source_name} 源"
        print_success "源地址: $source_url"
        return 0
    else
        print_error "切换失败"
        return 1
    fi
}

# 自动选择最快的源
auto_select_source() {
    print_info "正在测试各个源的可用性..."
    echo ""
    
    local fastest_source=""
    local fastest_url=""
    
    for source_name in "${!PIP_SOURCES[@]}"; do
        local url="${PIP_SOURCES[$source_name]}"
        echo -n "测试 ${source_name} ... "
        
        if test_source "$url"; then
            echo -e "${GREEN}✓ 可用${NC}"
            if [ -z "$fastest_source" ]; then
                fastest_source="$source_name"
                fastest_url="$url"
            fi
        else
            echo -e "${RED}✗ 不可用${NC}"
        fi
    done
    
    echo ""
    
    if [ -n "$fastest_source" ]; then
        print_info "选择第一个可用源: $fastest_source"
        set_pip_source "$fastest_source" "$fastest_url"
    else
        print_error "所有源均不可用，请检查网络连接"
        return 1
    fi
}

# 显示菜单
show_menu() {
    echo ""
    echo "======================================"
    echo "       pip 源一键切换工具"
    echo "======================================"
    echo ""
    echo "请选择操作："
    echo ""
    echo "  0) 自动选择可用源"
    echo "  1) 清华大学源"
    echo "  2) 阿里云源"
    echo "  3) 中国科技大学源"
    echo "  4) 豆瓣源"
    echo "  5) 华为云源"
    echo "  6) 腾讯云源"
    echo "  7) 网易源"
    echo "  8) 官方源 (PyPI)"
    echo "  9) 查看当前源"
    echo "  q) 退出"
    echo ""
    echo -n "请输入选项 [0-9/q]: "
}

# 主函数
main() {
    # 检查是否有参数
    if [ $# -gt 0 ]; then
        case $1 in
            auto)
                auto_select_source
                ;;
            show)
                show_current_source
                ;;
            tsinghua|tuna)
                set_pip_source "清华大学" "${PIP_SOURCES[清华大学]}"
                ;;
            aliyun|ali)
                set_pip_source "阿里云" "${PIP_SOURCES[阿里云]}"
                ;;
            ustc)
                set_pip_source "中国科技大学" "${PIP_SOURCES[中国科技大学]}"
                ;;
            douban)
                set_pip_source "豆瓣" "${PIP_SOURCES[豆瓣]}"
                ;;
            huawei)
                set_pip_source "华为云" "${PIP_SOURCES[华为云]}"
                ;;
            tencent)
                set_pip_source "腾讯云" "${PIP_SOURCES[腾讯云]}"
                ;;
            163)
                set_pip_source "网易" "${PIP_SOURCES[网易]}"
                ;;
            pypi|official)
                set_pip_source "官方源" "${PIP_SOURCES[官方源]}"
                ;;
            *)
                echo "用法: $0 [auto|show|tsinghua|aliyun|ustc|douban|huawei|tencent|163|pypi]"
                exit 1
                ;;
        esac
        exit 0
    fi
    
    # 交互式菜单
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            0)
                auto_select_source
                ;;
            1)
                set_pip_source "清华大学" "${PIP_SOURCES[清华大学]}"
                ;;
            2)
                set_pip_source "阿里云" "${PIP_SOURCES[阿里云]}"
                ;;
            3)
                set_pip_source "中国科技大学" "${PIP_SOURCES[中国科技大学]}"
                ;;
            4)
                set_pip_source "豆瓣" "${PIP_SOURCES[豆瓣]}"
                ;;
            5)
                set_pip_source "华为云" "${PIP_SOURCES[华为云]}"
                ;;
            6)
                set_pip_source "腾讯云" "${PIP_SOURCES[腾讯云]}"
                ;;
            7)
                set_pip_source "网易" "${PIP_SOURCES[网易]}"
                ;;
            8)
                set_pip_source "官方源" "${PIP_SOURCES[官方源]}"
                ;;
            9)
                show_current_source
                ;;
            q|Q)
                print_info "退出程序"
                exit 0
                ;;
            *)
                print_error "无效选项，请重新选择"
                ;;
        esac
        
        echo ""
        read -p "按回车键继续..." -r
    done
}

# 运行主函数
main "$@"
