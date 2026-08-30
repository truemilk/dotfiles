/opt/homebrew/bin/brew shellenv | source
fish_add_path --move /opt/homebrew/bin /opt/homebrew/sbin

set -g fish_transient_prompt 1

mise activate fish | source
fish_add_path --move /opt/homebrew/opt/mise/bin

fish_add_path --move ~/.cargo/bin
fish_add_path --move ~/.local/bin
fish_add_path --move ~/bin

if type -q nvim
    set -gx EDITOR nvim
else
    set -gx EDITOR vim
end

abbr -a v nvim
abbr -a e emacs
abbr -a g lazygit
abbr -a y yazi

abbr -a la ls -aG
abbr -a ll ls -laG
abbr -a tree eza --tree
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
abbr -a cm --position anywhere --set-cursor=% -- 'commit -m "%"'
abbr --add unset set --erase
abbr -a L --position anywhere --set-cursor "% | less"
abbr -a CP --position anywhere --set-cursor "% | pbcopy"

if type -q fzf
    fzf --fish | source
    set FZF_DEFAULT_OPTS "--height 40% --layout reverse --border=rounded --no-separator --info inline --preview-window down"
    #set FZF_CTRL_R_OPTS "--bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'"
    set FZF_CTRL_R_OPTS "--with-nth 3.. --bind 'alt-t:change-with-nth(2..|1,3..|3..)'"
    #set FZF_CTRL_T_OPTS "--walker-skip .git,node_modules,target --preview 'bat -n --color=always {}' --bind 'ctrl-/:change-preview-window(down|hidden|)'"
    #set FZF_ALT_C_OPTS "--walker-skip .git,node_modules,target --preview 'eza --tree {}'"
else
    echo "Install fzf, please."
end
