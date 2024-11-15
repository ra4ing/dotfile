#!/bin/bash

echo "======================="
echo "Starting configuration setup..."

# Define directories
DOTFILES_DIR="$HOME/.dotfile"
CONFIG_DIR="$HOME/.config"
ZSHENV_FILE="$HOME/.zshenv"
TMUX_CONF="$HOME/.tmux.conf"

# Remove existing configuration files
echo "Removing old configurations..."
for file in "$CONFIG_DIR" "$ZSHENV_FILE" "$TMUX_CONF"; do
    if [ -e "$file" ]; then
        rm -rf "$file"
    fi
done

echo "Linking new configuration files..."
ln -s "$DOTFILES_DIR/config" "$CONFIG_DIR"
ln -s "$DOTFILES_DIR/zsh_config/zshenv" "$ZSHENV_FILE"
ln -s "$DOTFILES_DIR/tmux_config/tmux.conf" "$TMUX_CONF"

# Install Anaconda
echo "======================="
echo "Installing Anaconda..."
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get -y install libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6
ANACONDA_VERSION=$(curl -s https://repo.anaconda.com/archive/ | grep -oP 'Anaconda3-[0-9]+\.[0-9]+-[0-9]+-Linux-x86_64\.sh' | sort -V | tail -n1)
wget "https://repo.anaconda.com/archive/$ANACONDA_VERSION" -O "$HOME/anaconda.sh"
bash "$HOME/anaconda.sh" -b -p "$HOME/.anaconda"
rm "$HOME/anaconda.sh"
source $HOME/.anaconda/etc/profile.d/conda.sh && \
$HOME/.anaconda/bin/conda create -n py310 python=3.10 -y && \
conda activate py310 && \
pip install --upgrade pip


echo "======================="
echo "Setting zsh"
sudo apt-get install -y \
    build-essential \
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

# cargo
curl https://sh.rustup.rs -sSf | sh -s -- -y

# fnm
curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
USER_ID=$(id -u)
sudo mkdir -p /run/user/$USER_ID/fnm_multishells
sudo chown $USER:$USER /run/user/$USER_ID/fnm_multishells

# thefuck
pip uninstall thefuck
pip install https://github.com/nvbn/thefuck/archive/master.zip

#starship
curl -sS https://starship.rs/install.sh | sh -s -- -y

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
chsh -s /usr/local/bin/zsh

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
typeset -g POWERLEVEL9K_GITSTATUS_DIR="$HOME/.cache/gitstatusd"

zsh "$HOME/.dotfile/config/zsh/.zshrc"

echo "Base configuration setup completed successfully!"