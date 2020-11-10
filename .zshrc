# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

bindkey -e
export KEYTIMEOUT=1

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

if which vim > /dev/null; then
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

alias gacp='git add . && git commit -m "gacp!" && git push'

alias zreload="echo 'Reloading zsh...' && source ~/.zshrc"
alias zshrc="v ~/.zshrc && zreload"

alias update-all-zplug="zplug update"
alias update-all-vim="vim '+PlugUpgrade' '+PlugUpdate' '+PlugClean!' '+qall'"
alias update-all-brew="brew update && brew upgrade && brew cleanup"

update() {
    if (( $# != 1 )); then
        echo "Say something..."
    else
        case "$1" in
            "zplug")
                update-all-zplug
                zreload
                ;;
            "vim")
                update-all-vim
                ;;
            "brew")
                update-all-brew
                zreload
                ;;
            "all")
                update-all-zplug
                update-all-vim
                update-all-brew
                zreload
                ;;
            esac
    fi
}

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

export ZPLUG_HOME=/usr/local/opt/zplug
if [ -d $ZPLUG_HOME ]; then
    source $ZPLUG_HOME/init.zsh
    zplug "romkatv/powerlevel10k", as:theme, depth:1
    if ! zplug check --verbose; then
        printf "Install? [y/N]: "
        if read -q; then
            echo; zplug install
        fi
    fi
    zplug load
fi

[ -d $HOME/.cargo ] && export PATH=$HOME/.cargo/bin:$PATH

if [ -d $HOME/go ]; then
    export GOPATH=$HOME/go
    export GOBIN=$GOPATH/bin
    export GOROOT=/usr/local/opt/go/libexec
    export PATH=$GOBIN:$PATH
fi

if which pyenv > /dev/null; then
    export PYENV_ROOT=$HOME/.pyenv
    export PATH=$PYENV_ROOT/bin:$PATH
    eval "$(pyenv init -)"
    if which pyenv-virtualenv-init > /dev/null; then
        eval "$(pyenv virtualenv-init -)";
    fi
fi

[ -d $HOME/.poetry ] && export PATH=$HOME/.poetry/bin:$PATH

if which pipenv > /dev/null; then
    export PIPENV_VENV_IN_PROJECT=1
fi

if [ -d $HOME/.sdkman ]; then
    export SDKMAN_DIR="$HOME/.sdkman"
    [ -s "$HOME/.sdkman/bin/sdkman-init.sh" ] && source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

if which jenv > /dev/null; then
    export PATH="$HOME/.jenv/bin:$PATH"
    eval "$(jenv init -)"
fi

if which fzf > /dev/null; then
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border horizontal  --inline-info'
    export FZF_CTRL_R_OPTS="-i"
    export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
    if which fd > /dev/null; then
        export FZF_DEFAULT_COMMAND="fd . $HOME"
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND="fd -t d . $HOME"
    fi
fi

if [ -d $HOME/.zextras ]; then
    for i in $HOME/.zextras/*;
        source $i
fi

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform

export GPG_TTY=$TTY

[ -d $HOME/bin ] && export PATH=$HOME/bin:$PATH

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
