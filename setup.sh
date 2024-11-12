#!/bin/bash

echo "======================="
echo "Removing old configs..."
for file in "$HOME/.config" "$HOME/.zshenv" "$HOME/.tmux.conf" "$HOME/.zshrc"; do
    if [ -e "$file" ]; then
        rm -r "$file"
    fi
done

echo "======================="
echo "Linking configs..."
ln -s "$HOME/.dotfile/config" "$HOME/.config"
ln -s "$HOME/.dotfile/zsh_config/zshenv" "$HOME/.zshenv"
ln -s "$HOME/.dotfile/tmux_config/tmux.conf" "$HOME/.tmux.conf"

echo "======================="
echo "Setting zsh"
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get -y install zsh

# cargo
curl https://sh.rustup.rs -sSf | sh -s -- -y

# fnm
curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell

if [ -d "$HOME/.pip_venv" ]; then
  source "$HOME/.pip_venv/bin/activate"
fi

pip install --upgrade pip

# thefuck
pip uninstall thefuck
pip install https://github.com/nvbn/thefuck/archive/master.zip
pip install setuptools pwntools pwncli

#starship
curl -sS https://starship.rs/install.sh | sh -s -- -y

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

echo "======================="
echo "Setup gdb..."

ubuntu_version=$(lsb_release -sr)
python_version=$(python3 --version | cut -d ' ' -f 2 | cut -d '.' -f1-2)
if [[ "$ubuntu_version" == "18.04" ]]; then
    pwndbg_version="2023.07.17"
elif [[ "$ubuntu_version" == "16.04" ]]; then
    pwndbg_version="2023.07.17"
else
    pwndbg_version="2024.08.29"
fi
git submodule init && git submodule update
cd "$HOME/.dotfile/gdb_config/pwndbg"
git checkout $pwndbg_version
./setup.sh
rm "$HOME/.gdbinit"
ln -s "$HOME/.dotfile/gdb_config/gdbinit" "$HOME/.gdbinit"

echo "Configuration is done."
