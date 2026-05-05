#!/usr/bin/env bash

set -euo pipefail

usage() {
  printf 'Usage: %s <source-file> [--root <root-dir>] [--dropzone <raw-meetings-dir>]\n' "$0" >&2
  exit 1
}

if [[ $# -lt 1 ]]; then
  usage
fi

SOURCE_FILE="$1"
shift

ROOT_DIR="$HOME/Documents/elixirr"
DROPZONE_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      ROOT_DIR="${2:-}"
      shift 2
      ;;
    --dropzone)
      DROPZONE_DIR="${2:-}"
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

if [[ ! -f "$SOURCE_FILE" ]]; then
  printf 'File not found: %s\n' "$SOURCE_FILE" >&2
  exit 1
fi

if [[ -z "$DROPZONE_DIR" ]]; then
  DROPZONE_DIR="$ROOT_DIR/raw-meetings"
fi

SOURCE_DIR_ABS="$(cd "$(dirname "$SOURCE_FILE")" && pwd)"
SOURCE_FILE_ABS="$SOURCE_DIR_ABS/$(basename "$SOURCE_FILE")"
DROPZONE_DIR_ABS="$(cd "$DROPZONE_DIR" && pwd)"

case "$SOURCE_FILE_ABS" in
  "$DROPZONE_DIR_ABS"/*) ;;
  *)
    printf 'Source file must be inside %s\n' "$DROPZONE_DIR_ABS" >&2
    exit 1
    ;;
esac

relative_path="${SOURCE_FILE_ABS#"$DROPZONE_DIR_ABS"/}"
archive_target="$DROPZONE_DIR_ABS/archive/$relative_path"
archive_dir="$(dirname "$archive_target")"

mkdir -p "$archive_dir"
mv "$SOURCE_FILE_ABS" "$archive_target"

printf 'Archived raw meeting transcript to %s\n' "$archive_target"
