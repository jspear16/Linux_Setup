#!/bin/bash
#
# Claude Code status line renderer.
# Reads the session JSON on stdin and prints two lines:
#   <home-relative dir>   <git branch|@sha><*-if-dirty>   <model>
#   <context used/total>   <session limit used, resets at HH:MM TZ Central>
#
# Percentages are colored green (<50%), amber (50-85%), or red (>85%).
#
# Registered via the "statusLine" block in ~/.claude/settings.json.

input=$(cat)

# Working directory: prefer workspace.current_dir, fall back to cwd, then $PWD.
dir=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')
[ -z "$dir" ] && dir="$PWD"

# Render the path home-relative (~/...).
case "$dir" in
	"$HOME") disp="~" ;;
	"$HOME"/*) disp="~${dir#"$HOME"}" ;;
	*) disp="$dir" ;;
esac

# ANSI colors.
dim=$'\033[2m'
cyan=$'\033[36m'
yellow=$'\033[33m'
green=$'\033[92m'
amber=$'\033[38;5;214m'
red=$'\033[91m'
reset=$'\033[0m'

# Color a percentage: green <50%, amber (yellow) 50-85%, red >85%.
pct_color() {
	awk -v p="$1" 'BEGIN { if (p > 85) print "red"; else if (p >= 50) print "yellow"; else print "green" }'
}

model_seg=""
model_name=$(printf '%s' "$input" | jq -r '.model.display_name // empty')
[ -n "$model_name" ] && model_seg="   ${dim}${model_name}${reset}"

git_seg=""
if git --no-optional-locks -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
	branch=$(git --no-optional-locks -C "$dir" branch --show-current 2>/dev/null)
	if [ -z "$branch" ]; then
		# Detached HEAD: show short SHA prefixed with @.
		sha=$(git --no-optional-locks -C "$dir" rev-parse --short HEAD 2>/dev/null)
		branch="@${sha}"
	fi
	# Dirty marker when there are uncommitted changes.
	dirty=""
	[ -n "$(git --no-optional-locks -C "$dir" status --porcelain 2>/dev/null)" ] && dirty="*"
	git_seg="   ${yellow}${branch}${dirty}${reset}"
fi

# Context window usage: tokens currently in context vs. the model's max window.
ctx_seg=""
used_tokens=$(printf '%s' "$input" | jq -r '.context_window.total_input_tokens // empty')
max_tokens=$(printf '%s' "$input" | jq -r '.context_window.context_window_size // empty')
used_pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')

# Format a raw token count as e.g. 12.3k or 1.2M for readability.
fmt_tokens() {
	awk -v n="$1" 'BEGIN {
		if (n >= 1000000) printf "%.1fM", n/1000000;
		else if (n >= 1000) printf "%.1fk", n/1000;
		else printf "%d", n;
	}'
}

if [ -n "$used_tokens" ] && [ -n "$max_tokens" ]; then
	used_fmt=$(fmt_tokens "$used_tokens")
	max_fmt=$(fmt_tokens "$max_tokens")
	if [ -n "$used_pct" ]; then
		pct_fmt=$(awk -v p="$used_pct" 'BEGIN { printf "%.0f", p }')
		case "$(pct_color "$used_pct")" in
			red) pct_color_code="$red" ;;
			yellow) pct_color_code="$amber" ;;
			*) pct_color_code="$green" ;;
		esac
		ctx_seg="${dim}ctx: ${used_fmt}/${max_fmt} (${pct_color_code}${pct_fmt}%${reset}${dim})${reset}"
	else
		ctx_seg="${dim}ctx: ${used_fmt}/${max_fmt}${reset}"
	fi
fi

# 5-hour session rate-limit usage (Pro/Max subscribers only; absent otherwise).
session_seg=""
session_pct=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
session_resets_at=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
if [ -n "$session_pct" ]; then
	session_pct_fmt=$(awk -v p="$session_pct" 'BEGIN { printf "%.0f", p }')
	case "$(pct_color "$session_pct")" in
		red) session_color_code="$red" ;;
		yellow) session_color_code="$amber" ;;
		*) session_color_code="$green" ;;
	esac
	session_seg="${dim}session: ${session_color_code}${session_pct_fmt}%${reset}${dim}"
	if [ -n "$session_resets_at" ]; then
		resets_fmt=$(TZ="America/Chicago" date -d "@${session_resets_at}" '+%-I:%M%P %Z' 2>/dev/null)
		[ -n "$resets_fmt" ] && session_seg="${session_seg} (resets ${resets_fmt})"
	fi
	session_seg="${session_seg}${reset}"
fi

line2=""
if [ -n "$ctx_seg" ] && [ -n "$session_seg" ]; then
	line2="${ctx_seg}   ${session_seg}"
else
	line2="${ctx_seg}${session_seg}"
fi

printf '%s%s%s%s%s\n' "${dim}${cyan}" "$disp" "$reset" "$git_seg" "$model_seg"
[ -n "$line2" ] && printf '%s\n' "$line2"
