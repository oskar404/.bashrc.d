# The main .bashrc file preparing the interactive bash environment
# Symlink this to ${HOME} directory as .bashrc
#
# Prepare the bash environment: PATH, completion, history, prompt etc
#


# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac


################################################################################
# Path

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ]; then
    MYBIN=$HOME/bin
    if [ "${PATH/$MYBIN}" == "$PATH" ]; then
        # Not set yet. Add the path
        PATH="$HOME/bin:$PATH"
    fi
    unset MYBIN
fi


################################################################################
# Command completion

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# pipenv (only if pipenv is installed)
command -v pipenv >/dev/null 2>&1 && eval "$(pipenv --completion)"

# Ignored file extensions in command completion
export FIGNORE='.pyc:.o:.os'


################################################################################
# History
#
# Nice tutorial:
# https://www.digitalocean.com/community/tutorials/how-to-use-bash-history-commands-and-expansions-on-a-linux-vps

# Configure how the history is written
export HISTSIZE=10000
export HISTFILESIZE=100000
export HISTCONTROL=ignoreboth
export HISTIGNORE='ls:ll:la:lc:cd:gt:up:todo:exit:clear:hist:history'
shopt -s histappend
shopt -s cmdhist
shopt -u lithist


################################################################################
# Environment

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Set prompt. List git branch and status in prompt
# Mac OSX does not seem to support __git_ps1
if [ "$(uname)" == "Darwin" ]; then
    PS1="\h:\w: "
else
    export GIT_PS1_SHOWDIRTYSTATE=1
    PS1="\h:\w\$(__git_ps1): "
fi

# Default editors
export EDITOR=nano
export GIT_EDITOR=nano
export GUI_EDITOR=gedit

# Fix perl locale problem (git uses perl)
export LC_ALL=en_US.UTF-8

# Imrpove interactive usage of the shell with some glob
shopt -s cdspell
shopt -s dirspell
shopt -s globstar


################################################################################
# Internal Helper Functions

function _howto_helper() {
    local FUNCLIST=$(declare -F | grep -v -e 'declare -f _' -e 'command_not_found_handle' -e 'in_array' -e 'quote' | awk '{print $3}')
    local ALIASLIST=$(alias | sort | awk -F "=" '{print $1}' | awk '{print $2}')
    local GITLIST=$(git config -l | grep alias | cut -c 7- | sort | awk -F "=" '{print $1}')
    cat <<EOF

# Functions

To list function details: declare -f <function>

$(printf "  %-18s %-18s %-18s %-18s\n" ${FUNCLIST})

# Aliases

To list alias details: alias <alias-name>

$(printf "  %-18s %-18s %-18s %-18s\n" ${ALIASLIST})

# Git Aliases

To list git alias details: git config --get-regexp alias.<name>

$(printf "  %-18s %-18s %-18s %-18s\n" ${GITLIST})

# More About Commands

  man <command>
  help <built-in>
  type [-a|-t] <command>
  command [-V] <command>

EOF
}

# Start $GUI_EDITOR if in X and $EDITOR if not
function _edit() {
    if xhost >& /dev/null ; then
        if [ "$TERM" = "screen" ] && [ -n "$TMUX" ]; then
            ${EDITOR} $@
        else
            ${GUI_EDITOR} $@ &
        fi
    else
        ${EDITOR} $@
    fi
}

# View or edit markdown file
# This uses mdv tool: https://github.com/axiros/terminal_markdown_viewer
function _mdhelper() {
    local USAGE="usage: _mdhelper <file> [-e|--edit]"
    local FILE=$1
    shift
    local EDIT="v"
    while [ "$1" != "" ]; do
        case "$1" in
          -e | --edit)
            local EDIT="e" ;;
          *)
            (>&2 echo $USAGE); return ;;
        esac
        shift
    done

    if [ "${EDIT}" == "e" ]; then
        _edit "${FILE}"
    else
        command -v mdv >/dev/null 2>&1 || { echo >&2 "missing mdv tool"; return; }
        [ -e "${FILE}" ] && (mdv -t 528.9419 ${FILE} | less -r -X -F) || (>&2 echo "missing file: ${FILE}")
    fi
}

# Update git repo. Tries to do 'git pull --rebase' if directory is a git repo
# usage: _git_update_repo <dir>
function _git_update_repo() {
    if [ -d "$1" ]; then
        cd "$1"
        [ -d .git ] && git pull --rebase
        cd -
    fi
}


################################################################################
# Public Functions

# Print HOWTO help to screen
# usage: howto [-e]
function howto() {
    local USAGE="usage: howto [-e]"
    local FILE=${HOME}/howto.txt
    local EDIT="v"
    while [ "$1" != "" ]; do
        case "$1" in
          -e | --edit)
            local EDIT="e" ;;
          *)
            (>&2 echo $USAGE); return ;;
        esac
        shift
    done

    if [ "${EDIT}" == "e" ]; then
        _edit "${FILE}"
    else
        if [ ! -e "${FILE}" ]; then
            echo "# How-to help" >${FILE}
            echo "" >>${FILE}
            echo "Add local help to this file. To edit: howto -e" >>${FILE}
        fi
        (cat ${FILE} ; _howto_helper) | less -r -X -F
    fi
}

# Loop command N-times. Fail if command return value is non-zero
# usage: loop [-h] <counter> <path-to-program> [command args]
function loop() {
    local USAGE="usage: loop [-h] <counter> <path-to-program> [command args]"
    local CNTR=0
    [ -z "$1" ] && (>&2 echo $USAGE) && return
    case $1 in
      -h)
        (>&2 echo $USAGE); return ;;
      *)
        local CNTR=$1 ;;
    esac
    shift

    local PROG=$@
    [ "${PROG}" == "" ] && (>&2 echo $USAGE) && return
    for i in $(seq 1 ${CNTR}); do
        ${PROG}
        local RET=$?
        [ "${RET}" != "0" ] && (>&2 echo "run $i fail: ${RET}") && return
    done
}

# cd multiple levels down
# usage: cdn <number>
function cdn() {
    local LVL=${1:-0}
    local ARG=""
    for (( i=0; i<${LVL}; i++)); do
        ARG="${ARG}../"
    done
    cd "${ARG:-$HOME}"
}

# Convert uppercase file and folder names to lower case.
# usage: lcffile [-r] <dir>
function lcfile() {
    local USAGE="usage: lcfile [-r] <dir>"
    local DEPTH="-maxdepth 1"

    while [ "$1" != "" ]; do
        case "$1" in
          -h | --help)
            (>&2 echo $USAGE); return ;;
          -r)
            local DEPTH="" ;;
          *)
            local DIR=$1 ;;
        esac
        shift
    done

    [ -z "${DIR}" ] && (>&2 echo $USAGE) && return

    for SRC in $(find ${DIR} -depth ${DEPTH}); do
        DST=$(dirname "${SRC}")/$(basename "${SRC}" | tr '[A-Z]' '[a-z]')
        if [ "${SRC}" != "${DST}" ]
        then
            echo ${DST}
            [ ! -e "${DST}" ] && mv -T "${SRC}" "${DST}" || (>&2 echo "${SRC} was not renamed")
        fi
    done
}

# Trim trailing whitespace
# usage: trim-ws <file> [<file> ..]
function trim-ws() {
    local USAGE="usage: trim-ws <file> [<file> ..]"
    [ -z "$1" ] && (>&2 echo $USAGE) && return
    [ "$1" == "-h" ] && (>&2 echo $USAGE) && return
    sed -i 's/[ \t]*$//' $@
}

# Replace tabs with spaces
# usage: trim-tab <file> [<file> ..]
function trim-tab() {
    local USAGE="usage: trim-tab <file> [<file> ..]"
    [ -z "$1" ] && (>&2 echo $USAGE) && return
    [ "$1" == "-h" ] && (>&2 echo $USAGE) && return
    command -v sponge >/dev/null 2>&1 || { echo >&2 "Missing sponge. Install moreutils"; return; }
    while [ "$1" != "" ]; do
        expand -t 4 "$1" | sponge "$1"
        shift
    done
}

# Generate a random password
# usage: genpasswd [length]
function genpasswd() {
    local PWDLEN=${1:-32}
    tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${PWDLEN} | xargs
}

# Generate a PIN code
# usage: genpin [length]
function genpin() {
    local PINLEN=${1:-4}
    tr -dc 0-9 < /dev/urandom | head -c ${PINLEN} | xargs
}

# Ceasar cipher / ROT-13
# usage: rot13 [filename]
function rot13() {
    if [  $# = 0 ]; then
        tr "[a-m][n-z][A-M][N-Z]" "[n-z][a-m][N-Z][A-M]"
    else
        tr "[a-m][n-z][A-M][N-Z]" "[n-z][a-m][N-Z][A-M]" < $1
    fi
}

# Show threads of a process
function atop() {
    [ -z "$1" ] && (>&2 echo "usage: atop <process-name>") && return
    top -H -p $(pgrep $1)
}

# List of most used commands in history
# NB! If ignoredups and erasedups is used then the output may not be usefull
# usage: xtop [number]
function xtop() {
    local N=${1:-10}
    history | awk '{a[$2]++ } END{for(i in a){print a[i] " " i}}' | sort -rn | head -n $N;
}

# Find all c and cpp src files in dir
# usage: c-src [dir]
function c-src() {
    local USAGE="usage: c-src [dir]"
    [ "$1" == "-h" ] && (>&2 echo $USAGE) && return
    local SRC=.
    [ -n "$1" ] && local SRC="$1"
    find ${SRC} -regextype posix-extended -regex "^.*\.(cpp|hpp|c|h)$" | grep -ve "^\.\/debian"
}

# Find all python src files in dir
# usage: py-src [dir]
function py-src() {
    local USAGE="usage: py-src [dir]"
    [ "$1" == "-h" ] && (>&2 echo $USAGE) && return
    local SRC=.
    [ -n "$1" ] && local SRC="$1"
    find ${SRC} -name "*.py"
}

# Find all R src files in dir
# usage: r-src [dir]
function r-src() {
    local USAGE="usage: r-src [dir]"
    [ "$1" == "-h" ] && (>&2 echo $USAGE) && return
    local SRC=.
    [ -n "$1" ] && local SRC="$1"
    find ${SRC} -regex ".*\.[rR]"
}

# Find all JSON files in dir
# usage: json-src [dir]
function json-src() {
    local USAGE="usage: json-src [dir]"
    [ "$1" == "-h" ] && (>&2 echo $USAGE) && return
    local SRC=.
    [ -n "$1" ] && local SRC="$1"
    find ${SRC} -iname "*.json"
}

# Validate JSON file(s)
# usage: jsv <file.json> [<file.json>..]
function jsv() {
    local USAGE="usage: jsv <file.json> [<file.json>..]"
    [ -z "$1" ] && (>&2 echo $USAGE) && return
    [ "$1" == "-h" ] && (>&2 echo $USAGE) && return
    while [ "$1" != "" ]; do
        echo -n "$1: "
        cat $1 | python -m json.tool >/dev/null && echo "OK"
        shift
    done
}

################################################################################
# Functions using external network services

# Search with google / open browser
function @google {
    xdg-open "https://google.com/search?q=$*"
}

# For completeness: search with duckduckgo.com / open browser
function @duckduckgo {
    xdg-open "https://duckduckgo.com/?q=$*"
}

# Search from sanakirja.org. Translate from Finnish to English
function @sanakirja {
    xdg-open "https://www.sanakirja.org/search.php?l=17&l2=3&q=$*"
}

# Search from sanakirja.org. Translate from English to Finnish
function @dictionary {
    xdg-open "https://www.sanakirja.org/search.php?l=3&l2=17&q=$*"
}

# Search from stackoverflow.com / open browser
function @stackoverflow {
    [ $# -eq 0 ] && xdg-open "https://stackoverflow.com/" && return
    xdg-open "https://stackoverflow.com/search?q=$*"
}

# Search from youtube.com
function @yt {
    [ $# -eq 0 ] && xdg-open "https://youtube.com/" && return
    xdg-open "https://youtube.com/results?search_query=$*"
}

# Search from haveibeenpwned.com
function @pwned {
    [ $# -eq 0 ] && xdg-open "https://haveibeenpwned.com/" && return
    curl "https://haveibeenpwned.com/api/v2/breachedaccount/$*?truncateResponse=true"
    echo ""
}

# Search from cppreference.com
function @cppreference {
    [ $# -eq 0 ] && xdg-open "https://en.cppreference.com/" && return
    xdg-open "https://en.cppreference.com/mwiki/index.php?search=$*"
}

# Search from explainshell.com
function @explain {
    [ $# -eq 0 ] && xdg-open "https://explainshell.com/" && return
    xdg-open "https://explainshell.com/explain?cmd=$*"
}

# Open www.grc.com/shieldsup
function @shieldsup {
    xdg-open "https://www.grc.com/shieldsup"
}

# Open regex101.com (Other similar sites: regexr.com www.regexpal.com)
function @regex101 {
    xdg-open "https://regex101.com/"
}

# Open tcpdump101.com
function @tcpdump101 {
    xdg-open "https://tcpdump101.com/"
}

# Get domain IP address
# Requires dig command. To install: sudo apt install dnsutils
function @ip-resolver {
    local USAGE="usage: ip-resolver <domain-name> [<domain-name>..]"
    [ "$1" == "-h" ] && (>&2 echo $USAGE) && return
    [ $# -eq 0 ] && (>&2 echo $USAGE) && return
    while [ "$1" != "" ]; do
        echo "$1 " ; dig +short @resolver1.opendns.com $1 ; shift
    done
}

# Get country / location information of an IP address
function @ip-locator {
    local USAGE="usage: ip-locator <ip> [<ip>..]"
    [ "$1" == "-h" ] && (>&2 echo $USAGE) && return
    curl ipinfo.io/$1 && shift
    while [ "$1" != "" ]; do
        curl ipinfo.io/$1
        shift
    done
}


################################################################################
# Aliases

# Enable color support of ls other tools if available
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias tree='tree -C'
    alias grep='grep --color=auto'
fi

# Aliases for file and directory operations
alias ll='ls -ltrh'
alias la='ls -A'
alias gr='grep --color -rIi'
alias lc='c-src | xargs -d "\n" cat | wc -l'
alias e='_edit'
alias scat='sudo cat'
alias td='pushd $(mktemp -d)' # creates a temp dir and cds into it

# Git aliases
alias up='git up' # Use git alias
alias st='git st' # Use git alias
alias lol='git lol' # Use git alias
alias lh='git lh' # Use git alias
alias gd='git diff'
alias gt='qgit --all -n 10000' # Start git GUI
alias gh='qgit -n 10000 HEAD' # Start git GUI

# Process aliases
alias ctop='top -o %CPU' #cpu
alias mtop='top -o %MEM' #memory

# Network aliases
alias publicip='curl https://ifcfg.me/all'
# alias publicip='curl http://ipinfo.io/ip'
alias myip='hostname -I'
alias dnstest='while true; do dig www.google.com | grep time; sleep 2; done'

# Quick HTTP/webserver for local files
alias webs='python -m SimpleHTTPServer'

# Some files where notes, todos etc are collected + other house keeping
alias todo='_mdhelper "${HOME}"/todo.md'
alias notes='_mdhelper "${HOME}"/notes.md'
alias hist='history -a; history -c; history -r'

# fslint aliases (sudo apt install fslint)
alias fslint='/usr/share/fslint/fslint/fslint'
alias findup='/usr/share/fslint/fslint/findup'

# Code utils
alias codecheck='cppcheck -j4 --enable=warning,performance,portability,style --inline-suppr --quiet'

# Just for fun
alias frak="fortune"


################################################################################
# External configs

# Bash config dir containing additional configs to be sourced
# Rewrite this if the configs are read from somewhere else
export BASHCONFD="$HOME/.bashrc.d"

# Source the configurations in .bashrc.d directory
if [ -d "${BASHCONFD}" ]; then
    CONFS=[]
    CONFS=$(ls "${BASHCONFD}"/*.conf 2> /dev/null)
    if [ $? -eq 0 ]; then
        for CONF in ${CONFS[@]}
        do
            source $CONF
        done
    fi
    unset CONFS
    unset CONF
fi

# Make bash environment update easier
alias re-bash='_git_update_repo ${BASHCONFD} &> /dev/null; source "${HOME}"/.bashrc'
alias re-edit='_edit "${HOME}"/.bashrc'

