#!/bin/bash
echo "======================="
echo "flag example..."
sudo sh -c 'echo "flag{this_is_a_flag}" > /flag' && \
sudo sh -c 'echo "flag{this_is_a_flag}" > /flag.txt' && \
sudo chmod 400 /flag /flag.txt

echo "======================="
echo "PWN shell/configuration setup..."

# 检查 Python 版本
PYVER=$(python3 -c 'import sys; print("{}.{}".format(sys.version_info.major, sys.version_info.minor))')
echo "Detected Python version: $PYVER"

# 选择 pwndbg 分支
git submodule init && git submodule update
cd "$HOME/.dotfile/gdb_config/pwndbg"
if [[ "$PYVER" == "3.8" || "$PYVER" == "3.9" ]]; then
    echo "Using pwndbg branch: 2024.08.29 (for Python 3.8/3.9)"
    git fetch --all
    git checkout 2024.08.29
elif [[ "$PYVER" == "3.6" || "$PYVER" == "3.7" ]]; then
    echo "Using pwndbg branch: 2023.07.17 (for Python 3.6/3.7)"
    git fetch --all
    git checkout 2023.07.17
elif [[ "$PYVER" =~ ^3\.(10|11|12|13|14|15|16|17|18|19)$ ]]; then
    echo "Using latest pwndbg master branch (for Python $PYVER)"
    git fetch --all
    # git checkout master
else
    echo "Warning: Detected Python $PYVER, which may not be supported by pwndbg."
    echo "Please refer to https://github.com/pwndbg/pwndbg for supported versions."
    sleep 2
fi

# 自动安装 pwndbg
echo "Running pwndbg setup.sh ..."
if ! ./setup.sh; then
    echo "pwndbg setup.sh failed. Please check the error log above."
    exit 1
fi

# 链接 gdbinit
if [ -e "$HOME/.gdbinit" ]; then
    rm -f "$HOME/.gdbinit"
fi
ln -sf "$HOME/.dotfile/gdb_config/gdbinit" "$HOME/.gdbinit"

sudo bash -c "echo core > /proc/sys/kernel/core_pattern"


echo "PWN configuration setup completed successfully!"
