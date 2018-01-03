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

# View or edit markdown file
# This uses mdv tool: https://github.com/axiros/terminal_markdown_viewer
# usage: mdhelper <file>
function mdhelper() {
    local USAGE="mdhelper <file> [-e|--edit]"
    local FILE=$1
    shift
    local EDIT="v"
    while [ "$1" != "" ];
    do
        case "$1" in
          -e)
            local EDIT="e"
            ;;
          --edit)
            local EDIT="e"
            ;;
          *)
            echo $USAGE
            return
            ;;
        esac
        shift
    done

    if [ "${EDIT}" == "e" ]; then
        ${GUI_EDITOR} "${FILE}"&
    else
        which mdv >/dev/null
        local MDV=$?
        [ "${MDV}" != "0" ] && (echo "missing mdv tool"; return)
        [ -e "${FILE}" ] && mdv -t 528.9419 ${FILE} || echo "missing file: ${FILE}"
    fi
}

# cd multiple levels down
# usage: cdn <number>
function cdn(){
    local LVL=${1:-0}
    local ARG=""
    for (( i=0; i<${LVL}; i++))
    do
        ARG="${ARG}../"
    done
    cd "${ARG:-$HOME}"
}

# Update git repo. Tries to do 'git pull --rebase' if directory is a git repo
# usage: update_git_repo <dir>
function update_git_repo(){
    if [ -d "$1" ]; then
        cd "$1"
        if [ -d .git ]; then
            git pull --rebase
        fi
        cd -
    fi
}

# Convert uppercase file and folder names to lower case.
# usage: lcffile [-r] <dir>
function lcfile(){
    local DEPTH="-maxdepth 1"

    while [ "$1" != "" ];
    do
        case "$1" in
          -r)
            local DEPTH=""
            ;;
          *)
            local DIR=$1
        esac
        shift
    done

    if [ -z "${DIR}" ]; then
        echo "lcfile [-r] <dir>"
        return
    fi

    for SRC in $(find ${DIR} -depth ${DEPTH})
    do
        DST=$(dirname "${SRC}")/$(basename "${SRC}" | tr '[A-Z]' '[a-z]')
        if [ "${SRC}" != "${DST}" ]
        then
            echo ${DST}
            [ ! -e "${DST}" ] && mv -T "${SRC}" "${DST}" || echo "${SRC} was not renamed"
        fi
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
    local TESTAPP=$1
    if [ -n "${TESTAPP}" ]; then
        top -H -p $(pgrep ${TESTAPP})
    else
        echo "usage: atop <process-name>"
    fi
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


################################################################################
# Aliases

# Enable color support of ls other tools if available
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias tree='tree -C'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Aliases for file and directory operations
alias ll='ls -ltrh'
alias la='ls -A'
alias grip='grep -rIi'
alias e='${GUI_EDITOR}'
alias scat='sudo cat'
alias td='pushd $(mktemp -d)' # creates a temp dir and cds into it

# Git aliases
alias up='git fetch --prune; git fetch --tags'
alias gt='qgit --all -n 10000' # Start git GUI

# Process aliases
alias ctop='top -o %CPU' #cpu
alias mtop='top -o %MEM' #memory

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
alias re-bash="update_git_repo ${BASHCONFD} &> /dev/null; source "${HOME}"/.bashrc"

