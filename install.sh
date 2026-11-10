#!/bin/sh
# Links this repository into the home directory so agents find it.
# Safe to run repeatedly.
set -e

repo="$(cd "$(dirname "$0")" && pwd)"

link() {
  target="$1"
  path="$2"
  if [ -e "$path" ] && [ ! -L "$path" ]; then
    backup="$path.bak.$(date +%Y%m%d%H%M%S)"
    mv "$path" "$backup"
    echo "moved: $path -> $backup"
  fi
  mkdir -p "$(dirname "$path")"
  ln -sfn "$target" "$path"
  echo "$path -> $target"
}

link "$repo/.agents" "$HOME/.agents"
link "$repo/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
link "$repo/.claude/skills" "$HOME/.claude/skills"
