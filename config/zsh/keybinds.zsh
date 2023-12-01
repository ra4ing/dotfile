##
## Keybindings
##

bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey -s '^K' 'ls^M'
bindkey -s '^o' '_smooth_fzf^M'

# prepend sudo on the current commmand
bindkey -M emacs '' _sudo_command_line
bindkey -M vicmd '' _sudo_command_line
bindkey -M viins '' _sudo_command_line

# fix backspace and other stuff in vi-mode
bindkey -M viins '\e/' _vi_search_fix
bindkey "^H" backward-delete-char
bindkey "^U" backward-kill-line

# vim:ft=zsh:nowrap




bindkey -M vicmd '^a' beginning-of-line
bindkey -M vicmd '^e' end-of-line
bindkey -M vicmd "^[[1;5C" forward-word
bindkey -M vicmd "^[[1;5D" backward-word
#bindkey "^[[1;5C" forward-word
#bindkey "^[[1;5D" backward-word
bindkey '^K' kill-line
bindkey '^Y' yank
bindkey '^[OA' up-line-or-beginning-search
bindkey '^[OB' down-line-or-beginning-search
