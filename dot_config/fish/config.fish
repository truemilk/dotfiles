/opt/homebrew/bin/brew shellenv | source
fish_add_path --move /opt/homebrew/bin /opt/homebrew/sbin

mise activate fish | source
fish_add_path --move /opt/homebrew/opt/mise/bin

if type -q /opt/homebrew/bin/go
    set -gx GOPATH $HOME/go
    set -gx GOROOT /usr/local/opt/go/libexec
    fish_add_path --move $GOPATH/bin
    fish_add_path --move $GOROOT/bin
else
    echo "Golang is not installed from Homebrew"
end

fish_add_path --move ~/.cargo/bin

fish_add_path --move ~/.local/bin
fish_add_path --move ~/bin

if type -q hx
    set -gx EDITOR hx
else
    set -gx EDITOR vim
end

abbr -a gg lazygit
abbr -a yy yazi

abbr -a la ls -aG
abbr -a ll ls -laG

abbr -a tree eza --tree --level

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

set -gx HOMEBREW_NO_ENV_HINTS 1

atuin init fish --disable-up-arrow | source
starship init fish | source
