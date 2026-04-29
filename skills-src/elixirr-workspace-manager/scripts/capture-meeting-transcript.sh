#!/usr/bin/env bash

set -euo pipefail

usage() {
  printf 'Usage: %s --client <client-slug> --meeting <meeting-name> --date <YYYY-MM-DD> [--project <project-slug>] [--scope recurring|adhoc|project] [--root <root-dir>] [--transcript-file <path>]\n' "$0" >&2
  exit 1
}

CLIENT_SLUG=""
PROJECT_SLUG=""
MEETING_NAME=""
DATE_VALUE=""
SCOPE=""
ROOT_DIR="$HOME/Documents/elixirr"
TRANSCRIPT_FILE=""

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
    --transcript-file)
      TRANSCRIPT_FILE="${2:-}"
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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CREATE_SCRIPT="$SCRIPT_DIR/create-meeting-note.sh"

create_args=(
  --client "$CLIENT_SLUG"
  --meeting "$MEETING_NAME"
  --date "$DATE_VALUE"
  --root "$ROOT_DIR"
)

if [[ -n "$PROJECT_SLUG" ]]; then
  create_args+=(--project "$PROJECT_SLUG")
fi

if [[ -n "$SCOPE" ]]; then
  create_args+=(--scope "$SCOPE")
fi

create_output="$("$CREATE_SCRIPT" "${create_args[@]}")"

TARGET_FILE="${create_output#Created meeting note at }"

TRANSCRIPT_TEMP_FILE="$(mktemp)"

if [[ -n "$TRANSCRIPT_FILE" ]]; then
  cat "$TRANSCRIPT_FILE" > "$TRANSCRIPT_TEMP_FILE"
else
  cat > "$TRANSCRIPT_TEMP_FILE"
fi

TEMP_FILE="$(mktemp)"

awk -v transcript_file="$TRANSCRIPT_TEMP_FILE" '
  BEGIN {
    in_transcript = 0
    transcript_written = 0
  }
  /^## Transcript$/ {
    print
    print ""
    while ((getline line < transcript_file) > 0) {
      print line
    }
    close(transcript_file)
    in_transcript = 1
    transcript_written = 1
    next
  }
  {
    if (in_transcript == 1) {
      next
    }
    print
  }
  END {
    if (transcript_written == 0) {
      print ""
      print "## Transcript"
      print ""
      while ((getline line < transcript_file) > 0) {
        print line
      }
      close(transcript_file)
    }
  }
' "$TARGET_FILE" > "$TEMP_FILE"

mv "$TEMP_FILE" "$TARGET_FILE"
rm -f "$TRANSCRIPT_TEMP_FILE"

printf 'Captured transcript in %s\n' "$TARGET_FILE"
