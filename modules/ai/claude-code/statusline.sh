# shellcheck disable=SC2239
#!@bash@
input=$(cat)

user=$(whoami)
host=$(hostname -s)
cwd=$(@jq@ -r '.workspace.current_dir // .cwd' <<<"$input")
model=$(@jq@ -r '.model.display_name // empty' <<<"$input")
used_pct=$(@jq@ -r '.context_window.used_percentage // empty' <<<"$input")
five_h=$(@jq@ -r '.rate_limits.five_hour.used_percentage // empty' <<<"$input")
five_h_reset=$(@jq@ -r '.rate_limits.five_hour.resets_at // empty' <<<"$input")
seven_d=$(@jq@ -r '.rate_limits.seven_day.used_percentage // empty' <<<"$input")
seven_d_reset=$(@jq@ -r '.rate_limits.seven_day.resets_at // empty' <<<"$input")
vim_mode=$(@jq@ -r '.vim.mode // empty' <<<"$input")

short_cwd="${cwd/#$HOME/\~}"

git_branch=""
if @git@ -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    git_branch=$(GIT_OPTIONAL_LOCKS=0 @git@ -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
                 || GIT_OPTIONAL_LOCKS=0 @git@ -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

RESET='\033[0m'
BOLD='\033[1m'
FG_YELLOW='\033[33m'
FG_CYAN='\033[36m'
FG_GREEN='\033[32m'
FG_BLUE='\033[34m'
FG_MAGENTA='\033[35m'
FG_RED='\033[31m'

pct_color() {
    local p
    p=$(printf '%.0f' "${1:-0}")
    if   [ "$p" -ge 80 ]; then printf '%s' "$FG_RED"
    elif [ "$p" -ge 50 ]; then printf '%s' "$FG_MAGENTA"
    else                       printf '%s' "$FG_GREEN"
    fi
}

progress_bar() {
    local pct filled empty bar i
    pct=$(printf '%.0f' "${1:-0}")
    filled=$(( pct * 10 / 100 ))
    empty=$(( 10 - filled ))
    bar=""
    for (( i=0; i<filled; i++ )); do bar+='█'; done
    for (( i=0; i<empty;  i++ )); do bar+='░'; done
    printf '%s%s%s' "$(pct_color "$pct")" "$bar" "$RESET"
}

fmt_reset() {
    local diff=$(( ${1:-0} - $(date +%s) ))
    if   [ "$diff" -le 0     ]; then printf "now"
    elif [ "$diff" -lt 3600  ]; then printf "%dm"    $(( diff / 60 ))
    elif [ "$diff" -lt 86400 ]; then printf "%dh%dm" $(( diff / 3600 )) $(( (diff % 3600) / 60 ))
    else                              printf "%dd%dh" $(( diff / 86400 )) $(( (diff % 86400) / 3600 ))
    fi
}

parts=""
parts+=$(printf "${FG_YELLOW}${BOLD}%s${RESET}${FG_YELLOW}@%s${RESET}" "$user" "$host")
parts+=$(printf " ${FG_CYAN}%s${RESET}" "$short_cwd")
if [ -n "$git_branch" ]; then
    parts+=$(printf " ${FG_GREEN}(%s)${RESET}" "$git_branch")
fi
if [ -n "$model" ]; then
    parts+=$(printf " ${FG_BLUE}[%s]${RESET}" "$model")
fi
if [ -n "$used_pct" ]; then
    col=$(pct_color "$used_pct")
    parts+=$(printf " ctx:%s %s%.0f%%${RESET}" "$(progress_bar "$used_pct")" "$col" "$used_pct")
fi
if [ -n "$five_h" ]; then
    col=$(pct_color "$five_h")
    reset_str=""
    [ -n "$five_h_reset" ] && reset_str=$(printf " ${FG_CYAN}(%s)${RESET}" "$(fmt_reset "$five_h_reset")")
    parts+=$(printf " 5h:%s %s%.0f%%${RESET}%s" "$(progress_bar "$five_h")" "$col" "$five_h" "$reset_str")
fi
if [ -n "$seven_d" ]; then
    col=$(pct_color "$seven_d")
    reset_str=""
    [ -n "$seven_d_reset" ] && reset_str=$(printf " ${FG_BLUE}(%s)${RESET}" "$(fmt_reset "$seven_d_reset")")
    parts+=$(printf " 7d:%s %s%.0f%%${RESET}%s" "$(progress_bar "$seven_d")" "$col" "$seven_d" "$reset_str")
fi
if [ -n "$vim_mode" ]; then
    parts+=$(printf " ${FG_MAGENTA}[%s]${RESET}" "$vim_mode")
fi

printf "%b\n" "$parts"
