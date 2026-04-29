#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 2 || $# -gt 3 ]]; then
  printf 'Usage: %s <client-slug> <project-slug> [root-dir]\n' "$0" >&2
  exit 1
fi

CLIENT_SLUG="$1"
PROJECT_SLUG="$2"
ROOT_DIR="${3:-$HOME/Documents/elixirr}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(cd "$SCRIPT_DIR/../templates" && pwd)"
PROJECT_DIR="$ROOT_DIR/clients/$CLIENT_SLUG/projects/$PROJECT_SLUG"
CONTEXT_DIR="$PROJECT_DIR/context"

mkdir -p "$CONTEXT_DIR"
mkdir -p "$PROJECT_DIR/working-memory"
mkdir -p "$PROJECT_DIR/meetings/general"
mkdir -p "$PROJECT_DIR/outputs/codex"
mkdir -p "$PROJECT_DIR/outputs/claude"
mkdir -p "$PROJECT_DIR/outputs/other-agents"
mkdir -p "$PROJECT_DIR/outputs/automations"
mkdir -p "$PROJECT_DIR/outputs/slack"
mkdir -p "$PROJECT_DIR/outputs/teams"
mkdir -p "$PROJECT_DIR/manual-exports/slack"
mkdir -p "$PROJECT_DIR/manual-exports/teams"
mkdir -p "$PROJECT_DIR/automations"

copy_template() {
  local source_file="$1"
  local target_file="$2"
  if [[ ! -f "$target_file" ]]; then
    sed \
      -e "s/{{CLIENT_NAME}}/$CLIENT_SLUG/g" \
      -e "s/{{PROJECT_NAME}}/$PROJECT_SLUG/g" \
      "$source_file" > "$target_file"
  fi
}

copy_template "$TEMPLATE_DIR/project-context-index.md" "$CONTEXT_DIR/index.md"
copy_template "$TEMPLATE_DIR/project.md" "$CONTEXT_DIR/project.md"
copy_template "$TEMPLATE_DIR/decisions.md" "$CONTEXT_DIR/decisions.md"
copy_template "$TEMPLATE_DIR/sources.md" "$CONTEXT_DIR/sources.md"
copy_template "$TEMPLATE_DIR/open-questions.md" "$CONTEXT_DIR/open-questions.md"
copy_template "$TEMPLATE_DIR/project-meeting-note.md" "$PROJECT_DIR/meetings/general/_template.md"
copy_template "$TEMPLATE_DIR/working-memory-current.md" "$PROJECT_DIR/working-memory/current.md"
copy_template "$TEMPLATE_DIR/working-memory-backlog.md" "$PROJECT_DIR/working-memory/backlog.md"
copy_template "$TEMPLATE_DIR/working-memory-risks.md" "$PROJECT_DIR/working-memory/risks.md"
copy_template "$TEMPLATE_DIR/working-memory-timeline.md" "$PROJECT_DIR/working-memory/timeline.md"
copy_template "$TEMPLATE_DIR/automations-notes.md" "$PROJECT_DIR/automations/notes.md"
copy_template "$TEMPLATE_DIR/automations-config.md" "$PROJECT_DIR/automations/config.md"

printf 'Created project scaffold at %s\n' "$PROJECT_DIR"
