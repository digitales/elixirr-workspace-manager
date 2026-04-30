#!/usr/bin/env bash

set -euo pipefail

usage() {
  printf 'Usage: %s --client <client-slug> --platform slack|teams --channel <channel-name> [--root <root-dir>]\n' "$0" >&2
  exit 1
}

slugify() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

CLIENT_SLUG=""
PLATFORM=""
CHANNEL_NAME=""
ROOT_DIR="$HOME/Documents/elixirr"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --client)
      CLIENT_SLUG="${2:-}"
      shift 2
      ;;
    --platform)
      PLATFORM="${2:-}"
      shift 2
      ;;
    --channel)
      CHANNEL_NAME="${2:-}"
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

if [[ -z "$CLIENT_SLUG" || -z "$PLATFORM" || -z "$CHANNEL_NAME" ]]; then
  usage
fi

if [[ "$PLATFORM" != "slack" && "$PLATFORM" != "teams" ]]; then
  printf 'Platform must be slack or teams\n' >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(cd "$SCRIPT_DIR/../templates" && pwd)"
CHANNEL_SLUG="$(slugify "$CHANNEL_NAME")"
CHANNEL_DIR="$ROOT_DIR/clients/$CLIENT_SLUG/$PLATFORM/channels/$CHANNEL_SLUG"

mkdir -p "$CHANNEL_DIR/manual-exports"
mkdir -p "$CHANNEL_DIR/manual-exports/archive"
mkdir -p "$CHANNEL_DIR/outputs"

TARGET_CONTEXT="$CHANNEL_DIR/context.md"
if [[ ! -s "$TARGET_CONTEXT" ]]; then
  sed \
    -e "s|{{CLIENT_NAME}}|$CLIENT_SLUG|g" \
    -e "s|{{CHANNEL_NAME}}|$CHANNEL_NAME|g" \
    -e "s|{{PLATFORM_NAME}}|$PLATFORM|g" \
    "$TEMPLATE_DIR/channel-context.md" > "$TARGET_CONTEXT"
fi

printf 'Created %s channel workspace at %s\n' "$PLATFORM" "$CHANNEL_DIR"
