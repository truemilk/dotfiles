# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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
    export EDITOR="vi"
fi

# aliases
alias ll="ls -l"
alias la="ls -A"
alias dh='dirs -v'

alias v="$EDITOR"

alias gacp='git add . && git commit -m "gacp!" && git push'

alias uv="vim '+PlugUpgrade' '+PlugUpdate' '+PlugClean!' '+qall'"
alias ub="brew update && brew upgrade && brew cleanup && brew cask upgrade"
alias uz="zplug update && echo '\nReloading zsh...' && source ~/.zshrc"

alias ze="v ~/.zshrc && echo '\nReloading zsh...\n' && source ~/.zshrc"
alias zr="echo '\nReloading zsh...\n' && source ~/.zshrc"

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

# zplug
export ZPLUG_HOME=/usr/local/opt/zplug
if [ -d $ZPLUG_HOME ]; then
    source $ZPLUG_HOME/init.zsh
    zplug "zsh-users/zsh-autosuggestions"
    zplug "romkatv/powerlevel10k", as:theme, depth:1
    if ! zplug check --verbose; then
        printf "Install? [y/N]: "
        if read -q; then
            echo; zplug install
        fi
    fi
    zplug load
    export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    export ZSH_AUTOSUGGEST_USE_ASYNC=1
    export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#888888,bg=#222222"
fi

# rust - Manually installed
if [ -d $HOME/.cargo ]; then
    export PATH=$HOME/.cargo/bin:$PATH
fi

# golang
if [ -d $HOME/go ]; then
    export GOPATH=$HOME/go
    export GOROOT=/usr/local/opt/go/libexec
    export PATH=$GOPATH/bin:$PATH
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
if [ -d $HOME/.poetry ]; then
    export PATH=$HOME/.poetry/bin:$PATH
fi

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
    export FZF_DEFAULT_OPTS='--height 50% --layout=reverse --border --inline-info'
    export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
    export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
fi

# extras
if [ -d $HOME/.zextras ]; then
  for i in $HOME/.zextras/*;
    source $i
fi

# ~/bin 
if [ -d $HOME/bin ]; then
    export PATH=$HOME/bin:$PATH
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
