#!/bin/bash

echo "======================="
echo "flag example..."
echo "flag{this_is_a_flag}" > /flag && \
echo "flag{this_is_a_flag}" > /flag.txt && \
chmod 400 /flag /flag.txt

echo "======================="
echo "packages for pwn..."
sudo dpkg --add-architecture i386
sudo apt-get install -y libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev
sudo apt-get install -y libc6-dbg libc6-dbg:i386
sudo apt-get install -y bison flex build-essential gcc-multilib
sudo apt-get install -y qemu-system-x86 qemu-user qemu-user-binfmt
sudo apt-get install -y gcc gdb gdbserver gdb-multiarch clang lldb make cmake
ubuntu_version=$(lsb_release -sr)
if [[ $(echo "$ubuntu_version >= 20.04" | bc) -eq 1 ]]; then
    sudo apt-get install -y libgcc-s1:i386
else
    sudo apt-get install -y libgcc1:i386
fi

echo "======================="
echo "Python packages for pwn..."
$HOME/.anaconda/bin/conda activate py310 && \
pip install --upgrade pip && \
pip config set global.index-url http://pypi.tuna.tsinghua.edu.cn/simple && \
pip config set global.trusted-host pypi.tuna.tsinghua.edu.cn && \
pip install --no-cache-dir \
python3-dev \
setuptools \
pwntools \
pwncli \
ropgadget \
z3-solver \
smmap2 \
apscheduler \
ropper \
unicorn \
keystone-engine \
capstone \
angr \
pebble \
r2pipe \
LibcSearcher \
poetry \
pipx

echo "======================="
echo "Setup gdb..."

# ubuntu_version=$(lsb_release -sr)
# python_version=$(python3 --version | cut -d ' ' -f 2 | cut -d '.' -f1-2)
# if [[ "$ubuntu_version" == "18.04" ]]; then
#     pwndbg_version="2023.07.17"
# elif [[ "$ubuntu_version" == "16.04" ]]; then
#     pwndbg_version="2023.07.17"
# else
#     pwndbg_version="2024.08.29"
# fi
pwndbg_version="2024.08.29"
git submodule init && git submodule update
cd "$HOME/.dotfile/gdb_config/pwndbg"
git checkout $pwndbg_version
./setup.sh
rm "$HOME/.gdbinit"
ln -s "$HOME/.dotfile/gdb_config/gdbinit" "$HOME/.gdbinit"
