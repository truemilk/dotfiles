function fish_prompt
    # Must be the first statement: any command (even `test`) overwrites $status.
    set -l last_status $status

    # Transient rendering: frozen into scrollback after the command runs
    if test "$argv[1]" = --final-rendering
        if test $last_status -ne 0
            set_color red
        else
            set_color green
        end
        printf '❯ '
        set_color normal
        return
    end

    set -l cwd (__git_prompt_pwd)

    # --- Current folder ---
    set_color blue
    printf '%s' $cwd
    set_color normal

    # --- Git info ---
    # One status call yields branch, upstream, ahead/behind, stash count and file states
    # (porcelain v2). It fails outside a work tree, which is the "not in a repo" test.
    # --no-optional-locks keeps the prompt from taking index.lock, so it never collides
    # with a git command running at the same time (lazygit, an editor).
    set -l git_lines (git --no-optional-locks status --porcelain=v2 --branch --show-stash 2>/dev/null)
    if test $status -eq 0
        set -l branch
        set -l detached 0
        set -l has_upstream 0
        set -l ahead 0
        set -l behind 0
        set -l stash_count 0
        set -l added 0
        set -l modified 0
        set -l deleted 0
        set -l untracked 0

        for line in $git_lines
            switch $line
                case '# branch.head *'
                    set branch (string replace '# branch.head ' '' -- $line)
                case '# branch.ab *'
                    # Only printed when the upstream actually exists (not when it was deleted),
                    # which is exactly when the '*' marker and the counts should show.
                    set has_upstream 1
                    set -l ab_counts (string match -rg '^# branch\.ab \+(\d+) -(\d+)$' -- $line)
                    set ahead $ab_counts[1]
                    set behind $ab_counts[2]
                case '# stash *'
                    set stash_count (string replace '# stash ' '' -- $line)
                case '1 *' '2 *' 'u *'
                    # Changed, renamed/copied, unmerged: XY status letters at columns 3-4
                    # ('.' = unchanged in v2).
                    set -l xy (string sub -s 3 -l 2 -- $line)
                    if string match -q '*D*' -- $xy
                        set deleted (math $deleted + 1)
                    else if string match -q '*A*' -- $xy
                        set added (math $added + 1)
                    else
                        set modified (math $modified + 1)
                    end
                case '? *'
                    set untracked (math $untracked + 1)
            end
        end

        if test "$branch" = '(detached)'
            set detached 1
            # Extra process only while detached; --short picks a unique abbreviation.
            set branch (git rev-parse --short HEAD 2>/dev/null)
        end

        set -l changes ""
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
        if test $stash_count -gt 0
            set changes "$changes \$$stash_count"
        end

        set -l ab ""
        if test $behind -gt 0
            set ab "$ab▼$behind"
        end
        if test $ahead -gt 0
            set ab "$ab▲$ahead"
        end

        set_color brmagenta
        if test $detached -eq 1
            set_color bryellow
            printf ' (detached:%s)' "$branch"
            set_color brmagenta
        else
            printf ' %s' "$branch"
        end
        if test $has_upstream -eq 1
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
