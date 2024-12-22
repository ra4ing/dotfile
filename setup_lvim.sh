#!/bin/bash

sudo apt-get -y update && sudo apt-get -y upgrade

# neovim
sudo apt-get -y install cmake
git clone https://github.com/neovim/neovim.git ~/neovim
cd ~/neovim
git checkout v0.10.2
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
cd ..
rm -rf neovim

# other requirements

# ripgrep
sudo apt-get install ripgrep

#nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.dotfile/config/zsh/env.zsh
nvm install v16.13.2
nvm use v16.13.2

#enable global
mkdir -p ~/.npm-global/lib
npm config set prefix '~/.npm-global'

npm config set registry=https://registry.npmmirror.com

#lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/
rm -rf ./lazygit lazygit.tar.gz

#lvim
LV_BRANCH='release-1.4/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.4/neovim-0.9/utils/installer/install.sh) -y
nvm use  --delete-prefix v16.13.2 --silent

