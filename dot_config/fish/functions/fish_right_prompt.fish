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
    if test "$PWD" = (chezmoi source-path 2>/dev/null)
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
