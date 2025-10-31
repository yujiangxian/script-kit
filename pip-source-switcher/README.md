# pip 源一键切换工具

一个简单易用的跨平台 pip 源切换脚本，支持 Linux 和 Windows 系统，支持多个国内镜像源，自动测试可用性。

## 功能特点

- 🚀 支持多个国内主流镜像源
- ✅ 自动测试源的可用性
- 🎯 一键切换到可用源
- 💻 支持交互式菜单和命令行参数两种模式
- 🎨 彩色输出，界面友好
- 🌐 跨平台支持（Linux Bash / Windows CMD / Windows PowerShell）

## 支持的镜像源

| 源名称 | 地址 | 命令参数 |
|--------|------|----------|
| 清华大学 | https://pypi.tuna.tsinghua.edu.cn/simple | `tsinghua` / `tuna` |
| 阿里云 | https://mirrors.aliyun.com/pypi/simple/ | `aliyun` / `ali` |
| 中国科技大学 | https://pypi.mirrors.ustc.edu.cn/simple/ | `ustc` |
| 豆瓣 | https://pypi.douban.com/simple/ | `douban` |
| 华为云 | https://repo.huaweicloud.com/repository/pypi/simple | `huawei` |
| 腾讯云 | https://mirrors.cloud.tencent.com/pypi/simple | `tencent` |
| 网易 | https://mirrors.163.com/pypi/simple/ | `163` |
| 官方源 | https://pypi.org/simple | `pypi` / `official` |

## 脚本文件说明

| 文件名 | 平台 | 说明 |
|--------|------|------|
| `switch-pip-source.sh` | Linux | Bash 脚本，适用于 Linux/Unix 系统 |
| `switch-pip-source.bat` | Windows | CMD 批处理脚本，适用于 Windows 命令提示符 |
| `switch-pip-source.ps1` | Windows | PowerShell 脚本，适用于 Windows PowerShell |

## 安装使用

### Linux 系统

#### 1. 下载脚本

```bash
# 克隆仓库或下载脚本文件
git clone <repository-url>
cd pip-source-switcher
```

#### 2. 添加执行权限

```bash
chmod +x switch-pip-source.sh
```

#### 3. 使用方式

#### 方式一：交互式菜单（推荐）

直接运行脚本，通过菜单选择：

```bash
./switch-pip-source.sh
```

菜单选项：
- `0` - 自动选择第一个可用源
- `1-8` - 手动选择指定源
- `9` - 查看当前配置的源
- `q` - 退出程序

#### 方式二：命令行参数

快速切换到指定源：

```bash
# 自动选择可用源
./switch-pip-source.sh auto

# 切换到清华源
./switch-pip-source.sh tsinghua

# 切换到阿里云源
./switch-pip-source.sh aliyun

# 切换到中科大源
./switch-pip-source.sh ustc

# 查看当前源
./switch-pip-source.sh show
```

#### 4. 全局安装（可选）

将脚本安装到系统路径，方便全局使用：

```bash
sudo cp switch-pip-source.sh /usr/local/bin/pip-switch
sudo chmod +x /usr/local/bin/pip-switch

# 之后可以在任何位置使用
pip-switch auto
```

### Windows 系统

#### 方式一：使用 PowerShell 脚本（推荐）

1. 下载脚本文件 `switch-pip-source.ps1`

2. 在 PowerShell 中运行：

```powershell
# 如果遇到执行策略限制，先运行（仅需一次）
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 交互式菜单
.\switch-pip-source.ps1

# 或使用命令行参数
.\switch-pip-source.ps1 auto
.\switch-pip-source.ps1 aliyun
```

3. 全局安装（可选）：

```powershell
# 复制到用户脚本目录
$scriptDir = "$env:USERPROFILE\Scripts"
if (-not (Test-Path $scriptDir)) { New-Item -ItemType Directory -Path $scriptDir }
Copy-Item switch-pip-source.ps1 $scriptDir\pip-switch.ps1

# 添加到 PATH（如果还没有）
# 之后可以在任何位置使用
pip-switch auto
```

#### 方式二：使用 CMD 批处理脚本

1. 下载脚本文件 `switch-pip-source.bat`

2. 在命令提示符中运行：

```cmd
# 交互式菜单
switch-pip-source.bat

# 或使用命令行参数
switch-pip-source.bat auto
switch-pip-source.bat aliyun
```

3. 全局安装（可选）：

```cmd
# 复制到系统目录（需要管理员权限）
copy switch-pip-source.bat C:\Windows\System32\pip-switch.bat

# 之后可以在任何位置使用
pip-switch auto
```

## 使用示例

### 示例 1：自动选择可用源

```bash
$ ./switch-pip-source.sh auto
[INFO] 正在测试各个源的可用性...

测试 清华大学 ... ✓ 可用
测试 阿里云 ... ✓ 可用
测试 中国科技大学 ... ✓ 可用
测试 豆瓣 ... ✓ 可用
测试 华为云 ... ✓ 可用
测试 腾讯云 ... ✓ 可用
测试 网易 ... ✓ 可用
测试 官方源 ... ✗ 不可用

[INFO] 选择第一个可用源: 清华大学
[SUCCESS] 已成功切换到 清华大学 源
[SUCCESS] 源地址: https://pypi.tuna.tsinghua.edu.cn/simple
```

### 示例 2：手动切换到阿里云源

```bash
$ ./switch-pip-source.sh aliyun
[INFO] 创建配置目录: /home/user/.pip
[SUCCESS] 已成功切换到 阿里云 源
[SUCCESS] 源地址: https://mirrors.aliyun.com/pypi/simple/
```

### 示例 3：查看当前源

```bash
$ ./switch-pip-source.sh show
[INFO] 当前 pip 源配置：
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/
trusted-host = mirrors.aliyun.com

[install]
trusted-host = mirrors.aliyun.com
```

## 配置文件位置

脚本会在以下位置创建/修改 pip 配置文件：

**Linux/Unix:**
```
~/.pip/pip.conf
```

**Windows:**
```
%USERPROFILE%\pip\pip.ini
```

例如：`C:\Users\YourName\pip\pip.ini`

## 依赖要求

### Linux
- Bash shell
- `curl` 或 `wget`（用于测试源可用性）

大多数 Linux 发行版默认已安装这些工具。

### Windows
- Windows 7 或更高版本
- PowerShell 5.0+ 或 CMD
- `curl`（Windows 10 1803+ 自带）

Windows 10/11 系统默认已满足所有要求。

## 验证切换结果

切换源后，可以通过以下命令验证：

```bash
# 查看 pip 配置
pip config list

# 或直接查看配置文件
cat ~/.pip/pip.conf

# 测试安装包（使用新源）
pip install requests -U
```

## 故障排除

### 问题 1：提示权限不足

```bash
chmod +x switch-pip-source.sh
```

### 问题 2：所有源都不可用

- 检查网络连接
- 确认防火墙设置
- 尝试手动访问源地址

### 问题 3：切换后仍使用旧源

```bash
# 清除 pip 缓存
pip cache purge

# 或使用 --no-cache-dir 参数
pip install --no-cache-dir package_name
```

## 注意事项

1. 脚本会覆盖现有的 `~/.pip/pip.conf` 配置文件
2. 建议先备份原有配置（如果有）
3. 某些企业网络环境可能需要额外配置代理
4. 如果使用虚拟环境，配置对所有虚拟环境生效

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！

## 项目文件

```
pip-source-switcher/
├── README.md                    # 项目说明文档（本文件）
├── switch-pip-source.sh        # Linux Bash 脚本
├── switch-pip-source.bat       # Windows CMD 批处理脚本
└── switch-pip-source.ps1       # Windows PowerShell 脚本
```

## 相关链接

- [pip 官方文档](https://pip.pypa.io/)
- [清华大学开源镜像站](https://mirrors.tuna.tsinghua.edu.cn/)
- [阿里云镜像站](https://developer.aliyun.com/mirror/)
- [中科大镜像站](https://mirrors.ustc.edu.cn/)
