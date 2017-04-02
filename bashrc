# Prepare the bash environment: PATH, completion, history, prompt etc
#
# Usage source ${HOME}/.bashrc.d/bashrc
#


# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    MYBIN=$HOME/bin
    if [ "${PATH/$MYBIN}" == "$PATH" ] ; then
        # Not set yet. Add the path
        PATH="$HOME/bin:$PATH"
    fi
fi


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


# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"


# Configure how the history is written
export HISTSIZE=10000
export HISTFILESIZE=100000
export HISTCONTROL=ignoreboth
export HISTIGNORE='ls:ll:la:cd:exit:clear:history'
shopt -s histappend
shopt -s cmdhist
export PROMPT_COMMAND="history -a; history -c; history -r; ${PROMPT_COMMAND}"


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

# Ignored file extensions in command completion
export FIGNORE='.pyc:.o:.os'

# Default editors
export EDITOR=nano
export GIT_EDITOR=nano

# Fix perl locale problem (git uses perl)
export LC_ALL=en_US.UTF-8

