# dotfile 项目说明

本项目为个人常用开发的配置集合，主要涵盖了 **zsh**、**pwn**（CTF 逆向/漏洞利用环境）等核心工具的定制化配置。**主要关注配置本身的说明与用法**，而非原项目内容。

---

## 📁 目录结构

- `zsh_config/` & `config/zsh/`：zsh 及其插件、主题配置
- `tmux_config/`：tmux 配置
- `gdb_config/`：pwn 相关 gdb 插件与配置（含 pwncli、pwndbg、Pwngdb 等）
- `setup_*.sh`：一键化环境部署脚本
- `config/`：其他常用工具配置（如 ranger、lvim、alacritty、rofi 等）

---

## 🐚 1. Zsh 配置

### 主要特性

- 基于 [oh-my-zsh](https://ohmyz.sh/) 框架
- 插件管理采用 [zinit](https://github.com/zdharma-continuum/zinit)
- 常用插件：
  - [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
  - [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
  - [fzf-tab](https://github.com/Aloxaf/fzf-tab)
  - [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting)
  - [zsh-completions](https://github.com/zsh-users/zsh-completions)
  - 以及 exa、bat、autojump、git、tmux 等增强插件
- 主题采用 [powerlevel10k](https://github.com/romkatv/powerlevel10k)（已高度自定义，支持丰富状态与美观提示）
- 个性化配置：包含别名、环境变量、快捷键、pwn 专用函数等，详见 `config/zsh/` 下各 `.zsh` 文件

### 使用说明

1. 安装 oh-my-zsh、zinit、powerlevel10k 及相关插件（可参考 `setup.sh` 脚本）
2. 将 `zsh_config/zshenv` 软链到 `$HOME/.zshenv`
3. 将 `config/zsh/` 软链到 `$HOME/.config/zsh/`
4. 终端选择 zsh 并重启即可生效

---

## 🛠️ 2. Pwn 环境配置

### 主要特性

- **gdb 多插件集成**，一站式支持 CTF 逆向与漏洞利用
  - [pwndbg](https://github.com/pwndbg/pwndbg)：现代化 GDB 调试增强插件
  - [Pwngdb](https://github.com/scwuaptx/Pwngdb)：heap/arena/fastbin 等堆利用辅助
  - [pwncli](https://github.com/RoderickChan/pwncli)：一体化 pwn 调试与攻击脚本工具，支持命令行、脚本、库三种模式，极大提升 CTF pwn 题目的调试与攻击效率
  - angelheap：自动化堆分析
- **一键部署脚本**：`setup_pwn.sh` 自动完成 pwndbg、Pwngdb、pwncli、glibc-all-in-one 等依赖的安装与配置
- **gdbinit**：自动加载上述插件，内置常用调试命令（如 sbase、bbase、dq/dd/dw/db、heapinfo、chunkinfo 等）

### pwncli 简介

- [pwncli 官方仓库](https://github.com/RoderickChan/pwncli)
- 支持命令行、脚本、库三种使用模式，极大简化 pwn 题目的调试与攻击流程
- 内置丰富的子命令（debug、remote、config、misc、patchelf、qemu 等），支持自动化调试、远程攻击、gdb 配置管理、gadget 搜索、模板生成等
- 依赖 [pwntools](https://github.com/Gallopsled/pwntools) 和 [click](https://github.com/pallets/click)
- 详细用法请参考 [pwncli 官方文档](https://github.com/RoderickChan/pwncli/blob/main/README.md)

### 使用说明

1. 执行 `setup_pwn.sh` 自动完成环境部署（包括 pwncli 的安装）
2. 启动 gdb 时自动加载 pwndbg、Pwngdb、angelheap 等插件
3. 直接使用 `pwncli` 命令行工具或在脚本中导入使用，详见官方文档

---

## ⌨️ 3. Tmux 配置

### 主要特性

- vi 模式、鼠标支持、系统剪切板集成
- 自定义状态栏、窗口/面板管理快捷键、常用工具一键新建窗口（htop、ranger、cmatrix 等）
- 会话保存插件（需自行安装 [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect)）
- 高度定制的快捷键与行为，详见 `tmux_config/tmux.conf`

### 使用说明

1. 将 `tmux_config/tmux.conf` 软链到 `$HOME/.tmux.conf`
2. 安装 tmux-resurrect 插件（可选）
3. 启动 tmux 即可体验定制化环境

---

## 🧩 4. 其他配置（简要）

- `config/` 目录下包含常用工具（如 ranger、lvim、alacritty、rofi、thefuck、starship、neofetch、lazygit 等）的配置文件
- 可根据实际需求软链到对应的 `$HOME/.config/` 子目录

