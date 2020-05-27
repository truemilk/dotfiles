if which vim > /dev/null; then
    export EDITOR="vim"
else
    export EDITOR="vi"
fi

alias v="$EDITOR"
