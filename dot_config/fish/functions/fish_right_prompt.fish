function fish_right_prompt
    # Transient: show chezmoi/AWS info only on the active prompt,
    # not in scrollback
    if test "$argv[1]" = --final-rendering
        return
    end

    set -l parts

    # --- Chezmoi indicator ---
    # Once you visit the chezmoi source dir during this shell session,
    # the marker stays on until the shell exits.
    # Source path looked up once per shell: ~18 ms per call, and it doesn't change
    # during a session.
    if not set -q __chezmoi_source
        set -g __chezmoi_source ""
        command -q chezmoi
        and set __chezmoi_source "$(chezmoi source-path 2>/dev/null)"
    end
    if test -n "$__chezmoi_source"; and test "$PWD" = "$__chezmoi_source"
        set -g __in_chezmoi 1
    end
    if set -q __in_chezmoi
        set -a parts (set_color brgreen)'chezmoi'(set_color normal)
    end

    # --- AWS info ---
    if set -q AWS_PROFILE
        set -l aws (set_color FF8800)'aws:'"$AWS_PROFILE"
        if set -q AWS_REGION
            set aws $aws(set_color FF8800)' @'"$AWS_REGION"
        end
        set -a parts $aws(set_color normal)
    else if set -q AWS_REGION
        set -a parts (set_color FF8800)'@'"$AWS_REGION"(set_color normal)
    end

    printf '%s' (string join '  ' -- $parts)
end
