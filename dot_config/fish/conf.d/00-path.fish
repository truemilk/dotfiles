# PATH setup. Lives in conf.d rather than config.fish, and sorts before mise-activate.fish, so
# mise prepends its tool paths after this has run and they win over Homebrew's and ~/bin's.
# From config.fish, the `fish_add_path --move` calls below would push brew back ahead of mise.

# Static copy of `brew shellenv fish` (saves ~37 ms per shell, which every `fish -c` pays).
# Re-check against `brew shellenv fish` after major Homebrew updates.
if test -x /opt/homebrew/bin/brew
    set -gx HOMEBREW_PREFIX /opt/homebrew
    set -gx HOMEBREW_CELLAR /opt/homebrew/Cellar
    set -gx HOMEBREW_REPOSITORY /opt/homebrew
    fish_add_path --global --move --path /opt/homebrew/bin /opt/homebrew/sbin
    if test -n "$MANPATH"
        set -gx MANPATH (string replace --regex '^:*(.*?):*$' ':$1' -- "$MANPATH")
    end
    if not set -q INFOPATH
        set -g INFOPATH ''
    end
    # Guarded, unlike brew's own output, so nested shells don't stack duplicate entries.
    if not contains /opt/homebrew/share/info $INFOPATH
        set -gx INFOPATH /opt/homebrew/share/info $INFOPATH
    end
end

# --path edits PATH directly (no universal fish_user_paths);
# missing dirs are skipped, so no existence checks needed.
fish_add_path --move --path ~/bin ~/.local/bin ~/.cargo/bin
