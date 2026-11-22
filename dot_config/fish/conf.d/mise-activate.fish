# Same name as Homebrew's /opt/homebrew/share/fish/vendor_conf.d/mise-activate.fish, so
# fish sources this file instead of that one and mise is activated exactly once.
# Must sort after 00-path.fish: mise prepends its paths, so whatever runs later and moves
# brew/~/bin to the front would shadow mise's tools. Absolute path: no PATH lookup needed.
set -l mise /opt/homebrew/opt/mise/bin/mise
if test -x $mise
    if status is-interactive
        $mise activate fish | source
    else
        # Non-interactive shells (fish -c, fzf previews, editor/tool subshells) never draw
        # a prompt, so the prompt hook is wasted; shims resolve tools per directory instead.
        $mise activate fish --shims | source
    end
end
