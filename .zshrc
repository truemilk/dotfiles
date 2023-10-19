bindkey -e
export KEYTIMEOUT=1

HISTFILE="$HOME/.zhistory"
HISTSIZE=999999
SAVEHIST=$HISTSIZE
setopt BANG_HIST
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt HIST_BEEP

autoload -Uz compinit
if [ $(date +'%j') != $(stat -f '%Sm' -t '%j' ~/.zcompdump) ]; then
    compinit
else
    compinit -C
fi

DIRSTACKSIZE=10
setopt autopushd pushdminus pushdsilent pushdtohome

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

zstyle ':completion:*' rehash true

fpath=(/usr/local/share/zsh-completions $fpath)

export CLICOLOR=1
export LSCOLORS=GxFxcxdxbxegedabagacad

if which nvim > /dev/null; then
    export EDITOR="vim"
else
    export EDITOR="nano"
fi

alias v="$EDITOR"

alias ls="ls -F"
alias la="ls -A"
alias ll="ls -l"

alias -g A="| awk"
alias -g R="| rg"
alias -g G="| grep --color"
alias -g L="| less"
alias -g F="| fzf"
alias -g C="| pbcopy"
alias -g V="| vim -"

alias curl="curl -s"

alias ..='cd ..'
alias ...='cd .. && cd ..'

alias h1g="history 1 | grep --color"

alias zreload="echo 'Reloading zsh...' && source ~/.zshrc"
alias zshrc="v ~/.zshrc && zreload"

alias update-brew="brew autoremove && brew update && brew upgrade && brew cleanup"
alias update-vim="vim '+PlugUpgrade' '+PlugUpdate' '+PlugClean!' '+qall'"

alias tm="tmux new-session -A"
alias tml="tmux list-sessions"

tma() {
    if (( $# != 1 )); then
        echo 'I need a session name!'
    else
        tmux attach-session -t $1
    fi
}

tmn() {
    if (( $# != 1 )); then
        echo 'I need a session name!'
    else
        tmux new-session -s $1
    fi
}

autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

#[ -d $HOME/.cargo ] && export PATH=$HOME/.cargo/bin:$PATH

if [ -d $HOME/go ]; then
    export GOPATH=$HOME/go
    export GOBIN=$GOPATH/bin
    export GOROOT=/usr/local/opt/go/libexec
    export PATH=$GOBIN:$PATH
fi

if which pyenv > /dev/null; then
    export PYENV_ROOT=$HOME/.pyenv
    export PATH=$PYENV_ROOT/bin:$PATH
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    if which pyenv-virtualenv-init > /dev/null; then
        eval "$(pyenv virtualenv-init -)";
    fi
fi

#[ -d $HOME/.poetry ] && export PATH=$HOME/.poetry/bin:$PATH

if which pipenv > /dev/null; then
    export PIPENV_VENV_IN_PROJECT=1
fi

#if [ -d $HOME/.sdkman ]; then
#    export SDKMAN_DIR="$HOME/.sdkman"
#    [ -s "$HOME/.sdkman/bin/sdkman-init.sh" ] && source "$HOME/.sdkman/bin/sdkman-init.sh"
#fi

#if which jenv > /dev/null; then
#    export PATH="$HOME/.jenv/bin:$PATH"
#    eval "$(jenv init -)"
#fi

if which fzf > /dev/null; then
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
    export FZF_DEFAULT_OPTS='--height 50% --reverse --info inline --border rounded'
    export FZF_CTRL_R_OPTS="-i"
    export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
    if which fd > /dev/null; then
        export FZF_DEFAULT_COMMAND="fd . $HOME"
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        bindkey "ç" fzf-cd-widget
        export FZF_ALT_C_COMMAND="fd -t d . $HOME"
    fi
fi

if [ -d $HOME/.zextras ]; then
    for i in $HOME/.zextras/*;
        source $i
fi

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform

#export GPG_TTY=$(tty)
#export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
#gpg-connect-agent updatestartuptty /bye > /dev/null

[ -d $HOME/bin ] && export PATH=$HOME/bin:$PATH

function gdub() {
    git fetch --all --prune;
    for branch in $(git branch -vv | grep ': gone]' | awk '{print $1}');
    do
        git branch -D $branch;
    done;
}

eval "$(starship init zsh)"

# added by Snowflake SnowSQL installer v1.2
export PATH=/Users/ivan.giacomelli/Applications/SnowSQL.app/Contents/MacOS:$PATH
