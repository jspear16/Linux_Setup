#!/usr/bin/env bash
#
# init.sh — link this repo's Claude config into ~/.claude/ on a fresh machine.
#
# Creates a symlink in ~/.claude/ for each config item below, pointing back to
# the copy that lives in this repo. Any existing file/link is moved aside to a
# timestamped backup first, so running this repeatedly is safe.
#
# Usage:  ./init.sh

set -euo pipefail

# The repo's claude/ directory is wherever this script lives.
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.claude"

# Config items to link. Each is a path relative to both dirs.
# Add a line here for anything new you want synced across machines.
ITEMS=(
	CLAUDE.md
	settings.json
	statusline.sh
	skills
)

mkdir -p "$TARGET_DIR"
backup_suffix="backup.$(date +%Y%m%d-%H%M%S)"

for item in "${ITEMS[@]}"; do
	source="$SOURCE_DIR/$item"
	target="$TARGET_DIR/$item"

	if [ ! -e "$source" ]; then
		echo "skip  $item — not present in repo"
		continue
	fi

	# Already pointing where we want? Nothing to do.
	if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$(readlink -f "$source")" ]; then
		echo "ok    $item — already linked"
		continue
	fi

	# Something else is in the way — move it aside before linking.
	if [ -e "$target" ] || [ -L "$target" ]; then
		mv "$target" "$target.$backup_suffix"
		echo "backup $item -> $(basename "$target.$backup_suffix")"
	fi

	ln -s "$source" "$target"
	echo "link  $item -> $source"
done

echo "Done. Claude config linked into $TARGET_DIR"
