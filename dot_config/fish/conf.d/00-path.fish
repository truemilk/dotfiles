# PATH setup, in one file so the order is explicit. Resulting precedence:
#
#   ~/bin → ~/.local/bin → mise → ~/.cargo/bin → Homebrew → system
#
# Each step prepends, so the steps run from lowest to highest priority. Step 3 has to come
# after mise activates: with mise's default `activate_aggressive = false`, entries prepended
# after activation stay ahead of mise's paths, even when its prompt/cd hook rewrites PATH.
# That only holds if those dirs were not on PATH at activation time, so don't add them earlier.
#
# --path edits PATH directly (no universal fish_user_paths). Missing dirs are skipped, so
# there's no need for existence checks.

# --- 1. Homebrew (lowest priority) -----------------------------------------------------------

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

# rustup's proxies sit behind mise, so a project that pins rust in mise.toml gets mise's toolchain.
fish_add_path --move --path ~/.cargo/bin

# --- 2. mise ---------------------------------------------------------------------------------

# Homebrew's /opt/homebrew/share/fish/vendor_conf.d/mise-activate.fish would run `mise activate`
# again later, after step 3. It skips activation when this is 0. Global, not exported.
set -g MISE_FISH_AUTO_ACTIVATE 0

# Absolute path, so no PATH lookup is needed.
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

# --- 3. User dirs (highest priority) ---------------------------------------------------------

fish_add_path --move --path ~/bin ~/.local/bin
