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
echo "Installing Anaconda for Python Management..."
wget https://repo.anaconda.com/archive/Anaconda3-2024.10-1-Linux-x86_64.sh -O "$HOME/anaconda.sh"
bash "$HOME/anaconda.sh" -b -p "$HOME/.anaconda"
rm "$HOME/anaconda.sh"
$HOME/.anaconda/bin/conda conda create -n py310 python=3.10 -y
$HOME/.anaconda/bin/conda activate py310
pip install --upgrade pip


echo "======================="
echo "Setting zsh"

# cargo
curl https://sh.rustup.rs -sSf | sh -s -- -y

# fnm
curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
mkdir /run/user/1001/fnm_multishells -p && chmod a+w /run/user/1001/fnm_multishells
mkdir /run/user/1000/fnm_multishells -p && chmod a+w /run/user/1000/fnm_multishells

# thefuck
pip install https://github.com/nvbn/thefuck/archive/master.zip

#starship
curl -sS https://starship.rs/install.sh | sh -s -- -y

sudo apt-get -y install zsh

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
# git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone --depth=1 https://gitee.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
GITSTATUSD_DIR="$HOME/.cache/gitstatus"
mkdir -p "$GITSTATUSD_DIR"
wget -O "$GITSTATUSD_DIR/gitstatusd-linux-x86_64.tar.gz" "https://github.com/romkatv/gitstatus/releases/download/v1.5.4/gitstatusd-linux-x86_64.tar.gz"
tar -xzf "$GITSTATUSD_DIR/gitstatusd-linux-x86_64.tar.gz" -C "$GITSTATUSD_DIR"
typeset -g POWERLEVEL9K_GITSTATUS_DIR="$HOME/.cache/gitstatusd"

zsh "$HOME/.dotfile/config/zsh/.zshrc"
echo "ZSH configuration loaded and plugins are downloaded."