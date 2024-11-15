#!/bin/bash

echo "======================="
echo "flag example..."
sudo sh -c 'echo "flag{this_is_a_flag}" > /flag' && \
sudo sh -c 'echo "flag{this_is_a_flag}" > /flag.txt' && \
sudo chmod 400 /flag /flag.txt

echo "======================="
echo "packages for pwn..."
sudo dpkg --add-architecture i386
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev
sudo apt-get install -y libc6-dbg libc6-dbg:i386
sudo apt-get install -y bison flex build-essential gcc-multilib
sudo apt-get install -y qemu-system-x86 qemu-user qemu-user-binfmt
sudo apt-get install -y libgmp-dev libmpfr-dev libmpc-dev 
sudo apt-get install -y gcc gdb gdbserver gdb-multiarch clang lldb make cmake
sudo apt-get install -y texinfo libncurses5-dev libexpat1-dev libssl-dev libdw-dev libelf-dev
sudo apt-get install -y libncursesw5-dev libpython3-dev liblzma-dev libbabeltrace-ctf-dev
sudo apt-get install -y bc lsb-release jq
ubuntu_version=$(lsb_release -sr)
echo "Ubuntu version: $ubuntu_version"
compare_result=$(echo "$ubuntu_version >= 20.04" | bc)
echo "Comparison result: $compare_result"

if [[ "$compare_result" -eq 1 ]]; then
    sudo apt-get install -y libgcc-s1:i386
else
    sudo apt-get install -y libgcc1:i386
fi

echo "======================="
echo "Python packages for pwn..."
source $HOME/.anaconda/bin/activate py310 && \
pip install --upgrade pip && \
pip config set global.index-url http://pypi.tuna.tsinghua.edu.cn/simple && \
pip config set global.trusted-host pypi.tuna.tsinghua.edu.cn && \
pip install --no-cache-dir \
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

gdb_version="gdb-15.2"
CONDA_PREFIX=$(conda info --base)/envs/py310
wget https://ftp.gnu.org/gnu/gdb/$gdb_version.tar.gz
tar -xzf $gdb_version.tar.gz
cd $gdb_version
./configure \
    --prefix=/usr/local \
    --with-python=$CONDA_PREFIX/bin/python3.10 \
    LDFLAGS="-L$CONDA_PREFIX/lib" \
    CPPFLAGS="-I$CONDA_PREFIX/include/python3.10"
make -j$(nproc)
sudo make install
rm $gdb_version.tar.gz
rm -rf $gdb_version
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
