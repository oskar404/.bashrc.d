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

# Ignored file extensions in command completion
export FIGNORE='.pyc:.o:.os'


################################################################################
# History

# Configure how the history is written
export HISTSIZE=10000
export HISTFILESIZE=100000
export HISTCONTROL=ignoreboth
export HISTIGNORE='ls:ll:la:cd:exit:clear:history'
shopt -s histappend
shopt -s cmdhist
export PROMPT_COMMAND="history -a; history -c; history -r; ${PROMPT_COMMAND}"


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


################################################################################
# Functions

# Loop command N-times. Fail if command return value is non-zero
# usage: loop [-h] <counter> <path-to-program> [command args]
function loop {
    local USAGE="usage: loop [-h] <counter> <path-to-program> [command args]"
    local CNTR=0
    [ -z "$1" ] && (>&2 echo $USAGE) && return
    case $1 in
      -h)
        (>&2 echo $USAGE); return
        ;;
      *)
        local CNTR=$1
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

# View or edit markdown file
# This uses mdv tool: https://github.com/axiros/terminal_markdown_viewer
# usage: mdhelper <file>
function mdhelper() {
    local USAGE="usage: mdhelper <file> [-e|--edit]"
    local FILE=$1
    shift
    local EDIT="v"
    while [ "$1" != "" ]; do
        case "$1" in
          -e)
            local EDIT="e"
            ;;
          --edit)
            local EDIT="e"
            ;;
          *)
            (>&2 echo $USAGE); return
            ;;
        esac
        shift
    done

    if [ "${EDIT}" == "e" ]; then
        ${GUI_EDITOR} "${FILE}"&
    else
        which mdv >/dev/null
        local MDV=$?
        [ "${MDV}" != "0" ] && (>&2 echo "missing mdv tool") && return
        [ -e "${FILE}" ] && (mdv -t 528.9419 ${FILE} | less -r -X -F) || (>&2 echo "missing file: ${FILE}")
    fi
}

# cd multiple levels down
# usage: cdn <number>
function cdn(){
    local LVL=${1:-0}
    local ARG=""
    for (( i=0; i<${LVL}; i++)); do
        ARG="${ARG}../"
    done
    cd "${ARG:-$HOME}"
}

# Update git repo. Tries to do 'git pull --rebase' if directory is a git repo
# usage: update_git_repo <dir>
function update_git_repo(){
    if [ -d "$1" ]; then
        cd "$1"
        [ -d .git ] && git pull --rebase
        cd -
    fi
}

# Convert uppercase file and folder names to lower case.
# usage: lcffile [-r] <dir>
function lcfile(){
    local USAGE="usage: lcfile [-r] <dir>"
    local DEPTH="-maxdepth 1"

    while [ "$1" != "" ]; do
        case "$1" in
          -h)
            (>&2 echo $USAGE); return
            ;;
          -r)
            local DEPTH=""
            ;;
          *)
            local DIR=$1
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

# Trim whitespace from the end of lines
# usage: trim_ws <file> [<file> ..]
function trim_ws(){
    local USAGE="usage: trim_ws <file> [<file> ..]"
    [ -z "$1" ] && (>&2 echo $USAGE) && return
    [ "$1" == "-h" ] && (>&2 echo $USAGE) && return
    sed -i 's/[ \t]*$//' $@
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
function rot13()
{
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
    xdg-open "https://stackoverflow.com/search?q=$*"
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
alias grip='grep --color -rIi'
alias gripc='find . -regextype posix-extended -regex "^.*\.(cpp|hpp|c|h)$" | grep -ve "^\.\/debian" | xargs -d "\n" grep --color -Ii'
alias grippy='find . -name "*.py" -print0 | xargs -0 grep --color -Ii'
alias gripr='find . -regex ".*\.[rR]" -print0 | xargs -0 grep --color -Ii'
alias e='${GUI_EDITOR}'
alias scat='sudo cat'
alias td='pushd $(mktemp -d)' # creates a temp dir and cds into it

# Git aliases
alias up='git up' # Use git alias
alias gt='qgit --all -n 10000' # Start git GUI

# Process aliases
alias ctop='top -o %CPU' #cpu
alias mtop='top -o %MEM' #memory

# Network aliases
alias publicip='curl https://ifcfg.me/all'
# alias publicip='curl http://ipinfo.io/ip'
alias shieldsup='xdg-open https://www.grc.com/shieldsup'
alias dnstest='while true; do dig www.google.com | grep time; sleep 2; done'

# Quick HTTP/webserver for local files
alias webs='python -m SimpleHTTPServer'

# Some files where notes, todos etc are collected
alias todo='mdhelper "${HOME}"/todo.md'
alias notes='mdhelper "${HOME}"/notes.md'

# Just for fun
alias frak="fortune"
alias yt="xdg-open https://youtube.com"


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
alias re-bash='update_git_repo ${BASHCONFD} &> /dev/null; source "${HOME}"/.bashrc'
alias re-edit='${GUI_EDITOR} "${HOME}"/.bashrc &'

