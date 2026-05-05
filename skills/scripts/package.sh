#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${SKILLS_ROOT}/.." && pwd)"

OUTPUT_DIR="${REPO_ROOT}/dist"
PACKAGE_NAME="elixirr-skills-package"

usage() {
  cat <<'EOF'
Create a distributable zip containing the Elixirr skills package.

Usage:
  bash ./skills/scripts/package.sh [options]

Options:
  --output-dir PATH    Directory to write the zip into. Default: ./dist
  --name NAME          Base package name. Default: elixirr-skills-package
  --help               Show this help text.

The zip will contain only:
  - README.md
  - skills/
  - automations/
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output-dir)
      [[ $# -ge 2 ]] || { echo "Error: --output-dir requires a value" >&2; exit 1; }
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --name)
      [[ $# -ge 2 ]] || { echo "Error: --name requires a value" >&2; exit 1; }
      PACKAGE_NAME="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Error: Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

command -v zip >/dev/null 2>&1 || {
  echo "Error: zip is required but not installed." >&2
  exit 1
}

mkdir -p "${OUTPUT_DIR}"
OUTPUT_DIR="$(cd "${OUTPUT_DIR}" && pwd)"

STAGING_DIR="$(mktemp -d "${TMPDIR:-/tmp}/elixirr-skills-package.XXXXXX")"
cleanup() {
  rm -rf "${STAGING_DIR}"
}
trap cleanup EXIT

cp "${REPO_ROOT}/README.md" "${STAGING_DIR}/README.md"
cp -R "${REPO_ROOT}/skills" "${STAGING_DIR}/skills"
cp -R "${REPO_ROOT}/automations" "${STAGING_DIR}/automations"

find "${STAGING_DIR}" -name '.DS_Store' -delete
find "${STAGING_DIR}" -name '__pycache__' -type d -prune -exec rm -rf {} +

ZIP_PATH="${OUTPUT_DIR}/${PACKAGE_NAME}.zip"
rm -f "${ZIP_PATH}"

(
  cd "${STAGING_DIR}"
  zip -r "${ZIP_PATH}" README.md skills automations >/dev/null
)

echo "Created package: ${ZIP_PATH}"
