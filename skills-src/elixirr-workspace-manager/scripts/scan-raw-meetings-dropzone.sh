#!/usr/bin/env bash

set -euo pipefail

usage() {
  printf 'Usage: %s [--root <root-dir>] [--dropzone <raw-meetings-dir>]\n' "$0" >&2
  exit 1
}

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

if [[ -z "$DROPZONE_DIR" ]]; then
  DROPZONE_DIR="$ROOT_DIR/raw-meetings"
fi

mkdir -p "$DROPZONE_DIR" "$DROPZONE_DIR/archive"

client_root="$ROOT_DIR/clients"
client_slugs=()

if [[ -d "$client_root" ]]; then
  while IFS= read -r slug; do
    client_slugs+=("$slug")
  done < <(find "$client_root" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | awk '{ print length, $0 }' | sort -rn | cut -d" " -f2-)
fi

date_from_mtime() {
  local file_path="$1"
  stat -f "%Sm" -t "%Y-%m-%d" "$file_path"
}

trim_hyphens() {
  printf '%s' "$1" | sed -E 's/^-+//; s/-+$//'
}

infer_from_filename() {
  local stem="$1"
  local matched_client=""
  local matched_meeting="$stem"

  for client_slug in "${client_slugs[@]}"; do
    if [[ "$stem" == "$client_slug" ]]; then
      matched_client="$client_slug"
      matched_meeting=""
      break
    fi

    if [[ "$stem" == "$client_slug-"* ]]; then
      matched_client="$client_slug"
      matched_meeting="${stem#"$client_slug"}"
      matched_meeting="$(trim_hyphens "$matched_meeting")"
      break
    fi
  done

  printf '%s\t%s\n' "$matched_client" "$matched_meeting"
}

printf 'source_path\tclient_slug\tmeeting_name\tdate\tscope\tarchive_path\tinference\n'

while IFS= read -r source_file; do
  relative_path="${source_file#"$DROPZONE_DIR"/}"
  parent_dir="$(dirname "$relative_path")"
  basename_md="$(basename "$source_file")"
  stem="${basename_md%.md}"
  stem_without_date="$stem"
  meeting_date=""
  inference_notes=()

  if [[ "$relative_path" == archive/* ]]; then
    continue
  fi

  if [[ "$stem" =~ ^(.+)-([0-9]{4}-[0-9]{2}-[0-9]{2})$ ]]; then
    stem_without_date="${BASH_REMATCH[1]}"
    meeting_date="${BASH_REMATCH[2]}"
    inference_notes+=("date:filename")
  else
    meeting_date="$(date_from_mtime "$source_file")"
    inference_notes+=("date:mtime")
  fi

  client_slug=""
  meeting_name="$stem_without_date"

  if [[ "$parent_dir" != "." ]]; then
    parent_slug="${parent_dir%%/*}"
    if [[ -d "$client_root/$parent_slug" ]]; then
      client_slug="$parent_slug"
      meeting_name="$stem_without_date"
      inference_notes+=("client:folder")
    elif [[ "$parent_slug" == "internal" ]]; then
      client_slug="internal"
      meeting_name="$stem_without_date"
      inference_notes+=("client:folder-internal")
    else
      inference_notes+=("client:folder-unmatched")
    fi
  fi

  if [[ -z "$client_slug" ]]; then
    inferred_values="$(infer_from_filename "$stem_without_date")"
    inferred_client="${inferred_values%%$'\t'*}"
    inferred_meeting="${inferred_values#*$'\t'}"

    if [[ -n "$inferred_client" ]]; then
      client_slug="$inferred_client"
      meeting_name="$inferred_meeting"
      inference_notes+=("client:filename")
    else
      client_slug="internal"
      meeting_name="$stem_without_date"
      inference_notes+=("client:fallback-internal")
    fi
  fi

  meeting_name="$(trim_hyphens "$meeting_name")"
  if [[ -z "$meeting_name" ]]; then
    meeting_name="general"
    inference_notes+=("meeting:general")
  fi

  archive_path="$DROPZONE_DIR/archive/$relative_path"
  inference_value="$(IFS=,; printf '%s' "${inference_notes[*]}")"

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$source_file" \
    "$client_slug" \
    "$meeting_name" \
    "$meeting_date" \
    "recurring" \
    "$archive_path" \
    "$inference_value"
done < <(find "$DROPZONE_DIR" -mindepth 1 -maxdepth 2 -type f -name '*.md' | sort)
