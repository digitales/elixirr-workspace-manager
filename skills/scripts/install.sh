#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DEFAULT_CODEX_HOME="${HOME}/.codex"

CODEX_HOME="${DEFAULT_CODEX_HOME}"
SKILLS_ONLY=0
AUTOMATIONS_ONLY=0
DRY_RUN=0
LIST_ONLY=0

declare -a SELECTED_SKILLS=()
declare -a SELECTED_AUTOMATIONS=()

usage() {
  cat <<'EOF'
Install Elixirr skills and automations into the local Codex home.

Usage:
  ./skills/scripts/install.sh [options]

Options:
  --skill NAME           Install one skill. Can be repeated.
  --automation NAME      Install one automation. Can be repeated.
  --skills-only          Install skills only.
  --automations-only     Install automations only.
  --codex-home PATH      Override the Codex home directory. Default: ~/.codex
  --dry-run              Show planned actions without changing anything.
  --list                 List discovered skills and automations, then exit.
  --help                 Show this help text.

Examples:
  ./skills/scripts/install.sh
  ./skills/scripts/install.sh --dry-run
  ./skills/scripts/install.sh --skill elixirr-memory-refresh --skill elixirr-comms-normalizer
  ./skills/scripts/install.sh --automations-only --automation elixirr-output-sync
EOF
}

log() {
  printf '%s\n' "$*"
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

run_cmd() {
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    printf '[dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

discover_skills() {
  find "${SKILLS_ROOT}" -mindepth 1 -maxdepth 1 -type d \
    -exec test -f '{}/SKILL.md' ';' -print | sort
}

resolve_automations_root() {
  local candidate
  for candidate in "${SKILLS_ROOT}/automations" "$(cd "${SKILLS_ROOT}/.." && pwd)/automations"; do
    if [[ -d "${candidate}" ]]; then
      printf '%s\n' "${candidate}"
      return 0
    fi
  done
  return 1
}

discover_automations() {
  local automations_root="$1"
  find "${automations_root}" -mindepth 1 -maxdepth 1 -type d \
    -exec test -f '{}/automation.toml' ';' -print | sort
}

contains_exact() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    if [[ "${item}" == "${needle}" ]]; then
      return 0
    fi
  done
  return 1
}

copy_skill() {
  local skill_name="$1"
  local source_dir="${SKILLS_ROOT}/${skill_name}"
  local dest_dir="${CODEX_HOME}/skills/${skill_name}"

  [[ -d "${source_dir}" ]] || die "Skill source not found: ${source_dir}"

  log "Installing skill: ${skill_name}"
  run_cmd mkdir -p "${CODEX_HOME}/skills"
  run_cmd rm -rf "${dest_dir}"
  run_cmd cp -R "${source_dir}" "${dest_dir}"
}

copy_automation() {
  local automations_root="$1"
  local automation_name="$2"
  local source_dir="${automations_root}/${automation_name}"
  local dest_dir="${CODEX_HOME}/automations/${automation_name}"
  local source_file="${source_dir}/automation.toml"

  [[ -f "${source_file}" ]] || die "Automation source not found: ${source_file}"

  log "Installing automation: ${automation_name}"
  run_cmd mkdir -p "${dest_dir}"
  run_cmd cp "${source_file}" "${dest_dir}/automation.toml"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skill)
      [[ $# -ge 2 ]] || die "--skill requires a value"
      SELECTED_SKILLS+=("$2")
      shift 2
      ;;
    --automation)
      [[ $# -ge 2 ]] || die "--automation requires a value"
      SELECTED_AUTOMATIONS+=("$2")
      shift 2
      ;;
    --skills-only)
      SKILLS_ONLY=1
      shift
      ;;
    --automations-only)
      AUTOMATIONS_ONLY=1
      shift
      ;;
    --codex-home)
      [[ $# -ge 2 ]] || die "--codex-home requires a value"
      CODEX_HOME="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --list)
      LIST_ONLY=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      die "Unknown argument: $1"
      ;;
  esac
done

if [[ "${SKILLS_ONLY}" -eq 1 && "${AUTOMATIONS_ONLY}" -eq 1 ]]; then
  die "--skills-only and --automations-only cannot be used together"
fi

declare -a AVAILABLE_SKILLS=()
declare -a AVAILABLE_AUTOMATIONS=()

while IFS= read -r path; do
  AVAILABLE_SKILLS+=("$(basename "${path}")")
done < <(discover_skills)

AUTOMATIONS_ROOT=""
if AUTOMATIONS_ROOT="$(resolve_automations_root 2>/dev/null)"; then
  while IFS= read -r path; do
    AVAILABLE_AUTOMATIONS+=("$(basename "${path}")")
  done < <(discover_automations "${AUTOMATIONS_ROOT}")
fi

if [[ "${LIST_ONLY}" -eq 1 ]]; then
  log "Skills:"
  printf '  - %s\n' "${AVAILABLE_SKILLS[@]}"
  if [[ ${#AVAILABLE_AUTOMATIONS[@]} -gt 0 ]]; then
    log ""
    log "Automations:"
    printf '  - %s\n' "${AVAILABLE_AUTOMATIONS[@]}"
  fi
  exit 0
fi

if [[ ${#AVAILABLE_SKILLS[@]} -eq 0 ]]; then
  die "No skills were discovered under ${SKILLS_ROOT}"
fi

declare -a SKILLS_TO_INSTALL=()
declare -a AUTOMATIONS_TO_INSTALL=()
HAS_EXPLICIT_SELECTION=0

if [[ ${#SELECTED_SKILLS[@]} -gt 0 || ${#SELECTED_AUTOMATIONS[@]} -gt 0 ]]; then
  HAS_EXPLICIT_SELECTION=1
fi

if [[ "${AUTOMATIONS_ONLY}" -eq 0 ]]; then
  if [[ ${#SELECTED_SKILLS[@]} -gt 0 ]]; then
    for skill_name in "${SELECTED_SKILLS[@]}"; do
      contains_exact "${skill_name}" "${AVAILABLE_SKILLS[@]}" || die "Unknown skill: ${skill_name}"
      SKILLS_TO_INSTALL+=("${skill_name}")
    done
  elif [[ "${HAS_EXPLICIT_SELECTION}" -eq 0 ]]; then
    SKILLS_TO_INSTALL=("${AVAILABLE_SKILLS[@]}")
  fi
fi

if [[ "${SKILLS_ONLY}" -eq 0 ]]; then
  if [[ ${#SELECTED_AUTOMATIONS[@]} -gt 0 ]]; then
    [[ ${#AVAILABLE_AUTOMATIONS[@]} -gt 0 ]] || die "No automations directory was discovered"
    for automation_name in "${SELECTED_AUTOMATIONS[@]}"; do
      contains_exact "${automation_name}" "${AVAILABLE_AUTOMATIONS[@]}" || die "Unknown automation: ${automation_name}"
      AUTOMATIONS_TO_INSTALL+=("${automation_name}")
    done
  elif [[ "${HAS_EXPLICIT_SELECTION}" -eq 0 && ${#AVAILABLE_AUTOMATIONS[@]} -gt 0 ]]; then
    AUTOMATIONS_TO_INSTALL=("${AVAILABLE_AUTOMATIONS[@]}")
  fi
fi

if [[ ${#SKILLS_TO_INSTALL[@]} -eq 0 && ${#AUTOMATIONS_TO_INSTALL[@]} -eq 0 ]]; then
  die "Nothing to install"
fi

log "Codex home: ${CODEX_HOME}"
log "Skills root: ${SKILLS_ROOT}"
if [[ -n "${AUTOMATIONS_ROOT}" ]]; then
  log "Automations root: ${AUTOMATIONS_ROOT}"
fi
log ""

if [[ ${#SKILLS_TO_INSTALL[@]} -gt 0 ]]; then
  for skill_name in "${SKILLS_TO_INSTALL[@]}"; do
    copy_skill "${skill_name}"
  done
fi

if [[ ${#AUTOMATIONS_TO_INSTALL[@]} -gt 0 ]]; then
  for automation_name in "${AUTOMATIONS_TO_INSTALL[@]}"; do
    copy_automation "${AUTOMATIONS_ROOT}" "${automation_name}"
  done
fi

log ""
log "Install complete."
