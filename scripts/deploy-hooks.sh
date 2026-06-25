#!/usr/bin/env bash
# deploy-hooks.sh — Install hooks from scripts/hooks/ to global location.
#
# This makes the standards repo the authoritative source for git hooks.
# Run after updating hooks in scripts/hooks/ to deploy system-wide.

set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "$0")/hooks" && pwd)"
TARGET_DIR="${HOME}/.config/git/ai-commit-hooks"

if [ ! -d "$SOURCE_DIR" ]; then
  echo "ERROR: Source hooks directory not found: $SOURCE_DIR" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"

echo "Deploying hooks from $SOURCE_DIR → $TARGET_DIR"
echo ""

count=0
for hook in "$SOURCE_DIR"/*; do
  hook_name="$(basename "$hook")"
  target="$TARGET_DIR/$hook_name"

  install -m 0755 "$hook" "$target"
  echo "  Installed: $hook_name"
  count=$((count + 1))
done

echo ""
echo "Done. $count hooks deployed."
echo ""
echo "Current global hooksPath: $(git config --global core.hooksPath 2>/dev/null || echo '(not set)')"
echo "To set: git config --global core.hooksPath '$TARGET_DIR'"
