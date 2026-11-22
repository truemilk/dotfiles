# PATH (Homebrew, ~/bin, ...) is set in conf.d/00-path.fish and mise is activated in
# conf.d/mise-activate.fish. Both run before this file, in that order, so mise's tools win.

if type -q hx
    set -gx EDITOR hx
else
    set -gx EDITOR vim
end


# Everything below only matters at a prompt. Non-interactive shells (fish -c, and fzf
# previews, which run through $SHELL -c) skip it.
if status is-interactive
    set -g fish_greeting

    if type -q zoxide
        zoxide init fish | source
    end

    if type -q fzf
        fzf --fish | source
        set -gx FZF_DEFAULT_OPTS "--height 40% --layout reverse --border=rounded --no-separator --info inline --preview-window down"
        set -g FZF_CTRL_R_OPTS "--with-nth 3.. --bind 'alt-t:change-with-nth(2..|1,3..|3..)'"
        set -g FZF_CTRL_T_OPTS "--walker-skip .git,node_modules,target --preview 'bat -n --color=always {}' --bind 'ctrl-/:change-preview-window(down|hidden|)'"
        set -g FZF_ALT_C_OPTS "--walker-skip .git,node_modules,target --preview 'lsd --tree --depth 2 --color always --icon never {}'"
    else
        echo "Install fzf, please."
    end

    abbr -a e $EDITOR

    abbr -a g lazygit
    abbr -a y yazi

    abbr -a l lsd
    abbr -a la lsd -A
    abbr -a ll lsd -Alg
    abbr -a lt lsd --tree

    abbr -a a 'abduco -e ^q -c'

    abbr --command git up pull --rebase --autostash
    abbr --command git lg log --pretty=oneline -n 20 --graph --abbrev-commit
    abbr --command git co checkout
    abbr --command git com checkout main
    abbr --command git cob checkout -b
    abbr --command git wtl worktree list
    abbr --command git wta worktree add
    abbr --command git wtr worktree remove
    abbr --command git wtp worktree prune
    abbr --command git done push -u origin HEAD
    abbr --command git undos reset --soft HEAD~1
    abbr --command git undom reset --mixed HEAD~1
    abbr --command git cm --set-cursor=% -- 'commit -m "%"'
    abbr --add unset set --erase
    abbr -a L --position anywhere --set-cursor "% | less"
    abbr -a CP --position anywhere --set-cursor "% | pbcopy"

    set -g fish_transient_prompt 1

    starship init fish | source
end
