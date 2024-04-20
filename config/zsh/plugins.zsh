##
## Plugins
##
export ZSH="$HOME/.oh-my-zsh/"
# source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
# [[ ! -f /usr/share/zsh/p10k.zsh ]] || source /usr/share/zsh/p10k.zsh

ZSH_THEME="powerlevel10k/powerlevel10k"

ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir $ZSH_CACHE_DIR
fi

source $ZSH/oh-my-zsh.sh


# source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
zstyle ':bracketed-paste-magic' active-widgets '.self-*'
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#a8a8a8"

# source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

MODE_INDICATOR="%{$fg_bold[red]%}<%{$fg[yellow]%}<%{$fg[green]%}<%{$fg[cyan]%}<%{$fg[blue]%}<%{$reset_color%}"
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes


plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-z cp history extract autojump tmux vi-mode docker golang)


# Configure and load plugins using Zinit's
ZINIT_HOME="${ZINIT_HOME:-${XDG_DATA_HOME:-${HOME}/.local/share}/zinit}"

# Added by Zinit's installer
if [[ ! -f ${ZINIT_HOME}/zinit.git/zinit.zsh ]]; then
    print -P "%F{14}▓▒░ Installing Flexible and fast ZSH plugin manager %F{13}(zinit)%f"
    command mkdir -p "${ZINIT_HOME}" && command chmod g-rwX "${ZINIT_HOME}"
    command git clone https://github.com/zdharma-continuum/zinit.git "${ZINIT_HOME}/zinit.git" && \
        print -P "%F{10}▓▒░ Installation successful.%f%b" || \
        print -P "%F{9}▓▒░ The clone has failed.%f%b"
fi

source "${ZINIT_HOME}/zinit.git/zinit.zsh"

zinit ice blockf atpull'zinit creinstall -q .'
zinit light zsh-users/zsh-completions

autoload compinit
compinit

zinit light-mode for \
  hlissner/zsh-autopair \
  zdharma-continuum/fast-syntax-highlighting \
  MichaelAquilina/zsh-you-should-use \
  zsh-users/zsh-autosuggestions \
  Aloxaf/fzf-tab

zinit ice wait'3' lucid
zinit light zsh-users/zsh-history-substring-search

zinit ice wait'2' lucid
zinit light zdharma-continuum/history-search-multi-word

# FZF
zinit ice from"gh-r" as"command"
zinit light junegunn/fzf-bin

# EXA
zinit ice wait lucid from"gh-r" as"program" mv"bin/exa* -> exa"
zinit light ogham/exa

# BAT
zinit ice wait lucid from"gh-r" as"program" mv"*/bat -> bat" atload"export BAT_THEME='Nord'"
zinit light sharkdp/bat

# vim:ft=zsh
