#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  printf 'Usage: %s <manual-export-file>\n' "$0" >&2
  exit 1
fi

SOURCE_FILE="$1"

if [[ ! -f "$SOURCE_FILE" ]]; then
  printf 'File not found: %s\n' "$SOURCE_FILE" >&2
  exit 1
fi

SOURCE_DIR="$(cd "$(dirname "$SOURCE_FILE")" && pwd)"
ARCHIVE_DIR="$SOURCE_DIR/archive"
BASENAME="$(basename "$SOURCE_FILE")"

mkdir -p "$ARCHIVE_DIR"
mv "$SOURCE_FILE" "$ARCHIVE_DIR/$BASENAME"

printf 'Archived manual export to %s\n' "$ARCHIVE_DIR/$BASENAME"
