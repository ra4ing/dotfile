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
# sudo apt-get install -y libgmp-dev libmpfr-dev libmpc-dev libreadline-dev libtool 
sudo apt-get install -y gcc gdb gdbserver gdb-multiarch clang lldb make cmake
# sudo apt-get install -y texinfo libncurses5-dev libexpat1-dev libssl-dev libdw-dev libelf-dev
# sudo apt-get install -y libncursesw5-dev libpython3-dev liblzma-dev libbabeltrace-ctf-dev
sudo apt-get install -y bc lsb-release jq

ubuntu_version=$(lsb_release -sr)
echo "Ubuntu version: $ubuntu_version"
if dpkg --compare-versions "$ubuntu_version" "ge" "20.04"; then
    sudo apt-get install -y libgcc-s1:i386
else
    sudo apt-get install -y libgcc1:i386
fi

echo "======================="
echo "Python packages for pwn..."
source $HOME/.anaconda/bin/activate && \
conda activate py310 && \
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
echo "Installing gdb..."
conda install -c conda-forge gdb --yes

# if dpkg --compare-versions "$ubuntu_version" "ge" "20.04"; then
#     gdb_version="gdb-15.2"
# elif dpkg --compare-versions "$ubuntu_version" "ge" "18.04"; then
#     gdb_version="gdb-10.2"
# else
#     gdb_version="gdb-8.3"
# fi
# CONDA_PREFIX=$(conda info --base)/envs/py310
# wget https://ftp.gnu.org/gnu/gdb/$gdb_version.tar.gz
# tar -xzf $gdb_version.tar.gz
# cd $gdb_version
# ./configure \
#     --prefix=/usr/local \
#     --with-python=$CONDA_PREFIX/bin/python3.10 \
#     LDFLAGS="-L$CONDA_PREFIX/lib -L$CONDA_PREFIX/lib64" \
#     CPPFLAGS="-I$CONDA_PREFIX/include/python3.10 -I$CONDA_PREFIX/include"
# make -j$(nproc)
# sudo make install
# cd ..
# rm -rf $gdb_version $gdb_version.tar.gz

echo "======================="
echo "installing pwndbg"
# if dpkg --compare-versions "$ubuntu_version" "ge" "20.04"; then
#     pwndbg_version="master"
# else
#     pwndbg_version="2024.08.29"
# fi
pwndbg_version="2024.08.29"
git submodule init && git submodule update
cd "$HOME/.dotfile/gdb_config/pwndbg"
git checkout $pwndbg_version
poetry install
ln -sf "$HOME/.dotfile/gdb_config/gdbinit" "$HOME/.gdbinit"
echo "PWN configuration setup completed successfully!"