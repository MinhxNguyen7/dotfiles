#!/usr/bin/env bash
# Claude Code status line command
# Reads JSON from stdin and outputs a formatted status line

input=$(cat)

# --- Model info ---
model=$(echo "$input" | jq -r '.model.display_name // .model.id // "unknown"')

# --- Context window ---
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
total_tokens=$(( total_input + total_output ))
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')

# --- Usage (cost + rate limits) ---
cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
five_h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# --- PS1-derived prompt (user@host:cwd (git-branch)) ---
user=$(whoami)
host=$(hostname -s)
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // empty')
[ -z "$cwd" ] && cwd=$(pwd)

# Shorten home dir to ~
home_dir="$HOME"
short_cwd="${cwd/#$home_dir/\~}"

# Git branch (skip optional locks)
git_branch=""
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    git_branch=$(git -C "$cwd" --no-optional-locks branch 2>/dev/null | sed -n 's/^\* \(.*\)/ (\1)/p')
fi

# --- Assemble status line ---
# Format (three lines):
#   line 1: cwd (branch)
#   line 2: model | ctx: XX% | tokens: NNNN
#   line 3: cost: $X.XX | 5h: NN% | 7d: NN%

# Context: "Context: <used>k/<avail>k <bar>" (used = input tokens in context)
if [ -n "$used_pct" ]; then
    ctx_pct_int=$(printf '%.0f' "$used_pct")
else
    ctx_pct_int=0
fi
used_k=$(( total_input / 1000 ))
avail_k=$(( ctx_size / 1000 ))

# Fill bar for a percentage: ━ filled, ─ empty (width 10)
# Horizontal line glyphs stay within normal text height (no taller line).
make_bar() {
    local pct_int=$1 width=10 i filled empty bar=""
    filled=$(( pct_int * width / 100 ))
    [ "$filled" -lt 0 ] && filled=0
    [ "$filled" -gt "$width" ] && filled=$width
    empty=$(( width - filled ))
    for ((i = 0; i < filled; i++)); do bar+="━"; done
    for ((i = 0; i < empty;  i++)); do bar+="─"; done
    printf '%s' "$bar"
}

# Usage line parts: rate-limit bars first, cost at end (skip absent)
usage_parts=()
if [ -n "$five_h" ]; then
    fi_int=$(printf '%.0f' "$five_h")
    usage_parts+=("$(printf '5h: %s %d%%' "$(make_bar "$fi_int")" "$fi_int")")
fi
if [ -n "$seven_d" ]; then
    sd_int=$(printf '%.0f' "$seven_d")
    usage_parts+=("$(printf '7d: %s %d%%' "$(make_bar "$sd_int")" "$sd_int")")
fi
[ -n "$cost_usd" ] && usage_parts+=("$(printf '$%.2f' "$cost_usd")")

# --- Colors ---
ESC=$'\033'
C_CYAN="${ESC}[01;36m"     # model + context
C_MAGENTA="${ESC}[00;35m"  # usage
C_WHITE="${ESC}[01;37m"    # dividers
C_RESET="${ESC}[00m"
DIV="${C_WHITE} | ${C_RESET}"

# Line 1: user@host:path (branch) -- PS1 style
printf '\033[01;32m%s@%s\033[00m:\033[01;34m%s\033[01;33m%s\033[00m\n' \
    "$user" \
    "$host" \
    "$short_cwd" \
    "$git_branch"

# Line 2: model + context bar (cyan), usage (magenta), white dividers
ctx_bar=$(make_bar "$ctx_pct_int")
line2="${C_CYAN}${model}${C_RESET}${DIV}${C_CYAN}Context: ${used_k}k/${avail_k}k ${ctx_bar}${C_RESET}"
for p in "${usage_parts[@]}"; do
    line2+="${DIV}${C_MAGENTA}${p}${C_RESET}"
done
printf '%s' "$line2"
