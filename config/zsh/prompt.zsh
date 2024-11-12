##
## Prompt
##

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

# Corrected Starship installation
install_with_retry "zinit ice from'gh-r' as'command' \
  atload 'export STARSHIP_CONFIG=\$HOME/.dotfile/config/starship/starship.toml; eval \$(starship init zsh)' \
  atclone './starship init zsh > init.zsh; ./starship completions zsh > _starship' \
  atpull '%atclone' src'init.zsh' \
  light 'starship/starship'" "starship/starship"

# vim:ft=zsh
