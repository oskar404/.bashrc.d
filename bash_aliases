# Magic world of bash aliases
# 
# source ${HOME}/.bashrc.d/bash_aliases
#

# Enable color support of ls other tools if available
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias tree='tree -C'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Makes bash update easier
alias re-bash="cd ${HOME}/.bashrc.d; git pull --rebase; source ${HOME}/.bashrc; cd -"

# Aliases for file and directory operations
alias ll='ls -ltrh'
alias la='ls -A'
alias grip='grep -rIi'
alias e='gedit'
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

# Just for fun
alias frak="fortune"
alias yt="xdg-open https://youtube.com"

