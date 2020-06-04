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

alias ll="ls -l"
alias la="ls -A"

alias -g A="| awk"
alias -g R="| rg"
alias -g G="| grep --color"
alias -g L="| less"
alias -g F="| fzf"
alias -g C="| pbcopy"
alias -g V="| vim -"

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

#autoload -Uz vcs_info
#precmd () { vcs_info }
#setopt prompt_subst
#PS1='%F{cyan}%(5~|%-1~/…/%3~|%4~)%f${vcs_info_msg_0_} %F{magenta}%%%f '

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

if [ -d $HOME/.zextras ]; then
    for i in $HOME/.zextras/*;
        source $i
fi

[ -d $HOME/bin ] && export PATH=$HOME/bin:$PATH

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
