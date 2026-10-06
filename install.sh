#!/bin/sh
# Links this repository into the home directory so agents find it.
# Safe to run repeatedly.
set -e

repo="$(cd "$(dirname "$0")" && pwd)"

link() {
  target="$1"
  path="$2"
  if [ -e "$path" ] && [ ! -L "$path" ]; then
    echo "skip: $path exists and is not a symlink" >&2
    return
  fi
  mkdir -p "$(dirname "$path")"
  ln -sfn "$target" "$path"
  echo "$path -> $target"
}

link "$repo/.agents" "$HOME/.agents"
link "$repo/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
link "$repo/.claude/skills" "$HOME/.claude/skills"
