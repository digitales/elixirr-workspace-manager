#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  printf 'Usage: %s <client-slug> [root-dir]\n' "$0" >&2
  exit 1
fi

CLIENT_SLUG="$1"
ROOT_DIR="${2:-$HOME/Documents/elixirr}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(cd "$SCRIPT_DIR/../templates" && pwd)"
CLIENT_DIR="$ROOT_DIR/clients/$CLIENT_SLUG"
CONTEXT_DIR="$CLIENT_DIR/context"

mkdir -p "$CONTEXT_DIR"
mkdir -p "$CLIENT_DIR/meetings/recurring"
mkdir -p "$CLIENT_DIR/meetings/ad-hoc"
mkdir -p "$CLIENT_DIR/projects"

copy_template() {
  local source_file="$1"
  local target_file="$2"
  if [[ ! -f "$target_file" ]]; then
    sed "s/{{CLIENT_NAME}}/$CLIENT_SLUG/g" "$source_file" > "$target_file"
  fi
}

copy_template "$TEMPLATE_DIR/client-context-index.md" "$CONTEXT_DIR/index.md"
copy_template "$TEMPLATE_DIR/client.md" "$CONTEXT_DIR/client.md"
copy_template "$TEMPLATE_DIR/people.md" "$CONTEXT_DIR/people.md"
copy_template "$TEMPLATE_DIR/preferences.md" "$CONTEXT_DIR/preferences.md"
copy_template "$TEMPLATE_DIR/commercial.md" "$CONTEXT_DIR/commercial.md"

printf 'Created client scaffold at %s\n' "$CLIENT_DIR"
