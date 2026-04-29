#!/usr/bin/env bash

set -euo pipefail

usage() {
  printf 'Usage: %s --client <client-slug> --meeting <meeting-name> --date <YYYY-MM-DD> [--project <project-slug>] [--scope recurring|adhoc|project] [--root <root-dir>]\n' "$0" >&2
  exit 1
}

slugify() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

CLIENT_SLUG=""
PROJECT_SLUG=""
MEETING_NAME=""
DATE_VALUE=""
SCOPE=""
ROOT_DIR="$HOME/Documents/elixirr"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --client)
      CLIENT_SLUG="${2:-}"
      shift 2
      ;;
    --project)
      PROJECT_SLUG="${2:-}"
      shift 2
      ;;
    --meeting)
      MEETING_NAME="${2:-}"
      shift 2
      ;;
    --date)
      DATE_VALUE="${2:-}"
      shift 2
      ;;
    --scope)
      SCOPE="${2:-}"
      shift 2
      ;;
    --root)
      ROOT_DIR="${2:-}"
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

if [[ -z "$CLIENT_SLUG" || -z "$MEETING_NAME" || -z "$DATE_VALUE" ]]; then
  usage
fi

if [[ -n "$PROJECT_SLUG" && -z "$SCOPE" ]]; then
  SCOPE="project"
fi

if [[ -z "$SCOPE" ]]; then
  SCOPE="recurring"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(cd "$SCRIPT_DIR/../templates" && pwd)"
MEETING_SLUG="$(slugify "$MEETING_NAME")"

case "$SCOPE" in
  recurring)
    TARGET_DIR="$ROOT_DIR/clients/$CLIENT_SLUG/meetings/recurring/$MEETING_SLUG"
    TARGET_FILE="$TARGET_DIR/$DATE_VALUE.md"
    TEMPLATE_FILE="$TEMPLATE_DIR/meeting-note.md"
    PROJECT_NAME_VALUE="none"
    ;;
  adhoc)
    TARGET_DIR="$ROOT_DIR/clients/$CLIENT_SLUG/meetings/ad-hoc"
    TARGET_FILE="$TARGET_DIR/$DATE_VALUE-$MEETING_SLUG.md"
    TEMPLATE_FILE="$TEMPLATE_DIR/meeting-note.md"
    PROJECT_NAME_VALUE="none"
    ;;
  project)
    if [[ -z "$PROJECT_SLUG" ]]; then
      printf 'Project scope requires --project <project-slug>\n' >&2
      exit 1
    fi
    TARGET_DIR="$ROOT_DIR/clients/$CLIENT_SLUG/projects/$PROJECT_SLUG/meetings/$MEETING_SLUG"
    TARGET_FILE="$TARGET_DIR/$DATE_VALUE.md"
    TEMPLATE_FILE="$TEMPLATE_DIR/project-meeting-note.md"
    PROJECT_NAME_VALUE="$PROJECT_SLUG"
    ;;
  *)
    printf 'Invalid scope: %s\n' "$SCOPE" >&2
    exit 1
    ;;
esac

mkdir -p "$TARGET_DIR"

if [[ ! -f "$TARGET_FILE" ]]; then
  sed \
    -e "s/{{CLIENT_NAME}}/$CLIENT_SLUG/g" \
    -e "s/{{PROJECT_NAME}}/$PROJECT_NAME_VALUE/g" \
    -e "s/{{MEETING_NAME}}/$MEETING_NAME/g" \
    -e "s/{{DATE}}/$DATE_VALUE/g" \
    "$TEMPLATE_FILE" > "$TARGET_FILE"
fi

printf 'Created meeting note at %s\n' "$TARGET_FILE"
