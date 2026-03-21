if test (count $argv) -lt 1; or string match -q -- '--help' $argv[1]; or string match -q -- '-h' $argv[1]
    echo "Usage: rgf QUERY"
    echo ""
    echo "Search with ripgrep, pick with fzf, open in nvim at matched line."
    return 0
end

set -l query (string join " " -- $argv)

set -l selected (
    rg --line-number --column --no-heading --smart-case --color=always -- "$query" |
    fzf --ansi \
        --delimiter ":" \
        --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' \
        --preview-window 'right,60%,border-left,+{2}+3/3'
)

if test -z "$selected"
    return 0
end

set -l clean (string replace -r '\x1b\[[0-9;]*m' '' -- "$selected")
set -l parts (string split -m 3 ":" -- "$clean")
set -l file "$parts[1]"
set -l line "$parts[2]"

if test -n "$file"; and test -n "$line"
    nvim +"$line" -- "$file"
end
