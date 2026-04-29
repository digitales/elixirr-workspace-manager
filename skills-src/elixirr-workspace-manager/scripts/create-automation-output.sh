#!/usr/bin/env bash

set -euo pipefail

usage() {
  printf 'Usage: %s --client <client-slug> --project <project-slug> --automation <automation-name> --date <YYYY-MM-DD|YYYY-Www> [--root <root-dir>]\n' "$0" >&2
  exit 1
}

slugify() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

CLIENT_SLUG=""
PROJECT_SLUG=""
AUTOMATION_NAME=""
DATE_VALUE=""
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
    --automation)
      AUTOMATION_NAME="${2:-}"
      shift 2
      ;;
    --date)
      DATE_VALUE="${2:-}"
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

if [[ -z "$CLIENT_SLUG" || -z "$PROJECT_SLUG" || -z "$AUTOMATION_NAME" || -z "$DATE_VALUE" ]]; then
  usage
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(cd "$SCRIPT_DIR/../templates" && pwd)"
AUTOMATION_SLUG="$(slugify "$AUTOMATION_NAME")"

case "$AUTOMATION_SLUG" in
  standup-summary)
    TEMPLATE_FILE="$TEMPLATE_DIR/automation-standup-summary.md"
    ;;
  daily-bug-scan)
    TEMPLATE_FILE="$TEMPLATE_DIR/automation-daily-bug-scan.md"
    ;;
  issue-triage)
    TEMPLATE_FILE="$TEMPLATE_DIR/automation-issue-triage.md"
    ;;
  skill-progression-map)
    TEMPLATE_FILE="$TEMPLATE_DIR/automation-skill-progression-map.md"
    ;;
  weekly-engineering-summary)
    TEMPLATE_FILE="$TEMPLATE_DIR/automation-weekly-engineering-summary.md"
    ;;
  *)
    TEMPLATE_FILE="$TEMPLATE_DIR/automation-generic.md"
    ;;
esac

TARGET_DIR="$ROOT_DIR/clients/$CLIENT_SLUG/projects/$PROJECT_SLUG/outputs/automations/$AUTOMATION_SLUG"
TARGET_FILE="$TARGET_DIR/$DATE_VALUE.md"

mkdir -p "$TARGET_DIR"

if [[ ! -s "$TARGET_FILE" ]]; then
  sed \
    -e "s/{{CLIENT_NAME}}/$CLIENT_SLUG/g" \
    -e "s/{{PROJECT_NAME}}/$PROJECT_SLUG/g" \
    -e "s/{{AUTOMATION_NAME}}/$AUTOMATION_NAME/g" \
    -e "s/{{DATE}}/$DATE_VALUE/g" \
    "$TEMPLATE_FILE" > "$TARGET_FILE"
fi

printf 'Created automation output shell at %s\n' "$TARGET_FILE"
