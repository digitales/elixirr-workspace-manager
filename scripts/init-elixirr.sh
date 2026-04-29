#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="${1:-$HOME/Documents/elixirr}"

mkdir -p "$ROOT_DIR/shared/templates"
mkdir -p "$ROOT_DIR/shared/prompts"
mkdir -p "$ROOT_DIR/shared/reference"
mkdir -p "$ROOT_DIR/clients"
mkdir -p "$ROOT_DIR/internal/context"
mkdir -p "$ROOT_DIR/internal/meetings"
mkdir -p "$ROOT_DIR/internal/projects"

printf 'Initialized elixirr workspace at %s\n' "$ROOT_DIR"
