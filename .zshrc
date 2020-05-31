bindkey -e
export KEYTIMEOUT=1

# history
HISTFILE="$HOME/.zhistory"
HISTSIZE=1000
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

# compinit
autoload -Uz compinit
if [ $(date +'%j') != $(stat -f '%Sm' -t '%j' ~/.zcompdump) ]; then
  compinit
else
  compinit -C
fi

# dirs
DIRSTACKSIZE=10
setopt autopushd pushdminus pushdsilent pushdtohome

# completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Persistent rehash - https://wiki.archlinux.org/index.php/zsh#Persistent_rehash
zstyle ':completion:*' rehash true

# completions
fpath=(/usr/local/share/zsh-completions $fpath)

# lscolors
export CLICOLOR=1
export LSCOLORS=GxFxcxdxbxegedabagacad

if which vim > /dev/null; then
    export EDITOR="vim"
else
    export EDITOR="nano"
fi

# aliases
alias ll="ls -l"
alias la="ls -A"

alias -g A="| awk"
alias -g R="| rg"
alias -g G="| grep"
alias -g L="| less"
alias -g F="| fzf"
alias -g C="| pbcopy"
alias -g V="| vim -"

alias v="$EDITOR"

alias gacp='git add . && git commit -m "gacp!" && git push'

alias uv="vim '+PlugUpgrade' '+PlugUpdate' '+PlugClean!' '+qall'"
alias ub="brew update && brew upgrade && brew cleanup && brew cask upgrade"

alias ze="v ~/.zshrc && echo '\nReloading zsh...\n' && source ~/.zshrc"
alias zr="echo '\nReloading zsh...\n' && source ~/.zshrc"

alias wiki="vim -c VimwikiIndex"

tm() {
    if (( $# != 1 )); then
        tmux list-sessions
    else
        tmux new-session -A -s $1
    fi
}

autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

autoload -Uz vcs_info
precmd () { vcs_info }
setopt prompt_subst
PS1='%F{cyan}%(5~|%-1~/…/%3~|%4~)%f${vcs_info_msg_0_} %F{magenta}%%%f '

# rust - Manually installed
[[ -d $HOME/.cargo ]] && export PATH=$HOME/.cargo/bin:$PATH

# golang - From Homebrew
if [ -d $HOME/go ]; then
    export GOPATH=$HOME/go
    export GOBIN=$GOPATH/bin
    export GOROOT=/usr/local/opt/go/libexec
    export PATH=$GOBIN:$PATH
fi

# pyenv - From Homebrew
if which pyenv > /dev/null; then
    export PYENV_ROOT=$HOME/.pyenv
    export PATH=$PYENV_ROOT/bin:$PATH
    eval "$(pyenv init -)"
    if which pyenv-virtualenv-init > /dev/null; then 
      eval "$(pyenv virtualenv-init -)";
    fi
fi

# poetry - Manually installed
[[ -d $HOME/.poetry ]] && export PATH=$HOME/.poetry/bin:$PATH

# pipenv - From Homebrew
if which pipenv > /dev/null; then
    export PIPENV_VENV_IN_PROJECT=1
fi

# sdkman - Manually installed
if [ -d $HOME/.sdkman ]; then
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# fzf
if which fzf > /dev/null; then
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --inline-info'
    export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
    export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
    if which fd > /dev/null; then
        export FZF_DEFAULT_COMMAND="fd . $HOME"
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND="fd -t d . $HOME"
    fi
fi

# extras
if [ -d $HOME/.zextras ]; then
  for i in $HOME/.zextras/*;
    source $i
fi

# ~/bin 
[[ -d $HOME/bin ]] && export PATH=$HOME/bin:$PATH
