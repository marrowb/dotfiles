# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples
# We use preexec and precmd hook functions for Bash
# If you have anything that's using the Debug Trap or PROMPT_COMMAND 
# change it to use preexec or precmd
# See also https://github.com/rcaloras/bash-preexec
#
# Vi-editing mode
set -o emacs
# Adding files to the path

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# WSL2 Xserver
# export DISPLAY=$(ip route|awk '/^default/{print $3}'):0.0
# export DISPLAY=host.docker.internal:0

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth
HISTCONTROL=ignoredups:erasedups

# save and reload history after each command
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=100000
HISTFILESIZE=100000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias lh='ls -latrh'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CFS'

# FZF Aliases
alias v='vim $(fzf -m)'

# Git aliases
alias gcs='git commit -S -m'

# Docker aliases
alias dcrestart='docker compose stop && docker compose rm -f && docker compose up'

# Man page search
alias fman='compgen -c | fzf | xargs man'

#cp
alias copy='cp ~/$(cd ~ && fzf)' 

# Find Large Files
alias bigfiles='find ~ -type f -printf "%s\t%p\n" | sort -n | tail -20 | awk '"'"'BEGIN {OFS="\t"} {$1=sprintf("%.2f", $1/(1024*1024*1024)); print $1, "GB", $2}'"'"

#Notify
not() {
    local last_command="$(fc -ln -1)"
    notify-send "Command Finished" "'$last_command' has finished executing."
}

#LLM Functions
#

alias opus='llm -m claude-3-opus'
alias haiku='llm -m claude-3-opus'

comment(){
  # Use the llm command with the claude-3-opus model
  # Pass the instructions as a string argument using the -s flag
  llm -m claude-3-opus -s 'Add comments to this code. Respond with the code and comments. Do not alter the functional aspect of the code, but still return it. Be sure and include the code in the response. Do not respond in a markdown code block. Just respond with the code and comments. Do not preamble or say anything before or after the code. for example: If the user sent "print(1)\nprint(2)", you would reply "# Prints 1\nprint(1)\n# Prints 2\nprint(2)"'
}

format() {
  llm -m claude-3-opus -s "Please reformat the code in the following way: $1.Do not alter the functional aspect of the code, but still return it. Be sure and include the code in the response. Do not respond in a markdown code block. Just respond with the reformatted code. Do not preamble or say anything before or after the code."
}


# Rust
export PATH="$PATH:$HOME/.cargo/bin"

# Neovim config
# alias vim='env -u VIMINIT vim'
# alias nvim="VIMINIT='$HOME/.cfg/nvim/init.lua' nvim"
export XDG_CONFIG_HOME=$HOME/.config
alias nvim="/usr/local/bin/nvim"

# Git dotfiles
# https://news.ycombinator.com/item?id=11071754
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'


# Note Aliases
alias rgn="rg -F '[NOTE]'"

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
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

# If this is an xterm set more declarative titles 
# "dir: last_cmd" and "actual_cmd" during execution
# If you want to exclude a cmd from being printed see line 156
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\$(print_title)\a\]$PS1"
    __el_LAST_EXECUTED_COMMAND=""
    print_title () 
    {
        __el_FIRSTPART=""
        __el_SECONDPART=""
        if [ "$PWD" == "$HOME" ]; then
            __el_FIRSTPART=$(gettext --domain="pantheon-files" "Home")
        else
            if [ "$PWD" == "/" ]; then
                __el_FIRSTPART="/"
            else
                __el_FIRSTPART="${PWD##*/}"
            fi
        fi
        if [[ "$__el_LAST_EXECUTED_COMMAND" == "" ]]; then
            echo "$__el_FIRSTPART"
            return
        fi
        #trim the command to the first segment and strip sudo
        if [[ "$__el_LAST_EXECUTED_COMMAND" == sudo* ]]; then
            __el_SECONDPART="${__el_LAST_EXECUTED_COMMAND:5}"
            __el_SECONDPART="${__el_SECONDPART%% *}"
        else
            __el_SECONDPART="${__el_LAST_EXECUTED_COMMAND%% *}"
        fi 
        printf "%s: %s" "$__el_FIRSTPART" "$__el_SECONDPART"
    }
    put_title()
    {
        __el_LAST_EXECUTED_COMMAND="${BASH_COMMAND}"
        printf "\033]0;%s\007" "$1"
    }
    
    # Show the currently running command in the terminal title:
    # http://www.davidpashley.com/articles/xterm-titles-with-bash.html
    update_tab_command()
    {
        # catch blacklisted commands and nested escapes
        case "$BASH_COMMAND" in 
            *\033]0*|update_*|echo*|printf*|clear*|cd*)
            __el_LAST_EXECUTED_COMMAND=""
                ;;
            *)
            put_title "${BASH_COMMAND}"
            ;;
        esac
    }
    preexec_functions+=(update_tab_command)
    ;;
*)
    ;;
esac
# Install Ruby Gems to ~/gems
export GEM_HOME="$HOME/gems"
export PATH="$HOME/gems/bin:$PATH"

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

export FLYCTL_INSTALL="$HOME/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

export PATH="$HOME/bin:$PATH"

export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"
[ -f ~/.fzf.bash ] && source ~/.fzf.bash


export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH=$HOME/go/bin:$PATH
