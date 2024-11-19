#!/bin/bash
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y build-essential \
    libncursesw5-dev \
    libssl-dev \
    libpcre3-dev \
    libdb-dev \
    zlib1g-dev \
    libgdbm-dev \
    liblzma-dev \
    uuid-dev \
    libicu-dev \
    libxml2-dev \
    libxslt1-dev \
    libreadline-dev \
    libevent-dev \
    autoconf \
    yodl \
    gettext

echo "======================="
echo "Starting configuration setup..."

# Define directories
DOTFILES_DIR="$HOME/.dotfile"
CONFIG_DIR="$HOME/.config"
ZSHENV_FILE="$HOME/.zshenv"
TMUX_CONF="$HOME/.tmux.conf"

# Remove existing configuration files
# echo "Removing old configurations..."
# for file in "$CONFIG_DIR" "$ZSHENV_FILE" "$TMUX_CONF"; do
#     if [ -e "$file" ]; then
#         rm -rf "$file"
#     fi
# done

echo "Linking new configuration files..."
ln -sf "$DOTFILES_DIR/config" "$CONFIG_DIR"
ln -sf "$DOTFILES_DIR/zsh_config/zshenv" "$ZSHENV_FILE"
ln -sf "$DOTFILES_DIR/tmux_config/tmux.conf" "$TMUX_CONF"

# Install Anaconda
echo "======================="
echo "Installing Anaconda..."
mkdir -p ~/.anaconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/.anaconda/miniconda.sh
bash ~/.anaconda/miniconda.sh -b -u -p ~/.anaconda
rm ~/.anaconda/miniconda.sh

source $HOME/.anaconda/bin/activate && \
$HOME/.anaconda/bin/conda create -n py310 python=3.10 -y && \
conda activate py310 && \
pip install --upgrade pip

echo "======================="
echo "Setting zsh"

# cargo
curl https://sh.rustup.rs -sSf | sh -s -- -y

# fnm
curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
USER_ID=$(id -u)
sudo mkdir -p /run/user/$USER_ID/fnm_multishells
sudo chmod a+w /run/user/$USER_ID/fnm_multishells

# thefuck
pip install https://github.com/nvbn/thefuck/archive/master.zip

#starship
conda install -c conda-forge starship --yes

wget https://www.zsh.org/pub/zsh-5.9.tar.xz -O zsh.tar.xz
tar xf zsh.tar.xz
cd zsh-5.9
./configure --prefix=/usr/local --without-tcsetpgrp
make -j$(nproc)
sudo make install
cd ..
rm -rf zsh-5.9 zsh.tar.xz
if ! grep -Fxq "/usr/local/bin/zsh" /etc/shells
then
    echo "/usr/local/bin/zsh" | sudo tee -a /etc/shells
fi
sudo ln -s /usr/local/bin/zsh /bin/zsh
# sudo apt-get install zsh

# oh-my-zsh
export RUNZSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install powerlevel10k
# git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone --depth=1 https://gitee.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Install gitstatus
GITSTATUSD_DIR="$HOME/.cache/gitstatus"
mkdir -p "$GITSTATUSD_DIR"
wget -O "$GITSTATUSD_DIR/gitstatusd-linux-x86_64.tar.gz" "https://github.com/romkatv/gitstatus/releases/download/v1.5.4/gitstatusd-linux-x86_64.tar.gz"
tar -xzf "$GITSTATUSD_DIR/gitstatusd-linux-x86_64.tar.gz" -C "$GITSTATUSD_DIR"
rm -rf "$GITSTATUSD_DIR/gitstatusd-linux-x86_64.tar.gz"
typeset -g POWERLEVEL9K_GITSTATUS_DIR="$GITSTATUSD_DIR"

zsh "$HOME/.dotfile/config/zsh/.zshrc"

sudo apt-get -y install -y locales
locale-gen en_US.UTF-8

echo "Base configuration setup completed successfully!"
