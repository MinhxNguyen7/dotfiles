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
# Format:
#   [model | ctx: XX% | tokens: NNNN]  user@host:cwd (branch)

ctx_part=""
if [ -n "$used_pct" ]; then
    ctx_part=$(printf "ctx: %.0f%%" "$used_pct")
else
    ctx_part="ctx: -"
fi

tokens_part=$(printf "tokens: %d" "$total_tokens")

printf '\033[01;36m[%s | %s | %s]\033[00m  \033[01;32m%s@%s\033[00m:\033[01;34m%s\033[01;33m%s\033[00m' \
    "$model" \
    "$ctx_part" \
    "$tokens_part" \
    "$user" \
    "$host" \
    "$short_cwd" \
    "$git_branch"
