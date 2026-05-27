#!/bin/sh
# Claude Code statusLine command
# Mirrors starship.toml visual style: blue dir, bright-black git, cyan git-status, purple model
# Context usage shown as a colored progress bar + percentage (primary info).

# ANSI colors (matches Starship palette)
BLUE='\033[34m'
BRIGHT_BLACK='\033[90m'
CYAN='\033[36m'
PURPLE='\033[35m'
PINK='\033[38;5;218m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

input=$(cat)

# --- Required: model name (purple, matches ❯ character color) ---
model=$(printf '%s' "$input" | jq -r '.model.display_name // .model.id // "unknown"')

# --- Required: cwd (blue, matches [directory] style=blue) ---
cwd=$(printf '%s' "$input" | jq -r '.cwd // .workspace.current_dir // ""')
# Abbreviate $HOME to ~
cwd=$(printf '%s' "$cwd" | sed "s|^$HOME|~|")
# Display: truncate to last 3 path segments (full $cwd kept for git detection below)
cwd_display=$(printf '%s' "$cwd" | awk -F/ '{ if (NF>4) printf "…/%s/%s/%s", $(NF-2),$(NF-1),$NF; else printf "%s", $0 }')

# --- Context usage: colored progress bar + percentage ---
ctx_bar=""
ctx_pct_str=""
used_pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used_pct" ]; then
  ctx_pct_str=$(printf '%.0f%%' "$used_pct")

  # Build 10-cell bar: filled = round(used_pct / 10), rest empty
  filled=$(printf '%.0f' "$(echo "$used_pct / 10" | bc -l 2>/dev/null || echo 0)")
  # Clamp to [0,10]
  [ "$filled" -lt 0 ] 2>/dev/null && filled=0
  [ "$filled" -gt 10 ] 2>/dev/null && filled=10
  empty=$((10 - filled))

  bar_filled=""
  i=0
  while [ "$i" -lt "$filled" ]; do
    bar_filled="${bar_filled}█"
    i=$((i + 1))
  done
  bar_empty=""
  i=0
  while [ "$i" -lt "$empty" ]; do
    bar_empty="${bar_empty}█"
    i=$((i + 1))
  done

  # Color by threshold: green <=50%, yellow 51-80%, red >80%
  _int_pct=$(printf '%.0f' "$used_pct")
  if [ "$_int_pct" -gt 80 ] 2>/dev/null; then
    bar_color="$RED"
  elif [ "$_int_pct" -gt 50 ] 2>/dev/null; then
    bar_color="$YELLOW"
  else
    bar_color="$GREEN"
  fi

  ctx_bar="${bar_color}${bar_filled}${DIM}${BRIGHT_BLACK}${bar_empty}${RESET}"
fi

# --- Git branch + repo root ---
# Resolve the repo top-level once ($_git_dir); empty when not in a repo, so it
# doubles as the existence check and is reused by the status block below.
git_branch=""
_git_dir=$(git -C "$(printf '%s' "$cwd" | sed "s|^~|$HOME|")" rev-parse --show-toplevel 2>/dev/null)
if [ -n "$_git_dir" ]; then
  _branch=$(git --git-dir="$_git_dir/.git" branch --show-current 2>/dev/null)
  [ -z "$_branch" ] && _branch=$(git --git-dir="$_git_dir/.git" rev-parse --short HEAD 2>/dev/null)
  git_branch="$_branch"
fi

# --- Git status (cyan with pink delimiters, matches [git_status]) ---
git_status_str=""
git_status_color="$CYAN"
if [ -n "$git_branch" ]; then
  # $_git_dir already resolved in the branch block above (reused, not recomputed)
  if [ -n "$_git_dir" ]; then
    _dirty=$(git --git-dir="$_git_dir/.git" --work-tree="$_git_dir" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    _stash=$(git --git-dir="$_git_dir/.git" stash list 2>/dev/null | wc -l | tr -d ' ')
    _ab=$(git --git-dir="$_git_dir/.git" rev-list --count --left-right "@{upstream}...HEAD" 2>/dev/null)
    _ahead=$(printf '%s' "$_ab" | awk '{print $2}')
    _behind=$(printf '%s' "$_ab" | awk '{print $1}')

    _parts=""
    [ "$_dirty" -gt 0 ] 2>/dev/null && _parts="*"
    [ "$_stash" -gt 0 ] 2>/dev/null && _parts="${_parts}≡"
    [ "${_ahead:-0}" -gt 0 ] 2>/dev/null && _parts="${_parts}⇡${_ahead}"
    [ "${_behind:-0}" -gt 0 ] 2>/dev/null && _parts="${_parts}⇣${_behind}"

    if [ -n "$_parts" ]; then
      git_status_str="$_parts"
      # Uncommitted changes (dirty working tree) -> yellow signal;
      # committed but ahead/behind/stash only -> calm cyan (no alarm)
      if [ "$_dirty" -gt 0 ] 2>/dev/null; then
        git_status_color="$YELLOW"
      else
        git_status_color="$CYAN"
      fi
    fi
  fi
fi

# --- Python virtualenv (dim, secondary info) ---
venv_str=""
if [ -n "$VIRTUAL_ENV" ]; then
  venv_str=$(basename "$VIRTUAL_ENV")
fi

# --- Assemble the line ---
# Three groups joined by a uniform separator; single spaces WITHIN each group.
#   location ( cwd  branch  (status) )  ·  model ( name (paren) )  ·  context ( bar pct )  [·  venv]
SEP=" ${DIM}${BRIGHT_BLACK}·${RESET} "

# Group: location — cwd (blue) + git branch + git status (bright-black)
g_loc=$(printf "${BLUE}%s${RESET}" "$cwd_display")
if [ -n "$git_branch" ]; then
  g_loc="${g_loc} $(printf "${CYAN}${BOLD}\356\202\240 %s${RESET}" "$git_branch")"
fi
if [ -n "$git_status_str" ]; then
  g_loc="${g_loc} $(printf "${git_status_color}(%s)${RESET}" "$git_status_str")"
fi

# Group: model — purple name + dim parenthetical (e.g. "Opus 4.7" + "(1M context)")
model_main=$(printf '%s' "$model" | sed -E 's/ *\(.*$//')
model_paren=$(printf '%s' "$model" | grep -oE '\([^)]*\)[[:space:]]*$' 2>/dev/null)
g_model=$(printf "${PURPLE}%s${RESET}" "$model_main")
if [ -n "$model_paren" ]; then
  g_model="${g_model} $(printf "${DIM}%s${RESET}" "$model_paren")"
fi

# Group: context — bar + percentage (one unit, single space; colored by threshold)
g_ctx=""
if [ -n "$ctx_bar" ]; then
  g_ctx="${ctx_bar} $(printf "${bar_color}%s${RESET}" "$ctx_pct_str")"
fi

# Group: lines changed this session — +adds (green) / -dels (red); omit when absent/zero
g_lines=""
_adds=$(printf '%s' "$input" | jq -r '.cost.total_lines_added // empty')
_dels=$(printf '%s' "$input" | jq -r '.cost.total_lines_removed // empty')
if [ -n "$_adds" ] && [ "$_adds" -gt 0 ] 2>/dev/null; then
  g_lines=$(printf "${GREEN}+%s${RESET}" "$_adds")
fi
if [ -n "$_dels" ] && [ "$_dels" -gt 0 ] 2>/dev/null; then
  [ -n "$g_lines" ] && g_lines="${g_lines} "
  g_lines="${g_lines}$(printf "${RED}−%s${RESET}" "$_dels")"
fi

# Group: venv — dim (secondary)
g_venv=""
if [ -n "$venv_str" ]; then
  g_venv=$(printf "${DIM}${BRIGHT_BLACK}%s${RESET}" "$venv_str")
fi

# Join non-empty groups with the uniform separator (location always present)
out="$g_loc"
[ -n "$g_model" ] && out="${out}${SEP}${g_model}"
[ -n "$g_ctx" ]   && out="${out}${SEP}${g_ctx}"
[ -n "$g_lines" ] && out="${out}${SEP}${g_lines}"
[ -n "$g_venv" ]  && out="${out}${SEP}${g_venv}"

printf '%b\n' "$out"
