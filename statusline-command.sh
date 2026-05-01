#!/bin/bash
input=$(cat)

# Current working directory (basename only)
cwd=$(echo "$input" | jq -r '.cwd // ""')
dir_name=$(basename "$cwd")

# Model display name
model=$(echo "$input" | jq -r '.model.display_name // ""')

# Effort level (not yet available in statusline JSON schema)
effort=""

# Context usage (pre-calculated percentage)
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Build output
# cwd (basename) in blue
printf "\033[01;34m%s\033[00m" "$dir_name"

# model in green
if [ -n "$model" ]; then
  printf "  \033[01;32m%s\033[00m" "$model"
fi

# effort in yellow
if [ -n "$effort" ]; then
  printf "  \033[0;33meffort:%s\033[00m" "$effort"
fi

# context usage
if [ -n "$used_pct" ]; then
  printf "  ctx:%.0f%%" "$used_pct"
fi
