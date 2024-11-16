##
## Utility Functions
##

edit ()
{
    if [ "$(type -t jpico)" = "file" ]; then
        # Use JOE text editor http://joe-editor.sourceforge.net/
        jpico -nonotice -linums -nobackups "$@"
    elif [ "$(type -t nano)" = "file" ]; then
        nano -c "$@"
    elif [ "$(type -t pico)" = "file" ]; then
        pico "$@"
    else
        nvim "$@"
    fi
}
sedit ()
{
    if [ "$(type -t jpico)" = "file" ]; then
        # Use JOE text editor http://joe-editor.sourceforge.net/
        sudo jpico -nonotice -linums -nobackups "$@"
    elif [ "$(type -t nano)" = "file" ]; then
        sudo nano -c "$@"
    elif [ "$(type -t pico)" = "file" ]; then
        sudo pico "$@"
    else
        sudo nvim "$@"
    fi
}

# Extracts any archive(s) (if unp isn't installed)
extract () {
    for archive in "$@"; do
        if [ -f "$archive" ] ; then
            case $archive in
                *.tar.bz2)   tar xvjf $archive    ;;
                *.tar.gz)    tar xvzf $archive    ;;
                *.bz2)       bunzip2 $archive     ;;
                *.rar)       rar x $archive       ;;
                *.gz)        gunzip $archive      ;;
                *.tar)       tar xvf $archive     ;;
                *.tbz2)      tar xvjf $archive    ;;
                *.tgz)       tar xvzf $archive    ;;
                *.zip)       unzip $archive       ;;
                *.Z)         uncompress $archive  ;;
                *.7z)        7z x $archive        ;;
                *)           echo "don't know how to extract '$archive'..." ;;
            esac
        else
            echo "'$archive' is not a valid file!"
        fi
    done
}

# Searches for text in all files in the current folder
ftext ()
{
    # -i case-insensitive
    # -I ignore binary files
    # -H causes filename to be printed
    # -r recursive search
    # -n causes line number to be printed
    # optional: -F treat search term as a literal, not a regular expression
    # optional: -l only print filenames and not the matching lines ex. grep -irl "$1" *
    grep -iIHrn --color=always "$1" . | less -r
}

# Copy file with a progress bar
cpp()
{
    set -e
    strace -q -ewrite cp -- "${1}" "${2}" 2>&1 \
    | awk '{
    count += $NF
    if (count % 10 == 0) {
        percent = count / total_size * 100
        printf "%3d%% [", percent
        for (i=0;i<=percent;i++)
            printf "="
            printf ">"
            for (i=percent;i<100;i++)
                printf " "
                printf "]\r"
            }
        }
    END { print "" }' total_size="$(stat -c '%s' "${1}")" count=0
}

# Copy and go to the directory
cpg ()
{
    if [ -d "$2" ];then
        cp "$1" "$2" && cd "$2"
    else
        cp "$1" "$2"
    fi
}

# Move and go to the directory
mvg ()
{
    if [ -d "$2" ];then
        mv "$1" "$2" && cd "$2"
    else
        mv "$1" "$2"
    fi
}

# Create and go to the directory
mkdirg ()
{
    mkdir -p "$1"
    cd "$1"
}

# Goes up a specified number of directories  (i.e. up 4)
up ()
{
    local d=""
    limit=$1
    for ((i=1 ; i <= limit ; i++))
        do
            d=$d/..
        done
    d=$(echo $d | sed 's/^\///')
    if [ -z "$d" ]; then
        d=..
    fi
    cd $d
}

#Automatically do an ls after each cd
# cd ()
# {
# 	if [ -n "$1" ]; then
# 		builtin cd "$@" && ls
# 	else
# 		builtin cd ~ && ls
# 	fi
# }

# Returns the last 2 fields of the working directory
pwdtail ()
{
    pwd|awk -F/ '{nlast = NF -1;print $nlast"/"$NF}'
}

# Show the current distribution
distribution ()
{
    local dtype
    # Assume unknown
    dtype="unknown"
    
    # First test against Fedora / RHEL / CentOS / generic Redhat derivative
    if [ -r /etc/rc.d/init.d/functions ]; then
        source /etc/rc.d/init.d/functions
        [ zz`type -t passed 2>/dev/null` == "zzfunction" ] && dtype="redhat"
    
    # Then test against SUSE (must be after Redhat,
    # I've seen rc.status on Ubuntu I think? TODO: Recheck that)
    elif [ -r /etc/rc.status ]; then
        source /etc/rc.status
        [ zz`type -t rc_reset 2>/dev/null` == "zzfunction" ] && dtype="suse"
    
    # Then test against Debian, Ubuntu and friends
    elif [ -r /lib/lsb/init-functions ]; then
        source /lib/lsb/init-functions
        [ zz`type -t log_begin_msg 2>/dev/null` == "zzfunction" ] && dtype="debian"
    
    # Then test against Gentoo
    elif [ -r /etc/init.d/functions.sh ]; then
        source /etc/init.d/functions.sh
        [ zz`type -t ebegin 2>/dev/null` == "zzfunction" ] && dtype="gentoo"
    
    # For Mandriva we currently just test if /etc/mandriva-release exists
    # and isn't empty (TODO: Find a better way :)
    elif [ -s /etc/mandriva-release ]; then
        dtype="mandriva"

    # For Slackware we currently just test if /etc/slackware-version exists
    elif [ -s /etc/slackware-version ]; then
        dtype="slackware"

    fi
    echo $dtype
}

# Show the current version of the operating system
ver ()
{
    local dtype
    dtype=$(distribution)

    if [ $dtype == "redhat" ]; then
        if [ -s /etc/redhat-release ]; then
            cat /etc/redhat-release && uname -a
        else
            cat /etc/issue && uname -a
        fi
    elif [ $dtype == "suse" ]; then
        cat /etc/SuSE-release
    elif [ $dtype == "debian" ]; then
        lsb_release -a
        # sudo cat /etc/issue && sudo cat /etc/issue.net && sudo cat /etc/lsb_release && sudo cat /etc/os-release # Linux Mint option 2
    elif [ $dtype == "gentoo" ]; then
        cat /etc/gentoo-release
    elif [ $dtype == "mandriva" ]; then
        cat /etc/mandriva-release
    elif [ $dtype == "slackware" ]; then
        cat /etc/slackware-version
    else
        if [ -s /etc/issue ]; then
            cat /etc/issue
        else
            echo "Error: Unknown distribution"
            exit 1
        fi
    fi
}

# Automatically install the needed support files for this .bashrc file
install_bashrc_support ()
{
    local dtype
    dtype=$(distribution)

    if [ $dtype == "redhat" ]; then
        sudo yum install multitail tree joe
    elif [ $dtype == "suse" ]; then
        sudo zypper install multitail
        sudo zypper install tree
        sudo zypper install joe
    elif [ $dtype == "debian" ]; then
        sudo apt-get install multitail tree joe
    elif [ $dtype == "gentoo" ]; then
        sudo emerge multitail
        sudo emerge tree
        sudo emerge joe
    elif [ $dtype == "mandriva" ]; then
        sudo urpmi multitail
        sudo urpmi tree
        sudo urpmi joe
    elif [ $dtype == "slackware" ]; then
        echo "No install support for Slackware"
    else
        echo "Unknown distribution"
    fi
}

# Show current network information
netinfo ()
{
    echo "--------------- Network Information ---------------"
    /sbin/ifconfig | awk /'inet addr/ {print $2}'
    echo ""
    /sbin/ifconfig | awk /'Bcast/ {print $3}'
    echo ""
    /sbin/ifconfig | awk /'inet addr/ {print $4}'

    /sbin/ifconfig | awk /'HWaddr/ {print $4,$5}'
    echo "---------------------------------------------------"
}

# IP address lookup
alias whatismyip="whatsmyip"
function whatsmyip ()
{
    # Dumps a list of all IP addresses for every device
    # /sbin/ifconfig |grep -B1 "inet addr" |awk '{ if ( $1 == "inet" ) { print $2 } else if ( $2 == "Link" ) { printf "%s:" ,$1 } }' |awk -F: '{ print $1 ": " $3 }';
    
    ### Old commands
    # Internal IP Lookup
    #echo -n "Internal IP: " ; /sbin/ifconfig eth0 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'
#
#	# External IP Lookup
    #echo -n "External IP: " ; wget http://smart-ip.net/myip -O - -q
    
    # Internal IP Lookup.
    if [ -e /sbin/ip ];
    then
        echo -n "Internal IP: " ; /sbin/ip addr show wlan0 | grep "inet " | awk -F: '{print $1}' | awk '{print $2}'
    else
        echo -n "Internal IP: " ; /sbin/ifconfig wlan0 | grep "inet " | awk -F: '{print $1} |' | awk '{print $2}'
    fi

    # External IP Lookup 
    echo -n "External IP: " ; curl -s ifconfig.me
}

# View Apache logs
apachelog ()
{
    if [ -f /etc/httpd/conf/httpd.conf ]; then
        cd /var/log/httpd && ls -xAh && multitail --no-repeat -c -s 2 /var/log/httpd/*_log
    else
        cd /var/log/apache2 && ls -xAh && multitail --no-repeat -c -s 2 /var/log/apache2/*.log
    fi
}

# Edit the Apache configuration
apacheconfig ()
{
    if [ -f /etc/httpd/conf/httpd.conf ]; then
        sedit /etc/httpd/conf/httpd.conf
    elif [ -f /etc/apache2/apache2.conf ]; then
        sedit /etc/apache2/apache2.conf
    else
        echo "Error: Apache config file could not be found."
        echo "Searching for possible locations:"
        sudo updatedb && locate httpd.conf && locate apache2.conf
    fi
}

# Edit the PHP configuration file
phpconfig ()
{
    if [ -f /etc/php.ini ]; then
        sedit /etc/php.ini
    elif [ -f /etc/php/php.ini ]; then
        sedit /etc/php/php.ini
    elif [ -f /etc/php5/php.ini ]; then
        sedit /etc/php5/php.ini
    elif [ -f /usr/bin/php5/bin/php.ini ]; then
        sedit /usr/bin/php5/bin/php.ini
    elif [ -f /etc/php5/apache2/php.ini ]; then
        sedit /etc/php5/apache2/php.ini
    else
        echo "Error: php.ini file could not be found."
        echo "Searching for possible locations:"
        sudo updatedb && locate php.ini
    fi
}

# Edit the MySQL configuration file
mysqlconfig ()
{
    if [ -f /etc/my.cnf ]; then
        sedit /etc/my.cnf
    elif [ -f /etc/mysql/my.cnf ]; then
        sedit /etc/mysql/my.cnf
    elif [ -f /usr/local/etc/my.cnf ]; then
        sedit /usr/local/etc/my.cnf
    elif [ -f /usr/bin/mysql/my.cnf ]; then
        sedit /usr/bin/mysql/my.cnf
    elif [ -f ~/my.cnf ]; then
        sedit ~/my.cnf
    elif [ -f ~/.my.cnf ]; then
        sedit ~/.my.cnf
    else
        echo "Error: my.cnf file could not be found."
        echo "Searching for possible locations:"
        sudo updatedb && locate my.cnf
    fi
}

# For some reason, rot13 pops up everywhere
rot13 () {
    if [ $# -eq 0 ]; then
        tr '[a-m][n-z][A-M][N-Z]' '[n-z][a-m][N-Z][A-M]'
    else
        echo $* | tr '[a-m][n-z][A-M][N-Z]' '[n-z][a-m][N-Z][A-M]'
    fi
}

# Trim leading and trailing spaces (for scripts)
trim()
{
    local var=$*
    var="${var#"${var%%[![:space:]]*}"}"  # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"  # remove trailing whitespace characters
    echo -n "$var"
}
# GitHub Titus Additions

gcom() {
    git add .
    git commit -m "$1"
    }
lazyg() {
    git add .
    git commit -m "$1"
    git push
}

eval $(thefuck --alias)

function f() {
    if [[ -n "$1" ]] ;then
        cd $1
    fi
    export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -l -g ""'
    FZF_FILESS=$(fzf)
    if [[ -n "$FZF_FILESS" ]] ;then
        cd ${FZF_FILESS%/*}
    fi
    if [[ -n "$1" ]] ;then
        cd -
    fi
}

function o() {
    if [[ -z "$1" ]] ;then
        xdg-open .
    else
        xdg-open "$1"
    fi
}

function db() {
    if [[ "$(eval 'file $1')" =~ 'Python script' ]] ;then
        pudb3 "$@"
    else
        cgdb "$@"
    fi
}

function man() {
        LESS_TERMCAP_md=$'\e[01;34m' \
        LESS_TERMCAP_me=$'\e[0m' \
        LESS_TERMCAP_se=$'\e[0m' \
        LESS_TERMCAP_so=$'\e[01;46;30m' \
        LESS_TERMCAP_ue=$'\e[0m' \
        LESS_TERMCAP_us=$'\e[01;32m' \
        command man "$@"
}

function _smooth_fzf() {
local fname
local current_dir="$PWD"
cd "${XDG_CONFIG_HOME:-~/.config}"
fname="$(fzf)" || return
$EDITOR "$fname"
cd "$current_dir"
}

function _sudo_replace_buffer() {
local old=$1 new=$2 space=${2:+ }

# if the cursor is positioned in the $old part of the text, make
# the substitution and leave the cursor after the $new text
if [[ $CURSOR -le ${#old} ]]; then
    BUFFER="${new}${space}${BUFFER#$old }"
    CURSOR=${#new}
# otherwise just replace $old with $new in the text before the cursor
else
    LBUFFER="${new}${space}${LBUFFER#$old }"
fi
}

function _sudo_command_line() {
# If line is empty, get the last run command from history
[[ -z $BUFFER ]] && LBUFFER="$(fc -ln -1)"

# Save beginning space
local WHITESPACE=""
if [[ ${LBUFFER:0:1} = " " ]]; then
    WHITESPACE=" "
    LBUFFER="${LBUFFER:1}"
fi

{
    # If $SUDO_EDITOR or $VISUAL are defined, then use that as $EDITOR
    # Else use the default $EDITOR
    local EDITOR=${SUDO_EDITOR:-${VISUAL:-$EDITOR}}

    # If $EDITOR is not set, just toggle the sudo prefix on and off
    if [[ -z "$EDITOR" ]]; then
    case "$BUFFER" in
        sudo\ -e\ *) _sudo_replace_buffer "sudo -e" "" ;;
        sudo\ *) _sudo_replace_buffer "sudo" "" ;;
        *) LBUFFER="sudo $LBUFFER" ;;
    esac
    return
    fi

    # Check if the typed command is really an alias to $EDITOR

    # Get the first part of the typed command
    local cmd="${${(Az)BUFFER}[1]}"
    # Get the first part of the alias of the same name as $cmd, or $cmd if no alias matches
    local realcmd="${${(Az)aliases[$cmd]}[1]:-$cmd}"
    # Get the first part of the $EDITOR command ($EDITOR may have arguments after it)
    local editorcmd="${${(Az)EDITOR}[1]}"

    # Note: ${var:c} makes a $PATH search and expands $var to the full path
    # The if condition is met when:
    # - $realcmd is '$EDITOR'
    # - $realcmd is "cmd" and $EDITOR is "cmd"
    # - $realcmd is "cmd" and $EDITOR is "cmd --with --arguments"
    # - $realcmd is "/path/to/cmd" and $EDITOR is "cmd"
    # - $realcmd is "/path/to/cmd" and $EDITOR is "/path/to/cmd"
    # or
    # - $realcmd is "cmd" and $EDITOR is "cmd"
    # - $realcmd is "cmd" and $EDITOR is "/path/to/cmd"
    # or
    # - $realcmd is "cmd" and $EDITOR is /alternative/path/to/cmd that appears in $PATH
    if [[ "$realcmd" = (\$EDITOR|$editorcmd|${editorcmd:c}) \
    || "${realcmd:c}" = ($editorcmd|${editorcmd:c}) ]] \
    || builtin which -a "$realcmd" | command grep -Fx -q "$editorcmd"; then
    _sudo_replace_buffer "$cmd" "sudo -e"
    return
    fi

    # Check for editor commands in the typed command and replace accordingly
    case "$BUFFER" in
    $editorcmd\ *) _sudo_replace_buffer "$editorcmd" "sudo -e" ;;
    \$EDITOR\ *) _sudo_replace_buffer '$EDITOR' "sudo -e" ;;
    sudo\ -e\ *) _sudo_replace_buffer "sudo -e" "$EDITOR" ;;
    sudo\ *) _sudo_replace_buffer "sudo" "" ;;
    *) LBUFFER="sudo $LBUFFER" ;;
    esac
} always {
    # Preserve beginning space
    LBUFFER="${WHITESPACE}${LBUFFER}"

    # Redisplay edit buffer (compatibility with zsh-syntax-highlighting)
    zle redisplay
}
}

function _vi_search_fix() {
zle vi-cmd-mode
zle .vi-history-search-backward
}

function toppy() {
    history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n 21
}

function cd() {
    builtin cd "$@" && command ls --group-directories-first --color=auto -F
}

function git-svn(){
if [[ ! -z "$1" && ! -z "$2" ]]; then
        echo "Starting clone/copy ..."
        repo=$(echo $1 | sed 's/\/$\|.git$//')
        svn export "$repo/trunk/$2"
else
        echo "Use: git-svn <repository> <subdirectory>"
fi  
}

# proxy setting
function proxy () {
    export windows_host=$(ip route | grep default | awk '{print $3}')
    export windows_host=172.24.208.1
    export socks_hostport=10808
    export http_hostport=10809

        export https_proxy=http://${windows_host}:${http_hostport}
        export HTTPS_PROXY=http://${windows_host}:${http_hostport}
        export http_proxy=http://${windows_host}:${http_hostport}
        export HTTP_PROXY=http://${windows_host}:${http_hostport}
        export ALL_PROXY=socks5://${windows_host}:${socks_hostport}
        export all_proxy=socks5://${windows_host}:${socks_hostport}
        git config --global http.proxy socks5://${windows_host}:${socks_hostport}
        git config --global https.proxy socks5://${windows_host}:${socks_hostport}
    echo "Proxy on"
}

function noproxy () {
    unset HTTPS_PROXY;
    unset HTTP_PROXY;
    unset ALL_PROXY;
        unset https_proxy
        unset http_proxy
        unset all_proxy
    git config --global --unset  http.proxy;
    git config --global --unset  https.proxy;
    echo "Proxy off"
}

function echoproxy() {
        echo $all_proxy
        echo $https_proxy
        echo $http_proxy
}	

# vim:ft=zsh
