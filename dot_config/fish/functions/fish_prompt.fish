function fish_prompt
    # Transient rendering: frozen into scrollback after the command runs
    if test "$argv[1]" = --final-rendering
        set -l last_status $status
        if test $last_status -ne 0
            set_color red
        else
            set_color green
        end
        printf '❯ '
        set_color normal
        return
    end

    set -l last_status $status
    set -l cwd (__git_prompt_pwd)

    # --- Current folder ---
    set_color blue
    printf '%s' $cwd
    set_color normal

    # --- Git info ---
    set -l git_info (__fish_git_prompt 2>/dev/null)
    if test -n "$git_info"
        set -l branch (git branch --show-current 2>/dev/null)
        set -l detached 0
        if test -z "$branch"
            set detached 1
            set branch (git rev-parse --short HEAD 2>/dev/null)
        end
        set -l inside (git rev-parse --is-inside-work-tree 2>/dev/null)

        if test "$inside" = true
            set -l changes ""
            set -l added 0
            set -l modified 0
            set -l deleted 0
            set -l untracked 0

            # parse git status --porcelain for counts
            for line in (git status --porcelain 2>/dev/null)
                set -l x (string sub -l 1 -- $line)
                set -l y (string sub -s 2 -l 1 -- $line)
                if test "$x" = "?"
                    set untracked (math $untracked + 1)
                else
                    if test "$x" = D; or test "$y" = D
                        set deleted (math $deleted + 1)
                    else if test "$x" = A; or test "$y" = A
                        set added (math $added + 1)
                    else if test "$x" != " "; or test "$y" != " "
                        set modified (math $modified + 1)
                    end
                end
            end

            if test $modified -gt 0
                set changes "$changes ~$modified"
            end
            if test $added -gt 0
                set changes "$changes +$added"
            end
            if test $deleted -gt 0
                set changes "$changes -$deleted"
            end
            if test $untracked -gt 0
                set changes "$changes ?$untracked"
            end

            # stash count
            set -l stash_count (git stash list 2>/dev/null | count)
            if test $stash_count -gt 0
                set changes "$changes \$$stash_count"
            end

            # ahead/behind vs upstream
            set -l remote (git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
            set -l ab ""
            if test -n "$remote"
                set -l counts (git rev-list --left-right --count @{u}...HEAD 2>/dev/null)
                if test (count $counts) -eq 2
                    if test $counts[1] -gt 0
                        set ab "$ab▼$counts[1]"
                    end
                    if test $counts[2] -gt 0
                        set ab "$ab▲$counts[2]"
                    end
                end
            end

            set_color brmagenta
            if test $detached -eq 1
                set_color bryellow
                printf ' (detached:%s)' "$branch"
                set_color brmagenta
            else
                printf ' %s' "$branch"
            end
            if test -n "$remote"
                printf '*'
            end
            if test -n "$changes"
                set_color yellow
                printf '%s' "$changes"
            end
            if test -n "$ab"
                set_color cyan
                printf ' %s' "$ab"
            end
            set_color normal
        end
    end

    # --- Prompt char (second line) ---
    printf '\n'
    if test $last_status -ne 0
        set_color red
    else
        set_color green
    end
    printf '❯ '
    set_color normal
end
