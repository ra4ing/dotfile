##
## Plugins
##
export ZSH="$HOME/.oh-my-zsh/"

ZSH_THEME="powerlevel10k/powerlevel10k"

ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir $ZSH_CACHE_DIR
fi

source $ZSH/oh-my-zsh.sh


zstyle ':bracketed-paste-magic' active-widgets '.self-*'
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#a8a8a8"

MODE_INDICATOR="%{$fg_bold[red]%}<%{$fg[yellow]%}<%{$fg[green]%}<%{$fg[cyan]%}<%{$fg[blue]%}<%{$reset_color%}"
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-z cp history extract autojump tmux vi-mode docker golang)

# Configure and load plugins using Zinit's
ZINIT_HOME="${ZINIT_HOME:-${XDG_DATA_HOME:-${HOME}/.local/share}/zinit}"

# Function to install plugins with retry mechanism, only retries on failure
install_with_retry() {
  local retries=5
  local count=0
  local cmd="$1"  # The plugin installation command
  local plugin_name="$2"  # Plugin name used for logging

  until eval "$cmd"; do
    count=$((count + 1))
    if [[ $count -ge $retries ]]; then
      print -P "%F{9}▓▒░ Failed to install after $retries attempts: $plugin_name.%f%b"
      return 1
    fi
    print -P "%F{11}▓▒░ Retrying installation... Attempt $count/$retries for $plugin_name.%f%b"
  done
}

# Added by Zinit's installer
install_zinit() {
  if [[ ! -f ${ZINIT_HOME}/zinit.git/zinit.zsh ]]; then
      print -P "%F{14}▓▒░ Installing Flexible and fast ZSH plugin manager %F{13}(zinit)%f"
      command mkdir -p "${ZINIT_HOME}" && command chmod g-rwX "${ZINIT_HOME}"
      command git clone https://github.com/zdharma-continuum/zinit.git "${ZINIT_HOME}/zinit.git" && \
          print -P "%F{10}▓▒░ Installation successful.%f%b" || \
          print -P "%F{9}▓▒░ The clone has failed.%f%b"
  fi
}

install_with_retry install_zinit
source "${ZINIT_HOME}/zinit.git/zinit.zsh"


# Install plugins with retry mechanism only if they are not installed
install_with_retry "zinit light 'zsh-users/zsh-completions'" "zsh-users/zsh-completions"
install_with_retry "zinit light 'hlissner/zsh-autopair'" "hlissner/zsh-autopair"
install_with_retry "zinit light 'zdharma-continuum/fast-syntax-highlighting'" "zdharma-continuum/fast-syntax-highlighting"
install_with_retry "zinit light 'MichaelAquilina/zsh-you-should-use'" "MichaelAquilina/zsh-you-should-use"
install_with_retry "zinit light 'zsh-users/zsh-autosuggestions'" "zsh-users/zsh-autosuggestions"
install_with_retry "zinit light 'Aloxaf/fzf-tab'" "Aloxaf/fzf-tab"
install_with_retry "zinit light 'zsh-users/zsh-history-substring-search'" "zsh-users/zsh-history-substring-search"
install_with_retry "zinit light 'zdharma-continuum/history-search-multi-word'" "zdharma-continuum/history-search-multi-word"
# FZF
install_with_retry "zinit ice from'gh-r' as'command' && zinit light 'junegunn/fzf-bin'" "junegunn/fzf-bin"
# EXA
install_with_retry "zinit ice from'gh-r' as'program' mv'bin/exa* -> exa' && zinit light 'ogham/exa'" "ogham/exa"
# BAT
install_with_retry "zinit ice from'gh-r' as'program' mv'*/bat -> bat' atload 'export BAT_THEME=\"Nord\"' && zinit light 'sharkdp/bat'" "sharkdp/bat"

autoload compinit
compinit

# vim:ft=zsh
