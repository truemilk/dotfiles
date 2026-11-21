function __git_prompt_pwd --description "prompt_pwd: full path if 3 dirs or less; else shorten to 1 char except git root and current folder"
    set -l cwd (pwd -P)
    set -l home $HOME

    # $HOME itself or below it; a bare "$home*" would also match siblings like /Users/ivan2.
    set -l cwd_disp $cwd
    if test "$cwd" = "$home"; or string match -q -- "$home/*" $cwd
        set cwd_disp "~"(string replace -- "$home" "" $cwd)
    end

    set -l segments (string split / $cwd_disp)
    # Drop the empty leading segment from absolute paths like /tmp/..., but
    # remember it so it can be printed again.
    set -l prefix ""
    if test -z "$segments[1]"
        set -e segments[1]
        set prefix "/"
    end

    # Find the repo root's segment by position rather than name, so a parent
    # directory with the same name is not highlighted accidentally.
    set -l root_index 0
    set -l root (git rev-parse --show-toplevel 2>/dev/null)
    if test -n "$root"
        set -l root_disp $root
        if test "$root" = "$home"; or string match -q -- "$home/*" $root
            set root_disp "~"(string replace -- "$home" "" $root)
        end
        set -l root_segments (string split / $root_disp)
        if test -z "$root_segments[1]"
            set -e root_segments[1]
        end
        set root_index (count $root_segments)
    end

    set -l n (count $segments)
    set -l shorten 0
    if test $n -gt 3
        set shorten 1
    end

    printf '%s' "$prefix"
    # Counter instead of (seq ...): seq is an external process, spawned on every prompt.
    set -l i 0
    for segment in $segments
        set i (math $i + 1)
        if test $i -gt 1
            printf '/'
        end

        set -l displayed $segment
        if test $shorten -eq 1; and test $i -ne $root_index; and test $i -ne $n; and test "$segment" != "~"
            # Hidden dirs keep the dot plus one char (".c", not ".").
            if string match -q -- '.*' $segment
                set displayed (string sub -l 2 -- $segment)
            else
                set displayed (string sub -l 1 -- $segment)
            end
        end

        if test $i -eq $root_index
            set_color --bold
            printf '%s' "$displayed"
            set_color normal
            set_color blue
        else
            printf '%s' "$displayed"
        end
    end
end
